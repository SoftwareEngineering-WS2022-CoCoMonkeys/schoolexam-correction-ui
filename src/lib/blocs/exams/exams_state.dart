import 'package:equatable/equatable.dart';
import 'package:schoolexam/schoolexam.dart';

class ExamsState extends Equatable {
  final List<Exam> exams;
  final List<Exam> filtered;

  ExamsState.empty()
      : exams = [],
        filtered = [];

  const ExamsState.unfiltered({required List<Exam> exams})
      : this.exams = exams,
        filtered = exams;

  const ExamsState.filtered(
      {required List<Exam> exams, required List<Exam> filtered})
      : this.exams = exams,
        this.filtered = filtered;

  @override
  List<Object> get props => [exams, filtered];
}
