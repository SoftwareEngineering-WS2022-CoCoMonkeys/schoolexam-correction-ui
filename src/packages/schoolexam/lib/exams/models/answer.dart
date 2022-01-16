import 'package:equatable/equatable.dart';

import 'correctable.dart';
import 'task.dart';

class Answer extends Correctable {
  final Task task;
  final List<AnswerSegment> segments;

  const Answer(
      {required this.task,
      required this.segments,
      required DateTime updatedAt,
      required double achievedPoints,
      required CorrectableStatus status})
      : super(
            achievedPoints: achievedPoints,
            status: status,
            updatedAt: updatedAt);

  static final empty = Answer(
      task: Task.empty,
      segments: [],
      achievedPoints: 0.0,
      updatedAt: DateTime(0),
      status: CorrectableStatus.unknown);

  bool get isEmpty => this == Answer.empty;

  bool get isNotEmpty => this != Answer.empty;

  @override
  List<Object?> get props => [status, achievedPoints, segments, task];

  Answer copyWith(
      {Task? task,
      List<AnswerSegment>? segments,
      double? achievedPoints,
      CorrectableStatus? status,
      DateTime? updatedAt}) {
    return Answer(
        task: task ?? this.task,
        segments: segments ?? this.segments,
        updatedAt: updatedAt ?? this.updatedAt,
        achievedPoints: achievedPoints ?? this.achievedPoints,
        status: status ?? this.status);
  }
}

/// Defines a segment within the PDF that is associated to an answer
class AnswerSegment extends Equatable {
  final SegmentPosition start;
  final SegmentPosition end;

  AnswerSegment({required this.start, required this.end});

  int compareTo(AnswerSegment other) {
    int c1 = start.compareTo(other.start);
    return (c1 == 0) ? end.compareTo(other.end) : c1;
  }

  @override
  List<Object?> get props => [start, end];
}

/// Defines a single position within a PDF
class SegmentPosition extends Equatable {
  final int page;
  final double y;

  const SegmentPosition({required this.page, required this.y});

  @override
  List<Object?> get props => [page, y];

  int compareTo(SegmentPosition other) {
    int c1 = page.compareTo(other.page);
    // Das Koordinatensystem in PDFs beginnt links unten
    return (c1 == 0) ? y.compareTo(other.y) * -1 : c1;
  }
}
