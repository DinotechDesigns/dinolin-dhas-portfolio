import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

void showNotice(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
  final screen = MediaQuery.sizeOf(context).width;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: context.type.label(15)),
        behavior: SnackBarBehavior.floating,
        width: screen < 560 ? screen - 32 : 520,
        backgroundColor: context.colors.surfaceHigh,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: context.colors.line),
        ),
        duration: const Duration(seconds: 5),
        persist: false,
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, textColor: context.colors.mint, onPressed: onAction ?? () {}),
      ),
    );
}
