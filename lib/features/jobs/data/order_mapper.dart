import '../domain/order_models.dart';

class OrderMapper {
  const OrderMapper._();

  static const int _photoSlotsPerType = 2;

  static JobListItem fromListJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'assigned';
    final description = json['description'] as String? ?? '';
    final category = json['category'] as String? ?? '';
    final createdAt = json['created_at'] as String? ?? '';
    final isHistory = _isHistoryStatus(status);

    return JobListItem(
      id: '${json['id']}',
      category: category,
      title: _truncate(description.isNotEmpty ? description : category, 48),
      clientName: json['client_name'] as String?,
      address: json['address'] as String? ?? '',
      priceText: '—',
      statusKey: _statusKey(status),
      actionKey: _actionKey(status),
      distanceText: isHistory ? _formatDate(createdAt) : '',
      isOutlinedAction: status == 'in_progress',
      isHistory: isHistory,
    );
  }

  static bool _isHistoryStatus(String status) {
    return status == 'completed' || status == 'cancelled';
  }

  static OrderTaskData taskFromJson(Map<String, dynamic> json) {
    return _taskFromJson(json);
  }

  static JobDetailsData fromDetailJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'assigned';
    final photos = (json['photos'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final tasks = (json['tasks'] as List<dynamic>? ?? const [])
        .map((item) => _taskFromJson(item as Map<String, dynamic>))
        .toList();

    final beforePhotos = <String?>[];
    final afterPhotos = <String?>[];

    if (tasks.isNotEmpty) {
      final task = tasks.first;
      beforePhotos.addAll(_photoSlotsFromList(task.beforePhotos));
      afterPhotos.addAll(_photoSlotsFromList(task.afterPhotos));
    } else {
      for (final photo in photos) {
        final url = _photoUrlFromJson(photo);
        if (url != null) {
          beforePhotos.add(url);
        }
      }
      while (beforePhotos.length < _photoSlotsPerType) {
        beforePhotos.add(null);
      }
      afterPhotos.addAll(List<String?>.filled(_photoSlotsPerType, null));
    }

    return JobDetailsData(
      id: '${json['id']}',
      statusKey: _statusKey(status),
      clientName: json['client_name'] as String? ?? '',
      clientPhone: json['client_phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      beforePhotos: beforePhotos,
      afterPhotos: afterPhotos,
      tasks: tasks,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      finalPrice: json['final_price'] as num?,
      assignedAt: json['assigned_at'] as String?,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  static OrderTaskData _taskFromJson(Map<String, dynamic> json) {
    return OrderTaskData(
      id: '${json['id']}',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      beforePhotos: _photosListFromJson(
        json['before_photos'],
        json['before_photo'],
      ),
      afterPhotos: _photosListFromJson(
        json['after_photos'],
        json['after_photo'],
      ),
    );
  }

  static List<OrderTaskPhoto> _photosListFromJson(
    dynamic arrayValue,
    dynamic legacyValue,
  ) {
    if (arrayValue is List) {
      return arrayValue
          .whereType<Map>()
          .map((item) => _photoFromJson(Map<String, dynamic>.from(item)))
          .whereType<OrderTaskPhoto>()
          .toList();
    }

    final legacyUrl = _photoUrlFromJson(legacyValue);
    if (legacyUrl != null) {
      return [OrderTaskPhoto(id: '', url: legacyUrl, status: 'done')];
    }

    return const [];
  }

  static OrderTaskPhoto? _photoFromJson(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    if (url == null || url.isEmpty) {
      return null;
    }

    return OrderTaskPhoto(
      id: '${json['id']}',
      url: url,
      status: json['status'] as String? ?? 'done',
    );
  }

  static List<String?> _photoSlotsFromList(List<OrderTaskPhoto> photos) {
    final slots = List<String?>.filled(_photoSlotsPerType, null);
    for (var i = 0; i < photos.length && i < _photoSlotsPerType; i++) {
      slots[i] = photos[i].url;
    }
    return slots;
  }

  static String? _photoUrlFromJson(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value.isEmpty ? null : value;
    }

    if (value is Map) {
      final url = value['url'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }

    return null;
  }

  static String _statusKey(String apiStatus) {
    return switch (apiStatus) {
      'assigned' => 'assigned',
      'in_progress' => 'inProgress',
      'completed' => 'completed',
      'cancelled' => 'cancelled',
      _ => apiStatus,
    };
  }

  static String _actionKey(String apiStatus) {
    return switch (apiStatus) {
      'assigned' => 'startJob',
      'in_progress' => 'complete',
      'completed' => 'report',
      _ => 'report',
    };
  }

  static String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength - 1)}…';
  }

  static String formatDisplayDate(String? iso) {
    if (iso == null || iso.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(iso);
    if (date == null) {
      return iso;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  static String _formatDate(String iso) {
    if (iso.isEmpty) {
      return '';
    }
    final date = DateTime.tryParse(iso);
    if (date == null) {
      return iso;
    }
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
