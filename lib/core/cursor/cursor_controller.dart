import 'package:flutter/widgets.dart';

/// Pointer state shared by everything that reacts to the mouse.
class CursorController extends ChangeNotifier {
  /// Null until a mouse is seen, so touch visitors get none of this.
  Offset? target;

  /// [target] followed with a little inertia.
  Offset position = Offset.zero;

  /// Short tail behind the ring, newest first.
  final List<Offset> trail = List.filled(9, Offset.zero);

  /// 0 to 1 easings toward the hovered, pressed and visible states.
  double heat = 0;
  double press = 0;
  double presence = 0;

  /// Smoothed speed of the ring, px per second; it stretches along this.
  Offset velocity = Offset.zero;

  bool visible = false;
  bool pressed = false;
  int _hotCount = 0;

  bool get isHot => _hotCount > 0;

  VoidCallback? onWake;

  void enterHot() {
    _hotCount++;
    onWake?.call();
  }

  void exitHot() {
    if (_hotCount > 0) _hotCount--;
    onWake?.call();
  }

  /// Pointer position as -1..1 on each axis, or zero without a mouse.
  Offset normalized(Size size) => target == null || size.isEmpty
      ? Offset.zero
      : Offset((position.dx / size.width) * 2 - 1, (position.dy / size.height) * 2 - 1) * presence;

  void notify() => notifyListeners();
}

class CursorScope extends InheritedWidget {
  const CursorScope({super.key, required this.controller, required super.child});

  final CursorController controller;

  static CursorController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CursorScope>()?.controller;

  @override
  bool updateShouldNotify(CursorScope old) => controller != old.controller;
}
