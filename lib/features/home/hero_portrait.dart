import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/animations/spring.dart';
import '../../core/cursor/cursor_controller.dart';

/// The portrait on its own, with a soft light behind it. It leans toward the
/// mouse on a spring, so it overshoots a little and settles with a wobble.
class HeroPortrait extends StatelessWidget {
  const HeroPortrait({super.key, required this.width});

  final double width;

  static const _imageAspect = 1550 / 1120;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = w * _imageAspect;
    final colors = context.colors;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Light behind the shoulders, so the dark jacket separates from the page.
          Positioned(
            left: -w * 0.25,
            right: -w * 0.25,
            top: h * 0.12,
            bottom: -h * 0.05,
            child: IgnorePointer(
              child: _SpringLean(
                shift: -10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.5,
                      colors: [
                        colors.indigo.withValues(alpha: colors.isDark ? 0.42 : 0.3),
                        colors.mint.withValues(alpha: colors.isDark ? 0.12 : 0.1),
                        colors.mint.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: _SpringLean(
              shift: 12,
              tilt: 0.06,
              // The jacket already dissolves into transparency at the bottom of the image.
              child: Image.asset(
                AppAssets.profile,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium,
                semanticLabel: 'Portrait of Dinolin Dhas in a black blazer and white shirt',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Follows the site-wide cursor through a spring: quick to react, a small
/// overshoot, then a settle. Sideways shift only, so the figure stays grounded.
class _SpringLean extends StatefulWidget {
  const _SpringLean({required this.shift, required this.child, this.tilt = 0});

  final double shift;
  final double tilt;
  final Widget child;

  @override
  State<_SpringLean> createState() => _SpringLeanState();
}

class _SpringLeanState extends State<_SpringLean> with SingleTickerProviderStateMixin {
  final _x = Spring(stiffness: 120, damping: 9);
  final _y = Spring(stiffness: 120, damping: 9);
  late final SpringTicker _ticker;
  final _lean = ValueNotifier(Offset.zero);
  CursorController? _cursor;

  @override
  void initState() {
    super.initState();
    _ticker = SpringTicker(this, (dt) {
      _x.step(dt);
      _y.step(dt);
      _lean.value = Offset(_x.value, _y.value);
      return !(_x.isAtRest && _y.isAtRest);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cursor?.removeListener(_follow);
    _cursor = reduceMotionOf(context) ? null : CursorScope.maybeOf(context);
    _cursor?.addListener(_follow);
  }

  void _follow() {
    final target = _cursor!.normalized(MediaQuery.sizeOf(context));
    if (target.dx == _x.target && target.dy == _y.target) return;
    _x.target = target.dx;
    _y.target = target.dy;
    _ticker.wake();
  }

  @override
  void dispose() {
    _cursor?.removeListener(_follow);
    _ticker.dispose();
    _lean.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _lean,
      child: widget.child,
      builder: (context, lean, child) => Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0011)
          ..translateByDouble(lean.dx * widget.shift, 0, 0, 1)
          ..rotateY(lean.dx * widget.tilt)
          ..rotateX(-lean.dy * widget.tilt * 0.6),
        child: child,
      ),
    );
  }
}
