import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_input.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/overlay_page.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'overlay_document.dart';

class OverlayCubit extends Cubit<OverlayState> {
  final RemarkCubit _remarkCubit;
  late final StreamSubscription _remarkSubscription;

  OverlayCubit({required RemarkCubit remarkCubit})
      : _remarkCubit = remarkCubit,
        super(OverlayState.none()) {
    _remarkSubscription = remarkCubit.stream.listen(_onRemarkStateChanged);
  }

  Future<OverlayDocument> _load({required String path}) async {
    const bool exists = false;

    late final OverlayDocument res;
    if (!exists) {
      final file = File(path);
      final document = PdfDocument(inputBytes: await file.readAsBytes());
      res = OverlayDocument(
          path: path,
          pages: List.generate(
              document.pages.count, (index) => OverlayPage(inputs: [])));
    } else {
      // TODO : Here we would need to load the overlay from storage
    }

    return res;
  }

  void _onRemarkStateChanged(RemarkState state) async {
    /// Added a new correction AND switched to it.
    if (state is AddedCorrectionState) {
      final overlays = List<OverlayDocument>.from(this.state.overlays);
      final document = await _load(path: state.added.correctionPath);
      overlays.add(document);

      final current = document
          .pages[state.corrections[state.selectedCorrection].pageNumber];

      emit(OverlayState(current: current, overlays: overlays));
    }
  }

  /// Takes the [lines] and converts them to overlay inputs, using the current remark state for missing information.
  List<OverlayInput> toOverlayInputs({required List<Stroke> lines}) {
    final _remarkState = _remarkCubit.state;

    switch (_remarkState.inputTool) {
      case RemarkInputTool.pencil:
        return _convert(lines: lines, options: _remarkState.pencilOptions);
      default:
        return [];
    }
  }

  /// Takes the [lines] and [color] to convert them to overlay inputs
  List<OverlayInput> _convert(
      {required List<Stroke> lines, required DrawingInputOptions options}) {
    final res = <OverlayInput>[];

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
      );

      res.add(OverlayInput(color: options.color, points: outlinePoints));
    }

    return res;
  }

  /// Adds the [lines] into the correction overlay.
  void addDrawing({required List<Stroke> lines}) {
    log("Adding new drawings");

    final remarkState = _remarkCubit.state;
    final overlayState = state;

    final currentCorrection =
        remarkState.corrections[remarkState.selectedCorrection];

    final documentNumber = overlayState.overlays.indexWhere(
        (element) => element.path == currentCorrection.correctionPath, -1);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${currentCorrection.correctionPath}");
      return;
    }

    emit(state.addInputs(
        documentNumber: documentNumber,
        pageNumber: currentCorrection.pageNumber,
        inputs: toOverlayInputs(lines: lines)));
  }

  /// Updates the lastly added line to match [line]
  void updateLine({required Stroke line}) {
    final remarkState = _remarkCubit.state;
    final overlayState = state;

    final currentCorrection =
        remarkState.corrections[remarkState.selectedCorrection];

    final documentNumber = overlayState.overlays.indexWhere(
        (element) => element.path == currentCorrection.correctionPath, -1);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${currentCorrection.correctionPath}");
      return;
    }

    emit(state.updateInput(
        index: overlayState.overlays[documentNumber]
                .pages[currentCorrection.pageNumber].inputs.length -
            1,
        documentNumber: documentNumber,
        pageNumber: currentCorrection.pageNumber,
        input: toOverlayInputs(lines: [line])[0]));
  }
}
