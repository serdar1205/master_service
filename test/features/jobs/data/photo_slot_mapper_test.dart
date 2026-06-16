import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/jobs/data/photo_slot_mapper.dart';
import 'package:master_service/features/jobs/domain/order_models.dart';

JobDetailsData _detailsWithTask({
  List<OrderTaskPhoto> beforePhotos = const [],
  List<OrderTaskPhoto> afterPhotos = const [],
}) {
  return JobDetailsData(
    id: '116',
    statusKey: 'inProgress',
    clientName: 'user',
    clientPhone: '+99361121212',
    address: 'address',
    category: 'category',
    description: 'description',
    beforePhotos: const [null, null],
    afterPhotos: const [null, null],
    tasks: [
      OrderTaskData(
        id: '91',
        title: 'task',
        description: 'task',
        beforePhotos: beforePhotos,
        afterPhotos: afterPhotos,
      ),
    ],
  );
}

void main() {
  test('arrangeFromApi maps before_photos array to UI slots', () {
    final arranged = PhotoSlotMapper.arrangeFromApi(
      _detailsWithTask(
        beforePhotos: const [
          OrderTaskPhoto(
            id: '1',
            url: 'http://example.com/before-1.webp',
            status: 'pending',
          ),
          OrderTaskPhoto(
            id: '2',
            url: 'http://example.com/before-2.webp',
            status: 'done',
          ),
        ],
      ),
    );

    expect(arranged.beforePhotos[0], 'http://example.com/before-1.webp');
    expect(arranged.beforePhotos[1], 'http://example.com/before-2.webp');
  });

  test('applyPhotoAtSlot updates only requested slot', () {
    final updated = PhotoSlotMapper.applyPhotoAtSlot(
      _detailsWithTask(
        beforePhotos: const [
          OrderTaskPhoto(
            id: '1',
            url: 'http://example.com/before-1.webp',
            status: 'done',
          ),
        ],
      ),
      type: 'after',
      slotIndex: 1,
      photoUrl: '/tmp/after.jpg',
    );

    expect(updated.beforePhotos[0], isNull);
    expect(updated.afterPhotos[0], isNull);
    expect(updated.afterPhotos[1], '/tmp/after.jpg');
  });
}
