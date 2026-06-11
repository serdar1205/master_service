import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

abstract class LocaleStorage {
  Future<String?> readLocaleCode();

  Future<void> writeLocaleCode(String code);
}

class AppLocaleStorage implements LocaleStorage {
  AppLocaleStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _localeKey = 'app_locale';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readLocaleCode() {
    return _storage.read(key: _localeKey);
  }

  @override
  Future<void> writeLocaleCode(String code) {
    final normalized = code == AppConstants.fallbackLocaleCode
        ? AppConstants.fallbackLocaleCode
        : AppConstants.defaultLocaleCode;

    return _storage.write(key: _localeKey, value: normalized);
  }
}
