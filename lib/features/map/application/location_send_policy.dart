import 'package:geolocator/geolocator.dart';

const minLocationSendDistanceMeters = 15.0;

bool hasMovedEnoughToSendLocation({
  required double? lastSentLatitude,
  required double? lastSentLongitude,
  required double latitude,
  required double longitude,
  double minDistanceMeters = minLocationSendDistanceMeters,
}) {
  if (lastSentLatitude == null || lastSentLongitude == null) {
    return true;
  }

  final distanceMeters = Geolocator.distanceBetween(
    lastSentLatitude,
    lastSentLongitude,
    latitude,
    longitude,
  );

  return distanceMeters >= minDistanceMeters;
}
