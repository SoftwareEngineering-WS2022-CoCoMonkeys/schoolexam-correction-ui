import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam/schoolexam.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);

    // Convert change within authentication repository to event within bloc
    _authenticationStatusSubscription = _authenticationRepository.status
        .listen((event) => add(AuthenticationStatusChanged(event)));
  }

  void _onAuthenticationStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        return emit(const AuthenticationState.unauthenticated());
      case AuthenticationStatus.authenticated:
        final user = await _authenticationRepository.getAccount();
        return emit((user.isEmpty)
            ? const AuthenticationState.unauthenticated()
            : AuthenticationState.authenticated(user));
      default:
        return emit(const AuthenticationState.unknown());
    }
  }

  void _onAuthenticationLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    _authenticationRepository.logOut();
  }

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    return super.close();
  }
}
