import 'package:flutter/widgets.dart';

import '../../app/localization/app_localizations.dart';

String jobAssignedToastMessage({
  required Locale locale,
  required Map<String, Object?> payload,
}) {
  final l10n = AppLocalizations(locale);
  final clientName = payload['client_name']?.toString().trim();
  final orderId = payload['order_id'];

  if (clientName != null && clientName.isNotEmpty) {
    return l10n
        .text('realtimeJobAssignedNamed')
        .replaceAll('{client}', clientName);
  }

  if (orderId != null) {
    return l10n.text('realtimeJobAssignedOrder').replaceAll('{id}', '$orderId');
  }

  return l10n.text('realtimeJobAssignedGeneric');
}
