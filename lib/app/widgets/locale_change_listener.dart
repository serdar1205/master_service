import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/locale_cubit.dart';

class LocaleChangeListener extends StatelessWidget {
  const LocaleChangeListener({
    required this.onLocaleChanged,
    required this.child,
    super.key,
  });

  final VoidCallback onLocaleChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocaleCubit, LocaleState>(
      listenWhen: (previous, current) => previous.locale != current.locale,
      listener: (context, state) => onLocaleChanged(),
      child: child,
    );
  }
}
