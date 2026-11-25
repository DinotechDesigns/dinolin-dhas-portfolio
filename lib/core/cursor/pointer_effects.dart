import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../app/theme/app_theme.dart';
import '../animations/motion.dart';

/// Pulls a control a few pixels toward the mouse.
class Magnetic extends StatefulWidget {
  const Magnetic({super.key, required this.child, this.strength = 7});

  final Widget child;
  final double strength;

  @override
  State<Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<Magnetic> {
  Offset _pull = Offset.zero;

  void _follow(PointerHoverEvent event) {
    final size = context.size;
    if (event.kind != PointerDeviceKind.mouse || size == null || size.isEmpty || reduceMotionOf(context)) return;
    final offset = Offset(
      (event.localPosition.dx / size.width - 0.5) * widget.strength * 2,
      (event.localPosition.dy / size.height - 0.5) * widget.strength,
    );
    setState(() => _pull = offset);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onHover: _follow,
      onExit: (_) => setState(() => _pull = Offset.zero),
      child: TweenAnimationBuilder(
        tween: Tween(end: _pull),
        duration: const Duration(milliseconds: 260),
        curve: Motion.curve,
        child: widget.child,
        builder: (context, value, child) => Transform.translate(offset: value, child: child),
      ),
    );
  }
}

/// Card surface that lights up under the mouse and, optionally, tilts to it.
class SpotlightCard extends StatefulWidget {
  const SpotlightCard({
    super.key,
    required this.builder,
    required this.radius,
    this.tilt = 0,
    this.shadowColor,
    this.padding = EdgeInsets.zero,
  });

  final Widget Function(BuildContext context, bool hovered) builder;
  final double radius;

  /// Largest tilt in radians. Zero keeps the card flat.
  final double tilt;

  /// Coloured shadow shown on hover.
  final Color? shadowColor;
  final EdgeInsets padding;

  @override
  State<SpotlightCard> createState() => _SpotlightCardState();
}

class _SpotlightCardState extends State<SpotlightCard> with SingleTickerProviderStateMixin {
  late final AnimationController _lift = AnimationController(vsync: this, duration: Motion.medium);
  final _pointer = ValueNotifier(Offset.zero);
  bool _hovered = false;

  @override
  void dispose() {
    _lift.dispose();
    _pointer.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    setState(() => _hovered = value);
    value ? _lift.forward() : _lift.reverse();
  }

  Matrix4 _transform(Size size) {
    final t = Motion.curve.transform(_lift.value);
    final x = (_pointer.value.dx / size.width - 0.5).clamp(-0.5, 0.5);
    final y = (_pointer.value.dy / size.height - 0.5).clamp(-0.5, 0.5);
    return Matrix4.identity()
      ..setEntry(3, 2, 0.0009)
      ..rotateX(-y * widget.tilt * t)
      ..rotateY(x * widget.tilt * t);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glow = widget.shadowColor ?? colors.indigo;

    final card = CustomPaint(
      foregroundPainter: _SpotlightPainter(_pointer, _lift, colors, widget.radius),
      child: AnimatedContainer(
        duration: Motion.medium,
        curve: Motion.curve,
        clipBehavior: Clip.antiAlias,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _hovered ? colors.surfaceHigh : colors.surface,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: colors.line),
          boxShadow: [
            BoxShadow(
              color: _hovered ? glow.withValues(alpha: colors.isDark ? 0.38 : 0.26) : colors.shadow,
              blurRadius: _hovered ? 46 : 26,
              spreadRadius: _hovered ? -14 : -10,
              offset: Offset(0, _hovered ? 24 : 14),
            ),
          ],
        ),
        child: widget.builder(context, _hovered),
      ),
    );

    return MouseRegion(
      opaque: false,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      onHover: (event) => _pointer.value = event.localPosition,
      child: widget.tilt == 0 || reduceMotionOf(context)
          ? card
          : AnimatedBuilder(
              animation: Listenable.merge([_pointer, _lift]),
              child: card,
              builder: (_, child) => Transform(
                alignment: Alignment.center,
                // The size is only read once hovered, after the first layout.
                transform: _lift.value == 0 ? Matrix4.identity() : _transform(context.size ?? const Size(1, 1)),
                child: child,
              ),
            ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.pointer, this.lift, this.colors, this.radius)
    : super(repaint: Listenable.merge([pointer, lift]));

  final ValueNotifier<Offset> pointer;
  final Animation<double> lift;
  final AppPalette colors;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (lift.value == 0) return;
    final shape = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.75), Radius.circular(radius));

    Shader light(Color color, double alpha, double reach) => RadialGradient(
      colors: [
        color.withValues(alpha: alpha * lift.value),
        color.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: pointer.value, radius: reach));

    canvas
      ..drawRRect(shape, Paint()..shader = light(colors.indigo, colors.isDark ? 0.16 : 0.08, 300))
      ..drawRRect(
        shape,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..shader = light(colors.mint, 0.95, 260),
      );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.colors != colors || old.radius != radius;
}
