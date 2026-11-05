import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_list/models/app_data.dart';
import 'package:shopping_list/models/checklist.dart';
import 'package:shopping_list/models/checklist_item.dart';
import 'package:shopping_list/services/app_data_store.dart';

void main() {
  test('round-trips checklists through JSON', () {
    final data = AppData(
      checklists: [
        Checklist(
          id: 'c',
          name: 'Prodavnica',
          items: [ChecklistItem(id: 'i', text: 'mleko', done: true)],
        ),
      ],
    );

    final back = AppData.fromJson(
      jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>,
    );
    final list = back.checklists.single;
    expect(list.name, 'Prodavnica');
    final item = list.items.single;
    expect([item.text, item.done], ['mleko', true]);
  });

  test('store recovers from a corrupt payload', () async {
    SharedPreferences.setMockInitialValues({'shopping_list_data': '{oops'});
    final data = await AppDataStore().read();
    expect(data.checklists, isEmpty);
  });
}
