import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_status.dart';
import '../data/local_home_repository.dart';

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

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState.initial());

  final LocalHomeRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetchHomeData();
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: 'Baş sahypa maglumatlary ýüklenmedi.',
        ),
      );
    }
  }
}
