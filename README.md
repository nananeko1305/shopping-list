# Shopping List (Flutter)

An Android app for shopping and packing lists. Everything is stored on the
phone; there is no backend. Serbian (Latin) by default, English in settings.

It was split off from [Reminders](https://github.com/nananeko1305/reminders),
which now holds only reminders. Android keeps each app's data private, so lists
made in Reminders were not carried over.

## Features

- **Lists**: any number of named lists (Prodavnica, Za put…), each with its
  progress. Tap to open, long-press to rename or delete.
- **Items**: quick add with the keyboard staying open. Checked items are struck
  through. Swipe to delete with undo, "Poništi sve" to reuse a list, "Obriši
  označene" to clear what was bought.
- **Settings**: language, theme and the update check.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

Install on a phone with USB debugging enabled:

```bash
flutter install --release
# or
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Local release builds are signed with the debug key unless
`android/key.properties` exists. The CI build is signed with the release key,
so switching between a local build and a GitHub one needs an uninstall, which
deletes the lists on that phone.

## Icon

The logo (a cart with a check) lives in `assets/icon/` as SVG sources:

- `logo.svg`: the full rounded icon. Used for legacy launchers and the download page.
- `logo_background.svg` + `logo_foreground.svg`: the Android adaptive-icon layers. The foreground keeps the glyph inside the safe zone, so no launcher mask clips it.

After editing an SVG, render the PNGs and regenerate the launcher icons:

```bash
for n in logo logo_background logo_foreground; do
  google-chrome --headless=new --hide-scrollbars --default-background-color=00000000 \
    --window-size=1024,1024 --screenshot="$PWD/assets/icon/$n.png" "file://$PWD/assets/icon/$n.svg"
done
dart run flutter_launcher_icons
```

## Release and update notifications

Same pipeline as Reminders. Day-to-day work goes to `dev`; merging into `main`
ships. `.github/workflows/release-apk.yml` then runs:

1. analyze, test, and a signed release APK;
2. a GitHub Release `vX.Y.Z` with `shopping-list.apk`;
3. `version.json` on GitHub Pages
   (<https://nananeko1305.github.io/shopping-list/version.json>);
4. an FCM push to the `releases` topic (Firebase project `shopping-list-261105`).

Every install subscribes to that topic (`lib/updates/push_service.dart`). The
push text comes from `res/values*/strings.xml`, so each phone shows it in its
own language. On start, on a push and from Settings → "Proveri ažuriranja",
the app compares its version with `version.json` and offers to download the
new APK (`lib/updates/update_checker.dart`).

Versions are `major.minor.patch`, worked out from the commit messages since
the last tag: `feat` bumps the minor, anything else the patch, and a breaking
change the major. The version in `pubspec.yaml` is a floor. Android's version
code is the workflow run number.

Repository secrets:

- `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
  `ANDROID_KEY_PASSWORD`: the release key. It lives in
  `~/.android-keys/shopping_list/`. Keep a backup: losing it means every phone
  has to uninstall to get new versions.
- `FCM_SERVICE_ACCOUNT`: a service-account key of the Firebase project
  (console → Project settings → Service accounts → Generate new private key).
  Without it the workflow skips only the push.
