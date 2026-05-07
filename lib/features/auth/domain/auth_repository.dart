class AuthSession {
  const AuthSession({
    required this.profileComplete,
    required this.categoriesComplete,
  });

  final bool profileComplete;
  final bool categoriesComplete;
}

abstract interface class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<void> requestOtp(String phoneNumber);

  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });

  Future<AuthSession> markProfileComplete();

  Future<AuthSession> markCategoriesComplete();

  Future<void> signOut();
}
