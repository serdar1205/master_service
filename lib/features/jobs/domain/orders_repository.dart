import 'order_models.dart';

abstract interface class OrdersRepository {
  Future<JobsDashboardData> fetchDashboard();

  Future<List<JobListItem>> fetchHistory();

  Future<JobDetailsData> fetchOrder(String orderId);

  Future<void> startOrder(String orderId);

  Future<OrderTaskData> createTask({
    required String orderId,
    required String title,
    required String description,
  });

  Future<void> uploadTaskPhoto({
    required String orderId,
    required String taskId,
    required String type,
    required String filePath,
  });

  Future<void> completeOrder({
    required String orderId,
    required num finalPrice,
  });
}
