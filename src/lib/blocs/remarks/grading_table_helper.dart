import 'dart:developer';
import 'dart:math' as math;

import 'package:schoolexam/exams/exams.dart';

/// This helper is responsible for applying changes to the [GradingTable] model.
class GradingTableHelper {
  const GradingTableHelper();

  GradingTable changeGradingTableBoundPoints(
      {required Exam exam,
      required GradingTable table,
      required int index,
      required double points}) {
    final copy = table.valueCopy();

    final adjustedLowerBound = copy.lowerBounds[index].copyWith(points: points);
    // remove old bound
    copy.lowerBounds.removeAt(index);

    final maxPoints = exam.tasks.fold<double>(0.0, (p, c) => p + c.maxPoints);
    points = math.min(points, maxPoints);

    // insert updated bound at same index
    copy.lowerBounds.insert(index, adjustedLowerBound);

    // Ensure lower bound constraint
    for (int j = 0; j < copy.lowerBounds.length; j++) {
      final lb = exam.gradingTable.lowerBounds[j];
      if (j < index && lb.points < points || j > index && lb.points > points) {
        log("Adjusting lower bound in grading table");

        final nextLb = lb.copyWith(points: points);
        // remove old bound
        copy.lowerBounds.removeAt(j);

        // insert updated bound at same index
        copy.lowerBounds.insert(j, nextLb);
      }
    }

    return copy;
  }
}
