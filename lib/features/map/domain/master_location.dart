class MasterLocation {
  const MasterLocation({
    required this.masterId,
    required this.cityId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  final String masterId;
  final String cityId;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
}
