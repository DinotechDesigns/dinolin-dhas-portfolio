import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Covers the page for a moment during long jumps: a soft wash in the page
/// colour with one band of light sweeping across it.
class TravelVeil extends StatelessWidget {
  const TravelVeil({super.key, required this.progress, required this.colors});

  final Animation<double> progress;
  final AppPalette colors;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(painter: _VeilPainter(progress, colors), size: Size.infinite),
    ),
  );
}

class _VeilPainter extends CustomPainter {
  _VeilPainter(this.progress, this.colors) : super(repaint: progress);

  final Animation<double> progress;
  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0) return;
    final page = Offset.zero & size;
    final leaving = progress.status == AnimationStatus.reverse;

    canvas.drawRect(
      page,
      Paint()
        ..color = colors.background.withValues(
          alpha: leaving ? Curves.easeInOutCubic.transform(t) : Curves.easeOutCubic.transform(t),
        ),
    );

    // The band enters from the left on the way in and leaves to the right.
    final travel = leaving ? 1 - t * 0.5 : t * 0.5;
    final width = size.width * 0.7;
    final band = Rect.fromLTWH(-width + (size.width + width) * travel, 0, width, size.height);
    canvas.drawRect(
      page,
      Paint()
        ..shader = LinearGradient(
          colors: [
            colors.indigo.withValues(alpha: 0),
            colors.indigo.withValues(alpha: 0.2 * t),
            colors.mint.withValues(alpha: 0.24 * t),
            colors.mint.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 0.8, 1],
          transform: const GradientRotation(0.18),
        ).createShader(band),
    );
  }

  @override
  bool shouldRepaint(_VeilPainter old) => old.colors != colors;
}
