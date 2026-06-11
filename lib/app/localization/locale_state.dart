import 'package:flutter/widgets.dart';

import '../../core/utils/app_status.dart';

class LocaleState {
  const LocaleState({required this.locale, this.status = AppStatus.success});

  const LocaleState.initial({required Locale locale})
    : this(locale: locale, status: AppStatus.idle);

  final Locale locale;
  final AppStatus status;

  LocaleState copyWith({Locale? locale, AppStatus? status}) {
    return LocaleState(
      locale: locale ?? this.locale,
      status: status ?? this.status,
    );
  }
}
