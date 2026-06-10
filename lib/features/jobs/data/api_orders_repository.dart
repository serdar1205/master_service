import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/order_models.dart';
import '../domain/orders_repository.dart';
import 'order_mapper.dart';

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<JobsDashboardData> fetchDashboard() async {
    final active = await _fetchOrders(filter: 'active');
    final history = await _fetchOrders(filter: 'history');

    return JobsDashboardData(
      activeCount: active.length,
      completedCount: history.length,
      activeJobs: active,
      historyJobs: history,
    );
  }

  @override
  Future<List<JobListItem>> fetchHistory() {
    return _fetchOrders(filter: 'history');
  }

  Future<List<JobListItem>> _fetchOrders({required String filter}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/master/orders',
        queryParameters: {'filter': filter},
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      final isHistory = filter == 'history';
      return data
          .map(
            (item) => OrderMapper.fromListJson(
              item as Map<String, dynamic>,
              isHistory: isHistory,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<JobDetailsData> fetchOrder(String orderId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/master/orders/$orderId',
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(statusCode: 404, message: 'Order not found.');
      }
      return OrderMapper.fromDetailJson(data);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<void> startOrder(String orderId) async {
    try {
      await _apiClient.dio.post<void>('/api/v1/master/orders/$orderId/start');
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<OrderTaskData> createTask({
    required String orderId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/master/orders/$orderId/tasks',
        data: {'title': title, 'description': description},
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(
          statusCode: 500,
          message: 'Could not create task.',
        );
      }
      return OrderTaskData(
        id: '${data['id']}',
        title: data['title'] as String? ?? title,
        description: data['description'] as String? ?? description,
        beforePhotoUrl: data['before_photo'] as String?,
        afterPhotoUrl: data['after_photo'] as String?,
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<void> uploadTaskPhoto({
    required String orderId,
    required String taskId,
    required String type,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        'photo': await MultipartFile.fromFile(filePath),
      });
      await _apiClient.dio.post<void>(
        '/api/v1/master/orders/$orderId/tasks/$taskId/photo',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<void> completeOrder({
    required String orderId,
    required num finalPrice,
  }) async {
    try {
      await _apiClient.dio.post<void>(
        '/api/v1/master/orders/$orderId/complete',
        data: {'final_price': finalPrice},
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }
}
