import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';

class JobHistoryScreen extends StatelessWidget {
  const JobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.text('history'))),
      body: Center(child: Text(localizations.text('placeholder'))),
    );
  }
}
