class JobListItem {
  const JobListItem({
    required this.id,
    required this.category,
    required this.title,
    required this.address,
    required this.priceText,
    required this.statusKey,
    required this.actionKey,
    required this.distanceText,
    required this.isOutlinedAction,
    required this.isHistory,
    this.latitude,
    this.longitude,
    this.clientName,
    this.clientPhone,
  });

  final String id;
  final String category;
  final String title;
  final String address;
  final String priceText;
  final String statusKey;
  final String actionKey;
  final String distanceText;
  final bool isOutlinedAction;
  final bool isHistory;
  final double? latitude;
  final double? longitude;
  final String? clientName;
  final String? clientPhone;
}

class JobsDashboardData {
  const JobsDashboardData({
    required this.activeCount,
    required this.completedCount,
    required this.activeJobs,
    required this.historyJobs,
    required this.allJobs,
  });

  factory JobsDashboardData.fromAllOrders(List<JobListItem> orders) {
    final activeJobs = orders.where((job) => !job.isHistory).toList();
    final historyJobs = orders.where((job) => job.isHistory).toList();

    return JobsDashboardData(
      activeCount: activeJobs.length,
      completedCount: historyJobs.length,
      activeJobs: activeJobs,
      historyJobs: historyJobs,
      allJobs: orders,
    );
  }

  final int activeCount;
  final int completedCount;
  final List<JobListItem> activeJobs;
  final List<JobListItem> historyJobs;
  final List<JobListItem> allJobs;

  String? get inProgressOrderId {
    for (final job in allJobs) {
      if (job.statusKey == 'inProgress') {
        return job.id;
      }
    }
    return null;
  }
}

class OrderTaskPhoto {
  const OrderTaskPhoto({
    required this.id,
    required this.url,
    required this.status,
  });

  final String id;
  final String url;
  final String status;
}

class OrderTaskData {
  const OrderTaskData({
    required this.id,
    required this.title,
    required this.description,
    this.beforePhotos = const [],
    this.afterPhotos = const [],
  });

  final String id;
  final String title;
  final String description;
  final List<OrderTaskPhoto> beforePhotos;
  final List<OrderTaskPhoto> afterPhotos;

  String? get beforePhotoUrl =>
      beforePhotos.isNotEmpty ? beforePhotos.first.url : null;

  String? get afterPhotoUrl =>
      afterPhotos.isNotEmpty ? afterPhotos.first.url : null;
}

class TaskPhotoUploadResult {
  const TaskPhotoUploadResult({
    required this.type,
    required this.status,
    this.id,
  });

  final String? id;
  final String type;
  final String status;
}

class JobDetailsData {
  const JobDetailsData({
    required this.id,
    required this.statusKey,
    required this.clientName,
    required this.clientPhone,
    required this.address,
    required this.category,
    required this.description,
    required this.beforePhotos,
    required this.afterPhotos,
    required this.tasks,
    this.latitude,
    this.longitude,
    this.finalPrice,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.createdAt,
  });

  final String id;
  final String statusKey;
  final String clientName;
  final String clientPhone;
  final String address;
  final String category;
  final String description;
  final List<String?> beforePhotos;
  final List<String?> afterPhotos;
  final List<OrderTaskData> tasks;
  final double? latitude;
  final double? longitude;
  final num? finalPrice;
  final String? assignedAt;
  final String? startedAt;
  final String? completedAt;
  final String? createdAt;

  OrderTaskData? get primaryTask => tasks.isNotEmpty ? tasks.first : null;

  JobDetailsData copyWith({
    String? id,
    String? statusKey,
    String? clientName,
    String? clientPhone,
    String? address,
    String? category,
    String? description,
    List<String?>? beforePhotos,
    List<String?>? afterPhotos,
    List<OrderTaskData>? tasks,
    double? latitude,
    double? longitude,
    num? finalPrice,
    String? assignedAt,
    String? startedAt,
    String? completedAt,
    String? createdAt,
  }) {
    return JobDetailsData(
      id: id ?? this.id,
      statusKey: statusKey ?? this.statusKey,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      address: address ?? this.address,
      category: category ?? this.category,
      description: description ?? this.description,
      beforePhotos: beforePhotos ?? this.beforePhotos,
      afterPhotos: afterPhotos ?? this.afterPhotos,
      tasks: tasks ?? this.tasks,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      finalPrice: finalPrice ?? this.finalPrice,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String? get finalPriceText {
    final price = finalPrice;
    if (price == null) {
      return null;
    }
    return '${price.toString()} TMT';
  }

  bool get isInProgress => statusKey == 'inProgress';
}
