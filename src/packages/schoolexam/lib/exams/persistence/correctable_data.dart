import 'package:schoolexam/exams/exams.dart';

abstract class Correctable {
  final double achievedPoints;
  final String status;

  const Correctable({required this.achievedPoints, required this.status});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {'achievedPoints': achievedPoints, 'status': status};
  }
}

class SubmissionData extends Correctable {
  final String id;
  final String examId;

  /// Base64 encoded PDF file
  final String data;

  final String studentId;

  SubmissionData({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.data,
    required double achievedPoints,
    required String status,
  }) : super(achievedPoints: achievedPoints, status: status);

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll(
          {'id': id, 'examId': examId, 'data': data, 'studentId': studentId});
  }

  static SubmissionData fromMap(Map<String, dynamic> data) {
    return SubmissionData(
        id: data["id"],
        examId: data["examId"],
        studentId: data["studentId"],
        data: data["data"],
        achievedPoints: data["achievedPoints"],
        status: data["status"]);
  }

  static SubmissionData fromModel(Submission model) => SubmissionData(
      id: model.id,
      examId: model.exam.id,
      studentId: model.student.id,
      data: model.data,
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
        achievedPoints: achievedPoints,
        status: CorrectableStatus.values.firstWhere(
            (element) => element.name == status,
            orElse: () => CorrectableStatus.unknown),
      );
}

class AnswerData extends Correctable {
  final String submissionId;
  final String taskId;

  AnswerData({
    required this.submissionId,
    required this.taskId,
    required double achievedPoints,
    required String status,
  }) : super(achievedPoints: achievedPoints, status: status);

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({'taskId': taskId});
  }

  static AnswerData fromMap(Map<String, dynamic> data) {
    return AnswerData(
        submissionId: data["submissionId"],
        taskId: data["taskId"],
        achievedPoints: data["achievedPoints"],
        status: data["status"]);
  }

  Answer toModel({required Task task, required List<AnswerSegment> segments}) =>
      Answer(
          task: task,
          segments: segments,
          achievedPoints: achievedPoints,
          status: CorrectableStatus.values.firstWhere(
              (element) => element.name == status,
              orElse: () => CorrectableStatus.unknown));
}
