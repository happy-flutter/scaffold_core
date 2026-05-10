import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_core/core_utils/lifecycle_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(LifecycleUtil.clear);

  test('LifecycleState maps from AppLifecycleState', () {
    expect(
      LifecycleState.fromAppLifecycleState(AppLifecycleState.resumed),
      LifecycleState.resumed,
    );
    expect(
      LifecycleState.fromAppLifecycleState(AppLifecycleState.paused),
      LifecycleState.paused,
    );
    expect(
      LifecycleState.fromValue('AppLifecycleState.inactive'),
      LifecycleState.inactive,
    );
  });

  testWidgets('LifecycleUtil dispatches lifecycle listeners', (tester) async {
    final states = <LifecycleState>[];
    final rawStates = <AppLifecycleState>[];

    LifecycleUtil.addLifeCycleListener(states.add);
    LifecycleUtil.addListener(rawStates.add);

    expect(LifecycleUtil.observing, isTrue);
    expect(LifecycleUtil.hasListeners, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    expect(states, [LifecycleState.resumed, LifecycleState.paused]);
    expect(rawStates, [AppLifecycleState.resumed, AppLifecycleState.paused]);
  });

  testWidgets('LifecycleUtil removes observer when listeners cleared', (
    tester,
  ) async {
    void listener(LifecycleState state) {}

    LifecycleUtil.addLifeCycleListener(listener);
    expect(LifecycleUtil.observing, isTrue);

    LifecycleUtil.removeLifeCycleListener(listener);
    expect(LifecycleUtil.observing, isFalse);
    expect(LifecycleUtil.hasListeners, isFalse);
  });
}
