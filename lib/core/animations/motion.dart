import 'package:flutter/widgets.dart';

import '../platform/browser.dart';

final bool _browserReduced = browserPrefersReducedMotion();

/// True when the visitor asked their system or browser for less movement.
bool reduceMotionOf(BuildContext context) => _browserReduced || MediaQuery.disableAnimationsOf(context);

abstract final class Motion {
  static const quick = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 360);
  static const reveal = Duration(milliseconds: 620);
  static const curve = Curves.easeOutCubic;

  /// Long, soft landing used for entrances and page travel.
  static const glide = Cubic(0.16, 1, 0.3, 1);
}
