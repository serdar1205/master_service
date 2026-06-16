import 'package:flutter/widgets.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_locale_holder.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/jobs/application/orders_list_refresh_notifier.dart';
import '../../features/jobs/data/api_orders_repository.dart';
import '../../features/jobs/domain/orders_repository.dart';
import '../../features/map/application/active_order_holder.dart';
import '../../features/map/data/api_location_repository.dart';
import '../../features/map/domain/location_repository.dart';
import '../../features/settings/data/api_profile_repository.dart';
import '../../features/settings/domain/profile_repository.dart';

class AppRepositories {
  AppRepositories({
    required this.tokenStorage,
    required this.apiClient,
    required this.authRepository,
    required this.profileRepository,
    required this.ordersRepository,
    required this.locationRepository,
    required this.activeOrderHolder,
    required this.ordersListRefreshNotifier,
  });

  factory AppRepositories.create() {
    final tokenStorage = SecureTokenStorage();
    final localeHolder = ApiLocaleHolder();
    final apiClient = ApiClient(
      tokenStorage: tokenStorage,
      localeHolder: localeHolder,
    );
    final activeOrderHolder = ActiveOrderHolder();
    final ordersListRefreshNotifier = OrdersListRefreshNotifier();

    return AppRepositories(
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authRepository: AuthRepositoryImpl(apiClient, tokenStorage),
      profileRepository: ApiProfileRepository(apiClient),
      ordersRepository: ApiOrdersRepository(apiClient),
      locationRepository: ApiLocationRepository(apiClient),
      activeOrderHolder: activeOrderHolder,
      ordersListRefreshNotifier: ordersListRefreshNotifier,
    );
  }

  final SecureTokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final OrdersRepository ordersRepository;
  final LocationRepository locationRepository;
  final ActiveOrderHolder activeOrderHolder;
  final OrdersListRefreshNotifier ordersListRefreshNotifier;
}

class AppRepositoriesScope extends InheritedWidget {
  const AppRepositoriesScope({
    required this.repositories,
    required super.child,
    super.key,
  });

  final AppRepositories repositories;

  static AppRepositories of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppRepositoriesScope>();
    assert(scope != null, 'AppRepositoriesScope not found in widget tree.');
    return scope!.repositories;
  }

  @override
  bool updateShouldNotify(AppRepositoriesScope oldWidget) => false;
}
