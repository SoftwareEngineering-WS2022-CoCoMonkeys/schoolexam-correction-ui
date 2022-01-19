import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';
import 'package:schoolexam_correction_ui/blocs/navigation/navigation.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/grading_table_helper.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks_error_extensions.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks_pdf_helper.dart';
import 'package:schoolexam_correction_ui/extensions/grading_scheme_helper.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

/// This cubit is responsible for managing the currently active corrections.
/// It therefore has to provide knowledge about the underlying submissions and corresponding students.
class RemarksCubit extends Cubit<RemarksState> {
  late final StreamSubscription _navigationSubscription;
  final ExamsRepository _examsRepository;
  final LanguageCubit _languageCubit;

  // Helper
  final RemarkPdfHelper _helper;
  final GradingTableHelper _tableHelper;

  RemarksCubit(
      {required ExamsRepository examsRepository,
      required NavigationCubit navigationCubit,
      required LanguageCubit languageCubit})
      : _examsRepository = examsRepository,
        _languageCubit = languageCubit,
        _helper = const RemarkPdfHelper(),
        _tableHelper = const GradingTableHelper(),
        super(RemarksInitial.empty()) {
    _navigationSubscription = navigationCubit.stream.listen(_onNavigationState);
  }

  /// This bloc is mainly triggered from observing the global [AppNavigationState].
  /// Based on changes within the navigation remarks are loaded, discarded.
  void _onNavigationState(AppNavigationState state) async {
    log("Observed navigation switch : $state");
    if (state.context != AppNavigationContext.exams ||
        state.requiresAuthentication) {
      return;
    }

    if (state.examId.isEmpty) {
      /// Remove any corrections, if still present.
      if (this.state is RemarksCorrectionInProgress) {
        final base = this.state as RemarksCorrectionInProgress;

        // TODO : Provide bulk removal state
        var removalState = base;
        for (final correction in base.corrections) {
          removalState = RemarksCorrectionRemoved.remove(
              initial: removalState, removed: correction);
          emit(removalState);
        }
        emit(RemarksInitial.empty());
      }
    }

    /// Start loading necessary data
    else {
      log("Starting to lad remark data due to observed navigational switch.");

      emit(RemarksLoadInProgress.loadingExam());
      final exam = await _examsRepository.getExam(state.examId);
      await correct(exam: exam);
    }
  }

  /// Start the correction for the [exam].
  /// This includes the retrieval of the corresponding submissions.
  /// At the end of the function the [RemarksCorrectionInProgress] state is emitted.
  Future<void> correct({required Exam exam}) async {
    emit(RemarksLoadInProgress.loadingSubmissions(exam: exam));

    // TODO : More efficient
    final general = await _examsRepository.getSubmissions(examId: exam.id);
    final details = await _examsRepository.getSubmissionDetails(
        examId: exam.id, submissionIds: general.map((e) => e.id).toList());

    final matched = details
        .where(
            (element) => element.isMatchedToStudent) //&& element.isCompleted)
        .toList();

    log("Determined matched submissions : $matched");

    emit(RemarksLoadSuccess(exam: exam, submissions: matched));
  }

  /// Opens the [submission] for correction
  Future<void> open(Submission submission) async {
    log("Requested to correct submission $submission");

    if (state is! RemarksCorrectionInProgress &&
        state is! RemarksLoadSuccess &&
        state is! RemarksGradingState) {
      log("Remark cubit is invalid state to open submission. The necessary data has to be loaded using correct beforehand.");
      return;
    }

    final correction = await _helper.loadCorrection(submission: submission);

    /// Sort segments by page and y
    for (final answer in correction.submission.answers) {
      answer.segments.sort((s1, s2) => s1.compareTo(s2));
    }

    /// Sort answers by first segment
    correction.submission.answers
        .sort((a1, a2) => a1.segments[0].compareTo(a2.segments[0]));

    /// Sort tasks by answers
    submission.exam.tasks.sort((t1, t2) => correction.submission.answers
        .indexWhere((element) => element.task.id == t1.id)
        .compareTo(correction.submission.answers
            .indexWhere((element) => element.task.id == t2.id)));

    if (state is! RemarksCorrectionInProgress) {
      emit(RemarksCorrectionAdded.start(
          selectedCorrection: 0,
          corrections: [correction],
          exam: state.exam,
          submissions: state.submissions,
          added: correction));
    } else {
      emit(RemarksCorrectionAdded.add(
          initial: state as RemarksCorrectionInProgress, added: correction));
    }
  }

