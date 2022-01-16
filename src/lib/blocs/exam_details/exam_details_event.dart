import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/course.dart';
import 'package:schoolexam/exams/models/exam.dart';

abstract class ExamDetailsEvent extends Equatable {
  const ExamDetailsEvent();

  @override
  List<Object> get props => [];
}

class NewExamOpened extends ExamDetailsEvent {
  const NewExamOpened();
}

class AdjustExamOpened extends ExamDetailsEvent {
  const AdjustExamOpened(this.exam);

  final Exam exam;

  @override
  List<Object> get props => [exam];
}

class ExamTitleChanged extends ExamDetailsEvent {
  const ExamTitleChanged(this.examTitle);

  final String examTitle;

  @override
  List<Object> get props => [examTitle];
}

class ExamTopicChanged extends ExamDetailsEvent {
  const ExamTopicChanged(this.examTopic);

  final String examTopic;

  @override
  List<Object> get props => [examTopic];
}

class ExamCourseChanged extends ExamDetailsEvent {
  const ExamCourseChanged(this.examCourse);

  final Course examCourse;

  @override
  List<Object> get props => [examCourse];
}

class ExamDateChanged extends ExamDetailsEvent {
  const ExamDateChanged(this.examDate);

  final DateTime examDate;

  @override
  List<Object> get props => [examDate];
}

class ExamSubmitted extends ExamDetailsEvent {
  const ExamSubmitted();
}
