import 'package:flutter/material.dart';

import '../../app/constants/portfolio_content.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/reveal.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/section_shell.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      title: 'Education',
      child: Column(
        children: [
          for (final (index, item) in PortfolioContent.education.indexed)
            Reveal(
              from: index.isEven ? RevealFrom.left : RevealFrom.right,
              delay: Duration(milliseconds: 50 * index),
              child: _EducationRow(item: item),
            ),
        ],
      ),
    );
  }
}

class _EducationRow extends StatelessWidget {
  const _EducationRow({required this.item});

  final Education item;

  @override
  Widget build(BuildContext context) {
    final title = Semantics(
      header: true,
      headingLevel: 3,
      child: Text(item.title, style: context.type.title(context.isCompact ? 19 : 21)),
    );
    final school = Text(item.school, style: context.type.body(16).copyWith(height: 1.45));
    final period = Text(item.period, style: context.type.label(16, color: context.colors.muted));
    final result = Text(item.result, style: context.type.title(19, color: context.colors.mint));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: context.isExpanded
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 4), school],
                  ),
                ),
                const SizedBox(width: 32),
                SizedBox(width: 250, child: period),
                SizedBox(
                  width: 110,
                  child: Align(alignment: Alignment.topRight, child: result),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 4),
                school,
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [result, period],
                ),
              ],
            ),
    );
  }
}
