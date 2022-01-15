import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/task_dto.dart';
import 'package:schoolexam/utils/api_helper.dart';

import 'participant_dto.dart';
import '../models/exam.dart';

class ExamDTO extends Equatable {
  final String id;
  final String status;
  final String title;

  /// Date when exam was written by all students
  final DateTime dateOfExam;

  /// Final date for the completion of the correction
  final DateTime dueDate;

  final String topic;

  /// The percentage of the exam that is already corrected
  final double quota;

  final List<ParticipantDTO> participants;

  final List<TaskDTO> tasks;

  ExamDTO.fromJson(Map<String, dynamic> json)
      : id = ApiHelper.getValue(map: json, keys: ["id"], value: ""),
        status = ApiHelper.getValue(map: json, keys: ["status"], value: ""),
        title = ApiHelper.getValue(map: json, keys: ["title"], value: ""),
        topic = ApiHelper.getValue(map: json, keys: ["topic"], value: ""),
        quota = ApiHelper.getValue(map: json, keys: ["quota"], value: 0.0),
        dateOfExam =
            ApiHelper.getValue(map: json, keys: ["date"], value: DateTime(0)),
        dueDate = ApiHelper.getValue(
            map: json, keys: ["dueDate"], value: DateTime(0)),
        participants = List<Map<String, dynamic>>.from(ApiHelper.getValue(
            map: json,
            keys: ["participants"],
            value: [])).map((e) => ParticipantDTO.fromJson(e)).toList(),
        tasks = List<Map<String, dynamic>>.from(
                ApiHelper.getValue(map: json, keys: ["tasks"], value: []))
            .map((e) => TaskDTO.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "title": title,
        "topic": topic,
        "quota": quota,
        "dateOfExam": dateOfExam,
        "dateOfDeadline": dueDate,
        "participants": participants,
        "tasks": tasks
      };

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props =>
      [id, status, title, topic, quota, dateOfExam, dueDate, participants];

  Exam toModel() {
    return Exam(
        status: ExamStatus.values.firstWhere(
            // Unknown is not known to API
            (element) => element.name.toLowerCase() == status.toLowerCase(),
            orElse: () => ExamStatus.unknown),
        id: id,
        title: title,
        topic: topic,
        quota: quota,
        dateOfExam: dateOfExam,
        dueDate: dueDate,
        participants:
            participants.map((e) => e.toModel()).toList(growable: false),
        tasks: tasks.map((e) => e.toModel()).toList(growable: false));
  }
}
