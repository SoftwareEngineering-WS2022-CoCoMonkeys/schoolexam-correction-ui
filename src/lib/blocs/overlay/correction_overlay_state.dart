import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

enum CorrectionInputTool { pencil, marker, text, eraser }

class CorrectionOverlayState extends Equatable {
  final int documentNumber;
  final List<CorrectionOverlayDocument> overlays;

  /// The following options define the behavior of the inputs
  final DrawingInputOptions pencilOptions;
  final DrawingInputOptions markerOptions;
  final ColoredInputOptions textOptions;
  final InputOptions eraserOptions;

  final CorrectionInputTool inputTool;

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

  CorrectionOverlayState(
      {this.documentNumber = 0,
      required this.overlays,
      this.inputTool = CorrectionInputTool.pencil,
      DrawingInputOptions? pencilOptions,
      DrawingInputOptions? markerOptions,
      ColoredInputOptions? textOptions,
      InputOptions? eraserOptions})
      : pencilOptions = pencilOptions ??
            DrawingInputOptions.pencil(size: 8, color: Colors.black),
        markerOptions = markerOptions ??
            DrawingInputOptions.marker(size: 8, color: Colors.yellow),
        textOptions =
            markerOptions ?? ColoredInputOptions(size: 8, color: Colors.black),
        eraserOptions = eraserOptions ?? InputOptions(size: 8);

  CorrectionOverlayState.none() : this(documentNumber: 0, overlays: []);

  CorrectionOverlayState changeDocument(
      {required int documentNumber,
      required CorrectionOverlayDocument document}) {
    final updated = List<CorrectionOverlayDocument>.from(overlays);
    updated[documentNumber] = document;

    return copyWith(overlays: updated);
  }

  /// Using this method the page [pageNumber] for the document [documentNumber] is replaced.
  /// Importantly, this returns a general [CorrectionOverlayState] type and should there not be used for state changes occurring through drawings.
  CorrectionOverlayState changePage(
      {required int documentNumber,
      required int pageNumber,
      required CorrectionOverlayPage page}) {
    final updatedPages =
        List<CorrectionOverlayPage>.from(overlays[documentNumber].pages);
    updatedPages[pageNumber] = page;

    return changeDocument(
        documentNumber: documentNumber,
        document: overlays[documentNumber].copyWith(pages: updatedPages));
  }

  UpdatedDrawingsState addInputs(
      {required int documentNumber,
      required int pageNumber,
      required List<CorrectionOverlayInput> inputs}) {
    final updated = changeDocument(
        documentNumber: documentNumber,
        document: overlays[documentNumber]
            .addInputs(pageNumber: pageNumber, inputs: inputs));

    return UpdatedDrawingsState.draw(initial: this, overlays: updated.overlays);
  }

  UpdatedDrawingsState updateInputs(
      {required int documentNumber,
      required int pageNumber,
      required List<CorrectionOverlayInput> inputs}) {
    final updated = changeDocument(
        documentNumber: documentNumber,
        document: overlays[documentNumber]
            .addInputs(pageNumber: pageNumber, inputs: inputs));

    return UpdatedDrawingsState.draw(initial: this, overlays: updated.overlays);
  }

  CorrectionOverlayState copyWith(
          {int? documentNumber,
          List<CorrectionOverlayDocument>? overlays,
          DrawingInputOptions? pencilOptions,
          DrawingInputOptions? markerOptions,
          ColoredInputOptions? textOptions,
          InputOptions? eraserOptions,
          CorrectionInputTool? inputTool}) =>
      CorrectionOverlayState(
          documentNumber: documentNumber ?? this.documentNumber,
          overlays: overlays ?? this.overlays,
          pencilOptions: pencilOptions ?? this.pencilOptions,
          markerOptions: markerOptions ?? this.markerOptions,
          textOptions: textOptions ?? this.textOptions,
          eraserOptions: eraserOptions ?? this.eraserOptions,
          inputTool: inputTool ?? this.inputTool);
}

class UpdatedDrawingsState extends CorrectionOverlayState {
  UpdatedDrawingsState.draw({
    required CorrectionOverlayState initial,
    required List<CorrectionOverlayDocument> overlays,
  }) : super(
            documentNumber: initial.documentNumber,
            overlays: overlays,
            inputTool: initial.inputTool,
            pencilOptions: initial.pencilOptions,
            markerOptions: initial.markerOptions,
            textOptions: initial.textOptions,
            eraserOptions: initial.eraserOptions);
}

class UpdatedInputOptionsState extends CorrectionOverlayState {
  UpdatedInputOptionsState.update(
      {required CorrectionOverlayState initial,
      CorrectionInputTool? inputTool,
      DrawingInputOptions? pencilOptions,
      DrawingInputOptions? markerOptions,
      ColoredInputOptions? textOptions,
      InputOptions? eraserOptions})
      : super(
            documentNumber: initial.documentNumber,
            overlays: initial.overlays,
            inputTool: inputTool ?? initial.inputTool,
            pencilOptions: pencilOptions ?? initial.pencilOptions,
            markerOptions: markerOptions ?? initial.markerOptions,
            textOptions: textOptions ?? initial.textOptions,
            eraserOptions: eraserOptions ?? initial.eraserOptions);
}
