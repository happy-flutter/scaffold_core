part of 'core_network.dart';

typedef SendProgress = void Function(int, int);
typedef ReceiveProgress = void Function(int, int);

/// methods of request
enum NetworkRequestMethod { get, post, put, delete, patch, head }

/// 可取消对象
/// 用于取消请求
class Cancelabel extends CancelToken {}

/// 普通请求对象
class NetworkRequest {
  /// 请求地址
  /// 如果是完整的url(如http://开头)
  /// 则会覆盖client中的baseUrl
  final String apiPath;

  /// request method
  final NetworkRequestMethod method;

  /// queryparams
  final Map<String, dynamic>? queryParams;

  /// body data
  final dynamic data;

  /// content type
  final String? contentType;

  /// headers
  final Map<String, dynamic> headers;

  final Map<String, dynamic> extra;

  final Cancelabel? cancelToken;

  final SendProgress? onSendProgress;
  final ReceiveProgress? onReceiveProgress;

  Options get optiopns => Options(
    method: method.name,
    contentType: contentType ?? Headers.jsonContentType,
    headers: headers,
    extra: extra,
  );

  const NetworkRequest(
    this.apiPath, {
    this.method = NetworkRequestMethod.get,
    this.queryParams,
    this.data,
    this.contentType,
    this.headers = const {},
    this.extra = const {},
    this.onSendProgress,
    this.onReceiveProgress,
    this.cancelToken,
  });

  factory NetworkRequest.fromRequestOptions(
    RequestOptions options, {
    bool clearHeaders = true,
  }) {
    return NetworkRequest(
      options.path,
      method: NetworkRequestMethod.values.firstWhere(
        (e) => e.name == options.method,
      ),
      queryParams: options.queryParameters,
      data: options.data,
      headers: clearHeaders ? {} : options.headers,
      extra: options.extra,
      cancelToken: options.cancelToken as Cancelabel?,
    );
  }
}

/// 下载请求
class DownloadRequest extends NetworkRequest {
  const DownloadRequest(
    super.apiPath, {
    required this.savePath,
    this.deleteOnError = true,
    super.method,
    super.onReceiveProgress,
    super.headers,
    super.extra,
    super.cancelToken,
    super.data,
    super.queryParams,
  });

  final String savePath;

  final bool deleteOnError;
}

/// 上传请求
/// 通过FormData的API来封装上传数据,
/// 参数可以直接放在api的para中
/// FormData.fromMap({
/// 'name': 'wendux',
/// 'age': 25,
/// 'file':
///   await MultipartFile.fromFile('./text.txt', filename: 'upload.txt'),
/// 'files': [
///   await MultipartFile.fromFile('./text1.txt', filename: 'text1.txt'),
///   await MultipartFile.fromFile('./text2.txt', filename: 'text2.txt'),
/// ]});
class UploadRequset extends NetworkRequest {
  UploadRequset(
    super.apiPath, {
    required List<String> filePaths,
    Map<String, dynamic>? fields,
    super.headers,
    super.cancelToken,
    super.onSendProgress,
  }) : super(
         method: NetworkRequestMethod.post,
         contentType: Headers.multipartFormDataContentType,
         extra: _createExtra(fields: fields, filePaths: filePaths),
         data: _createFormData(fields: fields, filePaths: filePaths),
       );

  static Map<String, dynamic> _createExtra({
    Map<String, dynamic>? fields,
    required List<String> filePaths,
  }) {
    return {'fields': fields, 'filePaths': filePaths};
  }

  static FormData _createFormData({
    Map<String, dynamic>? fields,
    required List<String> filePaths,
  }) {
    var formData = FormData();
    formData.clone();
    if (fields != null) {
      formData.fields.addAll(
        fields.map((key, value) => MapEntry(key, value.toString())).entries,
      );
    }
    if (filePaths.length == 1) {
      formData.files.add(
        MapEntry('file', MultipartFile.fromFileSync(filePaths.first)),
      );
    } else if (filePaths.length > 1) {
      formData.files.addAll(
        filePaths.map((e) => MapEntry('files', MultipartFile.fromFileSync(e))),
      );
    }

    return formData;
  }
}
