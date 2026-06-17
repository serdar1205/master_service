import '../domain/order_models.dart';
import '../domain/orders_repository.dart';

class OrderLocationEnricher {
  const OrderLocationEnricher(this._repository);

  final OrdersRepository _repository;

  Future<JobListItem> enrich(JobListItem job) async {
    if (_hasMapData(job)) {
      return job;
    }

    try {
      final details = await _repository.fetchOrder(job.id);
      return JobListItem(
        id: job.id,
        category: job.category,
        title: job.title,
        address: job.address,
        priceText: job.priceText,
        statusKey: job.statusKey,
        actionKey: job.actionKey,
        distanceText: job.distanceText,
        isOutlinedAction: job.isOutlinedAction,
        isHistory: job.isHistory,
        latitude: details.latitude ?? job.latitude,
        longitude: details.longitude ?? job.longitude,
        clientName: details.clientName.isNotEmpty
            ? details.clientName
            : job.clientName,
      );
    } on Object {
      return job;
    }
  }

  Future<List<JobListItem>> enrichAll(List<JobListItem> jobs) async {
    final enriched = <JobListItem>[];
    for (final job in jobs) {
      enriched.add(await enrich(job));
    }
    return enriched;
  }

  bool _hasMapData(JobListItem job) {
    return job.latitude != null &&
        job.longitude != null &&
        job.clientName != null &&
        job.clientName!.isNotEmpty;
  }
}
