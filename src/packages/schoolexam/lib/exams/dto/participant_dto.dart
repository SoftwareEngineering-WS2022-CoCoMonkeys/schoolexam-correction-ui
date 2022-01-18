import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/course.dart';
import 'package:schoolexam/exams/models/participant.dart';
import 'package:schoolexam/exams/models/student.dart';
import 'package:schoolexam/utils/api_helper.dart';

class CourseDTO extends Equatable {
  final String id;
  final String displayName;

  final List<StudentDTO> children;

  CourseDTO.fromJson(Map<String, dynamic> json)
      : id = ApiHelper.getValue(map: json, keys: ["id"], value: ""),
        displayName = ApiHelper.getValue(map: json, keys: ["name"], value: ""),
        children = List<Map<String, dynamic>>.from(
                ApiHelper.getValue(map: json, keys: ["students"], value: []))
            .map((e) => StudentDTO.fromJson(e))
            .toList();

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [id, displayName, children];

  Course toModel() => Course(
      id: id,
      displayName: displayName,
      children: children.map((e) => e.toModel()).toList(growable: false));
}

class StudentDTO extends Equatable {
  final String id;
  final String displayName;

  StudentDTO.fromJson(Map<String, dynamic> json)
      : id = ApiHelper.getValue(map: json, keys: ["id"], value: ""),
        displayName = "${ApiHelper.getValue(map: json, keys: [
              "lastName"
            ], value: "")}, ${ApiHelper.getValue(map: json, keys: ["firstName"], value: "")}";

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [id, displayName];

  Student toModel() => Student(id: id, displayName: displayName);
}

class ParticipantDTO extends Equatable {
  final String id;
  final String type;
  final String displayName;

  final List<ParticipantDTO> children;

  ParticipantDTO.fromJson(Map<String, dynamic> json)
      : id = ApiHelper.getValue(map: json, keys: ["id"], value: ""),
        type = ApiHelper.getValue(map: json, keys: ["type"], value: ""),
        displayName = ApiHelper.getValueChain(
            map: json,
            keyChain: [
              ["displayName"],
              ["name"]
            ],
            value: ""),
        children = List<Map<String, dynamic>>.from(
            ApiHelper.getValueChain(map: json, keyChain: [
          ["children"],
          ["students"]
        ], value: [])).map((e) => ParticipantDTO.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "displayName": displayName,
        "children": children
      };

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [id, type, displayName, children];

  Participant toModel() {
    if (type.toLowerCase() == "course") {
      return Course(
          id: id,
          displayName: displayName,
          children: children.map((e) => e.toModel()).toList(growable: false));
    } else {
      return Student(id: id, displayName: displayName);
    }
  }
}
