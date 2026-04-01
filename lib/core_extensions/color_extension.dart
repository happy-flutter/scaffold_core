// 颜色工具与扩展方法集合
// 提供随机颜色、十六进制/RGB/HSL 构造与转换，以及对 `Color` 的亮度、饱和度、色相、混色与灰度等便捷操作。

import 'dart:math';

import 'package:flutter/material.dart';

/// 全局函数：生成随机颜色
/// [opacity] 透明度 0.0 - 1.0
Color randomColor({double opacity = 1.0}) {
  Random random = Random();
  return Color.fromARGB(
    (opacity * 255).toInt(),
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

/// 全局函数：从十六进制字符串创建颜色
Color colorFromHex(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex'; // 添加不透明度
  }
  return Color(int.parse(hex, radix: 16));
}

/// 全局函数：从RGB值创建颜色
Color colorFromRgb(int red, int green, int blue, [int alpha = 255]) {
  return Color.fromARGB(alpha, red, green, blue);
}

/// 全局函数：从HSL值创建颜色
Color colorFromHsl(
  double hue,
  double saturation,
  double lightness, [
  double alpha = 1.0,
]) {
  return HSLColor.fromAHSL(alpha, hue, saturation, lightness).toColor();
}

/// Color扩展
extension ColorExtension on Color {
  int get alpha => (a * 255.0).round();
  int get red => (r * 255.0).round();
  int get green => (g * 255.0).round();
  int get blue => (b * 255.0).round();

  /// 颜色转十六进制字符串
  String get toHex {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// 颜色转十六进制字符串（带透明度）
  String get toHexWithAlpha {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0')}';
  }

  /// 判断颜色是否为深色
  bool get isDark {
    return computeLuminance() < 0.5;
  }

  /// 判断颜色是否为浅色
  bool get isLight => !isDark;

  /// 获取反色
  Color get inverted {
    return Color.fromARGB(
      alpha, // 保持原透明度
      255 - red, // 红色反转
      255 - green, // 绿色反转
      255 - blue, // 蓝色反转
    );
  }

  /// 调整亮度 (-1.0 到 1.0)
  Color brighten([double amount = 0.1]) {
    assert(amount >= -1.0 && amount <= 1.0);

    final hsl = HSLColor.fromColor(this);
    final lightness = max(0.0, min(1.0, hsl.lightness + amount));

    return hsl.withLightness(lightness).toColor();
  }

  /// 调整饱和度 (-1.0 到 1.0)
  Color saturate([double amount = 0.1]) {
    assert(amount >= -1.0 && amount <= 1.0);

    final hsl = HSLColor.fromColor(this);
    final saturation = max(0.0, min(1.0, hsl.saturation + amount));

    return hsl.withSaturation(saturation).toColor();
  }

  /// 调整色调 (0.0 到 1.0)
  Color rotateHue(double amount) {
    final hsl = HSLColor.fromColor(this);
    final hue = (hsl.hue + (amount * 360)) % 360;

    return hsl.withHue(hue).toColor();
  }

  /// 混合两种颜色
  Color mix(Color other, [double amount = 0.5]) {
    assert(amount >= 0.0 && amount <= 1.0);

    return Color.fromARGB(
      (alpha + ((other.a * 255.0).round() - alpha) * amount).round(),
      (red + ((other.r * 255.0).round() - red) * amount).round(),
      (green + ((other.g * 255.0).round() - green) * amount).round(),
      (blue + ((other.b * 255.0).round() - blue) * amount).round(),
    );
  }

  /// 设置透明度 (0.0 到 1.0)
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }

  /// 转换为灰度
  Color get grayscale {
    final gray = (0.299 * red + 0.587 * green + 0.114 * blue).round();
    return Color.fromARGB(alpha, gray, gray, gray);
  }
}
