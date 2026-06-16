import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/network/api_exception.dart';
import 'package:master_service/core/utils/app_status.dart';
import 'package:master_service/features/settings/application/profile_cubit.dart';
import 'package:master_service/features/settings/domain/profile_repository.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this._profile, {this.shouldFail = false});

  final ProfileData _profile;
  final bool shouldFail;
  bool? lastAvailability;

  @override
  Future<ProfileData> fetchProfile() async => _profile;

  @override
  Future<void> updateAvailability({required bool isAvailable}) async {
    lastAvailability = isAvailable;
    if (shouldFail) {
      throw const ApiException(statusCode: 422, message: 'Update failed.');
    }
  }
}

void main() {
  test('profile cubit loads profile data', () async {
    final cubit = ProfileCubit(
      _FakeProfileRepository(
        const ProfileData(
          fullName: 'Merdan',
          phone: '+99361000000',
          skills: ['Plumbing'],
          locationKey: 'Ashgabat',
          menuItemKeys: ['settings', 'paymentHistory', 'support'],
          balance: 0,
          isAvailable: true,
        ),
      ),
    );

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.data?.fullName, isNotEmpty);
    expect(cubit.state.data?.menuItemKeys.length, 3);
    expect(cubit.state.data?.isAvailable, isTrue);
  });

  test('profile cubit updates availability', () async {
    final repository = _FakeProfileRepository(
      const ProfileData(
        fullName: 'Merdan',
        phone: '+99361000000',
        skills: ['Plumbing'],
        locationKey: 'Ashgabat',
        menuItemKeys: ['settings', 'paymentHistory', 'support'],
        balance: 0,
        isAvailable: true,
      ),
    );
    final cubit = ProfileCubit(repository);
    await cubit.load();

    await cubit.setAvailability(false);

    expect(repository.lastAvailability, isFalse);
    expect(cubit.state.data?.isAvailable, isFalse);
    expect(cubit.state.isUpdatingAvailability, isFalse);
  });

  test('profile cubit reverts availability on failure', () async {
    final repository = _FakeProfileRepository(
      const ProfileData(
        fullName: 'Merdan',
        phone: '+99361000000',
        skills: ['Plumbing'],
        locationKey: 'Ashgabat',
        menuItemKeys: ['settings', 'paymentHistory', 'support'],
        balance: 0,
        isAvailable: true,
      ),
      shouldFail: true,
    );
    final cubit = ProfileCubit(repository);
    await cubit.load();

    await cubit.setAvailability(false);

    expect(cubit.state.data?.isAvailable, isTrue);
    expect(cubit.state.errorMessage, 'Update failed.');
  });
}
