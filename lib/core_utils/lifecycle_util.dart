import 'package:flutter/widgets.dart';

enum LifecycleState {
  inactive('AppLifecycleState.inactive', 'inactive', '非活跃'),
  paused('AppLifecycleState.paused', 'paused', '暂停'),
  resumed('AppLifecycleState.resumed', 'resumed', '恢复'),
  detached('AppLifecycleState.detached', 'detached', '断开'),
  hidden('AppLifecycleState.hidden', 'hidden', '隐藏');

  final String value;
  final String name;
  final String description;

  const LifecycleState(this.value, this.name, this.description);

  static LifecycleState fromValue(String value) {
    return values.firstWhere(
      (v) => v.value == value,
      orElse: () => LifecycleState.detached,
    );
  }

  static LifecycleState fromAppLifecycleState(AppLifecycleState state) {
    return values.firstWhere(
      (v) => v.name == state.name,
      orElse: () => LifecycleState.detached,
    );
  }

  @override
  String toString() {
    return 'AppLifecycle(value: $value, name: $name, description: $description)';
  }
}

typedef LifecycleChanged = void Function(LifecycleState state);
typedef AppLifecycleChanged = void Function(AppLifecycleState state);

class LifecycleUtil with WidgetsBindingObserver {
  LifecycleUtil._();

  static final LifecycleUtil _instance = LifecycleUtil._();
  static final Set<LifecycleChanged> _listeners = {};
  static final Set<AppLifecycleChanged> _rawListeners = {};
  static bool _observing = false;

  static bool get observing => _observing;
  static bool get hasListeners =>
      _listeners.isNotEmpty || _rawListeners.isNotEmpty;

  static void addLifeCycleListener(LifecycleChanged listener) {
    _ensureObserver();
    _listeners.add(listener);
  }

  static void removeLifeCycleListener(LifecycleChanged listener) {
    _listeners.remove(listener);
    _removeObserverIfNeeded();
  }

  static void addListener(AppLifecycleChanged listener) {
    _ensureObserver();
    _rawListeners.add(listener);
  }

  static void removeListener(AppLifecycleChanged listener) {
    _rawListeners.remove(listener);
    _removeObserverIfNeeded();
  }

  static void clear() {
    _listeners.clear();
    _rawListeners.clear();
    _removeObserver();
  }

  static void _ensureObserver() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(_instance);
    _observing = true;
  }

  static void _removeObserverIfNeeded() {
    if (hasListeners) return;
    _removeObserver();
  }

  static void _removeObserver() {
    if (!_observing) return;
    WidgetsBinding.instance.removeObserver(_instance);
    _observing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lifecycleState = LifecycleState.fromAppLifecycleState(state);
    for (final listener in List<LifecycleChanged>.of(_listeners)) {
      listener(lifecycleState);
    }
    for (final listener in List<AppLifecycleChanged>.of(_rawListeners)) {
      listener(state);
    }
  }
}
