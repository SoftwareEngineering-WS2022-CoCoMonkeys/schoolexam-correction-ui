import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/participant_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/utils/api_helper.dart';

class SubmissionDTO extends Equatable {
  final String status;
  final double achievedPoints;

  final String id;
  final ParticipantDTO student;
  final String updatedAt;
  final bool isCompleted;
  final bool isMatchedToStudent;

  SubmissionDTO(
      {required this.id,
      required this.student,
      required this.status,
      required this.achievedPoints,
      required this.updatedAt,
      required this.isCompleted,
      required this.isMatchedToStudent});

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'student': this.student,
      'status': this.status,
      'achievedPoints': this.achievedPoints,
      'updatedAt': this.updatedAt,
      'isCompleted': this.isCompleted,
      'isMatchedToStudent': this.isMatchedToStudent,
    };
  }

  factory SubmissionDTO.fromJson(Map<String, dynamic> map) {
    return SubmissionDTO(
      id: ApiHelper.getValue(map: map, keys: ["id"], value: ""),
      student: ParticipantDTO.fromJson(
          ApiHelper.getValue(map: map, keys: ["student"], value: {})),
      status: ApiHelper.getValue(map: map, keys: ["status"], value: ""),
      achievedPoints:
          ApiHelper.getValue(map: map, keys: ["achievedPoints"], value: 0.0),
      updatedAt: ApiHelper.getValue(map: map, keys: ["updatedAt"], value: ""),
      isCompleted:
          ApiHelper.getValue(map: map, keys: ["isCompleted"], value: false),
      isMatchedToStudent: ApiHelper.getValue(
          map: map, keys: ["isMatchedToStudent"], value: false),
    );
  }

  SubmissionOverview toModel({required Exam exam}) => SubmissionOverview(
      id: id,
      exam: exam,
      student: (student.toModel() is Student)
          ? student.toModel() as Student
          : Student.empty,
      isCompleted: isCompleted,
      isMatchedToStudent: isMatchedToStudent,
      updatedAt: DateTime.parse(updatedAt),
      achievedPoints: achievedPoints,
      status: CorrectableStatus.values.firstWhere(
          (element) => element.name == status,
          orElse: () => CorrectableStatus.unknown));

  @override
  List<Object?> get props => [
        id,
        student,
        status,
        achievedPoints,
        updatedAt,
        isCompleted,
        isMatchedToStudent
      ];
}
