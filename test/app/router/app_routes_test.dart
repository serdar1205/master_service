import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/app/router/app_routes.dart';

void main() {
  test('jobDetails path helper generates parameterized path', () {
    expect(AppRoutes.jobDetails, '/jobs/:jobId');
    expect(AppRoutes.jobDetailsPath('job-99'), '/jobs/job-99');
  });
}
