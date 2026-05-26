import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/auth/application/auth_cubit.dart';
import 'package:master_service/features/auth/domain/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.shouldFailPhone = false});

  final bool shouldFailPhone;

  @override
  Future<AuthSession?> restoreSession() async {
    return null;
  }

  @override
  Future<void> requestOtp(String phoneNumber) async {
    if (shouldFailPhone) {
      throw ArgumentError('invalid_phone');
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

    expect(cubit.state.status, AuthStatus.failure);
    expect(cubit.state.errorMessage, 'Enter a valid 8-digit phone number.');
  });

  test('verifyOtp success transitions to authenticated', () async {
    final cubit = AuthCubit(_FakeAuthRepository());
    await cubit.requestOtp('+99361000000');
    await cubit.verifyOtp('1234');

    expect(cubit.state.status, AuthStatus.authenticated);
  });
}
