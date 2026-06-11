import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/network/dio_error_mapper.dart';

void main() {
  test('map extracts API message from response body', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 422,
        data: {'message': 'Invalid OTP'},
      ),
      type: DioExceptionType.badResponse,
    );

    final mapped = DioErrorMapper.map(error);
    expect(mapped.statusCode, 422);
    expect(mapped.message, 'Invalid OTP');
  });

  test('map extracts message from Laravel-style validation response', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 422,
        data: {
          'message': 'Мастер с таким номером телефона не зарегистрирован.',
          'errors': {
            'phone': ['Мастер с таким номером телефона не зарегистрирован.'],
          },
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final mapped = DioErrorMapper.map(error);
    expect(
      mapped.message,
      'Мастер с таким номером телефона не зарегистрирован.',
    );
  });
}
