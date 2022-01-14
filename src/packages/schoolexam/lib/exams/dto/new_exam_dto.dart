import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/course.dart';

class NewExamDTO extends Equatable {
  final String title;
  final String topic;
  final Course course;
  final DateTime dateOfExam;

  NewExamDTO(this.title, this.topic, this.course, this.dateOfExam);

  @override
  // TODO: implement props
  List<Object?> get props => [title, topic, course, dateOfExam];
}
