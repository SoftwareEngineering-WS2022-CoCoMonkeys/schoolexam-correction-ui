import 'package:schoolexam/exams/exams.dart';

class TaskData {
  final String id;
  final String title;
  final double maxPoints;

  /// Id of the associated exam. A task may only belong to one exam.
  final String examId;

  const TaskData(
      {required this.id,
      required this.title,
      required this.maxPoints,
      required this.examId});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'maxPoints': maxPoints, 'examId': examId};
  }

  Task toModel() => Task(id: id, title: title, maxPoints: maxPoints);

  static TaskData fromModel(Task model, Exam exam) => TaskData(
      id: model.id,
      title: model.title,
      maxPoints: model.maxPoints,
      examId: exam.id);

  static TaskData fromMap(Map<String, dynamic> data) {
    return TaskData(
        id: data["id"],
        title: data["title"],
        maxPoints: data["maxPoints"],
        examId: data["examId"]);
  }
}
