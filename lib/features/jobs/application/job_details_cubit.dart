import 'dart:async' show unawaited;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_status.dart';
import '../data/photo_slot_mapper.dart';
import '../domain/order_models.dart';
import '../domain/orders_repository.dart';
import '../domain/task_photo_slot_state.dart';

const _photoSlotCount = PhotoSlotMapper.slotsPerType;
const _emptyPendingPhotos = <String?>[null, null];

class JobDetailsState {
  const JobDetailsState({
    required this.status,
    this.data,
    this.errorMessage,
    this.isSubmitting = false,
    this.isCreatingTask = false,
    this.isPickingPhoto = false,
    this.pendingBeforePhotos = _emptyPendingPhotos,
    this.pendingAfterPhotos = _emptyPendingPhotos,
    this.taskPhotoSlots = const {},
    this.activePhotoPickTaskId,
    this.activePhotoPickType,
  });

  const JobDetailsState.initial() : this(status: AppStatus.idle);

  final AppStatus status;
  final JobDetailsData? data;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isCreatingTask;
  final bool isPickingPhoto;
  final List<String?> pendingBeforePhotos;
  final List<String?> pendingAfterPhotos;
  final Map<String, TaskPhotoSlotUiState> taskPhotoSlots;
  final String? activePhotoPickTaskId;
  final String? activePhotoPickType;

  bool get isPhotoActionLocked =>
      isSubmitting || isPickingPhoto || isCreatingTask;

  bool get isTasksLoading => status == AppStatus.loading && data != null;

  bool get hasPendingBeforePhotos => _hasPendingPhotos(pendingBeforePhotos);

  bool get hasPendingAfterPhotos => _hasPendingPhotos(pendingAfterPhotos);

  bool hasPendingPhotos(String type) {
    return type == 'before' ? hasPendingBeforePhotos : hasPendingAfterPhotos;
  }

  TaskPhotoSlotUiState taskPhotoSlot(String taskId, String type) {
    return taskPhotoSlots[taskPhotoSlotKey(taskId, type)] ??
        const TaskPhotoSlotUiState();
  }

  JobDetailsState copyWith({
    AppStatus? status,
    JobDetailsData? data,
    String? errorMessage,
    bool? isSubmitting,
    bool? isCreatingTask,
    bool? isPickingPhoto,
    List<String?>? pendingBeforePhotos,
    List<String?>? pendingAfterPhotos,
    Map<String, TaskPhotoSlotUiState>? taskPhotoSlots,
    String? activePhotoPickTaskId,
    String? activePhotoPickType,
    bool clearError = false,
    bool clearPendingPhotos = false,
    bool clearActivePhotoPick = false,
  }) {
    return JobDetailsState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCreatingTask: isCreatingTask ?? this.isCreatingTask,
      isPickingPhoto: isPickingPhoto ?? this.isPickingPhoto,
      pendingBeforePhotos: clearPendingPhotos
          ? _emptyPendingPhotos
          : pendingBeforePhotos ?? this.pendingBeforePhotos,
      pendingAfterPhotos: clearPendingPhotos
          ? _emptyPendingPhotos
          : pendingAfterPhotos ?? this.pendingAfterPhotos,
      taskPhotoSlots: taskPhotoSlots ?? this.taskPhotoSlots,
      activePhotoPickTaskId: clearActivePhotoPick
          ? null
          : activePhotoPickTaskId ?? this.activePhotoPickTaskId,
      activePhotoPickType: clearActivePhotoPick
          ? null
          : activePhotoPickType ?? this.activePhotoPickType,
    );
  }

  static bool _hasPendingPhotos(List<String?> photos) {
    return photos.any((path) => path != null && path.isNotEmpty);
  }
}

class JobDetailsCubit extends Cubit<JobDetailsState> {
  JobDetailsCubit(this._repository) : super(const JobDetailsState.initial());

  final OrdersRepository _repository;

