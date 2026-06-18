import 'dart:convert';

import 'realtime_event.dart';

RealtimeEvent? parseReverbEvent({
  required String eventName,
  required dynamic data,
}) {
  if (eventName.startsWith('pusher:') ||
      eventName.startsWith('pusher_internal:')) {
    return null;
  }

  final payload = _decodePayload(data);
  if (payload == null) {
    return null;
  }

  final type = switch (eventName) {
    'master.assigned' => RealtimeEventType.jobAssigned,
    'order.status.changed' => RealtimeEventType.jobStatusChanged,
    _ => null,
  };

  if (type == null) {
    return null;
  }

  return RealtimeEvent(type: type, payload: payload);
}

Map<String, Object?>? _decodePayload(dynamic data) {
  if (data is Map<String, dynamic>) {
    return Map<String, Object?>.from(data);
  }

  if (data is Map) {
    return Map<String, Object?>.from(data);
  }

  if (data is String && data.isNotEmpty) {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) {
      return Map<String, Object?>.from(decoded);
    }
    if (decoded is Map) {
      return Map<String, Object?>.from(decoded);
    }
  }

  return null;
}

String masterChannelName(int masterId) => 'private-master.$masterId';
