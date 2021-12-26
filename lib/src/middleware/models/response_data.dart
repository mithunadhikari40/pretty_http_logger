import 'package:http/http.dart';
import 'package:pretty_http_logger/src/middleware/http_methods.dart';

///Response object, internally used by the library.
///The network request is received it is broken down into pieces to be used by the library.

///You can also modify every `ResponseData` after every response is received. For Example, if you want to only deal with `data` of the response.

///```dart
///class Logger extends MiddlewareContract {
///   @override
///   void interceptRequest(RequestData data) {
//   }
//
///   @override
///   void interceptResponse(ResponseData data) {
///     //Unwrapping response from a structure
///     data.body = jsonDecode(data.body)["data"];
///   }
///   @override
///   void interceptError(err) {
///   }
/// }
/// ```

class ResponseData {
  String url;
  int statusCode;
  Method method;
  Map<String, String>? headers;
  String body;
  List<int>? bodyBytes;
  int? contentLength;
  bool? isRedirect;
  bool? persistentConnection;

  ResponseData({
    required this.method,
    required this.url,
    required this.statusCode,
    this.headers,
    required this.body,
    this.bodyBytes,
    this.contentLength,
    this.isRedirect,
    this.persistentConnection,
  });

  factory ResponseData.fromHttpResponse(Response response) {
    return ResponseData(
      statusCode: response.statusCode,
      headers: response.headers,
      body: response.body,
      bodyBytes: response.bodyBytes,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      url: response.request!.url.toString(),
      method: methodFromString(response.request!.method),
      persistentConnection: response.persistentConnection,
    );
  }
}
