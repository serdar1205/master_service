import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/app_status.dart';
import 'package:master_service/features/settings/application/app_settings_cubit.dart';
import 'package:master_service/features/settings/domain/app_settings.dart';
import 'package:master_service/features/settings/domain/app_settings_repository.dart';

class _FakeAppSettingsRepository implements AppSettingsRepository {
  _FakeAppSettingsRepository(this._settings, {this.shouldFail = false});

  final AppSettings _settings;
  final bool shouldFail;

  @override
  Future<AppSettings> fetchSettings() async {
    if (shouldFail) {
      throw Exception('network');
    }

    return _settings;
  }
}

void main() {
  test('app settings cubit loads terms content', () async {
    const settings = AppSettings(content: '<h1>Terms</h1><p>Body</p>');
    final cubit = AppSettingsCubit(_FakeAppSettingsRepository(settings));

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.data?.content, settings.content);

    await cubit.close();
  });

  test('app settings cubit emits failure on error', () async {
    const settings = AppSettings(content: '');
    final cubit = AppSettingsCubit(
      _FakeAppSettingsRepository(settings, shouldFail: true),
    );

    await cubit.load();

    expect(cubit.state.status, AppStatus.failure);
    expect(cubit.state.errorMessage, isNotEmpty);

    await cubit.close();
  });
}
