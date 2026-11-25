import 'package:flutter/material.dart';

import 'app_palette.dart';

export 'app_palette.dart';

abstract final class AppTheme {
  static final ThemeData dark = _build(AppPalette.dark);
  static final ThemeData light = _build(AppPalette.light);

  static ThemeData of(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  static ThemeData _build(AppPalette colors) {
    final type = AppType(colors);
    final base = colors.isDark ? const ColorScheme.dark() : const ColorScheme.light();
    return ThemeData(
      brightness: colors.brightness,
      colorScheme: base.copyWith(
        primary: colors.mint,
        onPrimary: colors.onAccent,
        secondary: colors.indigo,
        surface: colors.surface,
        onSurface: colors.text,
      ),
      extensions: [colors],
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppType.family,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      tooltipTheme: TooltipThemeData(
        textStyle: type.label(13, color: colors.background),
        decoration: BoxDecoration(color: colors.text, borderRadius: BorderRadius.circular(8)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(colors.muted.withValues(alpha: 0.4)),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }
}
