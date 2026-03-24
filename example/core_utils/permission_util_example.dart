import 'package:scaffold_core/core_utils/permission_util.dart';

void main() async {
  final status = await PermissionType.camera.request();
  print('Camera permission: ${status.description}');
  
  if (status.isGranted) {
    print('Camera permission granted');
  } else if (status.isDenied) {
    print('Camera permission denied');
  }
  
  final result = await PermissionUtil.requestPermissionList([
    PermissionType.camera,
    PermissionType.photos,
    PermissionType.location,
  ]);
  
  result.forEach((permission, status) {
    print('${permission.name}: ${status.description}');
  });
}
