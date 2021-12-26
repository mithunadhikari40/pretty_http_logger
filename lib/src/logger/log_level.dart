///The level of logs you want on the console
/// Log level of NONE will not log anything on the console
///```dart
///HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     HttpLogger(logLevel: LogLevel.NONE),
/// ]);
/// ```

/// Log level of BASIC will print only the basic info to console such as Method Type, Request URL and Request Body.
/// In case of Response it will print only status code and content-length
///```dart
///HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     HttpLogger(logLevel: LogLevel.BASIC),
/// ]);
/// ```

/// ```
/// Log level of HEADERS will print only the headers info to console
///```dart
///HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     HttpLogger(logLevel: LogLevel.HEADERS),
/// ]);
/// ```

/// Log level of BODY will print everything. For e.g. it will print Method Name, Request URL, Request Headers and Request Body.
/// In case of Response it will print Method Name, Request URL, Response Headers and Response Body.
///```dart
///HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     HttpLogger(logLevel: LogLevel.BODY),
/// ]);
/// ```
enum LogLevel {
  NONE,
  BASIC,
  HEADERS,
  BODY,
}
