import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:pretty_http_logger/src/logger/log_level.dart';
import 'package:pretty_http_logger/src/middleware/http_methods.dart';
import 'package:pretty_http_logger/src/middleware/models/request_data.dart';
import 'package:pretty_http_logger/src/middleware/models/response_data.dart';

///Logger interface to log out request and response data on console.
///Use this class as a parameter of `HttpWithMiddleware` or `HttpClientWithMiddleware` such as
///```dart
/// HttpWithMiddleware http = HttpWithMiddleware.build(middlewares: [
///     HttpLogger(logLevel: LogLevel.BODY),
/// ]);```
/// or
///```dart
/// HttpClientWithMiddleware http = HttpClientWithMiddleware.build(middlewares: [
///     HttpLogger(logLevel: LogLevel.BODY),
/// ]);
///```
/// To see different types of Log level and their use cases, please see the documentation of Logger.

class Logger {
  final LogLevel logLevel;
  static JsonDecoder decoder = JsonDecoder();
  static JsonEncoder encoder = JsonEncoder.withIndent('  ');

  /// percentage of width the logger takes to print, defaults to 90
  final int maxWidth;

  /// counts of tabs for the indent, defaults to 4
  final int tabSpaces;

  /// Size in which the Uint8List will be splitted
  static const int chunkSize = 20;

  static const int initialTab = 1;

  static const String tabStep = '    ';

  /// whether the print will be compact or not, defaults to true
  final bool compact;

  Logger({
    required this.logLevel,
    this.maxWidth = 90,
    this.tabSpaces = 4,
    this.compact = true,
  });

  void logRequest(RequestData data) {
    if (logLevel == LogLevel.NONE) {
      return;
    }

    var method = data.method.toString().split('.')[1];

    var bodyInBytes =
        data.body != null ? (utf8.encode(data.body.toString()).length) : 0;

    if (logLevel == LogLevel.BASIC) {
      _printBlock('--> $method ${data.url} ($bodyInBytes-byte Body)');
      return;
    }

    var logBody = logLevel == LogLevel.BODY;
    var logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      _printRequestHeader(data);

      //Log the request body
      if (logBody) {
        _printMapAsTable(data.headers, header: 'Query Parameters');

        if (data.body != null && data.method != Method.GET) {
          final _data = data.body;
          if (_data != null) {
            if (_data is String) {
              _printMapAsTable(jsonDecode(_data), header: 'Body');
            }
            if (_data is Map) _printMapAsTable(_data, header: 'Body');
            if (_data is MultipartRequest) {
              final formDataMap = {}
                ..addAll(_data.fields)
                ..addAll(_getMultiPartRequestFiles(_data));
              _printMapAsTable(formDataMap,
                  header: 'Form _data | ${_data.contentLength}');
            } else {
              _printBlock(_data.toString());
            }
          }
        }
      }
    }
  }

/*
  void logRequest({required RequestData data}) {
    if (logLevel == LogLevel.NONE) {
      return;
    }

    var method = data.method.toString().split('.')[1];

    var bodyInBytes =
        data.body != null ? (utf8.encode(data.body.toString()).length) : 0;

    if (logLevel == LogLevel.BASIC) {
      prettyPrintJson('--> $method ${data.url} ($bodyInBytes-byte Body)');
      return;
    }

    var logBody = logLevel == LogLevel.BODY;
    var logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      prettyPrintJson(
          "--> ${data.method.toString().split(".")[1]} ${data.url}");

      print('HEADERS:');
      var headers = data.headers;
      if (headers == null || headers.isEmpty) {
        // print('Request has no headers.');
      } else {
        // _printRequestHeader(data);
        var headersBuffer = StringBuffer();
        headers.forEach((key, value) => headersBuffer.write('$key: $value\n'));
        prettyPrintJson(headersBuffer.toString());
      }

      //Log the request body
      if (logBody) {
        print('BODY:');

        if (data.body == null) {
          print('Request has no boy.');
        } else {
          prettyPrintJson(data.body);
        }
      }
    }

    print('--> END $method\n');
  }
*/

  void logResponse(ResponseData data) {
    if (logLevel == LogLevel.NONE) {
      return;
    }

    if (logLevel == LogLevel.BASIC) {
      _printBlock('<-- ${data.statusCode} (${data.contentLength}-byte Body)');
      return;
    }

    var logBody = logLevel == LogLevel.BODY;
    var logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      _printResponseHeader(data);

      // prettyPrintJson('URL: ${data.url}');
      // print('HEADERS:');
      // var headers = data.headers;
      // if (headers == null || headers.isEmpty) {
      //   print('Request has no headers.');
      // } else {
      //   var headersBuffer = StringBuffer();
      //   headers.forEach((key, value) => headersBuffer.write('$key: $value\n'));
      //   prettyPrintJson(headersBuffer.toString());
    }
    // }

    //Log the request body
    if (logBody) {
      final responseHeaders = <String, String>{};
      data.headers?.forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(responseHeaders, header: 'Headers');
      logPrint('╔ Body');
      logPrint('║');
      _printResponse(data);
      logPrint('║');
      _printLine('╚');
    }
  }

  void logError(error) {
    _printBoxed(header: 'Error', text: '$error');
  }

