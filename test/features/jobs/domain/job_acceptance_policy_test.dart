import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/categories/domain/service_category.dart';
import 'package:master_service/features/jobs/domain/job_acceptance_policy.dart';
import 'package:master_service/features/jobs/domain/job_request.dart';
import 'package:master_service/features/master_profile/domain/city.dart';
import 'package:master_service/features/master_profile/domain/master_access.dart';

void main() {
  group('JobAcceptancePolicy', () {
    const city = City(id: 'ashgabat', nameTk: 'Aşgabat', nameRu: 'Ашхабад');
    const category = ServiceCategory(id: 1, name: 'Elektrik', isActive: true);
    final now = DateTime(2026, 5, 7, 10);

    JobRequest jobWithStatus(JobStatus status) {
      return JobRequest(
        id: 'job-1',
        city: city,
        category: category,
        clientPhoneNumber: '+99300000000',
        description: 'Socket repair',
        problemPhotoUrls: const [],
        status: status,
      );
    }

    test('allows pending job when master access is active', () {
      final decision = const JobAcceptancePolicy().canAccept(
        access: MasterAccess(
          expiresAt: now.add(const Duration(days: 1)),
          checkedAt: now,
        ),
        job: jobWithStatus(JobStatus.pending),
      );

      expect(decision.allowed, isTrue);
    });

    test('denies accepting jobs when access is expired', () {
      final decision = const JobAcceptancePolicy().canAccept(
        access: MasterAccess(
          expiresAt: now.subtract(const Duration(minutes: 1)),
          checkedAt: now,
        ),
        job: jobWithStatus(JobStatus.pending),
      );

      expect(decision.allowed, isFalse);
      expect(decision.message, contains('inactive'));
    });

    test('denies non-pending jobs', () {
      final decision = const JobAcceptancePolicy().canAccept(
        access: MasterAccess(
          expiresAt: now.add(const Duration(days: 1)),
          checkedAt: now,
        ),
        job: jobWithStatus(JobStatus.completed),
      );

      expect(decision.allowed, isFalse);
      expect(decision.message, contains('pending'));
    });
  });
}
