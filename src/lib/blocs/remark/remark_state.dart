import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';

import 'correction.dart';

typedef CorrectionRetrievalCallback = Correction Function(Correction initial);

abstract class RemarkState extends Equatable {
  /// We may only provide remarks for one exam at the time. This contains information about the subject, participants etc.
  final Exam exam;

  /// All submissions currently known to the system. The user may start corrections from any of these.
  final List<Submission> submissions;

  /// Defines which correction is currently being worked on
  /// If corrections is empty, no correction is active
  final int selectedCorrection;
  final List<Correction> corrections;

  /// Callback to retrieve the updated correction from the state.
  /// This allows to centralize the logic, while allowing widgets to define their rebuild logic based on state changes.
  Correction getCurrent(Correction initial) => corrections.firstWhere(
      (element) => element.submission.id == initial.submission.id,
      orElse: () => Correction.empty);

  const RemarkState._(
      {required this.exam,
      this.selectedCorrection = 0,
      required this.submissions,
      required this.corrections});

  @override
  List<Object> get props => [
        exam,
        submissions,
        selectedCorrection,
        corrections,
      ];
}

/// Actions are outstanding.
/// The state holds the data that is outdated.
class LoadingRemarksState extends RemarkState {
  LoadingRemarksState.loading({required RemarkState old})
      : super._(
            exam: old.exam,
            selectedCorrection: old.selectedCorrection,
            submissions: old.submissions,
            corrections: old.corrections);
}

/// An erroneous state.
/// Could be the result of an API error.
class LoadingRemarksErrorState extends RemarkState implements BlocFailure {
  @override
  final Exception exception;

  @override
  final String description;

  LoadingRemarksErrorState.error(
      {required RemarkState old,
      required this.exception,
      required this.description})
      : super._(
            exam: old.exam,
            selectedCorrection: old.selectedCorrection,
            submissions: old.submissions,
            corrections: old.corrections);
}

/// Actions are finished.
class LoadedRemarksState extends RemarkState {
  LoadedRemarksState.none()
      : this._(exam: Exam.empty, submissions: [], corrections: []);

  const LoadedRemarksState._(
      {required Exam exam,
      int selectedCorrection = 0,
      required List<Submission> submissions,
      required List<Correction> corrections})
      : super._(
            exam: exam,
            selectedCorrection: selectedCorrection,
            submissions: submissions,
            corrections: corrections);
}

/// Changed the remark for a submission.
class UpdatedRemarksState extends LoadedRemarksState {
  final Correction marked;

  UpdatedRemarksState.marked(
      {required RemarkState initial, required this.marked})
      : super._(
            exam: initial.exam,
            selectedCorrection: initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: <Correction>[
              ...initial.corrections.map(
                  (e) => (e.submission.id == marked.submission.id) ? marked : e)
            ]);
}

/// Starting the overall correction for an exam. No submission can yet be actively corrected.
class StartedCorrectionState extends LoadedRemarksState {
  StartedCorrectionState.start(
      {required Exam exam, required List<Submission> submissions})
      : super._(exam: exam, submissions: submissions, corrections: []);
}

/// Added a new correction for active working.
class AddedCorrectionState extends LoadedRemarksState {
  final Correction added;

  AddedCorrectionState.add({required RemarkState initial, required this.added})
      : super._(
            exam: initial.exam,
            selectedCorrection: initial.corrections.length,
            submissions: initial.submissions,
            corrections: <Correction>[...initial.corrections, added]);
}

/// Removed a correction from active working.
class RemovedCorrectionState extends LoadedRemarksState {
  final Correction removed;

  RemovedCorrectionState.remove(
      {required RemarkState initial, required this.removed})
      : super._(
            exam: initial.exam,
            selectedCorrection: initial.corrections.length,
            submissions: initial.submissions,
            corrections: <Correction>[...initial.corrections]..remove(removed));
}

/// Switching the active correction.
class SwitchedCorrectionState extends LoadedRemarksState {
  SwitchedCorrectionState.change(
      {required RemarkState initial, required int selectedCorrection})
      : super._(
            exam: initial.exam,
            selectedCorrection: (selectedCorrection >= 0 &&
                    selectedCorrection < initial.corrections.length)
                ? selectedCorrection
                : initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: initial.corrections);
}

/// Navigated within [navigated] to e.g. a new answer.
class NavigatedRemarkState extends LoadedRemarksState {
  final Correction navigated;

  NavigatedRemarkState.navigated(
      {required RemarkState initial, required this.navigated})
      : super._(
            exam: initial.exam,
            selectedCorrection: initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: <Correction>[
              ...initial.corrections.map((e) =>
                  (e.submission.id == navigated.submission.id) ? navigated : e)
            ]);
}

/// Updated the grading table
class GradingTabledUpdatedState extends RemarkState {
  GradingTabledUpdatedState.updated(
      {required RemarkState initial, required GradingTable gradingTable})
      : super._(
            exam: initial.exam.copyWith(gradingTable: gradingTable),
            selectedCorrection: initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: initial.corrections);

  @override
  List<Object> get props =>
      [exam, submissions, selectedCorrection, corrections];
}
