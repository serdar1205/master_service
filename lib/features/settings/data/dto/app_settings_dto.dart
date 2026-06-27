class AppSettingsDto {
  const AppSettingsDto({required this.content});

  final String content;

  factory AppSettingsDto.fromJson(Map<String, dynamic> json) {
    return AppSettingsDto(content: json['content'] as String? ?? '');
  }
}
