import 'package:scaffold_core/core_extensions/string_extension.dart';

void main() {
  final phone = '13800138000';
  print('Is mobile exact: ${phone.isMobileExact()}');

  final email = 'test@example.com';
  print('Is email: ${email.isEmail()}');

  final idCard = '110101199001011234';
  print('Is ID card: ${idCard.isIDCard()}');

  final amount = '1234.56';
  print('Money format: ${amount.toMoneyFormat()}');
  print('CNY format: ${amount.toCNYFormat}');

  final text = 'hello_world';
  print('CamelCase: ${text.toCamelCase}');
  print('PascalCase: ${text.toPascalCase}');
  print('SnakeCase: ${'HelloWorld'.toSnakeCase}');

  final random = generateRandomString(10);
  print('Random string: $random');

  final chineseText = '你好世界';
  print('Display width: ${chineseText.displayWidth}');
}
