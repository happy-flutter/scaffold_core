import 'dart:io';
import 'package:scaffold_core/core_utils/video_compress_util.dart';

void main() async {
  final File videoFile = File('path/to/video.mp4');
  
  final estimate = await VideoCompressUtil.estimateCompressed(
    videoFile.path,
    quality: VideoCompressQuality.medium,
  );
  
  print('Estimated compression ratio: ${estimate?.compressionRatio}');
  print('Estimated size: ${estimate?.estimatedSizeFormatted}');
  
  final result = await VideoCompressUtil.compressVideo(
    videoFile.path,
    config: const VideoCompressConfig.medium(),
  );
  
  print('Compressed path: ${result?.compressedFilePath}');
  print('Compression ratio: ${result?.compressionRatio.toStringAsFixed(2)}');
  print('Space saved: ${result?.spaceSaved} bytes');
  
  final thumbnails = await VideoCompressUtil.getThumbnail(
    videoFile.path,
    timeMs: [1000, 3000, 5000],
    maxWidth: 300,
  );
  
  print('Generated ${thumbnails.length} thumbnails');
  
  final subscription = VideoCompressUtil.compressProgressListener((event) {
    print('Compression progress: ${event.progress * 100}%');
  });
  
  subscription.cancel();
}
