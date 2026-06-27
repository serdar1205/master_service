import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/app_settings.dart';
import '../domain/app_settings_repository.dart';
import 'dto/app_settings_dto.dart';

class ApiAppSettingsRepository implements AppSettingsRepository {
  ApiAppSettingsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AppSettings> fetchSettings() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/master/settings',
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(
          statusCode: 404,
          message: 'Settings not found.',
        );
      }

      final dto = AppSettingsDto.fromJson(data);
      return AppSettings(content: dto.content);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }
}
