import 'participant.dart';
import 'student.dart';

/// Defines a course within the school. This course is allowed to be a participant of an exam and is in turn made up of further participants.
/// While the most common case is going to be the inclusion of students, nesting courses is a possibility.
/// However, allowing this nesting structure requires server-side validation of acyclic graphs.
class Course extends Participant {
  final List<Participant> children;

  @override
  List<Student> getParticipants() =>
      children.map((e) => e.getParticipants()).fold<List<Student>>(
          [], (prev, element) => prev..addAll(element)).toList(growable: false);

  const Course(
      {required String id, required String displayName, required this.children})
      : super(id: id, displayName: displayName);

  static const empty = Course(id: "", displayName: "", children: []);

  bool get isEmpty => this == Course.empty;

  bool get isNotEmpty => this != Course.empty;
}
