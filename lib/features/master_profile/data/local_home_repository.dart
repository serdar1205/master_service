import '../../jobs/domain/order_models.dart';

class HomeStat {
  const HomeStat({required this.value, required this.labelKey});

  final String value;
  final String labelKey;
}

class HomeData {
  const HomeData({
    required this.greetingKey,
    required this.subtitleKey,
    required this.stats,
    this.masterName,
    this.activeJobs = const [],
  });

  final String greetingKey;
  final String subtitleKey;
  final List<HomeStat> stats;
  final String? masterName;
  final List<JobListItem> activeJobs;
}
