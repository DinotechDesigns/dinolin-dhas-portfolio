import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/theme_controller.dart';
import '../../core/animations/motion.dart';
import '../../core/widgets/interactive.dart';

/// Sun and moon switch. The new theme opens outward from the button.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);
    final label = theme.isDark ? 'Switch to light mode' : 'Switch to dark mode';
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Interactive(
        onTap: () {
          final box = context.findRenderObject()! as RenderBox;
          theme.toggle(box.localToGlobal(box.size.center(Offset.zero)));
        },
        semanticLabel: label,
        builder: (context, state) => AnimatedContainer(
          duration: Motion.quick,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.text.withValues(alpha: state.active ? 0.12 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.line),
          ),
          child: TweenAnimationBuilder(
            tween: Tween<double>(end: theme.isDark ? 1 : 0),
            duration: reduceMotionOf(context) ? Duration.zero : const Duration(milliseconds: 620),
            curve: Curves.easeInOutCubic,
            builder: (context, moon, _) => CustomPaint(painter: _SunMoonPainter(moon, context.colors.text)),
          ),
        ),
      ),
    );
  }
}

/// One shape that morphs: the sun's rays fold away as a bite turns it into a moon.
class _SunMoonPainter extends CustomPainter {
  _SunMoonPainter(this.moon, this.color);

  final double moon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(-moon * math.pi * 0.6);

    final radius = 5.0 + 3.2 * moon;
    final disc = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: Offset(16 - 11.5 * moon, -5 * moon), radius: radius * (0.3 + 0.62 * moon)));
    canvas.drawPath(Path.combine(PathOperation.difference, disc, bite), Paint()..color = color);

    final rays = (1 - moon * 1.6).clamp(0.0, 1.0);
    if (rays > 0) {
      final ray = Paint()
        ..color = color.withValues(alpha: rays)
        ..strokeWidth = 1.9
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 8; i++) {
        final direction = Offset.fromDirection(i * math.pi / 4);
        canvas.drawLine(direction * 8, direction * (8 + 2.8 * rays), ray);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SunMoonPainter old) => old.moon != moon || old.color != color;
}
