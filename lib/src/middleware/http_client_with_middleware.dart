import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:pretty_http_logger/src/middleware/http_methods.dart';
import 'package:pretty_http_logger/src/middleware/middleware_contract.dart';
import 'package:pretty_http_logger/src/middleware/models/request_data.dart';
import 'package:pretty_http_logger/src/middleware/models/response_data.dart';

///Class to be used by the user to set up a new `http.Client` with middleware supported.
///call the `build()` constructor passing in the list of middlewares.
///Example:
///```dart
/// HttpClientWithMiddleware httpClient = HttpClientWithMiddleware.build(middlewares: [
///     Logger(),
/// ]);
///```
///
///Then call the functions you want to, on the created `http` object.
///```dart
/// httpClient.get(...);
/// httpClient.post(...);
/// httpClient.put(...);
/// httpClient.delete(...);
/// httpClient.head(...);
/// httpClient.patch(...);
/// httpClient.read(...);
/// httpClient.readBytes(...);
/// httpClient.send(...);
/// httpClient.close();
///```
///Don't forget to close the client once you are done, as a client keeps
///the connection alive with the server.
class HttpClientWithMiddleware extends http.BaseClient {
  List<MiddlewareContract>? middlewares;
  Duration? requestTimeout;

  // final IOClient _client = IOClient();
  static final Client _client = Client();

  HttpClientWithMiddleware._internal(
      {this.middlewares = const [],
      this.requestTimeout = const Duration(seconds: 10)});

  factory HttpClientWithMiddleware.build({
    List<MiddlewareContract>? middlewares,
    Duration? requestTimeout,
  }) {
    //Remove any value that is null.
    // middlewares?.removeWhere((middleware) => middleware == null);
    return HttpClientWithMiddleware._internal(
      middlewares: middlewares,
      requestTimeout: requestTimeout,
    );
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      _sendUnstreamed('HEAD', url, headers);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      _sendUnstreamed('GET', url, headers);

  @override
  Future<Response> post(Uri url,
          {Map<String, String>? headers, body, Encoding? encoding}) =>
      _sendUnstreamed('POST', url, headers, body, encoding);

  @override
  Future<Response> put(Uri url,
          {Map<String, String>? headers, body, Encoding? encoding}) =>
      _sendUnstreamed('PUT', url, headers, body, encoding);

  @override
  Future<Response> patch(Uri url,
          {Map<String, String>? headers, body, Encoding? encoding}) =>
      _sendUnstreamed('PATCH', url, headers, body, encoding);

  @override
  Future<Response> delete(Uri url,
          {Map<String, String>? headers, body, Encoding? encoding}) =>
      _sendUnstreamed('DELETE', url, headers);

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.body;
    });
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.bodyBytes;
    });
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) => _client.send(request);

  Future<Response> _sendUnstreamed(
      String method, url, Map<String, String>? headers,
      [dynamic body, Encoding? encoding]) async {
    if (url is String) url = Uri.parse(url);
    var request = Request(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }

    //Send interception
    middlewares?.forEach(
      (middleware) => middleware.interceptRequest(
        RequestData(
          method: methodFromString(method),
          encoding: encoding,
          body: body,
          url: url,
          headers: headers ?? <String, String>{},
        ),
      ),
    );

    var stream = requestTimeout == null
        ? await send(request)
        : await send(request).timeout(requestTimeout!);

    return Response.fromStream(stream).then((response) {
      var responseData = ResponseData.fromHttpResponse(response);

      middlewares
          ?.forEach((middleware) => middleware.interceptResponse(responseData));

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

      return resultResponse;
    }).catchError((err) {
      middlewares?.forEach((middleware) => middleware.interceptError(err));
    });
  }

  void _checkResponseSuccess(url, Response response) {
    if (response.statusCode < 400) return;
    var message = 'Request to $url failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      message = '$message: ${response.reasonPhrase}';
    }
    if (url is String) url = Uri.parse(url);
    throw ClientException('$message.', url);
  }

  @override
  void close() {
    _client.close();
  }
}
