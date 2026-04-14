import 'dart:async';

import 'package:flutter/foundation.dart';

/// 节流/防抖管理器
class ThrottleUtil {
  static final ThrottleUtil _instance = ThrottleUtil._internal();
  factory ThrottleUtil() => _instance;
  ThrottleUtil._internal() {
    if (_cleanupTimer == null)
      _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
        _cleanupExpired();
      });
  }

  static ThrottleUtil get instance => _instance;
  Timer? _cleanupTimer;
  Duration _cleanupInterval = const Duration(minutes: 10);
  Duration get cleanupInterval => _cleanupInterval;

  /// 全局缓存
  final Map<String, ThrottleData<dynamic>> _throttleCache = {};
  Map<String, ThrottleData<dynamic>> get throttleCache => _throttleCache;

  final Map<String, DebounceData> _debounceCache = {};
  Map<String, DebounceData> get debounceCache => _debounceCache;

  /// 设置清理间隔
  void setCleanupInterval(Duration value) {
    _cleanupInterval = value;
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupExpired();
    });
  }

  /// 清理过期数据
  void _cleanupExpired() {
    final now = DateTime.now();
    _throttleCache.removeWhere((key, data) {
      return now.difference(data.lastCall) > Duration(minutes: 30);
    });
    _debounceCache.removeWhere((key, data) {
      return now.difference(data.lastCall) > Duration(minutes: 30);
    });
  }

  /// 清理所有缓存
  void clearAll() {
    _throttleCache.clear();
    _debounceCache.clear();
  }

  /// 清理指定 key 的节流缓存
  void clearThrottle(String key) {
    _throttleCache.remove(key);
  }

  /// 清理指定 key 的防抖缓存
  void clearDebounce(String key) {
    _debounceCache.remove(key);
  }

  /// 获取缓存大小
  int get throttleCacheSize => _throttleCache.length;
  int get debounceCacheSize => _debounceCache.length;

  /// 停止自动清理
  void dispose() {
    _cleanupTimer?.cancel();
    _throttleCache.clear();
    _debounceCache.clear();
  }
}

/// 节流数据
class ThrottleData<T> {
  final DateTime lastCall;
  final Future<T>? completedFuture;
  final Future<T>? pendingFuture;
  final Completer<T>? pendingCompleter;

  ThrottleData({
    required this.lastCall,
    this.completedFuture,
    this.pendingFuture,
    this.pendingCompleter,
  });
}

/// 防抖数据
class DebounceData {
  final DateTime lastCall;
  final Timer? timer;

  DebounceData({required this.lastCall, this.timer});
}

class _FunctionProxy {
  const _FunctionProxy(this.target, {Duration? timeout})
    : timeout = timeout ?? const Duration(milliseconds: 500);

  final Function? target;

  final Duration timeout;

  /// 节流
  ///
  /// 在事件触发时，立即执行事件的目标操作逻辑，
  /// 在当前事件未执行完成时，该事件再次触发时会被忽略，
  /// 直到当前事件执行完成后下一次事件触发才会被执行。
  void throttle() async {
    String key = target.hashCode.toString();
    if (ThrottleUtil.instance.throttleCache[key] != null) {
      return;
    }
    ThrottleUtil.instance.throttleCache[key] = ThrottleData<dynamic>(
      lastCall: DateTime.now(),
    );
    try {
      await target?.call();
    } catch (e) {
      rethrow;
    } finally {
      ThrottleUtil.instance.throttleCache.remove(key);
    }
  }

  /// 指定时间节流
  ///
  /// 按指定时间节流是在事件触发时，立即执行事件的目标操作逻辑，但
  /// 在指定时间内再次触发事件会被忽略，直到指定时间后再次触发事件才会被执行。
  void throttleWithTimeout() {
    String key = target.hashCode.toString();
    final now = DateTime.now();
    final cached = ThrottleUtil.instance.throttleCache[key];
    if (cached != null && now.difference(cached.lastCall) < timeout) {
      return;
    }
    ThrottleUtil.instance.throttleCache[key] = ThrottleData<dynamic>(
      lastCall: now,
    );
    target?.call();
  }

