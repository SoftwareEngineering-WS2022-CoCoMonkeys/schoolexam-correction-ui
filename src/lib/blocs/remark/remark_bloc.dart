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

/// This cubit is responsible for managing the currently active corrections.
/// It therefore has to provide knowledge about the underlying submissions and corresponding students.
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

    var state =
        StartedCorrectionState.start(exam: exam, submissions: submissions);

    emit(state);
  }

  Future<void> open(Submission submission) async {
    log("Requested to correct submission $submission");

    // Switch active pdf
    var newState = AddedCorrectionState.add(
        initial: state, added: await Correction.start(submission: submission));

    emit(newState);
  }

  void changePencilOptions(DrawingInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, pencilOptions: options));

  void changeMarkerOptions(DrawingInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, markerOptions: options));

  void changeTextOptions(ColoredInputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, textOptions: options));

  void changeEraserOptions(InputOptions options) => emit(
      UpdatedInputOptionsState.update(initial: state, eraserOptions: options));

  void changeTool(RemarkInputTool inputTool) => emit(
      UpdatedInputOptionsState.update(initial: state, inputTool: inputTool));

  // TODO : THIS IS NOT WORKING
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
  }

  @override
  Future<void> close() async {
    _navigationSubscription.cancel();
    return super.close();
  }
}
