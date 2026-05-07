class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const realtimeUrl = String.fromEnvironment(
    'REALTIME_URL',
    defaultValue: 'wss://realtime.example.com',
  );

  static const requestTimeout = Duration(seconds: 30);

  static void validateOrThrow({required bool isDebugMode}) {
    if (isDebugMode) {
      return;
    }

    if (apiBaseUrl == 'https://api.example.com' ||
        realtimeUrl == 'wss://realtime.example.com') {
      throw StateError(
        'Missing required --dart-define values: API_BASE_URL and REALTIME_URL.',
      );
    }
  }
}
