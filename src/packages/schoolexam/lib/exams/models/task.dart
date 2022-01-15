import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final double maxPoints;

  const Task({required this.id, required this.title, required this.maxPoints});

  static const empty = const Task(id: "", title: "", maxPoints: 0.0);

  bool get isEmpty => this == Task.empty;
  bool get isNotEmpty => this != Task.empty;

  @override
  String toString() {
    return "($id) $title : $maxPoints";
  }

  @override
  List<Object?> get props => [id, title, maxPoints];
}
