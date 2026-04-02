import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 基于shared_preferences的存储工具类
abstract class StorageUtil {
  StorageUtil._();

  static SharedPreferences? _innerInstance;

  static SharedPreferences get _storageInstance =>
      _innerInstance == null
          ? throw Exception(
            'storageInstance can not be null,pls call init() first',
          )
          : _innerInstance!;

  /// 初始化
  ///
  /// 请在使用存储方法前调用此方法，否则会报错
  static Future<void> init() async {
    _innerInstance ??= await SharedPreferences.getInstance();
  }

  /// Set Value
  ///
  /// 存储基础数据类型
  static Future<bool> setValue(String key, dynamic value) async {
    if (value == null) {
      return false;
    } else if (value is String) {
      return await _storageInstance.setString(key, value);
    } else if (value is int) {
      return await _storageInstance.setInt(key, value);
    } else if (value is bool) {
      return await _storageInstance.setBool(key, value);
    } else if (value is double) {
      return await _storageInstance.setDouble(key, value);
    } else {
      return false;
    }
  }

  /// Get value
  ///
  /// 提取基础数据类型
  static dynamic getValue(String key) {
    return _storageInstance.get(key);
  }

  /// Set Object
  static Future<bool> setObject(String key, dynamic value) async {
    if (value == null) return false;

    if (value is Map || value is List) {
      try {
        value = jsonEncode(value);
        return await _storageInstance.setString(key, value);
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// Get Object
  static dynamic getObject(String key) {
    dynamic value = _storageInstance.get(key);
    try {
      dynamic jsonObj = jsonDecode(value);
      if (jsonObj is Map || jsonObj is List) {
        return jsonObj;
      }
    } catch (e) {
      return value;
    }
  }

  /// Returns true if persistent storage the contains the given [key].
  static bool hasKey(String key) {
    return _storageInstance.containsKey(key);
  }

  /// Remove value for [key]
  static Future<bool> removeValue(String key) async {
    return await _storageInstance.remove(key);
  }

  /// Remove all key-value data
  static Future<bool> clear() async {
    return await _storageInstance.clear();
  }

  /// Get all keys in storage
  static Set<String> getKeys() {
    return _storageInstance.getKeys();
  }

  /// 下载目录
  static Future<String?> get downloadsDir async {
    try {
      final Directory? downloadsDir = await getDownloadsDirectory();
      return downloadsDir?.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取下载目录失败: $e');
      }
      return null;
    }
  }

  /// 文档目录
  static Future<String> get documentsDir async {
    String path = '';
    try {
      Directory documentsDir = await getApplicationDocumentsDirectory();
      path = documentsDir.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取文档目录失败: $e');
      }
    }
    return path;
  }

  /// 临时目录
  static Future<String> get tempDirectory async {
    String path = '';
    try {
      Directory tempDir = await getTemporaryDirectory();
      path = tempDir.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取临时目录失败: $e');
      }
    }
    return path;
  }

  /// 缓存目录
  static Future<String?> get cacheDirectory async {
    String? path;
    try {
      Directory cacheDir = await getApplicationCacheDirectory();
      path = cacheDir.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取缓存目录失败: $e');
      }
    } finally {}
    return path;
  }

  /// 缓存总大小
  static Future<int> totalSize() async {
    int totalSize = 0;
    Directory tempDir = await getTemporaryDirectory();
    Directory cacheDir = await getApplicationCacheDirectory();

    /// 计算缓存目录和临时目录的大小
    totalSize += !await tempDir.exists() ? 0 : await _computeSize(tempDir);
    totalSize += !await cacheDir.exists() ? 0 : await _computeSize(cacheDir);
    return totalSize;
  }

  /// 缓存总大小，格式化输出
  static Future<String> totalSizeString() async =>
      _formatSize(await totalSize());

  /// 清除缓存
  static Future<bool> clean() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final Directory cacheDir = await getApplicationCacheDirectory();

      // 检查目录是否存在
      final bool tempExists = await tempDir.exists();
      final bool cacheExists = await cacheDir.exists();

      if (!tempExists && !cacheExists) {
        return true; // 两个目录都不存在，认为清理成功
      }

      // 并发清理两个目录
      final List<Future<bool>> cleanTasks = [];

      if (tempExists) {
        cleanTasks.add(_cleanDirectory(tempDir));
      }

      if (cacheExists) {
        cleanTasks.add(_cleanDirectory(cacheDir));
      }

      // 等待所有清理任务完成
      final List<bool> results = await Future.wait(cleanTasks);

      // 所有任务都成功才算成功
      return results.every((result) => result);
    } catch (e) {
      // 记录错误日志
      if (kDebugMode) {
        debugPrint('清理缓存时发生错误: $e');
      }
      return false;
    }
  }

  /// 清理单个目录
  static Future<bool> _cleanDirectory(Directory directory) async {
    try {
      if (!await directory.exists()) {
        return true;
      }

      // 获取目录中的所有文件和子目录
      final List<FileSystemEntity> entities = await directory.list().toList();

      if (entities.isEmpty) {
        return true; // 目录为空，无需清理
      }

      // 并发删除所有文件和目录
      final List<Future<void>> deleteTasks =
          entities.map((entity) async {
            try {
              await entity.delete(recursive: true);
            } catch (e) {
              // 单个文件删除失败不应该影响整体清理
              if (kDebugMode) {
                debugPrint('删除文件失败: ${entity.path}, 错误: $e');
              }
            }
          }).toList();

      await Future.wait(deleteTasks);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('清理目录失败: ${directory.path}, 错误: $e');
      }
      return false;
    }
  }

  /// 计算缓存大小
  static Future<int> _computeSize(final FileSystemEntity file) async {
    int total = 0;

    /// 如果是文件，返回文件大小
    if (file is File) {
      total = await file.length();
    }

    /// 如果是目录，遍历目录计算大小
    if (file is Directory) {
      final Stream files = file.list(recursive: true);

      await for (FileSystemEntity file in files) {
        if (file is File) total += await file.length();
      }
    }

    return total;
  }

  /// 格式化缓存大小输出
  /// example:
  /// '323 B'、'1.22 MB'、'223 KB'
  static String _formatSize(int size) {
    const List<String> formatList = ['B', 'KB', 'MB', 'GB'];

    double formattedSize = size.toDouble();
    int index = 0;

    while (formattedSize > 1024) {
      index++;
      formattedSize = formattedSize / 1024;
    }

    return '${formattedSize.toStringAsFixed(index > 1 ? 2 : 0)} ${formatList[index]}';
  }
}
