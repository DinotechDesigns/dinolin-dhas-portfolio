import 'package:flutter/material.dart';

import '../../app/constants/portfolio_content.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/reveal.dart';
import '../../core/cursor/pointer_effects.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/section_shell.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    const jobs = PortfolioContent.jobs;
    return SectionShell(
      title: 'Experience',
      lead: '3+ years as a Flutter Developer across two companies.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final (index, job) in jobs.indexed) _TimelineEntry(job: job, isLast: index == jobs.length - 1)],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.job, required this.isLast});

  final Job job;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final wide = context.isExpanded;
    final railX = wide ? 264.0 : 8.0;
    final indent = wide ? 312.0 : 36.0;

    return RevealBuilder(
      duration: const Duration(milliseconds: 800),
      builder: (context, progress) => CustomPaint(
        painter: _RailPainter(
          colors: context.colors,
          progress: progress,
          railX: railX,
          isCurrent: job.isCurrent,
          isLast: isLast,
        ),
        child: Stack(
          children: [
            if (wide)
              Positioned(
                left: 0,
                top: 28,
                width: railX - 36,
                child: BuildIn(
                  progress: progress,
                  from: RevealFrom.left,
                  child: _Period(job: job),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: indent, bottom: isLast ? 0 : 36),
              child: BuildIn(
                progress: progress,
                from: RevealFrom.right,
                child: _JobCard(job: job, showPeriod: !wide),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Period extends StatelessWidget {
  const _Period({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final parts = job.period.split(' – ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parts.first, style: context.type.title(20)),
        Text(
          'to ${parts.last == 'Present' ? 'present' : parts.last}',
          style: context.type.title(20, color: job.isCurrent ? context.colors.mint : context.colors.muted),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.showPeriod});

  final Job job;
  final bool showPeriod;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return SpotlightCard(
      radius: 24,
      padding: EdgeInsets.all(compact ? 22 : 32),
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showPeriod) ...[
            Text(
              job.period,
              style: context.type.label(15, color: job.isCurrent ? context.colors.mint : context.colors.muted),
            ),
            const SizedBox(height: 10),
          ],
          Semantics(
            header: true,
            headingLevel: 3,
            child: Text(job.company, style: context.type.title(compact ? 22 : 27)),
          ),
          const SizedBox(height: 6),
          Text(job.role, style: context.type.label(17)),
          const SizedBox(height: 4),
          Text(job.place, style: context.type.body(15).copyWith(height: 1.4)),
          const SizedBox(height: 22),
          _Points(job.points),
        ],
      ),
    );
  }
}

/// Two columns where there is room, filled top to bottom.
class _Points extends StatelessWidget {
  const _Points(this.points);

  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) return _column(context, points);
        final half = (points.length / 2).ceil();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _column(context, points.sublist(0, half))),
            const SizedBox(width: 32),
            Expanded(child: _column(context, points.sublist(half))),
          ],
        );
      },
    );
  }

  Widget _column(BuildContext context, List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 2,
                margin: const EdgeInsets.only(top: 12, right: 12),
                color: context.colors.mint,
              ),
              Expanded(child: Text(item, style: context.type.body(16).copyWith(height: 1.5))),
            ],
          ),
        ),
    ],
  );
}

class _RailPainter extends CustomPainter {
  _RailPainter({
    required this.colors,
    required this.progress,
    required this.railX,
    required this.isCurrent,
    required this.isLast,
  }) : super(repaint: progress);

  final AppPalette colors;
  final Animation<double> progress;
  final double railX;
  final bool isCurrent;
  final bool isLast;

  static const _dotY = 42.0;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeInOutCubic.transform(progress.value);
    if (t <= 0) return;

    final end = isLast ? size.height : size.height + _dotY;
    final rail = Rect.fromLTRB(railX - 1, _dotY, railX + 1, _dotY + (end - _dotY) * t);
    canvas.drawRect(
      rail,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isCurrent ? colors.mint : colors.indigo,
            isLast ? colors.indigo.withValues(alpha: 0) : colors.indigo,
          ],
        ).createShader(Rect.fromLTRB(railX, _dotY, railX + 1, end)),
    );

    final pop = Curves.easeOutBack.transform((progress.value / 0.5).clamp(0.0, 1.0));
    final center = Offset(railX, _dotY);
    final color = isCurrent ? colors.mint : colors.indigo;
    if (isCurrent) canvas.drawCircle(center, 15 * pop, Paint()..color = color.withValues(alpha: 0.18));
    canvas
      ..drawCircle(center, 8 * pop, Paint()..color = color)
      ..drawCircle(center, 3 * pop, Paint()..color = colors.background);
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.colors != colors ||
      old.progress != progress ||
      old.railX != railX ||
      old.isCurrent != isCurrent ||
      old.isLast != isLast;
}
