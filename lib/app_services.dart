import 'services/app_data_store.dart';
import 'services/checklist_repository.dart';
import 'services/settings_store.dart';
import 'updates/push_service.dart';
import 'updates/update_checker.dart';

/// Composition root: one instance of every service, shared through
/// [AppScope]. Tests build it with fakes via the default constructor.
class AppServices {
  final SettingsStore settings;
  final ChecklistRepository checklists;
  final UpdateChecker updates;
  final PushService push;

  const AppServices({
    required this.settings,
    required this.checklists,
    required this.updates,
    required this.push,
  });

  /// Wires the real services.
  factory AppServices.create() => AppServices(
    settings: SettingsStore(),
    checklists: ChecklistRepository(store: AppDataStore()),
    updates: UpdateChecker(),
    push: PushService(),
  );
}
