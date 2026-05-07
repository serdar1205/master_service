import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/master_profile/domain/master_access.dart';

void main() {
  group('MasterAccess', () {
    test('is active when expiry is in the future', () {
      final checkedAt = DateTime(2026, 5, 7, 10);
      final access = MasterAccess(
        expiresAt: checkedAt.add(const Duration(days: 2, hours: 1)),
        checkedAt: checkedAt,
      );

      expect(access.isActive, isTrue);
      expect(access.daysRemaining, 3);
      expect(access.inactiveReason, isNull);
    });

    test('is inactive when expiry has passed', () {
      final checkedAt = DateTime(2026, 5, 7, 10);
      final access = MasterAccess(
        expiresAt: checkedAt.subtract(const Duration(minutes: 1)),
        checkedAt: checkedAt,
      );

      expect(access.isActive, isFalse);
      expect(access.daysRemaining, 0);
      expect(access.inactiveReason, MasterAccessInactiveReason.expired);
    });

    test('is inactive when admin has not activated access', () {
      final access = MasterAccess(
        expiresAt: null,
        checkedAt: DateTime(2026, 5, 7, 10),
      );

      expect(access.isActive, isFalse);
      expect(access.inactiveReason, MasterAccessInactiveReason.notActivated);
    });
  });
}
