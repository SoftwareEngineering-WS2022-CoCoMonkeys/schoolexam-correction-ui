import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:schoolexam/exams/dto/authentication_dto.dart';
import 'package:schoolexam/exams/models/authentication.dart';
import 'package:schoolexam/exams/models/person.dart';
import 'package:schoolexam/utils/api_provider.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final ApiProvider _provider;
  final StreamController<AuthenticationStatus> _controller;

  // Create storage
  final FlutterSecureStorage _storage;
  Authentication _authentication;

  static const _storageUserKey = "authentication_repository:user:key";
  static const _storagePasswordKey = "authentication_repository:password:key";

  AuthenticationRepository()
      : _controller = StreamController<AuthenticationStatus>(),
        _provider = ApiProvider(),
        _storage = const FlutterSecureStorage(),
        _authentication = Authentication.empty;

  // Why the initial state should never change from unauthenticated :
  // This app provides access to sensitive data.
  // Some form of authentication is always going to be required.
  // A way of improving the usage could be the inclusion of TouchID to use the currently stored credentials.
  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<String> _getTokenUsingStoredCredentials() async {
    if (await _storage.containsKey(key: _storagePasswordKey)) {
      return (await _getAuthenticationFromLogin(
              username: (await _storage.read(key: _storageUserKey))!,
              password: (await _storage.read(key: _storagePasswordKey))!))
          .token;
    } else {
      return "";
    }
  }

  Future<Authentication> _getAuthenticationFromLogin(
      {required String username, required String password}) async {
    final response = await _provider.query(
        path: "/authentication/authenticate",
        body: {"username": username, "password": password},
        method: HTTPMethod.post);

    _authentication = AuthenticationDTO.fromJson(response).toModel();

    // Update
    _storage.write(key: _storageUserKey, value: username);
    _storage.write(key: _storagePasswordKey, value: password);

    return _authentication;
  }

  Future<Person> getAccount() async => _authentication.user.person;

  Future<void> logIn(
      {required String username, required String password}) async {
    await _getAuthenticationFromLogin(username: username, password: password);
    _controller.add(AuthenticationStatus.authenticated);
  }

  Future<String> getKey() async {
    if (_authentication.isNotEmpty) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(
          (JwtDecoder.decode(_authentication.token))["exp"] * 1000);
      if (expiry.difference(DateTime.now()).inMinutes >= 5) {
        return _authentication.token;
      }
    }

    return _getTokenUsingStoredCredentials();
  }

  Future<void> logOut() async {
    // TODO : Maybe terminate session with School Exam
    await _storage.delete(key: _storageUserKey);
    await _storage.delete(key: _storagePasswordKey);
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() {
    _controller.close();
  }
}
