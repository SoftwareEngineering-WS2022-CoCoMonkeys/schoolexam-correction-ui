import 'participant.dart';

class Student extends Participant {
  @override
  List<Student> getParticipants() => [this];

  const Student({required String id, required String displayName})
      : super(id: id, displayName: displayName);

  static const empty = const Student(id: "", displayName: "");

  bool get isEmpty => this == Student.empty;

  bool get isNotEmpty => this != Student.empty;
}
