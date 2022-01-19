import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/person.dart';
import 'package:schoolexam/utils/api_helper.dart';

class PersonDTO extends Equatable {
  final String firstName;
  final String lastName;
  final String emailAddress;

  const PersonDTO(
      {required this.firstName,
      required this.lastName,
      required this.emailAddress});

  Person toModel() => Person(
      firstName: firstName, lastName: lastName, emailAddress: emailAddress);

  Map<String, dynamic> toJson() {
    return {
      'firstName': this.firstName,
      'lastName': this.lastName,
      'emailAddress': this.emailAddress,
    };
  }

  factory PersonDTO.fromJson(Map<String, dynamic> map) {
    return PersonDTO(
      firstName: ApiHelper.getValue(map: map, keys: ["firstName"], value: ""),
      lastName: ApiHelper.getValue(map: map, keys: ["lastName"], value: ""),
      emailAddress:
          ApiHelper.getValue(map: map, keys: ["emailAddress"], value: ""),
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, emailAddress];

  PersonDTO copyWith({
    String? firstName,
    String? lastName,
    String? emailAddress,
  }) {
    return PersonDTO(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      emailAddress: emailAddress ?? this.emailAddress,
    );
  }
}
