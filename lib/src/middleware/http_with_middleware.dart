import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:pretty_http_logger/src/middleware/http_methods.dart';
import 'package:pretty_http_logger/src/middleware/middleware_contract.dart';
import 'package:pretty_http_logger/src/middleware/models/request_data.dart';
import 'package:pretty_http_logger/src/middleware/models/response_data.dart';

///Class to be used by the user as a replacement for 'http' with middleware supported.
///call the `build()` constructor passing in the list of middlewares.
///Example:
///```dart
/// HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     Logger(),
/// ]);
///```
///Then call the functions you want to, on the created `http` object.
///```dart
/// http.get(...);
/// http.post(...);
/// http.put(...);
/// http.delete(...);
/// http.head(...);
/// http.patch(...);
/// http.read(...);
/// http.readBytes(...);
///```
class HttpWithMiddleware {
  List<MiddlewareContract>? middlewares;
  Duration? requestTimeout;

  HttpWithMiddleware._internal({
    this.middlewares = const [],
    this.requestTimeout = const Duration(seconds: 10),
  });

  factory HttpWithMiddleware.build({
    List<MiddlewareContract>? middlewares,
    Duration? requestTimeout,
  }) {
    //Remove any value that is null.
    // middlewares?.removeWhere((middleware) => middleware == null);
    return HttpWithMiddleware._internal(
        middlewares: middlewares, requestTimeout: requestTimeout);
  }

  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    _sendInterception(method: Method.HEAD, headers: headers, url: url);
    return _withClient((client) => client.head(url, headers: headers));
  }

  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    var data =
        _sendInterception(method: Method.GET, headers: headers, url: url);
    return _withClient((client) => client.get(data.url, headers: data.headers));
  }

  Future<Response> post(Uri url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) {
    var data = _sendInterception(
        method: Method.POST,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.post(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> put(Uri url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) {
    var data = _sendInterception(
        method: Method.PUT,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.put(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> patch(Uri url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) {
    var data = _sendInterception(
        method: Method.PATCH,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.patch(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> delete(Uri url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) {
    var data = _sendInterception(
        method: Method.DELETE,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.delete(data.url,
        headers: data.headers, body: body, encoding: encoding));
  }

  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return _withClient((client) => client.read(url, headers: headers));
  }

  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      _withClient((client) => client.readBytes(url, headers: headers));

  RequestData _sendInterception(
      {required Method method,
      Encoding? encoding,
      dynamic body,
      required Uri url,
      Map<String, String>? headers}) {
    var data = RequestData(
        method: method,
        encoding: encoding,
        body: body,
        url: url,
        headers: headers ?? <String, String>{});
    middlewares?.forEach((middleware) => middleware.interceptRequest(data));
    return data;
  }

  Future<T> _withClient<T>(Future<T> Function(Client client) fn) async {
    var client = Client();
    try {
      var response = requestTimeout == null
          ? await fn(client).catchError((err) {
              middlewares
                  ?.forEach((middleware) => middleware.interceptError(err));
            })
          : await fn(client).timeout(requestTimeout!).catchError((err) {
              middlewares
                  ?.forEach((middleware) => middleware.interceptError(err));
            });
      if (response is Response) {
        var responseData = ResponseData.fromHttpResponse(response);
        middlewares?.forEach(
            (middleware) => middleware.interceptResponse(responseData));

        var resultResponse = Response(
          responseData.body,
          responseData.statusCode,
          headers: responseData.headers ?? {},
          persistentConnection: responseData.persistentConnection ?? false,
          isRedirect: responseData.isRedirect ?? false,
          request: Request(
            responseData.method.toString().substring(7),
            Uri.parse(responseData.url),
          ),
        );

        return resultResponse as T;
      }
      return response;
    } finally {
      client.close();
    }
  }
}
