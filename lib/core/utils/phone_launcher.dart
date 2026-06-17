import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'phone_formatter.dart';

class PhoneLauncher {
  const PhoneLauncher._();

  static String? normalizeDialNumber(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (PhoneFormatter.isValidLocal(trimmed)) {
      return PhoneFormatter.toE164(trimmed);
    }

    final digits = PhoneFormatter.extractDigits(trimmed);
    if (digits.isEmpty) {
      return null;
    }

    if (trimmed.startsWith('+')) {
      return '+$digits';
    }

    if (digits.length == 11 && digits.startsWith('993')) {
      return '+$digits';
    }

    if (digits.length == 8) {
      return '+993$digits';
    }

    return '+$digits';
  }

  static Future<bool> call(
    BuildContext context,
    String phone, {
    String unavailableMessage = 'Phone number unavailable',
    String failedMessage = 'Could not start call',
  }) async {
    final dialNumber = normalizeDialNumber(phone);
    if (dialNumber == null) {
      _showMessage(context, unavailableMessage);
      return false;
    }

    final uri = Uri(scheme: 'tel', path: dialNumber);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showMessage(context, failedMessage);
      }
      return launched;
    } on Object {
      if (context.mounted) {
        _showMessage(context, failedMessage);
      }
      return false;
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