  Future<void> load(String jobId) async {
    final hadData = state.data != null;
    emit(
      state.copyWith(
        status: AppStatus.loading,
        clearError: true,
        clearPendingPhotos: !hadData,
        taskPhotoSlots: hadData ? state.taskPhotoSlots : const {},
      ),
    );
    try {
      final fetched = await _repository.fetchOrder(jobId);
      emit(
        state.copyWith(
          status: AppStatus.success,
          data: PhotoSlotMapper.arrangeFromApi(fetched),
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: hadData ? AppStatus.success : AppStatus.failure,
          errorMessage: _friendlyError(
            error,
            'Sargyt maglumatlary ýüklenip bilinmedi.',
          ),
        ),
      );
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
  }) async {
    final data = state.data;
    if (data == null || !data.isInProgress) {
      return false;
    }

    emit(state.copyWith(isCreatingTask: true, clearError: true));
    try {
      final task = await _repository.createTask(
        orderId: data.id,
        title: title,
        description: description,
      );
      emit(
        state.copyWith(
          isCreatingTask: false,
          data: data.copyWith(tasks: [...data.tasks, task]),
        ),
      );
      return true;
    } on Object catch (error) {
      emit(
        state.copyWith(
          isCreatingTask: false,
          errorMessage: _friendlyError(error, 'Tabşyryk döredilip bilinmedi.'),
        ),
      );
      return false;
    }
  }

  bool beginTaskPhotoPick(String taskId, String type) {
    if (state.isPhotoActionLocked) {
      return false;
    }

    emit(
      state.copyWith(
        isPickingPhoto: true,
        activePhotoPickTaskId: taskId,
        activePhotoPickType: type,
        clearError: true,
      ),
    );
    return true;
  }

  void endPhotoPick() {
    if (!state.isPickingPhoto) {
      return;
    }

    emit(state.copyWith(isPickingPhoto: false, clearActivePhotoPick: true));
  }

  void addRecoveredTaskPhoto(String path) {
    final taskId = state.activePhotoPickTaskId;
    final type = state.activePhotoPickType;
    if (taskId == null || type == null) {
      return;
    }

    unawaited(uploadTaskPhoto(taskId: taskId, type: type, filePath: path));
  }

  String? taskPhotoSource(OrderTaskData task, String type) {
    final slot = state.taskPhotoSlot(task.id, type);
    if (slot.localPreviewPath != null) {
      return slot.localPreviewPath;
    }

    final photos = type == 'before' ? task.beforePhotos : task.afterPhotos;
    return photos.isNotEmpty ? photos.first.url : null;
  }

  bool isTaskPhotoUploading(String taskId, String type) {
    return state.taskPhotoSlot(taskId, type).isUploading;
  }

  bool isTaskPhotoFailed(String taskId, String type) {
    return state.taskPhotoSlot(taskId, type).hasError;
  }

  bool canEditTaskPhoto(OrderTaskData task, String type, bool orderInProgress) {
    if (!orderInProgress) {
      return false;
    }

    final photos = type == 'before' ? task.beforePhotos : task.afterPhotos;
    if (photos.isNotEmpty) {
      return true;
    }

    final slot = state.taskPhotoSlot(task.id, type);
    return !slot.isUploading;
  }

  bool canAddTaskPhoto(OrderTaskData task, String type, bool orderInProgress) {
    if (!orderInProgress) {
      return false;
    }

    final photos = type == 'before' ? task.beforePhotos : task.afterPhotos;
    if (photos.isNotEmpty) {
      return false;
    }

    final slot = state.taskPhotoSlot(task.id, type);
    return !slot.isUploading && slot.localPreviewPath == null;
  }

