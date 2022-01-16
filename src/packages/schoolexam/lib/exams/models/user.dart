import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/person.dart';

class User extends Equatable {
  final String username;
  final String role;
  final Person person;

  const User(
      {required this.username, required this.role, required this.person});

  @override
  List<Object?> get props => [username, role, person];

  static const empty = User(username: "", role: "", person: Person.empty);

  bool get isEmpty => this == User.empty;

  bool get isNotEmpty => this != User.empty;
}
