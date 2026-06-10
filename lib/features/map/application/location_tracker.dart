import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../domain/location_repository.dart';
import 'active_order_holder.dart';

class LocationTracker {
  LocationTracker({
    required LocationRepository locationRepository,
    required SecureTokenStorage tokenStorage,
    required ActiveOrderHolder activeOrderHolder,
    AppLogger logger = const ConsoleAppLogger(),
  }) : _locationRepository = locationRepository,
       _tokenStorage = tokenStorage,
       _activeOrderHolder = activeOrderHolder,
       _logger = logger;

  final LocationRepository _locationRepository;
  final SecureTokenStorage _tokenStorage;
  final ActiveOrderHolder _activeOrderHolder;
  final AppLogger _logger;

  Timer? _timer;
  bool _isSending = false;
  String? _lastServerErrorMessage;

  Future<void> start() async {
    if (_timer != null) {
      return;
    }

    final permission = await _ensurePermission();
    if (!permission) {
      return;
    }

    await _sendCurrentLocation();
    _timer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => _sendCurrentLocation(),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _sendCurrentLocation() async {
    if (_isSending) {
      return;
    }

    final masterId = await _tokenStorage.readMasterId();
    if (masterId == null) {
      return;
    }

    _isSending = true;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await _locationRepository.sendLocation(
        masterId: masterId,
        latitude: position.latitude,
        longitude: position.longitude,
        orderId: _activeOrderHolder.activeOrderId,
        recordedAt: DateTime.now(),
      );
      _lastServerErrorMessage = null;
    } on Object catch (error, stackTrace) {
      _logLocationFailure(error, stackTrace);
    } finally {
      _isSending = false;
    }
  }

  void _logLocationFailure(Object error, StackTrace stackTrace) {
    if (error is ApiException && error.statusCode >= 500) {
      final message = error.message;
      if (_lastServerErrorMessage == message) {
        return;
      }

      _lastServerErrorMessage = message;
      _logger.info(
        'Location ping failed (${error.statusCode}): $message. '
        'This is usually a backend issue (e.g. Pusher not running).',
      );
      return;
    }

    _logger.error(
      'Failed to send master location',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void dispose() {
    stop();
  }
}
