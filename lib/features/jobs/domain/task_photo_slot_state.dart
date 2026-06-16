class TaskPhotoSlotUiState {
  const TaskPhotoSlotUiState({
    this.localPreviewPath,
    this.isUploading = false,
    this.hasError = false,
  });

  final String? localPreviewPath;
  final bool isUploading;
  final bool hasError;

  TaskPhotoSlotUiState copyWith({
    String? localPreviewPath,
    bool? isUploading,
    bool? hasError,
    bool clearPreview = false,
  }) {
    return TaskPhotoSlotUiState(
      localPreviewPath: clearPreview
          ? null
          : localPreviewPath ?? this.localPreviewPath,
      isUploading: isUploading ?? this.isUploading,
      hasError: hasError ?? this.hasError,
    );
  }
}

String taskPhotoSlotKey(String taskId, String type) => '$taskId:$type';
