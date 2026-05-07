import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_status.dart';
import '../data/local_map_repository.dart';

class MapState {
  const MapState({required this.status, this.data, this.errorMessage});

  const MapState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final MapData? data;
  final String? errorMessage;

  MapState copyWith({
    AppStatus? status,
    MapData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MapState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class MapCubit extends Cubit<MapState> {
  MapCubit(this._repository) : super(const MapState.initial());

  final LocalMapRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetchMapData();
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: 'Karta maglumatlary ýüklenmedi.',
        ),
      );
    }
  }
}
