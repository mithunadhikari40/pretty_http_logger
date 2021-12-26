import 'dart:convert';

import 'package:pretty_http_logger/src/middleware/http_methods.dart';

///Request object, internally used by the library.
///The network request app makes is broken down into pieces to be used by the library.

///You can also modify the `RequestData` before the request is made For Example, if you want to wrap your data in a particular structure before sending, or you want every request header to have `Content-Type` set to `application/json`.

///```dart
///class Logger extends MiddlewareContract {
///   @override
///   void interceptRequest(RequestData data) {
///   //Adding content type to every request
///     data.headers["Content-Type"] = "application/json";
///
///     data.body = jsonEncode({
///       uniqueId: "some unique id",
///       data: data.body,
///     });
///   }
///   @override
///   void interceptResponse(ResponseData data) {
///   }
///   @override
///   void interceptError(err) {
///   }
/// }
/// ```
class RequestData {
  Method method;
  Uri url;
  Map<String, String>? headers;
  dynamic body;
  Encoding? encoding;

  RequestData({
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.encoding,
  });
}
