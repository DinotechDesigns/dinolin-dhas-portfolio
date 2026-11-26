import 'dart:math' as math;

import 'package:flutter/scheduler.dart';

/// A small damped spring. Under-damped settings overshoot and wobble before
/// settling, which gives motion a physical, slightly playful feel.
class Spring {
  Spring({this.stiffness = 170, this.damping = 12});

  final double stiffness;
  final double damping;

  double value = 0;
  double velocity = 0;
  double target = 0;

  bool get isAtRest => (value - target).abs() < 0.01 && velocity.abs() < 0.05;

  void step(double dt) {
    // Sub-steps keep it stable when a frame arrives late.
    final steps = math.max(1, (dt / (1 / 120)).ceil());
    final h = dt / steps;
    for (var i = 0; i < steps; i++) {
      final force = -stiffness * (value - target) - damping * velocity;
      velocity += force * h;
      value += velocity * h;
    }
  }
}

/// Runs [onTick] every frame while it reports activity, and sleeps otherwise.
class SpringTicker {
  SpringTicker(TickerProvider vsync, this.onTick) {
    _ticker = vsync.createTicker(_tick);
  }

  /// Returns true while anything is still moving.
  final bool Function(double dt) onTick;
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  void wake() {
    if (_ticker.isActive) return;
    _last = Duration.zero;
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero ? 1 / 60 : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.001, 0.05);
    _last = elapsed;
    if (!onTick(dt)) _ticker.stop();
  }

  void dispose() => _ticker.dispose();
}
