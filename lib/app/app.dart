import 'package:flutter/material.dart';

import '../core/cursor/cursor_layer.dart';
import '../features/shell/portfolio_page.dart';
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  final _theme = ThemeController();

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _theme,
      builder: (context, page) => MaterialApp(
        title: AppConstants.siteTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.of(_theme.brightness),
        themeAnimationStyle: AnimationStyle.noAnimation,
        builder: (context, child) => ThemeScope(
          controller: _theme,
          child: CursorLayer(
            child: ThemeReveal(controller: _theme, child: child!),
          ),
        ),
        home: page,
      ),
      child: const PortfolioPage(),
    );
  }
}
