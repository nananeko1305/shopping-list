import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../theme.dart';
import '../widgets/checklist_item_tile.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/framed_icon_button.dart';
import '../widgets/quick_add_field.dart';

/// One checklist: tap to check (strike-through), swipe to delete with undo,
/// quick-add at the bottom. A pencil next to the name renames the list; at
/// the top right one button empties it and a red one deletes it.
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, required this.listId});

  final String listId;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _scroll = ScrollController();
  Checklist? _list;
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    // Undo belongs to this list; it makes no sense on the screen below.
    _messenger?.hideCurrentSnackBar();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final list = await AppScope.of(context).services.checklists
        .byId(widget.listId);
    if (mounted) setState(() => _list = list);
  }

  /// Runs a repository change, then shows the result.
  Future<void> _change(Future<void> Function() action) async {
    await action();
    await _reload();
  }

  Future<void> _add(String text) async {
    final repo = AppScope.of(context).services.checklists;
    await _change(() => repo.addItem(widget.listId, text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _delete(ChecklistItem item, int index) {
    final scope = AppScope.of(context);
    final repo = scope.services.checklists;
    setState(() => _list?.items.removeAt(index));
    repo.deleteItem(widget.listId, item.id);
    _messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(scope.strings.itemDeleted),
          // Flutter keeps a bar with an action on screen until it is closed.
          persist: false,
          // A fixed bar would sit on top of the add field.
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 80),
          action: SnackBarAction(
            label: scope.strings.undo,
            onPressed: () =>
                _change(() => repo.restoreItem(widget.listId, item, index)),
          ),
        ),
      );
  }

  Future<void> _rename(Checklist list) async {
    final scope = AppScope.of(context);
    final name = await showNameDialog(
      context,
      title: scope.strings.renameList,
      label: scope.strings.listNameLabel,
      initial: list.name,
    );
    if (name == null) return;
    await _change(() => scope.services.checklists.renameList(list.id, name));
  }

  /// Empties the list for the next shopping trip, after asking.
  Future<void> _clear(Checklist list) async {
    final scope = AppScope.of(context);
    final ok = await showConfirmDialog(
      context,
      title: scope.strings.clearList,
      message: scope.strings.clearListMsg(list.name),
    );
    if (!ok) return;
    await _change(() => scope.services.checklists.clearItems(list.id));
  }

  Future<void> _deleteList(Checklist list) async {
    final scope = AppScope.of(context);
    final ok = await showConfirmDialog(
      context,
      title: scope.strings.deleteList,
      message: scope.strings.deleteListMsg(list.name),
    );
    if (!ok) return;
    await scope.services.checklists.deleteList(list.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    final list = _list;
    if (list == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Flexible(child: Text(list.name, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            FramedIconButton(
              icon: Icons.edit_outlined,
              tooltip: s.renameList,
              onPressed: () => _rename(list),
            ),
          ],
        ),
        actions: [
          Text(s.progress(list.doneCount, list.items.length)),
          const SizedBox(width: 8),
          FramedIconButton(
            icon: Icons.restart_alt,
            tooltip: s.clearList,
            onPressed: list.items.isEmpty ? null : () => _clear(list),
          ),
          const SizedBox(width: 8),
          FramedIconButton(
            icon: Icons.delete_outline,
            tooltip: s.deleteList,
            color: palette(context).danger,
            onPressed: () => _deleteList(list),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: list.items.isEmpty
                ? EmptyState(
                    icon: Icons.playlist_add_check,
                    title: list.name,
                    hint: s.emptyListHint,
                  )
                : ListView.builder(
                    controller: _scroll,
                    itemCount: list.items.length,
                    itemBuilder: (context, i) => _itemRow(list, i),
                  ),
          ),
          QuickAddField(hint: s.addItemHint, onAdd: _add),
        ],
      ),
    );
  }

  Widget _itemRow(Checklist list, int index) {
    final item = list.items[index];
    final repo = AppScope.of(context).services.checklists;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(item, index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline, color: palette(context).danger),
      ),
      child: ChecklistItemTile(
        item: item,
        onToggle: () => _change(() => repo.toggleItem(list.id, item.id)),
      ),
    );
  }
}
