import 'package:flutter/material.dart';

/// Every colour the site uses, once per theme.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.mint,
    required this.indigo,
    required this.plum,
    required this.text,
    required this.muted,
    required this.line,
    required this.onAccent,
    required this.shadow,
    required this.panel,
    required this.glow,
  });

  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF131B36),
    surface: Color(0xFF1B2547),
    surfaceHigh: Color(0xFF243159),
    mint: Color(0xFF52E6C7),
    indigo: Color(0xFF8896FF),
    plum: Color(0xFFB274C9),
    text: Color(0xFFF7F8FF),
    muted: Color(0xFFB9C2DF),
    line: Color(0x33B9C2DF),
    onAccent: Color(0xFF0C1228),
    shadow: Color(0x73060A1A),
    panel: [Color(0xFF7C89F2), Color(0xFF4B4FA8), Color(0xFF272C63)],
    glow: 1,
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF4F6FC),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFFFFFFF),
    mint: Color(0xFF0A7A69),
    indigo: Color(0xFF4B56E2),
    plum: Color(0xFF9A4FA8),
    text: Color(0xFF131A35),
    muted: Color(0xFF505A79),
    line: Color(0x211F2A50),
    onAccent: Color(0xFFFFFFFF),
    shadow: Color(0x1F2A3570),
    panel: [Color(0xFFE6EAFF), Color(0xFFB9C3FB), Color(0xFF8B97EC)],
    glow: 0.55,
  );

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceHigh;

  /// Primary accent. Deep teal on light backgrounds, so it stays readable as text.
  final Color mint;
  final Color indigo;
  final Color plum;
  final Color text;
  final Color muted;
  final Color line;

  /// Text and icons placed on an accent fill.
  final Color onAccent;
  final Color shadow;

  /// Gradient of the panel behind the portrait.
  final List<Color> panel;

  /// Strength of the atmospheric light, relative to the dark theme.
  final double glow;

  bool get isDark => brightness == Brightness.dark;

  @override
  AppPalette copyWith() => this;

  // Themes swap behind a reveal animation, so there is nothing to blend.
  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 ? this : other ?? this;
}

/// One variable family in two widths: expanded for display, normal for reading.
class AppType {
  const AppType(this._colors);

  static const family = 'MonaSans';

  final AppPalette _colors;

  TextStyle display(double size, {Color? color}) =>
      _style(size, weight: 720, width: 118, height: 1.06, color: color ?? _colors.text, spacing: -0.022);

  TextStyle title(double size, {Color? color}) =>
      _style(size, weight: 640, width: 108, height: 1.25, color: color ?? _colors.text, spacing: -0.01);

  TextStyle body(double size, {Color? color}) =>
      _style(size, weight: 420, width: 100, height: 1.65, color: color ?? _colors.muted, spacing: 0);

  TextStyle label(double size, {Color? color, double weight = 560}) =>
      _style(size, weight: weight, width: 100, height: 1.3, color: color ?? _colors.text, spacing: 0);

  static TextStyle _style(
    double size, {
    required double weight,
    required double width,
    required double height,
    required Color color,
    required double spacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height,
      color: color,
      letterSpacing: size * spacing,
      fontVariations: [FontVariation('wght', weight), FontVariation('wdth', width)],
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;

  AppType get type => AppType(colors);
}