  Future<bool> uploadTaskPhoto({
    required String taskId,
    required String type,
    required String filePath,
  }) async {
    final data = state.data;
    if (data == null) {
      return false;
    }

    final key = taskPhotoSlotKey(taskId, type);
    final slots = Map<String, TaskPhotoSlotUiState>.from(state.taskPhotoSlots);
    slots[key] = TaskPhotoSlotUiState(
      localPreviewPath: filePath,
      isUploading: true,
    );
    emit(state.copyWith(taskPhotoSlots: slots, clearError: true));

    try {
      final updatedTask = await _repository.uploadTaskPhoto(
        orderId: data.id,
        taskId: taskId,
        type: type,
        filePath: filePath,
      );
      final refreshedSlots = Map<String, TaskPhotoSlotUiState>.from(
        state.taskPhotoSlots,
      );
      refreshedSlots.remove(key);
      emit(
        state.copyWith(
          data: _replaceTask(data, updatedTask),
          taskPhotoSlots: refreshedSlots,
        ),
      );
      return true;
    } on Object catch (error) {
      final failedSlots = Map<String, TaskPhotoSlotUiState>.from(
        state.taskPhotoSlots,
      );
      failedSlots[key] = TaskPhotoSlotUiState(
        localPreviewPath: filePath,
        hasError: true,
      );
      emit(
        state.copyWith(
          taskPhotoSlots: failedSlots,
          errorMessage: _friendlyError(error, 'Surat ýüklenip bilinmedi.'),
        ),
      );
      return false;
    }
  }

  Future<bool> retryTaskPhotoUpload({
    required String taskId,
    required String type,
  }) async {
    final key = taskPhotoSlotKey(taskId, type);
    final slot = state.taskPhotoSlots[key];
    final path = slot?.localPreviewPath;
    if (path == null) {
      return false;
    }

    return uploadTaskPhoto(taskId: taskId, type: type, filePath: path);
  }

  bool tryBeginPhotoPick() {
    if (state.isPhotoActionLocked) {
      return false;
    }

    emit(state.copyWith(isPickingPhoto: true, clearError: true));
    return true;
  }

  int availableBeforePhotoSlots() => _availablePhotoSlots('before');

  int availableAfterPhotoSlots() => _availablePhotoSlots('after');

  int availablePhotoSlots(String type) => _availablePhotoSlots(type);

  String? beforePhotoAt(int index) => _photoAt('before', index);

  String? afterPhotoAt(int index) => _photoAt('after', index);

  String? photoAt(String type, int index) => _photoAt(type, index);

  bool isPendingBeforePhoto(int index) => _isPendingPhoto('before', index);

  bool isPendingAfterPhoto(int index) => _isPendingPhoto('after', index);

  bool isPendingPhoto(String type, int index) => _isPendingPhoto(type, index);

  void setPendingBeforePhotos(List<String> paths) =>
      _setPendingPhotos('before', paths);

  void setPendingAfterPhotos(List<String> paths) =>
      _setPendingPhotos('after', paths);

  void addRecoveredBeforePhoto(String path) {
    if (availableBeforePhotoSlots() == 0) {
      return;
    }

    setPendingBeforePhotos([path]);
  }

  void removePendingBeforePhoto(int index) =>
      _removePendingPhoto('before', index);

  void removePendingAfterPhoto(int index) =>
      _removePendingPhoto('after', index);

  void removePendingPhoto(String type, int index) =>
      _removePendingPhoto(type, index);

  Future<bool> submitBeforePhotos() => _submitPhotos('before');

  Future<bool> submitAfterPhotos() => _submitPhotos('after');

  Future<bool> submitPhotos(String type) => _submitPhotos(type);

