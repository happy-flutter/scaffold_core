import 'dart:async';

import 'interceptors/retry_interceptor.dart';
import 'package:dio/dio.dart';

export 'package:dio/dio.dart';

part 'exception.dart';
part 'request.dart';
part 'response.dart';

typedef Decoder<T> = T Function(Map<String, dynamic>);
typedef ResponseDecoder<T> = T Function(dynamic data);

class NetworkClient {
  NetworkClient._() : _dio = Dio();

  static Dio get dio => _instance._dio;

  factory NetworkClient() => _instance;

  static final NetworkClient _instance = NetworkClient._();

  final Dio _dio;

  /// 初始化
  /// 设置全局请求参数
  static void init({
    String baseUrl = '',
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = _instance._dio;
    dio.options = dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      queryParameters: queryParameters,
      extra: extra,
      headers: headers,
    );

    dio.interceptors.addAll(interceptors);
  }

  /// 添加全局请求头
  void addHeaders(Map<String, dynamic> headers) {
    _instance._dio.options.headers.addAll(headers);
  }

  /// 移除全局请求头
  void removeHeader(String key) {
    _instance._dio.options.headers.remove(key);
  }

  /// 添加拦截器
  void addInterceptor(List<Interceptor> interceptors) {
    _instance._dio.interceptors.addAll(interceptors);
  }

  /// 移除拦截器
  void removeInterceptor(Interceptor interceptor) {
    _instance._dio.interceptors.remove(interceptor);
  }

  /// 基础请求
  /// [req] 请求体构建对象
  /// [retry] 是否重试
  Future<NetworkResponse<T>> fetch<T>(
    NetworkRequest req, {
    bool retry = false,
    ResponseDecoder<T>? decoder,
  }) async {
    try {
      Response response = await dio.request(
        req.apiPath,
        data: req.data,
        queryParameters: req.queryParams,
        cancelToken: req.cancelToken,
        options: req.options..disableRetry = !retry,
        onSendProgress: req.onSendProgress,
        onReceiveProgress: req.onReceiveProgress,
      );

      return NetworkResponse.fromResponse(response, decoder: decoder);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on Error catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  /// 上传
  Future<NetworkResponse<T>> upload<T>(
    UploadRequest req, {
    bool retry = false,
    ResponseDecoder<T>? decoder,
  }) async => fetch(req, retry: retry, decoder: decoder);

  /// 下载
  Future<NetworkResponse<T>> download<T>(
    DownloadRequest req, {
    bool retry = false,
    ResponseDecoder<T>? decoder,
  }) async {
    try {
      Response response = await dio.download(
        req.apiPath,
        req.savePath,
        data: req.data,
        queryParameters: req.queryParams,
        onReceiveProgress: req.onReceiveProgress,
        cancelToken: req.cancelToken,
        deleteOnError: req.deleteOnError,
        options: req.options..disableRetry = !retry,
      );
      return NetworkResponse.fromResponse(response, decoder: decoder);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on Error catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  /// 使用无配置的dio发送请求
  Future<Response> retry<T>(RequestOptions options) async {
    NetworkRequest req = NetworkRequest.fromRequestOptions(options);

    return await dio.request(
      req.apiPath,
      data: req.data,
      queryParameters: req.queryParams,
      cancelToken: req.cancelToken,
      options: req.options,
      onSendProgress: req.onSendProgress,
      onReceiveProgress: req.onReceiveProgress,
    );
  }
}
