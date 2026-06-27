import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../domain/app_settings.dart';
import '../domain/app_settings_repository.dart';

class AppSettingsState {
  const AppSettingsState({required this.status, this.data, this.errorMessage});

  const AppSettingsState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final AppSettings? data;
  final String? errorMessage;

  AppSettingsState copyWith({
    AppStatus? status,
    AppSettings? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppSettingsState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._repository) : super(const AppSettingsState.initial());

  final AppSettingsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));

    try {
      final data = await _repository.fetchSettings();
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: error is ApiException
              ? error.message
              : 'Could not load terms.',
        ),
      );
    }
  }
}
