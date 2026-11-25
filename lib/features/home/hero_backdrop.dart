import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/scroll/hero_ticker.dart';

/// Slow-moving colour fields behind the first screen.
class HeroBackdrop extends StatefulWidget {
  const HeroBackdrop({super.key});

  @override
  State<HeroBackdrop> createState() => _HeroBackdropState();
}

class _HeroBackdropState extends State<HeroBackdrop> with HeroTicker {
  @override
  Duration get loop => const Duration(seconds: 28);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _BackdropPainter(drift, context.colors), size: Size.infinite),
  );
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.drift, this.colors) : super(repaint: drift);

  final ValueNotifier<double> drift;
  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = drift.value * math.pi * 2;
    final reach = math.max(size.width, size.height);

    void field(Color color, double x, double y, double radius, double alpha) {
      final center = Offset(size.width * x, size.height * y);
      // Never past the bottom edge, so the next section starts without a seam.
      final bounds = Rect.fromCircle(center: center, radius: math.min(reach * radius, size.height - center.dy));
      final strength = alpha * colors.glow;
      canvas.drawRect(
        bounds.intersect(Offset.zero & size),
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: strength),
              color.withValues(alpha: strength * 0.45),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.42, 1],
          ).createShader(bounds),
      );
    }

    canvas.clipRect(Offset.zero & size);
    field(colors.indigo, 0.82 + 0.06 * math.sin(t), 0.3 + 0.08 * math.cos(t), 0.5, 0.34);
    field(colors.plum, 0.6 + 0.05 * math.cos(t), 0.62 + 0.05 * math.sin(t), 0.42, 0.24);
    field(colors.mint, 0.05 + 0.05 * math.cos(t + 1), 0.02 + 0.06 * math.sin(t + 2), 0.38, 0.2);
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.drift != drift || old.colors != colors;
}
