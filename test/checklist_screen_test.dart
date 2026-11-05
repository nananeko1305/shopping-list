import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_list/app_services.dart';
import 'package:shopping_list/screens/checklist_screen.dart';

import 'fakes/fakes.dart';

/// The closest text style around [text] (Material adds more further up).
TextDecoration? decorationOf(WidgetTester tester, String text) => tester
    .widget<AnimatedDefaultTextStyle>(
      find
          .ancestor(
            of: find.text(text),
            matching: find.byType(AnimatedDefaultTextStyle),
          )
          .first,
    )
    .style
    .decoration;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('checking an item strikes it through and persists', (
    tester,
  ) async {
    final services = fakeServices();
    final list = await services.checklists.addList('Prodavnica');
    await services.checklists.addItem(list.id, 'mleko');

    await tester.pumpWidget(
      wrapInApp(ChecklistScreen(listId: list.id), services),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prodavnica'), findsOneWidget);
    expect(decorationOf(tester, 'mleko'), isNot(TextDecoration.lineThrough));

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(decorationOf(tester, 'mleko'), TextDecoration.lineThrough);
    expect(find.text('1/1'), findsOneWidget);
    expect(
      (await services.checklists.byId(list.id))!.items.single.done,
      isTrue,
    );
  });

  testWidgets('quick add appends items', (tester) async {
    final services = fakeServices();
    final list = await services.checklists.addList('Za put');

    await tester.pumpWidget(
      wrapInApp(ChecklistScreen(listId: list.id), services),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lista je prazna — dodaj stavku ispod'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pasoš');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'punjač');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.text('pasoš'), findsOneWidget);
    expect(find.text('punjač'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
  });

  group('deleting an item', () {
    Future<void> deleteMilk(WidgetTester tester) async {
      await tester.drag(find.text('mleko'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Vrati'), findsOneWidget);
    }

    Future<String> listWithMilk(AppServices services) async {
      final list = await services.checklists.addList('Prodavnica');
      await services.checklists.addItem(list.id, 'mleko');
      return list.id;
    }

    testWidgets('the undo bar leaves the add field free and goes away', (
      tester,
    ) async {
      final services = fakeServices();
      final listId = await listWithMilk(services);
      await tester.pumpWidget(
        wrapInApp(ChecklistScreen(listId: listId), services),
      );
      await tester.pumpAndSettle();

      await deleteMilk(tester);
      expect(
        // The bar itself: the SnackBar widget also spans its margin.
        tester
            .getRect(
              find
                  .descendant(
                    of: find.byType(SnackBar),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(TextField)).top),
      );

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Vrati'), findsNothing);
    });

    testWidgets('undo puts the item back', (tester) async {
      final services = fakeServices();
      final listId = await listWithMilk(services);
      await tester.pumpWidget(
        wrapInApp(ChecklistScreen(listId: listId), services),
      );
      await tester.pumpAndSettle();

      await deleteMilk(tester);
      expect(find.text('mleko'), findsNothing);

      await tester.tap(find.text('Vrati'));
      await tester.pumpAndSettle();
      expect(find.text('mleko'), findsOneWidget);
      expect((await services.checklists.byId(listId))!.items, hasLength(1));
    });

    testWidgets('leaving the list takes the undo bar away', (tester) async {
      final services = fakeServices();
      final listId = await listWithMilk(services);
      await tester.pumpWidget(
        wrapInApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ChecklistScreen(listId: listId),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
          services,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await deleteMilk(tester);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Vrati'), findsNothing);
    });
  });
}
