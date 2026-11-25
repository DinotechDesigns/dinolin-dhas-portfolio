import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../app/theme/app_theme.dart';
import '../animations/motion.dart';
import 'cursor_controller.dart';

/// Site-wide cursor: the system pointer stays, and a ring with a fading tail
/// follows it. The ticker sleeps whenever the ring has caught up.
class CursorLayer extends StatefulWidget {
  const CursorLayer({super.key, required this.child});

  final Widget child;

  @override
  State<CursorLayer> createState() => _CursorLayerState();
}

class _CursorLayerState extends State<CursorLayer> with SingleTickerProviderStateMixin {
  final _cursor = CursorController();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _cursor.onWake = _wake;
  }

  @override
  void dispose() {
    _cursor.onWake = null;
    _ticker.dispose();
    _cursor.dispose();
    super.dispose();
  }

  void _wake() {
    if (!mounted || _cursor.target == null || _ticker.isActive) return;
    _last = Duration.zero;
    _ticker.start();
  }

  void _move(PointerEvent event) {
    if (event.kind != PointerDeviceKind.mouse || reduceMotionOf(context)) return;
    if (_cursor.target == null || !_cursor.visible) {
      _cursor.position = event.position;
      _cursor.trail.fillRange(0, _cursor.trail.length, event.position);
    }
    _cursor
      ..target = event.position
      ..visible = true;
    _wake();
  }

  void _press(PointerEvent event, bool down) {
    if (event.kind != PointerDeviceKind.mouse) return;
    _cursor.pressed = down;
    _wake();
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.001, 0.05);
    _last = elapsed;
    // Frame-rate independent easing.
    double ease(double speed) => 1 - math.exp(-dt * speed);

    final target = _cursor.target!;
    _cursor.position = Offset.lerp(_cursor.position, target, ease(16))!;
    var lead = _cursor.position;
    for (var i = 0; i < _cursor.trail.length; i++) {
      _cursor.trail[i] = Offset.lerp(_cursor.trail[i], lead, ease(30))!;
      lead = _cursor.trail[i];
    }
    _cursor
      ..heat += ((_cursor.isHot ? 1 : 0) - _cursor.heat) * ease(13)
      ..press += ((_cursor.pressed ? 1 : 0) - _cursor.press) * ease(20)
      ..presence += ((_cursor.visible ? 1 : 0) - _cursor.presence) * ease(8);

    final settled =
        (_cursor.trail.last - target).distance < 0.3 &&
        (_cursor.heat - (_cursor.isHot ? 1 : 0)).abs() < 0.01 &&
        (_cursor.press - (_cursor.pressed ? 1 : 0)).abs() < 0.01 &&
        (_cursor.presence - (_cursor.visible ? 1 : 0)).abs() < 0.01;
    _cursor.notify();
    if (settled) _ticker.stop();
  }

  @override
  Widget build(BuildContext context) {
    return CursorScope(
      controller: _cursor,
      child: MouseRegion(
        opaque: false,
        onExit: (_) {
          _cursor.visible = false;
          _wake();
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: _move,
          onPointerMove: _move,
          onPointerDown: (event) => _press(event, true),
          onPointerUp: (event) => _press(event, false),
          onPointerCancel: (event) => _press(event, false),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _CursorPainter(_cursor, context.colors), size: Size.infinite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CursorPainter extends CustomPainter {
  _CursorPainter(this.cursor, this.colors) : super(repaint: cursor);

  final CursorController cursor;
  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = cursor.presence;
    if (cursor.target == null || alpha < 0.01) return;

    final count = cursor.trail.length;
    for (var i = count - 1; i > 0; i--) {
      final fade = 1 - i / count;
      canvas.drawLine(
        cursor.trail[i],
        cursor.trail[i - 1],
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1 + 4 * fade
          ..color = Color.lerp(colors.indigo, colors.mint, fade)!.withValues(alpha: 0.42 * fade * alpha),
      );
    }

    final radius = (17 + 12 * cursor.heat) * (1 - 0.28 * cursor.press);
    canvas
      ..drawCircle(
        cursor.position,
        radius,
        Paint()..color = colors.mint.withValues(alpha: (0.05 + 0.1 * cursor.heat) * alpha),
      )
      ..drawCircle(
        cursor.position,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Color.lerp(colors.indigo, colors.mint, cursor.heat)!.withValues(alpha: 0.85 * alpha),
      );
  }

  @override
  bool shouldRepaint(_CursorPainter old) => old.cursor != cursor || old.colors != colors;
}

/// Soft light behind the page content that travels with the mouse.
class CursorGlow extends StatelessWidget {
  const CursorGlow({super.key});

  @override
  Widget build(BuildContext context) {
    final cursor = CursorScope.maybeOf(context);
    if (cursor == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _GlowPainter(cursor, context.colors), size: Size.infinite),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.cursor, this.colors) : super(repaint: cursor);

  final CursorController cursor;
  final AppPalette colors;

  static const _radius = 340.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (cursor.target == null || cursor.presence < 0.01) return;
    final rect = Rect.fromCircle(center: cursor.position, radius: _radius);
    final strength = (colors.isDark ? 0.2 : 0.13) * cursor.presence;
    canvas.drawCircle(
      rect.center,
      _radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.indigo.withValues(alpha: strength),
            colors.mint.withValues(alpha: strength * 0.35),
            colors.mint.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.cursor != cursor || old.colors != colors;
}
