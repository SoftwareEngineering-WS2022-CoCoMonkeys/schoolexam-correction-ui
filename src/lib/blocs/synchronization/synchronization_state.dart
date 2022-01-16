import 'package:equatable/equatable.dart';

/// This enum is used for describing the current status of synchronization between the local device and online API.
/// none : A push is needed, but not yet initiated
/// ongoing : A push is currently in process
/// failed : A push was attempted, but failed
/// succeeded : No push is needed. Local data is available online.
enum PushStatus { none, ongoing, failed, succeeded }

class SynchronizationState extends Equatable {
  /// Describes in which [PushStatus] the upload of the PDF file is.
  final PushStatus remarkStatus;

  /// Describes in which [AnswerStatus] the upload of the local answers is.
  final PushStatus answerStatus;

  const SynchronizationState(
      {required this.remarkStatus, required this.answerStatus});

  SynchronizationState copyWith({
    PushStatus? remarkStatus,
    PushStatus? answerStatus,
  }) {
    return SynchronizationState(
      remarkStatus: remarkStatus ?? this.remarkStatus,
      answerStatus: answerStatus ?? this.answerStatus,
    );
  }

  @override
  List<Object> get props => [remarkStatus, answerStatus];
}

class InitSynchronizationState extends SynchronizationState {
  const InitSynchronizationState()
      : super(
            remarkStatus: PushStatus.succeeded,
            answerStatus: PushStatus.succeeded);
}
