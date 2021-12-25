import 'package:pretty_http_logger/src/logger/log_level.dart';
import 'package:pretty_http_logger/src/logger/logger.dart';
import 'package:pretty_http_logger/src/middleware/middleware_contract.dart';
import 'package:pretty_http_logger/src/middleware/models/request_data.dart';
import 'package:pretty_http_logger/src/middleware/models/response_data.dart';

class HttpLogger implements MiddlewareContract {
  LogLevel logLevel;
  Logger? logger;

  HttpLogger({
    this.logLevel = LogLevel.BODY,
  }) {
    logger = Logger(logLevel: logLevel);
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
