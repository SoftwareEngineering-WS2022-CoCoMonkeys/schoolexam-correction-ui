import 'package:equatable/equatable.dart';

class GradingTableLowerBound extends Equatable {
  final double points;
  final String grade;

  const GradingTableLowerBound({required this.points, required this.grade});

  @override
  List<Object?> get props => [points, grade];
}
