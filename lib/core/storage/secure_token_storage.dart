import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  SecureTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _accessTokenKey = 'access_token';
  static const _profileCompleteKey = 'profile_complete';
  static const _categoriesCompleteKey = 'categories_complete';
  static const _masterIdKey = 'master_id';
  static const _masterNameKey = 'master_name';
  static const _masterPhoneKey = 'master_phone';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> writeAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  Future<int?> readMasterId() async {
    final value = await _storage.read(key: _masterIdKey);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> writeMasterId(int masterId) {
    return _storage.write(key: _masterIdKey, value: masterId.toString());
  }

  Future<String?> readMasterName() {
    return _storage.read(key: _masterNameKey);
  }

  Future<void> writeMasterName(String name) {
    return _storage.write(key: _masterNameKey, value: name);
  }

  Future<String?> readMasterPhone() {
    return _storage.read(key: _masterPhoneKey);
  }

  Future<void> writeMasterPhone(String phone) {
    return _storage.write(key: _masterPhoneKey, value: phone);
  }

  Future<bool> readProfileComplete() async {
    return (await _storage.read(key: _profileCompleteKey)) == 'true';
  }

  Future<void> writeProfileComplete({required bool value}) {
    return _storage.write(key: _profileCompleteKey, value: value.toString());
  }

  Future<bool> readCategoriesComplete() async {
    return (await _storage.read(key: _categoriesCompleteKey)) == 'true';
  }

  Future<void> writeCategoriesComplete({required bool value}) {
    return _storage.write(key: _categoriesCompleteKey, value: value.toString());
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _profileCompleteKey);
    await _storage.delete(key: _categoriesCompleteKey);
    await _storage.delete(key: _masterIdKey);
    await _storage.delete(key: _masterNameKey);
    await _storage.delete(key: _masterPhoneKey);
  }
}
