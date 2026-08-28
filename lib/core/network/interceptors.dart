import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
    level: kReleaseMode ? Level.off : Level.debug,
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('${err.requestOptions.method} request failed (${err.type.name})');
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('${options.method} request started');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      '${response.requestOptions.method} response ${response.statusCode}',
    );
    handler.next(response);
  }
}
