class WorkProof {
  const WorkProof({
    required this.jobId,
    required this.workTitle,
    required this.beforePhotoUrls,
    required this.afterPhotoUrls,
  });

  final String jobId;
  final String workTitle;
  final List<String> beforePhotoUrls;
  final List<String> afterPhotoUrls;

  bool get isComplete {
    return workTitle.trim().isNotEmpty &&
        beforePhotoUrls.isNotEmpty &&
        afterPhotoUrls.isNotEmpty;
  }
}
