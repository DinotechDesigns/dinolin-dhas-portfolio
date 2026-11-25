import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/site_actions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/interactive.dart';

Future<void> showMobileMenu(
  BuildContext context, {
  required SectionId active,
  required ValueChanged<SectionId> onNavigate,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Close menu',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: reduceMotionOf(context) ? Duration.zero : const Duration(milliseconds: 420),
    transitionBuilder: (_, _, _, child) => child,
    pageBuilder: (dialogContext, animation, _) => _MobileMenu(
      animation: animation,
      active: active,
      onSelect: (id) {
        Navigator.of(dialogContext).pop();
        onNavigate(id);
      },
      onResume: () {
        Navigator.of(dialogContext).pop();
        SiteActions.resume(context);
      },
    ),
  );
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({required this.animation, required this.active, required this.onSelect, required this.onResume});

  final Animation<double> animation;
  final SectionId active;
  final ValueChanged<SectionId> onSelect;
  final VoidCallback onResume;

  Animation<double> _step(int index) =>
      animation.drive(CurveTween(curve: Interval(0.1 + index * 0.06, 0.55 + index * 0.06, curve: Motion.curve)));

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: const Interval(0, 0.4))),
      child: Material(
        color: context.colors.background,
        child: SafeArea(
          child: ContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 76,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Close menu',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: context.colors.text),
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final id in SectionId.values)
                          _MenuEntry(progress: _step(id.index), child: _item(context, id)),
                        const SizedBox(height: 28),
                        _MenuEntry(
                          progress: _step(SectionId.values.length),
                          child: AppButton(
                            label: 'Download resume',
                            style: AppButtonStyle.outline,
                            expand: true,
                            onPressed: onResume,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, SectionId id) {
    final current = id == active;
    return Interactive(
      onTap: () => onSelect(id),
      semanticLabel: id.label,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (current)
              Container(width: 20, height: 3, margin: const EdgeInsets.only(right: 14), color: context.colors.mint),
            Text(
              id.label,
              style: context.type.display(
                32,
                color: current || state.active ? context.colors.text : context.colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuEntry extends StatelessWidget {
  const _MenuEntry({required this.progress, required this.child});

  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeTransition(
    alwaysIncludeSemantics: true,
    opacity: progress,
    child: SlideTransition(
      position: progress.drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero)),
      child: child,
    ),
  );
}
