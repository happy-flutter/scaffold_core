import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';

enum LinkLaunchMode {
  /// Leaves the decision of how to launch the URL to the platform
  /// implementation.
  platformDefault,

  /// Loads the URL in an in-app web view (e.g., Android WebView).
  inAppWebView,

  /// Loads the URL in an in-app web view (e.g., Android Custom Tabs, SFSafariViewController).
  inAppBrowserView,

  /// Passes the URL to the OS to be handled by another application.
  externalApplication,

  /// Passes the URL to the OS to be handled by another non-browser application.
  externalNonBrowserApplication;

  LaunchMode get toLaunchMode {
    switch (this) {
      case LinkLaunchMode.platformDefault:
        return LaunchMode.platformDefault;
      case LinkLaunchMode.inAppWebView:
        return LaunchMode.inAppWebView;
      case LinkLaunchMode.inAppBrowserView:
        return LaunchMode.inAppBrowserView;
      case LinkLaunchMode.externalApplication:
        return LaunchMode.externalApplication;
      case LinkLaunchMode.externalNonBrowserApplication:
        return LaunchMode.externalNonBrowserApplication;
    }
  }
}

abstract class LinkUtil {
  static final _appLinks = AppLinks();

  static Stream<Uri> get appLinkStream => _appLinks.uriLinkStream;

  /// 打开系统设置
  static Future<void> openAppSettings() async =>
      await AppSettings.openAppSettings();

  /// 检测链接是否可以打开
  static Future<bool> canOpenUri(Uri uri) async {
    return await canLaunchUrl(uri);
  }

  /// 打开url链接
  static Future<void> openUri(
    Uri uri, {
    bool checkCanLaunch = false,
    LinkLaunchMode mode = LinkLaunchMode.platformDefault,
  }) async {
    if (checkCanLaunch && !await canOpenUri(uri)) {
      return;
    }

    await launchUrl(uri, mode: mode.toLaunchMode);
  }

  /// 获取收到的链接
  static Future<Uri?> getInitialLink() async {
    // Get the initial/first link.
    // This is useful when app was terminated (i.e. not started)
    return await _appLinks.getInitialLink();
  }

  /// 获取最新的链接
  static Future<Uri?> getLatestLink() async {
    return await _appLinks.getLatestLink();
  }
}
