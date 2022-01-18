import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_loading.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_success.dart';

import 'correction.dart';

typedef CorrectionRetrievalCallback = Correction Function(Correction initial);

abstract class RemarksState extends Equatable {
  /// We may only provide remarks for one exam at the time. This contains information about the subject, participants etc.
  final Exam exam;

  /// All submissions currently known to the system. The user may start corrections from any of these.
  final List<Submission> submissions;

  const RemarksState({required this.exam, required this.submissions});

  @override
  List<Object?> get props => [exam, submissions];
}

class RemarksInitial extends RemarksState {
  RemarksInitial.empty() : super(exam: Exam.empty, submissions: []);
}

/// State for loading necessary data into the states.
abstract class RemarksLoadState extends RemarksState {
  const RemarksLoadState(
      {required Exam exam, required List<Submission> submissions})
      : super(exam: exam, submissions: submissions);
}

/// Loading initial data.
class RemarksLoadInProgress extends RemarksLoadState implements BlocLoading {
  @override
  final String description;

  /// Initial loading state.
  RemarksLoadInProgress.loadingExam({
    this.description = "",
  }) : super(exam: Exam.empty, submissions: []);

  /// Loading submissions
  RemarksLoadInProgress.loadingSubmissions(
      {this.description = "", required Exam exam})
      : super(exam: exam, submissions: []);
}

/// An erroneous state.
/// Could be the result of an API error.
class RemarksLoadFailure extends RemarksLoadState implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  RemarksLoadFailure(
      {required RemarksLoadState initial,
      this.description = "",
      this.exception})
      : super(exam: initial.exam, submissions: initial.submissions);
}

class RemarksLoadSuccess extends RemarksLoadState implements BlocSuccess {
  @override
  final String description;

  const RemarksLoadSuccess(
      {this.description = "",
      required Exam exam,
      required List<Submission> submissions})
      : super(exam: exam, submissions: submissions);
}

/// This state contains information about the grading table.
/// It is used for alternating the grading table.
abstract class RemarksGradingState extends RemarksState {
  final GradingTable table;

  const RemarksGradingState(
      {required this.table,
      required Exam exam,
      required List<Submission> submissions})
      : super(exam: exam, submissions: submissions);

  @override
  List<Object?> get props => super.props..addAll([table]);
}

/// The user started the alternation of the grading table.
class RemarksGradingInProgress extends RemarksGradingState {
  const RemarksGradingInProgress(
      {required GradingTable table,
      required Exam exam,
      required List<Submission> submissions})
      : super(table: table, exam: exam, submissions: submissions);

  RemarksGradingInProgress.update(
      {required GradingTable table,
      required Exam exam,
      required List<Submission> submissions})
      : this(
            table: table,
            exam: exam.copyWith(gradingTable: table),
            submissions: submissions);

  RemarksGradingInProgress copyWith({
    Exam? exam,
    List<Submission>? submissions,
    GradingTable? table,
  }) {
    return RemarksGradingInProgress(
      table: table ?? this.table,
      exam: exam ?? this.exam,
      submissions: submissions ?? this.submissions,
    );
  }
}

class RemarksGradingLoading extends RemarksGradingState implements BlocLoading {
  @override
  final String description;

  RemarksGradingLoading(
      {this.description = "", required RemarksGradingState initial})
      : super(
            table: initial.table,
            exam: initial.exam,
            submissions: initial.submissions);

  @override
  List<Object?> get props => super.props..addAll([description]);
}

class RemarksGradingSuccess extends RemarksGradingState implements BlocSuccess {
  @override
  final String description;

  RemarksGradingSuccess(
      {this.description = "", required RemarksGradingState initial})
      : super(
            table: initial.table,
            exam: initial.exam,
            submissions: initial.submissions);

  @override
  List<Object?> get props => super.props..addAll([description]);
}

class RemarksGradingFailure extends RemarksGradingState implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  RemarksGradingFailure(
      {this.description = "",
      this.exception,
      required RemarksGradingState initial})
      : super(
            table: initial.table,
            exam: initial.exam,
            submissions: initial.submissions);

  @override
  List<Object?> get props => super.props..addAll([description, exception]);
}

/// This state contains information about an ongoing correction.
abstract class RemarksCorrectionState extends RemarksState {
  /// Defines which correction is currently being worked on
  /// If corrections is empty, no correction is active
  final int selectedCorrection;
  final List<Correction> corrections;

  const RemarksCorrectionState(
      {required this.selectedCorrection,
      required this.corrections,
      required Exam exam,
      required List<Submission> submissions})
      : super(exam: exam, submissions: submissions);

  /// Callback to retrieve the updated correction from the state.
  /// This allows to centralize the logic, while allowing widgets to define their rebuild logic based on state changes.
  Correction getCurrent(Correction initial) => corrections.firstWhere(
      (element) => element.submission.id == initial.submission.id,
      orElse: () => Correction.empty);

  @override
  List<Object?> get props =>
      super.props..addAll([selectedCorrection, corrections]);
}

/// An ongoing correction.
abstract class RemarksCorrectionInProgress extends RemarksCorrectionState {
  const RemarksCorrectionInProgress(
      {required int selectedCorrection,
      required List<Correction> corrections,
      required Exam exam,
      required List<Submission> submissions})
      : super(
            selectedCorrection: selectedCorrection,
            corrections: corrections,
            exam: exam,
            submissions: submissions);
}

