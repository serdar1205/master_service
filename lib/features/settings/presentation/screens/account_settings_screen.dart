import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/localization/locale_cubit.dart';
import '../../../../app/router/app_routes.dart';

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
          BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, state) {
              return ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.text('language')),
                subtitle: Text(
                  l10n.languageLabelFor(state.locale.languageCode),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.languageSettings),
              );
            },
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
