import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  SecureTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _accessTokenKey = 'access_token';
  static const _profileCompleteKey = 'profile_complete';
  static const _categoriesCompleteKey = 'categories_complete';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> writeAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
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
  }
}
