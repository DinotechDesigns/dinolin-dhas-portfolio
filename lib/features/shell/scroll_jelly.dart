import 'package:flutter/widgets.dart';

import '../../core/animations/spring.dart';

/// Lets sections trail the scroll a little and bounce back into place when it
/// stops. Each section uses its own share of the movement, so they separate
/// and settle like a loose stack rather than one rigid sheet.
class ScrollJelly {
  ScrollJelly(TickerProvider vsync, this._scroll) {
    _ticker = SpringTicker(vsync, _tick);
    _scroll.addListener(_onScroll);
  }

  final ScrollController _scroll;
  final _spring = Spring(stiffness: 150, damping: 8.5);
  late final SpringTicker _ticker;

  /// Pixels of lag; positive while content is travelling up the screen.
  final offset = ValueNotifier<double>(0);

  bool enabled = true;
  double _lastPixels = 0;
  double _velocity = 0;
  double _quiet = 0;

  static const _maxLag = 26.0;

  void _onScroll() {
    if (!enabled || !_scroll.hasClients) return;
    _ticker.wake();
  }

  bool _tick(double dt) {
    final pixels = _scroll.hasClients ? _scroll.position.pixels : _lastPixels;
    final delta = pixels - _lastPixels;
    _lastPixels = pixels;
    // Smoothed velocity; ignores the first frame after a jump.
    final measured = delta.abs() > 2000 ? 0.0 : delta / dt;
    _velocity += (measured - _velocity) * 0.35;
    _quiet = delta == 0 ? _quiet + dt : 0;

    _spring.target = (_velocity * 0.022).clamp(-_maxLag, _maxLag);
    if (_quiet > 0.04) _spring.target = 0;
    _spring.step(dt);
    offset.value = _spring.value;
    return !(_quiet > 0.1 && _spring.isAtRest);
  }

  void dispose() {
    _scroll.removeListener(_onScroll);
    _ticker.dispose();
    offset.dispose();
  }
}

class JellySection extends StatelessWidget {
  const JellySection({super.key, required this.jelly, required this.share, required this.child});

  final ScrollJelly jelly;

  /// How much of the lag this section takes, 0 to 1.
  final double share;
  final Widget child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: jelly.offset,
    child: child,
    builder: (context, lag, child) => Transform.translate(offset: Offset(0, lag * share), child: child),
  );
}
