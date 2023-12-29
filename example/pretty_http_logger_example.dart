import 'dart:convert';

import 'package:http/http.dart';
import 'package:pretty_http_logger/src/logger/log_level.dart';
import 'package:pretty_http_logger/src/logger/logging_middleware.dart';
import 'package:pretty_http_logger/src/middleware/http_client_with_middleware.dart';
import 'package:pretty_http_logger/src/middleware/http_with_middleware.dart';

void main() async {
  final res = await baseRequest
      .get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
  jsonDecode(res.body);

  /// *************** Observe the request and response log in the console ***********************
}

class _BaseRequest {
  static final HttpWithMiddleware _httpClient =
      HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY, tabSpaces: 2),
  ]);
  static final HttpClientWithMiddleware _streamedHttpClient =
      HttpClientWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _streamedHttpClient.send(request);
    return response;
  }

  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final response = await _httpClient.patch(url, headers: headers);
    return response;
  }

  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await _httpClient.get(url, headers: headers);
    return response;
  }

  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final response = await _httpClient.put(url, headers: headers);
    return response;
  }

  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final response = await _httpClient.post(url, headers: headers, body: body);
    return response;
  }

  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final response =
        await _httpClient.delete(url, headers: headers, body: body);
    return response;
  }
}

final baseRequest = _BaseRequest();
