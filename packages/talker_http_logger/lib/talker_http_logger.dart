library talker_http_logger;

import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:talker/talker.dart';

class TalkerHttpLogger extends InterceptorContract {
  TalkerHttpLogger({Talker? talker}) {
    _talker = talker ?? Talker();
  }

  late Talker _talker;

  @override
  Future<BaseRequest> interceptRequest({
    required BaseRequest request,
  }) async {
    final message = '${request.url}';
    _talker.logCustom(HttpRequestLog(message, request: request));
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    final message = '${response.request?.url}';

    if (response.statusCode >= 400 && response.statusCode < 600) {
      _talker.logCustom(HttpErrorLog(message, response: response));
    } else {
      _talker.logCustom(HttpResponseLog(message, response: response));
    }

    return response;
  }
}

const encoder = JsonEncoder.withIndent('  ');

class HttpRequestLog extends TalkerLog {
  HttpRequestLog(
    String title, {
    required this.request,
  }) : super(title);

  final BaseRequest request;

  @override
  AnsiPen get pen => (AnsiPen()..xterm(219));

  @override
  String get key => TalkerLogType.httpRequest.key;

  @override
  String generateTextMessage({TimeFormat timeFormat = TimeFormat.timeAndSeconds}) {
    var msg = '[$title] [${request.method}] $message';

    final headers = request.headers;

    try {
      if (headers.isNotEmpty) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (_) {
      // TODO: add handling can`t convert
    }
    return msg;
  }
}

class HttpResponseLog extends TalkerLog {
  HttpResponseLog(
    String title, {
    required this.response,
  }) : super(title);

  final BaseResponse response;

  @override
  AnsiPen get pen => (AnsiPen()..xterm(46));

  @override
  String get key => TalkerLogType.httpResponse.key;

  @override
  String generateTextMessage({TimeFormat timeFormat = TimeFormat.timeAndSeconds}) {
    var msg = '[$title] [${response.request?.method}] $message';

    final headers = response.request?.headers;

    msg += '\nStatus: ${response.statusCode}';

    try {
      if (headers?.isNotEmpty ?? false) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (_) {
      // TODO: add handling can`t convert
    }
    return msg;
  }
}

class HttpErrorLog extends TalkerLog {
  HttpErrorLog(
    String title, {
    required this.response,
  }) : super(title);

  final BaseResponse response;

  @override
  AnsiPen get pen => AnsiPen()..red();

  @override
  String get key => TalkerLogType.httpError.key;

  @override
  String generateTextMessage({TimeFormat timeFormat = TimeFormat.timeAndSeconds}) {
    var msg = '[$title] [${response.request?.method}] $message';

    final headers = response.request?.headers;

    msg += '\nStatus: ${response.statusCode}';

    try {
      if (headers?.isNotEmpty ?? false) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
    } catch (_) {
      // TODO: add handling can`t convert
    }
    return msg;
  }
}
