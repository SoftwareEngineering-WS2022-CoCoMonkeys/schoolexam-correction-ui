import 'package:schoolexam/exams/exams.dart';

class AnswerSegmentData {
  final String submissionId;
  final String taskId;
  final int? segmentId;

  final int startPage;
  final int endPage;

  final double startY;
  final double endY;

  const AnswerSegmentData(
      {required this.submissionId,
      required this.taskId,
      this.segmentId,
      required this.startPage,
      required this.endPage,
      required this.startY,
      required this.endY});

  Map<String, dynamic> toMap() => {
        'submissionId': submissionId,
        'taskId': taskId,
        'startPage': startPage,
        'endPage': endPage,
        'startY': startY,
        'endY': endY,
      };

  factory AnswerSegmentData.fromMap(Map<String, dynamic> data) =>
      AnswerSegmentData(
          submissionId: data['submissionId'],
          taskId: data['taskId'],
          segmentId: data['segmentId'],
          startPage: data['startPage'],
          endPage: data['endPage'],
          startY: data['startY'],
          endY: data['endY']);

  factory AnswerSegmentData.fromModel(
          {required Submission submission,
          required Task task,
          required AnswerSegment segment}) =>
      AnswerSegmentData(
          submissionId: submission.id,
          taskId: task.id,
          startPage: segment.start.page,
          startY: segment.start.y,
          endPage: segment.end.page,
          endY: segment.end.y);

  AnswerSegment toModel() => AnswerSegment(
      start: SegmentPosition(page: startPage, y: startY),
      end: SegmentPosition(page: endPage, y: endY));
}
