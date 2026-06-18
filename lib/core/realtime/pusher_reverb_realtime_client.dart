import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import 'realtime_client.dart';
import 'realtime_event.dart';
import 'reverb_event_parser.dart';

/// Master-app Reverb client using [PusherChannelsFlutter] (Pusher protocol).
class PusherReverbRealtimeClient implements RealtimeClient {
  PusherReverbRealtimeClient({
    AppLogger logger = const ConsoleAppLogger(),
    Future<Map<String, dynamic>> Function({
      required String channelName,
      required String socketId,
      required String accessToken,
    })?
    authorizeChannel,
  }) : _logger = logger,
       _authorizeChannel = authorizeChannel ?? _defaultAuthorizeChannel;

  final AppLogger _logger;
  final Future<Map<String, dynamic>> Function({
    required String channelName,
    required String socketId,
    required String accessToken,
  })
  _authorizeChannel;
  final _eventsController = StreamController<RealtimeEvent>.broadcast();
  final _pusher = PusherChannelsFlutter.getInstance();

  String? _accessToken;
  int? _masterId;
  String? _subscribedChannel;
  bool _isConnecting = false;

  @override
  Stream<RealtimeEvent> get events => _eventsController.stream;

  @override
  Future<void> connect({required String accessToken, int? masterId}) async {
    if (masterId == null) {
      _logger.error('Cannot connect realtime without master id.');
      return;
    }

    if (_isConnecting &&
        _accessToken == accessToken &&
        _masterId == masterId &&
        _pusher.connectionState == 'CONNECTED') {
      return;
    }

    _accessToken = accessToken;
    _masterId = masterId;
    _isConnecting = true;

    try {
      await disconnect();

      await _pusher.init(
        apiKey: AppConfig.reverbAppKey,
        cluster: AppConfig.reverbCluster,
        useTLS: AppConfig.reverbUseTls,
        onEvent: _handlePusherEvent,
        onAuthorizer: _authorizeChannelCallback,
        onError: (message, code, error) {
          _logger.error(
            'Reverb connection error',
            error: error,
            context: {'message': message, 'code': code},
          );
        },
        onConnectionStateChange: (current, previous) {
          _logger.info('Reverb state: $previous -> $current');
        },
        onSubscriptionError: (message, error) {
          _logger.error(
            'Reverb subscription error',
            error: error,
            context: {'message': message},
          );
        },
      );

      await _pusher.methodChannel.invokeMethod<void>('init', {
        'apiKey': AppConfig.reverbAppKey,
        'host': AppConfig.reverbHost,
        if (AppConfig.reverbUseTls)
          'wssPort': AppConfig.reverbPort
        else
          'wsPort': AppConfig.reverbPort,
        'useTLS': AppConfig.reverbUseTls,
        'authorizer': true,
      });

      await _pusher.connect();

      final channelName = masterChannelName(masterId);
      _subscribedChannel = channelName;
      await _pusher.subscribe(channelName: channelName);

      _logger.info(
        'Subscribed to master realtime channel',
        context: {'channel': channelName},
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Failed to connect master realtime channel',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isConnecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    final channel = _subscribedChannel;
    if (channel != null) {
      try {
        await _pusher.unsubscribe(channelName: channel);
      } on Object catch (error) {
        _logger.error('Failed to unsubscribe realtime channel', error: error);
      }
    }

    _subscribedChannel = null;

    try {
      await _pusher.disconnect();
    } on Object catch (error) {
      _logger.error('Failed to disconnect realtime client', error: error);
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _eventsController.close();
  }

  Future<dynamic> _authorizeChannelCallback(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Missing access token for Reverb auth.');
    }

    return _authorizeChannel(
      channelName: channelName,
      socketId: socketId,
      accessToken: token,
    );
  }

  void _handlePusherEvent(PusherEvent event) {
    final mapped = parseReverbEvent(
      eventName: event.eventName,
      data: event.data,
    );

    if (mapped == null) {
      if (!event.eventName.startsWith('pusher')) {
        _logger.info(
          'Ignored Reverb event',
          context: {'event': event.eventName},
        );
      }
      return;
    }

    _logger.info(
      'Received Reverb event',
      context: {'event': event.eventName, 'payload': mapped.payload},
    );

    if (!_eventsController.isClosed) {
      _eventsController.add(mapped);
    }
  }
}

Future<Map<String, dynamic>> _defaultAuthorizeChannel({
  required String channelName,
  required String socketId,
  required String accessToken,
}) async {
  final dio = Dio(BaseOptions(headers: const {'Accept': 'application/json'}));

  final response = await dio.post<Map<String, dynamic>>(
    AppConfig.reverbAuthEndpoint,
    data: {'socket_id': socketId, 'channel_name': channelName},
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {'Authorization': 'Bearer $accessToken'},
    ),
  );

  final body = response.data;
  if (body == null) {
    throw StateError('Empty Reverb auth response.');
  }

  return body;
}
