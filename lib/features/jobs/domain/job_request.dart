import '../../categories/domain/service_category.dart';
import '../../master_profile/domain/city.dart';

enum JobStatus { pending, assigned, inProgress, completed }

class JobRequest {
  const JobRequest({
    required this.id,
    required this.city,
    required this.category,
    required this.clientPhoneNumber,
    required this.description,
    required this.problemPhotoUrls,
    required this.status,
    this.assignedAt,
    this.completedAt,
    this.finalAmount,
  });

  final String id;
  final City city;
  final ServiceCategory category;
  final String clientPhoneNumber;
  final String description;
  final List<String> problemPhotoUrls;
  final JobStatus status;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final num? finalAmount;

  bool get canBeAcceptedByMaster => status == JobStatus.pending;
}
