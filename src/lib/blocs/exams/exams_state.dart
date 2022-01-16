import 'package:equatable/equatable.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';

abstract class ExamsState extends Equatable {
  final List<Exam> exams;
  final List<Exam> filtered;

  const ExamsState({required this.exams, required this.filtered});

  @override
  List<Object> get props => [exams, filtered];
}

/// Actions are outstanding.
/// The state holds the data that is outdated.
class LoadingExamsState extends ExamsState {
  LoadingExamsState.loading({required ExamsState old})
      : super(exams: old.exams, filtered: old.filtered);
}

/// An erroneous state.
/// Could be the result of an API error.
class LoadingExamsErrorState extends ExamsState implements BlocException {
  @override
  final Exception exception;

  LoadingExamsErrorState.error(
      {required ExamsState old, required this.exception})
      : super(exams: old.exams, filtered: old.filtered);
}

class LoadedExamsState extends ExamsState {
  LoadedExamsState.empty() : super(exams: [], filtered: []);

  const LoadedExamsState.unfiltered({required List<Exam> exams})
      : super(exams: exams, filtered: exams);

  const LoadedExamsState.filtered(
      {required List<Exam> exams, required List<Exam> filtered})
      : super(exams: exams, filtered: filtered);
}
