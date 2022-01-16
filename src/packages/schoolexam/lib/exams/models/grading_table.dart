import 'package:equatable/equatable.dart';

import 'grading_table_lower_bound.dart';

class GradingTable extends Equatable {
  final List<GradingTableLowerBound> lowerBounds;

  const GradingTable({required List<GradingTableLowerBound> this.lowerBounds});

  @override
  List<Object?> get props => [lowerBounds];

  static final empty = GradingTable(lowerBounds: [
    GradingTableLowerBound(points: 10, grade: "sehr gut"),
    GradingTableLowerBound(points: 5, grade: "gut")
  ]);
}
