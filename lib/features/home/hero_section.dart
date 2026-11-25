import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/responsive/responsive.dart';
import 'hero_backdrop.dart';
import 'hero_copy.dart';
import 'hero_portrait.dart';

/// First screen: the name rises, then the rest follows in a short stagger.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key, required this.onNavigate});

  final ValueChanged<SectionId> onNavigate;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _prepared = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    if (reduceMotionOf(context)) {
      _intro.value = 1;
      return;
    }
    // Wait for the portrait so the sequence never plays over an empty frame.
    precacheImage(const AssetImage(AppAssets.profile), context).whenComplete(() {
      if (mounted) _intro.forward();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  /// Entrance for the [index]th element, after the loading screen has faded.
  Animation<double> _step(int index) =>
      _intro.drive(CurveTween(curve: Interval(0.12 + index * 0.065, math.min(1, 0.6 + index * 0.08))));

  Widget _build(int index, Widget child) =>
      index == 0 ? RiseIn(progress: _step(0), child: child) : BuildIn(progress: _step(index), child: child);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final sideBySide = size.width >= 900;

    return Stack(
      children: [
        const Positioned.fill(child: HeroBackdrop()),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: sideBySide ? math.max(680, size.height) : 0),
          child: ContentFrame(
            child: Padding(
              padding: EdgeInsets.only(
                top: sideBySide ? 96 : (context.isCompact ? 86 : 104),
                bottom: sideBySide ? 48 : 56,
              ),
              child: sideBySide ? _wide(size) : _stacked(size),
            ),
          ),
        ),
      ],
    );
  }

  Widget _wide(Size size) {
    final large = size.width >= 1240;
    final portraitWidth = large ? 420.0 : 350.0;
    return Row(
      children: [
        Expanded(
          child: HeroCopy(nameSize: large ? 116 : 84, wrap: _build, onNavigate: widget.onNavigate),
        ),
        SizedBox(width: large ? 64 : 36),
        _build(3, HeroPortrait(width: portraitWidth)),
        if (large) const SizedBox(width: 24),
      ],
    );
  }

  Widget _stacked(Size size) {
    final gutter = ContentFrame.gutterOf(context);
    final available = size.width - gutter * 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeroCopy(nameSize: (available * 0.19).clamp(46.0, 104.0), wrap: _build, onNavigate: widget.onNavigate),
        SizedBox(height: context.isCompact ? 28 : 56),
        Center(child: _build(5, HeroPortrait(width: math.min(available - 8, 400)))),
        if (context.isCompact) ...[
          const SizedBox(height: 20),
          Center(child: ConnectLink(onNavigate: widget.onNavigate)),
        ],
      ],
    );
  }
}
