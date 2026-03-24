import 'package:scaffold_core/core_utils/lifecycle_util.dart';

void main() {
  final subscription = LifecycleUtil.addLifeCycleListener((lifecycle) {
    print('App lifecycle changed: ${lifecycle.description}');
  });

  subscription.cancel();
}
