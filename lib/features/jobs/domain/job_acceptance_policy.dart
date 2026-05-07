import '../../master_profile/domain/master_access.dart';
import 'job_request.dart';

class JobAcceptDecision {
  const JobAcceptDecision._({required this.allowed, required this.message});

  const JobAcceptDecision.allowed()
    : this._(allowed: true, message: 'Job can be accepted.');

  const JobAcceptDecision.denied(String message)
    : this._(allowed: false, message: message);

  final bool allowed;
  final String message;
}

class JobAcceptancePolicy {
  const JobAcceptancePolicy();

  JobAcceptDecision canAccept({
    required MasterAccess access,
    required JobRequest job,
  }) {
    if (!access.isActive) {
      return const JobAcceptDecision.denied(
        'Master access is inactive. New jobs cannot be accepted.',
      );
    }

    if (!job.canBeAcceptedByMaster) {
      return const JobAcceptDecision.denied(
        'Only pending jobs can be accepted by a master.',
      );
    }

    return const JobAcceptDecision.allowed();
  }
}
