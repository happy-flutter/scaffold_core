import 'package:scaffold_core/core_utils/storage_util.dart';

void main() async {
  await StorageUtil.init();
  
  await StorageUtil.setValue('username', 'john');
  await StorageUtil.setValue('age', 25);
  await StorageUtil.setValue('loggedIn', true);
  
  final username = StorageUtil.getValue('username');
  final age = StorageUtil.getValue('age');
  print('Username: $username, age: $age');
  
  await StorageUtil.setObject('user', {'name': 'John', 'age': 30});
  final user = StorageUtil.getObject('user');
  print('User object: $user');
  
  print('Has key "username": ${StorageUtil.hasKey('username')}');
  
  final cacheSize = await StorageUtil.totalSizeString();
  print('Cache size: $cacheSize');
  
  final tempDir = await StorageUtil.tempDirectory;
  print('Temp directory: $tempDir');
}
