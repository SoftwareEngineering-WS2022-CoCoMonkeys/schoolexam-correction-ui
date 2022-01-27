import 'package:http/http.dart';

abstract class NetworkException implements Exception {
  const NetworkException();
}

class ConnectionException extends NetworkException {
  final String message;
  const ConnectionException(this.message);

  @override
  String toString() => 'Fehler beim Aufbau der Verbindung : $message';
}

// -- 4xx

abstract class ClientException extends NetworkException {
  final Response response;
  const ClientException(this.response);
}

// 400
class BadRequestException extends ClientException {
  BadRequestException(response) : super(response);
}

// 401
class UnauthorisedException extends ClientException {
  UnauthorisedException(response) : super(response);
}

// 403
class ForbiddenException extends ClientException {
  ForbiddenException(response) : super(response);
}

// 404
class NotFoundException extends ClientException {
  NotFoundException(response) : super(response);
}

// 405
class MethodNotAllowedException extends ClientException {
  MethodNotAllowedException(response) : super(response);
}

// -- 5xx

abstract class ServerException extends NetworkException {
  final Response response;
  ServerException(this.response);
}

// 500
class InternalServerException extends ServerException {
  InternalServerException(response) : super(response);
}
