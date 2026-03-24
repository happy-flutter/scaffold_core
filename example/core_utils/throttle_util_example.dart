import 'package:scaffold_core/core_utils/throttle_util.dart';

void main() {
  ThrottleUtil.init();

  void onButtonClick() {
    print('Button clicked at ${DateTime.now()}');
  }

  final throttled = onButtonClick.throttleWithTimeout(
    timeout: Duration(milliseconds: 500),
  );

  throttled();
  throttled();
  throttled();

  final debounced = onButtonClick.debounce(
    timeout: Duration(milliseconds: 500),
  );
  debounced();
  debounced();
  debounced();

  print('Cached: ${ThrottleUtil.instance.throttleCacheSize} throttle entries');
}
