import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import 'realtime_event.dart';

abstract interface class RealtimeClient {
  Stream<RealtimeEvent> get events;

  Future<void> connect({required String accessToken});

  Future<void> disconnect();
}

class WebSocketRealtimeClient implements RealtimeClient {
  WebSocketRealtimeClient({String url = AppConfig.realtimeUrl}) : _url = url;

  final String _url;
  final _eventsController = StreamController<RealtimeEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  @override
  Stream<RealtimeEvent> get events => _eventsController.stream;

  @override
  Future<void> connect({required String accessToken}) async {
    await disconnect();

    final uri = Uri.parse(
      _url,
    ).replace(queryParameters: {'token': accessToken});
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(_handleMessage);
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _handleMessage(dynamic message) {
    if (message is! String) {
      return;
    }

    final decoded = jsonDecode(message);
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final typeName = decoded['type'] as String?;
    final payload = decoded['payload'];
    final type = switch (typeName) {
      'new_job' => RealtimeEventType.newJob,
      'job_assigned' => RealtimeEventType.jobAssigned,
      'job_status_changed' => RealtimeEventType.jobStatusChanged,
      _ => null,
    };

    if (type == null || payload is! Map<String, dynamic>) {
      return;
    }

    _eventsController.add(RealtimeEvent(type: type, payload: payload));
  }

  Future<void> dispose() async {
    await disconnect();
    await _eventsController.close();
  }
}
