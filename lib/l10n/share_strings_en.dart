import 'share_strings.dart';

/// English strings for sharing the app.
mixin ShareStringsEn implements ShareStrings {
  @override
  String get shareApp => 'Share the app';
  @override
  String get shareAppHint =>
      "Scan the code with another phone's camera, or send the link. Android will ask to allow installing from that source.";
  @override
  String get shareAppMessage => 'Shopping List: lists for shopping and trips.';
  @override
  String get copyLink => 'Copy link';
  @override
  String get linkCopied => 'Link copied.';
  @override
  String get sendLink => 'Send';
}
