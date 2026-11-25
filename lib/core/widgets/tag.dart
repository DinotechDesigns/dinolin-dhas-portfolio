import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.text.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(label, style: context.type.label(14)),
      ),
    );
  }
}
