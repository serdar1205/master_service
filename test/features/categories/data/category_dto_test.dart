import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/categories/data/category_dto.dart';
import 'package:master_service/features/categories/domain/service_category.dart';

void main() {
  group('CategoryDto', () {
    test('parses nested category tree from API', () {
      final tree = parseCategoryTree([
        {
          'id': 11,
          'name': 'Бытовая техника',
          'parent_id': null,
          'icon_type': 'preset',
          'icon': 'cpu-chip',
          'icon_url': 'http://192.168.31.64:8000/icons/services/cpu-chip.svg',
          'children': [
            {
              'id': 14,
              'parent_id': 11,
              'name': 'Ремонт кондиционера',
              'is_active': true,
              'created_at': '2026-06-18T06:39:21.000000Z',
              'updated_at': '2026-06-18T06:39:21.000000Z',
              'icon_type': null,
              'icon': null,
              'icon_url': 'http://192.168.31.64:8000/icons/services/bolt.svg',
            },
            {
              'id': 13,
              'parent_id': 11,
              'name': 'Ремонт стиральной машины',
              'is_active': true,
              'icon_url': null,
            },
          ],
        },
      ]);

      expect(tree, hasLength(1));
      expect(tree.first.id, 11);
      expect(tree.first.name, 'Бытовая техника');
      expect(tree.first.icon, 'cpu-chip');
      expect(tree.first.children, hasLength(2));
      expect(tree.first.children.first.id, 14);
      expect(tree.first.children.first.iconUrl, isNotNull);
    });

    test('flattenSelectable returns leaf categories for parents', () {
      const parent = ServiceCategory(
        id: 11,
        name: 'Бытовая техника',
        children: [
          ServiceCategory(id: 12, name: 'Ремонт холодильника'),
          ServiceCategory(id: 13, name: 'Ремонт стиральной машины'),
        ],
      );

      final leaves = parent.flattenSelectable();

      expect(leaves, hasLength(2));
      expect(leaves.map((category) => category.id), [12, 13]);
    });
  });
}
