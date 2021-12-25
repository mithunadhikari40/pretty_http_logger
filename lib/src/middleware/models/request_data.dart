import 'dart:convert';

import 'package:pretty_http_logger/src/middleware/http_methods.dart';

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
