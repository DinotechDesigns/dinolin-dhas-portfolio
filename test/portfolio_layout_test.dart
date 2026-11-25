import 'dart:io';

import 'package:dinolin_dhas_portfolio/app/app.dart';
import 'package:dinolin_dhas_portfolio/app/constants/app_constants.dart';
import 'package:dinolin_dhas_portfolio/app/constants/portfolio_content.dart';
import 'package:dinolin_dhas_portfolio/features/shell/portfolio_page.dart';
import 'package:dinolin_dhas_portfolio/features/shell/theme_toggle.dart';
import 'package:dinolin_dhas_portfolio/features/shell/travel_veil.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double _pixels(WidgetTester tester) => tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;

Future<void> _pumpAt(WidgetTester tester, Size size, {bool reduceMotion = true}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // Reduced motion keeps looping animations from blocking pumpAndSettle.
  tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(const PortfolioApp());
  if (reduceMotion) {
    await tester.pumpAndSettle();
    return;
  }
  // Looping hero decoration never settles, so step past the entrance instead.
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    final bytes = File('assets/fonts/MonaSans.ttf').readAsBytesSync();
    await (FontLoader('MonaSans')..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  });

  for (final width in [
    320.0,
    360.0,
    390.0,
    600.0,
    719.0,
    768.0,
    860.0,
    900.0,
    920.0,
    1024.0,
    1080.0,
    1280.0,
    1440.0,
    1920.0,
  ]) {
    testWidgets('lays out without overflow at ${width.round()}px', (tester) async {
      await _pumpAt(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
      expect(find.byType(PortfolioPage), findsOneWidget);
      for (final project in PortfolioContent.projects) {
        expect(find.text(project.name), findsWidgets);
      }
    });
  }

  testWidgets('navigation scrolls to a section', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.text('Contact').first);
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scrollable.position.pixels, greaterThan(1000));
  });

  testWidgets('mobile menu opens and navigates', (tester) async {
    await _pumpAt(tester, const Size(390, 844));
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Close menu'), findsOneWidget);
    await tester.tap(find.text('Skills').last);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Close menu'), findsNothing);
    expect(tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels, greaterThan(500));
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(360, 740), const Size(1280, 800)]) {
    testWidgets('project details open and close at ${size.width.round()}px', (tester) async {
      await _pumpAt(tester, size);
      for (final project in PortfolioContent.projects) {
        final button = find.text('Explore ${project.name}');
        // Centered, so the fixed navigation bar never covers the button.
        await Scrollable.ensureVisible(tester.element(button), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text(project.details.first), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets('theme switch changes palette and lays out in both', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));
    Brightness current() => Theme.of(tester.element(find.byType(PortfolioPage))).brightness;
    final before = current();
    await tester.tap(find.byType(ThemeToggle));
    await tester.pumpAndSettle();
    expect(current(), isNot(before));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(ThemeToggle));
    await tester.pumpAndSettle();
    expect(current(), before);
  });

  testWidgets('theme reveal plays and cleans up with motion on', (tester) async {
    await _pumpAt(tester, const Size(1440, 900), reduceMotion: false);
    await tester.tap(find.byType(ThemeToggle));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('removed demo controls stay removed', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));
    expect(find.text('Show layout'), findsNothing);
    expect(find.text('Leave request'), findsNothing);
  });

  testWidgets('fast wheel steps keep their full distance', (tester) async {
    await _pumpAt(tester, const Size(1280, 800), reduceMotion: false);
    for (var i = 0; i < 5; i++) {
      await tester.sendEventToBinding(
        const PointerScrollEvent(position: Offset(640, 400), scrollDelta: Offset(0, 100)),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_pixels(tester), closeTo(500, 1));
  });

  testWidgets('every menu item lands with its heading visible', (tester) async {
    await _pumpAt(tester, const Size(1440, 900), reduceMotion: false);
    for (final id in [SectionId.contact, SectionId.about, SectionId.projects, SectionId.skills, SectionId.home]) {
      await tester.tap(find.text(id.label).first);
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      if (id == SectionId.home) expect(_pixels(tester), 0);
      if (id == SectionId.about) expect(tester.getTopLeft(find.text('About me')).dy, inInclusiveRange(64, 400));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('a new destination wins over a trip under way', (tester) async {
    await _pumpAt(tester, const Size(1440, 900), reduceMotion: false);
    await tester.tap(find.text('Contact').first);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.text('Home').first);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(_pixels(tester), 0);
    expect(tester.widget<TravelVeil>(find.byType(TravelVeil)).progress.value, 0);
  });

  testWidgets('content replays on the way down and back up', (tester) async {
    await _pumpAt(tester, const Size(1440, 900), reduceMotion: false);
    double opacityOf(String text) => tester
        .widget<FadeTransition>(find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)).first)
        .opacity
        .value;
    Future<void> scrollTo(double offset) async {
      tester.state<ScrollableState>(find.byType(Scrollable).first).position.jumpTo(offset);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
    }

    expect(opacityOf('OpticalHR'), 0);
    await scrollTo(tester.getTopLeft(find.text('OpticalHR')).dy - 300);
    expect(opacityOf('OpticalHR'), 1);
    await scrollTo(0);
    expect(opacityOf('OpticalHR'), 0);
  });

  testWidgets('keyboard focus is brought clear of the navigation bar', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));
    tester.state<ScrollableState>(find.byType(Scrollable).first).position.jumpTo(690);
    await tester.pumpAndSettle();
    for (var i = 0; i < 12; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final focus = FocusManager.instance.primaryFocus;
      if (focus?.context == null || Scrollable.maybeOf(focus!.context!) == null) continue;
      if (focus.rect.height > 400) continue;
      expect(focus.rect.top, greaterThanOrEqualTo(64));
      expect(focus.rect.bottom, lessThanOrEqualTo(900));
    }
  });

  testWidgets('End and Home reach both ends', (tester) async {
    await _pumpAt(tester, const Size(1280, 800));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    expect(position.pixels, closeTo(position.maxScrollExtent, 1));
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(_pixels(tester), 0);
  });

  testWidgets('cursor ring follows the mouse without errors', (tester) async {
    await _pumpAt(tester, const Size(1440, 900), reduceMotion: false);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(200, 200));
    await mouse.moveTo(tester.getCenter(find.text('Explore my work')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await mouse.moveTo(const Offset(900, 500));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    await mouse.removePointer();
  });

  testWidgets('missing resume explains itself and offers email', (tester) async {
    await _pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.text('Download resume').first);
    await tester.pumpAndSettle();
    final bundled = File('assets/resume/dinolin-dhas-resume.pdf').existsSync();
    expect(find.text('Email me'), bundled ? findsOneWidget : findsNWidgets(2));
  });

  for (final (width, scale) in [(360.0, 1.4), (860.0, 1.3), (1024.0, 1.3), (1280.0, 1.5), (1440.0, 2.0)]) {
    testWidgets('large text x$scale fits at ${width.round()}px', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pumpAt(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keyboard scrolls without a click first', (tester) async {
    await _pumpAt(tester, const Size(1280, 800));
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels, greaterThan(200));
  });

  testWidgets('wheel over the navigation bar scrolls the page', (tester) async {
    await _pumpAt(tester, const Size(1280, 800));
    await tester.sendEventToBinding(const PointerScrollEvent(position: Offset(640, 30), scrollDelta: Offset(0, 120)));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels, greaterThan(50));
  });
}
