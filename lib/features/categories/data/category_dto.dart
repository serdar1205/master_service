import '../domain/service_category.dart';

class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.name,
    this.parentId,
    this.iconType,
    this.icon,
    this.iconUrl,
    this.isActive = true,
    this.children = const [],
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>? ?? const [];

    return CategoryDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      parentId: json['parent_id'] as int?,
      iconType: json['icon_type'] as String?,
      icon: json['icon'] as String?,
      iconUrl: json['icon_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      children: childrenJson
          .map((item) => CategoryDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String name;
  final int? parentId;
  final String? iconType;
  final String? icon;
  final String? iconUrl;
  final bool isActive;
  final List<CategoryDto> children;

  ServiceCategory toDomain() {
    return ServiceCategory(
      id: id,
      name: name,
      parentId: parentId,
      iconType: iconType,
      icon: icon,
      iconUrl: iconUrl,
      isActive: isActive,
      children: children.map((child) => child.toDomain()).toList(),
    );
  }
}

List<ServiceCategory> parseCategoryTree(List<dynamic> jsonList) {
  return jsonList
      .map((item) => CategoryDto.fromJson(item as Map<String, dynamic>))
      .map((dto) => dto.toDomain())
      .toList();
}

List<ServiceCategory> parseCategoryList(List<dynamic> jsonList) {
  return jsonList
      .map((item) => CategoryDto.fromJson(item as Map<String, dynamic>))
      .map((dto) => dto.toDomain())
      .toList();
}
