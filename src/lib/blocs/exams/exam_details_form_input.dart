import 'package:formz/formz.dart';
import 'package:schoolexam/exams/models/course.dart';
import 'package:schoolexam_correction_ui/extensions/date_time_extensions.dart';

enum ExamTitleValidationError { empty, invalid }
enum ExamTopicValidationError { empty, invalid }
enum ExamCourseValidationError { empty, invalid }
enum ExamDateValidationError { empty, invalid }

class ExamTitle extends FormzInput<String, ExamTitleValidationError> {
  const ExamTitle.pure() : super.pure('');

  const ExamTitle.dirty({String value = ''}) : super.dirty(value);

  @override
  ExamTitleValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : ExamTitleValidationError.empty;
  }
}

class ExamTopic extends FormzInput<String, ExamTopicValidationError> {
  const ExamTopic.pure() : super.pure('');

  const ExamTopic.dirty({String value = ''}) : super.dirty(value);

  @override
  ExamTopicValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : ExamTopicValidationError.empty;
  }
}

// TODO change to participant
class ExamCourse extends FormzInput<Course, ExamCourseValidationError> {
  const ExamCourse.pure() : super.pure(Course.empty);

  const ExamCourse.dirty({Course value = Course.empty}) : super.dirty(value);

  @override
  ExamCourseValidationError? validator(Course? value) {
    return value?.isNotEmpty == true ? null : ExamCourseValidationError.empty;
  }
}

class ExamDate extends FormzInput<DateTime, ExamDateValidationError> {
  ExamDate.pure() : super.pure(DateTime.now());

  const ExamDate.dirty(DateTime value) : super.dirty(value);

  @override
  ExamDateValidationError? validator(DateTime? value) {
    if (value == null) {
      return ExamDateValidationError.empty;
    }
    return value.isAfter(DateTime.now()) || value.isSameDate(DateTime.now())
        ? null
        : ExamDateValidationError.invalid;
  }
}
