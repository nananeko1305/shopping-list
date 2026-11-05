import 'share_strings.dart';

/// Serbian (Latin) strings for sharing the app.
mixin ShareStringsSr implements ShareStrings {
  @override
  String get shareApp => 'Podeli aplikaciju';
  @override
  String get shareAppHint =>
      'Skeniraj kod kamerom drugog telefona ili pošalji link. Android će tražiti dozvolu za instalaciju iz tog izvora.';
  @override
  String get shareAppMessage => 'Shopping List: liste za kupovinu i put.';
  @override
  String get copyLink => 'Kopiraj link';
  @override
  String get linkCopied => 'Link je kopiran.';
  @override
  String get sendLink => 'Pošalji';
}
