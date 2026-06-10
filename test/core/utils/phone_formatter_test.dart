import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/phone_formatter.dart';
import 'package:master_service/core/utils/turkmen_phone_text_input_formatter.dart';

void main() {
  test('toE164 formats 8-digit local number', () {
    expect(PhoneFormatter.toE164('62111222'), '+99362111222');
  });

  test('toE164 formats spaced local number', () {
    expect(PhoneFormatter.toE164('62 11 12 22'), '+99362111222');
  });

  test('toE164 formats number with country code', () {
    expect(PhoneFormatter.toE164('+99362111222'), '+99362111222');
  });

  test('toE164 throws for invalid phone', () {
    expect(() => PhoneFormatter.toE164('123'), throwsArgumentError);
  });

  test('formatLocalDisplay groups digits as ## ## ## ##', () {
    expect(PhoneFormatter.formatLocalDisplay('62111222'), '62 11 12 22');
  });

  test('toDisplayE164 includes country code and spacing', () {
    expect(PhoneFormatter.toDisplayE164('62 11 12 22'), '+993 62 11 12 22');
  });

  test('TurkmenPhoneTextInputFormatter limits to 8 digits', () {
    const formatter = TurkmenPhoneTextInputFormatter();
    final result = formatter.formatEditUpdate(
      const TextEditingValue.empty(),
      const TextEditingValue(text: '621112223344'),
    );

    expect(result.text, '62 11 12 22');
  });
}
