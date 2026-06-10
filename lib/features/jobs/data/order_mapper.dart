import '../domain/order_models.dart';

class OrderMapper {
  const OrderMapper._();

  static JobListItem fromListJson(
    Map<String, dynamic> json, {
    bool isHistory = false,
  }) {
    final status = json['status'] as String? ?? 'assigned';
    final description = json['description'] as String? ?? '';
    final category = json['category'] as String? ?? '';
    final createdAt = json['created_at'] as String? ?? '';

    return JobListItem(
      id: '${json['id']}',
      category: category,
      title: _truncate(description.isNotEmpty ? description : category, 48),
      address: json['address'] as String? ?? '',
      priceText: '—',
      statusKey: _statusKey(status),
      actionKey: _actionKey(status),
      distanceText: isHistory ? _formatDate(createdAt) : '',
      isOutlinedAction: status == 'in_progress',
      isHistory: isHistory,
    );
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
      beforePhotos.add(task.beforePhotoUrl);
      beforePhotos.add(null);
      afterPhotos.add(task.afterPhotoUrl);
      afterPhotos.add(null);
    } else {
      for (final photo in photos) {
        final url = photo['url'] as String?;
        if (url != null) {
          beforePhotos.add(url);
        }
      }
      while (beforePhotos.length < 2) {
        beforePhotos.add(null);
      }
      afterPhotos.addAll([null, null]);
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
    );
  }

  static OrderTaskData _taskFromJson(Map<String, dynamic> json) {
    return OrderTaskData(
      id: '${json['id']}',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      beforePhotoUrl: json['before_photo'] as String?,
      afterPhotoUrl: json['after_photo'] as String?,
    );
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
