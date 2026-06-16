import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../domain/order_models.dart';
import '../domain/orders_filter.dart';
import '../domain/orders_repository.dart';

class JobsState {
  const JobsState({
    required this.status,
    this.dashboard,
    this.jobs = const [],
    this.filter = OrdersFilter.active,
    this.errorMessage,
  });

  const JobsState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final JobsDashboardData? dashboard;
  final List<JobListItem> jobs;
  final OrdersFilter filter;
  final String? errorMessage;

  int get activeCount => dashboard?.activeCount ?? 0;

  int get completedCount => dashboard?.completedCount ?? 0;

  JobsState copyWith({
    AppStatus? status,
    JobsDashboardData? dashboard,
    List<JobListItem>? jobs,
    OrdersFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JobsState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      jobs: jobs ?? this.jobs,
      filter: filter ?? this.filter,
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
      final dashboard = await _repository.fetchDashboard();
      final jobs = await _repository.fetchOrders(filter: state.filter.apiValue);
      emit(
        state.copyWith(
          status: AppStatus.success,
          dashboard: dashboard,
          jobs: jobs,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: _friendlyError(error, 'Sargytlar ýüklenip bilinmedi.'),
        ),
      );
    }
  }

  Future<void> setFilter(OrdersFilter filter) async {
    if (filter == state.filter && state.jobs.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        filter: filter,
        status: AppStatus.loading,
        clearError: true,
      ),
    );
    try {
      final jobs = await _repository.fetchOrders(filter: filter.apiValue);
      emit(state.copyWith(status: AppStatus.success, jobs: jobs));
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
      final dashboard = await _repository.fetchDashboard();
      final jobs = await _repository.fetchOrders(filter: state.filter.apiValue);
      emit(
        state.copyWith(
          status: AppStatus.success,
          dashboard: dashboard,
          jobs: jobs,
        ),
      );
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
