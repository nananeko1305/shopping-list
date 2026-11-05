import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_list/app.dart';
import 'package:shopping_list/screens/share_app_screen.dart';
import 'package:shopping_list/updates/update_checker.dart';

import 'fakes/fakes.dart';

/// A phone-sized screen, so the buttons below the code are on it.
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('settings open the share screen with the download code', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(AppRoot(services: fakeServices()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Podeli aplikaciju'));
    await tester.pumpAndSettle();

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(find.text(kAppDownloadUrl), findsOneWidget);
    // Dark on white whatever the theme: scanners read an inverted code badly.
    expect(qr.backgroundColor, Colors.white);
    expect(qr.dataModuleStyle.color, Colors.black);
    expect(qr.eyeStyle.color, Colors.black);
  });

  testWidgets('copying puts the link on the clipboard, and says so', (
    tester,
  ) async {
    _phone(tester);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await tester.pumpWidget(wrapInApp(const ShareAppScreen(), fakeServices()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kopiraj link'));
    await tester.pump();
    expect(copied, kAppDownloadUrl);
    expect(find.text('Link je kopiran.'), findsOneWidget);
  });

  // Renaming the APK in CI would quietly break every code already handed out.
  test('the link names the file the release publishes', () {
    final workflow = File('.github/workflows/release-apk.yml')
        .readAsStringSync();
    final name = RegExp(r'APK_NAME: (\S+)').firstMatch(workflow)!.group(1)!;
    expect(kAppDownloadUrl, endsWith('/releases/latest/download/$name'));
    expect(kAppDownloadUrl, contains('/nananeko1305/shopping-list/'));
  });
}
