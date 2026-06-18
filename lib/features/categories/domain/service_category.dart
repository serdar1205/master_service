class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.iconType,
    this.icon,
    this.iconUrl,
    this.isActive = true,
    this.children = const [],
  });

  final int id;
  final String name;
  final int? parentId;
  final String? iconType;
  final String? icon;
  final String? iconUrl;
  final bool isActive;
  final List<ServiceCategory> children;

  bool get hasChildren => children.isNotEmpty;

  /// Returns leaf categories when this node is a parent, otherwise itself.
  List<ServiceCategory> flattenSelectable() {
    if (!hasChildren) {
      return [this];
    }

    return children.expand((child) => child.flattenSelectable()).toList();
  }
}
