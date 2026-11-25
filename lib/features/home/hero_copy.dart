import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/site_actions.dart';
import '../../core/widgets/app_button.dart';

class HeroCopy extends StatelessWidget {
  const HeroCopy({super.key, required this.nameSize, required this.wrap, required this.onNavigate});

  final double nameSize;

  /// Wraps an element in the hero's staggered entrance.
  final Widget Function(int index, Widget child) wrap;
  final ValueChanged<SectionId> onNavigate;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        wrap(
          0,
          Semantics(
            header: true,
            headingLevel: 1,
            child: Text('Dinolin\nDhas', style: context.type.display(nameSize).copyWith(height: 0.98)),
          ),
        ),
        SizedBox(height: compact ? 12 : 24),
        wrap(
          1,
          Wrap(
            spacing: 18,
            runSpacing: 2,
            children: [
              Text('Flutter Developer', style: context.type.title(compact ? 19 : 22, color: context.colors.mint)),
              Text(
                'Mobile Application Developer',
                style: context.type.title(compact ? 19 : 22, color: context.colors.muted),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 16 : 28),
        wrap(
          2,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Mobile apps, from first widget to store release.',
              style: context.type.title(compact ? 24 : 30).copyWith(height: 1.2),
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        wrap(
          3,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              '3+ years building cross-platform apps for Android and iOS, and connecting them to the REST APIs, '
              'Spring Boot services and databases behind them.',
              style: compact ? context.type.body(16).copyWith(height: 1.5) : context.type.body(18),
            ),
          ),
        ),
        SizedBox(height: compact ? 22 : 36),
        wrap(4, _actions(context, compact)),
      ],
    );
  }

  Widget _actions(BuildContext context, bool compact) {
    final explore = AppButton(
      label: 'Explore my work',
      expand: compact,
      dense: compact,
      onPressed: () => onNavigate(SectionId.projects),
    );
    final resume = AppButton(
      label: 'Download resume',
      style: AppButtonStyle.outline,
      expand: compact,
      dense: compact,
      onPressed: () => SiteActions.resume(context),
    );
    if (compact) {
      if (context.screenWidth < 350) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [explore, const SizedBox(height: 12), resume],
        );
      }
      return Row(
        children: [
          Expanded(child: explore),
          const SizedBox(width: 12),
          Expanded(child: resume),
        ],
      );
    }
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        explore,
        resume,
        ConnectLink(onNavigate: onNavigate),
      ],
    );
  }
}

class ConnectLink extends StatelessWidget {
  const ConnectLink({super.key, required this.onNavigate});

  final ValueChanged<SectionId> onNavigate;

  @override
  Widget build(BuildContext context) => AppButton(
    label: 'Let\u2019s connect',
    style: AppButtonStyle.quiet,
    onPressed: () => onNavigate(SectionId.contact),
  );
}
