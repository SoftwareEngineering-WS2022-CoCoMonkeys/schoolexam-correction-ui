import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/schoolexam.dart';

import 'exam_details_form_input.dart';

class ExamDetailsState extends Equatable {
  final FormzStatus status;
  final ExamTitle examTitle;
  final ExamTopic examTopic;
  final ExamCourse examCourse;
  final ExamDate examDate;

  // valid inputs for new exam form
  final List<Course> validCourses;

  const ExamDetailsState({
    this.status = FormzStatus.pure,
    this.examTitle = const ExamTitle.pure(),
    this.examTopic = const ExamTopic.pure(),
    this.examCourse = const ExamCourse.pure(),
    required this.examDate,
    required this.validCourses,
  });

  ExamDetailsState.initial()
      //TODO get initial courses from repository
      : this(examDate: ExamDate.pure(), validCourses: [
          Course(
            children: List.empty(),
            id: "12",
            displayName: "kek1",
          ),
          Course(
            children: List.empty(),
            id: "12",
            displayName: "kek2",
          )
        ]);

  ExamDetailsState copyWith({
    FormzStatus? status,
    ExamTitle? examTitle,
    ExamTopic? examTopic,
    ExamCourse? examCourse,
    ExamDate? examDate,
    List<Course>? validCourses,
  }) {
    return ExamDetailsState(
      status: status ?? this.status,
      examTitle: examTitle ?? this.examTitle,
      examTopic: examTopic ?? this.examTopic,
      examCourse: examCourse ?? this.examCourse,
      examDate: examDate ?? this.examDate,
      validCourses: validCourses ?? this.validCourses,
    );
  }

  @override
  List<Object> get props => [examTitle, examTopic, examCourse, examDate];
}
