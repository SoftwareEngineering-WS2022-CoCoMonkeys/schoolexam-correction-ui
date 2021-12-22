import 'package:formz/formz.dart';
import 'package:schoolexam_correction_ui/models/password.dart';
import 'package:schoolexam_correction_ui/models/username.dart';

class LoginForm with FormzMixin {
  final Username username;
  final Password password;

  LoginForm({required this.username, required this.password});

  @override
  List<FormzInput> get inputs => [username, password];
}
