import 'package:flutter/material.dart';

import '../../app/constants/portfolio_content.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/site_actions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/tag.dart';
import 'project_visual.dart';
import 'projects_section.dart';

Future<void> showProjectDetails(BuildContext context, Project project) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Close ${project.name}',
    barrierDismissible: true,
    barrierColor: const Color(0xCC04060D),
    transitionDuration: reduceMotionOf(context) ? Duration.zero : const Duration(milliseconds: 420),
    transitionBuilder: (context, animation, _, child) {
      final curved = animation.drive(CurveTween(curve: Motion.curve));
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: curved.drive(Tween(begin: 0.96, end: 1.0)), child: child),
      );
    },
    pageBuilder: (context, _, _) => _ProjectDetails(project: project),
  );
}

class _ProjectDetails extends StatelessWidget {
  const _ProjectDetails({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Material(
              color: context.colors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(compact ? 24 : 32),
                side: BorderSide(color: context.colors.line),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: compact ? 260 : 360,
                          child: ProjectVisualPanel(project: project, active: true),
                        ),
                        Padding(padding: EdgeInsets.all(compact ? 24 : 40), child: _body(context)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: IconButton.filled(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: context.colors.background.withValues(alpha: 0.85),
                        foregroundColor: context.colors.text,
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectHeading(project: project),
        const SizedBox(height: 18),
        Text(project.summary, style: context.type.body(17)),
        const SizedBox(height: 24),
        for (final detail in project.details)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3, right: 12),
                  child: Icon(Icons.check_rounded, size: 18, color: context.colors.mint),
                ),
                Expanded(
                  child: Text(detail, style: context.type.body(16, color: context.colors.text).copyWith(height: 1.5)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final tech in project.tech) Tag(tech)]),
        if (project.visual == ProjectVisual.pipeline) ...[
          const SizedBox(height: 20),
          Text('The artwork illustrates the payment flow. It is not an app screenshot.', style: context.type.body(14)),
        ],
        if (project.storeUrl != null) ...[
          const SizedBox(height: 26),
          AppButton(label: 'View project', isLink: true, onPressed: () => SiteActions.open(context, project.storeUrl!)),
        ],
      ],
    );
  }
}
