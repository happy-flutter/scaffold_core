import 'package:flutter/material.dart';
import 'package:scaffold_core/core_extensions/color_extension.dart';

void main() {
  final color = Color(0xFF1E88E5);
  
  print('Hex: ${color.toHex}');
  print('IsDark: ${color.isDark}');
  print('Brighter: ${color.brighten(0.2)}');
  
  final random = randomColor(opacity: 0.8);
  print('Random color: ${random.toHex}');
  
  final fromHex = colorFromHex('#FF5733');
  print('From hex: $fromHex');
}