/// Sub-state to signal the addition of a correction to the ongoing correction process.
class RemarksCorrectionAdded extends RemarksCorrectionInProgress {
  final Correction added;

  RemarksCorrectionAdded.add(
      {required RemarksCorrectionInProgress initial, required this.added})
      : super(
            exam: initial.exam,
            selectedCorrection: initial.corrections.length,
            submissions: initial.submissions,
            corrections: <Correction>[...initial.corrections, added]);

  const RemarksCorrectionAdded.start(
      {required int selectedCorrection,
      required List<Correction> corrections,
      required Exam exam,
      required List<Submission> submissions,
      required this.added})
      : super(
            exam: exam,
            selectedCorrection: selectedCorrection,
            submissions: submissions,
            corrections: corrections);

  @override
  List<Object?> get props => super.props..addAll([added]);
}

/// Sub-state to signal the removal of a correction from the ongoing correction process.
class RemarksCorrectionRemoved extends RemarksCorrectionInProgress {
  final Correction removed;

  const RemarksCorrectionRemoved(
      {required this.removed,
      required int selectedCorrection,
      required List<Correction> corrections,
      required Exam exam,
      required List<Submission> submissions})
      : super(
            selectedCorrection: selectedCorrection,
            corrections: corrections,
            exam: exam,
            submissions: submissions);

  factory RemarksCorrectionRemoved.remove(
      {required RemarksCorrectionInProgress initial,
      required Correction removed}) {
    final corrections = <Correction>[
      ...initial.corrections
    ]..removeWhere((element) => element.submission.id == removed.submission.id);

    return RemarksCorrectionRemoved(
        removed: removed,
        selectedCorrection:
            min(initial.selectedCorrection, corrections.length - 1),
        corrections: corrections,
        exam: initial.exam,
        submissions: initial.submissions);
  }

  @override
  List<Object?> get props => super.props..addAll([removed]);
}

/// Sub-state to signal the change of the currently active submission being corrected.
class RemarksCorrectionSwapped extends RemarksCorrectionInProgress {
  RemarksCorrectionSwapped.swap(
      {required RemarksCorrectionInProgress initial,
      required int selectedCorrection})
      : super(
            exam: initial.exam,
            selectedCorrection: (selectedCorrection >= 0 &&
                    selectedCorrection < initial.corrections.length)
                ? selectedCorrection
                : initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: initial.corrections);
}

/// Sub-state to signal the navigation to a different answer within an ongoing correction,
class RemarksCorrectionNavigated extends RemarksCorrectionInProgress {
  final Correction navigated;

  RemarksCorrectionNavigated.navigate(
      {required RemarksCorrectionInProgress initial, required this.navigated})
      : super(
            exam: initial.exam,
            selectedCorrection: initial.selectedCorrection,
            submissions: initial.submissions,
            corrections: <Correction>[
              ...initial.corrections.map((e) =>
                  (e.submission.id == navigated.submission.id) ? navigated : e)
            ]);
}

/// A sub-state of an ongoing exam correction.
/// Here, the different changes to tasks for a single submission can be tracked and accordingly reacted to.
abstract class RemarksCorrectionRemarkState
    extends RemarksCorrectionInProgress {
  final Answer answer;
  final Correction correction;

  const RemarksCorrectionRemarkState(
      {required this.answer,
      required this.correction,
      required int selectedCorrection,
      required List<Correction> corrections,
      required Exam exam,
      required List<Submission> submissions})
      : super(
            selectedCorrection: selectedCorrection,
            corrections: corrections,
            exam: exam,
            submissions: submissions);

  @override
  List<Object?> get props => super.props..addAll([answer, correction]);
}

/// Within an ongoing correction the remark for a task is being updated.
/// By inheriting from [RemarksCorrectionInProgress] the data needed for displaying corrections is kept.
class RemarksCorrectionRemarkLoading extends RemarksCorrectionRemarkState
    implements BlocLoading {
  @override
  final String description;

  const RemarksCorrectionRemarkLoading.mark(
      {this.description = "",
      required Answer answer,
      required Correction correction,
      required int selectedCorrection,
      required List<Correction> corrections,
      required Exam exam,
      required List<Submission> submissions})
      : super(
            answer: answer,
            correction: correction,
            selectedCorrection: selectedCorrection,
            corrections: corrections,
            exam: exam,
            submissions: submissions);

  @override
  List<Object?> get props => super.props..addAll([description]);
}

class RemarksCorrectionRemarkSuccess extends RemarksCorrectionRemarkState
    implements BlocSuccess {
  @override
  final String description;

  RemarksCorrectionRemarkSuccess(
      {this.description = "", required RemarksCorrectionRemarkState initial})
      : super(
            answer: initial.answer,
            correction: initial.correction,
            selectedCorrection: initial.selectedCorrection,
            corrections: initial.corrections,
            exam: initial.exam,
            submissions: initial.submissions);

  @override
  List<Object?> get props => super.props..addAll([description]);
}

class RemarksCorrectionRemarkFailure extends RemarksCorrectionRemarkState
    implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  RemarksCorrectionRemarkFailure(
      {this.description = "",
      this.exception,
      required RemarksCorrectionRemarkState initial})
      : super(
            answer: initial.answer,
            correction: initial.correction,
            selectedCorrection: initial.selectedCorrection,
            corrections: initial.corrections,
            exam: initial.exam,
            submissions: initial.submissions);

  @override
  List<Object?> get props => super.props..addAll([description, exception]);
}
