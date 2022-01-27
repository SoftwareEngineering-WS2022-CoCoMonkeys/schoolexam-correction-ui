import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/user_dto.dart';
import 'package:schoolexam/exams/models/authentication.dart';
import 'package:schoolexam/utils/api_helper.dart';

class AuthenticationDTO extends Equatable {
  final String token;
  final UserDTO user;

  const AuthenticationDTO({required this.token, required this.user});

  Authentication toModel() =>
      Authentication(token: token, user: user.toModel());

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }

  factory AuthenticationDTO.fromJson(Map<String, dynamic> map) {
    return AuthenticationDTO(
      token: ApiHelper.getValue(map: map, keys: ["token"], value: ""),
      user: UserDTO.fromJson(
          ApiHelper.getValue(map: map, keys: ["user"], value: {})),
    );
  }

  @override
  List<Object?> get props => [token, user];
}
