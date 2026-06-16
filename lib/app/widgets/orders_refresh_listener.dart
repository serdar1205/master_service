import 'package:flutter/material.dart';

import '../di/app_repositories.dart';
import '../../features/jobs/application/orders_list_refresh_notifier.dart';

class OrdersRefreshListener extends StatefulWidget {
  const OrdersRefreshListener({
    required this.onRefreshRequested,
    required this.child,
    super.key,
  });

  final VoidCallback onRefreshRequested;
  final Widget child;

  @override
  State<OrdersRefreshListener> createState() => _OrdersRefreshListenerState();
}

class _OrdersRefreshListenerState extends State<OrdersRefreshListener> {
  OrdersListRefreshNotifier? _notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextNotifier = AppRepositoriesScope.of(
      context,
    ).ordersListRefreshNotifier;
    if (_notifier != nextNotifier) {
      _notifier?.removeListener(_handleRefresh);
      _notifier = nextNotifier;
      _notifier?.addListener(_handleRefresh);
    }
  }

  void _handleRefresh() => widget.onRefreshRequested();

  @override
  void dispose() {
    _notifier?.removeListener(_handleRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
