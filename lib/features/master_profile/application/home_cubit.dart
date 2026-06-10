import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../../jobs/domain/orders_repository.dart';
import '../../settings/domain/profile_repository.dart';
import '../data/local_home_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required ProfileRepository profileRepository,
    required OrdersRepository ordersRepository,
  }) : _profileRepository = profileRepository,
       _ordersRepository = ordersRepository,
       super(const HomeState.initial());

  final ProfileRepository _profileRepository;
  final OrdersRepository _ordersRepository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final profile = await _profileRepository.fetchProfile();
      final dashboard = await _ordersRepository.fetchDashboard();

      emit(
        state.copyWith(
          status: AppStatus.success,
          data: HomeData(
            greetingKey: 'homeGreeting',
            subtitleKey: 'homeSubtitle',
            masterName: profile.fullName,
            stats: [
              HomeStat(value: '${dashboard.activeCount}', labelKey: 'active'),
              HomeStat(
                value: '${dashboard.completedCount}',
                labelKey: 'completed',
              ),
              HomeStat(value: '${profile.balance} TMT', labelKey: 'earnings'),
            ],
            activeJobs: dashboard.activeJobs,
          ),
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: error is ApiException
              ? error.message
              : 'Baş sahypa maglumatlary ýüklenmedi.',
        ),
      );
    }
  }
}

class HomeState {
  const HomeState({required this.status, this.data, this.errorMessage});

  const HomeState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final HomeData? data;
  final String? errorMessage;

  HomeState copyWith({
    AppStatus? status,
    HomeData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
