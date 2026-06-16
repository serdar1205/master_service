enum OrdersFilter {
  active,
  history;

  String get apiValue => switch (this) {
    OrdersFilter.active => 'active',
    OrdersFilter.history => 'history',
  };
}
