import 'package:schoolexam/exams/exams.dart';

abstract class ParticipantData {
  final String id;
  final String displayName;

  const ParticipantData({required this.id, required this.displayName});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {'id': id, 'displayName': displayName};
  }

  /// Converts this data object to a participant model, using the list of [children] for its structure.
  Participant toModel(List<CourseChildren> children) {
    if (this is StudentData) {
      return Student(id: id, displayName: displayName);
    } else {
      return Course(
          id: id,
          displayName: displayName,
          children: children
              .where((e) => e.courseId == id)
              .map((e) => e.participant.toModel(children))
              .toList());
    }
  }
}

class StudentData extends ParticipantData {
  const StudentData({required String id, required String displayName})
      : super(id: id, displayName: displayName);

  static StudentData fromMap(Map<String, dynamic> data) {
    return StudentData(id: data["id"], displayName: data["displayName"]);
  }

  static StudentData fromModel(Student model) =>
      StudentData(id: model.id, displayName: model.displayName);
}

class CourseData extends ParticipantData {
  const CourseData({required String id, required String displayName})
      : super(id: id, displayName: displayName);

  static CourseData fromMap(Map<String, dynamic> data) {
    return CourseData(id: data["id"], displayName: data["displayName"]);
  }

  static CourseData fromModel(Course model) =>
      CourseData(id: model.id, displayName: model.displayName);
}

class CourseChildren {
  final String courseId;
  final ParticipantData participant;

  CourseChildren({required this.courseId, required this.participant});
}
