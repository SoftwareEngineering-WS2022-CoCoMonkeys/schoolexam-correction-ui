import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/login/login_form.dart';
import 'package:schoolexam_correction_ui/models/password.dart';
import 'package:schoolexam_correction_ui/models/username.dart';

import 'exam_details_event.dart';
import 'exam_details_form.dart';
import 'exam_details_form_input.dart';
import 'exam_details_state.dart';

class ExamDetailsBloc extends Bloc<ExamDetailsEvent, ExamDetailsState> {
  final AuthenticationRepository _authenticationRepository;

  ExamDetailsBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(ExamDetailsState.initial()) {
    on<ExamTitleChanged>(_onExamTitleChanged);
    on<ExamTopicChanged>(_onExamTopicChanged);
    on<ExamCourseChanged>(_onExamCourseChanged);
    on<ExamDateChanged>(_onExamDateChanged);
    on<ExamSubmitted>(_onExamSubmitted);
  }

  _onExamTitleChanged(ExamTitleChanged event, Emitter<ExamDetailsState> emit) {
    print(state.validCourses.first.id);
    final examTitle = ExamTitle.dirty(value: event.examTitle);
    print(examTitle);
    emit(state.copyWith(
        examTitle: examTitle,
        status: ExamDetailsForm(
                examTitle: examTitle,
                examTopic: state.examTopic,
                examCourse: state.examCourse,
                examDate: state.examDate)
            .status));
  }

  _onExamTopicChanged(
      ExamTopicChanged event, Emitter<ExamDetailsState> emit) {
    final examTopic = ExamTopic.dirty(value: event.examTopic);
    print(examTopic);
    emit(state.copyWith(
        examTopic: examTopic,
        status: ExamDetailsForm(
                examTitle: state.examTitle,
                examTopic: examTopic,
                examCourse: state.examCourse,
                examDate: state.examDate)
            .status));
  }

  _onExamCourseChanged(
      ExamCourseChanged event, Emitter<ExamDetailsState> emit) {
    final examCourse = ExamCourse.dirty(value: event.examCourse);
    print(examCourse);
    emit(state.copyWith(
        examCourse: examCourse,
        status: ExamDetailsForm(
                examTitle: state.examTitle,
                examTopic: state.examTopic,
                examCourse: examCourse,
                examDate: state.examDate)
            .status));
  }

  _onExamDateChanged(ExamDateChanged event, Emitter<ExamDetailsState> emit) {
    final examDate = ExamDate.dirty(event.examDate);
    print(examDate);
    emit(state.copyWith(
        examDate: examDate,
        status: ExamDetailsForm(
                examTitle: state.examTitle,
                examTopic: state.examTopic,
                examCourse: state.examCourse,
                examDate: examDate)
            .status));
  }

  _onExamSubmitted(ExamSubmitted event, Emitter<ExamDetailsState> emit) {
    //TODO
    throw UnimplementedError();
  }
}
