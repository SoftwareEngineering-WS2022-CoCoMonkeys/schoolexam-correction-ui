import 'package:equatable/equatable.dart';

import 'grading_table_lower_bound.dart';

class GradingTable extends Equatable {
  final List<GradingTableLowerBound> lowerBounds;

  const GradingTable({required this.lowerBounds});

  @override
  List<Object?> get props => [lowerBounds];

  static const empty = GradingTable(lowerBounds: []);

  /// Creates a copy by value of this grading table
  GradingTable valueCopy() {
    return GradingTable(
        lowerBounds: lowerBounds.map((lb) => lb.valueCopy()).toList());
  }
}
