import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

const int defaultMaxAssetsCount = 9;

/// 拍摄分辨率
enum PickerResolution {
  /// 352x288 on iOS, ~240p on Android and Web
  low,

  /// ~480p
  medium,

  /// ~720p
  high,

  /// ~1080p
  veryHigh,

  /// ~2160p
  ultraHigh,

  /// The highest resolution available.
  max;

  ResolutionPreset get resolutionPreset {
    switch (this) {
      case PickerResolution.low:
        return ResolutionPreset.low;
      case PickerResolution.medium:
        return ResolutionPreset.medium;
      case PickerResolution.high:
        return ResolutionPreset.high;
      case PickerResolution.veryHigh:
        return ResolutionPreset.veryHigh;
      case PickerResolution.ultraHigh:
        return ResolutionPreset.ultraHigh;
      case PickerResolution.max:
        return ResolutionPreset.max;
    }
  }
}

/// 拍照工具类
abstract class AssetsPickerUtil {
  AssetsPickerUtil._();

  /// 相机拍摄
  ///
  /// 包含拍摄图片和录像
  static Future<File?> pickFromCamera(
    BuildContext context, {
    bool canRecording = false,
    bool onlyEnableRecording = false,
    bool shouldDeletePreviewFile = true,
    bool enableAudio = false,
    Duration maximumRecordingDuration = const Duration(seconds: 15),
    PickerResolution resolutionPreset = PickerResolution.high,
    void Function(List<File>)? onCaptured,
    void Function(Object error, StackTrace? stackTrace)? onError,
  }) async {
    AssetEntity? entity = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: CameraPickerConfig(
        enableRecording: canRecording,
        onlyEnableRecording: onlyEnableRecording,
        shouldDeletePreviewFile: shouldDeletePreviewFile,
        enableAudio: false,
        maximumRecordingDuration: maximumRecordingDuration,
        resolutionPreset: resolutionPreset.resolutionPreset,
        imageFormatGroup: ImageFormatGroup.jpeg,
        permissionRequestOption: PermissionRequestOption(),
        onError: onError,
      ),
    );

    /// 输出图片
    return entity?.file;
  }

  /// 从相册获取
  ///
  ///
  static Future<List<File>> pickFromGallery(
    BuildContext context, {
    int maxAssets = defaultMaxAssetsCount,
    bool canRecording = false,
  }) async {
    List<AssetEntity>? entities = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxAssets,
        requestType: canRecording ? RequestType.common : RequestType.image,
      ),
    );

    // 并行处理所有实体，提升性能
    final futures = (entities ?? []).map((entity) async {
      File? file = await entity.file;
      if (file == null) return null;

      // 检查文件名扩展
      if (file.extension.isEmpty) {
        file = await file.rename(file.path + entity.type.suffix);
      }
      return file;
    });

    // 等待所有操作完成，过滤掉null值
    return (await Future.wait(futures)).whereType<File>().toList();
  }
}

extension _AssetTypeExtension on AssetType {
  String get suffix {
    switch (this) {
      case AssetType.image:
        return '.jpg';
      case AssetType.video:
        return '.mp4';
      case AssetType.audio:
        return '.mp3';
      case AssetType.other:
        return '';
    }
  }
}

extension _FileExtension on File {
  /// 获取文件扩展名
  String get extension {
    final dotIndex = path.lastIndexOf('.');
    final slashIndex = path.lastIndexOf(Platform.pathSeparator);
    if (dotIndex == -1 || slashIndex >= dotIndex) {
      return '';
    }
    return path.substring(dotIndex + 1);
  }
}
