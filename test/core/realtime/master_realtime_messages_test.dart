import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/realtime/master_realtime_messages.dart';

void main() {
  group('jobAssignedToastMessage', () {
    test('uses client name when available', () {
      final message = jobAssignedToastMessage(
        locale: const Locale('ru'),
        payload: {'order_id': 42, 'client_name': 'Мурат'},
      );

      expect(message, 'Новая заявка: Мурат');
    });

    test('falls back to order id without client name', () {
      final message = jobAssignedToastMessage(
        locale: const Locale('tk'),
        payload: {'order_id': 42},
      );

      expect(message, 'Täze sargyt #42');
    });

    test('uses generic message when payload is sparse', () {
      final message = jobAssignedToastMessage(
        locale: const Locale('ru'),
        payload: const {},
      );

      expect(message, 'Вам назначена новая заявка');
    });
  });
}
