import 'checklist_strings_sr.dart';
import 'share_strings_sr.dart';
import 'strings.dart';
import 'update_strings_sr.dart';

/// Serbian (Latin) translations.
class StringsSr extends AppStrings
    with ChecklistStringsSr, UpdateStringsSr, ShareStringsSr {
  const StringsSr();

  @override
  String get localeCode => 'sr';
  @override
  String get listsTitle => 'Liste';
  @override
  String get save => 'Sačuvaj';
  @override
  String get cancel => 'Otkaži';
  @override
  String get delete => 'Obriši';
  @override
  String get undo => 'Vrati';
  @override
  String get settings => 'Podešavanja';
  @override
  String get language => 'Jezik';
  @override
  String get theme => 'Tema';
  @override
  String get themeSystem => 'Sistem';
  @override
  String get themeLight => 'Svetla';
  @override
  String get themeDark => 'Tamna';
}
