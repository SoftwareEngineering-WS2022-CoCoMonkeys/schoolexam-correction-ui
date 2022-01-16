import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String firstName;
  final String lastName;
  final String emailAddress;

  const Person(
      {required this.firstName,
      required this.lastName,
      required this.emailAddress});

  @override
  List<Object?> get props => [firstName, lastName, emailAddress];

  static const empty = Person(firstName: "", lastName: "", emailAddress: "");

  bool get isEmpty => this == Person.empty;

  bool get isNotEmpty => this != Person.empty;
}
