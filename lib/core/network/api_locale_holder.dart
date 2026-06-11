import '../constants/app_constants.dart';

class ApiLocaleHolder {
  ApiLocaleHolder({String? initialLocaleCode})
    : _localeCode = normalizeLocaleCode(
        initialLocaleCode ?? AppConstants.defaultLocaleCode,
      );

  static const headerName = 'X-Locale';

  String _localeCode;

  String get localeCode => _localeCode;

  void setLocaleCode(String code) {
    _localeCode = normalizeLocaleCode(code);
  }

  static String normalizeLocaleCode(String code) {
    return code == AppConstants.fallbackLocaleCode
        ? AppConstants.fallbackLocaleCode
        : AppConstants.defaultLocaleCode;
  }
}
