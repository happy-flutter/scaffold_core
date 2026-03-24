/// 函数与异步工具扩展集合
import 'dart:async';

/// Future 常用扩展
extension FutureMinDuration<T> on Future<T> {
  /// 确保 Future 至少执行指定时间
  Future<T> withMinDuration(Duration minDuration) async {
    final results = await Future.wait([
      this,
      Future<void>.delayed(minDuration),
    ]);
    return results.first as T;
  }

  /// 确保 Future 至少执行指定秒数
  Future<T> withMinSeconds(int seconds) =>
      withMinDuration(Duration(seconds: seconds));

  /// 确保 Future 至少执行指定毫秒数
  Future<T> withMinMilliseconds(int milliseconds) =>
      withMinDuration(Duration(milliseconds: milliseconds));

  /// 超时处理
  Future<T> withTimeout(Duration timeout, {T? fallback}) {
    return this.timeout(
      timeout,
      onTimeout: () {
        if (fallback != null) return fallback;
        throw TimeoutException('Future did not complete in $timeout');
      },
    );
  }

  /// 错误捕获，返回默认值
  Future<T> catchErrorReturn(T defaultValue) {
    return this.catchError((error) => defaultValue);
  }

  /// 延迟执行
  Future<T> delayed(Duration duration) async {
    await Future.delayed(duration);
    return this;
  }
}
