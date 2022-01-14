import 'package:equatable/equatable.dart';
import 'package:schoolexam/schoolexam.dart';

class ExamsState extends Equatable {
  final List<Exam> exams;
  final List<Exam> filtered;

  ExamsState.empty()
      : exams = [],
        filtered = [];

  const ExamsState.unfiltered({required this.exams}) : filtered = exams;

  const ExamsState.filtered({required this.exams, required this.filtered});

  @override
  List<Object> get props => [exams, filtered];
}
