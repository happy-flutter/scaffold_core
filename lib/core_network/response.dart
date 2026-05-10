part of 'core_network.dart';

/// 请求返回对象
class NetworkResponse<T> {
  /// 返回的状态码
  final int code;

  /// 返回状态信息
  final String msg;

  /// 返回的数据
  final T? data;

  /// 返回的headers
  final Map<String, List<String>> headers;

  /// 请求是否成功
  bool get success => code >= 200 && code < 300;

  NetworkResponse(this.code, this.msg, this.headers, {this.data});

  factory NetworkResponse.fromResponse(
    Response response, {
    ResponseDecoder<T>? decoder,
  }) {
    final rawData = response.data;
    return NetworkResponse<T>(
      response.statusCode ?? -1,
      response.statusMessage ?? 'Unknown',
      response.headers.map,
      data: decoder == null ? rawData as T? : decoder(rawData),
    );
  }

  @override
  String toString() {
    return '[NetworkResponse] \n'
        'status: $code, \n'
        'msg: $msg, \n'
        'headers: $headers, \n'
        'data: ${data.toString()}';
  }
}
