import '../../categories/domain/service_category.dart';

class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.phone,
    required this.categories,
    required this.locationKey,
    required this.menuItemKeys,
    required this.balance,
    required this.isAvailable,
  });

  final String fullName;
  final String phone;
  final List<ServiceCategory> categories;
  final String locationKey;
  final List<String> menuItemKeys;
  final num balance;
  final bool isAvailable;

  ProfileData copyWith({
    String? fullName,
    String? phone,
    List<ServiceCategory>? categories,
    String? locationKey,
    List<String>? menuItemKeys,
    num? balance,
    bool? isAvailable,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      categories: categories ?? this.categories,
      locationKey: locationKey ?? this.locationKey,
      menuItemKeys: menuItemKeys ?? this.menuItemKeys,
      balance: balance ?? this.balance,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

abstract interface class ProfileRepository {
  Future<ProfileData> fetchProfile();

  Future<void> updateAvailability({required bool isAvailable});
}
