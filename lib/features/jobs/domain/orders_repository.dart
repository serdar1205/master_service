import 'order_models.dart';

abstract interface class OrdersRepository {
  Future<JobsDashboardData> fetchDashboard();

  Future<List<JobListItem>> fetchAllOrders();

  Future<List<JobListItem>> fetchHistory();

  Future<List<JobListItem>> fetchOrders({required String filter});

  Future<JobDetailsData> fetchOrder(String orderId);

  Future<JobDetailsData> startOrder(String orderId);

  Future<OrderTaskData> createTask({
    required String orderId,
    required String title,
    required String description,
  });

  Future<OrderTaskData> uploadTaskPhoto({
    required String orderId,
    required String taskId,
    required String type,
    required String filePath,
  });

  Future<JobDetailsData> completeOrder({
    required String orderId,
    num? finalPrice,
  });
}
