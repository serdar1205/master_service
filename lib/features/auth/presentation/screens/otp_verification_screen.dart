import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../application/auth_cubit.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<AuthCubit>().backToLogin(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state.isLoading;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations.text('otpTitle'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.phoneNumber == null
                        ? localizations.text('otpSubtitle')
                        : '${localizations.text('otpSubtitle')}\n'
                              '${PhoneFormatter.toDisplayE164(state.phoneNumber!)}',
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: localizations.text('otpCode'),
                    ),
                    onSubmitted: (_) => _submit(context),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    label: localizations.text('verify'),
                    onPressed: () => _submit(context),
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<AuthCubit>().resendOtp(),
                    child: Text(
                      localizations.text('resendOtp'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<AuthCubit>().verifyOtp(_otpController.text);
  }
}
