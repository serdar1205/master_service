import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.brand,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// Wraps non-scrollable content so pull-to-refresh still works.
class AppRefreshableBody extends StatelessWidget {
  const AppRefreshableBody({
    required this.onRefresh,
    required this.child,
    this.padding,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
