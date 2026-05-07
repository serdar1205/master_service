class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.skills,
    required this.locationKey,
    required this.menuItemKeys,
  });

  final String fullName;
  final List<String> skills;
  final String locationKey;
  final List<String> menuItemKeys;
}

class LocalProfileRepository {
  const LocalProfileRepository();

  Future<ProfileData> fetchProfile() async {
    return const ProfileData(
      fullName: 'Merdan Berdiýew',
      skills: ['Elektrika', 'Santexnika'],
      locationKey: 'profileLocation',
      menuItemKeys: ['settings', 'paymentHistory', 'support'],
    );
  }
}