  Future<bool> completeOrder() async {
    final data = state.data;
    if (data == null) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final updated = await _repository.completeOrder(
        orderId: data.id,
        finalPrice: data.finalPrice,
      );
      emit(
        state.copyWith(
          status: AppStatus.success,
          data: PhotoSlotMapper.arrangeFromApi(updated),
          isSubmitting: false,
        ),
      );
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

  JobDetailsData _replaceTask(JobDetailsData data, OrderTaskData updated) {
    return data.copyWith(
      tasks: data.tasks
          .map((task) => task.id == updated.id ? updated : task)
          .toList(),
    );
  }

  int _availablePhotoSlots(String type) {
    final data = state.data;
    if (data == null) {
      return 0;
    }

    var available = 0;
    for (var i = 0; i < _photoSlotCount; i++) {
      if (_serverPhotoAt(data, type, i) == null) {
        available++;
      }
    }
    return available;
  }

  String? _photoAt(String type, int index) {
    final data = state.data;
    if (data == null || index < 0 || index >= _photoSlotCount) {
      return null;
    }

    final pending = _pendingPhotoAt(type, index);
    if (pending != null) {
      return pending;
    }

    return _serverPhotoAt(data, type, index);
  }

  bool _isPendingPhoto(String type, int index) {
    return _pendingPhotoAt(type, index) != null;
  }

  void _setPendingPhotos(String type, List<String> paths) {
    final data = state.data;
    if (data == null || paths.isEmpty) {
      return;
    }

    final pending = List<String?>.from(_pendingPhotos(type));
    while (pending.length < _photoSlotCount) {
      pending.add(null);
    }

    var pathIndex = 0;
    for (
      var slot = 0;
      slot < _photoSlotCount && pathIndex < paths.length;
      slot++
    ) {
      if (_serverPhotoAt(data, type, slot) != null) {
        continue;
      }
      pending[slot] = paths[pathIndex++];
    }

    emit(_copyWithPending(type, pending, clearError: true));
  }

  void _removePendingPhoto(String type, int index) {
    final pending = List<String?>.from(_pendingPhotos(type));
    if (index < 0 || index >= pending.length) {
      return;
    }

    pending[index] = null;
    emit(_copyWithPending(type, pending));
  }

  Future<bool> _submitPhotos(String type) async {
    final data = state.data;
    final task = data?.primaryTask;
    if (data == null) {
      return false;
    }
    if (task == null) {
      emit(
        state.copyWith(
          errorMessage:
              'Surat ýüklemek üçin iş başlanmaly we tabşyryk döredilmeli.',
        ),
      );
      return false;
    }

    final uploads = <String>[];
    for (var i = 0; i < _photoSlotCount; i++) {
      final pending = _pendingPhotoAt(type, i);
      if (pending != null) {
        uploads.add(pending);
      }
    }

    if (uploads.isEmpty) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      var currentData = data;
      for (final filePath in uploads) {
        final updatedTask = await _repository.uploadTaskPhoto(
          orderId: data.id,
          taskId: task.id,
          type: type,
          filePath: filePath,
        );
        currentData = _replaceTask(currentData, updatedTask);
      }

      final refreshed = await _repository.fetchOrder(data.id);
      emit(
        _copyWithPending(
          type,
          _emptyPendingPhotos,
          status: AppStatus.success,
          data: PhotoSlotMapper.arrangeFromApi(refreshed),
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

  List<String?> _pendingPhotos(String type) {
    return type == 'before'
        ? state.pendingBeforePhotos
        : state.pendingAfterPhotos;
  }

  JobDetailsState _copyWithPending(
    String type,
    List<String?> pending, {
    AppStatus? status,
    JobDetailsData? data,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    if (type == 'before') {
      return state.copyWith(
        status: status,
        data: data,
        isSubmitting: isSubmitting,
        pendingBeforePhotos: pending,
        clearError: clearError,
      );
    }

    return state.copyWith(
      status: status,
      data: data,
      isSubmitting: isSubmitting,
      pendingAfterPhotos: pending,
      clearError: clearError,
    );
  }

  List<String?> _serverPhotos(JobDetailsData data, String type) {
    return type == 'before' ? data.beforePhotos : data.afterPhotos;
  }

  String? _serverPhotoAt(JobDetailsData data, String type, int index) {
    final photos = _serverPhotos(data, type);
    if (index >= photos.length) {
      return null;
    }
    return photos[index];
  }

  String? _pendingPhotoAt(String type, int index) {
    final pending = _pendingPhotos(type);
    if (index >= pending.length) {
      return null;
    }
    return pending[index];
  }

  String _friendlyError(Object error, String fallback) {
    if (error is ApiException) {
      return error.message;
    }
    return fallback;
  }
}
