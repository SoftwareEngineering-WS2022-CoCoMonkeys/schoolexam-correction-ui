/// A participant is tasked with solving the exams supplied by the teacher
abstract class Participant {
  final String id;
  final String displayName;

  /// Determines a complete list of participants contained within this participant.
  List<Participant> getParticipants();

  const Participant({required this.id, required this.displayName});
}
