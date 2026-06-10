import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/app/di/app_repositories.dart';
import 'package:master_service/app/master_app.dart';
import 'package:master_service/features/auth/application/auth_cubit.dart';
import 'package:master_service/features/auth/domain/auth_repository.dart';
import 'package:master_service/features/map/application/location_tracker.dart';

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

  @override
  Future<void> clearLocalSession() async {}
}

void main() {
  testWidgets('shows phone login after session restore fails', (tester) async {
    final repositories = AppRepositories.create();
    final authCubit = AuthCubit(_TestAuthRepository());
    final locationTracker = LocationTracker(
      locationRepository: repositories.locationRepository,
      tokenStorage: repositories.tokenStorage,
      activeOrderHolder: repositories.activeOrderHolder,
    );

    await tester.pumpWidget(
      MasterApp(
        authCubit: authCubit,
        repositories: repositories,
        locationTracker: locationTracker,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hoş geldiňiz!'), findsOneWidget);
    expect(find.text('Usta hyzmaty'), findsOneWidget);

    locationTracker.dispose();
    authCubit.close();
  });
}