  /// Closes the [submission].
  void stop(Submission submission) async {
    log("Requested to close submission $submission");

    if (state is! RemarksCorrectionInProgress) {
      log("Remark cubit is invalid state to close submission.");
      return;
    }

    final correctionState = state as RemarksCorrectionInProgress;

    final correction = correctionState.corrections.firstWhere(
        (element) => element.submission.id == submission.id,
        orElse: () => Correction.empty);

    final removalState = RemarksCorrectionRemoved.remove(
        initial: correctionState, removed: correction);

    emit(removalState);

    /// Traverse back to previous state
    if (removalState.corrections.isEmpty) {
      emit(RemarksLoadSuccess(
          exam: removalState.exam, submissions: removalState.submissions));
    }
  }

  /// Changes the active correction to match the desired [submission].
  void changeTo({required Submission submission}) async {
    log("Requested to change to $submission");

    if (state is! RemarksCorrectionInProgress) {
      log("Remark cubit is invalid state to change submission.");
      return;
    }

    final correctionState = state as RemarksCorrectionInProgress;

    if (correctionState.corrections.isEmpty) {
      log("No corrections currently present.");
      return;
    }

    final selection = correctionState.corrections
        .indexWhere((element) => element.submission.id == submission.id, -1);
    if (selection < 0) {
      log("Found no correction for ${submission.id}");
      return;
    }

    emit(RemarksCorrectionSwapped.swap(
        initial: correctionState, selectedCorrection: selection));
  }

  /// Moves the currently selected correction to the desired [task].
  void moveTo({required Task task}) {
    log("Requested to move to $task");

    if (state is! RemarksCorrectionInProgress) {
      log("Remark cubit is invalid state to change submission.");
      return;
    }

    final correctionState = state as RemarksCorrectionInProgress;

    if (correctionState.corrections.isEmpty) {
      log("No corrections currently present.");
      return;
    }

    final correction = correctionState
        .corrections[correctionState.selectedCorrection]
        .copyWith(
            currentAnswer: correctionState
                .corrections[correctionState.selectedCorrection]
                .submission
                .answers
                .firstWhere((element) => element.task.id == task.id,
                    orElse: () => Answer.empty));

    emit(RemarksCorrectionNavigated.navigate(
        initial: correctionState, navigated: correction));
  }

  /// Marks the [task] with [points].
  Future<void> mark(
      {required Submission submission,
      required Task task,
      required double achievedPoints}) async {
    log("Requested to set $task to $achievedPoints for ${submission.student.displayName}");

    if (state is! RemarksCorrectionInProgress) {
      log("Remark cubit is invalid state to change submission.");
      return;
    }

    final correctionState = state as RemarksCorrectionInProgress;

    final correction = correctionState.corrections.firstWhere(
        (element) => element.submission.id == submission.id,
        orElse: () => Correction.empty);

    final answer = submission.answers.firstWhere(
        (element) => element.task.id == task.id,
        orElse: () => Answer.empty);

    if (answer.isEmpty) {
      log("Found no matching task or answer in exam.");
      return;
    }

    final markedAnswer = answer.copyWith(
        achievedPoints: achievedPoints, status: CorrectableStatus.corrected);

    final marked = correction.copyWith(
        submission: correction.submission.copyWith(
            answers: List<Answer>.from(correction.submission.answers)
                .map((e) => (e.task.id == answer.task.id) ? markedAnswer : e)
                .toList()));

    final loadingRemark = RemarksCorrectionRemarkLoading.mark(
        answer: markedAnswer,
        correction: marked,
        selectedCorrection: correctionState.selectedCorrection,
        corrections: correctionState.corrections,
        submissions: correctionState.submissions,
        exam: correctionState.exam);

    emit(loadingRemark);

    try {
      await _examsRepository.setPoints(
          submissionId: submission.id,
          taskId: markedAnswer.task.id,
          achievedPoints: achievedPoints);
      log("Remark update was successful for ${markedAnswer.task.title} in ${submission.id}");

      emit(RemarksCorrectionRemarkSuccess(initial: loadingRemark));
    } on NetworkException catch (e) {
      // TODO : Look into -> Localize description etc. based on exception
      emit(RemarksCorrectionRemarkFailure(
          initial: loadingRemark,
          description: e.getRemarkDescription(_languageCubit, markedAnswer)));
    }
  }

