import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam/exams/models/submission.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'correction_overlay_state.dart';

class CorrectionOverlayCubit extends Cubit<CorrectionOverlayState> {
  // Internal revision history for in memory pages
  static const int _maximumHistorySize = 20;
  final Map<String, Queue<CorrectionOverlayPage>> _pageHistory;
  //

  final CorrectionOverlayRepository _correctionOverlayRepository;
  final RemarkCubit _remarkCubit;
  late final StreamSubscription _remarkSubscription;
  late final StreamSubscription _correctionSubscription;

  CorrectionOverlayCubit(
      {required CorrectionOverlayRepository correctionOverlayRepository,
      required RemarkCubit remarkCubit})
      : _correctionOverlayRepository = correctionOverlayRepository,
        _remarkCubit = remarkCubit,
        _pageHistory = <String, Queue<CorrectionOverlayPage>>{},
        super(InitialOverlayState()) {
    _remarkSubscription = remarkCubit.stream.listen(_onRemarkStateChanged);
    _correctionSubscription = stream.listen(_onSelfStateChanged);
  }

  /// Listener enacting necessary changes to the correction state, given the remark state changes.
  /// This may include the inclusion or exclusion of submissions in the correcting process.
  void _onRemarkStateChanged(RemarkState state) async {
    /// Added a new correction AND switched to it.
    if (state is AddedCorrectionState) {
      final overlays =
          List<CorrectionOverlayDocument>.from(this.state.overlays);
      final document = await _load(
          path: state.added.submissionPath, submission: state.added.submission);

      emit(LoadedOverlayState.add(initial: this.state, document: document));
    }
  }

  /// Listener, that updates the internal history of pages (identified by instanceId).
  void _onSelfStateChanged(CorrectionOverlayState state) {
    if (state is! UpdatedDrawingsState) {
      return;
    }

    final currentDocument = state.overlays[state.documentNumber];
    final currentPage = currentDocument.pages[currentDocument.pageNumber];
    _pageHistory.putIfAbsent(
        currentPage.instanceId, () => Queue.from(<CorrectionOverlayPage>[]));

    // Constraint the history size to prevent memory blowup
    final _currentHistory = _pageHistory[currentPage.instanceId]!;

    if (_currentHistory.length == _maximumHistorySize) {
      _currentHistory.removeLast();
    }

    // Cut of history of alternate timeline
    if (_currentHistory.isNotEmpty) {
      _currentHistory
          .removeWhere((element) => element.version >= currentPage.version);
    }

    _currentHistory.addFirst(currentPage);
  }

  /// Using the specified [submission] and [path] pointing to the local location of the submission PDF,
  /// the corresponding overlay document is loaded. If no overlay document exists yet, it is created without inputs and locally persisted.
  Future<CorrectionOverlayDocument> _load(
      {required String path, required Submission submission}) async {
    final document = await _correctionOverlayRepository.getDocument(
        submissionId: submission.id);

    late final CorrectionOverlayDocument res;
    if (document.isEmpty) {
      log("No local overlay document for ${submission.id} was found. Creating one.");

      final file = File(path);
      final sDocument = PdfDocument(inputBytes: await file.readAsBytes());

      log("Submission document has ${sDocument.pages.count} page(s).");

      res = CorrectionOverlayDocument(
          submissionId: submission.id,
          pages: List.generate(sDocument.pages.count, (index) {
            final size = sDocument.pages[index].size;
            // DO NOT MAKE const, as no changes are otherwise possible
            return CorrectionOverlayPage(pageSize: size, inputs: []);
          }));

      await _correctionOverlayRepository.saveDocument(document: res);
    } else {
      log("The document was successfully retrieved from the local persistence layer.");
      log("Overlay document has ${document.pages.length} page(s) and ${document.pages.map((e) => e.inputs.length).reduce((a, b) => a + b)} input(s).");

      res = document;
    }

    return res;
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

  /// Tries to determine the index to the [document] within the given [state].
  /// Returns a number smaller then 0, if the [document] is not contained within [state].
  int _getDocumentNumber(
          {required CorrectionOverlayState state,
          required CorrectionOverlayDocument document}) =>
      state.overlays.indexWhere(
          (element) => element.submissionId == document.submissionId, -1);

  /// Takes the [lines] and converts them to overlay inputs, using the current remark state for missing information.
  /// Importantly [size] has to be the dimension of the FULL REPRESENTATION OF THE PAGE one is drawing on.
  List<CorrectionOverlayInput> toOverlayInputs(
      {required List<Stroke> lines, required Size size}) {
    final correctionState = state;

    switch (correctionState.inputTool) {
      case CorrectionInputTool.pencil:
        return _convert(
            lines: lines, size: size, options: correctionState.pencilOptions);
      case CorrectionInputTool.marker:
        return _convert(
            lines: lines, size: size, options: correctionState.markerOptions);
      default:
        return [];
    }
  }

  /// Adds the [lines] into the correction overlay [document].
  /// Importantly [size] has to be the dimension of the FULL REPRESENTATION OF THE PAGE one is drawing on.
  void addDrawing(
      {required CorrectionOverlayDocument document,
      required List<Stroke> lines,
      required Size size}) async {
    log("Adding new drawings");
    final correctionState = state;
    final documentNumber =
        _getDocumentNumber(state: correctionState, document: document);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.submissionId}");
      return;
    }

