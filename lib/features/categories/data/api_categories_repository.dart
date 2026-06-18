import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/categories_repository.dart';
import '../domain/service_category.dart';
import 'category_dto.dart';

class ApiCategoriesRepository implements CategoriesRepository {
  ApiCategoriesRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ServiceCategory>> fetchCategoryTree() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/master/categories',
      );
      final data = response.data?['data'] as List<dynamic>? ?? const [];
      return parseCategoryTree(data);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }
}
