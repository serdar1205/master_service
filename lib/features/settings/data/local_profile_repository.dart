export '../domain/profile_repository.dart';

import '../../categories/domain/service_category.dart';
import '../domain/profile_repository.dart';

class LocalProfileRepository implements ProfileRepository {
  const LocalProfileRepository();

  @override
  Future<ProfileData> fetchProfile() async {
    return const ProfileData(
      fullName: 'Merdan Berdiýew',
      phone: '+99361000000',
      categories: [
        ServiceCategory(id: 1, name: 'Elektrika'),
        ServiceCategory(id: 2, name: 'Santexnika'),
      ],
      locationKey: 'profileLocation',
      menuItemKeys: ['settings', 'paymentHistory', 'support'],
      balance: 0,
      isAvailable: true,
    );
  }

  @override
  Future<void> updateAvailability({required bool isAvailable}) async {}
}
