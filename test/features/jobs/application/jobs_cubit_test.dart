import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/app_status.dart';
import 'package:master_service/features/jobs/application/jobs_cubit.dart';
import 'package:master_service/features/jobs/data/local_jobs_repository.dart';
import 'package:master_service/features/jobs/domain/orders_repository.dart';

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository(this._dashboard);

  final JobsDashboardData _dashboard;

  @override
  Future<JobsDashboardData> fetchDashboard() async => _dashboard;

  @override
  Future<List<JobListItem>> fetchHistory() async => _dashboard.historyJobs;

  @override
  Future<JobDetailsData> fetchOrder(String orderId) {
    throw UnimplementedError();
  }

  @override
  Future<void> startOrder(String orderId) async {}

  @override
  Future<OrderTaskData> createTask({
    required String orderId,
    required String title,
    required String description,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> uploadTaskPhoto({
    required String orderId,
    required String taskId,
    required String type,
    required String filePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> completeOrder({
    required String orderId,
    required num finalPrice,
  }) async {}
}

void main() {
  test('jobs cubit loads dashboard from repository', () async {
    final local = const LocalJobsRepository();
    final dashboard = await local.fetchDashboard();
    final cubit = JobsCubit(_FakeOrdersRepository(dashboard));

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.data?.activeJobs.length, 1);
    expect(cubit.state.data?.historyJobs.length, 1);
  });
}
