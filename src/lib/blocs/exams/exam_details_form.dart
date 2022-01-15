import 'package:formz/formz.dart';
import 'package:schoolexam_correction_ui/blocs/exams/exam_details_form_input.dart';

class ExamDetailsForm with FormzMixin {
  final ExamTitle examTitle;
  final ExamTopic examTopic;
  final ExamCourse examCourse;
  final ExamDate examDate;

  ExamDetailsForm(
      {required this.examTitle,
      required this.examTopic,
      required this.examCourse,
      required this.examDate});

  @override
  List<FormzInput> get inputs => [examTitle, examTopic, examCourse, examDate];

  ExamDetailsForm copyWith({
    ExamTitle? examTitle,
    ExamTopic? examTopic,
    ExamCourse? examCourse,
    ExamDate? examDate,
  }) {
    return ExamDetailsForm(
      examTitle: examTitle ?? this.examTitle,
      examTopic: examTopic ?? this.examTopic,
      examCourse: examCourse ?? this.examCourse,
      examDate: examDate ?? this.examDate,
    );
  }
}
