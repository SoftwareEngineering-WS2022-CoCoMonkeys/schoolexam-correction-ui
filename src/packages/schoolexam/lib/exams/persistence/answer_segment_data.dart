import 'package:schoolexam/exams/exams.dart';

class AnswerSegmentData {
  final String submissionId;
  final String taskId;
  final int segmentId;

  final int startPage;
  final int endPage;

  final double startY;
  final double endY;

  const AnswerSegmentData(
      {required this.submissionId,
      required this.taskId,
      required this.segmentId,
      required this.startPage,
      required this.endPage,
      required this.startY,
      required this.endY});

  static AnswerSegmentData fromMap(Map<String, dynamic> data) =>
      AnswerSegmentData(
          submissionId: data['submissionId'],
          taskId: data['taskId'],
          segmentId: data['segmentId'],
          startPage: data['startPage'],
          endPage: data['endPage'],
          startY: data['startY'],
          endY: data['endY']);

  AnswerSegment toModel() => AnswerSegment(
      start: SegmentPosition(page: startPage, y: startY),
      end: SegmentPosition(page: endPage, y: endY));
}
