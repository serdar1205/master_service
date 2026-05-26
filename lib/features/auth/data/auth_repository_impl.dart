import '../../../core/storage/secure_token_storage.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    return AuthSession(
      profileComplete: await _tokenStorage.readProfileComplete(),
      categoriesComplete: await _tokenStorage.readCategoriesComplete(),
    );
  }

  @override
  Future<void> requestOtp(String phoneNumber) async {
    final normalizedPhone = _normalizePhone(phoneNumber);
    if (!_phonePattern.hasMatch(normalizedPhone)) {
      throw ArgumentError('invalid_phone');
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final normalizedPhone = _normalizePhone(phoneNumber);
    if (!_phonePattern.hasMatch(normalizedPhone)) {
      throw ArgumentError('invalid_phone');
    }

    if (!_otpPattern.hasMatch(otpCode.trim())) {
      throw ArgumentError('invalid_otp');
    }

    await _tokenStorage.writeAccessToken('local-master-session');
    return _readCurrentSession();
  }

  @override
  Future<AuthSession> markProfileComplete() async {
    await _tokenStorage.writeProfileComplete(value: true);
    return _readCurrentSession();
  }

  @override
  Future<AuthSession> markCategoriesComplete() async {
    await _tokenStorage.writeCategoriesComplete(value: true);
    return _readCurrentSession();
  }

  @override
  Future<void> signOut() {
    return _tokenStorage.clearSession();
  }

  Future<AuthSession> _readCurrentSession() async {
    return AuthSession(
      profileComplete: await _tokenStorage.readProfileComplete(),
      categoriesComplete: await _tokenStorage.readCategoriesComplete(),
    );
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Turkmen local number: 8 digits, optionally prefixed with country code 993.
  static final _phonePattern = RegExp(r'^(\d{8}|993\d{8})$');
  static final _otpPattern = RegExp(r'^\d{4,6}$');
}
