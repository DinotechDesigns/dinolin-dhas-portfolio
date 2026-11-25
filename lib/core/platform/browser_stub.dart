import 'dart:ui';

/// Non-web fallbacks, used by widget tests running on the Dart VM.
bool browserPrefersReducedMotion() => false;

void downloadBundledAsset(String asset, {required String fileName}) {}

String? loadThemeChoice() => null;

void saveThemeChoice(String choice, Color background) {}
