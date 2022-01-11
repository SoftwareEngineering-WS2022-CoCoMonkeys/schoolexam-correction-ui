import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';

import 'correction_overlay_document.dart';
import 'correction_overlay_input.dart';
import 'correction_overlay_page.dart';

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

  CorrectionOverlayState addInputs(
      {required int documentNumber,
      required int pageNumber,
      required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayDocument>.from(overlays);
    updated[documentNumber] = overlays[documentNumber]
        .addInputs(pageNumber: pageNumber, inputs: inputs);

    return CorrectionOverlayState(
        current: updated[documentNumber].pages[pageNumber], overlays: updated);
  }

  CorrectionOverlayState updateInput(
      {required int documentNumber,
      required int pageNumber,
      required int index,
      required CorrectionOverlayInput input}) {
    final updated = List<CorrectionOverlayDocument>.from(overlays);
    updated[documentNumber] = overlays[documentNumber]
        .updateInput(pageNumber: pageNumber, index: index, input: input);

    return CorrectionOverlayState(
        current: updated[documentNumber].pages[pageNumber], overlays: updated);
  }

  @override
  List<Object?> get props => [current, overlays];
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
