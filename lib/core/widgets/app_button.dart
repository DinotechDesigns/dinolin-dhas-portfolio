import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../animations/motion.dart';
import '../cursor/pointer_effects.dart';
import 'interactive.dart';

enum AppButtonStyle { primary, outline, quiet }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.leading,
    this.expand = false,
    this.dense = false,
    this.isLink = false,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonStyle style;
  final Widget? leading;
  final bool expand;

  /// Tighter sides for two buttons sharing a phone's width.
  final bool dense;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    final button = Interactive(
      onTap: onPressed,
      isLink: isLink,
      semanticLabel: label,
      builder: (context, state) => AnimatedScale(
        scale: state.pressed ? 0.97 : 1,
        duration: Motion.quick,
        curve: Motion.curve,
        child: style == AppButtonStyle.quiet ? _QuietBody(label, state) : _solid(context, state),
      ),
    );
    // Full-width buttons have nowhere to go, so only free-standing ones pull.
    return expand ? button : Magnetic(child: button);
  }

  Widget _solid(BuildContext context, InteractiveState state) {
    final colors = context.colors;
    final primary = style == AppButtonStyle.primary;
    final foreground = primary ? colors.onAccent : colors.text;
    return AnimatedContainer(
      duration: Motion.medium,
      curve: Motion.curve,
      constraints: const BoxConstraints(minHeight: 52),
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 24, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: primary
            ? LinearGradient(
                colors: [colors.mint, colors.indigo],
                begin: Alignment(state.active ? -0.2 : -1, 0),
                end: Alignment(state.active ? 1.8 : 1, 0),
              )
            : null,
        color: primary ? null : colors.text.withValues(alpha: state.active ? 0.1 : 0.04),
        border: Border.all(
          color: state.focused
              ? colors.text
              : primary
              ? Colors.transparent
              : colors.text.withValues(alpha: state.hovered ? 0.4 : 0.18),
          width: 1.5,
        ),
        boxShadow: [
          if (primary)
            BoxShadow(
              color: colors.indigo.withValues(alpha: state.active ? 0.42 : 0.2),
              blurRadius: state.active ? 30 : 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(color: foreground, size: 18),
              child: leading!,
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.type.label(dense ? 15 : 16, color: foreground, weight: 620),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text button whose underline grows from a short stroke to the full label.
class _QuietBody extends StatelessWidget {
  const _QuietBody(this.label, this.state);

  final String label;
  final InteractiveState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Text(label, style: context.type.label(16, weight: 600)),
            Positioned(
              left: 0,
              right: 0,
              bottom: -6,
              child: AnimatedFractionallySizedBox(
                duration: Motion.medium,
                curve: Motion.curve,
                alignment: Alignment.centerLeft,
                widthFactor: state.active ? 1 : 0.35,
                child: Container(height: 2, color: context.colors.mint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
