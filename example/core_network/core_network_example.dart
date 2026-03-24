import 'package:scaffold_core/core_network/core_network.dart';

void main() async {
  NetworkClient.init(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  );

  final response = await NetworkClient().fetch(
    NetworkRequest('/users', method: NetworkRequestMethod.get),
  );

  if (response.success) {
    print(response.data);
  } else {
    print('${response.code}: ${response.msg}');
  }

  final uploadRequest = UploadRequset(
    '/upload',
    filePaths: ['/path/to/file.jpg'],
    fields: {'name': 'test'},
  );

  final uploadResponse = await NetworkClient().upload(uploadRequest);
  print('Upload response: $uploadResponse');
}