    final updatedState = UpdatedDrawingsState.addInputs(
        initial: correctionState,
        documentNumber: documentNumber,
        pageNumber: correctionState.overlays[documentNumber].pageNumber,
        inputs: toOverlayInputs(lines: lines, size: size));

    emit(updatedState);
  }

  /// Replaces all drawings in the current page within [document] with [inputs].
  /// Use this function with caution, as you are practically destroying previous work of a user.
  void replaceDrawings(
      {required CorrectionOverlayDocument document,
      required List<CorrectionOverlayInput> inputs}) async {
    log("Updating drawings from external source");
    final correctionState = state;
    final documentNumber =
        _getDocumentNumber(state: correctionState, document: document);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.submissionId}");
      return;
    }

    final pageNumber = correctionState.overlays[documentNumber].pageNumber;

    emit(UpdatedDrawingsState.replaceDrawings(
        initial: correctionState,
        documentNumber: documentNumber,
        pageNumber: pageNumber,
        inputs: inputs));
  }

  void changePencilOptions(DrawingInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, pencilOptions: options));

  void changeMarkerOptions(DrawingInputOptions options) =>
      emit(UpdatedInputOptionsState.update(
          initial: state,
          markerOptions:
              options.copyWith(color: options.color.withOpacity(0.5))));

  void changeTextOptions(ColoredInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, textOptions: options));

  void changeEraserOptions(InputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, eraserOptions: options));

  void changeTool(CorrectionInputTool inputTool) => emit(
      UpdatedInputOptionsState.update(initial: state, inputTool: inputTool));

  void jumpToPage(
      {required CorrectionOverlayDocument document, required int pageNumber}) {
    final correctionState = state;
    final documentNumber =
        _getDocumentNumber(state: correctionState, document: document);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.submissionId}");
      return;
    }

    if (pageNumber < 0 ||
        pageNumber >= correctionState.overlays[documentNumber].pages.length) {
      log("Not jumping to invalid page $pageNumber");
      return;
    }

    log("Jumping from ${document.pageNumber} to $pageNumber within ${document.submissionId}");
    emit(UpdatedNavigationState.jump(
        initial: correctionState,
        documentNumber: documentNumber,
        page: pageNumber));
  }

  /// If possible, an undo of the last change is applied to the current page of [document].
  Future<void> undo({required CorrectionOverlayDocument document}) async {
    final correctionState = state;
    final documentNumber =
        _getDocumentNumber(state: correctionState, document: document);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.submissionId}");
      return;
    }

    final stateDocument = correctionState.overlays[documentNumber];
    final statePage = stateDocument.pages[stateDocument.pageNumber];

    if (statePage.version <= 0) {
      log("Page is already in initial version. Applying no undo.");
      return;
    }

    final undoPage = _pageHistory[statePage.instanceId]!.lastWhere(
        (element) => element.version == statePage.version - 1,
        orElse: () => CorrectionOverlayPage.empty);

    if (undoPage.isEmpty) {
      log("History does not contain the version ${statePage.version - 1}");
      return;
    }

    final updated = RevertedDrawingsState.revert(
        initial: correctionState,
        documentNumber: documentNumber,
        pageNumber: stateDocument.pageNumber,
        page: undoPage);
    emit(updated);
  }

  /// If possible, redo  is applied to the current page of [document].
  Future<void> redo({required CorrectionOverlayDocument document}) async {
    final correctionState = state;
    final documentNumber =
        _getDocumentNumber(state: correctionState, document: document);

    if (documentNumber < 0) {
      log("Found no existing overlay document for ${document.submissionId}");
      return;
    }

    final stateDocument = correctionState.overlays[documentNumber];
    final statePage = stateDocument.pages[stateDocument.pageNumber];

    final redoPage = _pageHistory[statePage.instanceId]!.lastWhere(
        (element) => element.version == statePage.version + 1,
        orElse: () => CorrectionOverlayPage.empty);

    if (redoPage.isEmpty) {
      log("The version ${statePage.version} is the most up-to date version known to the history.");
      return;
    }

    final updated = RevertedDrawingsState.revert(
        initial: correctionState,
        documentNumber: documentNumber,
        pageNumber: stateDocument.pageNumber,
        page: redoPage);
    emit(updated);
  }

  @override
  Future<void> close() async {
    super.close();
    await _remarkSubscription.cancel();
    await _correctionSubscription.cancel();
  }
}
