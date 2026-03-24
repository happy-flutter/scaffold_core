import 'package:scaffold_core/core_utils/connectivity_util.dart';

void main() async {
  final status = await ConnectivityUtil.checkConnectivity();
  print('Connectivity status: ${status.name}');
  print('Has internet: ${status.hasInternet}');
  print('Is WiFi: ${status.isWifi}');

  final subscription = ConnectivityUtil.listenConnectivityChanged((status) {
    print('Connectivity changed: ${status.name}');
  });

  subscription.cancel();
}
