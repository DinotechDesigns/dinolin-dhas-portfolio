import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/constants/app_constants.dart';
import '../platform/browser.dart';
import '../widgets/notice.dart';

/// Outbound actions shared by the hero, the project details and the contact section.
abstract final class SiteActions {
  static Future<void> email(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: AppConstants.email);
    final opened = await launchUrl(uri, webOnlyWindowName: '_self');
    if (!opened && context.mounted) await copyEmail(context);
  }

  static Future<void> copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: AppConstants.email));
    if (context.mounted) showNotice(context, 'Email address copied');
  }

  static Future<void> open(BuildContext context, String url) async {
    final opened = await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    if (!opened && context.mounted) {
      showNotice(context, 'The link could not be opened. Check whether your browser blocked a new tab.');
    }
  }

  static Future<void> linkedIn(BuildContext context) => open(context, AppConstants.linkedInUrl);

  static Future<void> gitHub(BuildContext context) =>
      open(context, 'https://github.com/${AppConstants.gitHubUsername}');

  static Future<void> whatsApp(BuildContext context) async {
    if (AppConstants.whatsAppNumber.isEmpty) {
      showNotice(
        context,
        'WhatsApp is not connected yet. Email reaches me directly.',
        actionLabel: 'Email me',
        onAction: () => email(context),
      );
      return;
    }
    await open(context, 'https://wa.me/${AppConstants.whatsAppNumber}');
  }

  static Future<void> resume(BuildContext context) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    if (manifest.listAssets().contains(AppConstants.resumeAsset)) {
      downloadBundledAsset(AppConstants.resumeAsset, fileName: AppConstants.resumeFileName);
      return;
    }
    if (!context.mounted) return;
    showNotice(
      context,
      'The resume is not online yet. Email me and I will send it.',
      actionLabel: 'Email me',
      onAction: () => email(context),
    );
  }
}
