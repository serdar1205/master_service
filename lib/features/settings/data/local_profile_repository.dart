export '../domain/profile_repository.dart';

import '../domain/profile_repository.dart';

class LocalProfileRepository implements ProfileRepository {
  const LocalProfileRepository();

  @override
  Future<ProfileData> fetchProfile() async {
    return const ProfileData(
      fullName: 'Merdan Berdiýew',
      phone: '+99361000000',
      skills: ['Elektrika', 'Santexnika'],
      locationKey: 'profileLocation',
      menuItemKeys: ['settings', 'paymentHistory', 'support'],
      balance: 0,
      isAvailable: true,
    );
  }

  @override
  Future<void> updateAvailability({required bool isAvailable}) async {}
}
