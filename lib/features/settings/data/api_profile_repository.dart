import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../auth/data/dto/auth_dto.dart';
import '../domain/profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ProfileData> fetchProfile() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/master/me',
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(
          statusCode: 404,
          message: 'Profile not found.',
        );
      }

      final master = MasterDto.fromJson(data);
      return ProfileData(
        fullName: master.name,
        phone: master.phone,
        skills: master.categories.map((category) => category.name).toList(),
        locationKey: master.city?.name ?? '',
        menuItemKeys: const ['settings', 'paymentHistory', 'support'],
        balance: master.balance,
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }
}
