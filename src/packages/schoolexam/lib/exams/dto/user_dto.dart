import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/person_dto.dart';
import 'package:schoolexam/exams/models/user.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam/utils/api_helper.dart';

class UserDTO extends Equatable {
  final String username;
  final String role;
  final PersonDTO person;

  const UserDTO(
      {required this.username, required this.role, required this.person});

  User toModel() =>
      User(username: username, role: role, person: person.toModel());

  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'role': this.role,
      'person': this.person.toMap(),
    };
  }

  factory UserDTO.fromMap(Map<String, dynamic> map) {
    return UserDTO(
        username: ApiHelper.getValue(map: map, keys: ["username"], value: ""),
        role: ApiHelper.getValue(map: map, keys: ["role"], value: ""),
        person: PersonDTO.fromMap(
            ApiHelper.getValue(map: map, keys: ["person"], value: {})));
  }

  UserDTO copyWith({
    String? username,
    String? role,
    PersonDTO? person,
  }) {
    return UserDTO(
      username: username ?? this.username,
      role: role ?? this.role,
      person: person ?? this.person,
    );
  }

  @override
  List<Object?> get props => [username, role, person];
}
