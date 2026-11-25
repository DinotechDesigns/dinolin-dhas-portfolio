import 'dart:ui';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

bool browserPrefersReducedMotion() => web.window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/// Downloads a file that was bundled through pubspec assets.
void downloadBundledAsset(String asset, {required String fileName}) {
  final anchor = web.HTMLAnchorElement()
    ..href = ui_web.assetManager.getAssetUrl(asset)
    ..download = fileName;
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

/// Also read by the loading screen in web/index.html.
const _themeKey = 'portfolio-theme';

// Storage throws when the visitor blocks site data; the choice then lasts for the visit.
String? loadThemeChoice() {
  try {
    return web.window.localStorage.getItem(_themeKey);
  } on Object {
    return null;
  }
}

/// Remembers the theme and recolours the browser chrome to match.
void saveThemeChoice(String choice, Color background) {
  try {
    web.window.localStorage.setItem(_themeKey, choice);
  } on Object {
    // Nothing to do: see loadThemeChoice.
  }
  final hex = '#${(background.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  web.document.querySelector('meta[name="theme-color"]')?.setAttribute('content', hex);
  web.document.documentElement?.setAttribute('data-theme', choice);
}
