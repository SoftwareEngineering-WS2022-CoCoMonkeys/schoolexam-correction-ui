import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/grading_table_lower_bound_dto.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/utils/api_helper.dart';

class GradingTableDTO extends Equatable {
  final List<GradingTableLowerBoundDTO> lowerBounds;

  const GradingTableDTO({required this.lowerBounds});

  GradingTableDTO.fromJson(Map<String, dynamic> json)
      : lowerBounds = List<Map<String, dynamic>>.from(
                ApiHelper.getValue(map: json, keys: ["lowerBounds"], value: []))
            .map((e) => GradingTableLowerBoundDTO.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {"lowerBounds": lowerBounds};

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [lowerBounds];

  GradingTable toModel() {
    return GradingTable(
        lowerBounds: lowerBounds.map((e) => e.toModel()).toList());
  }
}
