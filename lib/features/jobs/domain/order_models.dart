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
}

class JobsDashboardData {
  const JobsDashboardData({
    required this.activeCount,
    required this.completedCount,
    required this.activeJobs,
    required this.historyJobs,
  });

  final int activeCount;
  final int completedCount;
  final List<JobListItem> activeJobs;
  final List<JobListItem> historyJobs;

  String? get inProgressOrderId {
    for (final job in activeJobs) {
      if (job.statusKey == 'inProgress') {
        return job.id;
      }
    }
    return null;
  }
}

class OrderTaskData {
  const OrderTaskData({
    required this.id,
    required this.title,
    required this.description,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
  });

  final String id;
  final String title;
  final String description;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;
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

  OrderTaskData? get primaryTask => tasks.isNotEmpty ? tasks.first : null;
}
