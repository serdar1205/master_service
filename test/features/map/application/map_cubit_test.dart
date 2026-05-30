import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/app_status.dart';
import 'package:master_service/features/map/application/map_cubit.dart';
import 'package:master_service/features/map/data/local_map_repository.dart';

void main() {
  test('map cubit loads map markers', () async {
    final cubit = MapCubit(const LocalMapRepository());

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.data?.markers.length, 3);
    expect(cubit.state.data?.offers.length, 3);
  });
}
