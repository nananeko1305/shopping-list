import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shopping_list/app_scope.dart';
import 'package:shopping_list/app_services.dart';
import 'package:shopping_list/l10n/strings.dart';
import 'package:shopping_list/services/app_data_store.dart';
import 'package:shopping_list/services/checklist_repository.dart';
import 'package:shopping_list/services/settings_store.dart';
import 'package:shopping_list/theme.dart';
import 'package:shopping_list/updates/push_service.dart';
import 'package:shopping_list/updates/update_checker.dart';

/// Answers update checks with [result] (up to date unless set).
class FakeUpdateChecker implements UpdateChecker {
  UpdateResult result = const UpToDate();
  int checks = 0;

  @override
  Future<String> currentVersion() async => '1.0.0';

  @override
  Future<UpdateResult> check() async {
    checks++;
    return result;
  }
}

/// Release pushes on demand via [simulateRelease].
class FakePushService implements PushService {
  final _releases = StreamController<void>.broadcast();
  bool started = false;

  void simulateRelease() => _releases.add(null);

  @override
  Stream<void> get onRelease => _releases.stream;

  @override
  Future<void> start() async => started = true;
}

AppServices fakeServices({FakeUpdateChecker? updates, FakePushService? push}) =>
    AppServices(
      settings: SettingsStore(),
      checklists: ChecklistRepository(store: AppDataStore()),
      updates: updates ?? FakeUpdateChecker(),
      push: push ?? FakePushService(),
    );

/// [child] inside the app's scope and theme, in Serbian.
Widget wrapInApp(Widget child, AppServices services) => AppScope(
  strings: AppStrings.of('sr'),
  themeMode: ThemeMode.light,
  services: services,
  setLocale: (_) {},
  setThemeMode: (_) {},
  child: MaterialApp(theme: buildLightTheme(), home: child),
);
