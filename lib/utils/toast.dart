import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Simple SnackBar-based toast used across the app instead of a third
/// party plugin - avoids native embedding / SDK version conflicts.
void showAppToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.textPrimary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ),
  );
}
