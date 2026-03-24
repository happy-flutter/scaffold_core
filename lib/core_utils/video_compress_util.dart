import 'dart:async';

import 'package:v_video_compressor/v_video_compressor.dart';

/// 视频压缩进度回调事件
class VideoCompressEvent extends VVideoProgressEvent {
  const VideoCompressEvent({
    required super.progress,
    super.videoPath,
    super.currentIndex,
    super.total,
    super.compressionId,
  });
}

/// 视频压缩质量
enum VideoCompressQuality {
  high('HIGH', '1080p HD', 'High quality with better file size'),
  medium('MEDIUM', '720p', 'Balanced quality and compression'),
  low('LOW', '480p', 'Good compression for sharing'),
  veryLow('VERY_LOW', '360p', 'High compression, smaller files'),
  ultraLow('ULTRA_LOW', '240p', 'Maximum compression, smallest files');

  const VideoCompressQuality(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  VVideoCompressQuality toVVideoCompressQuality() {
    switch (this) {
      case VideoCompressQuality.high:
        return VVideoCompressQuality.high;
      case VideoCompressQuality.medium:
        return VVideoCompressQuality.medium;
      case VideoCompressQuality.low:
        return VVideoCompressQuality.low;
      case VideoCompressQuality.veryLow:
        return VVideoCompressQuality.veryLow;
      case VideoCompressQuality.ultraLow:
        return VVideoCompressQuality.ultraLow;
    }
  }
}

/// 视频压缩配置
class VideoCompressConfig extends VVideoCompressionConfig {
  VideoCompressConfig({
    required super.quality,
    super.advanced,
    super.outputPath,
    super.deleteOriginal,
    super.saveToGallery,
    super.includeAudio,
    super.includeMetadata,
    super.optimizeForStreaming,
    super.useHardwareAcceleration,
    super.useFastStart,
    super.useTwoPassEncoding,
    super.useVariableBitrate,
    super.copyMetadata,
  });

  const VideoCompressConfig.high() : super(quality: VVideoCompressQuality.high);

  const VideoCompressConfig.medium()
    : super(quality: VVideoCompressQuality.medium);

  const VideoCompressConfig.low() : super(quality: VVideoCompressQuality.low);

  const VideoCompressConfig.veryLow()
    : super(quality: VVideoCompressQuality.veryLow);

  const VideoCompressConfig.ultraLow()
    : super(quality: VVideoCompressQuality.ultraLow);

  VideoCompressConfig copyWith({
    VVideoCompressQuality? quality,
    VideoCompressAdvancedConfig? advanced,
    String? outputPath,
    bool? deleteOriginal,
    bool? saveToGallery,
  }) => VideoCompressConfig(
    quality: quality ?? this.quality,
    advanced: advanced ?? this.advanced,
    outputPath: outputPath ?? this.outputPath,
    deleteOriginal: deleteOriginal ?? this.deleteOriginal,
    saveToGallery: saveToGallery ?? this.saveToGallery,
  );
}

/// 视频压缩进阶配置
class VideoCompressAdvancedConfig extends VVideoAdvancedConfig {
  // final advancedConfig = VVideoAdvancedConfig(
  //   // Resolution & Quality
  //   customWidth: 1280,
  //   customHeight: 720,
  //   videoBitrate: 2000000, // 2 Mbps
  //   frameRate: 30.0, // 30 FPS
  //   // Codec & Encoding
  //   videoCodec: VVideoCodec.h265, // Better compression
  //   audioCodec: VAudioCodec.aac,
  //   encodingSpeed: VEncodingSpeed.medium,
  //   crf: 25, // Quality factor (lower = better)
  //   twoPassEncoding: true, // Better quality
  //   hardwareAcceleration: true, // Use GPU
  //   // Audio Settings
  //   audioBitrate: 128000, // 128 kbps
  //   audioSampleRate: 44100, // 44.1 kHz
  //   audioChannels: 2, // Stereo
  //   // Video Effects
  //   brightness: 0.1, // Slight brightness boost
  //   contrast: 0.05, // Slight contrast increase
  //   saturation: 0.1, // Slight saturation increase
  //   // Editing
  //   trimStartMs: 2000, // Skip first 2 seconds
  //   trimEndMs: 60000, // End at 1 minute
  //   rotation: 90, // Rotate 90 degrees
  // );

  factory VideoCompressAdvancedConfig.maxCompression({
    int? targetBitrate,
    bool keepAudio = false,
  }) =>
      VVideoAdvancedConfig.maximumCompression(
            targetBitrate: targetBitrate,
            keepAudio: keepAudio,
          )
          as VideoCompressAdvancedConfig;

  factory VideoCompressAdvancedConfig.socialMediaOptimized() =>
      VVideoAdvancedConfig.socialMediaOptimized()
          as VideoCompressAdvancedConfig;

  factory VideoCompressAdvancedConfig.mobileOptimized() =>
      VVideoAdvancedConfig.mobileOptimized() as VideoCompressAdvancedConfig;
}

/// 视频压缩结果
class VideoCompressionResult extends VVideoCompressionResult {
  VideoCompressionResult({
    required super.originalVideo,
    required super.compressedFilePath,
    required super.originalSizeBytes,
    required super.compressedSizeBytes,
    required super.compressionRatio,
    required super.timeTaken,
    required super.quality,
    required super.originalResolution,
    required super.compressedResolution,
    required super.spaceSaved,
  });

