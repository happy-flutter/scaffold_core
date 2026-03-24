import 'package:scaffold_core/core_extensions/future_extension.dart';

void main() async {
  final result = await Future.delayed(
    Duration(milliseconds: 100),
    () => 'data',
  ).withMinDuration(Duration(seconds: 1));

  print(result);

  final timedOut = await Future.delayed(
    Duration(seconds: 5),
    () => 'slow data',
  ).withTimeout(Duration(seconds: 2), fallback: 'timeout');

  print(timedOut);
}
