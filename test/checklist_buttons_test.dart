import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_list/app_services.dart';
import 'package:shopping_list/screens/checklist_screen.dart';

import 'fakes/fakes.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('buttons at the top', () {
    Future<String> listWithItems(AppServices services) async {
      final list = await services.checklists.addList('Prodavnica');
      await services.checklists.addItem(list.id, 'mleko');
      await services.checklists.addItem(list.id, 'hleb');
      return list.id;
    }

    /// The list opened from a plain home screen, so closing it can be seen.
    Future<void> openFromHome(
      WidgetTester tester,
      AppServices services,
      String listId,
    ) async {
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
    }

    IconButton buttonWith(WidgetTester tester, String tooltip) =>
        tester.widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        );

    testWidgets('no overflow menu; the pencil renames the list', (
      tester,
    ) async {
      final services = fakeServices();
      final listId = await listWithItems(services);
      await tester.pumpWidget(
        wrapInApp(ChecklistScreen(listId: listId), services),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.more_vert), findsNothing);

      await tester.tap(find.byTooltip('Preimenuj listu'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Pijaca');
      await tester.tap(find.text('Sačuvaj'));
      await tester.pumpAndSettle();

      expect(find.text('Pijaca'), findsOneWidget);
      expect((await services.checklists.byId(listId))!.name, 'Pijaca');
    });

    testWidgets('emptying the list asks first and keeps the list', (
      tester,
    ) async {
      final services = fakeServices();
      final listId = await listWithItems(services);
      await tester.pumpWidget(
        wrapInApp(ChecklistScreen(listId: listId), services),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Isprazni listu'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Sve stavke sa liste „Prodavnica" biće obrisane. Lista ostaje.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Otkaži'));
      await tester.pumpAndSettle();
      expect(find.text('mleko'), findsOneWidget);

      await tester.tap(find.byTooltip('Isprazni listu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Obriši'));
      await tester.pumpAndSettle();

      expect(find.text('mleko'), findsNothing);
      expect(find.text('0/0'), findsOneWidget);
      expect((await services.checklists.byId(listId))!.items, isEmpty);
      // Nothing left to empty.
      expect(buttonWith(tester, 'Isprazni listu').onPressed, isNull);
    });

    testWidgets('the trash deletes the whole list after asking', (
      tester,
    ) async {
      final services = fakeServices();
      final listId = await listWithItems(services);
      await openFromHome(tester, services, listId);

      await tester.tap(find.byTooltip('Obriši listu'));
      await tester.pumpAndSettle();
      expect(
        find.text('Lista „Prodavnica" i sve njene stavke biće obrisane.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Obriši'));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
      expect(await services.checklists.lists(), isEmpty);
    });
  });
}
