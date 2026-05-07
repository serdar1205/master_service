import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/app/master_app.dart';
import 'package:master_service/features/auth/application/auth_cubit.dart';
import 'package:master_service/features/auth/domain/auth_repository.dart';

class _TestAuthRepository implements AuthRepository {
  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> requestOtp(String phoneNumber) async {}

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
  testWidgets('shows phone login after session restore fails', (tester) async {
    await tester.pumpWidget(
      MasterApp(authCubit: AuthCubit(_TestAuthRepository())),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hoş geldiňiz!'), findsOneWidget);
    expect(find.text('Usta hyzmaty'), findsOneWidget);
  });
}
