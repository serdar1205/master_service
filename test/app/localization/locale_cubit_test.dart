import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/app/localization/locale_cubit.dart';
import 'package:master_service/core/constants/app_constants.dart';
import 'package:master_service/core/network/api_locale_holder.dart';
import 'package:master_service/core/storage/app_locale_storage.dart';

class _FakeLocaleStorage implements LocaleStorage {
  String? savedCode;

  @override
  Future<String?> readLocaleCode() async => savedCode;

  @override
  Future<void> writeLocaleCode(String code) async {
    savedCode = code;
  }
}

void main() {
  test('resolveInitialLocale prefers saved locale', () {
    final locale = LocaleCubit.resolveInitialLocale(
      savedLocaleCode: 'ru',
      deviceLocaleCode: 'tk',
    );

    expect(locale.languageCode, 'ru');
  });

  test('resolveInitialLocale falls back to device locale', () {
    final locale = LocaleCubit.resolveInitialLocale(deviceLocaleCode: 'ru');

    expect(locale.languageCode, 'ru');
  });

  test('normalizeLocaleCode maps unknown codes to tk', () {
    expect(
      LocaleCubit.normalizeLocaleCode('en'),
      AppConstants.defaultLocaleCode,
    );
  });

  test('setLocale persists and syncs ApiLocaleHolder', () async {
    final storage = _FakeLocaleStorage();
    final apiHolder = ApiLocaleHolder(initialLocaleCode: 'tk');
    final cubit = LocaleCubit(
      storage: storage,
      apiLocaleHolder: apiHolder,
      initialLocale: const Locale('tk'),
    );

    await cubit.setLocale('ru');

    expect(cubit.state.locale.languageCode, 'ru');
    expect(storage.savedCode, 'ru');
    expect(apiHolder.localeCode, 'ru');

    await cubit.close();
  });
}
