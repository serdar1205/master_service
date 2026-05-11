import 'package:flutter/material.dart';

/// Single source of truth for all hard-coded UI colors in `lib/`.
///
/// Notes:
/// - Values are extracted from existing `Color(0x...)` literals in the project.
/// - There are a few semantic aliases at the top for common colors.
class AppColors {
  const AppColors._();

  // Single primary color used for main accents (buttons, icons, highlights).
  static const primary = kFF3B82F6;

  // Semantic aliases kept for compatibility; all point to one primary source.
  static const brand = primary;
  static const brandLight = primary;
  static const buttonTeal = primary;
  static const buttonTealSoft = primary;
  static const seedTeal = primary;

  // --- Extracted palette (all unique Color(0x...) literals) ---

  static const k08000000 = Color(0x08000000);
  static const k0A000000 = Color(0x0A000000);
  static const k0D000000 = Color(0x0D000000);
  static const k0F000000 = Color(0x0F000000);
  static const k12000000 = Color(0x12000000);
  static const k14000000 = Color(0x14000000);
  static const k18000000 = Color(0x18000000);
  static const k1A000000 = Color(0x1A000000);
  static const k24000000 = Color(0x24000000);

  static const kFF083237 = Color(0xFF083237);
  static const kFF087D83 = Color(0xFF087D83);
  static const kFF0B1117 = Color(0xFF0B1117);
  static const kFF101719 = Color(0xFF101719);
  static const kFF11191C = Color(0xFF11191C);
  static const kFF171717 = Color(0xFF171717);
  static const kFF172025 = Color(0xFF172025);
  static const kFF1B2327 = Color(0xFF1B2327);
  static const kFF1C3153 = Color(0xFF1C3153);
  static const kFF1F2933 = Color(0xFF1F2933);
  static const kFF1F4B93 = Color(0xFF1F4B93);
  static const kFF242B2F = Color(0xFF242B2F);
  static const kFF293237 = Color(0xFF293237);
  static const kFF2C3E46 = Color(0xFF2C3E46);
  static const kFF2E3B40 = Color(0xFF2E3B40);
  static const kFF2F79A7 = Color(0xFF2F79A7);
  static const kFF30393D = Color(0xFF30393D);
  static const kFF3B629B = Color(0xFF3B629B);
  static const kFF3B70D8 = Color(0xFF3B70D8);
  static const kFF3B82F6 = Color(0xFF3B82F6);
  static const kFF424C52 = Color(0xFF424C52);
  static const kFF426A63 = Color(0xFF426A63);
  static const kFF4290A3 = Color(0xFF4290A3);
  static const kFF4777A6 = Color(0xFF4777A6);
  static const kFF4B5960 = Color(0xFF4B5960);
  static const kFF4E5B61 = Color(0xFF4E5B61);
  static const kFF4F79A3 = Color(0xFF4F79A3);
  static const kFF526168 = Color(0xFF526168);
  static const kFF527075 = Color(0xFF527075);
  static const kFF536065 = Color(0xFF536065);
  static const kFF536167 = Color(0xFF536167);
  static const kFF5CC2C8 = Color(0xFF5CC2C8);
  static const kFF5D686E = Color(0xFF5D686E);
  static const kFF63C6CB = Color(0xFF63C6CB);
  static const kFF63D5DA = Color(0xFF63D5DA);
  static const kFF66767D = Color(0xFF66767D);
  static const kFF69767A = Color(0xFF69767A);
  static const kFF6B777C = Color(0xFF6B777C);
  static const kFF6D7A82 = Color(0xFF6D7A82);
  static const kFF76C3C6 = Color(0xFF76C3C6);
  static const kFF7A868C = Color(0xFF7A868C);
  static const kFF7D898E = Color(0xFF7D898E);
  static const kFF849198 = Color(0xFF849198);
  static const kFF8D989D = Color(0xFF8D989D);
  static const kFF8EBBFF = Color(0xFF8EBBFF);
  static const kFF8FBEC1 = Color(0xFF8FBEC1);
  static const kFF94A69A = Color(0xFF94A69A);
  static const kFF9AA7AD = Color(0xFF9AA7AD);
  static const kFF9DB2B6 = Color(0xFF9DB2B6);
  static const kFF9DBAEA = Color(0xFF9DBAEA);
  static const kFF9FB8B9 = Color(0xFF9FB8B9);
  static const kFFaFC8C3 = Color(0xFFAFC8C3);
  static const kFFB3262E = Color(0xFFB3262E);
  static const kFFB5D9DA = Color(0xFFB5D9DA);
  static const kFFBCC9CD = Color(0xFFBCC9CD);
  static const kFFBFE7E8 = Color(0xFFBFE7E8);
  static const kFFC5D6D9 = Color(0xFFC5D6D9);
  static const kFFCFE3FF = Color(0xFFCFE3FF);
  static const kFFD0D8DC = Color(0xFFD0D8DC);
  static const kFFD7E0E3 = Color(0xFFD7E0E3);
  static const kFFD9E8FF = Color(0xFFD9E8FF);
  static const kFFDCE5E7 = Color(0xFFDCE5E7);
  static const kFFE0E4E8 = Color(0xFFE0E4E8);
  static const kFFE1E7E9 = Color(0xFFE1E7E9);
  static const kFFE2E8EA = Color(0xFFE2E8EA);
  static const kFFE3F3F3 = Color(0xFFE3F3F3);
  static const kFFE5FCF8 = Color(0xFFE5FCF8);
  static const kFFE6FAF8 = Color(0xFFE6FAF8);
  static const kFFE6FBF8 = Color(0xFFE6FBF8);
  static const kFFE7EEF0 = Color(0xFFE7EEF0);
  static const kFFE7FBF5 = Color(0xFFE7FBF5);
  static const kFFE9F0F2 = Color(0xFFE9F0F2);
  static const kFFEAF3FF = Color(0xFFEAF3FF);
  static const kFFEAFBFF = Color(0xFFEAFBFF);
  static const kFFEEF6F7 = Color(0xFFEEF6F7);
  static const kFFEFF5FF = Color(0xFFEFF5FF);
  static const kFFF0D9DC = Color(0xFFF0D9DC);
  static const kFFF0F3F4 = Color(0xFFF0F3F4);
  static const kFFF0F5F6 = Color(0xFFF0F5F6);
  static const kFFF1F3F4 = Color(0xFFF1F3F4);
  static const kFFF3FAFA = Color(0xFFF3FAFA);
  static const kFFF4F6F7 = Color(0xFFF4F6F7);
  static const kFFF4F8F9 = Color(0xFFF4F8F9);
  static const kFFF4FBFB = Color(0xFFF4FBFB);
  static const kFFF8FAFC = Color(0xFFF8FAFC);
}
