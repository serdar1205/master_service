import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/app_status.dart';
import 'package:master_service/features/settings/application/profile_cubit.dart';
import 'package:master_service/features/settings/data/local_profile_repository.dart';

void main() {
  test('profile cubit loads profile data', () async {
    final cubit = ProfileCubit(const LocalProfileRepository());

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.data?.fullName, isNotEmpty);
    expect(cubit.state.data?.menuItemKeys.length, 3);
  });
}
