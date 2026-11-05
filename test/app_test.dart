import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_list/app.dart';
import 'package:shopping_list/screens/checklists_screen.dart';
import 'package:shopping_list/widgets/empty_state.dart';

import 'fakes/fakes.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('starts in Serbian on the lists, with release pushes on', (
    tester,
  ) async {
    final push = FakePushService();
    final updates = FakeUpdateChecker();
    await tester.pumpWidget(
      AppRoot(
        services: fakeServices(push: push, updates: updates),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liste'), findsOneWidget);
    expect(find.text('Nema lista'), findsOneWidget);
    expect(push.started, isTrue);
    expect(updates.checks, 1);
    // The placeholder sits in the middle of the screen, not in its top-left corner.
    final placeholder = tester.getCenter(
      find.descendant(
        of: find.byType(EmptyState),
        matching: find.byType(Column),
      ),
    );
    final screen = tester.getRect(find.byType(ChecklistsScreen));
    expect((placeholder - screen.center).distance, lessThan(1));
  });

  testWidgets('creating a list opens it and it stays on the home screen', (
    tester,
  ) async {
    await tester.pumpWidget(AppRoot(services: fakeServices()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Prodavnica');
    await tester.tap(find.text('Sačuvaj'));
    await tester.pumpAndSettle();
    expect(find.text('Lista je prazna — dodaj stavku ispod'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Prodavnica'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
  });

  testWidgets('switching to English changes the screen and is remembered', (
    tester,
  ) async {
    final services = fakeServices();
    await tester.pumpWidget(AppRoot(services: services));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(await services.settings.loadLocale(), 'en');
  });
}
