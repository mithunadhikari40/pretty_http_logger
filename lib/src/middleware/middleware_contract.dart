import 'package:pretty_http_logger/src/middleware/models/request_data.dart';
import 'package:pretty_http_logger/src/middleware/models/response_data.dart';

///Middleware interface to create custom middleware for http.
///Extend this class and override the functions that you want
///to intercept.
///
///Intercepting: You have to implement three functions, `interceptRequest`,
///`interceptResponse` and `interceptError`.
///
///Example (Simple logging):
///
///```dart
///class CustomMiddleWare extends MiddlewareContract {
///    @override
///    Function(http.Response) interceptRequest(RequestData data) {
///        print("${data.method} Url: ${data.url}")
///        return (response) {
///            print("POST Status: ${}")
///        };
///    }
///
///    @override
///    Function(http.Response) interceptResponse(ResponseData data) {
///        print("${data.method}: ${response}")
///        return (response) {
///            print("POST Status: ${}")
///        };
///    }
///}

///    @override
///    Function(http.Response) interceptError(error) {
///        print("$err")
///}
///```
abstract class MiddlewareContract {
  void interceptRequest(RequestData data);

  void interceptResponse(ResponseData data);

  void interceptError(dynamic error);
}
