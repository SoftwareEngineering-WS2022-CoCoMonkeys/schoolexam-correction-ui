import 'package:equatable/equatable.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';

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

/// Actions are outstanding.
/// The state holds the data that is outdated.
class LoadingExamsState extends ExamsState {
  LoadingExamsState.loading(
      {required ExamsState old, String? search, List<ExamStatus>? states})
      : super(
            exams: old.exams,
            filtered: old.filtered,
            search: search ?? old.search,
            states: states ?? old.states);
}

/// An erroneous state.
/// Could be the result of an API error.
class LoadingExamsErrorState extends ExamsState implements BlocException {
  @override
  final Exception exception;

  LoadingExamsErrorState.error(
      {required ExamsState old, required this.exception})
      : super(
            exams: old.exams,
            filtered: old.filtered,
            search: old.search,
            states: old.states);
}

class LoadedExamsState extends ExamsState {
  LoadedExamsState.empty()
      : super(exams: [], filtered: [], states: [], search: "");

  const LoadedExamsState.loaded(
      {required List<Exam> exams,
      required List<Exam> filtered,
      required String search,
      required List<ExamStatus> states})
      : super(exams: exams, filtered: filtered, states: states, search: search);
}
