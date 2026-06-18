import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_empty_view.dart';

class AppEmptyPage extends StatelessWidget {
  const AppEmptyPage({
    this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.onAction,
    this.actionLabel,
    super.key,
  });

  final String? title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kFFF4FBFB,
      body: SafeArea(
        child: AppEmptyView(
          title: title,
          message: message,
          icon: icon,
          onAction: onAction,
          actionLabel: actionLabel,
        ),
      ),
    );
  }
}
