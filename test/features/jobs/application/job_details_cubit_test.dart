import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/jobs/application/job_details_cubit.dart';
import 'package:master_service/features/jobs/data/photo_slot_mapper.dart';
import 'package:master_service/features/jobs/domain/order_models.dart';
import 'package:master_service/features/jobs/domain/orders_repository.dart';

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository(this._details);

  final JobDetailsData _details;
  final uploadedPaths = <({String type, String path})>[];

  @override
  Future<JobsDashboardData> fetchDashboard() => throw UnimplementedError();

  @override
  Future<List<JobListItem>> fetchAllOrders() => throw UnimplementedError();

  @override
  Future<List<JobListItem>> fetchHistory() => throw UnimplementedError();

  @override
  Future<List<JobListItem>> fetchOrders({required String filter}) =>
      throw UnimplementedError();

  @override
  Future<JobDetailsData> fetchOrder(String orderId) async => _details;

  @override
  Future<JobDetailsData> startOrder(String orderId) =>
      throw UnimplementedError();

  @override
  Future<OrderTaskData> createTask({
    required String orderId,
    required String title,
    required String description,
  }) => throw UnimplementedError();

  @override
  Future<OrderTaskData> uploadTaskPhoto({
    required String orderId,
    required String taskId,
    required String type,
    required String filePath,
  }) async {
    uploadedPaths.add((type: type, path: filePath));
    return OrderTaskData(
      id: taskId,
      title: 'task',
      description: 'task',
      beforePhotos: type == 'before'
          ? [
              OrderTaskPhoto(
                id: '1',
                url: 'https://example.com/$filePath',
                status: 'pending',
              ),
            ]
          : const [],
      afterPhotos: type == 'after'
          ? [
              OrderTaskPhoto(
                id: '2',
                url: 'https://example.com/$filePath',
                status: 'pending',
              ),
            ]
          : const [],
    );
  }

  @override
  Future<JobDetailsData> completeOrder({
    required String orderId,
    num? finalPrice,
  }) => throw UnimplementedError();
}

JobDetailsData _details() {
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
    tasks: const [OrderTaskData(id: '91', title: 'task', description: 'task')],
  );
}

void main() {
  test('uploadTaskPhoto updates task with server photo', () async {
    final repository = _FakeOrdersRepository(_details());
    final cubit = JobDetailsCubit(repository);
    await cubit.load('116');

    final uploaded = await cubit.uploadTaskPhoto(
      taskId: '91',
      type: 'before',
      filePath: '/tmp/one.jpg',
    );

    expect(uploaded, isTrue);
    expect(repository.uploadedPaths.single.path, '/tmp/one.jpg');
    expect(
      cubit.taskPhotoSource(cubit.state.data!.tasks.first, 'before'),
      'https://example.com//tmp/one.jpg',
    );
    expect(cubit.isTaskPhotoUploading('91', 'before'), isFalse);
  });

  test('setPendingBeforePhotos fills available slots', () async {
    final repository = _FakeOrdersRepository(_details());
    final cubit = JobDetailsCubit(repository);
    await cubit.load('116');

    cubit.setPendingBeforePhotos(['/tmp/one.jpg', '/tmp/two.jpg']);

    expect(cubit.beforePhotoAt(0), '/tmp/one.jpg');
    expect(cubit.beforePhotoAt(1), '/tmp/two.jpg');
    expect(cubit.state.hasPendingBeforePhotos, isTrue);
  });

  test('submitBeforePhotos uploads all pending images', () async {
    final repository = _FakeOrdersRepository(_details());
    final cubit = JobDetailsCubit(repository);
    await cubit.load('116');

    cubit.setPendingBeforePhotos(['/tmp/one.jpg', '/tmp/two.jpg']);
    final uploaded = await cubit.submitBeforePhotos();

    expect(uploaded, isTrue);
    expect(repository.uploadedPaths.map((item) => item.path), [
      '/tmp/one.jpg',
      '/tmp/two.jpg',
    ]);
    expect(cubit.state.hasPendingBeforePhotos, isFalse);
  });

  test('setPendingAfterPhotos fills available slots', () async {
    final repository = _FakeOrdersRepository(_details());
    final cubit = JobDetailsCubit(repository);
    await cubit.load('116');

    cubit.setPendingAfterPhotos(['/tmp/after-one.jpg', '/tmp/after-two.jpg']);

    expect(cubit.afterPhotoAt(0), '/tmp/after-one.jpg');
    expect(cubit.afterPhotoAt(1), '/tmp/after-two.jpg');
    expect(cubit.state.hasPendingAfterPhotos, isTrue);
  });

  test('submitAfterPhotos uploads all pending images', () async {
    final repository = _FakeOrdersRepository(_details());
    final cubit = JobDetailsCubit(repository);
    await cubit.load('116');

    cubit.setPendingAfterPhotos(['/tmp/after-one.jpg', '/tmp/after-two.jpg']);
    final uploaded = await cubit.submitAfterPhotos();

    expect(uploaded, isTrue);
    expect(
      repository.uploadedPaths.every((item) => item.type == 'after'),
      isTrue,
    );
    expect(cubit.state.hasPendingAfterPhotos, isFalse);
  });

  test('availableBeforePhotoSlots skips server-filled slots', () async {
    final repository = _FakeOrdersRepository(
      PhotoSlotMapper.arrangeFromApi(
        _details().copyWith(
          tasks: [
            const OrderTaskData(
              id: '91',
              title: 'task',
              description: 'task',
              beforePhotos: [
                OrderTaskPhoto(
                  id: '1',
                  url: 'https://example.com/one.webp',
                  status: 'done',
                ),
              ],
            ),
          ],
        ),
      ),
    );
    final cubit = JobDetailsCubit(repository);
    await cubit.load('116');

    expect(cubit.availableBeforePhotoSlots(), 1);
  });
}
