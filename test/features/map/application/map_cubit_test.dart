import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/app_status.dart';
import 'package:master_service/features/jobs/data/local_jobs_repository.dart';
import 'package:master_service/features/jobs/domain/orders_repository.dart';
import 'package:master_service/features/map/application/map_cubit.dart';

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository(this._dashboard, this._details);

  final JobsDashboardData _dashboard;
  final JobDetailsData _details;

  @override
  Future<JobsDashboardData> fetchDashboard() async => _dashboard;

  @override
  Future<List<JobListItem>> fetchAllOrders() async => _dashboard.allJobs;

  @override
  Future<List<JobListItem>> fetchHistory() async => _dashboard.historyJobs;

  @override
  Future<List<JobListItem>> fetchOrders({required String filter}) async {
    return filter == 'active' ? _dashboard.activeJobs : _dashboard.historyJobs;
  }

  @override
  Future<JobDetailsData> fetchOrder(String orderId) async => _details;

  @override
  Future<JobDetailsData> startOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<OrderTaskData> createTask({
    required String orderId,
    required String title,
    required String description,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OrderTaskData> uploadTaskPhoto({
    required String orderId,
    required String taskId,
    required String type,
    required String filePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<JobDetailsData> completeOrder({
    required String orderId,
    num? finalPrice,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('map cubit loads active order offers', () async {
    final local = const LocalJobsRepository();
    final dashboard = await local.fetchDashboard();
    final details = await local.fetchDetails('job-1');
    final cubit = MapCubit(_FakeOrdersRepository(dashboard, details));

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.data?.offers.length, 1);
  });
}
