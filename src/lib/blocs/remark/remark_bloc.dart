import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/components/correction/input/colored_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/drawing_input_options.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_options.dart';

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
    print(state);
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

    emit(RemarkState.start(exam: exam, submissions: submissions));
  }

  Future<void> open(Submission submission) async {
    log("Requested to correct submission $submission");

    // TODO : Ensures state change, however inefficient copy
    // TODO : Equality check
    final corrections = <Correction>{...state.corrections};
    corrections.add(await Correction.start(submission: submission));

    emit(state.copyWith(corrections: corrections.toList(growable: false)));
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
  Future<void> close() {
    _navigationSubscription.cancel();
    return super.close();
  }
}
