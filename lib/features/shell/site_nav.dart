import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/interactive.dart';
import 'mobile_menu.dart';
import 'theme_toggle.dart';

class SiteNav extends StatelessWidget {
  const SiteNav({
    super.key,
    required this.active,
    required this.scrolled,
    required this.scroll,
    required this.onNavigate,
  });

  final ValueListenable<SectionId> active;
  final ValueListenable<bool> scrolled;
  final ScrollController scroll;
  final ValueChanged<SectionId> onNavigate;

  static const height = 76.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Measured rather than fixed, so larger text falls back to the menu.
    final available =
        math.min(context.screenWidth, ContentFrame.maxWidth + ContentFrame.gutterOf(context) * 2) -
        ContentFrame.gutterOf(context) * 2;
    final wordmark = _NavLinks.measure('Dinolin Dhas', context.type.title(18), MediaQuery.textScalerOf(context));
    final expanded = wordmark + _NavLinks.totalWidth(context) + 112 <= available;
    return RepaintBoundary(
      child: ValueListenableBuilder(
        valueListenable: scrolled,
        builder: (context, isScrolled, child) => CustomPaint(
          foregroundPainter: _ProgressPainter(scroll, colors),
          child: AnimatedContainer(
            duration: Motion.medium,
            height: isScrolled ? 64 : height,
            decoration: BoxDecoration(
              color: colors.background.withValues(alpha: isScrolled ? 0.97 : 0),
              border: Border(bottom: BorderSide(color: isScrolled ? colors.line : colors.line.withValues(alpha: 0))),
            ),
            child: child,
          ),
        ),
        child: ContentFrame(
          child: Row(
            children: [
              _Wordmark(onTap: () => onNavigate(SectionId.home)),
              const Spacer(),
              if (expanded) ...[
                ValueListenableBuilder(
                  valueListenable: active,
                  builder: (context, id, _) => _NavLinks(active: id, onNavigate: onNavigate),
                ),
                const SizedBox(width: 20),
              ],
              const ThemeToggle(),
              if (!expanded) ...[
                const SizedBox(width: 8),
                _MenuButton(
                  onTap: () => showMobileMenu(context, active: active.value, onNavigate: onNavigate),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// How far down the page the visitor is.
class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.scroll, this.colors) : super(repaint: scroll);

  final ScrollController scroll;
  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (!scroll.hasClients || !scroll.position.hasContentDimensions) return;
    final extent = scroll.position.maxScrollExtent;
    final t = extent <= 0 ? 0.0 : (scroll.position.pixels / extent).clamp(0.0, 1.0);
    if (t <= 0.001) return;
    final line = Rect.fromLTWH(0, size.height - 2, size.width * t, 2);
    canvas.drawRect(
      line,
      Paint()
        ..shader = LinearGradient(
          colors: [colors.indigo, colors.mint],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 2)),
    );
  }

  @override
  bool shouldRepaint(_ProgressPainter old) => old.scroll != scroll || old.colors != colors;
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Interactive(
      onTap: onTap,
      semanticLabel: 'Dinolin Dhas, back to top',
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: AnimatedDefaultTextStyle(
          duration: Motion.quick,
          style: context.type.title(18, color: state.active ? context.colors.mint : context.colors.text),
          child: const Text('Dinolin Dhas'),
        ),
      ),
    );
  }
}

/// Links with one underline that travels to the active section.
class _NavLinks extends StatelessWidget {
  const _NavLinks({required this.active, required this.onNavigate});

  final SectionId active;
  final ValueChanged<SectionId> onNavigate;

  static const _padding = 13.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.type.label(15);
    final scaler = MediaQuery.textScalerOf(context);
    final widths = [for (final id in SectionId.values) measure(id.label, style, scaler) + _padding * 2];
    final left = widths.take(active.index).fold(0.0, (sum, w) => sum + w);

    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Row(
            children: [
              for (final id in SectionId.values)
                SizedBox(
                  width: widths[id.index],
                  child: Interactive(
                    onTap: () => onNavigate(id),
                    semanticLabel: id.label,
                    builder: (context, state) => Center(
                      child: AnimatedDefaultTextStyle(
                        duration: Motion.quick,
                        style: style.copyWith(color: id == active || state.active ? colors.text : colors.muted),
                        child: Text(id.label, maxLines: 1, softWrap: false),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 520),
            curve: Motion.glide,
            left: left + _padding,
            width: widths[active.index] - _padding * 2,
            bottom: 8,
            height: 2,
            child: DecoratedBox(decoration: BoxDecoration(color: colors.mint)),
          ),
        ],
      ),
    );
  }

  static double totalWidth(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final style = context.type.label(15);
    return SectionId.values.fold(0, (sum, id) => sum + measure(id.label, style, scaler) + _padding * 2);
  }

  static double measure(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final width = painter.width.ceilToDouble() + 1;
    painter.dispose();
    return width;
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Interactive(
      onTap: onTap,
      semanticLabel: 'Open menu',
      builder: (context, state) => AnimatedContainer(
        duration: Motion.quick,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.text.withValues(alpha: state.active ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.line),
        ),
        child: Icon(Icons.menu_rounded, size: 20, color: colors.text),
      ),
    );
  }
}
