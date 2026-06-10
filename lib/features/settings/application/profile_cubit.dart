import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../domain/profile_repository.dart';

class ProfileState {
  const ProfileState({required this.status, this.data, this.errorMessage});

  const ProfileState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final ProfileData? data;
  final String? errorMessage;

  ProfileState copyWith({
    AppStatus? status,
    ProfileData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
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
}
