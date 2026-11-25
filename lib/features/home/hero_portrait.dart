import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/cursor/cursor_controller.dart';
import '../../core/scroll/hero_ticker.dart';

/// The portrait standing in front of a phone-shaped panel, head breaking the
/// top edge. Panel, rings and portrait shift by different amounts as the mouse
/// moves anywhere on the page, which gives the scene depth.
class HeroPortrait extends StatelessWidget {
  const HeroPortrait({super.key, required this.width});

  final double width;

  static const _imageAspect = 1550 / 1120;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final imageHeight = w * _imageAspect;
    final panelHeight = w * 1.27;
    final radius = w * 0.13;
    final screen = MediaQuery.sizeOf(context);

    return _Parallax(
      screen: screen,
      shift: -5,
      tilt: 0.05,
      child: SizedBox(
        width: w,
        height: imageHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -w * 0.22,
              right: -w * 0.22,
              top: imageHeight * 0.04,
              height: w * 1.44,
              child: const _Orbits(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: panelHeight,
              child: _Panel(radius: radius),
            ),
            Positioned.fill(
              child: ClipPath(
                clipper: _PanelFootClipper(radius),
                child: _Parallax(
                  screen: screen,
                  shift: 9,
                  child: Transform.scale(
                    // Leaves slack so the shift never exposes an edge.
                    scale: 1.03,
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      AppAssets.profile,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.medium,
                      semanticLabel: 'Portrait of Dinolin Dhas in a black blazer and white shirt',
                    ),
                  ),
                ),
              ),
            ),
            // Grounds the jacket in the panel.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: imageHeight * 0.17,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colors.panel.last.withValues(alpha: 0),
                        context.colors.panel.last.withValues(alpha: context.colors.isDark ? 1 : 0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Moves and tilts its child with the site-wide cursor. Sideways only for the
/// shift, so the portrait stays planted on the bottom edge.
class _Parallax extends StatelessWidget {
  const _Parallax({required this.screen, required this.shift, required this.child, this.tilt = 0});

  final Size screen;
  final double shift;
  final double tilt;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cursor = CursorScope.maybeOf(context);
    if (cursor == null || reduceMotionOf(context)) return child;
    return AnimatedBuilder(
      animation: cursor,
      child: child,
      builder: (context, child) {
        final lean = cursor.normalized(screen);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0011)
            ..translateByDouble(lean.dx * shift, 0, 0, 1)
            ..rotateY(lean.dx * tilt)
            ..rotateX(-lean.dy * tilt * 0.7),
          child: child,
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.indigo.withValues(alpha: colors.isDark ? 0.34 : 0.28),
            blurRadius: 70,
            spreadRadius: -12,
            offset: const Offset(0, 28),
          ),
        ],
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors.panel),
        border: Border.all(color: Colors.white.withValues(alpha: colors.isDark ? 0.26 : 0.8), width: 1.5),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: RadialGradient(
            center: const Alignment(0.05, -0.62),
            radius: 0.75,
            colors: [
              (colors.isDark ? colors.mint : Colors.white).withValues(alpha: colors.isDark ? 0.5 : 0.9),
              (colors.isDark ? colors.mint : Colors.white).withValues(alpha: 0),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Two fine rings turning slowly behind the panel, each carrying a light.
class _Orbits extends StatefulWidget {
  const _Orbits();

  @override
  State<_Orbits> createState() => _OrbitsState();
}

class _OrbitsState extends State<_Orbits> with HeroTicker {
  @override
  Duration get loop => const Duration(seconds: 36);

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _OrbitPainter(drift, context.colors), size: Size.infinite),
  );
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.turn, this.colors) : super(repaint: turn);

  final ValueNotifier<double> turn;
  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final angle = turn.value * math.pi * 2;

    void orbit(double radius, double start, Color color) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas
        ..drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = colors.muted.withValues(alpha: 0.18),
        )
        ..drawArc(
          rect,
          start - 1.1,
          1.1,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.butt
            ..strokeWidth = 2.2
            ..shader = SweepGradient(
              startAngle: 0,
              endAngle: 1.1,
              transform: GradientRotation(start - 1.1),
              colors: [color.withValues(alpha: 0), color],
            ).createShader(rect),
        )
        ..drawCircle(center + Offset.fromDirection(start, radius), 5, Paint()..color = color);
    }

    final reach = size.shortestSide / 2;
    orbit(reach * 0.98, angle, colors.mint);
    orbit(reach * 0.84, math.pi * 1.1 - angle * 2, colors.indigo);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.colors != colors;
}

/// Keeps the area above the panel open and rounds only the bottom corners.
class _PanelFootClipper extends CustomClipper<Path> {
  const _PanelFootClipper(this.radius);

  final double radius;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Offset.zero & size,
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
    );

  @override
  bool shouldReclip(_PanelFootClipper old) => old.radius != radius;
}
