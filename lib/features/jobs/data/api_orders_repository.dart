import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/order_models.dart';
import '../domain/orders_repository.dart';
import 'order_mapper.dart';

String _fileNameFromPath(String filePath) {
  final name = filePath.split(RegExp(r'[\\/]')).last;
  return name.isEmpty ? 'photo.jpg' : name;
}

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
      allJobs: [...active, ...history],
    );
  }

  @override
  Future<List<JobListItem>> fetchAllOrders() {
    return _fetchOrders();
  }

  @override
  Future<List<JobListItem>> fetchHistory() {
    return _fetchOrders(filter: 'history');
  }

  @override
  Future<List<JobListItem>> fetchOrders({required String filter}) {
    return _fetchOrders(filter: filter);
  }

  Future<List<JobListItem>> _fetchOrders({String? filter}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/master/orders',
        queryParameters: filter == null ? null : {'filter': filter},
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return data
          .map((item) => OrderMapper.fromListJson(item as Map<String, dynamic>))
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
  Future<JobDetailsData> startOrder(String orderId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/master/orders/$orderId/start',
      );
      return _parseOrderResponse(response.data);
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
        throw ApiException(
          statusCode: response.statusCode ?? 500,
          message: _messageFromBody(response.data) ?? 'Could not create task.',
        );
      }
      return OrderMapper.taskFromJson(data);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<OrderTaskData> uploadTaskPhoto({
    required String orderId,
    required String taskId,
    required String type,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        'photo': await MultipartFile.fromFile(
          filePath,
          filename: _fileNameFromPath(filePath),
        ),
      });
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/master/orders/$orderId/tasks/$taskId/photo',
        data: formData,
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ApiException(
          statusCode: response.statusCode ?? 500,
          message: _messageFromBody(response.data) ?? 'Could not upload photo.',
        );
      }
      return OrderMapper.taskFromJson(data);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<JobDetailsData> completeOrder({
    required String orderId,
    required num finalPrice,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/master/orders/$orderId/complete',
        data: {'final_price': finalPrice},
      );
      return _parseOrderResponse(response.data);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  JobDetailsData _parseOrderResponse(Map<String, dynamic>? body) {
    final data = body?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw ApiException(
        statusCode: 500,
        message: _messageFromBody(body) ?? 'Invalid order response.',
      );
    }

    return OrderMapper.fromDetailJson(data);
  }

  String? _messageFromBody(Map<String, dynamic>? body) {
    final message = body?['message'];
    return message is String && message.isNotEmpty ? message : null;
  }
}
