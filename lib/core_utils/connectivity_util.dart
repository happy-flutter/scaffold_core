import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

typedef StatusChangedCallback = void Function(ConnectivityStatus);

/// 网络状态枚举
enum ConnectivityStatus {
  mobile('mobile', '移动网络'),
  wifi('wifi', 'Wi-Fi'),
  ethernet('ethernet', '以太网'),
  vpn('vpn', 'VPN'),
  bluetooth('bluetooth', '蓝牙'),
  other('other', '其他'),
  none('none', '无');

  /// 是否有网络
  bool get hasInternet => this != none;

  /// 是否是移动网络
  bool get isMobile => this == mobile;

  /// 是否是Wi-Fi
  bool get isWifi => this == wifi;

  final String name;
  final String nameZh;

  const ConnectivityStatus(this.name, this.nameZh);

  factory ConnectivityStatus.fromConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.mobile;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.wifi;
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.ethernet;
      case ConnectivityResult.vpn:
        return ConnectivityStatus.vpn;
      case ConnectivityResult.bluetooth:
        return ConnectivityStatus.bluetooth;
      case ConnectivityResult.other:
        return ConnectivityStatus.other;
      case ConnectivityResult.none:
        return ConnectivityStatus.none;
      default:
        return ConnectivityStatus.none;
    }
  }
}

/// 网络状态工具类
class ConnectivityUtil {
  ConnectivityUtil._();

  static StreamController<ConnectivityStatus>? _connectivityController;

  static StreamController<ConnectivityStatus> get connectivityController =>
      _connectivityController ?? _init();

  static StreamController<ConnectivityStatus> _init() {
    return StreamController.broadcast();
  }

  /// 监听网络状态
  /// [onStatusChanged] 网络状态回调
  ///
  /// 生成一个用于监听网络状态的订阅器[StreamSubscription<ConnectivityStatus>]
  /// 页面生命周期结束时，需要调用[subscription.cancel()]取消订阅
  static StreamSubscription<ConnectivityStatus> listenConnectivityChanged(
    StatusChangedCallback onStatusChanged,
  ) {
    return Connectivity().onConnectivityChanged
        .map((result) => _statusFormConnectivityResult(result))
        .listen(onStatusChanged);
  }

  /// 检查网络状态
  static Future<ConnectivityStatus> checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    return _statusFormConnectivityResult(connectivityResult);
  }

  /// 由于Connectivity在返回监听网络状态或是当前网络状态时，
  /// 会返回多个网络状态[List<ConnectivityResult>]，
  /// 所以需要根据判断逻辑转换为单个网络状态[ConnectivityStatus]
  static ConnectivityStatus _statusFormConnectivityResult(
    List<ConnectivityResult> connectivityResult,
  ) {
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Mobile network available.
      return ConnectivityStatus.wifi;
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Note for Android:
      // When both mobile and Wi-Fi are turned on
      //system will return Wi-Fi only as active network type
      return ConnectivityStatus.mobile;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      return ConnectivityStatus.ethernet;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      return ConnectivityStatus.bluetooth;
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
      return ConnectivityStatus.other;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      return ConnectivityStatus.none;
    }
    return ConnectivityStatus.none;
  }
}
