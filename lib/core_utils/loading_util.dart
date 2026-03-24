import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

abstract class LoadingUtil {
  LoadingUtil._();

  static TransitionBuilder init({TransitionBuilder? builder}) {
    return (BuildContext context, Widget? child) {
      if (builder != null) {
        return builder(context, FlutterEasyLoading(child: child));
      } else {
        return FlutterEasyLoading(child: child);
      }
    };
  }

  static void configLoading({
    Duration displayDuration = const Duration(milliseconds: 2000),
    EasyLoadingIndicatorType indicatorType =
        EasyLoadingIndicatorType.fadingCircle,
    EasyLoadingStyle loadingStyle = EasyLoadingStyle.dark,
    double indicatorSize = 45.0,
    double radius = 10.0,
    Color progressColor = Colors.yellow,
    Color backgroundColor = Colors.green,
    Color indicatorColor = Colors.yellow,
    Color textColor = Colors.yellow,
    Color maskColor = Colors.black54,
    bool userInteractions = true,
    bool dismissOnTap = false,
    EasyLoadingMaskType maskType = EasyLoadingMaskType.clear,
    EasyLoadingAnimation? customAnimation,
  }) {
    EasyLoading.instance
      ..displayDuration = displayDuration
      ..indicatorType = indicatorType
      ..loadingStyle = loadingStyle
      ..indicatorSize = indicatorSize
      ..radius = radius
      ..progressColor = progressColor
      ..backgroundColor = backgroundColor
      ..indicatorColor = indicatorColor
      ..textColor = textColor
      ..maskColor = maskColor
      ..userInteractions = userInteractions
      ..dismissOnTap = dismissOnTap
      ..maskType = maskType
      ..customAnimation = customAnimation;
  }

  static bool get isShow => EasyLoading.isShow;

  static Future<void> show() async {
    await EasyLoading.show();
  }

  static Future<void> dismiss() async {
    await EasyLoading.dismiss();
  }

  static Future<void> showProgress(double progress) async {
    await EasyLoading.showProgress(progress);
  }

  static Future<void> showSuccess(String message) async {
    await EasyLoading.showSuccess(message);
  }

  static Future<void> showError(String message) async {
    await EasyLoading.showError(message);
  }

  static Future<void> showInfo(String message) async {
    await EasyLoading.showInfo(message);
  }
}

extension LoadingOnFuture<T> on Future<T> {
  Future<T> withLoading() async {
    try {
      await LoadingUtil.show();
      final result = await this;
      await LoadingUtil.dismiss();
      return result;
    } catch (e) {
      await LoadingUtil.dismiss();
      rethrow;
    }
  }
}
