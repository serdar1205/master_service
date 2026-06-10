import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/jobs/data/order_mapper.dart';

void main() {
  test('fromListJson maps assigned order to start action', () {
    final item = OrderMapper.fromListJson({
      'id': 42,
      'status': 'assigned',
      'client_name': 'Merdan',
      'address': 'Ashgabat',
      'category': 'Сантехника',
      'description': 'Сломался кран',
      'created_at': '2026-05-16T10:00:00+05:00',
    });

    expect(item.id, '42');
    expect(item.statusKey, 'assigned');
    expect(item.actionKey, 'startJob');
  });

  test('fromListJson maps in_progress order to complete action', () {
    final item = OrderMapper.fromListJson({
      'id': 7,
      'status': 'in_progress',
      'description': 'Fix pipe',
      'category': 'Plumbing',
      'address': 'Ashgabat',
      'created_at': '2026-05-16T10:00:00+05:00',
    });

    expect(item.statusKey, 'inProgress');
    expect(item.actionKey, 'complete');
    expect(item.isOutlinedAction, isTrue);
  });
}
