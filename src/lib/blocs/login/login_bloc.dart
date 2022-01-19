import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam/schoolexam.dart';
import 'package:schoolexam/utils/network_exceptions.dart';
import 'package:schoolexam_correction_ui/blocs/language/language.dart';
import 'package:schoolexam_correction_ui/blocs/login/login_error_extensions.dart';
import 'package:schoolexam_correction_ui/blocs/login/login_form.dart';
import 'package:schoolexam_correction_ui/models/password.dart';
import 'package:schoolexam_correction_ui/models/username.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LanguageCubit _languageCubit;
  final AuthenticationRepository _authenticationRepository;

  LoginBloc(
      {required AuthenticationRepository authenticationRepository,
      required LanguageCubit languageCubit})
      : _authenticationRepository = authenticationRepository,
        _languageCubit = languageCubit,
        super(const LoginState.initial()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    final username = Username.dirty(value: event.username);
    emit(state.copyWith(
        username: username,
        status:
            LoginForm(username: username, password: state.password).status));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(value: event.password);
    emit(state.copyWith(
        password: password,
        status:
            LoginForm(password: password, username: state.username).status));
  }

  void _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.status.isValidated) {
      log("Error during login, the form was not validated.");
      return;
    }

    emit(state.copyWith(status: FormzStatus.submissionInProgress));

    try {
      await _authenticationRepository.logIn(
        username: state.username.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on NetworkException catch (e) {
      emit(LoginSubmissionFailure(
          initial: state, description: e.getDescription(_languageCubit)));
    }
  }
}
