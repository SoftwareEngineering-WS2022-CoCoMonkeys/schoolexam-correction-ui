import 'package:schoolexam/exams/exams.dart';

abstract class Correctable {
  final double achievedPoints;
  final String status;
  final int updatedAt;

  const Correctable(
      {required this.achievedPoints,
      required this.status,
      required this.updatedAt});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {
      'achievedPoints': achievedPoints,
      'status': status,
      'updatedAt': updatedAt
    };
  }
}

class SubmissionData extends Correctable {
  final String id;
  final String examId;

  /// Base64 encoded PDF file
  final String data;

  final String studentId;

  final int isMatchedToStudent;
  final int isCompleted;

  const SubmissionData({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.data,
    required this.isMatchedToStudent,
    required this.isCompleted,
    required int updatedAt,
    required double achievedPoints,
    required String status,
  }) : super(
            achievedPoints: achievedPoints,
            status: status,
            updatedAt: updatedAt);

  Map<String, dynamic> toMap() => super.toMap()
    ..addAll({
      'id': this.id,
      'examId': this.examId,
      'data': this.data,
      'studentId': this.studentId,
      'isMatchedToStudent': this.isMatchedToStudent,
      'isCompleted': this.isCompleted
    });

  factory SubmissionData.fromMap(Map<String, dynamic> map) {
    return SubmissionData(
        id: map['id'] as String,
        examId: map['examId'] as String,
        data: map['data'] as String,
        studentId: map['studentId'] as String,
        isMatchedToStudent: map['isMatchedToStudent'] as int,
        isCompleted: map['isCompleted'] as int,
        updatedAt: map['updatedAt'] as int,
        achievedPoints: map['achievedPoints'] as double,
        status: map['status'] as String);
  }

  factory SubmissionData.fromModel({required Submission model}) =>
      SubmissionData(
          id: model.id,
          examId: model.exam.id,
          studentId: model.student.id,
          data: model.data,
          isMatchedToStudent: model.isMatchedToStudent ? 1 : 0,
          isCompleted: model.isCompleted ? 1 : 0,
          updatedAt: model.updatedAt.toUtc().millisecondsSinceEpoch,
          achievedPoints: model.achievedPoints,
          status: model.status.name);

  Submission toModel(
          {required Exam exam,
          required Student student,
          required List<Answer> answers}) =>
      Submission(
        id: id,
        exam: exam,
        student: student,
        data: data,
        answers: answers,
        isCompleted: isCompleted == 1 ? true : false,
        isMatchedToStudent: isMatchedToStudent == 1 ? true : false,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt).toUtc(),
        achievedPoints: achievedPoints,
        status: CorrectableStatus.values.firstWhere(
            (element) => element.name.toLowerCase() == status.toLowerCase(),
            orElse: () => CorrectableStatus.unknown),
      );
}

class AnswerData extends Correctable {
  final String submissionId;
  final String taskId;

  AnswerData({
    required this.submissionId,
    required this.taskId,
    required int updatedAt,
    required double achievedPoints,
    required String status,
  }) : super(
            achievedPoints: achievedPoints,
            status: status,
            updatedAt: updatedAt);

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({'submissionId': submissionId, 'taskId': taskId});
  }

  static AnswerData fromMap(Map<String, dynamic> data) {
    return AnswerData(
        submissionId: data["submissionId"],
        taskId: data["taskId"],
        achievedPoints: data["achievedPoints"],
        status: data["status"],
        updatedAt: data["updatedAt"]);
  }

  factory AnswerData.fromModel(
          {required Submission submission, required Answer model}) =>
      AnswerData(
          submissionId: submission.id,
          taskId: model.task.id,
          achievedPoints: model.achievedPoints,
          status: model.status.name,
          updatedAt: model.updatedAt.toUtc().millisecondsSinceEpoch);

  Answer toModel({required Task task, required List<AnswerSegment> segments}) =>
      Answer(
          task: task,
          segments: segments,
          achievedPoints: achievedPoints,
          status: CorrectableStatus.values.firstWhere(
              (element) => element.name.toLowerCase() == status.toLowerCase(),
              orElse: () => CorrectableStatus.unknown),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt).toUtc());
}
