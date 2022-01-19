import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/exams/dto/new_exam_dto.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/authentication/authentication.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details_extensions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';

import 'exam_details_form_input.dart';
import 'exam_details_state.dart';

class ExamDetailsCubit extends Cubit<ExamDetailsState> {
  final LanguageCubit _languageCubit;
  late final StreamSubscription _authenticationSubscription;
  final ExamsRepository _examsRepository;
  List<Course> validCourses;

  ExamDetailsCubit(
      {required ExamsRepository examsRepository,
      required AuthenticationBloc authenticationBloc,
      required LanguageCubit languageCubit})
      : _examsRepository = examsRepository,
        _languageCubit = languageCubit,
        validCourses = [],
        super(ExamDetailsInitial.empty()) {
    _authenticationSubscription =
        authenticationBloc.stream.listen(_onAuthenticationStateChanged);
  }

  void _onAuthenticationStateChanged(AuthenticationState state) async {
    switch (state.status) {
      case AuthenticationStatus.authenticated:
        validCourses = await _examsRepository.getCourses();
        break;
      case AuthenticationStatus.unauthenticated:
        validCourses = [];
        break;
      case AuthenticationStatus.unknown:
        validCourses = [];
        break;
    }
  }

  /// Starts the creation of a new exam.
  void openNewExam() =>
      emit(ExamDetailsCreationInProgress.start(validCourses: validCourses));

  /// Open the exam [exam] for adjustment.
  void adjustExamOpened({required Exam exam}) =>
      emit(ExamDetailsUpdateInProgress.start(
          exam: exam, validCourses: validCourses));

  /// The title was changed to [title]
  void changeExamTitle({required String title}) {
    final examTitle = ExamTitle.dirty(value: title);
    if (state is ExamDetailsCreationState) {
      emit(ExamDetailsCreationInProgress.proceed(
              state: state as ExamDetailsCreationState)
          .copyWith(examTitle: examTitle));
    } else if (state is ExamDetailsUpdateState) {
      emit(ExamDetailsUpdateInProgress.proceed(
              state: state as ExamDetailsUpdateState)
          .copyWith(examTitle: examTitle));
    }
  }

  /// The topic was changed to [topic]
  void changeExamTopic({required String topic}) {
    final examTopic = ExamTopic.dirty(value: topic);
    if (state is ExamDetailsCreationState) {
      emit(ExamDetailsCreationInProgress.proceed(
              state: state as ExamDetailsCreationState)
          .copyWith(examTopic: examTopic));
    } else if (state is ExamDetailsUpdateState) {
      emit(ExamDetailsUpdateInProgress.proceed(
              state: state as ExamDetailsUpdateState)
          .copyWith(examTopic: examTopic));
    }
  }

  /// The course was changed to [course]
  void changeExamCourse({required Course course}) {
    final examCourse = ExamCourse.dirty(value: course);
    if (state is ExamDetailsCreationState) {
      emit(ExamDetailsCreationInProgress.proceed(
              state: state as ExamDetailsCreationState)
          .copyWith(examCourse: examCourse));
    } else if (state is ExamDetailsUpdateState) {
      emit(ExamDetailsUpdateInProgress.proceed(
              state: state as ExamDetailsUpdateState)
          .copyWith(examCourse: examCourse));
    }
  }

  /// The date of the exam was changed to [date]
  void changeExamDate({required DateTime date}) {
    final examDate = ExamDate.dirty(date);
    if (state is ExamDetailsCreationState) {
      emit(ExamDetailsCreationInProgress.proceed(
              state: state as ExamDetailsCreationState)
          .copyWith(examDate: examDate));
    } else if (state is ExamDetailsUpdateState) {
      emit(ExamDetailsUpdateInProgress.proceed(
              state: state as ExamDetailsUpdateState)
          .copyWith(examDate: examDate));
    }
  }

  /// Trigger the submission of the current exam form.
  Future<void> submitExam() async {
    log("Requested to submit exam.");

    if (!state.status.isValidated) {
      log("Error during exam creation/adjustment, the form was not validated.");
      return;
    }

    final basis = NewExamDTO(
      title: state.examTitle.value,
      topic: state.examTopic.value,
      course: state.examCourse.value,
      dateOfExam: state.examDate.value,
    );

    // A) Submit creation
    if (state is ExamDetailsCreationInProgress ||
        state is ExamDetailsCreationFailure) {
      final creationState = state as ExamDetailsCreationState;
      emit(ExamDetailsCreationLoading(
          initial: creationState,
          description: basis.getCreationLoadingDescription(_languageCubit)));

      try {
        await _examsRepository.uploadExam(exam: basis);
        log("Upload for ${basis.title} succeeded");
        emit(ExamDetailsCreationSuccess(
            initial: creationState,
            description: basis.getCreationDescription(_languageCubit)));
      } on NetworkException catch (e) {
        log("Upload failed with error: ${e.toString()}");
        emit(ExamDetailsCreationFailure(
            initial: creationState,
            exception: e,
            description: e.getCreationDescription(_languageCubit, basis)));
      }
    }

    // B) Submit update
    else if (state is ExamDetailsUpdateInProgress ||
        state is ExamDetailsUpdateFailure) {
      final updateState = state as ExamDetailsUpdateState;
      emit(ExamDetailsUpdateLoading(
          initial: updateState,
          description: basis.getUpdateLoadingDescription(_languageCubit)));

      try {
        await _examsRepository.updateExam(
            exam: basis, examId: updateState.examId);
        log("Update for ${basis.title} succeeded");
        emit(ExamDetailsUpdateSuccess(
            initial: updateState,
            description: basis.getUpdateDescription(_languageCubit)));
      } on NetworkException catch (e) {
        log("Update failed with error: ${e.toString()}");
        emit(ExamDetailsUpdateFailure(
            initial: updateState,
            exception: e,
            description: e.getUpdateDescription(_languageCubit, basis)));
      }
    }
    // C) Drop other states
    else {
      log("Cannot submit from state $state.");
      return;
    }
  }

  @override
  Future<void> close() async {
    await _authenticationSubscription.cancel();
    await super.close();
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    log("Following error occurred within details bloc : ${error.toString()}");
    super.onError(error, stackTrace);
  }
}
