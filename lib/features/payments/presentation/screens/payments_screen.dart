import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/widgets/app_empty_view.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFB),
      appBar: AppBar(
        title: Text(localizations.text('payments')),
        backgroundColor: const Color(0xFFF4FBFB),
        surfaceTintColor: Colors.transparent,
      ),
      body: AppEmptyView(
        title: localizations.text('emptyPaymentsTitle'),
        message: localizations.text('emptyPaymentsMessage'),
        icon: Icons.account_balance_wallet_outlined,
      ),
    );
  }
}
