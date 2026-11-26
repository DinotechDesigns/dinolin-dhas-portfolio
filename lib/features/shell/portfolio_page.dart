import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_theme.dart';
import '../../core/animations/motion.dart';
import '../../core/cursor/cursor_layer.dart';
import '../../core/scroll/glide_scroll.dart';
import '../../core/widgets/section_shell.dart';
import '../about/about_section.dart';
import '../contact/contact_section.dart';
import '../education/education_section.dart';
import '../experience/experience_section.dart';
import '../home/hero_section.dart';
import '../projects/projects_section.dart';
import '../skills/skills_section.dart';
import 'site_nav.dart';
import 'scroll_jelly.dart';
import 'travel_veil.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with TickerProviderStateMixin {
  final _scroll = GlideScrollController();
  final _active = ValueNotifier(SectionId.home);
  final _scrolled = ValueNotifier(false);
  final _keys = {for (final id in SectionId.values) id: GlobalKey()};
  late final AnimationController _veil = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 620),
  );

  /// Section tops, measured once per layout instead of on every scroll tick.
  Map<SectionId, double> _offsets = const {};
  (double, double)? _measuredFor;

  /// Guards against a second navigation starting while one is under way.
  int _trip = 0;
  SectionId? _destination;

  late final ScrollJelly _jelly = ScrollJelly(this, _scroll);

  /// Share of the scroll lag per section: a gentle wave down the page.
  static const _jellyShare = [0.35, 0.75, 1.0, 0.7, 1.0, 0.75, 0.45];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _precache());
  }

  /// Decodes project artwork ahead of time, so scrolling to it never hitches.
  void _precache() {
    if (!mounted) return;
    for (final asset in AppAssets.all) {
      unawaited(precacheImage(AssetImage(asset), context));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _active.dispose();
    _scrolled.dispose();
    _veil.dispose();
    _jelly.dispose();
    super.dispose();
  }

  void _measure() {
    final position = _scroll.position;
    final layout = (position.maxScrollExtent, position.viewportDimension);
    if (layout == _measuredFor) return;
    final offsets = <SectionId, double>{};
    for (final id in SectionId.values) {
      final box = _keys[id]?.currentContext?.findRenderObject();
      if (box != null) offsets[id] = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset;
    }
    _offsets = offsets;
    _measuredFor = layout;
  }

  void _onScroll() {
    final position = _scroll.position;
    _scrolled.value = position.pixels > 24;
    // While travelling, the menu already shows where the visitor is headed.
    if (_destination != null) return;

    _measure();
    var current = SectionId.home;
    if (position.maxScrollExtent - position.pixels < 8) {
      current = SectionId.contact;
    } else {
      final line = position.pixels + position.viewportDimension * 0.35;
      for (final MapEntry(key: id, value: offset) in _offsets.entries) {
        if (offset <= line) current = id;
      }
    }
    _active.value = current;
  }

  double _landing(SectionId id) {
    _measure();
    // Land with the heading a fixed distance below the navigation bar.
    final top = id == SectionId.home
        ? 0.0
        : (_offsets[id] ?? 0) + SectionShell.paddingOf(context) - SiteNav.height - 36;
    return math.min(math.max(top, 0.0), _scroll.position.maxScrollExtent);
  }

  Future<void> _goTo(SectionId id) async {
    final target = _landing(id);
    if (reduceMotionOf(context)) {
      _scroll.jumpTo(target);
      return;
    }
    final trip = ++_trip;
    _destination = id;
    _active.value = id;

    final viewport = _scroll.position.viewportDimension;
    final distance = target - _scroll.offset;
    final isLong = distance.abs() > viewport * 1.5;

    if (isLong) {
      // Rather than rushing past whole sections, dip through a veil and arrive
      // on the last stretch of the way.
      final run = viewport * 0.4 * distance.sign;
      unawaited(_scroll.animateTo(_scroll.offset + run * 0.45, duration: _veil.duration!, curve: Curves.easeInCubic));
      await _veil.forward().orCancel.catchError((_) {});
      if (!mounted || trip != _trip) return;
      _scroll.jumpTo((target - run).clamp(0.0, _scroll.position.maxScrollExtent));
      unawaited(_veil.reverse());
      await _scroll.animateTo(target, duration: const Duration(milliseconds: 1000), curve: Motion.glide);
    } else {
      // A long trip may have been cut short with the veil still up.
      unawaited(_veil.reverse());
      await _scroll.animateTo(
        target,
        duration: Duration(milliseconds: (620 + distance.abs() / 4).clamp(620, 1000).round()),
        curve: Curves.easeInOutCubic,
      );
    }

    if (!mounted || trip != _trip) return;
    _destination = null;
    _onScroll();
  }

  Widget _section(SectionId id, Widget child) => RepaintBoundary(
    key: _keys[id],
    child: JellySection(jelly: _jelly, share: _jellyShare[id.index], child: child),
  );

  /// The bar sits above the scroll view, so it hands wheel events down to it.
  void _forwardWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scroll.hasClients) return;
    GestureBinding.instance.pointerSignalResolver.register(
      event,
      (_) => _scroll.position.pointerScroll(event.scrollDelta.dy),
    );
  }

  @override
  Widget build(BuildContext context) {
    _jelly.enabled = !reduceMotionOf(context);
    return Scaffold(
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.home): () => _goTo(SectionId.home),
          const SingleActivator(LogicalKeyboardKey.end): () => _goTo(SectionId.contact),
        },
        child: PrimaryScrollController(
          controller: _scroll,
          // Takes initial focus so arrow keys and Page Down scroll straight away.
          child: Focus(
            autofocus: true,
            skipTraversal: true,
            includeSemantics: false,
            child: Stack(
              children: [
                const Positioned.fill(child: CursorGlow()),
                Scrollbar(
                  controller: _scroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _section(SectionId.home, HeroSection(onNavigate: _goTo)),
                        _section(SectionId.about, const AboutSection()),
                        _section(SectionId.skills, const SkillsSection()),
                        _section(SectionId.experience, const ExperienceSection()),
                        _section(SectionId.projects, const ProjectsSection()),
                        _section(SectionId.education, const EducationSection()),
                        _section(SectionId.contact, ContactSection(onNavigate: _goTo)),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: TravelVeil(progress: _veil, colors: context.colors),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Listener(
                    onPointerSignal: _forwardWheel,
                    child: SiteNav(active: _active, scrolled: _scrolled, scroll: _scroll, onNavigate: _goTo),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
