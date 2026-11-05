import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Semantic colors for the app, resolved per light/dark theme via a
/// [ThemeExtension]. Access with [palette].
///
/// Concept: a fresh market green, with coral only for deleting.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color brand; // primary
  final Color danger; // delete accents
  final Color muted; // checked items, secondary text
  final Color cardSurface;
  final Color cardBorder;

  const AppPalette({
    required this.brand,
    required this.danger,
    required this.muted,
    required this.cardSurface,
    required this.cardBorder,
  });

  static const AppPalette light = AppPalette(
    brand: Color(0xFF2E7D57),
    danger: Color(0xFFD9534F),
    muted: Color(0xFF667068),
    cardSurface: Color(0xFFFFFFFF),
    cardBorder: Color(0x1A2E7D57),
  );

  static const AppPalette dark = AppPalette(
    brand: Color(0xFF7FD6A8),
    danger: Color(0xFFFF8A80),
    muted: Color(0xFF9AA39D),
    cardSurface: Color(0xFF18211C),
    cardBorder: Color(0x267FD6A8),
  );

  @override
  AppPalette copyWith({
    Color? brand,
    Color? danger,
    Color? muted,
    Color? cardSurface,
    Color? cardBorder,
  }) => AppPalette(
    brand: brand ?? this.brand,
    danger: danger ?? this.danger,
    muted: muted ?? this.muted,
    cardSurface: cardSurface ?? this.cardSurface,
    cardBorder: cardBorder ?? this.cardBorder,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brand: Color.lerp(brand, other.brand, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
    );
  }
}

/// Shortcut to read the palette from a [BuildContext].
AppPalette palette(BuildContext context) =>
    Theme.of(context).extension<AppPalette>()!;

ThemeData buildLightTheme() => _build(
  AppPalette.light,
  Brightness.light,
  scaffold: const Color(0xFFF3F7F4),
  ink: const Color(0xFF1B2A22),
);

ThemeData buildDarkTheme() => _build(
  AppPalette.dark,
  Brightness.dark,
  scaffold: const Color(0xFF0F1512),
  ink: const Color(0xFFE6F0EA),
);

/// Status and navigation bar icons: dark on the light theme, light on the
/// dark theme, over transparent bars. The navigation icons are set too:
/// SystemUiOverlayStyle.dark assumes a black navigation bar and would make
/// them light, invisible over the light theme.
SystemUiOverlayStyle overlayStyle(Brightness brightness) {
  final icons = brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;
  return (brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark)
      .copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: icons,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: icons,
      );
}

ThemeData _build(
  AppPalette p,
  Brightness brightness, {
  required Color scaffold,
  required Color ink,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.brand,
    brightness: brightness,
    primary: p.brand,
    error: p.danger,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffold,
    extensions: [p],
    // The bar takes the page colour, so the status bar above it needs dark
    // icons on the light theme; Flutter would infer light ones from a dark
    // bar, so the style is set explicitly from the theme.
    appBarTheme: AppBarTheme(
      backgroundColor: scaffold,
      surfaceTintColor: Colors.transparent,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: overlayStyle(brightness),
    ),
    cardTheme: CardThemeData(
      color: p.cardSurface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.cardBorder),
      ),
    ),
  );
}
