import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/student.dart';

import 'answer.dart';
import 'correctable.dart';
import 'exam.dart';

class Submission extends Correctable {
  final String id;

  final Exam exam;

  /// Base64 encoded PDF file
  final String data;

  final Student student;
  final List<Answer> answers;

  Submission({
    required this.id,
    required this.exam,
    required this.student,
    required this.data,
    required this.answers,
    required double achievedPoints,
    required CorrectableStatus status,
  }) : super(achievedPoints: achievedPoints, status: status);

  @override
  String toString() {
    return "(${exam.title}) ${student.displayName}";
  }

  static final empty = Submission(
      id: "",
      exam: Exam.empty,
      data: "",
      student: Student.empty,
      answers: [],
      achievedPoints: 0,
      status: CorrectableStatus.unknown);

  bool get isEmpty => this == Submission.empty;
  bool get isNotEmpty => this != Submission.empty;

  @override
  List<Object?> get props =>
      [id, exam, data, student, answers, status, achievedPoints];

  Submission copyWith({
    String? id,
    Exam? exam,
    String? data,
    Student? student,
    List<Answer>? answers,
    double? achievedPoints,
    CorrectableStatus? status,
  }) {
    return Submission(
        id: id ?? this.id,
        exam: exam ?? this.exam,
        data: data ?? this.data,
        student: student ?? this.student,
        answers: answers ?? this.answers,
        achievedPoints: achievedPoints ?? this.achievedPoints,
        status: status ?? this.status);
  }
}
