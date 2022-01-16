import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

enum CorrectionInputTool { pencil, marker, text, eraser }

abstract class CorrectionOverlayState extends Equatable {
  final int documentNumber;
  final List<CorrectionOverlayDocument> overlays;

  /// The following options define the behavior of the inputs
  final DrawingInputOptions pencilOptions;
  final DrawingInputOptions markerOptions;
  final ColoredInputOptions textOptions;
  final InputOptions eraserOptions;

  final CorrectionInputTool inputTool;

  /// Callback to retrieve the updated document from the state.
  /// This allows to centralize the logic, while allowing widgets to define their rebuild logic based on state changes.
  CorrectionOverlayDocument getCurrent(Correction initial) =>
      overlays.firstWhere(
          (element) => element.submissionId == initial.submission.id,
          orElse: () => CorrectionOverlayDocument.empty);

  @override
  List<Object?> get props => [
        documentNumber,
        overlays,
        pencilOptions,
        markerOptions,
        textOptions,
        eraserOptions,
        inputTool
      ];

  const CorrectionOverlayState._(
      {this.documentNumber = 0,
      required this.overlays,
      this.inputTool = CorrectionInputTool.pencil,
      DrawingInputOptions? pencilOptions,
      DrawingInputOptions? markerOptions,
      ColoredInputOptions? textOptions,
      InputOptions? eraserOptions})
      : pencilOptions = pencilOptions ??
            const DrawingInputOptions.pencil(size: 4, color: Colors.black),
        markerOptions = markerOptions ??
            const DrawingInputOptions.marker(size: 4, color: Colors.yellow),
        // TODO : Find pdf library with opacity support ...
        /*DrawingInputOptions.marker(
                size: 4, color: Colors.yellow.withOpacity(0.5)),*/
        textOptions = textOptions ??
            const ColoredInputOptions(size: 4, color: Colors.black),
        eraserOptions = eraserOptions ?? const InputOptions(size: 4);

  /// Using this method the document [documentNumber] is replaced.
  static List<CorrectionOverlayDocument> _changeDocument(
      {required CorrectionOverlayState initial,
      required int documentNumber,
      required CorrectionOverlayDocument document}) {
    assert(documentNumber < initial.overlays.length);

    final updated = List<CorrectionOverlayDocument>.from(initial.overlays);
    updated[documentNumber] = document;
    return updated;
  }

  /// Using this method the page [pageNumber] for the document [documentNumber] is replaced.
  static List<CorrectionOverlayDocument> _changePage(
      {required CorrectionOverlayState initial,
      required int documentNumber,
      required int pageNumber,
      required CorrectionOverlayPage page}) {
    assert(documentNumber < initial.overlays.length);
    assert(pageNumber < initial.overlays[documentNumber].pages.length);

    final updatedPages = List<CorrectionOverlayPage>.from(
        initial.overlays[documentNumber].pages);
    updatedPages[pageNumber] = page;

    return CorrectionOverlayState._changeDocument(
        initial: initial,
        documentNumber: documentNumber,
        document:
            initial.overlays[documentNumber].copyWith(pages: updatedPages));
  }
}

/// Document was nearly added
abstract class LoadedOverlayState extends CorrectionOverlayState {
  const LoadedOverlayState._(
      {required List<CorrectionOverlayDocument> overlays,
      int? documentNumber,
      CorrectionInputTool? inputTool,
      DrawingInputOptions? pencilOptions,
      DrawingInputOptions? markerOptions,
      ColoredInputOptions? textOptions,
      InputOptions? eraserOptions})
      : super._(
            documentNumber: documentNumber ?? 0,
            overlays: overlays,
            inputTool: inputTool ?? CorrectionInputTool.pencil,
            pencilOptions: pencilOptions,
            markerOptions: markerOptions,
            textOptions: textOptions,
            eraserOptions: eraserOptions);
}

class InitialOverlayState extends LoadedOverlayState {
  InitialOverlayState() : super._(documentNumber: 0, overlays: []);
}

/// Added
class AddedCorrectionOverlayState extends LoadedOverlayState {
  final CorrectionOverlayDocument added;

  AddedCorrectionOverlayState.add(
      {required CorrectionOverlayState initial, required this.added})
      : super._(
            overlays: List<CorrectionOverlayDocument>.from(initial.overlays)
              ..add(added),
            documentNumber: initial.overlays.length);
}

/// Removed
class RemovedCorrectionOverlayState extends LoadedOverlayState {
  final CorrectionOverlayDocument removed;

