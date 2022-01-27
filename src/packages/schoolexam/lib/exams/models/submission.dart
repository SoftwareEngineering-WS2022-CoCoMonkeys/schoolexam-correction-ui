import 'package:schoolexam/exams/models/student.dart';

import 'answer.dart';
import 'correctable.dart';
import 'exam.dart';

class SubmissionOverview extends Correctable {
  final String id;
  final Student student;

  final Exam exam;

  /// Meta information about the status
  final bool isComplete;
  final bool isMatchedToStudent;

  const SubmissionOverview({
    required this.id,
    required this.exam,
    required this.student,
    required this.isComplete,
    required this.isMatchedToStudent,
    required DateTime updatedAt,
    required double achievedPoints,
    required CorrectableStatus status,
  }) : super(
            achievedPoints: achievedPoints,
            status: status,
            updatedAt: updatedAt);

  @override
  String toString() {
    return "(${exam.title}) ${student.displayName}";
  }

  static final empty = SubmissionOverview(
      id: "",
      exam: Exam.empty,
      student: Student.empty,
      updatedAt: DateTime.utc(0),
      isMatchedToStudent: false,
      isComplete: false,
      achievedPoints: 0,
      status: CorrectableStatus.unknown);

  bool get isEmpty => this == SubmissionOverview.empty;
  bool get isNotEmpty => this != SubmissionOverview.empty;

  @override
  List<Object?> get props => [
        id,
        exam,
        student,
        updatedAt,
        isMatchedToStudent,
        isComplete,
        status,
        achievedPoints
      ];

  SubmissionOverview copyWith({
    String? id,
    Exam? exam,
    Student? student,
    DateTime? updatedAt,
    bool? isMatchedToStudent,
    bool? isComplete,
    double? achievedPoints,
    CorrectableStatus? status,
  }) {
    return SubmissionOverview(
        id: id ?? this.id,
        exam: exam ?? this.exam,
        student: student ?? this.student,
        updatedAt: updatedAt ?? this.updatedAt,
        isMatchedToStudent: isMatchedToStudent ?? this.isMatchedToStudent,
        isComplete: isComplete ?? this.isComplete,
        achievedPoints: achievedPoints ?? this.achievedPoints,
        status: status ?? this.status);
  }
}

class Submission extends SubmissionOverview {
  /// Base64 encoded PDF file
  final String data;

  final List<Answer> answers;

  const Submission({
    required String id,
    required Exam exam,
    required Student student,
    required this.data,
    required this.answers,
    required bool isComplete,
    required bool isMatchedToStudent,
    required DateTime updatedAt,
    required double achievedPoints,
    required CorrectableStatus status,
  }) : super(
            id: id,
            exam: exam,
            student: student,
            updatedAt: updatedAt,
            isComplete: isComplete,
            isMatchedToStudent: isMatchedToStudent,
            achievedPoints: achievedPoints,
            status: status);

  @override
  String toString() {
    return "(${exam.title}) ${student.displayName}";
  }

  static final empty = Submission(
      id: "",
      exam: Exam.empty,
      data: "",
      student: Student.empty,
      answers: const [],
      updatedAt: DateTime.utc(0),
      isMatchedToStudent: false,
      isComplete: false,
      achievedPoints: 0,
      status: CorrectableStatus.unknown);

  @override
  bool get isEmpty => this == Submission.empty;
  @override
  bool get isNotEmpty => this != Submission.empty;

  @override
  List<Object?> get props => super.props..addAll([data, answers]);

  @override
  Submission copyWith({
    String? id,
    Exam? exam,
    String? data,
    Student? student,
    List<Answer>? answers,
    DateTime? updatedAt,
    bool? isMatchedToStudent,
    bool? isComplete,
    double? achievedPoints,
    CorrectableStatus? status,
  }) {
    return Submission(
        id: id ?? this.id,
        exam: exam ?? this.exam,
        data: data ?? this.data,
        student: student ?? this.student,
        answers: answers ?? this.answers,
        updatedAt: updatedAt ?? this.updatedAt,
        isMatchedToStudent: isMatchedToStudent ?? this.isMatchedToStudent,
        isComplete: isComplete ?? this.isComplete,
        achievedPoints: achievedPoints ?? this.achievedPoints,
        status: status ?? this.status);
  }
}
