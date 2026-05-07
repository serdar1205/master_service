class AppError implements Exception {
  const AppError({required this.message, this.details, this.stackTrace});

  final String message;
  final Object? details;
  final StackTrace? stackTrace;

  @override
  String toString() {
    if (details == null) {
      return message;
    }

    return '$message ($details)';
  }
}
