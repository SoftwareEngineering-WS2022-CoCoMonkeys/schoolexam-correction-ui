import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';

import 'exam_details_form_input.dart';
import 'exam_details_state.dart';

class ExamDetailsBloc extends Cubit<ExamDetailsState> {
  late final StreamSubscription _authenticationSubscription;
  final ExamsRepository _examsRepository;

  ExamDetailsBloc({
    required ExamsRepository examsRepository,
    required AuthenticationBloc authenticationBloc,
  })  : _examsRepository = examsRepository,
        super(ExamDetailsState.empty()) {
    _authenticationSubscription =
        authenticationBloc.stream.listen(_onAuthenticationStateChanged);
  }

  void _onAuthenticationStateChanged(AuthenticationState state) async {
    switch (state.status) {
      case AuthenticationStatus.authenticated:
        final courses = await _examsRepository.getCourses();
        emit(this.state.copyWith(validCourses: courses));
        break;
      case AuthenticationStatus.unauthenticated:
        emit(this.state.copyWith(validCourses: []));
        break;
      case AuthenticationStatus.unknown:
        break;
    }
  }

  /// Starts the creation of a new exam.
  Future<void> openNewExam() async {
    // only reset form values if we switch from an exam adjustment to an exam creation
    if (!state.isNewExamEdit) {
      emit(ExamDetailsState.initialNewExam(validCourses: state.validCourses));
    }
  }

  /// Open the exam [exam] for adjustment.
  Future<void> adjustExamOpened({required Exam exam}) async {
    emit(ExamDetailsState.initialAdjustExam(
            exam: exam, validCourses: state.validCourses)
        .copyWith());
  }

  /// The title was changed to [title]
  Future<void> changeExamTitle({required String title}) async {
    final examTitle = ExamTitle.dirty(value: title);
    emit(state.copyWith(examTitle: examTitle));
  }

  /// The topic was changed to [topic]
  Future<void> changeExamTopic({required String topic}) async {
    final examTopic = ExamTopic.dirty(value: topic);
    emit(state.copyWith(examTopic: examTopic));
  }

  /// The course was changed to [course]
  Future<void> changeExamCourse({required Course course}) async {
    final examCourse = ExamCourse.dirty(value: course);
    emit(state.copyWith(examCourse: examCourse));
  }

  /// The date of the exam was changed to [date]
  Future<void> changeExamDate({required DateTime date}) async {
    final examDate = ExamDate.dirty(date);
    emit(state.copyWith(examDate: examDate));
  }

  /// Trigger the submission of the current exam form.
  Future<void> submitExam() async {
    if (!state.status.isValidated) {
      log("Error during exam creation/adjustment, the form was not validated.");
      return;
    }

    emit(state.copyWith(status: FormzStatus.submissionInProgress));

    if (state.isNewExamEdit) {
      final examDto = NewExamDTO(
        title: state.examTitle.value,
        topic: state.examTopic.value,
        course: state.examCourse.value,
        dateOfExam: state.examDate.value,
      );
      try {
        await _examsRepository.uploadExam(exam: examDto);
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (e) {
        log("Upload failed with error: ${e.toString()}");
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    } else if (state.adjustedExamId != null) {
      final adjustedExamDto = NewExamDTO(
        title: state.examTitle.value,
        topic: state.examTopic.value,
        course: state.examCourse.value,
        dateOfExam: state.examDate.value,
      );
      try {
        await _examsRepository.updateExam(
            exam: adjustedExamDto, examId: state.adjustedExamId!);
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (e) {
        log(e.toString());
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    } else {
      log("Error during exam adjustment, the form is missing an examId.");
      emit(state.copyWith(status: FormzStatus.invalid));
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _authenticationSubscription.cancel();
  }
}
