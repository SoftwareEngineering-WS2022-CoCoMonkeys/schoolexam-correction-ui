import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';

import 'correction.dart';

enum RemarkInputTool { pencil, marker, text, eraser }

class RemarkState extends Equatable {
  final Exam exam;
  final List<Submission> submissions;

  final int selectedCorrection;
  final List<Correction> corrections;

  /// The following options define the behavior of the inputs
  final DrawingInputOptions pencilOptions;
  final DrawingInputOptions markerOptions;
  final ColoredInputOptions textOptions;
  final InputOptions eraserOptions;

  final RemarkInputTool inputTool;

  @override
  List<Object> get props => [
        exam,
        submissions,
        selectedCorrection,
        corrections,
        pencilOptions,
        markerOptions,
        textOptions,
        eraserOptions,
        inputTool
      ];

  RemarkState._(
      {this.exam = Exam.empty,
      this.selectedCorrection = 0,
      this.inputTool = RemarkInputTool.pencil,
      required this.submissions,
      required this.corrections,
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

  RemarkState.none() : this._(submissions: [], corrections: []);

  RemarkState.start({required Exam exam, required List<Submission> submissions})
      : this._(exam: exam, submissions: submissions, corrections: []);

  RemarkState copyWith(
      {List<Correction>? corrections,
      RemarkInputTool? inputTool,
      DrawingInputOptions? pencilOptions,
      DrawingInputOptions? markerOptions,
      ColoredInputOptions? textOptions,
      InputOptions? eraserOptions}) {
    return RemarkState._(
        exam: exam,
        submissions: submissions,
        corrections: corrections ?? this.corrections,
        inputTool: inputTool ?? this.inputTool,
        pencilOptions: pencilOptions ?? this.pencilOptions,
        markerOptions: markerOptions ?? this.markerOptions,
        textOptions: textOptions ?? this.textOptions,
        eraserOptions: eraserOptions ?? this.eraserOptions);
  }
}
