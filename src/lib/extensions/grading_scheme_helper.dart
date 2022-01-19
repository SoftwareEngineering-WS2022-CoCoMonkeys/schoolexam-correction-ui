import 'package:collection/src/iterable_extensions.dart';import 'package:schoolexam/exams/models/exam.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/exams/models/grading_table_lower_bound.dart';

abstract class GradingSchemeHelper {
  /// Gets a default grading scheme based on the [low] and [high] numeric grade
  /// for a given [exam].
  /// Currently, the two official Germany grading schemes are supported.
  /// Otherwise, an empty [GradingTable] is returned.
  /// Source: https://de.wikipedia.org/wiki/Vorlage:Punktesystem_der_gymnasialen_Oberstufe
  static GradingTable getDefaultGradingScheme(
      {required int low, required int high, required Exam exam}) {
    List<String> grades = [];
    List<double> points = [];
    if (low == 1 && high == 6) {
      grades = [
        "sehr gut",
        "gut",
        "befriedigend",
        "ausreichend",
        "mangelhaft",
        "ungenügend"
      ];
      points = [0.85, 0.70, 0.55, 0.4, 0.20, 0.0];
    } else if (low == 0 && high == 15) {
      grades = [
        "sehr gut (1+)",
        "sehr gut (1)",
        "sehr gut (1-)",
        "gut (2+)",
        "gut (2)",
        "gut (2-)",
        "befriedigend (3+)",
        "befriedigend (3)",
        "befriedigend (3-)",
        "ausreichend (4+)",
        "ausreichend (4)",
        "schwach ausreichend (4-)",
        "mangelhaft (5+)",
        "mangelhaft (5)",
        "mangelhaft (5-)",
        "ungenügend (6)"
      ];
      points = [
        0.95,
        0.90,
        0.85,
        0.80,
        0.75,
        0.70,
        0.65,
        0.60,
        0.55,
        0.50,
        0.45,
        0.39,
        0.33,
        0.27,
        0.20,
        0.0
      ];
    }
    final maxPoints = exam.tasks.fold<double>(0.0, (p, c) => p + c.maxPoints);
    final lowerBounds = grades.mapIndexed((i, grade) {
      return GradingTableLowerBound(
          // round down to nearest half point
          points: (2 * (points[i] * maxPoints)).floor().toDouble() / 2,
          grade: grade);
    }).toList();
    return GradingTable(lowerBounds: lowerBounds);
  }
}
