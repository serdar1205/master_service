import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../auth/application/auth_cubit.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.text('profileSetupTitle'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.text('profileSetupSubtitle'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              PrimaryActionButton(
                label: localizations.text('completeProfile'),
                onPressed: context.read<AuthCubit>().completeProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
