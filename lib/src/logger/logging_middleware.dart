import 'package:pretty_http_logger/src/logger/log_level.dart';
import 'package:pretty_http_logger/src/logger/logger.dart';
import 'package:pretty_http_logger/src/middleware/middleware_contract.dart';
import 'package:pretty_http_logger/src/middleware/models/request_data.dart';
import 'package:pretty_http_logger/src/middleware/models/response_data.dart';

/// A custom Middleware interface for http.
///It extends `MiddlewareContract`` class and override the three functions
///to intercept.
///
///Intercepting: This class implements three functions, `interceptRequest`,
///`interceptResponse` and `interceptError`.
/// The method implemented are used by `Logger` class to log info to console.
/// You can also create your own custom middleware like
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
class HttpLogger implements MiddlewareContract {
  LogLevel logLevel;
  Logger? logger;
  int tabSpaces;

  HttpLogger({
    this.logLevel = LogLevel.BODY,
    this.tabSpaces = 4,
  }) {
    logger = Logger(logLevel: logLevel, tabSpaces: tabSpaces);
  }

  @override
  void interceptRequest(RequestData data) {
    logger!.logRequest(data);
  }

  @override
  void interceptResponse(ResponseData data) {
    logger!.logResponse(data);
  }

  @override
  void interceptError(dynamic error) {
    logger!.logError(error);
  }
}