  /// 防抖
  ///
  /// 在事件触发时，不立即执行事件的目标操作逻辑，而是延迟指定时间再执行，
  /// 如果该时间内事件再次触发，则取消上一次事件的执行并重新计算延迟时间，
  /// 直到指定时间内事件没有再次触发时才会执行事件的目标操作。
  void debounce() {
    String key = target.hashCode.toString();
    final now = DateTime.now();
    DebounceData? data = ThrottleUtil.instance.debounceCache[key];
    data?.timer?.cancel();

    final timer = Timer(timeout, () {
      ThrottleUtil.instance.debounceCache.remove(key);
      target?.call();
    });
    ThrottleUtil.instance.debounceCache[key] = DebounceData(
      lastCall: now,
      timer: timer,
    );
  }
}

extension FunctionExt on Function {
  VoidCallback throttle() => _FunctionProxy(this).throttle;

  VoidCallback throttleWithTimeout({Duration? timeout}) =>
      _FunctionProxy(this, timeout: timeout).throttleWithTimeout;

  VoidCallback debounce({Duration? timeout}) =>
      _FunctionProxy(this, timeout: timeout).debounce;

  /// 针对future的节流
  /// 推荐在无参数输入的场景下使用
  Future<T> throttleFuture<T>({
    Duration? duration,
    List<Object?> positionalArgs = const [],
    Map<Symbol, Object?> namedArgs = const {},
  }) {
    late final String key;
    if (positionalArgs.isEmpty && namedArgs.isEmpty) {
      key = hashCode.toString();
    } else {
      final keyBuffer = StringBuffer();
      keyBuffer.write(hashCode);
      for (final arg in positionalArgs) {
        keyBuffer.write('_');
        keyBuffer.write(arg.hashCode);
      }
      for (final entry in namedArgs.entries) {
        keyBuffer.write('_');
        keyBuffer.write(entry.key.hashCode);
        keyBuffer.write('_');
        keyBuffer.write(entry.value.hashCode);
      }
      key = keyBuffer.toString();
    }
    final now = DateTime.now();
    final cached = ThrottleUtil.instance.throttleCache[key];

    if (cached != null) {
      if (cached.pendingFuture != null) {
        return cached.pendingFuture as Future<T>;
      }
      if (duration != null && cached.completedFuture != null) {
        if (now.difference(cached.lastCall) < duration) {
          return cached.completedFuture as Future<T>;
        }
      }
    }

    final completer = Completer<T>();
    final future = Function.apply(this, positionalArgs, namedArgs) as Future<T>;
    future
        .then((value) {
          if (!completer.isCompleted) completer.complete(value);
          ThrottleUtil.instance.throttleCache[key] = ThrottleData<T>(
            lastCall: now,
            completedFuture: Future.value(value),
            pendingFuture: null,
            pendingCompleter: null,
          );
          return value;
        })
        .catchError((error) {
          if (!completer.isCompleted) completer.completeError(error);
          ThrottleUtil.instance.throttleCache.remove(key);
          throw error;
        });

    ThrottleUtil.instance.throttleCache[key] = ThrottleData<T>(
      lastCall: now,
      completedFuture: null,
      pendingFuture: future,
      pendingCompleter: completer,
    );

    return completer.future;
  }

  /// 针对future的防抖
  /// 推荐在无参数输入的场景下使用
  Future<T?> debounceFuture<T>({
    required Duration duration,
    List<Object?> positionalArgs = const [],
    Map<Symbol, Object?> namedArgs = const {},
  }) {
    late final String key;
    if (positionalArgs.isEmpty && namedArgs.isEmpty) {
      key = hashCode.toString();
    } else {
      final keyBuffer = StringBuffer();
      keyBuffer.write(hashCode);
      for (final arg in positionalArgs) {
        keyBuffer.write('_');
        keyBuffer.write(arg.hashCode);
      }
      for (final entry in namedArgs.entries) {
        keyBuffer.write('_');
        keyBuffer.write(entry.key.hashCode);
        keyBuffer.write('_');
        keyBuffer.write(entry.value.hashCode);
      }
      key = keyBuffer.toString();
    }
    final now = DateTime.now();

    DebounceData? data = ThrottleUtil.instance.debounceCache[key];
    data?.timer?.cancel();

    final completer = Completer<T?>();

    final timer = Timer(duration, () {
      ThrottleUtil.instance.debounceCache.remove(key);
      final future =
          Function.apply(this, positionalArgs, namedArgs) as Future<T>;
      future
          .then((value) {
            if (!completer.isCompleted) completer.complete(value);
          })
          .catchError((error) {
            if (!completer.isCompleted) completer.completeError(error);
            throw error;
          });
    });

    ThrottleUtil.instance.debounceCache[key] = DebounceData(
      lastCall: now,
      timer: timer,
    );

    return completer.future;
  }
}
