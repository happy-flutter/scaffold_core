import 'package:flutter/widgets.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// 日志等级
enum LogUtilLevel {
  info(LogLevel.info, 'info'),
  warning(LogLevel.warning, 'warning'),
  error(LogLevel.error, 'error'),
  debug(LogLevel.debug, 'debug');

  final LogLevel level;

  final String name;

  const LogUtilLevel(this.level, this.name);
}

/// 日志工具类
abstract class LogUtil {
  static Talker? _talker;

  // Talker实例
  static Talker get talker => _talker ??= _init();

  static Talker _init() {
    final logger = TalkerLogger(formatter: _CustomColoredLoggerFormatter());
    final talker = TalkerFlutter.init(logger: logger);
    return talker;
  }

  static void info(
    dynamic message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    talker.info(message, exception, stackTrace);
  }

  static void warning(
    dynamic message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    talker.warning(message);
  }

  static void error(
    dynamic message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    talker.error(message);
  }

  static void debug(
    dynamic message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    talker.debug(message);
  }

  static void log(
    dynamic message, {
    LogUtilLevel logLevel = LogUtilLevel.debug,
    Object? exception,
    StackTrace? stackTrace,
    AnsiPen? pen,
  }) {
    talker.log(
      message,
      logLevel: logLevel.level,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  static TalkerDioLogger get talkerDioLogger => TalkerDioLogger(
    talker: talker,
    settings: const TalkerDioLoggerSettings(
      printRequestHeaders: true,
      printResponseHeaders: false,
      printResponseTime: true,
      printResponseData: true,
      logLevel: LogLevel.debug,
    ),
  );

  static Widget get talkerPage => TalkerScreen(talker: talker);

  static NavigatorObserver get navigatorObserver => TalkerRouteObserver(talker);
}

extension StringExtensionLog on String {
  /// 打印
  void log() {
    LogUtil.log(this);
  }
}

class _CustomColoredLoggerFormatter implements LoggerFormatter {
  @override
  String fmt(LogDetails details, TalkerLoggerSettings settings) {
    final msg = details.message?.toString() ?? '';
    final coloredMsg = msg
        .split('\n')
        .map((e) => details.pen.write(e))
        .toList()
        .join('\n');
    return coloredMsg;
  }
}
