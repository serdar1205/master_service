import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.text('payments'))),
      body: Center(child: Text(localizations.text('placeholder'))),
    );
  }
}
