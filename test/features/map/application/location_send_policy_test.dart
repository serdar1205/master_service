import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/map/application/location_send_policy.dart';

void main() {
  test('allows first location without previous point', () {
    expect(
      hasMovedEnoughToSendLocation(
        lastSentLatitude: null,
        lastSentLongitude: null,
        latitude: 37.94,
        longitude: 58.38,
      ),
      isTrue,
    );
  });

  test('blocks send when movement is below threshold', () {
    expect(
      hasMovedEnoughToSendLocation(
        lastSentLatitude: 37.9400,
        lastSentLongitude: 58.3800,
        latitude: 37.9401,
        longitude: 58.3801,
      ),
      isFalse,
    );
  });

  test('allows send when movement is at least 15 meters', () {
    expect(
      hasMovedEnoughToSendLocation(
        lastSentLatitude: 37.9400,
        lastSentLongitude: 58.3800,
        latitude: 37.9402,
        longitude: 58.3820,
      ),
      isTrue,
    );
  });
}
