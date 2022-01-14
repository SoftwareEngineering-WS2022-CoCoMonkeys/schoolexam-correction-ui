import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:schoolexam/utils/api_provider.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final ApiProvider _provider;
  final StreamController<AuthenticationStatus> _controller;

  // Create storage
  final FlutterSecureStorage _storage;
  String? _token;

  static const _storage_user_key = "authentication_repository:user:key";
  static const _storage_password_key = "authentication_repository:password:key";

  AuthenticationRepository()
      : _controller = StreamController<AuthenticationStatus>(),
        _provider = ApiProvider(),
        _storage = FlutterSecureStorage();

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unknown;

    try {
      final response = await _getTokenUsingStoredCredentials();
      if (response.isEmpty) {
        yield AuthenticationStatus.unauthenticated;
      }
    } catch (_) {
      yield AuthenticationStatus.unauthenticated;
    }

    yield* _controller.stream;
  }

  Future<String> _getTokenUsingStoredCredentials() async {
    if (await _storage.containsKey(key: _storage_password_key)) {
      return await _getTokenFromLogin(
          username: (await _storage.read(key: _storage_user_key))!,
          password: (await _storage.read(key: _storage_password_key))!);
    } else {
      return "";
    }
  }

  Future<String> _getTokenFromLogin(
      {required String username, required String password}) async {
    final response = await _provider.query(
        path: "/authentication/authenticate",
        body: {"username": username, "password": password},
        method: HTTPMethod.POST);

    // Update
    _storage.write(key: _storage_user_key, value: username);
    _storage.write(key: _storage_password_key, value: password);
    _token = response;

    return response;
  }

  Future<void> logIn(
      {required String username, required String password}) async {
    await _getTokenFromLogin(username: username, password: password);
    _controller.add(AuthenticationStatus.authenticated);

    print(await getKey());
  }

  Future<String> getKey() async {
    if (_token != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(
          (JwtDecoder.decode(_token!))["exp"] * 1000);
      if (expiry.difference(DateTime.now()).inMinutes >= 5) {
        return _token!;
      }
    }

    return _getTokenUsingStoredCredentials();
  }

  void logOut() async {
    await _storage.delete(key: _storage_user_key);
    await _storage.delete(key: _storage_password_key);
    // TODO : Maybe terminate session with School Exam
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() {
    _controller.close();
  }
}
