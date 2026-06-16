import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../domain/location_repository.dart';
import 'active_order_holder.dart';
import 'location_send_policy.dart';

const _minSendDistanceMeters = minLocationSendDistanceMeters;

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

  StreamSubscription<Position>? _positionSubscription;
  bool _isSending = false;
  String? _lastServerErrorMessage;
  Position? _lastSentPosition;

  static final _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: _minSendDistanceMeters.round(),
  );

  Future<void> start() async {
    if (_positionSubscription != null) {
      return;
    }

    final permission = await _ensurePermission();
    if (!permission) {
      return;
    }

    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    );
    await _sendPosition(initialPosition, force: true);

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: _locationSettings,
        ).listen((position) {
          unawaited(_sendPosition(position));
        });
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastSentPosition = null;
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _sendPosition(Position position, {bool force = false}) async {
    if (_isSending) {
      return;
    }

    if (!force && !_hasMovedEnough(position)) {
      return;
    }

    final masterId = await _tokenStorage.readMasterId();
    if (masterId == null) {
      return;
    }

    _isSending = true;
    try {
      await _locationRepository.sendLocation(
        masterId: masterId,
        latitude: position.latitude,
        longitude: position.longitude,
        orderId: _activeOrderHolder.activeOrderId,
        recordedAt: DateTime.now(),
      );
      _lastSentPosition = position;
      _lastServerErrorMessage = null;
    } on Object catch (error, stackTrace) {
      _logLocationFailure(error, stackTrace);
    } finally {
      _isSending = false;
    }
  }

  bool _hasMovedEnough(Position position) {
    final lastSent = _lastSentPosition;
    return hasMovedEnoughToSendLocation(
      lastSentLatitude: lastSent?.latitude,
      lastSentLongitude: lastSent?.longitude,
      latitude: position.latitude,
      longitude: position.longitude,
      minDistanceMeters: _minSendDistanceMeters,
    );
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
