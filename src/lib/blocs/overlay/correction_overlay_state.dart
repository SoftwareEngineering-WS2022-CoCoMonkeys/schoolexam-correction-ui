import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

enum CorrectionInputTool { pencil, marker, text, eraser }

class CorrectionOverlayState extends Equatable {
  final CorrectionOverlayPage current;
  final List<CorrectionOverlayDocument> overlays;

  /// The following options define the behavior of the inputs
  final DrawingInputOptions pencilOptions;
  final DrawingInputOptions markerOptions;
  final ColoredInputOptions textOptions;
  final InputOptions eraserOptions;

  final CorrectionInputTool inputTool;

  @override
  List<Object?> get props => [
        current,
        overlays,
        pencilOptions,
        markerOptions,
        textOptions,
        eraserOptions,
        inputTool
      ];

  CorrectionOverlayState(
      {required this.current,
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

  CorrectionOverlayState.none()
      : this(current: CorrectionOverlayPage.empty, overlays: []);

  CorrectionOverlayState changeDocument(
      {required int documentNumber,
      required CorrectionOverlayDocument document}) {
    final updated = List<CorrectionOverlayDocument>.from(overlays);
    updated[documentNumber] = document;

    return CorrectionOverlayState(current: current, overlays: updated);
  }

  CorrectionOverlayState addInputs(
      {required int documentNumber,
      required int pageNumber,
      required List<CorrectionOverlayInput> inputs}) {
    final updated = changeDocument(
        documentNumber: documentNumber,
        document: overlays[documentNumber]
            .addInputs(pageNumber: pageNumber, inputs: inputs));

    return CorrectionOverlayState(
        current: updated.overlays[documentNumber].pages[pageNumber],
        overlays: updated.overlays);
  }

  CorrectionOverlayState updateInput(
      {required int documentNumber,
      required int pageNumber,
      required int index,
      required CorrectionOverlayInput input}) {
    final updated = changeDocument(
        documentNumber: documentNumber,
        document: overlays[documentNumber]
            .updateInput(pageNumber: pageNumber, index: index, input: input));

    return CorrectionOverlayState(
        current: updated.overlays[documentNumber].pages[pageNumber],
        overlays: updated.overlays);
  }
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
            current: initial.current,
            overlays: initial.overlays,
            inputTool: inputTool ?? initial.inputTool,
            pencilOptions: pencilOptions ?? initial.pencilOptions,
            markerOptions: markerOptions ?? initial.markerOptions,
            textOptions: textOptions ?? initial.textOptions,
            eraserOptions: eraserOptions ?? initial.eraserOptions);
}
