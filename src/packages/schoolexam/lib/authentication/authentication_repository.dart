import 'dart:async';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final StreamController<AuthenticationStatus> _controller;

  AuthenticationRepository()
      : _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    // TODO : Authenticated
    yield AuthenticationStatus.authenticated;
    yield* _controller.stream;
  }

  Future<void> logIn(
      {required String username, required String password}) async {
    // TODO : Add authentication against our School Exam repository
    // TODO : Add persistence of authenticated user
    _controller.add(AuthenticationStatus.authenticated);
  }

  void logOut() {
    // TODO : Maybe terminate session with School Exam
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() {
    _controller.close();
  }
}
