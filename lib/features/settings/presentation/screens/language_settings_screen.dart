import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/localization/locale_cubit.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  static const _brandColor = AppColors.brand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF242B2F),
        elevation: 0,
        title: Text(l10n.text('languageSettingsTitle')),
      ),
      body: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              Text(
                l10n.text('languageSettingsSubtitle'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF6D7A82),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 14,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _LanguageOptionTile(
                      title: l10n.text('languageTurkmen'),
                      subtitle: l10n.text('languageTurkmenSubtitle'),
                      languageCode: 'tk',
                      isSelected: state.locale.languageCode == 'tk',
                      onTap: () => _selectLanguage(context, l10n, 'tk'),
                    ),
                    const SizedBox(height: 12),
                    _LanguageOptionTile(
                      title: l10n.text('languageRussian'),
                      subtitle: l10n.text('languageRussianSubtitle'),
                      languageCode: 'ru',
                      isSelected: state.locale.languageCode == 'ru',
                      onTap: () => _selectLanguage(context, l10n, 'ru'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    AppLocalizations l10n,
    String languageCode,
  ) async {
    final localeCubit = context.read<LocaleCubit>();
    if (localeCubit.state.locale.languageCode == languageCode) {
      return;
    }

    await localeCubit.setLocale(languageCode);
    if (!context.mounted) {
      return;
    }

    AppToast.showSuccess(l10n.text('languageChanged'));
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.title,
    required this.subtitle,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFEAF3FF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? LanguageSettingsScreen._brandColor
                  : const Color(0xFFE7EEF0),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              _LanguageFlag(languageCode: languageCode),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF242B2F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6D7A82),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? LanguageSettingsScreen._brandColor
                    : const Color(0xFFD0D8DC),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageFlag extends StatelessWidget {
  const _LanguageFlag({required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final isRussian = languageCode == 'ru';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isRussian ? const Color(0xFFEFF5FF) : const Color(0xFFE5FCF8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          isRussian ? 'RU' : 'TM',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isRussian
                ? const Color(0xFF2F79A7)
                : LanguageSettingsScreen._brandColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
