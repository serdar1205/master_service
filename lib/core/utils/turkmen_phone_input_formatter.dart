import 'package:flutter/services.dart';

import 'phone_formatter.dart';

/// Formats Turkmen local numbers as `## ## ## ##` (8 digits).
class TurkmenPhoneInputFormatter extends TextInputFormatter {
  const TurkmenPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = PhoneFormatter.extractDigits(newValue.text);
    final limited = digits.length > PhoneFormatter.localDigitCount
        ? digits.substring(0, PhoneFormatter.localDigitCount)
        : digits;
    final formatted = PhoneFormatter.formatLocalDisplay(limited);

    final digitsBeforeCursor = _digitsBeforeCursor(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final cursorOffset = _cursorOffsetForDigitCount(
      formatted,
      digitsBeforeCursor.clamp(0, limited.length),
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  static int _digitsBeforeCursor(String text, int cursor) {
    if (cursor <= 0) {
      return 0;
    }

    final safeCursor = cursor.clamp(0, text.length);
    return PhoneFormatter.extractDigits(text.substring(0, safeCursor)).length;
  }

  static int _cursorOffsetForDigitCount(String formatted, int digitCount) {
    if (digitCount <= 0) {
      return 0;
    }

    var digitsSeen = 0;
    for (var index = 0; index < formatted.length; index++) {
      if (formatted[index] != ' ') {
        digitsSeen++;
      }
      if (digitsSeen >= digitCount) {
        return index + 1;
      }
    }

    return formatted.length;
  }
}
