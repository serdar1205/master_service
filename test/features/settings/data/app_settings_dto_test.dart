import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/settings/data/dto/app_settings_dto.dart';

void main() {
  test('AppSettingsDto parses content from API payload', () {
    final dto = AppSettingsDto.fromJson({
      'content': '<h1>Правила</h1><p>Текст...</p>',
    });

    expect(dto.content, '<h1>Правила</h1><p>Текст...</p>');
  });

  test('AppSettingsDto defaults missing content to empty string', () {
    final dto = AppSettingsDto.fromJson({});

    expect(dto.content, isEmpty);
  });
}
