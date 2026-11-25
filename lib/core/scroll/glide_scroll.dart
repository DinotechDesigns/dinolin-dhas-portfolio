import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../animations/motion.dart';

/// Scroll controller whose mouse wheel glides. Each wheel step moves the
/// destination of one continuous motion, so fast scrolling never stutters and
/// no distance is lost. Trackpads already send fine steps and stay direct.
class GlideScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) =>
      _GlidePosition(physics: physics, context: context, oldPosition: oldPosition);
}

class _GlidePosition extends ScrollPositionWithSingleContext {
  _GlidePosition({required super.physics, required super.context, super.oldPosition});

  /// Anything larger than this is a wheel notch rather than a trackpad step.
  static const _notch = 40.0;

  @override
  void pointerScroll(double delta) {
    final current = activity;
    final gliding = current is _GlideActivity;
    final host = context.notificationContext;
    final reduced = host != null && reduceMotionOf(host);
    if (reduced || (!gliding && delta.abs() < _notch)) {
      super.pointerScroll(delta);
      return;
    }
    final from = gliding ? current.target : pixels;
    final target = math.min(math.max(from + delta, minScrollExtent), maxScrollExtent);
    if (gliding) {
      current.target = target;
      return;
    }
    if (target == pixels) return;
    updateUserScrollDirection(delta > 0 ? ScrollDirection.reverse : ScrollDirection.forward);
    beginActivity(_GlideActivity(this, vsync: context.vsync, target: target));
  }
}

class _GlideActivity extends ScrollActivity {
  _GlideActivity(this._position, {required TickerProvider vsync, required this.target}) : super(_position) {
    _ticker = vsync.createTicker(_tick)..start();
  }

  static const _speed = 11.0;

  final _GlidePosition _position;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _velocity = 0;

  double target;

  void _tick(Duration elapsed) {
    final dt = math.min((elapsed - _last).inMicroseconds / 1e6, 0.05);
    _last = elapsed;
    if (dt <= 0) return;
    final remaining = target - _position.pixels;
    final arrived = remaining.abs() < 0.5;
    final step = arrived ? remaining : remaining * (1 - math.exp(-dt * _speed));
    _velocity = step / dt;
    final overscroll = _position.setPixels(_position.pixels + step);
    if (arrived || overscroll != 0) _position.goIdle();
  }

  @override
  bool get isScrolling => true;

  @override
  bool get shouldIgnorePointer => false;

  @override
  double get velocity => _velocity;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
