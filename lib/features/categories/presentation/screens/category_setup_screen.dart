import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../auth/application/auth_cubit.dart';

class CategorySetupScreen extends StatelessWidget {
  const CategorySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.text('categorySetupTitle'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.text('categorySetupSubtitle'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(label: Text('Elektrik'), selected: true),
                  ChoiceChip(label: Text('Santehnika'), selected: true),
                  ChoiceChip(label: Text('Tehnika abatlaýyş'), selected: false),
                ],
              ),
              const Spacer(),
              PrimaryActionButton(
                label: localizations.text('completeCategories'),
                onPressed: context.read<AuthCubit>().completeCategories,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
