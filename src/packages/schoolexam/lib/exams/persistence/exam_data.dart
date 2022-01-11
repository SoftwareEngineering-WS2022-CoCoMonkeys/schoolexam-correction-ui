import 'package:schoolexam/exams/exams.dart';

class ExamData {
  final String id;
  final String status;
  final String title;

  /// Date when exam was written by all students
  final String? dateOfExam;

  /// Final date for the completion of the correction
  final String? dueDate;

  final String topic;

  const ExamData(
      {required this.id,
      required this.status,
      required this.title,
      this.dateOfExam,
      this.dueDate,
      required this.topic});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'title': title,
      'dateOfExam': dateOfExam,
      'dueDate': dueDate,
      'topic': topic
    };
  }

  static ExamData fromModel(Exam model) => ExamData(
      id: model.id,
      status: model.status.name,
      title: model.title,
      topic: model.topic);

  Exam toModel(
          {required List<Participant> participants,
          required List<Task> tasks}) =>
      Exam(
          id: id,
          status: ExamStatus.values.firstWhere(
              (element) => element.name == status,
              orElse: () => ExamStatus.unknown),
          title: title,
          topic: topic,
          quota: 0.0,
          participants: participants,
          tasks: tasks);

  static ExamData fromMap(Map<String, dynamic> data) {
    return ExamData(
        id: data["id"],
        status: data["status"],
        title: data["title"],
        topic: data["topic"],
        dateOfExam: data["dateOfExam"],
        dueDate: data["dueDate"]);
  }
}
