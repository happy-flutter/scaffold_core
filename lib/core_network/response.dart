part of 'core_network.dart';

/// 请求返回对象
class NetworkResponse {
  /// 返回的状态码
  final int code;

  /// 返回状态信息
  final String msg;

  /// 返回的数据
  dynamic data;

  /// 返回的headers
  Map<String, List<String>> headers;

  /// 请求是否成功
  bool get success => code >= 200 && code < 300;

  NetworkResponse(this.code, this.msg, this.headers, {this.data});

  factory NetworkResponse.fromResponse(Response response) {
    return NetworkResponse(
      response.statusCode ?? -1,
      response.statusMessage ?? 'Unknown',
      response.headers.map,
      data: response.data,
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
