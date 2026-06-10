import 'package:flutter/services.dart';

/// Formats Turkmen local numbers as `## ## ## ##` (8 digits).
class TurkmenPhoneTextInputFormatter extends TextInputFormatter {
  const TurkmenPhoneTextInputFormatter();

  static const int maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    final formatted = formatDigits(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 2 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
