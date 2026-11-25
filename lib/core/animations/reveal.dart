import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../responsive/responsive.dart';
import 'motion.dart';

/// Where content travels in from.
enum RevealFrom {
  /// Below while scrolling down, above while scrolling up.
  scroll,
  left,
  right,
}

/// Plays its animation each time it scrolls into view, and rewinds once it is
/// well off screen, so the page feels alive in both directions.
class RevealBuilder extends StatefulWidget {
  const RevealBuilder({super.key, required this.builder, this.duration = Motion.reveal, this.delay = Duration.zero});

  final Widget Function(BuildContext context, Animation<double> progress) builder;
  final Duration duration;
  final Duration delay;

  @override
  State<RevealBuilder> createState() => _RevealBuilderState();
}

class _RevealBuilderState extends State<RevealBuilder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  /// 1 when entering from below, -1 from above.
  final _direction = ValueNotifier<double>(1);

  /// How far off screen content must be before it rewinds.
  static const _rewindMargin = 60.0;

  ScrollPosition? _position;
  bool _shown = false;

  /// Place in the page, measured once per layout so scroll ticks only compare numbers.
  double _top = 0;
  double _height = 0;
  (double, double)? _measuredFor;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    // The delay is part of the curve, so there are no timers to cancel.
    _progress = _controller.drive(CurveTween(curve: Interval(widget.delay.inMilliseconds / total.inMilliseconds, 1)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MediaQuery.sizeOf(context); // Check again whenever the window is resized.
    _position?.removeListener(_check);
    if (reduceMotionOf(context)) {
      _position = null;
      _shown = true;
      _controller.value = 1;
      return;
    }
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_check);
    _measuredFor = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  bool _measure(ScrollPosition position) {
    final layout = (position.maxScrollExtent, position.viewportDimension);
    if (layout == _measuredFor) return true;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return false;
    _top = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset;
    _height = box.size.height;
    _measuredFor = layout;
    return true;
  }

  void _check() {
    if (!mounted) return;
    final position = _position;
    if (position == null || !position.hasContentDimensions) {
      if (!_shown) {
        _shown = true;
        _controller.forward();
      }
      return;
    }
    if (!_measure(position)) return;

    final viewport = position.viewportDimension;
    final top = _top - position.pixels;
    final bottom = top + _height;
    if (!_shown) {
      final atEnd = position.pixels >= position.maxScrollExtent - 1;
      if (top < viewport * (atEnd ? 1 : 0.93) && bottom > viewport * 0.08) {
        _shown = true;
        _controller.forward(from: 0);
      }
    } else if (top > viewport + _rewindMargin || bottom < -_rewindMargin) {
      _shown = false;
      _direction.value = bottom < 0 ? -1 : 1;
      _controller.value = 0;
    }
    if (!_shown) _direction.value = bottom < viewport * 0.5 ? -1 : 1;
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    _controller.dispose();
    _direction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RevealDirection(
    direction: _direction,
    child: Builder(builder: (context) => widget.builder(context, _progress)),
  );
}

class _RevealDirection extends InheritedWidget {
  const _RevealDirection({required this.direction, required super.child});

  final ValueNotifier<double> direction;

  static double of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_RevealDirection>()?.direction.value ?? 1;

  @override
  bool updateShouldNotify(_RevealDirection old) => direction != old.direction;
}

/// Fades and slides content in as it enters the screen.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.delay = Duration.zero, this.from = RevealFrom.scroll});

  final Widget child;
  final Duration delay;
  final RevealFrom from;

  @override
  Widget build(BuildContext context) => RevealBuilder(
    delay: delay,
    builder: (context, progress) => BuildIn(progress: progress, from: from, child: child),
  );
}

/// Headings slide out from behind their own edge.
class RiseIn extends StatelessWidget {
  const RiseIn({super.key, required this.progress, required this.child});

  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) => FractionalTranslation(
        translation: Offset(0, 1.05 * _RevealDirection.of(context) * (1 - Motion.glide.transform(progress.value))),
        child: child,
      ),
    ),
  );
}

/// The shared entrance: a quick fade with a slide that lands softly.
class BuildIn extends StatelessWidget {
  const BuildIn({super.key, required this.progress, required this.child, this.from = RevealFrom.scroll});

  final Animation<double> progress;
  final Widget child;
  final RevealFrom from;

  @override
  Widget build(BuildContext context) {
    final sideways = context.isCompact ? 44.0 : 110.0;
    return FadeTransition(
      alwaysIncludeSemantics: true,
      opacity: progress.drive(CurveTween(curve: const Interval(0, 0.45, curve: Curves.easeOut))),
      child: AnimatedBuilder(
        animation: progress,
        child: child,
        builder: (context, child) {
          final left = 1 - Motion.glide.transform(progress.value);
          return Transform.translate(
            offset: switch (from) {
              RevealFrom.scroll => Offset(0, 56 * _RevealDirection.of(context) * left),
              RevealFrom.left => Offset(-sideways * left, 0),
              RevealFrom.right => Offset(sideways * left, 0),
            },
            child: child,
          );
        },
      ),
    );
  }
}
