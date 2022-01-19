import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/grading_table_lower_bound_dto.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/utils/api_helper.dart';

class GradingTableDTO extends Equatable {
  final List<GradingTableLowerBoundDTO> lowerBounds;

  const GradingTableDTO({required this.lowerBounds});

  factory GradingTableDTO.fromJson(Map<String, dynamic> json) =>
      GradingTableDTO(
          lowerBounds: List<Map<String, dynamic>>.from(ApiHelper.getValue(
                  map: json, keys: ["lowerBounds"], value: []))
              .map((e) => GradingTableLowerBoundDTO.fromJson(e))
              .toList()
            ..sort((a, b) => b.points.compareTo(a.points)));

  Map<String, dynamic> toJson() => {"lowerBounds": lowerBounds};

  @override
  String toString() {
    return jsonEncode(this);
  }

  GradingTable toModel() {
    return GradingTable(
        lowerBounds: lowerBounds.map((e) => e.toModel()).toList());
  }

  GradingTableDTO.fromModel(GradingTable model)
      : lowerBounds = model.lowerBounds
            .map((lb) => GradingTableLowerBoundDTO.fromModel(lb))
            .toList();

  @override
  List<Object?> get props => [lowerBounds];
}