  factory VideoCompressionResult._fromResult(VVideoCompressionResult result) =>
      VideoCompressionResult(
        originalVideo: result.originalVideo,
        compressedFilePath: result.compressedFilePath,
        originalSizeBytes: result.originalSizeBytes,
        compressedSizeBytes: result.compressedSizeBytes,
        compressionRatio: result.compressionRatio,
        timeTaken: result.timeTaken,
        quality: result.quality,
        originalResolution: result.originalResolution,
        compressedResolution: result.compressedResolution,
        spaceSaved: result.spaceSaved,
      );
}

/// 视频预估压缩结果
class VideoCompressionEstimate extends VVideoCompressionEstimate {
  const VideoCompressionEstimate({
    required super.estimatedSizeFormatted,
    required super.compressionRatio,
    required super.bitrateMbps,
    required super.estimatedSizeBytes,
  });

  factory VideoCompressionEstimate.fromEstimate(
    VVideoCompressionEstimate estimate,
  ) => VideoCompressionEstimate(
    estimatedSizeFormatted: estimate.estimatedSizeFormatted,
    compressionRatio: estimate.compressionRatio,
    bitrateMbps: estimate.bitrateMbps,
    estimatedSizeBytes: estimate.estimatedSizeBytes,
  );
}

/// 视频压缩工具类
/// 使用v_video_compressor库进行视频压缩
class VideoCompressUtil {
  VideoCompressUtil._();

  static VVideoCompressor? _compressor;
  static VVideoCompressor get compressor => _compressor ??= VVideoCompressor();

  static StreamController<VideoCompressEvent>? _videoCompressEventController;

  /// 压缩视频
  ///
  /// [videoPath] 视频路径
  /// [config] 视频压缩配置
  /// [advancedConfig] 视频压缩进阶配置
  /// [id] 视频压缩id
  /// [onProgress] 视频压缩进度回调
  static Future<VideoCompressionResult?> compressVideo(
    String videoPath, {
    VideoCompressConfig config = const VideoCompressConfig.medium(),
    VideoCompressAdvancedConfig? advancedConfig,
    String? id,
    void Function(double progress)? onProgress,
  }) async {
    final compressionResult = await compressor.compressVideo(
      videoPath,
      config.copyWith(advanced: advancedConfig),
      id: id,
      onProgress: onProgress,
    );

    if (compressionResult == null) {
      return null;
    }

    return VideoCompressionResult._fromResult(compressionResult);
  }

  /// 取消视频压缩
  static Future<void> cancelCompression() async =>
      await compressor.cancelCompression();

  /// 检查视频压缩是否正在进行
  static Future<bool> isCompressing() async => await compressor.isCompressing();

  /// 获取缩略图
  ///
  /// [videoPath] 视频路径
  /// [timeMs] 时间戳列表
  /// [maxWidth] 最大宽度
  static Future<List<String>> getThumbnail(
    String videoPath, {
    List<int> timeMs = const [5000],
    int maxWidth = 150,
  }) async {
    final thumbnails = await compressor.getVideoThumbnails(
      videoPath,
      List<VVideoThumbnailConfig>.from(
        timeMs.map((e) => VVideoThumbnailConfig(timeMs: e, maxWidth: maxWidth)),
      ),
    );

    return thumbnails.map((e) => e.thumbnailPath).toList();
  }

  /// 预估视频压缩结果
  static Future<VideoCompressionEstimate?> estimateCompressed(
    String videoPath, {
    VideoCompressQuality quality = VideoCompressQuality.medium,
    VideoCompressAdvancedConfig? advancedConfig,
  }) async {
    final estimate = await compressor.getCompressionEstimate(
      videoPath,
      quality.toVVideoCompressQuality(),
      advanced: advancedConfig, // Optional
    );

    return estimate != null
        ? VideoCompressionEstimate.fromEstimate(estimate)
        : null;
  }

  /// Simple progress callback
  static void listenToProgress(
    onProgress, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => VVideoCompressor.listenToProgress(
    onProgress,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  /// Batch progress callback
  static void listenToBatchProgress(
    void Function(double progress, int currentIndex, int total) onBatchProgress,
  ) => VVideoCompressor.listenToBatchProgress(onBatchProgress);

  /// Full event callback
  static void listen(void Function(VideoCompressEvent event) onEvent) =>
      VideoCompressUtil.compressProgressListener(onEvent);

  /// 添加全局视频压缩进度监听
  ///
  /// [onData] 视频压缩进度回调
  static StreamSubscription<VideoCompressEvent> compressProgressListener(
    void Function(VideoCompressEvent event) onData,
  ) {
    if (_videoCompressEventController == null) {
      _videoCompressEventController = StreamController.broadcast();

      VVideoCompressor.progressStream.listen((VVideoProgressEvent event) {
        _videoCompressEventController!.sink.add(
          VideoCompressEvent(
            progress: event.progress,
            videoPath: event.videoPath,
            currentIndex: event.currentIndex,
            total: event.total,
            compressionId: event.compressionId,
          ),
        );
      });
    }

    // 创建一个用于监听视频压缩进度的订阅器
    return _videoCompressEventController!.stream.listen(onData);
  }
}
