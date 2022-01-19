import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';
import 'package:schoolexam_correction_ui/models/password.dart';
import 'package:schoolexam_correction_ui/models/username.dart';

class LoginState extends Equatable {
  final FormzStatus status;
  final Username username;
  final Password password;

  const LoginState._({
    this.status = FormzStatus.pure,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
  });

  const LoginState.initial() : this._();

  LoginState copyWith({
    FormzStatus? status,
    Username? username,
    Password? password,
  }) {
    return LoginState._(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [status, username, password];
}

/// An error arose during the submission of the login form.
/// The [LoginBloc] is responsible for providing detailed information about the reasoning.
class LoginSubmissionFailure extends LoginState implements BlocFailure {
  @override
  final String description;

  @override
  final Exception? exception;

  /// The [description] provides the user with the localized information about the reasoning of the failure.
  /// This may indicate a failure in the provided credentials or a temporary server error.
  LoginSubmissionFailure(
      {required LoginState initial, required this.description, this.exception})
      : super._(
            status: FormzStatus.submissionFailure,
            username: initial.username,
            password: initial.password);

  @override
  List<Object?> get props => super.props..addAll([description, exception]);
}
