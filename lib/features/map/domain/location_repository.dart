abstract interface class LocationRepository {
  Future<void> sendLocation({
    required int masterId,
    required double latitude,
    required double longitude,
    int? orderId,
    DateTime? recordedAt,
  });
}
