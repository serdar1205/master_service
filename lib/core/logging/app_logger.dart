import 'dart:developer' as developer;

abstract interface class AppLogger {
  void info(String message, {Map<String, Object?>? context});

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });
}

class ConsoleAppLogger implements AppLogger {
  const ConsoleAppLogger();

  @override
  void info(String message, {Map<String, Object?>? context}) {
    developer.log(message, name: 'master_service.info', error: context);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    developer.log(
      message,
      name: 'master_service.error',
      error: error ?? context,
      stackTrace: stackTrace,
    );
  }
}
