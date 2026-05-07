import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_status.dart';
import '../data/local_jobs_repository.dart';

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

  final LocalJobsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetchDashboard();
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: 'Sargytlar ýüklenip bilinmedi.',
        ),
      );
    }
  }
}
