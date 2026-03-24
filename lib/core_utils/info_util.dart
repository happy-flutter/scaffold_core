import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart'
    as dip
    show AndroidDeviceInfo, IosDeviceInfo, DeviceInfoPlugin;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 设备信息
class DeviceInfo {
  final dip.AndroidDeviceInfo? androidDeviceInfo;

  final dip.IosDeviceInfo? iosDeviceInfo;

  const DeviceInfo({this.androidDeviceInfo, this.iosDeviceInfo});

  Map<String, dynamic> get data => Platform.isAndroid
      ? androidDeviceInfo?.data ?? {}
      : iosDeviceInfo?.data ?? {};
}

/// 应用信息
class AppInfo {
  /// 应用名称
  final String appName;

  /// 包名
  final String packageName;

  /// 版本号
  final String version;

  /// build版本号
  final String buildNumber;

  /// 安装时间
  final DateTime? installTime;

  /// 更新时间
  final DateTime? updateTime;

  /// 是否是debug模式
  String get mode => kDebugMode ? 'debug' : 'release';

  AppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.installTime,
    this.updateTime,
  });

  Map<String, dynamic> get data => {
    '名称': appName,
    '包名': packageName,
    '版本号': version,
    'build号': buildNumber,
    '安装时间': installTime,
    '更新时间': updateTime,
    '构建模式': mode,
  };
}

/// app信息工具类
abstract class InfoUtil {
  InfoUtil._();

  /// app信息
  static late final AppInfo appInfo;

  /// 设备信息
  static late final DeviceInfo deviceInfo;

  /// 初始化
  ///
  static Future<void> init() async {
    dip.DeviceInfoPlugin info = dip.DeviceInfoPlugin();
    dip.AndroidDeviceInfo? androidInfo;
    dip.IosDeviceInfo? iosInfo;
    if (Platform.isAndroid) {
      androidInfo = await info.androidInfo;
    } else if (Platform.isIOS) {
      iosInfo = await info.iosInfo;
    }

    deviceInfo = DeviceInfo(
      androidDeviceInfo: androidInfo,
      iosDeviceInfo: iosInfo,
    );

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appInfo = AppInfo(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      installTime: packageInfo.installTime,
      updateTime: packageInfo.updateTime,
    );
  }
}
