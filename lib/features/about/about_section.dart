import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/reveal.dart';
import '../../core/cursor/pointer_effects.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/section_shell.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      title: 'About me',
      child: context.isCompact
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_Photo(), SizedBox(height: 36), _Story()],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 5, child: _Photo()),
                SizedBox(width: context.isExpanded ? 80 : 44),
                const Expanded(flex: 7, child: _Story()),
              ],
            ),
    );
  }
}

/// Black-and-white portrait on a lit panel that follows the theme.
class _Photo extends StatelessWidget {
  const _Photo();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Reveal(
      from: RevealFrom.left,
      child: SpotlightCard(
        radius: 28,
        tilt: context.isCompact ? 0 : 0.06,
        builder: (context, _) => AspectRatio(
          aspectRatio: 4 / 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors.panel),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.05, -0.45),
                      radius: 0.7,
                      colors: [
                        Colors.white.withValues(alpha: colors.isDark ? 0.34 : 0.85),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  AppAssets.about,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  filterQuality: FilterQuality.medium,
                  semanticLabel: 'Black-and-white portrait of Dinolin Dhas with arms folded',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Story extends StatelessWidget {
  const _Story();

  @override
  Widget build(BuildContext context) {
    final body = context.type.body(context.isCompact ? 16 : 18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          from: RevealFrom.right,
          child: Text(
            'A mobile application developer with 3+ years of building cross-platform apps for Android and iOS '
            'in Flutter and Dart.',
            style: context.type.title(context.responsive(compact: 23, medium: 25, expanded: 31)).copyWith(height: 1.32),
          ),
        ),
        const SizedBox(height: 24),
        Reveal(
          from: RevealFrom.right,
          delay: const Duration(milliseconds: 50),
          child: Text(
            'My work covers the full path of a feature: understanding the requirement, shaping it into reusable '
            'widgets, managing state with GetX, connecting it to REST APIs and Spring Boot services, and testing it '
            'through to release.',
            style: body,
          ),
        ),
        const SizedBox(height: 16),
        Reveal(
          from: RevealFrom.right,
          delay: const Duration(milliseconds: 90),
          child: Text(
            'I work closely with backend and UI teams, and I’ve coordinated directly with clients on requirements '
            'and timelines. What I enjoy most is building apps people can rely on.',
            style: body,
          ),
        ),
        const SizedBox(height: 36),
        const _Facts(),
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts();

  static const _rows = [
    ('Based in', 'Tamil Nadu, India'),
    ('Languages', 'English and Tamil (read, write, speak), Malayalam (speak)'),
    ('Certification', 'Full Stack Developer'),
  ];

  @override
  Widget build(BuildContext context) {
    return Reveal(
      from: RevealFrom.right,
      delay: const Duration(milliseconds: 60),
      child: Column(
        children: [
          for (final (term, value) in _rows)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.colors.line)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: context.isCompact ? 112 : 150,
                    child: Text(term, style: context.type.label(16, color: context.colors.muted)),
                  ),
                  Expanded(child: Text(value, style: context.type.label(16).copyWith(height: 1.45))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
