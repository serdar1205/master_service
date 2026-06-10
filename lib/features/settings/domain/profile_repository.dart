class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.phone,
    required this.skills,
    required this.locationKey,
    required this.menuItemKeys,
    required this.balance,
  });

  final String fullName;
  final String phone;
  final List<String> skills;
  final String locationKey;
  final List<String> menuItemKeys;
  final num balance;
}

abstract interface class ProfileRepository {
  Future<ProfileData> fetchProfile();
}
