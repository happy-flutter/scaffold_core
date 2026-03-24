import 'package:flutter/material.dart';
import 'package:scaffold_core/core_utils/image_util.dart';

void main() {
  Widget imageWidget = ImageUtil.network(
    'https://example.com/image.jpg',
    width: 200,
    height: 200,
  );

  print('Network image widget created: $imageWidget');

  final provider = ImageUtil.networkProvider(
    'https://example.com/image.jpg',
    size: Size(200, 200),
  );

  print('Image provider: $provider');

  Widget assetImage = ImageUtil.asset(
    'assets/images/icon.svg',
    width: 24,
    height: 24,
    color: Colors.blue,
  );

  print('SVG asset created: $assetImage');
}
