import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_theme.dart';
import '../animations/motion.dart';
import '../cursor/cursor_controller.dart';

class InteractiveState {
  const InteractiveState({required this.hovered, required this.focused, required this.pressed});

  final bool hovered;
  final bool focused;
  final bool pressed;

  bool get active => hovered || focused;
}

/// Pointer, keyboard and screen-reader behaviour for custom controls.
class Interactive extends StatefulWidget {
  const Interactive({
    super.key,
    required this.builder,
    required this.onTap,
    required this.semanticLabel,
    this.isLink = false,
  });

  final Widget Function(BuildContext context, InteractiveState state) builder;
  final VoidCallback onTap;
  final String semanticLabel;
  final bool isLink;

  @override
  State<Interactive> createState() => _InteractiveState();
}

class _InteractiveState extends State<Interactive> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;
  CursorController? _cursor;

  /// Height covered by the navigation bar, plus breathing room.
  static const _clearTop = 88.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cursor = CursorScope.maybeOf(context);
  }

  @override
  void dispose() {
    if (_hovered) _cursor?.exitHot();
    super.dispose();
  }

  void _setHovered(bool value) {
    if (value == _hovered) return;
    value ? _cursor?.enterHot() : _cursor?.exitHot();
    setState(() => _hovered = value);
  }

  void _setFocused(bool value) {
    setState(() => _focused = value);
    if (value) _keepInView();
  }

  /// Keyboard focus must never land behind the navigation bar or off screen.
  void _keepInView() {
    final position = Scrollable.maybeOf(context)?.position;
    final box = context.findRenderObject() as RenderBox?;
    if (position == null || box == null || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top >= _clearTop && top + box.size.height <= MediaQuery.sizeOf(context).height - 16) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: reduceMotionOf(context) ? Duration.zero : const Duration(milliseconds: 380),
      curve: Motion.glide,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: !widget.isLink,
      link: widget.isLink,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: _setHovered,
        onShowFocusHighlight: _setFocused,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: _focused ? Border.all(color: context.colors.text, width: 2) : null,
            ),
            // The label above already names the control.
            child: ExcludeSemantics(
              child: widget.builder(context, InteractiveState(hovered: _hovered, focused: _focused, pressed: _pressed)),
            ),
          ),
        ),
      ),
    );
  }
}
