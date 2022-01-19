import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/participant_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam/utils/api_helper.dart';

import 'answer_dto.dart';

class SubmissionDetailsDTO extends Equatable {
  final String updatedAt;
  final String status;
  final double achievedPoints;

  final String id;
  final ParticipantDTO student;
  final bool isComplete;
  final bool isMatchedToStudent;

  // details
  final String data;
  final List<AnswerDTO> answers;

  SubmissionDetailsDTO(
      {required this.id,
      required this.student,
      required this.status,
      required this.achievedPoints,
      required this.updatedAt,
      required this.isComplete,
      required this.isMatchedToStudent,
      required this.data,
      required this.answers});

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'student': this.student,
      'status': this.status,
      'achievedPoints': this.achievedPoints,
      'updatedAt': this.updatedAt,
      'isComplete': this.isComplete,
      'isMatchedToStudent': this.isMatchedToStudent,
      'data': this.data,
      'answers': this.answers.map((e) => e.toJson()).toList()
    };
  }

  factory SubmissionDetailsDTO.fromJson(Map<String, dynamic> map) {
    return SubmissionDetailsDTO(
      data: ApiHelper.getValue(map: map, keys: ["data"], value: ""),
      answers: List<Map<String, dynamic>>.from(
              ApiHelper.getValue(map: map, keys: ["answers"], value: []))
          .map((e) => AnswerDTO.fromJson(e))
          .toList(),
      id: ApiHelper.getValue(map: map, keys: ["id"], value: ""),
      student: ParticipantDTO.fromJson(
          ApiHelper.getValue(map: map, keys: ["student"], value: {})),
      status: ApiHelper.getValue(map: map, keys: ["status"], value: ""),
      achievedPoints:
          ApiHelper.getValue(map: map, keys: ["achievedPoints"], value: 0.0),
      updatedAt: ApiHelper.getValue(map: map, keys: ["updatedAt"], value: ""),
      isComplete:
          ApiHelper.getValue(map: map, keys: ["isComplete"], value: false),
      isMatchedToStudent: ApiHelper.getValue(
          map: map, keys: ["isMatchedToStudent"], value: false),
    );
  }

  Submission toModel({required Exam exam}) => Submission(
      id: id,
      exam: exam,
      student: (student.toModel() is Student)
          ? student.toModel() as Student
          : Student.empty,
      data: data,
      answers: answers.map((e) => e.toModel()).toList(),
      isComplete: isComplete,
      isMatchedToStudent: isMatchedToStudent,
      updatedAt: DateTime.parse(updatedAt).toUtc(),
      achievedPoints: achievedPoints,
      status: CorrectableStatus.values.firstWhere(
          (element) => element.name.toLowerCase() == status.toLowerCase(),
          orElse: () => CorrectableStatus.unknown));

  @override
  List<Object?> get props => [
        id,
        student,
        status,
        achievedPoints,
        updatedAt,
        isComplete,
        isMatchedToStudent,
        data,
        answers
      ];
}
