import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/realtime/realtime_event.dart';
import 'package:master_service/core/realtime/reverb_event_parser.dart';

void main() {
  group('parseReverbEvent', () {
    test('maps master.assigned to jobAssigned', () {
      final event = parseReverbEvent(
        eventName: 'master.assigned',
        data: '{"order_id":42,"master_id":7,"client_name":"Murat"}',
      );

      expect(event, isNotNull);
      expect(event!.type, RealtimeEventType.jobAssigned);
      expect(event.payload['order_id'], 42);
    });

    test('maps order.status.changed to jobStatusChanged', () {
      final event = parseReverbEvent(
        eventName: 'order.status.changed',
        data: {'order_id': 42, 'from': 'assigned', 'to': 'in_progress'},
      );

      expect(event, isNotNull);
      expect(event!.type, RealtimeEventType.jobStatusChanged);
      expect(event.payload['to'], 'in_progress');
    });

    test('ignores unknown events', () {
      final event = parseReverbEvent(
        eventName: 'client.updated',
        data: {'id': 1},
      );

      expect(event, isNull);
    });
  });

  test('masterChannelName uses master private channel', () {
    expect(masterChannelName(7), 'private-master.7');
  });
}
