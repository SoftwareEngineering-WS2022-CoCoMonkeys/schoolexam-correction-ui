import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/task_dto.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/utils/api_helper.dart';

import '../models/exam.dart';
import 'grading_table_dto.dart';
import 'participant_dto.dart';

class ExamDTO extends Equatable {
  final String id;
  final String status;
  final String title;

  /// Date when exam was written by all students
  final String date;

  /// Final date for the completion of the correction
  final String dueDate;

  final String topic;

  /// The percentage of the exam that is already corrected
  final double quota;

  final List<ParticipantDTO> participants;

  final List<TaskDTO> tasks;
  final GradingTableDTO? gradingTable;

  const ExamDTO({
    required this.id,
    required this.status,
    required this.title,
    required this.date,
    required this.dueDate,
    required this.topic,
    required this.quota,
    required this.participants,
    required this.tasks,
    this.gradingTable,
  });

  ExamDTO.fromJson(Map<String, dynamic> json)
      : id = ApiHelper.getValue(map: json, keys: ["id"], value: ""),
        status = ApiHelper.getValue(map: json, keys: ["status"], value: ""),
        title = ApiHelper.getValue(map: json, keys: ["title"], value: ""),
        topic = ApiHelper.getValue(map: json, keys: ["topic"], value: ""),
        quota = ApiHelper.getValue(map: json, keys: ["quota"], value: 0.0),
        date = ApiHelper.getValue(map: json, keys: ["date"], value: ""),
        dueDate = ApiHelper.getValue(map: json, keys: ["dueDate"], value: ""),
        participants = List<Map<String, dynamic>>.from(ApiHelper.getValue(
            map: json,
            keys: ["participants"],
            value: [])).map((e) => ParticipantDTO.fromJson(e)).toList(),
        tasks = List<Map<String, dynamic>>.from(
                ApiHelper.getValue(map: json, keys: ["tasks"], value: []))
            .map((e) => TaskDTO.fromJson(e))
            .toList(),
        gradingTable =
            json.containsKey('gradingTable') && json['gradingTable'] != null
                ? GradingTableDTO.fromJson(json['gradingTable'])
                : null;

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "title": title,
        "topic": topic,
        "quota": quota,
        "date": date,
        "dueDate": dueDate,
        "participants": participants,
        "tasks": tasks,
        "gradingTable": gradingTable
      };

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [
        id,
        status,
        title,
        topic,
        quota,
        date,
        dueDate,
        participants,
        gradingTable
      ];

  /// Converts to a DTO instance based on the [model].
  /// Importantly, the internal model uses percentages as 50% instead of 0.5 like the API.
  factory ExamDTO.fromModel({required Exam model}) => ExamDTO(
      id: model.id,
      status: model.status.name,
      title: model.title,
      topic: model.topic,
      quota: model.quota / 100,
      date: model.dateOfExam.toIso8601String(),
      dueDate: (model.dueDate != null) ? model.dueDate!.toIso8601String() : "",
      gradingTable: GradingTableDTO.fromModel(model.gradingTable),
      participants: model.participants
          .map((e) => ParticipantDTO.fromModel(model: e))
          .toList(),
      tasks: model.tasks.map((e) => TaskDTO.fromModel(task: e)).toList());

  /// Converts this instance to its model [Exam] representation.
  /// Importantly, the internal model uses percentages as 50% instead of 0.5 like the API.
  Exam toModel() {
    return Exam(
        status: ExamStatus.values.firstWhere(
            // Unknown is not known to API
            (element) => element.name.toLowerCase() == status.toLowerCase(),
            orElse: () => ExamStatus.unknown),
        id: id,
        title: title,
        topic: topic,
        quota: quota * 100,
        dateOfExam: DateTime.parse(date),
        dueDate: DateTime.parse(dueDate),
        participants:
            participants.map((e) => e.toModel()).toList(growable: false),
        tasks: tasks.map((e) => e.toModel()).toList(growable: false),
        gradingTable: gradingTable != null
            ? gradingTable!.toModel()
            : GradingTable.empty);
  }
}
