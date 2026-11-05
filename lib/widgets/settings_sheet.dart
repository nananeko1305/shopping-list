import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'update_tile.dart';

/// Language, theme and the update check.
Future<void> showSettingsSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SettingsSheet(),
    );

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final s = scope.strings;
    final sectionStyle = Theme.of(context).textTheme.titleSmall
        ?.copyWith(color: palette(context).brand);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.settings, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(s.language, style: sectionStyle),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'sr', label: Text('Srpski')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {s.localeCode},
              onSelectionChanged: (v) => scope.setLocale(v.first),
            ),
            const SizedBox(height: 16),
            Text(s.theme, style: sectionStyle),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(s.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(s.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(s.themeDark)),
              ],
              selected: {scope.themeMode},
              onSelectionChanged: (v) => scope.setThemeMode(v.first),
            ),
            const Divider(height: 32),
            const UpdateTile(),
          ],
        ),
      ),
    );
  }
}
