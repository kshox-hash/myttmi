// lib/state/app_scope.dart
import 'package:flutter/widgets.dart';
import 'app_store.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    super.key,
    required AppStore store,
    required Widget child,
  }) : super(notifier: store, child: child);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope no encontrado en el árbol');
    return scope!.notifier!;
  }
}
