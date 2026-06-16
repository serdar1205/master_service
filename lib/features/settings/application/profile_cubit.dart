import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../domain/profile_repository.dart';

class ProfileState {
  const ProfileState({
    required this.status,
    this.data,
    this.errorMessage,
    this.isUpdatingAvailability = false,
  });

  const ProfileState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final ProfileData? data;
  final String? errorMessage;
  final bool isUpdatingAvailability;

  ProfileState copyWith({
    AppStatus? status,
    ProfileData? data,
    String? errorMessage,
    bool clearError = false,
    bool? isUpdatingAvailability,
  }) {
    return ProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isUpdatingAvailability:
          isUpdatingAvailability ?? this.isUpdatingAvailability,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState.initial());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetchProfile();
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: error is ApiException
              ? error.message
              : 'Profil maglumatlary ýüklenmedi.',
        ),
      );
    }
  }

  Future<void> setAvailability(bool isAvailable) async {
    final current = state.data;
    if (current == null ||
        current.isAvailable == isAvailable ||
        state.isUpdatingAvailability) {
      return;
    }

    emit(
      state.copyWith(
        data: current.copyWith(isAvailable: isAvailable),
        isUpdatingAvailability: true,
        clearError: true,
      ),
    );

    try {
      await _repository.updateAvailability(isAvailable: isAvailable);
      emit(state.copyWith(isUpdatingAvailability: false));
    } on Object catch (error) {
      emit(
        state.copyWith(
          data: current,
          isUpdatingAvailability: false,
          errorMessage: error is ApiException
              ? error.message
              : 'Elýeterlilik üýtgedilmedi.',
        ),
      );
    }
  }
}
