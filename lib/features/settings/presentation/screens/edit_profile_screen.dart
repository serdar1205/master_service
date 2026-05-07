import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('editProfile'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: l10n.text('fullName'),
              hintText: 'Myrat Annageldiyev',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.text('phoneNumber'),
              hintText: '+993 65 12 34 56',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.text('city'),
              hintText: l10n.text('profileLocation'),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.text('saveChanges')),
          ),
        ],
      ),
    );
  }
}
