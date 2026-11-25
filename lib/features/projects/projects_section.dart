import 'package:flutter/material.dart';

import '../../app/constants/portfolio_content.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/reveal.dart';
import '../../core/cursor/pointer_effects.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/section_shell.dart';
import '../../core/widgets/tag.dart';
import 'project_details.dart';
import 'project_visual.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const projects = PortfolioContent.projects;
    return SectionShell(
      title: 'Projects',
      lead: 'Three business apps: people operations, customer relationships and commerce.',
      child: Column(
        children: [
          for (final (index, project) in projects.indexed) ...[
            if (index > 0) SizedBox(height: context.isCompact ? 24 : 36),
            RevealBuilder(
              duration: const Duration(milliseconds: 760),
              builder: (context, progress) => BuildIn(
                progress: progress,
                child: ProjectCard(project: project, visualFirst: index.isOdd, progress: progress),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.visualFirst, required this.progress});

  final Project project;

  /// Entrance of the card; its two halves slide in from their own sides.
  final Animation<double> progress;
  final bool visualFirst;

  double _stackedVisualHeight(BuildContext context) {
    if (!context.isCompact) return 380;
    // Store artwork is short, so a tall panel would leave it stranded at the bottom.
    return project.visual == ProjectVisual.storeArt ? 210 : 300;
  }

  @override
  Widget build(BuildContext context) {
    final sideBySide = context.screenWidth >= 860;
    final inner = progress.drive(CurveTween(curve: const Interval(0.12, 1)));
    final info = BuildIn(
      progress: inner,
      from: sideBySide && visualFirst ? RevealFrom.right : RevealFrom.left,
      child: _Info(project: project),
    );

    return SpotlightCard(
      radius: 32,
      tilt: sideBySide ? 0.05 : 0,
      shadowColor: project.colors.first,
      builder: (context, hovered) {
        final visual = BuildIn(
          progress: inner,
          from: sideBySide && visualFirst ? RevealFrom.left : RevealFrom.right,
          child: ProjectVisualPanel(project: project, active: hovered),
        );
        return sideBySide
            ? _SplitLayout(visual: visual, info: info, visualFirst: visualFirst)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: _stackedVisualHeight(context), child: visual),
                  info,
                ],
              );
      },
    );
  }
}

/// The text decides the height; the visual fills whatever that turns out to be.
class _SplitLayout extends StatelessWidget {
  const _SplitLayout({required this.visual, required this.info, required this.visualFirst});

  final Widget visual;
  final Widget info;
  final bool visualFirst;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final visualWidth = box.maxWidth * 0.54;
        final side = visualFirst ? Alignment.centerRight : Alignment.centerLeft;
        return Stack(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 480),
              child: Align(
                heightFactor: 1,
                alignment: side,
                child: SizedBox(width: box.maxWidth - visualWidth, child: info),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: visualFirst ? 0 : null,
              right: visualFirst ? null : 0,
              width: visualWidth,
              child: visual,
            ),
          ],
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return Padding(
      padding: EdgeInsets.all(context.responsive(compact: 24, medium: 32, expanded: 44)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProjectHeading(project: project),
          const SizedBox(height: 20),
          Text(project.summary, style: context.type.body(compact ? 16 : 17).copyWith(height: 1.55)),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'My part: ', style: context.type.label(16)),
                TextSpan(text: project.contribution),
              ],
            ),
            style: context.type.body(16).copyWith(height: 1.55),
          ),
          const SizedBox(height: 22),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final tech in project.tech) Tag(tech)]),
          const SizedBox(height: 28),
          AppButton(
            label: 'Explore ${project.name}',
            style: AppButtonStyle.outline,
            onPressed: () => showProjectDetails(context, project),
          ),
        ],
      ),
    );
  }
}

/// Icon (when there is a real one), name and product type.
class ProjectHeading extends StatelessWidget {
  const ProjectHeading({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (project.icon != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(project.icon!, width: 56, height: 56, semanticLabel: '${project.name} app icon'),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                headingLevel: 3,
                child: Text(project.name, style: context.type.title(context.isCompact ? 24 : 28)),
              ),
              Text(project.kind, style: context.type.label(15, color: context.colors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}
