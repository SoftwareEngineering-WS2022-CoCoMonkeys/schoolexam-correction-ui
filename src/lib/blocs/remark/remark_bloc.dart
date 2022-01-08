import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/stroke.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'correction.dart';
import 'remark_state.dart';

class RemarkCubit extends Cubit<RemarkState> {
  late final StreamSubscription _navigationSubscription;
  final ExamsRepository _examsRepository;

  RemarkCubit(
      {required ExamsRepository examsRepository,
      required NavigationCubit navigationCubit})
      : _examsRepository = examsRepository,
        super(RemarkState.none()) {
    _navigationSubscription = navigationCubit.stream.listen(_onNavigationState);
  }

  void _onNavigationState(AppNavigationState state) async {
    log("Observed navigation switch : $state");
    if (state.context != AppNavigationContext.exams) {
      return;
    }
    if (state.examId.isEmpty) {
      return;
    }

    await correct(await _examsRepository.getExam(state.examId));
  }

  Future<void> correct(Exam exam) async {
    final submissions = await _examsRepository.getSubmissions(examId: exam.id);

    log("Determined submissions : $submissions");

    var state = RemarkState.start(exam: exam, submissions: submissions);

    emit(state);
  }

  Future<void> open(Submission submission) async {
    log("Requested to correct submission $submission");

    // TODO : Ensures state change, however inefficient copy
    // TODO : Equality check
    final corrections = <Correction>{...state.corrections};
    corrections.add(await Correction.start(submission: submission));

    // Switch active pdf
    var newState =
        state.copyWith(corrections: corrections.toList(growable: false));

    emit(newState);
  }

  Future<void> _addDrawing(
      {required List<Stroke> lines,
      required DrawingInputOptions options}) async {
    // Cant be persisted. I literally want to cry. Why are all the PDF libraries bs...
    final document = PdfDocument(
        inputBytes: state.corrections[state.selectedCorrection].correction);
    // TODO : Obtain from valid current page
    final page = document.pages[0];

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

      // Empty
      if (outlinePoints.isEmpty) {
        continue;
      }
      // Dot
      else if (outlinePoints.length < 2) {
        page.graphics.drawEllipse(Rect.fromCircle(
            center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
      }
      // Path
      else {
        final path = PdfPath();

        page.graphics.drawPolygon(
            outlinePoints.map((e) => Offset(e.x, e.y)).toList(),
            brush: PdfBrushes.black);
      }
    }

    final res = document.save();
    document.dispose();

    var updatedState = UpdatedRemarks.update(
        state: state, correction: Uint8List.fromList(res));

    emit(updatedState);
  }

  void addDrawing(List<Stroke> lines) async {
    switch (state.inputTool) {
      case RemarkInputTool.pencil:
        await _addDrawing(lines: lines, options: state.pencilOptions);
        break;
      default:
        return;
    }
  }

  void changePencilOptions(DrawingInputOptions options) =>
      emit(state.copyWith(pencilOptions: options));

  void changeMarkerOptions(DrawingInputOptions options) =>
      emit(state.copyWith(markerOptions: options));

  void changeTextOptions(ColoredInputOptions options) =>
      emit(state.copyWith(textOptions: options));

  void changeEraserOptions(InputOptions options) =>
      emit(state.copyWith(eraserOptions: options));

  void changeTool(RemarkInputTool inputTool) =>
      emit(state.copyWith(inputTool: inputTool));

  void moveTo(Task task) {
    log("Requested to move to $task");

    if (state.corrections.isEmpty) {
      log("No corrections currently present.");
      return;
    }

    // TODO : Ensures state change. However, this copy seems rather ugly
    var corrections = <Correction>[...state.corrections];
    corrections[state.selectedCorrection] =
        corrections[state.selectedCorrection].copyWith(
            currentAnswer: corrections[state.selectedCorrection]
                .submission
                .answers
                .firstWhere((element) => element.task.id == task.id,
                    orElse: () => Answer.empty));

    emit(state.copyWith(corrections: corrections));
  }

  @override
  Future<void> close() async {
    _navigationSubscription.cancel();
    return super.close();
  }
}
