import 'dart:async';

import 'package:dio/dio.dart';
import '../status_codes.dart';

const _kDisableRetryKey = 'disable_retry';

const defaultRetryableStatuses = <int>{
  status408RequestTimeout,
  status429TooManyRequests,
  status500InternalServerError,
  status502BadGateway,
  status503ServiceUnavailable,
  status504GatewayTimeout,
  status440LoginTimeout,
  status499ClientClosedRequest,
  status460ClientClosedRequest,
  status598NetworkReadTimeoutError,
  status599NetworkConnectTimeoutError,
  status520WebServerReturnedUnknownError,
  status521WebServerIsDown,
  status522ConnectionTimedOut,
  status523OriginIsUnreachable,
  status524TimeoutOccurred,
  status525SSLHandshakeFailed,
  status527RailgunError,
};

/// 默认重试评估器
class DefaultRetryEvaluator {
  DefaultRetryEvaluator(this._retryableStatuses);

  final Set<int> _retryableStatuses;
  int currentAttempt = 0;

  /// Returns true only if the response hasn't been cancelled
  ///   or got a bad status code.
  FutureOr<bool> evaluate(DioException error, int attempt) {
    bool shouldRetry;
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        shouldRetry = isRetryable(statusCode);
      } else {
        // 当状态码为null时，不重试
        shouldRetry = false;
      }
    } else {
      shouldRetry =
          error.type != DioExceptionType.cancel &&
          error.error is! FormatException;
    }
    currentAttempt = attempt;
    return shouldRetry;
  }

  bool isRetryable(int statusCode) => _retryableStatuses.contains(statusCode);
}

/// 重试评估器
typedef RetryEvaluator =
    FutureOr<bool> Function(DioException error, int attempt);

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.logPrint,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 3),
      Duration(seconds: 5),
    ],
    RetryEvaluator? retryEvaluator,
    this.ignoreRetryEvaluatorExceptions = false,
    this.retryableExtraStatuses = const {},
  }) : _retryEvaluator =
           retryEvaluator ??
           DefaultRetryEvaluator({
             ...defaultRetryableStatuses,
             ...retryableExtraStatuses,
           }).evaluate {
    if (retryEvaluator != null && retryableExtraStatuses.isNotEmpty) {
      throw ArgumentError(
        '[retryableExtraStatuses] works only if [retryEvaluator] is null.'
            ' Set either [retryableExtraStatuses] or [retryEvaluator].'
            ' Not both.',
        'retryableExtraStatuses',
      );
    }
    if (retries < 0) {
      throw ArgumentError('[retries] cannot be less than 0', 'retries');
    }
  }

  /// The original dio
  final Dio dio;

  /// For logging purpose
  final void Function(String message)? logPrint;

  /// The number of retry in case of an error
  final int retries;

  /// Ignore exception if [_retryEvaluator] throws it (not recommend)
  final bool ignoreRetryEvaluatorExceptions;

  /// The delays between attempts.
  /// Empty [retryDelays] means no delay.
  ///
  /// If [retries] count more than [retryDelays] count,
  ///   the last element value of [retryDelays] will be used.
  final List<Duration> retryDelays;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  ///   updating authentication token in case of a unauthorized error
  ///   (be careful with concurrency though).
  ///
  /// Defaults to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetryableStatuses].
  final RetryEvaluator _retryEvaluator;

  /// Specifies an extra retryable statuses,
  ///   which will be taken into account with [defaultRetryableStatuses]
  /// IMPORTANT: THIS SETTING WORKS ONLY IF [_retryEvaluator] is null
  final Set<int> retryableExtraStatuses;

  /// Redirects to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetryableStatuses]
  static final FutureOr<bool> Function(DioException error, int attempt)
  defaultRetryEvaluator = DefaultRetryEvaluator(
    defaultRetryableStatuses,
  ).evaluate;

  Future<bool> _shouldRetry(DioException error, int attempt) async {
    try {
      return await _retryEvaluator(error, attempt);
    } catch (e) {
      logPrint?.call('There was an exception in _retryEvaluator: $e');
      if (!ignoreRetryEvaluatorExceptions) {
        rethrow;
      }
    }
    // 当忽略异常时，默认不重试
    return false;
  }

  @override
  Future<dynamic> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    return _handleRetry(err, handler);
  }

  Future<dynamic> _handleRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var requestOptions = err.requestOptions;
    final attempt = requestOptions.attempt + 1;

    /// 检查是否需要重试
    bool isCancelled = requestOptions.cancelToken?.isCancelled ?? false;
    bool isDisableRetry = requestOptions.disableRetry;
    bool isExceedMaxRetry = attempt > retries;
    bool shouldRetryEvaluator = await _shouldRetry(err, attempt);

    final shouldRetry =
        !isCancelled &&
        !isDisableRetry &&
        !isExceedMaxRetry &&
        shouldRetryEvaluator;

    if (!shouldRetry) {
      if (isCancelled) {
        logPrint?.call('请求不重试：请求通过CancelToken取消');
      } else if (isDisableRetry) {
        logPrint?.call('请求不重试：已设置 disableRetry');
      } else if (isExceedMaxRetry) {
        logPrint?.call('请求不重试：已达到最大重试次数($retries)');
      } else if (!shouldRetryEvaluator) {
        logPrint?.call(
          '请求不重试：重试评估器判定不重试(statusCode: ${err.response?.statusCode})',
        );
      } else {
        logPrint?.call('请求不重试：未知原因');
      }
      return super.onError(err, handler);
    }

    ///// 下面是重试逻辑 /////
    final delay = _getDelay(attempt);

    logPrint?.call(
      '[${requestOptions.path}] 请求发生错误!\n'
      '(重试中,尝试次数: $attempt/$retries,等待 ${delay.inMilliseconds} ms)\n '
      'error: ${err.error ?? err}',
    );

    requestOptions.attempt = attempt;
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    requestOptions = _recreateOptions(requestOptions);

    try {
      await dio
          .fetch<void>(requestOptions)
          .then((value) => handler.resolve(value));
    } on DioException catch (e) {
      handler.reject(e);
    } catch (e) {
      // 将其他异常包装为DioException
      handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  Duration _getDelay(int attempt) {
    if (retryDelays.isEmpty) return Duration.zero;
    return attempt - 1 < retryDelays.length
        ? retryDelays[attempt - 1]
        : retryDelays.last;
  }

  RequestOptions _recreateOptions(RequestOptions options) {
    late dynamic data;
    if (options.data is FormData) {
      try {
        data = (options.data as FormData).clone();
      } catch (e) {
        logPrint?.call('FormData 克隆失败: $e, 使用原始数据');
        data = options.data;
      }
    } else {
      data = options.data;
    }

    return options.copyWith(
      data: data,
      queryParameters: options.queryParameters,
      headers: options.headers,
      extra: options.extra,
    );
  }
}

/// 请求选项扩展
extension RequestOptionsX on RequestOptions {
  static const _kAttemptKey = 'attempt_retry';

  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;

  int get attempt => (extra[_kAttemptKey] as int?) ?? 0;

  set attempt(int value) => extra[_kAttemptKey] = value;
}

/// 选项扩展
extension OptionsX on Options {
  bool get disableRetry => (extra?[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) {
    extra = Map.of(extra ??= <String, dynamic>{});
    extra![_kDisableRetryKey] = value;
  }
}
