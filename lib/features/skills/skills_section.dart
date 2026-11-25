import 'package:flutter/material.dart';

import '../../app/constants/portfolio_content.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/section_shell.dart';

/// Skills drawn the way a Flutter developer reads an app: as a widget tree.
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const groups = PortfolioContent.skillGroups;
    return SectionShell(
      title: 'Skills',
      lead: 'Everything I build with, laid out as a widget tree.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: _RootNode()),
          for (final (index, group) in groups.indexed) _Branch(group: group, isLast: index == groups.length - 1),
        ],
      ),
    );
  }
}

class _RootNode extends StatelessWidget {
  const _RootNode();

  @override
  Widget build(BuildContext context) {
    return Reveal(
      from: RevealFrom.left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(colors: [context.colors.mint, context.colors.indigo]),
        ),
        child: Text('Flutter Developer', style: context.type.title(18, color: context.colors.onAccent)),
      ),
    );
  }
}

class _Branch extends StatefulWidget {
  const _Branch({required this.group, required this.isLast});

  final SkillGroup group;
  final bool isLast;

  @override
  State<_Branch> createState() => _BranchState();
}

class _BranchState extends State<_Branch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final indent = compact ? 40.0 : 64.0;
    const topGap = 34.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: RevealBuilder(
        duration: const Duration(milliseconds: 700),
        builder: (context, progress) => TweenAnimationBuilder(
          tween: Tween<double>(end: _hovered ? 1 : 0),
          duration: Motion.medium,
          builder: (context, glow, child) => CustomPaint(
            painter: _ConnectorPainter(
              colors: context.colors,
              progress: progress,
              glow: glow,
              isLast: widget.isLast,
              trunkX: 22,
              branchY: topGap + (compact ? 14 : 26),
              branchEnd: indent - 10,
            ),
            child: child,
          ),
          child: Padding(
            padding: EdgeInsets.only(left: indent, top: topGap),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_heading(progress), const SizedBox(height: 14), _leaves(progress)],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: context.isExpanded ? 320 : 240, child: _heading(progress)),
                      const SizedBox(width: 24),
                      Expanded(child: _leaves(progress)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _heading(Animation<double> progress) {
    return BuildIn(
      progress: progress,
      from: RevealFrom.left,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, headingLevel: 3, child: Text(widget.group.name, style: context.type.title(21))),
          const SizedBox(height: 4),
          Text(widget.group.note, style: context.type.body(15).copyWith(height: 1.45)),
        ],
      ),
    );
  }

  Widget _leaves(Animation<double> progress) {
    return LayoutBuilder(
      builder: (context, box) {
        // Leaves share a column grid, so every branch of the tree lines up.
        const gap = 12.0;
        final natural = box.maxWidth < 356;
        final columns = (box.maxWidth / 172).floor().clamp(2, 4);
        final width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (index, skill) in widget.group.skills.indexed)
              SizedBox(
                width: natural ? null : width.floorToDouble(),
                child: BuildIn(
                  progress: progress.drive(CurveTween(curve: Interval((0.08 + index * 0.09).clamp(0, 0.45), 1))),
                  from: RevealFrom.right,
                  child: _Leaf(label: skill, lit: _hovered),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.label, required this.lit});

  final String label;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Motion.medium,
      curve: Motion.curve,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: lit ? context.colors.mint.withValues(alpha: 0.12) : context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lit ? context.colors.mint.withValues(alpha: 0.7) : context.colors.line),
      ),
      child: Text(label, style: context.type.label(17)),
    );
  }
}

/// Trunk and elbow joining a branch to the tree.
class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.colors,
    required this.progress,
    required this.glow,
    required this.isLast,
    required this.trunkX,
    required this.branchY,
    required this.branchEnd,
  }) : super(repaint: progress);

  final AppPalette colors;
  final Animation<double> progress;
  final double glow;
  final bool isLast;
  final double trunkX;
  final double branchY;
  final double branchEnd;

  static const _corner = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeInOutCubic.transform((progress.value / 0.7).clamp(0.0, 1.0));
    if (t <= 0) return;

    final elbow = Path()
      ..moveTo(trunkX, 0)
      ..lineTo(trunkX, branchY - _corner)
      ..quadraticBezierTo(trunkX, branchY, trunkX + _corner, branchY)
      ..lineTo(branchEnd, branchY);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(colors.muted.withValues(alpha: 0.4), colors.mint, glow)!;

    if (!isLast) {
      canvas.drawLine(
        Offset(trunkX, branchY - _corner),
        Offset(trunkX, branchY - _corner + (size.height - branchY + _corner) * t),
        Paint()
          ..strokeWidth = 1.5
          ..color = colors.muted.withValues(alpha: 0.4),
      );
    }
    for (final metric in elbow.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * t), paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.colors != colors ||
      old.glow != glow ||
      old.progress != progress ||
      old.branchY != branchY ||
      old.branchEnd != branchEnd;
}
