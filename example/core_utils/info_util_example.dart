import 'package:scaffold_core/core_utils/info_util.dart';

void main() async {
  await InfoUtil.init();
  
  print('App name: ${InfoUtil.appInfo.appName}');
  print('App version: ${InfoUtil.appInfo.version}');
  print('Package name: ${InfoUtil.appInfo.packageName}');
  print('Build number: ${InfoUtil.appInfo.buildNumber}');
  print('Build mode: ${InfoUtil.appInfo.mode}');
  
  if (InfoUtil.deviceInfo.androidDeviceInfo != null) {
    print('Android model: ${InfoUtil.deviceInfo.androidDeviceInfo?.model}');
  }
}
