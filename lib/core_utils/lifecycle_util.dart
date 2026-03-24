import 'dart:async';

import 'package:flutter/services.dart';

enum AppLifecycle {
  /// incative
  inactive('AppLifecycleState.inactive', 'inactive', '非活跃'),

  /// paused
  paused('AppLifecycleState.paused', 'paused', '暂停'),

  /// resumed
  resumed('AppLifecycleState.resumed', 'resumed', '恢复'),

  /// detached
  detached('AppLifecycleState.detached', 'detached', '断开');

  final String value;

  final String name;

  final String description;

  const AppLifecycle(this.value, this.name, this.description);

  static AppLifecycle fromValue(String value) {
    return values.firstWhere(
      (v) => v.value == value,
      orElse: () => AppLifecycle.detached,
    );
  }

  @override
  String toString() {
    return 'AppLifecycle(value: $value, name: $name, description: $description)';
  }
}

/// app生命周期管理类
///
/// 使用方式：
/// ```dart
/// LifecycleUtil.addLifeCycleListener((lifecycle) {
///   print(lifecycle);
/// });
/// ```
abstract class LifecycleUtil {
  LifecycleUtil._();

  static StreamController<AppLifecycle>? _lifecycleNotifaction;

  /// 添加生命周期监听
  /// [onData] 生命周期回调
  /// [onError] 错误回调
  /// [onDone] 完成回调
  /// [cancelOnError] 是否在错误时取消监听
  static StreamSubscription addLifeCycleListener(
    void Function(AppLifecycle)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (_lifecycleNotifaction == null) {
      _lifecycleNotifaction = StreamController.broadcast();
      SystemChannels.lifecycle.setMessageHandler((msg) async {
        AppLifecycle lifecycle = AppLifecycle.fromValue(msg ?? '');
        _lifecycleNotifaction!.sink.add(lifecycle);
        return msg;
      });
    }

    return _lifecycleNotifaction!.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
