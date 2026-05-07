enum RealtimeEventType { newJob, jobAssigned, jobStatusChanged }

class RealtimeEvent {
  const RealtimeEvent({required this.type, required this.payload});

  final RealtimeEventType type;
  final Map<String, Object?> payload;
}
