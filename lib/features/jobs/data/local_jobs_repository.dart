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
}

class JobDetailsData {
  const JobDetailsData({
    required this.id,
    required this.beforePhotos,
    required this.afterPhotos,
  });

  final String id;
  final List<String?> beforePhotos;
  final List<String?> afterPhotos;
}

class LocalJobsRepository {
  const LocalJobsRepository();

  static const _jobImageUrl = 'local:image';

  Future<JobsDashboardData> fetchDashboard() async {
    return const JobsDashboardData(
      activeCount: 12,
      completedCount: 48,
      activeJobs: [
        JobListItem(
          id: 'job-1',
          category: 'Elektrik',
          title: 'Rozetka we lentalar',
          address: 'Aşgabat ş., Magtymguly şaýoly 45',
          priceText: '250 TMT',
          statusKey: 'assigned',
          actionKey: 'startJob',
          distanceText: '2.5 km',
          isOutlinedAction: false,
          isHistory: false,
        ),
        JobListItem(
          id: 'job-2',
          category: 'Santehnik',
          title: 'Suw akmasyny\ndüzetmek',
          address: 'Aşgabat ş., Parahat 4, 12-nji jaý',
          priceText: '180 TMT',
          statusKey: 'inProgress',
          actionKey: 'complete',
          distanceText: '4.2 km',
          isOutlinedAction: true,
          isHistory: false,
        ),
        JobListItem(
          id: 'job-3',
          category: 'Kondisioner',
          title: 'Filtr arassalamak',
          address: 'Änew ş., 10 ýyl abadançylyk köç.',
          priceText: '320 TMT',
          statusKey: 'assigned',
          actionKey: 'startJob',
          distanceText: '3.1 km',
          isOutlinedAction: false,
          isHistory: false,
        ),
      ],
      historyJobs: [
        JobListItem(
          id: 'job-h1',
          category: 'Santehnik',
          title: 'Turbany çalyşmak',
          address: 'Aşgabat ş., Görogly köç. 12',
          priceText: '150 TMT',
          statusKey: 'completed',
          actionKey: 'report',
          distanceText: '12.05.2024',
          isOutlinedAction: false,
          isHistory: true,
        ),
      ],
    );
  }

  Future<JobDetailsData> fetchDetails(String jobId) async {
    return const JobDetailsData(
      id: 'job-2',
      beforePhotos: [_jobImageUrl, null],
      afterPhotos: [_jobImageUrl, null],
    );
  }
}
