import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/schoolexam.dart';

import 'exam_details_event.dart';
import 'exam_details_form_input.dart';
import 'exam_details_state.dart';

class ExamDetailsBloc extends Bloc<ExamDetailsEvent, ExamDetailsState> {
  final ExamsRepository _examsRepository;

  ExamDetailsBloc({
    required ExamsRepository examsRepository,
  })  : _examsRepository = examsRepository,
        super(ExamDetailsState.initialNewExam()) {
    on<NewExamOpened>(_onNewExamOpened);
    on<AdjustExamOpened>(_onAdjustExamOpened);
    on<ExamTitleChanged>(_onExamTitleChanged);
    on<ExamTopicChanged>(_onExamTopicChanged);
    on<ExamCourseChanged>(_onExamCourseChanged);
    on<ExamDateChanged>(_onExamDateChanged);
    on<ExamSubmitted>(_onExamSubmitted);
  }

  void _onNewExamOpened(NewExamOpened event, Emitter<ExamDetailsState> emit) {
    // only reset form values if we switch from an exam adjustment to an exam creation
    if (!state.isNewExamEdit) {
      emit(ExamDetailsState.initialNewExam());
    }
  }

  void _onAdjustExamOpened(
      AdjustExamOpened event, Emitter<ExamDetailsState> emit) {
    final examToAdjust = event.exam;
    // Force form status update
    emit(ExamDetailsState.initialAdjustExam(exam: examToAdjust).copyWith());
  }

  void _onExamTitleChanged(
      ExamTitleChanged event, Emitter<ExamDetailsState> emit) {
    final examTitle = ExamTitle.dirty(value: event.examTitle);
    emit(state.copyWith(examTitle: examTitle));
  }

  void _onExamTopicChanged(
      ExamTopicChanged event, Emitter<ExamDetailsState> emit) {
    final examTopic = ExamTopic.dirty(value: event.examTopic);
    emit(state.copyWith(examTopic: examTopic));
  }

  void _onExamCourseChanged(
      ExamCourseChanged event, Emitter<ExamDetailsState> emit) {
    final examCourse = ExamCourse.dirty(value: event.examCourse);
    emit(state.copyWith(examCourse: examCourse));
  }

  void _onExamDateChanged(
      ExamDateChanged event, Emitter<ExamDetailsState> emit) {
    final examDate = ExamDate.dirty(event.examDate);
    emit(state.copyWith(examDate: examDate));
  }

  void _onExamSubmitted(
      ExamSubmitted event, Emitter<ExamDetailsState> emit) async {
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
}
