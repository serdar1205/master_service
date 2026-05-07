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
  });

  final String greetingKey;
  final String subtitleKey;
  final List<HomeStat> stats;
}

class LocalHomeRepository {
  const LocalHomeRepository();

  Future<HomeData> fetchHomeData() async {
    return const HomeData(
      greetingKey: 'homeGreeting',
      subtitleKey: 'homeSubtitle',
      stats: [
        HomeStat(value: '12', labelKey: 'active'),
        HomeStat(value: '48', labelKey: 'completed'),
        HomeStat(value: '3.4k', labelKey: 'earnings'),
      ],
    );
  }
}
