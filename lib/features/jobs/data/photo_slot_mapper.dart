import '../domain/order_models.dart';

class PhotoSlotMapper {
  const PhotoSlotMapper._();

  static const int slotsPerType = 2;

  static JobDetailsData arrangeFromApi(JobDetailsData data) {
    final task = data.primaryTask;
    if (task == null) {
      return data;
    }

    return data.copyWith(
      beforePhotos: _slotsFromPhotos(task.beforePhotos),
      afterPhotos: _slotsFromPhotos(task.afterPhotos),
    );
  }

  static JobDetailsData applyPhotoAtSlot(
    JobDetailsData data, {
    required String type,
    required int slotIndex,
    required String? photoUrl,
  }) {
    final index = _normalizeSlotIndex(slotIndex);

    if (type == 'before') {
      final photos = _normalizedSlots(data.beforePhotos);
      photos[index] = photoUrl;
      return data.copyWith(beforePhotos: photos);
    }

    final photos = _normalizedSlots(data.afterPhotos);
    photos[index] = photoUrl;
    return data.copyWith(afterPhotos: photos);
  }

  static List<String?> _slotsFromPhotos(List<OrderTaskPhoto> photos) {
    final slots = List<String?>.filled(slotsPerType, null);
    for (var i = 0; i < photos.length && i < slotsPerType; i++) {
      slots[i] = photos[i].url;
    }
    return slots;
  }

  static List<String?> _normalizedSlots(List<String?> slots) {
    final normalized = List<String?>.from(slots);
    while (normalized.length < slotsPerType) {
      normalized.add(null);
    }
    if (normalized.length > slotsPerType) {
      return normalized.sublist(0, slotsPerType);
    }
    return normalized;
  }

  static int _normalizeSlotIndex(int? slotIndex) {
    if (slotIndex == null) {
      return 0;
    }

    if (slotIndex < 0) {
      return 0;
    }

    if (slotIndex >= slotsPerType) {
      return slotsPerType - 1;
    }

    return slotIndex;
  }
}
