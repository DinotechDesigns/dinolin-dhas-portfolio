import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/portfolio_content.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import 'payment_pipeline.dart';

/// The picture half of a project. [active] spreads the screens on hover.
class ProjectVisualPanel extends StatelessWidget {
  const ProjectVisualPanel({super.key, required this.project, required this.active});

  final Project project;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotionOf(context) ? Duration.zero : const Duration(milliseconds: 520);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: project.colors),
      ),
      child: ClipRect(
        child: switch (project.visual) {
          ProjectVisual.pipeline => PaymentPipeline(active: active),
          _ => TweenAnimationBuilder(
            tween: Tween<double>(end: active ? 1 : 0),
            duration: duration,
            curve: Motion.curve,
            builder: (context, t, _) => project.visual == ProjectVisual.tallScreens
                ? _TallScreens(project: project, spread: t)
                : _StoreArt(project: project, spread: t),
          ),
        },
      ),
    );
  }
}

/// Two full app screens in slim device frames, rising from the bottom edge.
class _TallScreens extends StatelessWidget {
  const _TallScreens({required this.project, required this.spread});

  final Project project;
  final double spread;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final height = box.maxHeight * 0.98;
        final width = math.min(height * 0.46, box.maxWidth * 0.4);
        return Stack(
          alignment: Alignment.center,
          children: [
            _screen(
              0,
              width,
              Offset(-width * 0.56 - 10 * spread, box.maxHeight * 0.06 - 14 * spread),
              -0.05 - 0.02 * spread,
            ),
            _screen(
              1,
              width,
              Offset(width * 0.56 + 10 * spread, box.maxHeight * 0.14 - 24 * spread),
              0.04 + 0.02 * spread,
            ),
          ],
        );
      },
    );
  }

  Widget _screen(int index, double width, Offset offset, double angle) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: OverflowBox(
          maxHeight: double.infinity,
          child: Container(
            width: width,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF05070D),
              borderRadius: BorderRadius.circular(width * 0.13),
              border: Border.all(color: AppPalette.dark.text.withValues(alpha: 0.22)),
              boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 24))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.105),
              child: Image.asset(
                project.images[index],
                filterQuality: FilterQuality.medium,
                semanticLabel: '${project.name} app screen',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// App Store artwork that already contains a device, kept flush with the bottom.
class _StoreArt extends StatelessWidget {
  const _StoreArt({required this.project, required this.spread});

  final Project project;
  final double spread;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = math.min(math.min(box.maxWidth * 0.45, 310.0), box.maxHeight / 1.16);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (index, image) in project.images.indexed)
              Positioned(
                left: box.maxWidth / 2 + (index == 0 ? -width - 10 - 4 * spread : 10 + 4 * spread),
                // Sits below the edge so the hover lift never opens a gap.
                bottom: width * ((index == 0 ? -0.08 : -0.05) + 0.045 * spread),
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(width * 0.1)),
                  child: Image.asset(
                    image,
                    filterQuality: FilterQuality.medium,
                    semanticLabel: '${project.name} App Store artwork',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
