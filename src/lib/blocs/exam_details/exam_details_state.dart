import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_loading.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_success.dart';

import 'exam_details_form.dart';
import 'exam_details_form_input.dart';

abstract class ExamDetailsState extends Equatable {
  final FormzStatus status;
  final ExamTitle examTitle;
  final ExamTopic examTopic;
  final ExamCourse examCourse;
  final ExamDate examDate;

  /// Specifies which courses are allowed for selection with the current data.
  /// In the current version, all updates or creation may be associated to all courses.
  final List<Course> validCourses;

  const ExamDetailsState(
      {required this.status,
      required this.examTitle,
      required this.examTopic,
      required this.examCourse,
      required this.examDate,
      required this.validCourses});

  @override
  List<Object?> get props =>
      [status, examTitle, examTopic, examCourse, examDate, validCourses];
}

class ExamDetailsInitial extends ExamDetailsState {
  ExamDetailsInitial.empty()
      : super(
            status: FormzStatus.pure,
            examTitle: const ExamTitle.pure(),
            examTopic: const ExamTopic.pure(),
            examCourse: const ExamCourse.pure(),
            examDate: ExamDate.pure(),
            validCourses: []);
}

/// Tracks the state of the current creation of an exam.
abstract class ExamDetailsCreationState extends ExamDetailsState {
  const ExamDetailsCreationState(
      {required FormzStatus status,
      required ExamTitle examTitle,
      required ExamTopic examTopic,
      required ExamCourse examCourse,
      required ExamDate examDate,
      required List<Course> validCourses})
      : super(
            status: status,
            examTitle: examTitle,
            examTopic: examTopic,
            examCourse: examCourse,
            examDate: examDate,
            validCourses: validCourses);
}

/// Tracks the state of the current update of an exam.
abstract class ExamDetailsUpdateState extends ExamDetailsState {
  /// The id of the currently updated [Exam].
  final String examId;

  const ExamDetailsUpdateState(
      {required this.examId,
      required FormzStatus status,
      required ExamTitle examTitle,
      required ExamTopic examTopic,
      required ExamCourse examCourse,
      required ExamDate examDate,
      required List<Course> validCourses})
      : super(
            status: status,
            examTitle: examTitle,
            examTopic: examTopic,
            examCourse: examCourse,
            examDate: examDate,
            validCourses: validCourses);

  @override
  List<Object?> get props => super.props..add(examId);
}

/// Tracks the creation values for an exam.
class ExamDetailsCreationInProgress extends ExamDetailsCreationState {
  const ExamDetailsCreationInProgress(
      {required FormzStatus status,
      required ExamTitle examTitle,
      required ExamTopic examTopic,
      required ExamCourse examCourse,
      required ExamDate examDate,
      required List<Course> validCourses})
      : super(
            status: status,
            examTitle: examTitle,
            examTopic: examTopic,
            examCourse: examCourse,
            examDate: examDate,
            validCourses: validCourses);

  /// Start the creation of a new exam using [validCourses].
  ExamDetailsCreationInProgress.start({required List<Course> validCourses})
      : this(
            status: FormzStatus.pure,
            examTitle: const ExamTitle.pure(),
            examTopic: const ExamTopic.pure(),
            examCourse: const ExamCourse.pure(),
            examDate: ExamDate.pure(),
            validCourses: validCourses);

  /// Continue an old creation [state].
  ExamDetailsCreationInProgress.proceed(
      {required ExamDetailsCreationState state})
      : this(
            status: state.status,
            examTitle: state.examTitle,
            examTopic: state.examTopic,
            examCourse: state.examCourse,
            examDate: state.examDate,
            validCourses: state.validCourses);

  ExamDetailsCreationInProgress copyWith({
    FormzStatus? status,
    ExamTitle? examTitle,
    ExamTopic? examTopic,
    ExamCourse? examCourse,
    ExamDate? examDate,
    List<Course>? validCourses,
  }) {
    return ExamDetailsCreationInProgress(
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
      validCourses: validCourses ?? this.validCourses,
    );
  }
}

/// Tracks the update values for an exam.
class ExamDetailsUpdateInProgress extends ExamDetailsUpdateState {
  const ExamDetailsUpdateInProgress(
      {required String examId,
      required FormzStatus status,
      required ExamTitle examTitle,
      required ExamTopic examTopic,
      required ExamCourse examCourse,
      required ExamDate examDate,
      required List<Course> validCourses})
      : super(
            examId: examId,
            status: status,
            examTitle: examTitle,
            examTopic: examTopic,
            examCourse: examCourse,
            examDate: examDate,
            validCourses: validCourses);

  /// Start the update of [exam] using [validCourses].
  ExamDetailsUpdateInProgress.start(
      {required Exam exam, required List<Course> validCourses})
      : super(
            status: FormzStatus.pure,
            validCourses: validCourses,
            examId: exam.id,
            examTitle: ExamTitle.dirty(value: exam.title),
            examTopic: ExamTopic.dirty(value: exam.topic),
            examCourse: ExamCourse.dirty(
                value: exam.participants.firstWhere(
                    (element) => element is Course,
                    orElse: () => Course.empty) as Course),
            examDate: ExamDate.dirty(exam.dateOfExam));

