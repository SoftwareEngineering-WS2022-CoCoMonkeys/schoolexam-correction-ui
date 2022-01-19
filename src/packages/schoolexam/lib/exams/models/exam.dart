import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/grading_table.dart';
import 'package:schoolexam/exams/models/participant.dart';

import 'student.dart';
import 'task.dart';

enum ExamStatus {
  unknown,
  planned,
  buildReady,
  submissionReady,
  inCorrection,
  corrected,
  published
}

class Exam extends Equatable {
  final String id;
  final ExamStatus status;
  final String title;

  /// Date when exam was written by all students
  final DateTime dateOfExam;

  /// Final date for the completion of the correction
  final DateTime? dueDate;

  final String topic;

  /// The percentage of the exam that is already corrected
  final double quota;

  /// The list of participants
  final List<Participant> participants;

  /// All the tasks associated with this exam
  final List<Task> tasks;

  /// The grading table associated with this exam
  final GradingTable gradingTable;

  @override
  List<Object?> get props => [
        id,
        status,
        title,
        dateOfExam,
        dueDate,
        topic,
        quota,
        participants,
        tasks,
        gradingTable
      ];

  const Exam(
      {required this.id,
      required this.status,
      required this.title,
      required this.dateOfExam,
      this.dueDate,
      required this.topic,
      required this.quota,
      required this.participants,
      required this.tasks,
      required this.gradingTable});

  static final empty = Exam(
      id: "",
      status: ExamStatus.unknown,
      title: "",
      topic: "",
      quota: 0,
      dateOfExam: DateTime.now(),
      participants: [],
      tasks: [],
      gradingTable: GradingTable.empty);

  bool get isEmpty => this == Exam.empty;

  bool get isNotEmpty => this != Exam.empty;

  /// Returns all participants of an exam
  List<Student> getParticipants() =>
      participants.map((e) => e.getParticipants()).fold<Set<Student>>(
          {}, (prev, element) => prev..addAll(element)).toList(growable: false);

  Exam copyWith({
    String? id,
    ExamStatus? status,
    String? title,
    DateTime? dateOfExam,
    DateTime? dueDate,
    String? topic,
    double? quota,
    List<Participant>? participants,
    List<Task>? tasks,
    GradingTable? gradingTable,
  }) {
    return Exam(
      id: id ?? this.id,
      status: status ?? this.status,
      title: title ?? this.title,
      dateOfExam: dateOfExam ?? this.dateOfExam,
      dueDate: dueDate ?? this.dueDate,
      topic: topic ?? this.topic,
      quota: quota ?? this.quota,
      participants: participants ?? this.participants,
      tasks: tasks ?? this.tasks,
      gradingTable: gradingTable ?? this.gradingTable,
    );
  }
}
