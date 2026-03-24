part of 'core_network.dart';

/// 网络请求异常类型
enum NetworkExceptionType {
  /// 请求超时
  sendTimeout,

  /// 响应超时
  receiveTimeout,

  ///链接超时
  connectionTimeout,

  /// 连接错误
  connectionError,

  /// 取消
  cancel,

  /// 错误的响应
  badResponse,

  /// 证书错误
  badCertificate,

  /// 外部异常
  /// 如数据解析发生错误
  external,

  /// 未知
  unknown,
}

/// 网络请求异常
class NetworkException implements Exception {
  final String message;

  final NetworkExceptionType type;

  final int? statusCode;

  final StackTrace? stackTrace;

  const NetworkException(
    this.message,
    this.type, {
    this.statusCode,
    this.stackTrace,
  });

  factory NetworkException.fromError(Error error) {
    return NetworkException(
      error.toString(),
      NetworkExceptionType.external,
      stackTrace: error.stackTrace,
    );
  }

  factory NetworkException.fromDioException(DioException ex) {
    String message = '发生错误,请稍后再试';
    NetworkExceptionType type = NetworkExceptionType.unknown;

    switch (ex.type) {
      case DioExceptionType.connectionTimeout:
        message = '请求链接超时，请检查网络！';
        type = NetworkExceptionType.connectionTimeout;
        break;
      case DioExceptionType.receiveTimeout:
        message = '请求响应超时，请稍等片刻重试！';
        type = NetworkExceptionType.receiveTimeout;
        break;
      case DioExceptionType.sendTimeout:
        message = '请求发送超时，请重试！';
        type = NetworkExceptionType.sendTimeout;
        break;
      case DioExceptionType.connectionError:
        message = '请求链接错误，请检查网络！';
        type = NetworkExceptionType.connectionError;
        break;
      case DioExceptionType.cancel:
        message = '请求取消';
        type = NetworkExceptionType.cancel;
        break;
      case DioExceptionType.badResponse:
        final response = ex.response;
        final statusCode = response?.statusCode;
        var msg = response?.data is Map && response?.data['msg'] != null
            ? response?.data['msg']
            : response?.data['message'] ?? message;
        return NetworkException(
          msg,
          NetworkExceptionType.badResponse,
          statusCode: statusCode,
        );
      case DioExceptionType.badCertificate:
        message = '证书错误，请检查网络或稍后重试！';
        type = NetworkExceptionType.badCertificate;
        break;
      case DioExceptionType.unknown:
        message = ex.message ?? ex.error?.toString() ?? '未知错误，请检查网络连接！';
        type = NetworkExceptionType.unknown;
        break;
    }

    return NetworkException(
      message,
      type,
      statusCode: ex.response?.statusCode,
      stackTrace: ex.stackTrace,
    );
  }

  @override
  String toString() {
    return 'NetworkException : $message\n$stackTrace ';
  }
}
