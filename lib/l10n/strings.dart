import 'checklist_strings.dart';
import 'strings_en.dart';
import 'strings_sr.dart';
import 'update_strings.dart';

/// Contract for all user-facing strings.
///
/// Translations live in one file per language: Serbian (Latin) in
/// [StringsSr], English in [StringsEn]. Feature strings are declared in their
/// own contracts ([ChecklistStrings], [UpdateStrings]), each implemented per
/// language in its own file.
abstract class AppStrings with ChecklistStrings, UpdateStrings {
  const AppStrings();

  String get localeCode;

  /// The app's name is English in every language, like the launcher label
  /// and the user's other apps.
  String get appName => 'Shopping List';

  String get listsTitle;
  // Common
  String get save;
  String get cancel;
  String get delete;
  String get undo;
  // Settings
  String get settings;
  String get language;
  String get theme;
  String get themeSystem;
  String get themeLight;
  String get themeDark;

  String progress(int done, int total) => '$done/$total';

  static AppStrings of(String code) =>
      code == 'en' ? const StringsEn() : const StringsSr();
}
