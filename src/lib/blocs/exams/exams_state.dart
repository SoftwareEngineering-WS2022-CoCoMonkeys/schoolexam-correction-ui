import 'package:equatable/equatable.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_loading.dart';

import '../bloc_success.dart';

/// The basic class holding all relevant information about the exams.
abstract class ExamsState extends Equatable {
  final List<Exam> exams;
  final List<Exam> filtered;

  final String search;
  final List<ExamStatus> states;

  const ExamsState(
      {required this.exams,
      required this.filtered,
      required this.search,
      required this.states});

  @override
  List<Object> get props => [exams, filtered, search, states];
}

/// Starting point for the [ExamsCubit].
class ExamsInitial extends ExamsState {
  ExamsInitial.empty()
      : super(
            exams: [],
            filtered: [],
            search: "",
            states: [ExamStatus.planned, ExamStatus.inCorrection]);
}

/// The bloc is within the loading state machine.
abstract class ExamsLoadState extends ExamsState {
  const ExamsLoadState(
      {required List<Exam> exams,
      required List<Exam> filtered,
      required String search,
      required List<ExamStatus> states})
      : super(exams: exams, filtered: filtered, search: search, states: states);
}

/// Started to refresh the exams using the desired [search] and [states].
/// [states], [exams] and [filtered] allow a pass-through of previous data.
class ExamsLoadInProgress extends ExamsLoadState implements BlocLoading {
  @override
  final String description;

  ExamsLoadInProgress(
      {this.description = "",
      required String search,
      required List<ExamStatus> states,
      List<Exam>? exams,
      List<Exam>? filtered})
      : super(
            exams: exams ?? [],
            filtered: filtered ?? [],
            search: search,
            states: states);
}

class ExamsLoadFailure extends ExamsLoadState implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  ExamsLoadFailure(
      {required ExamsLoadState initial, this.description = "", this.exception})
      : super(
            exams: initial.exams,
            filtered: initial.filtered,
            search: initial.search,
            states: initial.states);
}

/// The exams were successfully loaded and filtered.
/// Future states can apply the filters without (poss.) reloading from the online repository.
class ExamsLoadSuccess extends ExamsLoadState implements BlocSuccess {
  @override
  final String description;

  ExamsLoadSuccess(
      {this.description = "",
      required String search,
      required List<ExamStatus> states,
      List<Exam>? exams,
      List<Exam>? filtered})
      : super(
            exams: exams ?? [],
            filtered: filtered ?? [],
            search: search,
            states: states);
}

enum ExamTransition { publish }

/// This state is used for triggering transitions triggered upon an [exam] by the user.
abstract class ExamsTransitionState extends ExamsState {
  final ExamTransition transition;
  final Exam exam;

  const ExamsTransitionState(
      {required this.transition,
      required this.exam,
      required List<Exam> exams,
      required List<Exam> filtered,
      required String search,
      required List<ExamStatus> states})
      : super(exams: exams, filtered: filtered, search: search, states: states);
}

/// A transition for [exam] is currently being progressed.
class ExamTransitionInProgress extends ExamsTransitionState
    implements BlocLoading {
  @override
  final String description;

  const ExamTransitionInProgress(
      {this.description = "",
      required ExamTransition transition,
      required Exam exam,
      required List<Exam> exams,
      required List<Exam> filtered,
      required String search,
      required List<ExamStatus> states})
      : super(
            transition: transition,
            exam: exam,
            exams: exams,
            filtered: filtered,
            search: search,
            states: states);
}

class ExamTransitionFailure extends ExamsTransitionState
    implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  ExamTransitionFailure(
      {required ExamsTransitionState initial,
      this.description = "",
      this.exception})
      : super(
            transition: initial.transition,
            exam: initial.exam,
            exams: initial.exams,
            filtered: initial.filtered,
            search: initial.search,
            states: initial.states);
}

class ExamTransitionSuccess extends ExamsTransitionState
    implements BlocSuccess {
  @override
  final String description;

  ExamTransitionSuccess(
      {required ExamsTransitionState initial, this.description = ""})
      : super(
            transition: initial.transition,
            exam: initial.exam,
            exams: initial.exams,
            filtered: initial.filtered,
            search: initial.search,
            states: initial.states);
}
