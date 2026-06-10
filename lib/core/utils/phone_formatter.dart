import 'turkmen_phone_text_input_formatter.dart';

class PhoneFormatter {
  const PhoneFormatter._();

  static const String countryCode = '+993';
  static const String localDisplayHint = '61 00 00 00';
  static const int localDigitCount = 8;
  static const int localDisplayLength = 11;

  static String extractDigits(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String formatLocalDisplay(String value) {
    final digits = extractDigits(value);
    final limited = digits.length > localDigitCount
        ? digits.substring(0, localDigitCount)
        : digits;

    return TurkmenPhoneTextInputFormatter.formatDigits(limited);
  }

  static String toDisplayE164(String value) {
    if (!isValidLocal(value)) {
      return value;
    }

    final e164 = toE164(value);
    final local = e164.substring(countryCode.length);
    return '$countryCode ${formatLocalDisplay(local)}';
  }

  static String toE164(String value) {
    final digits = extractDigits(value);
    if (digits.length == 8) {
      return '+993$digits';
    }

    if (digits.length == 11 && digits.startsWith('993')) {
      return '+$digits';
    }

    throw ArgumentError('invalid_phone');
  }

  static bool isValidLocal(String value) {
    final digits = extractDigits(value);
    return RegExp(r'^(\d{8}|993\d{8})$').hasMatch(digits);
  }
}
