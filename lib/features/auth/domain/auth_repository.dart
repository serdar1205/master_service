class AuthSession {
  const AuthSession({
    required this.profileComplete,
    required this.categoriesComplete,
    this.masterId,
    this.masterName,
    this.masterPhone,
  });

  final bool profileComplete;
  final bool categoriesComplete;
  final int? masterId;
  final String? masterName;
  final String? masterPhone;
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

  Future<void> clearLocalSession();
}
