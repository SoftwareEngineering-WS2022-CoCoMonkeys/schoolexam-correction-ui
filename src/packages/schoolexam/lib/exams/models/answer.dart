import 'correctable.dart';
import 'task.dart';

class Answer extends Correctable {
  final Task task;
  final List<AnswerSegment> segments;

  const Answer(
      {required this.task,
      required this.segments,
      required double achievedPoints,
      required CorrectableStatus status})
      : super(achievedPoints: achievedPoints, status: status);

  static const empty = const Answer(
      task: Task.empty,
      segments: [],
      achievedPoints: 0.0,
      status: CorrectableStatus.unknown);

  bool get isEmpty => this == Answer.empty;
  bool get isNotEmpty => this != Answer.empty;
}

/// Defines a segment within the PDF that is associated to an answer
class AnswerSegment {
  final SegmentPosition start;
  final SegmentPosition end;

  AnswerSegment({required this.start, required this.end});
}

/// Defines a single position within a PDF
class SegmentPosition {
  final int page;
  final double y;

  const SegmentPosition({required this.page, required this.y});
}
