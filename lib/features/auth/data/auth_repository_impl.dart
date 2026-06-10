import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../../../core/utils/phone_formatter.dart';
import '../domain/auth_repository.dart';
import 'dto/auth_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    return _readCurrentSession(
      masterId: await _tokenStorage.readMasterId(),
      masterName: await _tokenStorage.readMasterName(),
      masterPhone: await _tokenStorage.readMasterPhone(),
    );
  }

  @override
  Future<void> requestOtp(String phoneNumber) async {
    if (!PhoneFormatter.isValidLocal(phoneNumber)) {
      throw ArgumentError('invalid_phone');
    }

    final phone = PhoneFormatter.toE164(phoneNumber);

    try {
      await _apiClient.dio.post<void>(
        '/api/v1/master/auth/request-otp',
        data: {'phone': phone},
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    if (!PhoneFormatter.isValidLocal(phoneNumber)) {
      throw ArgumentError('invalid_phone');
    }

    final otp = otpCode.trim();
    if (!RegExp(r'^\d{4,6}$').hasMatch(otp)) {
      throw ArgumentError('invalid_otp');
    }

    final phone = PhoneFormatter.toE164(phoneNumber);

    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/master/auth/verify-otp',
        data: {'phone': phone, 'code': otp},
      );

      final dto = VerifyOtpResponseDto.fromJson(
        response.data ?? const <String, dynamic>{},
      );

      await _tokenStorage.writeAccessToken(dto.token);
      await _tokenStorage.writeMasterId(dto.master.id);
      await _tokenStorage.writeMasterName(dto.master.name);
      await _tokenStorage.writeMasterPhone(dto.master.phone);
      await _tokenStorage.writeProfileComplete(
        value: dto.master.name.trim().isNotEmpty,
      );
      await _tokenStorage.writeCategoriesComplete(
        value: dto.master.categories.isNotEmpty,
      );

      return _readCurrentSession(
        masterId: dto.master.id,
        masterName: dto.master.name,
        masterPhone: dto.master.phone,
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<AuthSession> markProfileComplete() async {
    await _tokenStorage.writeProfileComplete(value: true);
    return _readCurrentSession(
      masterId: await _tokenStorage.readMasterId(),
      masterName: await _tokenStorage.readMasterName(),
      masterPhone: await _tokenStorage.readMasterPhone(),
    );
  }

  @override
  Future<AuthSession> markCategoriesComplete() async {
    await _tokenStorage.writeCategoriesComplete(value: true);
    return _readCurrentSession(
      masterId: await _tokenStorage.readMasterId(),
      masterName: await _tokenStorage.readMasterName(),
      masterPhone: await _tokenStorage.readMasterPhone(),
    );
  }

  @override
  Future<void> clearLocalSession() {
    return _tokenStorage.clearSession();
  }

  @override
  Future<void> signOut() async {
    try {
      await _apiClient.dio.post<void>('/api/v1/master/auth/logout');
    } on DioException {
      // Clear local session even when logout API fails.
    }

    await _tokenStorage.clearSession();
  }

  Future<AuthSession> _readCurrentSession({
    int? masterId,
    String? masterName,
    String? masterPhone,
  }) async {
    return AuthSession(
      profileComplete: await _tokenStorage.readProfileComplete(),
      categoriesComplete: await _tokenStorage.readCategoriesComplete(),
      masterId: masterId,
      masterName: masterName,
      masterPhone: masterPhone,
    );
  }
}
