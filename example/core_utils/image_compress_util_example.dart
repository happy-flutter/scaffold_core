import 'dart:io';
import 'package:scaffold_core/core_utils/image_compress_util.dart';

void main() async {
  final File imageFile = File('path/to/image.jpg');

  final compressedBytes = await ImageCompressUtil.compressFromFile(
    imageFile.path,
    minWidth: 1080,
    minHeight: 1080,
    quality: 85,
  );

  print('Compressed bytes length: ${compressedBytes?.length}');

  final result = await ImageCompressUtil.compressFromFiletoXFile(
    imageFile.path,
    'output/compressed.jpg',
    minWidth: 1080,
    quality: 85,
  );

  print('Compressed file: ${result?.path}');
}
