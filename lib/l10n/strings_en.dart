import 'checklist_strings_en.dart';
import 'share_strings_en.dart';
import 'strings.dart';
import 'update_strings_en.dart';

/// English translations.
class StringsEn extends AppStrings
    with ChecklistStringsEn, UpdateStringsEn, ShareStringsEn {
  const StringsEn();

  @override
  String get localeCode => 'en';
  @override
  String get listsTitle => 'Lists';
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get undo => 'Undo';
  @override
  String get settings => 'Settings';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
}
