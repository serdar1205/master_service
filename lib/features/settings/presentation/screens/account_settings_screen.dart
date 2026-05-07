import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('accountSettingsTitle'))),
      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: Text(l10n.text('pushNotifications')),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.text('language')),
            subtitle: const Text('RU / TM'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.text('privacySecurity')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