/*
  void logResponse({required ResponseData data}) {
    if (logLevel == LogLevel.NONE) {
      return;
    }

    if (logLevel == LogLevel.BASIC) {
      prettyPrintJson(
          '<-- ${data.statusCode} (${data.contentLength}-byte Body)');
      return;
    }

    var method = data.method.toString().split('.')[1];

    print('<-- $method ${data.statusCode}');

    var logBody = logLevel == LogLevel.BODY;
    var logHeaders = logBody || logLevel == LogLevel.HEADERS;

    if (logHeaders) {
      prettyPrintJson('URL: ${data.url}');
      print('HEADERS:');
      var headers = data.headers;
      if (headers == null || headers.isEmpty) {
        print('Request has no headers.');
      } else {
        var headersBuffer = StringBuffer();
        headers.forEach((key, value) => headersBuffer.write('$key: $value\n'));
        prettyPrintJson(headersBuffer.toString());
      }

      //Log the request body
      if (logBody) {
        print('BODY:');
        if (data.body == null) {
          print('Request has no body.');
        } else {
          prettyPrintJson(data.body);
        }
      }
    }

    print('<-- END HTTP');
  }
*/

  void Function(Object object) logPrint = print;

  static void prettyPrintJson(String? input) {
    var object = decoder.convert(input ?? '');
    var prettyString = encoder.convert(object);
    prettyString.split('\n').forEach((element) => print(element));
  }

  void _printBoxed({String? header, String? text}) {
    logPrint('');
    logPrint('╔╣ $header');
    logPrint('║  $text');
    _printLine('╚');
  }

  void _printResponse(ResponseData response) {
    if (response.body.isNotEmpty) {
      try {
        jsonDecode(response.body);
      } catch (e) {
        _printBlock(response.body.toString());
      }
      if (jsonDecode(response.body) is Map) {
        _printPrettyMap(jsonDecode(response.body));
      } else if (jsonDecode(response.body) is Uint8List) {
        logPrint('║${_indent()}[');
        _printUint8List(jsonDecode(response.body));
        logPrint('║${_indent()}]');
      } else if (jsonDecode(response.body) is List) {
        logPrint('║${_indent()}[');
        _printList(jsonDecode(response.body));
        logPrint('║${_indent()}]');
      } else {
        _printBlock(response.body.toString());
      }
    }
  }

  void _printResponseHeader(ResponseData response) {
    final uri = response.url;
    final method = response.method;
    _printBoxed(
        header: 'Response ║ $method ║ Status: ${response.statusCode}',
        text: uri.toString());
  }

  void _printRequestHeader(RequestData options) {
    final uri = options.url;
    final method = options.method;
    _printBoxed(header: 'Request ║ $method ', text: uri.toString());
  }

  void _printLine([String pre = '', String suf = '╝']) =>
      logPrint('$pre${'═' * maxWidth}$suf');

  void _printKV(String key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(pre);
      _printBlock(msg);
    } else {
      logPrint('$pre$msg');
    }
  }

  void _printBlock(String msg) {
    var lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      logPrint((i >= 0 ? '║ ' : '') +
          msg.substring(i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length)));
    }
  }

  String _indent([int tabCount = initialTab]) {
    // Set tabSpaces to default of 4 if outside the range [1, 10]
    final normalizedTabCount = (tabCount >= 1 && tabCount <= 10) ? tabCount : 4;
    return ' ' * (normalizedTabCount * tabSpaces);
  }

  void _printPrettyMap(Map data,
      {int tabs = initialTab, bool isListItem = false, bool isLast = false}) {
    final isRoot = tabs == initialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) logPrint('║$initialIndent{');

    data.keys.toList().asMap().forEach((index, key) {
      final isLast = index == data.length - 1;
      var value = data[key];
//      key = '\"$key\"';
      if (value is String) {
        value = '\"${value.toString().replaceAll(RegExp(r'(\r|\n)+'), " ")}\"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          logPrint('║${_indent(tabs)} $key: {');
          _printPrettyMap(value, tabs: tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint('║${_indent(tabs)} $key: ${value.toString()}');
        } else {
          logPrint('║${_indent(tabs)} $key: [');
          _printList(value, tabs: tabs);
          logPrint('║${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          var lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            logPrint(
                '║${_indent(tabs)} ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
          logPrint('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    });

    logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printUint8List(Uint8List list, {int tabs = initialTab}) {
    var chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
            i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    for (var element in chunks) {
      logPrint('║${_indent(tabs)} ${element.join(", ")}');
    }
  }

  void _printList(List list, {int tabs = initialTab}) {
    list.asMap().forEach((i, e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (compact && _canFlattenMap(e)) {
          logPrint('║${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(e, tabs: tabs + 1, isListItem: true, isLast: isLast);
        }
      } else {
        logPrint('║${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  bool _canFlattenMap(Map map) {
    return map.values.where((val) => val is Map || val is List).isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return (list.length < 10 && list.toString().length < maxWidth);
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    logPrint('╔ $header ');
    map.forEach((key, value) => _printKV(key, value));
    _printLine('╚');
  }

  Map<String, dynamic> _getMultiPartRequestFiles(MultipartRequest data) {
    var _map = <String, dynamic>{};
    data.files.forEach((e) {
      _map.addAll(<String, dynamic>{
        'fileName': e.filename,
        'field': e.field,
        'contentType': e.contentType
      });
    });

    return _map;
  }
}
