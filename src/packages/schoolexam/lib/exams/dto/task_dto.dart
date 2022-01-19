import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/utils/api_helper.dart';

class TaskDTO extends Equatable {
  final String id;
  final String title;
  final double maxPoints;

  const TaskDTO({
    required this.id,
    required this.title,
    required this.maxPoints,
  });

  factory TaskDTO.fromJson(Map<String, dynamic> json) => TaskDTO(
      id: ApiHelper.getValue(map: json, keys: ["id"], value: ""),
      title: ApiHelper.getValue(map: json, keys: ["title"], value: ""),
      maxPoints:
          ApiHelper.getValue(map: json, keys: ["maxPoints"], value: 0.0));

  factory TaskDTO.fromModel({required Task task}) =>
      TaskDTO(id: task.id, title: task.title, maxPoints: task.maxPoints);

  Map<String, dynamic> toJson() =>
      {"id": id, "title": title, "maxPoints": maxPoints};

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [id];

  Task toModel() => Task(id: id, title: title, maxPoints: maxPoints);
}
