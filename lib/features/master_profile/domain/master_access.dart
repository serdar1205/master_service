enum MasterAccessInactiveReason { notActivated, expired }

class MasterAccess {
  const MasterAccess({required this.expiresAt, required this.checkedAt});

  final DateTime? expiresAt;
  final DateTime checkedAt;

  bool get isActive {
    final expiresAt = this.expiresAt;
    return expiresAt != null && expiresAt.isAfter(checkedAt);
  }

  MasterAccessInactiveReason? get inactiveReason {
    if (isActive) {
      return null;
    }

    return expiresAt == null
        ? MasterAccessInactiveReason.notActivated
        : MasterAccessInactiveReason.expired;
  }

  int get daysRemaining {
    if (!isActive) {
      return 0;
    }

    final remaining = expiresAt!.difference(checkedAt);
    return (remaining.inHours / Duration.hoursPerDay).ceil();
  }
}
