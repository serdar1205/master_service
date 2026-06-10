import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../domain/order_models.dart';
import '../domain/orders_repository.dart';

class JobDetailsState {
  const JobDetailsState({
    required this.status,
    this.data,
    this.errorMessage,
    this.isSubmitting = false,
    this.isPickingPhoto = false,
  });

  const JobDetailsState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final JobDetailsData? data;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isPickingPhoto;

  bool get isPhotoActionLocked => isSubmitting || isPickingPhoto;

  JobDetailsState copyWith({
    AppStatus? status,
    JobDetailsData? data,
    String? errorMessage,
    bool? isSubmitting,
    bool? isPickingPhoto,
    bool clearError = false,
  }) {
    return JobDetailsState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isPickingPhoto: isPickingPhoto ?? this.isPickingPhoto,
    );
  }
}

class JobDetailsCubit extends Cubit<JobDetailsState> {
  JobDetailsCubit(this._repository) : super(const JobDetailsState.initial());

  final OrdersRepository _repository;

  Future<void> load(String jobId) async {
    emit(state.copyWith(status: AppStatus.loading, clearError: true));
    try {
      final data = await _repository.fetchOrder(jobId);
      emit(state.copyWith(status: AppStatus.success, data: data));
      await _ensureTask(jobId, data);
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: _friendlyError(
            error,
            'Sargyt maglumatlary ýüklenip bilinmedi.',
          ),
        ),
      );
    }
  }

  Future<void> _ensureTask(String jobId, JobDetailsData data) async {
    if (data.tasks.isNotEmpty) {
      return;
    }

    try {
      final task = await _repository.createTask(
        orderId: jobId,
        title: data.description.isNotEmpty ? data.description : data.category,
        description: data.description,
      );
      emit(
        state.copyWith(
          data: JobDetailsData(
            id: data.id,
            statusKey: data.statusKey,
            clientName: data.clientName,
            clientPhone: data.clientPhone,
            address: data.address,
            category: data.category,
            description: data.description,
            beforePhotos: [task.beforePhotoUrl, null],
            afterPhotos: [task.afterPhotoUrl, null],
            tasks: [task],
            latitude: data.latitude,
            longitude: data.longitude,
          ),
        ),
      );
    } on Object {
      // Task creation is best-effort; photo upload can retry later.
    }
  }

  bool tryBeginPhotoPick() {
    if (state.isPhotoActionLocked) {
      return false;
    }

    emit(state.copyWith(isPickingPhoto: true, clearError: true));
    return true;
  }

  void endPhotoPick() {
    if (!state.isPickingPhoto) {
      return;
    }

    emit(state.copyWith(isPickingPhoto: false));
  }

  Future<bool> uploadPhoto({
    required String type,
    required String filePath,
  }) async {
    final data = state.data;
    final task = data?.primaryTask;
    if (data == null || task == null) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _repository.uploadTaskPhoto(
        orderId: data.id,
        taskId: task.id,
        type: type,
        filePath: filePath,
      );
      final refreshed = await _repository.fetchOrder(data.id);
      emit(
        state.copyWith(
          status: AppStatus.success,
          data: refreshed,
          isSubmitting: false,
        ),
      );
      return true;
    } on Object catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(error, 'Surat ýüklenip bilinmedi.'),
        ),
      );
      return false;
    }
  }

  Future<bool> completeOrder(num finalPrice) async {
    final data = state.data;
    if (data == null) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _repository.completeOrder(orderId: data.id, finalPrice: finalPrice);
      emit(state.copyWith(isSubmitting: false));
      return true;
    } on Object catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(error, 'Sargyt tamamlanyp bilinmedi.'),
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
