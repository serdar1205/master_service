import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/core/utils/app_status.dart';
import 'package:master_service/features/jobs/application/jobs_cubit.dart';
import 'package:master_service/features/jobs/data/local_jobs_repository.dart';

void main() {
  test('jobs cubit loads dashboard from local repository', () async {
    final cubit = JobsCubit(const LocalJobsRepository());

    await cubit.load();

    expect(cubit.state.status, AppStatus.success);
    expect(cubit.state.data?.activeJobs.length, 3);
    expect(cubit.state.data?.historyJobs.length, 1);
  });
}