  RemovedCorrectionOverlayState.remove(
      {required CorrectionOverlayState initial, required this.removed})
      : super._(
            overlays: List<CorrectionOverlayDocument>.from(initial.overlays)
              ..removeWhere(
                  (element) => element.submissionId == removed.submissionId),
            documentNumber: initial.overlays.length);
}

/// The user navigated to a new page, loaded e.g. a new document ...
class UpdatedNavigationState extends LoadedOverlayState {
  UpdatedNavigationState.jump(
      {required CorrectionOverlayState initial,
      required int documentNumber,
      required int page})
      : super._(
            documentNumber: initial.documentNumber,
            overlays: CorrectionOverlayState._changeDocument(
                initial: initial,
                documentNumber: documentNumber,
                document: initial.overlays[documentNumber]
                    .copyWith(pageNumber: page)),
            inputTool: initial.inputTool,
            pencilOptions: initial.pencilOptions,
            markerOptions: initial.markerOptions,
            textOptions: initial.textOptions,
            eraserOptions: initial.eraserOptions);
}

/// Applied a change to the document overlay without using an input tool.
class RevertedDrawingsState extends LoadedOverlayState {
  RevertedDrawingsState.revert(
      {required CorrectionOverlayState initial,
      required int documentNumber,
      required int pageNumber,
      required CorrectionOverlayPage page})
      : super._(
            documentNumber: initial.documentNumber,
            overlays: CorrectionOverlayState._changePage(
                initial: initial,
                documentNumber: documentNumber,
                pageNumber: pageNumber,
                page: page),
            inputTool: initial.inputTool,
            pencilOptions: initial.pencilOptions,
            markerOptions: initial.markerOptions,
            textOptions: initial.textOptions,
            eraserOptions: initial.eraserOptions);
}

/// Applied a change to the document overlay with using an input tool.
class UpdatedDrawingsState extends LoadedOverlayState {
  UpdatedDrawingsState.draw({
    required CorrectionOverlayState initial,
    required List<CorrectionOverlayDocument> overlays,
  }) : super._(
            documentNumber: initial.documentNumber,
            overlays: overlays,
            inputTool: initial.inputTool,
            pencilOptions: initial.pencilOptions,
            markerOptions: initial.markerOptions,
            textOptions: initial.textOptions,
            eraserOptions: initial.eraserOptions);

  static UpdatedDrawingsState addInputs(
          {required CorrectionOverlayState initial,
          required int documentNumber,
          required int pageNumber,
          required List<CorrectionOverlayInput> inputs}) =>
      UpdatedDrawingsState.draw(
          overlays: CorrectionOverlayState._changeDocument(
              documentNumber: documentNumber,
              document: initial.overlays[documentNumber]
                  .addInputs(pageNumber: pageNumber, inputs: inputs),
              initial: initial),
          initial: initial);

  static UpdatedDrawingsState updateInputs(
          {required CorrectionOverlayState initial,
          required int documentNumber,
          required int pageNumber,
          required List<CorrectionOverlayInput> inputs}) =>
      UpdatedDrawingsState.draw(
          overlays: CorrectionOverlayState._changeDocument(
              initial: initial,
              documentNumber: documentNumber,
              document: initial.overlays[documentNumber]
                  .addInputs(pageNumber: pageNumber, inputs: inputs)),
          initial: initial);

  static UpdatedDrawingsState replaceDrawings(
          {required CorrectionOverlayState initial,
          required int documentNumber,
          required int pageNumber,
          required List<CorrectionOverlayInput> inputs}) =>
      UpdatedDrawingsState.draw(
          overlays: CorrectionOverlayState._changePage(
              initial: initial,
              documentNumber: documentNumber,
              pageNumber: pageNumber,
              page: initial.overlays[documentNumber].pages[pageNumber].copyWith(
                  inputs: inputs,
                  version: initial
                          .overlays[documentNumber].pages[pageNumber].version +
                      1)),
          initial: initial);
}

/// The user changes the behavior of the input tools.
class UpdatedInputOptionsState extends LoadedOverlayState {
  UpdatedInputOptionsState.update(
      {required CorrectionOverlayState initial,
      CorrectionInputTool? inputTool,
      DrawingInputOptions? pencilOptions,
      DrawingInputOptions? markerOptions,
      ColoredInputOptions? textOptions,
      InputOptions? eraserOptions})
      : super._(
            documentNumber: initial.documentNumber,
            overlays: initial.overlays,
            inputTool: inputTool ?? initial.inputTool,
            pencilOptions: pencilOptions ?? initial.pencilOptions,
            markerOptions: markerOptions ?? initial.markerOptions,
            textOptions: textOptions ?? initial.textOptions,
            eraserOptions: eraserOptions ?? initial.eraserOptions);
}
