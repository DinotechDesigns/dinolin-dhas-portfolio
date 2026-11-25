import 'dart:async';

import 'package:flutter/widgets.dart';

import '../animations/motion.dart';

/// A slow loop for decoration at the top of the page. It advances at a modest
/// frame rate, because nothing here moves fast enough to need more, and stops
/// while that part of the page is scrolled away or motion is unwelcome.
mixin HeroTicker<T extends StatefulWidget> on State<T> {
  Duration get loop;

  static const _frame = Duration(milliseconds: 40);

  /// 0 to 1, repeating.
  final drift = ValueNotifier<double>(0);

  ScrollPosition? _position;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_sync);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_sync);
    _sync();
  }

  void _sync() {
    final position = _position;
    final onScreen = position == null || !position.hasPixels || position.pixels < MediaQuery.sizeOf(context).height;
    if (onScreen && !reduceMotionOf(context)) {
      _timer ??= Timer.periodic(_frame, (_) {
        drift.value = (drift.value + _frame.inMicroseconds / loop.inMicroseconds) % 1;
      });
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _position?.removeListener(_sync);
    drift.dispose();
    super.dispose();
  }
}
