import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/network/api_exception.dart';
import 'package:master_service/features/auth/application/auth_cubit.dart';
import 'package:master_service/features/auth/domain/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.shouldFailPhone = false, this.apiError});

  final bool shouldFailPhone;
  final ApiException? apiError;

  @override
  Future<AuthSession?> restoreSession() async {
    return null;
  }

  @override
  Future<void> requestOtp(String phoneNumber) async {
    if (shouldFailPhone) {
      throw ArgumentError('invalid_phone');
    }

    if (apiError != null) {
      throw apiError!;
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    return const AuthSession(profileComplete: false, categoriesComplete: false);
  }

  @override
  Future<AuthSession> markProfileComplete() async {
    return const AuthSession(profileComplete: true, categoriesComplete: false);
  }

  @override
  Future<AuthSession> markCategoriesComplete() async {
    return const AuthSession(profileComplete: true, categoriesComplete: true);
  }

  @override
  Future<void> signOut() async {}

  var clearLocalSessionCalls = 0;

  @override
  Future<void> clearLocalSession() async {
    clearLocalSessionCalls++;
  }
}

void main() {
  test('restoreSession moves to unauthenticated without session', () async {
    final cubit = AuthCubit(_FakeAuthRepository());
    await cubit.restoreSession();

    expect(cubit.state.status, AuthStatus.unauthenticated);
  });

  test('requestOtp failure returns friendly phone error', () async {
    final cubit = AuthCubit(_FakeAuthRepository(shouldFailPhone: true));
    await cubit.requestOtp('+993');

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.errorMessage, 'Enter a valid 8-digit phone number.');
  });

  test('requestOtp failure shows API message', () async {
    const apiMessage = 'Мастер с таким номером телефона не зарегистрирован.';
    final cubit = AuthCubit(
      _FakeAuthRepository(
        apiError: const ApiException(statusCode: 422, message: apiMessage),
      ),
    );
    await cubit.requestOtp('62 11 12 22');

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.errorMessage, apiMessage);
  });

  test('verifyOtp success transitions to authenticated', () async {
    final cubit = AuthCubit(_FakeAuthRepository());
    await cubit.requestOtp('+99361000000');
    await cubit.verifyOtp('1234');

    expect(cubit.state.status, AuthStatus.authenticated);
  });

  test('handleSessionExpired clears session and signs out', () async {
    final repository = _FakeAuthRepository();
    final cubit = AuthCubit(repository);
    await cubit.requestOtp('+99361000000');
    await cubit.verifyOtp('1234');

    await cubit.handleSessionExpired();

    expect(repository.clearLocalSessionCalls, 1);
    expect(cubit.state.status, AuthStatus.unauthenticated);
  });
}
