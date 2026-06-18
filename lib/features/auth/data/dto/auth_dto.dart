import '../../../categories/data/category_dto.dart';
import '../../../categories/domain/service_category.dart';

class VerifyOtpResponseDto {
  const VerifyOtpResponseDto({required this.token, required this.master});

  factory VerifyOtpResponseDto.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseDto(
      token: json['token'] as String,
      master: MasterDto.fromJson(json['master'] as Map<String, dynamic>),
    );
  }

  final String token;
  final MasterDto master;
}

class MasterDto {
  const MasterDto({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.isActive,
    required this.isAvailable,
    required this.accessExpiresAt,
    required this.categories,
    this.city,
    this.paymentModel,
    this.paymentValue,
  });

  factory MasterDto.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List<dynamic>? ?? const [];
    return MasterDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      balance: (json['balance'] as num?) ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isAvailable: json['is_available'] as bool? ?? true,
      accessExpiresAt: json['access_expires_at'] as String?,
      categories: parseCategoryList(categoriesJson),
      city: json['city'] == null
          ? null
          : CityDto.fromJson(json['city'] as Map<String, dynamic>),
      paymentModel: json['payment_model'] as String?,
      paymentValue: json['payment_value'] as num?,
    );
  }

  final int id;
  final String name;
  final String phone;
  final num balance;
  final bool isActive;
  final bool isAvailable;
  final String? accessExpiresAt;
  final List<ServiceCategory> categories;
  final CityDto? city;
  final String? paymentModel;
  final num? paymentValue;
}

class CityDto {
  const CityDto({required this.id, required this.name});

  factory CityDto.fromJson(Map<String, dynamic> json) {
    return CityDto(id: json['id'] as int, name: json['name'] as String? ?? '');
  }

  final int id;
  final String name;
}
