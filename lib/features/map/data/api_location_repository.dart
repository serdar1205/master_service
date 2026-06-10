import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/location_repository.dart';

class ApiLocationRepository implements LocationRepository {
  ApiLocationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> sendLocation({
    required int masterId,
    required double latitude,
    required double longitude,
    int? orderId,
    DateTime? recordedAt,
  }) async {
    try {
      final payload = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      };
      if (orderId != null) {
        payload['order_id'] = orderId;
      }
      if (recordedAt != null) {
        payload['recorded_at'] = recordedAt.toIso8601String();
      }

      await _apiClient.dio.post<void>(
        '/api/v1/master/$masterId/location',
        data: payload,
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }
}
