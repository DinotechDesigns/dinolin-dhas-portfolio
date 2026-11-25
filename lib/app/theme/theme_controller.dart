import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/animations/motion.dart';
import '../../core/platform/browser.dart';
import 'app_theme.dart';

/// Owns the light or dark choice and the circular reveal between the two.
class ThemeController extends ChangeNotifier {
  ThemeController() : _brightness = _initial();

  Brightness _brightness;
  _ThemeRevealState? _reveal;

  Brightness get brightness => _brightness;

  bool get isDark => _brightness == Brightness.dark;

  static Brightness _initial() => switch (loadThemeChoice()) {
    'dark' => Brightness.dark,
    'light' => Brightness.light,
    _ => WidgetsBinding.instance.platformDispatcher.platformBrightness,
  };

  /// Switches theme; the new one opens outward from [origin].
  void toggle(Offset origin) {
    _reveal?.capture(origin);
    _brightness = isDark ? Brightness.light : Brightness.dark;
    saveThemeChoice(isDark ? 'dark' : 'light', (isDark ? AppPalette.dark : AppPalette.light).background);
    notifyListeners();
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({super.key, required ThemeController controller, required super.child})
    : super(notifier: controller);

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;
}

/// Holds a picture of the outgoing theme and cuts a growing circle out of it.
class ThemeReveal extends StatefulWidget {
  const ThemeReveal({super.key, required this.controller, required this.child});

  final ThemeController controller;
  final Widget child;

  @override
  State<ThemeReveal> createState() => _ThemeRevealState();
}

class _ThemeRevealState extends State<ThemeReveal> with SingleTickerProviderStateMixin {
  final _boundary = GlobalKey();
  late final AnimationController _progress;

  ui.Image? _before;
  Offset _origin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 820))
      ..addStatusListener(_onStatus);
    widget.controller._reveal = this;
  }

  @override
  void dispose() {
    if (widget.controller._reveal == this) widget.controller._reveal = null;
    _progress.dispose();
    _before?.dispose();
    super.dispose();
  }

  void capture(Offset origin) {
    if (reduceMotionOf(context)) return;
    final boundary = _boundary.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return;
    final ui.Image picture;
    try {
      picture = boundary.toImageSync(pixelRatio: math.min(MediaQuery.devicePixelRatioOf(context), 2));
    } on Object {
      return; // Without a snapshot the theme simply switches.
    }
    setState(() {
      _before?.dispose();
      _before = picture;
      _origin = origin;
    });
    _progress.forward(from: 0);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() {
      _before?.dispose();
      _before = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final before = _before;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(key: _boundary, child: widget.child),
        if (before != null)
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _RevealPainter(before, _origin, _progress), size: Size.infinite),
            ),
          ),
      ],
    );
  }
}

class _RevealPainter extends CustomPainter {
  _RevealPainter(this.before, this.origin, this.progress) : super(repaint: progress);

  final ui.Image before;
  final Offset origin;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final reach = [
      Offset.zero,
      size.topRight(Offset.zero),
      size.bottomLeft(Offset.zero),
      size.bottomRight(Offset.zero),
    ].map((corner) => (corner - origin).distance).reduce(math.max);
    final t = Curves.easeInOutCubic.transform(progress.value);
    final hole = Rect.fromCircle(center: origin, radius: reach * t);

    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Offset.zero & size)
          ..addOval(hole),
      )
      ..drawImageRect(
        before,
        Offset.zero & Size(before.width.toDouble(), before.height.toDouble()),
        Offset.zero & size,
        Paint()..filterQuality = FilterQuality.low,
      )
      ..restore()
      ..drawOval(
        hole,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppPalette.dark.mint.withValues(alpha: 0.7 * (1 - t)),
      );
  }

  @override
  bool shouldRepaint(_RevealPainter old) => old.before != before || old.origin != origin;
}
