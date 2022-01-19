import 'package:equatable/equatable.dart';

class GradingTableLowerBound extends Equatable {
  // TODO consider percentages, too
  final double points;
  final String grade;

  const GradingTableLowerBound({required this.points, required this.grade});

  @override
  List<Object?> get props => [points, grade];

  GradingTableLowerBound copyWith({
    double? points,
    String? grade,
  }) {
    return GradingTableLowerBound(
      points: points ?? this.points,
      grade: grade ?? this.grade,
    );
  }

  /// Creates a copy by value of this grading table lower bound
  GradingTableLowerBound valueCopy() {
    return GradingTableLowerBound(points: points, grade: grade);
  }

  static const empty = GradingTableLowerBound(points: 0.0, grade: "");
}
