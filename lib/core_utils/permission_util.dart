import 'package:permission_handler/permission_handler.dart';

/// 系统服务状态
enum ServiceStatusType {
  /// The service for the permission is disabled.
  disabled(ServiceStatus.disabled, 'disabled', '已开启'),

  /// The service for the permission is enabled.
  enabled(ServiceStatus.enabled, 'enabled', '关闭'),

  /// The permission does not have an associated service on the current
  /// platform.
  notApplicable(ServiceStatus.notApplicable, 'notApplicable', '不适用');

  final ServiceStatus rawType;

  final String name;

  final String description;

  const ServiceStatusType(this.rawType, this.name, this.description);

  bool get isEnabled => rawType == ServiceStatus.enabled;

  bool get isDisabled => rawType == ServiceStatus.disabled;

  static ServiceStatusType fromRawType(ServiceStatus status) {
    return ServiceStatusType.values.firstWhere(
      (e) => e.rawType == status,
      orElse: () => ServiceStatusType.notApplicable,
    );
  }
}

/// 权限状态
enum PermissionStatusType {
  /// The user denied access to the requested feature, permission needs to be
  /// asked first.
  denied(PermissionStatus.denied, 'denied', '拒绝'),

  /// The user granted access to the requested feature.
  granted(PermissionStatus.granted, 'granted', '已开启'),

  /// The OS denied access to the requested feature. The user cannot change
  /// this app's status, possibly due to active restrictions such as parental
  /// controls being in place.
  ///
  /// *Only supported on iOS.*
  restricted(PermissionStatus.restricted, 'restricted', '限制'),

  /// The user has authorized this application for limited access. So far this
  /// is only relevant for the Photo Library picker.
  ///
  /// *Only supported on iOS (iOS14+).*
  limited(PermissionStatus.limited, 'limited', '限制'),

  /// Permission to the requested feature is permanently denied, the permission
  /// dialog will not be shown when requesting this permission. The user may
  /// still change the permission status in the settings.
  ///
  /// *On Android:*
  /// Android 11+ (API 30+): whether the user denied the permission for a second
  /// time.
  /// Below Android 11 (API 30): whether the user denied access to the requested
  /// feature and selected to never again show a request.
  ///
  /// *On iOS:*
  /// If the user has denied access to the requested feature.
  permanentlyDenied(
    PermissionStatus.permanentlyDenied,
    'permanentlyDenied',
    '永久拒绝',
  ),

  /// The application is provisionally authorized to post non-interruptive user
  /// notifications.
  ///
  /// *Only supported on iOS (iOS12+).*
  provisional(PermissionStatus.provisional, 'provisional', '临时授权');

  final PermissionStatus rawType;

  final String name;

  final String description;

  const PermissionStatusType(this.rawType, this.name, this.description);

  bool get isDenied => rawType == PermissionStatus.denied;

  bool get isGranted => rawType == PermissionStatus.granted;

  bool get isRestricted => rawType == PermissionStatus.restricted;

  static PermissionStatusType fromRawType(PermissionStatus status) {
    return PermissionStatusType.values.firstWhere(
      (e) => e.rawType == status,
      orElse: () => PermissionStatusType.denied,
    );
  }
}

/// 权限类型
enum PermissionType {
  camera(1, 'camera', '相机', Permission.camera),

  location(3, 'location', '位置', Permission.location),

  microphone(7, 'microphone', '麦克风', Permission.microphone),

  phone(8, 'phone', '电话', Permission.phone),

  photos(9, 'photos', '照片', Permission.photos),

  storage(15, 'storage', '存储', Permission.storage),

  notification(17, 'notification', '通知', Permission.notification),

  requestInstallPackages(
    24,
    'requestInstallPackages',
    '请求安装包',
    Permission.requestInstallPackages,
  ),

  unknown(20, 'unknown', '未知', Permission.unknown);

  final int value;

  final String name;

  final String description;

  final Permission rawType;

  const PermissionType(this.value, this.name, this.description, this.rawType);

  static PermissionType fromRawType(Permission rawType) {
    return PermissionType.values.firstWhere(
      (e) => e.rawType == rawType,
      orElse: () => PermissionType.unknown,
    );
  }
}

extension PermissionTypeExtension on PermissionType {

  Future<PermissionStatusType> request() async =>
      await PermissionUtil.requestPermission(this);

  Future<ServiceStatusType> serviceStatus() async =>
      await PermissionUtil.checkServiceStatus(this);

}

/// 权限工具类
abstract class PermissionUtil {
  PermissionUtil._();

  /// 检查权限状态
  static Future<PermissionStatusType> checkPermission(
    PermissionType permissonType,
  ) async {
    PermissionStatus status = await permissonType.rawType.status;
    return PermissionStatusType.fromRawType(status);
  }

  /// 请求权限
  static Future<PermissionStatusType> requestPermission(
    PermissionType permissonType,
  ) async {
    PermissionStatus status = await permissonType.rawType.request();
    return PermissionStatusType.fromRawType(status);
  }

  /// 批量请求权限
  static Future<Map<PermissionType, PermissionStatusType>>
  requestPermissionList(List<PermissionType> permissonTypeList) async {
    Map<Permission, PermissionStatus> res = await permissonTypeList
        .map((e) => e.rawType)
        .toList()
        .request();

    return res.map(
      (key, value) => MapEntry(
        PermissionType.fromRawType(key),
        PermissionStatusType.fromRawType(value),
      ),
    );
  }

  /// 检查系统服务状态
  static Future<ServiceStatusType> checkServiceStatus(
    PermissionType permissonType,
  ) async {
    ServiceStatus status =
        await (permissonType.rawType as PermissionWithService).serviceStatus;
    return ServiceStatusType.fromRawType(status);
  }

  /// 打开系统设置--app设置页面
  // static Future<void> openAppSettings() async {
  //   await openAppSettings();
  // }
}
