import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('paymentHistory'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final amount = (180 + index * 40).toString();
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
              title: Text('+$amount TMT'),
              subtitle: Text('Order #10${index + 1}'),
              trailing: Text(
                index.isEven ? l10n.text('completed') : l10n.text('inProgress'),
              ),
            ),
          );
        },
      ),
    );
  }
}
