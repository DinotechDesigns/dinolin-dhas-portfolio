import 'package:flutter/widgets.dart';

enum ScreenSize { compact, medium, expanded }

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize => switch (screenWidth) {
    < 720 => ScreenSize.compact,
    < 1080 => ScreenSize.medium,
    _ => ScreenSize.expanded,
  };

  bool get isCompact => screenSize == ScreenSize.compact;

  bool get isExpanded => screenSize == ScreenSize.expanded;

  /// Picks a value per breakpoint; [medium] falls back to [expanded].
  T responsive<T>({required T compact, T? medium, required T expanded}) => switch (screenSize) {
    ScreenSize.compact => compact,
    ScreenSize.medium => medium ?? expanded,
    ScreenSize.expanded => expanded,
  };
}

/// Centers content in a readable measure with breakpoint-aware gutters.
class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child});

  static const maxWidth = 1200.0;

  final Widget child;

  static double gutterOf(BuildContext context) =>
      context.responsive(compact: context.screenWidth < 360 ? 18.0 : 24.0, medium: 40.0, expanded: 56.0);

  @override
  Widget build(BuildContext context) {
    final gutter = gutterOf(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