  /// Merges the supplied [CorrectionOverlayDocument] with the pdf stored for the associated submission into a separate pdf file.
  Future<Uint8List> merge(
          {required CorrectionOverlayDocument document}) async =>
      await _helper.merge(document: document);

  /// Add a new lower bound to the existing grading table
  void addGradingTableBound() {
    if (state is! RemarksLoadSuccess && state is! RemarksGradingState) {
      log("Remark cubit is invalid state to change grading table bounds.");
      return;
    }

    final copy = state.exam.gradingTable.valueCopy();
    copy.lowerBounds.add(GradingTableLowerBound.empty);

    emit(RemarksGradingInProgress.update(
        table: copy, exam: state.exam, submissions: state.submissions));
  }

  /// Change the points on a lower bound in the existing grading table
  void changeGradingTableBoundPoints(
      {required int index, required double points}) {
    if (state is! RemarksLoadSuccess && state is! RemarksGradingState) {
      log("Remark cubit is invalid state to change grading table bounds.");
      return;
    }

    final update = _tableHelper.changeGradingTableBoundPoints(
        exam: state.exam,
        table: state.exam.gradingTable,
        index: index,
        points: points);

    emit(RemarksGradingInProgress.update(
        table: update, exam: state.exam, submissions: state.submissions));
  }

  /// Change the grade descriptor on a lower bound in the existing grading table
  void changeGradingTableBoundGrade(
      {required int index, required String grade}) {
    if (state is! RemarksLoadSuccess && state is! RemarksGradingState) {
      log("Remark cubit is invalid state to change grading table bounds.");
      return;
    }

    final copy = state.exam.gradingTable.valueCopy();
    final adjustedLowerBound = copy.lowerBounds[index].copyWith(grade: grade);

    // remove old bound
    copy.lowerBounds.removeAt(index);

    // insert updated bound at same index
    copy.lowerBounds.insert(index, adjustedLowerBound);

    emit(RemarksGradingInProgress.update(
        table: copy, exam: state.exam, submissions: state.submissions));
  }

  /// Change the grading table to a default layout
  /// The two standard german grading schemes are available as presets
  void getDefaultGradingTable({required int low, required int high}) {
    if (state is! RemarksLoadSuccess && state is! RemarksGradingState) {
      log("Remark cubit is invalid state to change grading table bounds.");
      return;
    }

    emit(RemarksGradingInProgress.update(
        table: GradingSchemeHelper.getDefaultGradingScheme(
            low: low, high: high, exam: state.exam),
        exam: state.exam,
        submissions: state.submissions));
  }

  /// Delete a grading table interval
  void deleteGradingTableBound(int index) {
    if (state is! RemarksLoadSuccess && state is! RemarksGradingState) {
      log("Remark cubit is invalid state to change grading table bounds.");
      return;
    }

    final copy = state.exam.gradingTable.valueCopy();
    copy.lowerBounds.removeAt(index);

    emit(RemarksGradingInProgress.update(
        table: copy, exam: state.exam, submissions: state.submissions));
  }

  /// Save grading table
  Future<void> saveGradingTable() async {
    if (state is! RemarksGradingState) {
      log("Remark cubit is invalid state to change grading table bounds.");
      return;
    }

    final gradingState = state as RemarksGradingState;
    emit(RemarksGradingLoading(
        initial: gradingState,
        description:
            gradingState.table.getUpdateLoadingDescription(_languageCubit)));
    try {
      await _examsRepository.setGradingTable(exam: state.exam);
      log("Grading table update was successful for ${state.exam.title}");

      emit(RemarksGradingSuccess(
          initial: gradingState,
          description:
              gradingState.table.getUpdateDescription(_languageCubit)));
    } on NetworkException catch (e) {
      emit(RemarksGradingFailure(
          initial: gradingState,
          description: e.getGradingDescription(_languageCubit)));
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _navigationSubscription.cancel();
  }
}
