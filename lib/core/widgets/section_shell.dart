import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../animations/reveal.dart';
import '../responsive/responsive.dart';

/// Shared vertical rhythm and heading for every section below the hero.
class SectionShell extends StatelessWidget {
  const SectionShell({super.key, required this.title, this.lead, required this.child});

  final String title;
  final String? lead;
  final Widget child;

  static double paddingOf(BuildContext context) => context.responsive(compact: 56, medium: 72, expanded: 88);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingOf(context)),
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              headingLevel: 2,
              child: RevealBuilder(
                builder: (context, progress) => RiseIn(
                  progress: progress,
                  child: Text(
                    title,
                    style: context.type.display(context.responsive(compact: 34, medium: 44, expanded: 54)),
                  ),
                ),
              ),
            ),
            if (lead != null) ...[
              const SizedBox(height: 16),
              Reveal(
                from: RevealFrom.left,
                delay: const Duration(milliseconds: 60),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Text(lead!, style: context.type.body(context.isCompact ? 16 : 18)),
                ),
              ),
            ],
            SizedBox(height: context.responsive(compact: 36, medium: 48, expanded: 60)),
            child,
          ],
        ),
      ),
    );
  }
}