  /// Continue an old update [state].
  ExamDetailsUpdateInProgress.proceed({required ExamDetailsUpdateState state})
      : this(
            examId: state.examId,
            status: state.status,
            examTitle: state.examTitle,
            examTopic: state.examTopic,
            examCourse: state.examCourse,
            examDate: state.examDate,
            validCourses: state.validCourses);

  ExamDetailsUpdateInProgress copyWith({
    String? examId,
    FormzStatus? status,
    ExamTitle? examTitle,
    ExamTopic? examTopic,
    ExamCourse? examCourse,
    ExamDate? examDate,
    List<Course>? validCourses,
  }) {
    return ExamDetailsUpdateInProgress(
      examId: examId ?? this.examId,
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
      validCourses: validCourses ?? this.validCourses,
    );
  }
}

/// We are currently awaiting the result of the creation process.
/// This state includes a [description] with a localized information about the loading.
/// Using the [description] the e.g. [AppBlocListener] can display a dialog to the user.
class ExamDetailsCreationLoading extends ExamDetailsCreationState
    implements BlocLoading {
  @override
  final String description;

  ExamDetailsCreationLoading(
      {required ExamDetailsCreationState initial, required this.description})
      : super(
            status: FormzStatus.submissionInProgress,
            examTitle: initial.examTitle,
            examTopic: initial.examTopic,
            examCourse: initial.examCourse,
            examDate: initial.examDate,
            validCourses: initial.validCourses);

  @override
  List<Object?> get props => super.props..addAll([description]);
}

/// We are currently awaiting the result of the update process.
/// This state includes a [description] with a localized information about the loading.
/// Using the [description] the e.g. [AppBlocListener] can display a dialog to the user.
class ExamDetailsUpdateLoading extends ExamDetailsUpdateState
    implements BlocLoading {
  @override
  final String description;

  ExamDetailsUpdateLoading(
      {required ExamDetailsUpdateState initial, required this.description})
      : super(
            examId: initial.examId,
            status: FormzStatus.submissionInProgress,
            examTitle: initial.examTitle,
            examTopic: initial.examTopic,
            examCourse: initial.examCourse,
            examDate: initial.examDate,
            validCourses: initial.validCourses);

  @override
  List<Object?> get props => super.props..addAll([description]);
}

/// The creation process failed.
/// This state includes a [description] with a localized information about the reasoning.
class ExamDetailsCreationFailure extends ExamDetailsCreationState
    implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  ExamDetailsCreationFailure(
      {required ExamDetailsCreationState initial,
      required this.description,
      this.exception})
      : super(
            status: FormzStatus.submissionInProgress,
            examTitle: initial.examTitle,
            examTopic: initial.examTopic,
            examCourse: initial.examCourse,
            examDate: initial.examDate,
            validCourses: initial.validCourses);

  @override
  List<Object?> get props => super.props..addAll([description, exception]);
}

/// The creation process failed.
/// This state includes a [description] with a localized information about the reasoning.
class ExamDetailsUpdateFailure extends ExamDetailsUpdateState
    implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  ExamDetailsUpdateFailure(
      {required ExamDetailsUpdateState initial,
      required this.description,
      this.exception})
      : super(
            examId: initial.examId,
            status: FormzStatus.submissionInProgress,
            examTitle: initial.examTitle,
            examTopic: initial.examTopic,
            examCourse: initial.examCourse,
            examDate: initial.examDate,
            validCourses: initial.validCourses);

  @override
  List<Object?> get props =>
      super.props..addAll([description, exception, Random()]);
}

/// The creation process succeeded.
/// This state includes a [description] with a localized information about the created exam.
class ExamDetailsCreationSuccess extends ExamDetailsCreationState
    implements BlocSuccess {
  @override
  final String description;

  ExamDetailsCreationSuccess(
      {required ExamDetailsCreationState initial, this.description = ""})
      : super(
            status: FormzStatus.submissionInProgress,
            examTitle: initial.examTitle,
            examTopic: initial.examTopic,
            examCourse: initial.examCourse,
            examDate: initial.examDate,
            validCourses: initial.validCourses);

  @override
  List<Object?> get props => super.props..addAll([description]);
}

/// The creation process succeeded.
/// This state includes a [description] with a localized information about the created exam.
class ExamDetailsUpdateSuccess extends ExamDetailsUpdateState
    implements BlocSuccess {
  @override
  final String description;

  ExamDetailsUpdateSuccess(
      {required ExamDetailsUpdateState initial, this.description = ""})
      : super(
            examId: initial.examId,
            status: FormzStatus.submissionInProgress,
            examTitle: initial.examTitle,
            examTopic: initial.examTopic,
            examCourse: initial.examCourse,
            examDate: initial.examDate,
            validCourses: initial.validCourses);

  @override
  List<Object?> get props => super.props..addAll([description]);
}
