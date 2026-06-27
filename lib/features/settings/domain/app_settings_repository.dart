import 'app_settings.dart';

abstract interface class AppSettingsRepository {
  Future<AppSettings> fetchSettings();
}
