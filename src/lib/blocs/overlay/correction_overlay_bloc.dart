import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam/exams/models/submission.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'correction_overlay_document.dart';
import 'correction_overlay_input.dart';
import 'correction_overlay_page.dart';
import 'correction_overlay_point.dart';
import 'correction_overlay_state.dart';

class CorrectionOverlayCubit extends Cubit<CorrectionOverlayState> {
  final RemarkCubit _remarkCubit;
  late final StreamSubscription _remarkSubscription;

  CorrectionOverlayCubit({required RemarkCubit remarkCubit})
      : _remarkCubit = remarkCubit,
        super(CorrectionOverlayState.none()) {
    _remarkSubscription = remarkCubit.stream.listen(_onRemarkStateChanged);
  }

  Future<CorrectionOverlayDocument> _load(
      {required String path, required Submission submission}) async {
    const bool exists = false;

    late final CorrectionOverlayDocument res;
    if (!exists) {
      log("No local overlay document for $path was found. Creating one.");

      final file = File(path);
      final document = PdfDocument(inputBytes: await file.readAsBytes());

      log("Submission document has ${document.pages.count} page(s).");

      res = CorrectionOverlayDocument(
          submissionId: submission.id,
          path: path,
          pages: List.generate(document.pages.count, (index) {
            final size = document.pages[index].size;
            // DO NOT MAKE const, as no changes are otherwise possible
            return CorrectionOverlayPage(pageSize: size, inputs: []);
          }));
    } else {
      // TODO : Here we would need to load the overlay from storage
    }

    return res;
  }

  void _onRemarkStateChanged(RemarkState state) async {
    /// Added a new correction AND switched to it.
    if (state is AddedCorrectionState) {
      final overlays =
          List<CorrectionOverlayDocument>.from(this.state.overlays);
      final document = await _load(
          path: state.added.submissionPath, submission: state.added.submission);
      overlays.add(document);

      // TODO : Maybe use current answer
      final current = document.pages[0];

      emit(CorrectionOverlayState(current: current, overlays: overlays));
    }
  }

  /// Takes the [lines] and converts them to overlay inputs, using the current remark state for missing information.
  /// Importantly [size] has to be the dimension of the FULL REPRESENTATION OF THE PAGE one is drawing on.
  List<CorrectionOverlayInput> toOverlayInputs(
      {required List<Stroke> lines, required Size size}) {
    final correctionState = state;

    switch (correctionState.inputTool) {
      case CorrectionInputTool.pencil:
        return _convert(
            lines: lines, size: size, options: correctionState.pencilOptions);
      default:
        return [];
    }
  }

  /// Takes the [lines] and [color] to convert them to overlay inputs
  List<CorrectionOverlayInput> _convert(
      {required List<Stroke> lines,
      required Size size,
      required DrawingInputOptions options}) {
    final res = <CorrectionOverlayInput>[];

    for (int i = 0; i < lines.length; ++i) {
      final outlinePoints = getStroke(
        lines[i].points,
        size: options.size * 1.0,
        thinning: options.thinning,
        smoothing: options.smoothing,
        streamline: options.streamline,
        taperStart: options.taperStart,
        capStart: options.capStart,
        taperEnd: options.taperEnd,
        capEnd: options.capEnd,
        simulatePressure: options.simulatePressure,
        isComplete: options.isComplete,
      )
          .map((e) => CorrectionOverlayPoint.fromAbsolute(point: e, size: size))
          .where((element) => !element.isInvalid)
          .toList();

      res.add(
          CorrectionOverlayInput(color: options.color, points: outlinePoints));
    }

    return res;
  }

  /// Adds the [lines] into the correction overlay [document].
  /// Importantly [size] has to be the dimension of the FULL REPRESENTATION OF THE PAGE one is drawing on.
  void addDrawing(
      {required CorrectionOverlayDocument document,
      required List<Stroke> lines,
      required Size size}) async {
    log("Adding new drawings");

    final overlayState = state;

    final documentNumber = overlayState.overlays
        .indexWhere((element) => element.path == document.path, -1);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.path}");
      return;
    }

    final updatedState = state.addInputs(
        documentNumber: documentNumber,
        pageNumber: overlayState.overlays[documentNumber].pageNumber,
        inputs: toOverlayInputs(lines: lines, size: size));

    emit(updatedState);
  }

  /// Updates the lastly added line to match [line] within the correction overlay [document].
  /// Importantly [size] has to be the dimension of the FULL REPRESENTATION OF THE PAGE one is drawing on.
  void updateLine(
      {required CorrectionOverlayDocument document,
      required Stroke line,
      required Size size}) async {
    final overlayState = state;

    final documentNumber = overlayState.overlays
        .indexWhere((element) => element.path == document.path, -1);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.path}");
      return;
    }

    final updatedState = state.updateInput(
        index: overlayState
                .overlays[documentNumber]
                .pages[overlayState.overlays[documentNumber].pageNumber]
                .inputs
                .length -
            1,
        documentNumber: documentNumber,
        pageNumber: overlayState.overlays[documentNumber].pageNumber,
        input: toOverlayInputs(lines: [line], size: size)[0]);

    emit(updatedState);
  }

  void changePencilOptions(DrawingInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, pencilOptions: options));

  void changeMarkerOptions(DrawingInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, markerOptions: options));

  void changeTextOptions(ColoredInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, textOptions: options));

  void changeEraserOptions(InputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, eraserOptions: options));

  void changeTool(CorrectionInputTool inputTool) => emit(
      UpdatedInputOptionsState.update(initial: state, inputTool: inputTool));

  void jumpToPage(
      {required CorrectionOverlayDocument document, required int pageNumber}) {
    final overlayState = state;

    final documentNumber = overlayState.overlays
        .indexWhere((element) => element.path == document.path, -1);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.path}");
      return;
    }

    if (pageNumber < 0 ||
        pageNumber >= overlayState.overlays[documentNumber].pages.length) {
      log("Not jumping to invalid page $pageNumber");
      return;
    }

    log("Jumping from ${document.pageNumber} to $pageNumber within ${document.path}");
    final updated = overlayState.changeDocument(
        documentNumber: documentNumber,
        document: overlayState.overlays[documentNumber]
            .copyWith(pageNumber: pageNumber));

    emit(updated);
  }

  @override
  Future<void> close() async {
    _remarkSubscription.cancel();
    return super.close();
  }
}
