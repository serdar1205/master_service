import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../features/jobs/application/orders_list_refresh_notifier.dart';
import '../logging/app_logger.dart';
import '../network/api_locale_holder.dart';
import '../storage/secure_token_storage.dart';
import '../widgets/app_toast.dart';
import 'master_realtime_messages.dart';
import 'pusher_reverb_realtime_client.dart';
import 'realtime_event.dart';

/// Connects the master app to `private-master.{masterId}` and refreshes UI.
class MasterRealtimeCoordinator {
  MasterRealtimeCoordinator({
    required PusherReverbRealtimeClient realtimeClient,
    required SecureTokenStorage tokenStorage,
    required OrdersListRefreshNotifier ordersListRefreshNotifier,
    required ApiLocaleHolder localeHolder,
    AppLogger logger = const ConsoleAppLogger(),
  }) : _realtimeClient = realtimeClient,
       _tokenStorage = tokenStorage,
       _ordersListRefreshNotifier = ordersListRefreshNotifier,
       _localeHolder = localeHolder,
       _logger = logger;

  final PusherReverbRealtimeClient _realtimeClient;
  final SecureTokenStorage _tokenStorage;
  final OrdersListRefreshNotifier _ordersListRefreshNotifier;
  final ApiLocaleHolder _localeHolder;
  final AppLogger _logger;

  StreamSubscription<RealtimeEvent>? _eventsSubscription;
  bool _isStarted = false;

  Future<void> start() async {
    if (_isStarted) {
      return;
    }

    _isStarted = true;
    _eventsSubscription ??= _realtimeClient.events.listen(_handleEvent);
    await _connectIfPossible();
  }

  void stop() {
    _isStarted = false;
    unawaited(_realtimeClient.disconnect());
  }

  Future<void> dispose() async {
    stop();
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    await _realtimeClient.dispose();
  }

  Future<void> reconnect() => _connectIfPossible();

  Future<void> _connectIfPossible() async {
    if (!_isStarted) {
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    final masterId = await _tokenStorage.readMasterId();

    if (token == null || token.isEmpty || masterId == null) {
      await _realtimeClient.disconnect();
      return;
    }

    await _realtimeClient.connect(accessToken: token, masterId: masterId);
  }

  void _handleEvent(RealtimeEvent event) {
    switch (event.type) {
      case RealtimeEventType.jobAssigned:
        _ordersListRefreshNotifier.requestRefresh();
        AppToast.showSuccess(
          jobAssignedToastMessage(
            locale: Locale(_localeHolder.localeCode),
            payload: event.payload,
          ),
        );
      case RealtimeEventType.jobStatusChanged:
      case RealtimeEventType.newJob:
        _ordersListRefreshNotifier.requestRefresh();
    }

    _logger.info(
      'Master realtime event handled',
      context: {'type': event.type.name, 'payload': event.payload},
    );
  }
}
