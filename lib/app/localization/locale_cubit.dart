import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_locale_holder.dart';
import '../../core/storage/app_locale_storage.dart';
import '../../core/utils/app_status.dart';
import 'locale_state.dart';

export 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit({
    required LocaleStorage storage,
    required ApiLocaleHolder apiLocaleHolder,
    Locale? initialLocale,
  }) : _storage = storage,
       _apiLocaleHolder = apiLocaleHolder,
       super(LocaleState.initial(locale: initialLocale ?? _defaultLocale()));

  final LocaleStorage _storage;
  final ApiLocaleHolder _apiLocaleHolder;

  static Locale _defaultLocale() {
    return const Locale(AppConstants.defaultLocaleCode);
  }

  static Locale resolveInitialLocale({
    String? savedLocaleCode,
    String? deviceLocaleCode,
  }) {
    if (savedLocaleCode != null && savedLocaleCode.isNotEmpty) {
      return Locale(normalizeLocaleCode(savedLocaleCode));
    }

    return Locale(normalizeLocaleCode(deviceLocaleCode));
  }

  static String normalizeLocaleCode(String? code) {
    return code == AppConstants.fallbackLocaleCode
        ? AppConstants.fallbackLocaleCode
        : AppConstants.defaultLocaleCode;
  }

  Future<void> loadSavedLocale({String? deviceLocaleCode}) async {
    emit(state.copyWith(status: AppStatus.loading));

    try {
      final savedCode = await _storage.readLocaleCode();
      final locale = resolveInitialLocale(
        savedLocaleCode: savedCode,
        deviceLocaleCode: deviceLocaleCode,
      );

      _syncApiLocale(locale);
      emit(LocaleState(locale: locale, status: AppStatus.success));
    } on Object {
      final locale = resolveInitialLocale(deviceLocaleCode: deviceLocaleCode);
      _syncApiLocale(locale);
      emit(LocaleState(locale: locale, status: AppStatus.success));
    }
  }

  Future<void> setLocale(String languageCode) async {
    final normalized = normalizeLocaleCode(languageCode);
    if (state.locale.languageCode == normalized) {
      return;
    }

    final locale = Locale(normalized);
    _syncApiLocale(locale);

    try {
      await _storage.writeLocaleCode(normalized);
    } on Object {
      // Keep in-memory locale even if persistence fails.
    }

    emit(LocaleState(locale: locale, status: AppStatus.success));
  }

  Future<void> toggleLocale() async {
    final nextCode =
        state.locale.languageCode == AppConstants.fallbackLocaleCode
        ? AppConstants.defaultLocaleCode
        : AppConstants.fallbackLocaleCode;
    await setLocale(nextCode);
  }

  void _syncApiLocale(Locale locale) {
    _apiLocaleHolder.setLocaleCode(locale.languageCode);
  }
}
