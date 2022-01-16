import 'package:schoolexam/exams/models/exam.dart';
import 'package:schoolexam/exams/models/grading_table_lower_bound.dart';

class GradingTableLowerBoundData {
  final double points;
  final String grade;
  final String examId;

  const GradingTableLowerBoundData({required this.points, required this.grade, required this.examId});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {'grade': grade, 'points': points, 'examId': examId};
  }

  static GradingTableLowerBoundData fromModel(GradingTableLowerBound model, Exam exam) =>
      GradingTableLowerBoundData(grade: model.grade, points: model.points, examId: exam.id);

  GradingTableLowerBound toModel() =>
      GradingTableLowerBound(points: points, grade: grade);

  static GradingTableLowerBoundData fromMap(Map<String, dynamic> data) {
    return GradingTableLowerBoundData(
        grade: data['grade'], points: data['points'], examId: data['examId']);
  }
}
