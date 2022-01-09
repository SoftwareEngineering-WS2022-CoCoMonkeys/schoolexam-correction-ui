import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';

import 'correction.dart';

enum RemarkInputTool { pencil, marker, text, eraser }

class RemarkState extends Equatable {
  /// We may only provide remarks for one exam at the time. This contains information about the subject, participants etc.
  final Exam exam;

  /// All submissions currently known to the system. The user may start corrections from any of these.
  final List<Submission> submissions;

  /// Defines which correction is currently being worked on
  /// If corrections is empty, no correction is active
  final int selectedCorrection;
  final List<Correction> corrections;

  /// The following options define the behavior of the inputs
  final DrawingInputOptions pencilOptions;
  final DrawingInputOptions markerOptions;
  final ColoredInputOptions textOptions;
  final InputOptions eraserOptions;

  final RemarkInputTool inputTool;

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
}

/// Starting the overall correction for an exam. No submission can yet be actively corrected.
class StartedCorrectionState extends RemarkState {
  StartedCorrectionState.start(
      {required Exam exam, required List<Submission> submissions})
      : super._(exam: exam, submissions: submissions, corrections: []);
}

/// Added a new correction for active working.
class AddedCorrectionState extends RemarkState {
  final Correction added;

  AddedCorrectionState.add({required RemarkState initial, required this.added})
      : super._(
            exam: initial.exam,
            selectedCorrection: initial.corrections.length,
            submissions: initial.submissions,
            corrections: <Correction>[...initial.corrections]..add(added),
            inputTool: initial.inputTool,
            pencilOptions: initial.pencilOptions,
            markerOptions: initial.markerOptions,
            textOptions: initial.textOptions,
            eraserOptions: initial.eraserOptions);
}

class SwitchedCorrectionState extends RemarkState {
  SwitchedCorrectionState.change(
      {required RemarkState initial, required int selectedCorrection})
      : super._(
            exam: initial.exam,
            selectedCorrection: (selectedCorrection >= 0 &&
                    selectedCorrection < initial.corrections.length)
                ? selectedCorrection
                : initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: initial.corrections,
            inputTool: initial.inputTool,
            pencilOptions: initial.pencilOptions,
            markerOptions: initial.markerOptions,
            textOptions: initial.textOptions,
            eraserOptions: initial.eraserOptions);
}

class UpdatedInputOptionsState extends RemarkState {
  UpdatedInputOptionsState.update(
      {required RemarkState initial,
      RemarkInputTool? inputTool,
      DrawingInputOptions? pencilOptions,
      DrawingInputOptions? markerOptions,
      ColoredInputOptions? textOptions,
      InputOptions? eraserOptions})
      : super._(
            exam: initial.exam,
            selectedCorrection: initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: initial.corrections,
            inputTool: inputTool ?? initial.inputTool,
            pencilOptions: pencilOptions ?? initial.pencilOptions,
            markerOptions: markerOptions ?? initial.markerOptions,
            textOptions: textOptions ?? initial.textOptions,
            eraserOptions: eraserOptions ?? initial.eraserOptions);
}