import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/locale_cubit.dart';
import '../theme/app_colors.dart';

class LocaleBadge extends StatelessWidget {
  const LocaleBadge({this.brandColor = AppColors.brand, super.key});

  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final label = state.locale.languageCode == 'ru' ? 'RU' : 'TM';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: brandColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
