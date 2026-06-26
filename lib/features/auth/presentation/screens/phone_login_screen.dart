import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/app_brand_header.dart';
import '../../../../core/widgets/turkmen_phone_field.dart';
import '../../application/auth_cubit.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    const brandColor = AppColors.brand;

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFA),
      body: SafeArea(
        child: Column(
          children: [
            AppBrandHeader(
              title: localizations.text('appTitle'),
              brandColor: brandColor,
              horizontalPadding: 28,
            ),
            Expanded(
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                    children: [
                      _LoginCard(
                        localizations: localizations,
                        state: state,
                        phoneController: _phoneController,
                        brandColor: brandColor,
                        termsAccepted: _termsAccepted,
                        onTermsChanged: (accepted) {
                          setState(() => _termsAccepted = accepted);
                        },
                        onSubmit: () => _submit(context),
                      ),
                      const SizedBox(height: 20),
                      _TrustBadges(
                        localizations: localizations,
                        brandColor: brandColor,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_termsAccepted) {
      return;
    }

    context.read<AuthCubit>().requestOtp(_phoneController.text);
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.localizations,
    required this.state,
    required this.phoneController,
    required this.brandColor,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.onSubmit,
  });

  final AppLocalizations localizations;
  final AuthState state;
  final TextEditingController phoneController;
  final Color brandColor;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onSubmit;

  bool get _canContinue => termsAccepted && !state.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: const BorderSide(color: Color(0xFFE7EEF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.text('phoneLoginTitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF171717),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.text('phoneLoginSubtitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF424C52),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 34),
            Text(
              localizations.text('phoneNumber'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B777C),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            TurkmenPhoneField(
              controller: phoneController,
              focusedBorderColor: brandColor,
              onSubmitted: (_) {
                if (_canContinue) {
                  onSubmit();
                }
              },
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 18),
            _TermsAcceptanceRow(
              localizations: localizations,
              brandColor: brandColor,
              termsAccepted: termsAccepted,
              onTermsChanged: onTermsChanged,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _canContinue ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonTeal,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppColors.buttonTeal.withValues(alpha: 0.18),
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isLoading) ...[
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(localizations.text('continueAction')),
                  const SizedBox(width: 9),
                  const Icon(Icons.arrow_forward, size: 21),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Divider(color: Color(0xFFE1E7E9), height: 1),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _RoundInfoIcon(icon: Icons.shield_outlined),
                SizedBox(width: 20),
                _RoundInfoIcon(icon: Icons.help_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsAcceptanceRow extends StatelessWidget {
  const _TermsAcceptanceRow({
    required this.localizations,
    required this.brandColor,
    required this.termsAccepted,
    required this.onTermsChanged,
  });

  final AppLocalizations localizations;
  final Color brandColor;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: termsAccepted,
            onChanged: (value) => onTermsChanged(value ?? false),
            activeColor: brandColor,
            side: const BorderSide(color: Color(0xFFB8C4C8), width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onTermsChanged(!termsAccepted),
            child: Text.rich(
              TextSpan(
                text: '${localizations.text('termsNotice')} ',
                children: [
                  TextSpan(
                    text: localizations.text('termsLink'),
                    style: TextStyle(
                      color: brandColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' ${localizations.text('termsAccept')}'),
                ],
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B777C),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundInfoIcon extends StatelessWidget {
  const _RoundInfoIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F5F6),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Color(0xFF2F79A7), size: 26),
      ),
    );
  }
}

class _TrustBadges extends StatelessWidget {
  const _TrustBadges({required this.localizations, required this.brandColor});

  final AppLocalizations localizations;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TrustBadge(
            icon: Icons.verified_outlined,
            text: localizations.text('verifiedMasters'),
            iconColor: brandColor,
            iconBackgroundColor: const Color(0xFFE5FCF8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TrustBadge(
            icon: Icons.speed_outlined,
            text: localizations.text('fastService'),
            iconColor: const Color(0xFF2F79A7),
            iconBackgroundColor: const Color(0xFFEFF5FF),
          ),
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9F0F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lines.first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF7D898E),
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.4,
                    height: 1.1,
                  ),
                ),
                if (lines.length > 1) ...[
                  const SizedBox(height: 1),
                  Text(
                    lines[1],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF172025),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
