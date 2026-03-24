import 'dart:core';
import 'package:scaffold_core/core_utils/link_util.dart';

void main() async {
  final uri = Uri.parse('https://flutter.dev');
  await LinkUtil.openUri(uri);

  final canOpen = await LinkUtil.canOpenUri(uri);
  print('Can open: $canOpen');

  await LinkUtil.openAppSettings();

  final initialLink = await LinkUtil.getInitialLink();
  print('Initial link: $initialLink');

  LinkUtil.appLinkStream.listen((uri) {
    print('Received deep link: $uri');
  });
}
