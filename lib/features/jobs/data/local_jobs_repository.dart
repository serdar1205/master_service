export '../domain/order_models.dart';

import '../domain/order_models.dart';

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
      statusKey: 'inProgress',
      clientName: 'Merdan',
      clientPhone: '+99361234567',
      address: 'Aşgabat ş., Parahat 4, 12-nji jaý',
      category: 'Santehnik',
      description: 'Suw akmasyny düzetmek',
      beforePhotos: [_jobImageUrl, null],
      afterPhotos: [_jobImageUrl, null],
      tasks: [],
    );
  }
}
