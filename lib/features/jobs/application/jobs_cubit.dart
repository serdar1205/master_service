import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../domain/order_models.dart';
import '../domain/orders_repository.dart';

class JobsState {
  const JobsState({required this.status, this.data, this.errorMessage});

  const JobsState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final JobsDashboardData? data;
  final String? errorMessage;

  JobsState copyWith({
    AppStatus? status,
    JobsDashboardData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JobsState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class JobsCubit extends Cubit<JobsState> {
  JobsCubit(this._repository) : super(const JobsState.initial());

  final OrdersRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetchDashboard();
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: _friendlyError(error, 'Sargytlar ýüklenip bilinmedi.'),
        ),
      );
    }
  }

  Future<bool> startOrder(String orderId) async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      await _repository.startOrder(orderId);
      final data = await _repository.fetchDashboard();
      emit(state.copyWith(status: AppStatus.success, data: data));
      return true;
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: _friendlyError(error, 'Sargyt başlap bolmady.'),
        ),
      );
      return false;
    }
  }

  String _friendlyError(Object error, String fallback) {
    if (error is ApiException) {
      return error.message;
    }
    return fallback;
  }
}
