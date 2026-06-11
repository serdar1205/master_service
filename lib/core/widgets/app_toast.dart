import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppToast {
  AppToast._();

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showError(String message) {
    _show(message: message, backgroundColor: AppColors.kFFB3262E);
  }

  static void showSuccess(String message) {
    _show(message: message, backgroundColor: AppColors.brand);
  }

  static void _show({required String message, required Color backgroundColor}) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final messenger = messengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            trimmed,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
