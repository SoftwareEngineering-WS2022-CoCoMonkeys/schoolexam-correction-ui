import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/user_dto.dart';
import 'package:schoolexam/exams/models/user.dart';
import 'package:schoolexam/utils/api_helper.dart';

class Authentication extends Equatable {
  final String token;
  final User user;

  const Authentication({required this.token, required this.user});

  @override
  List<Object?> get props => [token, user];

  static const empty = Authentication(token: "", user: User.empty);

  bool get isEmpty => this == Authentication.empty;
  bool get isNotEmpty => this != Authentication.empty;
}
