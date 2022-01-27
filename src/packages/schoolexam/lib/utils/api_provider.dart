import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:schoolexam/configuration.dart';

import 'network_exceptions.dart';

enum HTTPMethod { get, post, patch, put, delete }

class ApiProvider {
  final Client client;

  ApiProvider({Client? client}) : client = client ?? http.Client();

  Future<http.Response> _httpRequest(
      Uri uri, Map<String, String> headers, HTTPMethod method,
      {Object? body}) async {
    // REQUEST AND INCLUDE BODY
    if (body != null) headers["Content-Type"] = "application/json";

    try {
      switch (method) {
        case HTTPMethod.delete:
          return await client.delete(uri,
              headers: headers, body: (body != null) ? jsonEncode(body) : null);
        case HTTPMethod.post:
          return await client.post(uri,
              headers: headers, body: (body != null) ? jsonEncode(body) : null);
        case HTTPMethod.patch:
          return await client.patch(uri,
              headers: headers, body: (body != null) ? jsonEncode(body) : null);
        case HTTPMethod.put:
          return await client.put(uri,
              headers: headers, body: (body != null) ? jsonEncode(body) : null);
        default:
          return await client.get(uri, headers: headers);
      }
    } on SocketException catch (e) {
      throw ConnectionException(e.toString());
    }
  }

  Future<dynamic> query(
      {required String path,
      Map<String, String>? headers,
      HTTPMethod method = HTTPMethod.get,
      Object? body,
      String? key}) async {
    //Default headers
    headers ??= {};
    headers["Accept"] = "application/json";

    if (key != null) headers["Authorization"] = "Bearer $key";

    final base = (await Configuration.get())["Connection"]["Uri"];
    final url = Uri.https(base, path);

    var response = (body != null)
        ? await _httpRequest(url, headers, method, body: body)
        : await _httpRequest(url, headers, method);

    switch (response.statusCode) {
      case 200:
      case 201:
        return (response.body.isEmpty) ? "" : json.decode(response.body);
      case 204:
        return "";
      case 400:
        throw BadRequestException(response);
      case 401:
        throw UnauthorisedException(response);
      case 403:
        throw ForbiddenException(response);
      case 404:
        throw NotFoundException(response);
      case 405:
        throw MethodNotAllowedException(response);
      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
      case 505:
      case 506:
      case 507:
      case 508:
      case 509:
      case 510:
      case 511:
        throw InternalServerException(response);
      default:
        throw Exception("Could not access web resource.");
    }
  }
}
