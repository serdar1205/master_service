import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_status.dart';
import '../data/local_jobs_repository.dart';

class JobDetailsState {
  const JobDetailsState({required this.status, this.data, this.errorMessage});

  const JobDetailsState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final JobDetailsData? data;
  final String? errorMessage;

  JobDetailsState copyWith({
    AppStatus? status,
    JobDetailsData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JobDetailsState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class JobDetailsCubit extends Cubit<JobDetailsState> {
  JobDetailsCubit(this._repository) : super(const JobDetailsState.initial());

  final LocalJobsRepository _repository;

  Future<void> load(String jobId) async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetchDetails(jobId);
      emit(state.copyWith(status: AppStatus.success, data: data));
    } on Object {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: 'Sargyt maglumatlary ýüklenip bilinmedi.',
        ),
      );
    }
  }
}
