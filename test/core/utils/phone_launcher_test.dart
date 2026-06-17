import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/phone_launcher.dart';

void main() {
  group('PhoneLauncher.normalizeDialNumber', () {
    test('normalizes local Turkmen number', () {
      expect(PhoneLauncher.normalizeDialNumber('61 00 00 00'), '+99361000000');
    });

    test('keeps E.164 number', () {
      expect(PhoneLauncher.normalizeDialNumber('+99361234567'), '+99361234567');
    });

    test('returns null for empty input', () {
      expect(PhoneLauncher.normalizeDialNumber(''), isNull);
      expect(PhoneLauncher.normalizeDialNumber('   '), isNull);
    });
  });
}
