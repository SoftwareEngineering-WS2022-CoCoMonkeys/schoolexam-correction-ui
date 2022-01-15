import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/course.dart';

class NewExamDTO extends Equatable {
  final String title;

  // TODO: should be topic?
  final String topic;
  final Course course;
  final DateTime dateOfExam;

  NewExamDTO(
      {required this.title,
      required this.topic,
      required this.course,
      required this.dateOfExam});

  @override
  // TODO: implement props
  List<Object?> get props => [title, topic, course, dateOfExam];

  Map<String, dynamic> toJson() => {
        "title": title,
        "topic": topic,
        "dateOfExam": dateOfExam.toString(),
        "description": "",
      };
}
