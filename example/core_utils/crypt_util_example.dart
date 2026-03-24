import 'package:scaffold_core/core_utils/crypt_util.dart';

void main() {
  final text = 'hello world';

  print('MD5: ${text.toMD5()}');
  print('SHA1: ${text.toSH1()}');

  final key = '1234567890123456';
  final encrypted = text.aesEncode(key: key);
  print('AES encrypted: $encrypted');
  final decrypted = encrypted.aesDecode(key: key);
  print('AES decrypted: $decrypted');

  final password = 'MyPassword123!';
  print('Password strength: ${password.passwordStrength.description}');
}
