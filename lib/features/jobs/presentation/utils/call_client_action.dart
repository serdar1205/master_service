import 'package:flutter/material.dart';

import '../../../../app/di/app_repositories.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../domain/order_models.dart';

Future<void> callClientForJob(BuildContext context, JobListItem job) async {
  var phone = job.clientPhone;
  if (phone == null || phone.isEmpty) {
    try {
      final details = await AppRepositoriesScope.of(
        context,
      ).ordersRepository.fetchOrder(job.id);
      phone = details.clientPhone;
    } on Object {
      phone = null;
    }
  }

  if (!context.mounted) {
    return;
  }

  final localizations = AppLocalizations.of(context);
  await PhoneLauncher.call(
    context,
    phone ?? '',
    unavailableMessage: localizations.text('phoneUnavailable'),
    failedMessage: localizations.text('callFailed'),
  );
}
