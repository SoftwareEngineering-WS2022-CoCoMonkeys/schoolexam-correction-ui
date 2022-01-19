import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/grading_table_lower_bound.dart';
import 'package:schoolexam/utils/api_helper.dart';

class GradingTableLowerBoundDTO extends Equatable {
  final String grade;
  final double points;

  const GradingTableLowerBoundDTO({
    required this.grade,
    required this.points,
  });

  GradingTableLowerBoundDTO.fromJson(Map<String, dynamic> json)
      : grade = ApiHelper.getValue(map: json, keys: ['grade'], value: ""),
        points = ApiHelper.getValue(map: json, keys: ['points'], value: 0.0);

  Map<String, dynamic> toJson() =>
      {"grade": grade, "points": points, "type": "Points"};

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [grade, points];

  GradingTableLowerBound toModel() {
    return GradingTableLowerBound(grade: grade, points: points);
  }

  GradingTableLowerBoundDTO.fromModel(GradingTableLowerBound model)
      : grade = model.grade,
        points = model.points;
}
