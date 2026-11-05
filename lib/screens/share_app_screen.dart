import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../app_scope.dart';
import '../updates/update_checker.dart';

/// Hands the app to someone else: a QR code to scan, or the link to copy or
/// send. Same screen as in Warranty Manager.
class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  Future<void> _copy(BuildContext context) async {
    final s = AppScope.of(context).strings;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(const ClipboardData(text: kAppDownloadUrl));
    messenger.showSnackBar(SnackBar(content: Text(s.linkCopied)));
  }

  Future<void> _send(BuildContext context) {
    final s = AppScope.of(context).strings;
    return SharePlus.instance.share(
      ShareParams(
        text: '${s.shareAppMessage}\n$kAppDownloadUrl',
        title: s.appName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(title: Text(s.shareApp)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            // Dark on white in both themes: scanners read an inverted code badly.
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: kAppDownloadUrl,
                  size: 240,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                  semanticsLabel: s.shareApp,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(s.shareAppHint, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          const SelectableText(
            kAppDownloadUrl,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _copy(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            icon: const Icon(Icons.copy_rounded),
            label: Text(s.copyLink),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _send(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            icon: const Icon(Icons.share_rounded),
            label: Text(s.sendLink),
          ),
        ],
      ),
    );
  }
}
