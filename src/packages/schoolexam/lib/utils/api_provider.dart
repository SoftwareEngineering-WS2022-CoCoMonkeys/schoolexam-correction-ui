import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:schoolexam/configuration.dart';

import 'network_exceptions.dart';

enum HTTPMethod { GET, POST, PATCH, PUT, DELETE }

class ApiProvider {
  Future<http.Response> _httpRequest(
      Uri uri, Map<String, String> headers, HTTPMethod method,
      {Object? body}) async {
    var methodKey = '';
    switch (method) {
      case HTTPMethod.DELETE:
        methodKey = 'DELETE';
        break;
      case HTTPMethod.POST:
        methodKey = 'POST';
        break;
      case HTTPMethod.PATCH:
        methodKey = 'PATCH';
        break;
      case HTTPMethod.PUT:
        methodKey = 'PUT';
        break;
      default:
        methodKey = 'GET';
        break;
    }

    // REQUEST AND INCLUDE BODY
    if (body != null) headers["Content-Type"] = "application/json";

    final client = http.Client();
    try {
      final response = (body != null)
          ? await client.send(http.Request(methodKey, uri)
            ..headers.addAll(headers)
            ..body = jsonEncode(body))
          : await client
              .send(http.Request(methodKey, uri)..headers.addAll(headers));

      final result = await http.Response.fromStream(response);
      return result;
    } on SocketException catch (e) {
      throw ConnectionException(e.toString());
    } finally {
      client.close();
    }
  }

  Future<dynamic> query(
      {required String path,
      Map<String, String>? headers,
      HTTPMethod method = HTTPMethod.GET,
      Object? body,
      String? key}) async {
    //Default headers
    if (headers == null) headers = {};
    headers["Accept"] = "application/json";

    if (key != null) headers["Authorization"] = "Bearer $key";

    final base = (await Configuration.get())["Connection"]["Uri"];
    final url = Uri.https(base, path);

    var response = (body != null)
        ? await _httpRequest(url, headers, method, body: body)
        : await _httpRequest(url, headers, method);

    print(response.statusCode);
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
