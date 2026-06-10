import '../../jobs/domain/order_models.dart';

class ActiveOrderHolder {
  int? _activeOrderId;

  int? get activeOrderId => _activeOrderId;

  void updateFromDashboard(JobsDashboardData? data) {
    final orderId = data?.inProgressOrderId;
    _activeOrderId = orderId == null ? null : int.tryParse(orderId);
  }

  void updateFromActiveJobs(List<JobListItem> jobs) {
    for (final job in jobs) {
      if (job.statusKey == 'inProgress') {
        _activeOrderId = int.tryParse(job.id);
        return;
      }
    }
    _activeOrderId = null;
  }

  void clear() {
    _activeOrderId = null;
  }
}
