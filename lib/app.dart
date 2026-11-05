import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'app_services.dart';
import 'l10n/strings.dart';
import 'screens/home_shell.dart';
import 'theme.dart';
import 'updates/update_checker.dart';
import 'widgets/update_dialog.dart';

/// Serbian with Latin script; plain 'sr' would give Cyrillic pickers.
const _serbianLatin = Locale.fromSubtags(
  languageCode: 'sr',
  scriptCode: 'Latn',
);

/// Root widget: owns the language and theme settings and offers new app
/// versions.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.services});

  final AppServices services;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<void> _releases;
  bool _updateDialogOpen = false;

  String _localeCode = 'sr';
  ThemeMode _themeMode = ThemeMode.system;

  AppServices get _services => widget.services;

  @override
  void initState() {
    super.initState();
    // A release push (received in the foreground or tapped) re-runs the
    // update check, which then shows the download dialog.
    _releases = _services.push.onRelease.listen((_) => _checkForUpdate());
    _services.push.start();
    _start();
  }

  @override
  void dispose() {
    _releases.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final settings = _services.settings;
    final locale = await settings.loadLocale();
    final themeMode = await settings.loadThemeMode();
    if (!mounted) return;
    setState(() {
      _localeCode = locale;
      _themeMode = themeMode;
    });
    await _checkForUpdate();
  }

  /// On app start and on release pushes; silent when offline or already
  /// up to date, and never stacks a second dialog on an open one.
  Future<void> _checkForUpdate() async {
    if (_updateDialogOpen) return;
    final result = await _services.updates.check();
    if (result is! UpdateAvailable || _updateDialogOpen) return;
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    _updateDialogOpen = true;
    await showUpdateDialog(context, result);
    _updateDialogOpen = false;
  }

  Future<void> _setLocale(String code) async {
    setState(() => _localeCode = code);
    await _services.settings.saveLocale(code);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await _services.settings.saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(_localeCode);
    return AppScope(
      strings: strings,
      themeMode: _themeMode,
      services: _services,
      setLocale: _setLocale,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: strings.appName,
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: _themeMode,
        locale: _localeCode == 'en' ? const Locale('en') : _serbianLatin,
        supportedLocales: const [_serbianLatin, Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Screens without an app bar (a list while it loads) still get
        // status-bar icons that match the theme.
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle(Theme.of(context).brightness),
          child: child!,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
