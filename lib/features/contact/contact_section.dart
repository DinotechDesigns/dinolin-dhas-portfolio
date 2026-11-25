import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/site_actions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/brand_icons.dart';
import '../../core/widgets/interactive.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.onNavigate});

  final ValueChanged<SectionId> onNavigate;

  @override
  Widget build(BuildContext context) {
    return RevealBuilder(
      duration: const Duration(milliseconds: 900),
      builder: (context, progress) => CustomPaint(
        painter: _HorizonPainter(progress, context.colors),
        child: Padding(
          padding: EdgeInsets.only(top: context.responsive(compact: 72.0, medium: 100.0, expanded: 132.0)),
          child: ContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Closing(),
                SizedBox(height: context.isCompact ? 36 : 52),
                const _EmailLine(),
                const SizedBox(height: 32),
                const _Channels(),
                SizedBox(height: context.isCompact ? 72 : 110),
                _Footer(onNavigate: onNavigate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Closing extends StatelessWidget {
  const _Closing();

  @override
  Widget build(BuildContext context) {
    return Reveal(
      from: RevealFrom.left,
      child: Semantics(
        header: true,
        headingLevel: 2,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 940),
          child: Text(
            'Have an idea or an opportunity? Let’s build something meaningful.',
            style: context.type.display(context.responsive(compact: 36, medium: 52, expanded: 68)),
          ),
        ),
      ),
    );
  }
}

class _EmailLine extends StatelessWidget {
  const _EmailLine();

  @override
  Widget build(BuildContext context) {
    final size = context.responsive(compact: 20.0, medium: 26.0, expanded: 30.0);
    return Reveal(
      from: RevealFrom.right,
      delay: const Duration(milliseconds: 60),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Interactive(
            onTap: () => SiteActions.email(context),
            isLink: true,
            semanticLabel: 'Email ${AppConstants.email}',
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: AnimatedDefaultTextStyle(
                duration: Motion.quick,
                style: context.type.title(size, color: state.active ? context.colors.text : context.colors.mint),
                child: const FittedBox(fit: BoxFit.scaleDown, child: Text(AppConstants.email, maxLines: 1)),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy email address',
            onPressed: () => SiteActions.copyEmail(context),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(Icons.copy_rounded, size: 20, color: context.colors.muted),
          ),
        ],
      ),
    );
  }
}

class _Channels extends StatelessWidget {
  const _Channels();

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final buttons = [
      AppButton(
        label: 'Email me',
        expand: compact,
        isLink: true,
        leading: const Icon(Icons.mail_outline_rounded),
        onPressed: () => SiteActions.email(context),
      ),
      AppButton(
        label: 'LinkedIn',
        style: AppButtonStyle.outline,
        expand: compact,
        isLink: true,
        leading: const Icon(BrandIcons.linkedIn),
        onPressed: () => SiteActions.linkedIn(context),
      ),
      AppButton(
        label: 'WhatsApp',
        style: AppButtonStyle.outline,
        expand: compact,
        isLink: true,
        leading: const Icon(BrandIcons.whatsApp),
        onPressed: () => SiteActions.whatsApp(context),
      ),
      if (AppConstants.gitHubUsername.isNotEmpty)
        AppButton(
          label: 'GitHub',
          style: AppButtonStyle.outline,
          expand: compact,
          isLink: true,
          leading: const Icon(BrandIcons.gitHub),
          onPressed: () => SiteActions.gitHub(context),
        ),
      AppButton(
        label: 'Download resume',
        style: AppButtonStyle.outline,
        expand: compact,
        leading: const Icon(Icons.download_rounded),
        onPressed: () => SiteActions.resume(context),
      ),
    ];
    return Reveal(
      delay: const Duration(milliseconds: 100),
      child: compact
          ? Column(
              children: [
                for (final button in buttons) Padding(padding: const EdgeInsets.only(bottom: 12), child: button),
              ],
            )
          : Wrap(spacing: 14, runSpacing: 14, children: buttons),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onNavigate});

  final ValueChanged<SectionId> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.line)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 8,
        children: [
          Text('Dinolin Dhas. Built with Flutter Web.', style: context.type.body(15)),
          AppButton(label: 'Back to top', style: AppButtonStyle.quiet, onPressed: () => onNavigate(SectionId.home)),
        ],
      ),
    );
  }
}

/// A single arc of light that rises behind the closing message.
class _HorizonPainter extends CustomPainter {
  _HorizonPainter(this.progress, this.colors) : super(repaint: progress);

  final Animation<double> progress;
  final AppPalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutCubic.transform(progress.value);
    if (t <= 0) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    void glow(Color color, Alignment at, double radius, double alpha) {
      final center = at.alongSize(size) + Offset(0, (1 - t) * 160);
      // Fades out before the top edge, so the section above flows into this one.
      final rect = Rect.fromCircle(center: center, radius: math.min(radius, center.dy));
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha * t),
              color.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    final reach = size.longestSide;
    glow(colors.indigo, const Alignment(0.7, 1.15), reach * 0.62, 0.34);
    glow(colors.plum, const Alignment(-0.1, 1.3), reach * 0.5, 0.26);
    glow(colors.mint, const Alignment(1.1, 0.9), reach * 0.28, 0.16);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HorizonPainter old) => old.progress != progress || old.colors != colors;
}
