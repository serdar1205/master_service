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

  test('fromDetailJson maps start order action response', () {
    final details = OrderMapper.fromDetailJson({
      'id': 114,
      'status': 'in_progress',
      'client_name': 'user',
      'client_phone': '+99361121212',
      'address': 'gokee',
      'latitude': 37.9567787,
      'longitude': 58.4264467,
      'description': 'tezele',
      'final_price': null,
      'assigned_at': '2026-06-15T17:20:48+05:00',
      'started_at': '2026-06-15T17:25:08+05:00',
      'completed_at': null,
      'created_at': '2026-06-15T17:15:40+05:00',
    });

    expect(details.id, '114');
    expect(details.statusKey, 'inProgress');
    expect(details.clientName, 'user');
    expect(details.latitude, closeTo(37.9567787, 0.0001));
    expect(details.tasks, isEmpty);
  });

  test('fromDetailJson maps complete order action response', () {
    final details = OrderMapper.fromDetailJson({
      'id': 114,
      'status': 'completed',
      'client_name': 'user',
      'client_phone': '+99361121212',
      'address': 'gokee',
      'latitude': 37.9567787,
      'longitude': 58.4264467,
      'category': 'Plumbing',
      'description': 'tezele',
      'final_price': 150,
      'assigned_at': '2026-06-15T17:20:48+05:00',
      'started_at': '2026-06-15T17:25:08+05:00',
      'completed_at': '2026-06-15T17:25:31+05:00',
      'created_at': '2026-06-15T17:15:40+05:00',
    });

    expect(details.statusKey, 'completed');
    expect(details.finalPrice, 150);
    expect(details.assignedAt, isNotNull);
    expect(details.finalPriceText, '150 TMT');
  });

  test('fromDetailJson maps full order detail payload', () {
    final details = OrderMapper.fromDetailJson({
      'id': 119,
      'status': 'in_progress',
      'client_name': 'Dock Murazik',
      'client_phone': '+993623004004',
      'address': '6346 Beatty Highway Apt. 086',
      'latitude': 37.9998,
      'longitude': 58.3667,
      'category': 'Ремонт стиральной машины',
      'description': 'Omnis porro ab rerum quam voluptatem.',
      'final_price': 250,
      'photos': [],
      'tasks': [
        {
          'id': 91,
          'title': 'Voluptatum quod maiores harum ea.',
          'description': null,
          'before_photos': [
            {
              'id': 1,
              'url': 'https://example.com/before-1.webp',
              'status': 'done',
            },
          ],
          'after_photos': [],
        },
        {
          'id': 92,
          'title': 'Aut quae et.',
          'description': null,
          'before_photos': [],
          'after_photos': [],
        },
      ],
      'assigned_at': '2026-06-16T10:20:23+05:00',
      'started_at': '2026-06-16T11:37:23+05:00',
      'completed_at': null,
      'created_at': '2026-06-16T12:20:23+05:00',
    });

    expect(details.id, '119');
    expect(details.clientName, 'Dock Murazik');
    expect(details.category, 'Ремонт стиральной машины');
    expect(details.finalPrice, 250);
    expect(details.tasks.length, 2);
    expect(details.beforePhotos.first, 'https://example.com/before-1.webp');
    expect(
      OrderMapper.formatDisplayDate(details.startedAt),
      contains('16.06.2026'),
    );
  });

  test('taskFromJson maps create task response', () {
    final task = OrderMapper.taskFromJson({
      'id': 7,
      'title': 'Замена прокладки крана',
      'description': 'Заменил резиновую прокладку, кран перестал капать',
      'before_photos': [],
      'after_photos': [],
    });

    expect(task.id, '7');
    expect(task.title, 'Замена прокладки крана');
    expect(task.beforePhotos, isEmpty);
  });

  test('fromDetailJson maps task before_photos array into slots', () {
    final details = OrderMapper.fromDetailJson({
      'id': 116,
      'status': 'in_progress',
      'client_name': 'user',
      'client_phone': '+99361121212',
      'address': 'rrrrrr',
      'description': 'qwwwwww',
      'photos': [],
      'tasks': [
        {
          'id': 7,
          'title': 'Замена труб',
          'description': 'qwwwwww',
          'before_photos': [
            {
              'id': 1,
              'url': 'https://example.com/before-1.webp',
              'status': 'pending',
            },
            {
              'id': 2,
              'url': 'https://example.com/before-2.webp',
              'status': 'done',
            },
          ],
          'after_photos': [],
        },
      ],
    });

    expect(details.beforePhotos[0], 'https://example.com/before-1.webp');
    expect(details.beforePhotos[1], 'https://example.com/before-2.webp');
    expect(details.afterPhotos[0], isNull);
    expect(details.afterPhotos[1], isNull);
    expect(details.tasks.first.beforePhotos.length, 2);
    expect(details.tasks.first.beforePhotos.first.status, 'pending');
  });

  test('fromDetailJson supports legacy single before_photo field', () {
    final details = OrderMapper.fromDetailJson({
      'id': 116,
      'status': 'in_progress',
      'description': 'qwwwwww',
      'photos': [],
      'tasks': [
        {
          'id': 91,
          'title': 'qwwwwww',
          'description': 'qwwwwww',
          'before_photo': {
            'url': 'http://192.168.31.64:8000/storage/before.webp',
            'status': 'done',
          },
          'after_photo': null,
        },
      ],
    });

    expect(details.beforePhotos.first, contains('/before.webp'));
    expect(details.beforePhotos[1], isNull);
  });
}
