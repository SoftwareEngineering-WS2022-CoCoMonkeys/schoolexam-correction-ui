import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_form.dart';

import 'exam_details_form_input.dart';

class ExamDetailsState extends Equatable {
  final FormzStatus status;
  final ExamTitle examTitle;
  final ExamTopic examTopic;
  final ExamCourse examCourse;
  final ExamDate examDate;
  final bool isNewExamEdit;
  final String? adjustedExamId;

  // valid inputs for new exam form
  final List<Course> validCourses;

  const ExamDetailsState({
    this.status = FormzStatus.pure,
    this.examTitle = const ExamTitle.pure(),
    this.examTopic = const ExamTopic.pure(),
    this.examCourse = const ExamCourse.pure(),
    this.adjustedExamId,
    required this.examDate,
    required this.isNewExamEdit,
    required this.validCourses,
  });

  ExamDetailsState.initialNewExam()
      //TODO get initial courses from repository
      : this(
            examDate: ExamDate.pure(),
            validCourses: [
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
            ],
            isNewExamEdit: true);

  ExamDetailsState.initialAdjustExam({required Exam exam})
      //TODO get initial courses from repository
      : this(
            validCourses: [
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
            ],
            isNewExamEdit: false,
            adjustedExamId: exam.id,
            examTitle: ExamTitle.dirty(value: exam.title),
            examTopic: ExamTopic.dirty(value: exam.topic),
            examCourse:
                ExamCourse.dirty(value: exam.participants.first as Course),
            examDate: ExamDate.dirty(exam.dateOfExam));

  ExamDetailsState copyWith({
    FormzStatus? status,
    ExamTitle? examTitle,
    ExamTopic? examTopic,
    ExamCourse? examCourse,
    ExamDate? examDate,
    bool? isNewExamEdit,
    String? adjustedExamId,
    List<Course>? validCourses,
  }) {
    return ExamDetailsState(
      status: status ??
          ExamDetailsForm(
                  examTitle: examTitle ?? this.examTitle,
                  examTopic: examTopic ?? this.examTopic,
                  examCourse: examCourse ?? this.examCourse,
                  examDate: examDate ?? this.examDate)
              .status,
      examTitle: examTitle ?? this.examTitle,
      examTopic: examTopic ?? this.examTopic,
      examCourse: examCourse ?? this.examCourse,
      examDate: examDate ?? this.examDate,
      isNewExamEdit: isNewExamEdit ?? this.isNewExamEdit,
      adjustedExamId: adjustedExamId ?? this.adjustedExamId,
      validCourses: validCourses ?? this.validCourses,
    );
  }

  @override
  List<Object?> get props =>
      [status, examTitle, examTopic, examCourse, examDate, isNewExamEdit, adjustedExamId, validCourses];
}
