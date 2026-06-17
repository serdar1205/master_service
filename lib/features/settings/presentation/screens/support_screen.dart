import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/phone_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('support'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.text('faq')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: Text(l10n.text('chatWithSupport')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.call_outlined),
            title: Text(l10n.text('callSupport')),
            subtitle: Text(AppConfig.supportPhone),
            onTap: () => PhoneLauncher.call(
              context,
              AppConfig.supportPhone,
              unavailableMessage: l10n.text('phoneUnavailable'),
              failedMessage: l10n.text('callFailed'),
            ),
          ),
        ],
      ),
    );
  }
}
