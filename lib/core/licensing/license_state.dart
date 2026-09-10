enum LicenseStatus { demo, licensed, expired, clockTampered }

class LicenseState {
  const LicenseState({
    required this.status,
    required this.installationId,
    this.demoStartedAt,
    this.demoExpiresAt,
    this.lastSeenAt,
  });

  final LicenseStatus status;
  final String installationId;
  final DateTime? demoStartedAt;
  final DateTime? demoExpiresAt;
  final DateTime? lastSeenAt;

  Duration? get remaining {
    if (demoExpiresAt == null) {
      return null;
    }

    final duration = demoExpiresAt!.difference(DateTime.now().toUtc());

    if (duration.isNegative) {
      return Duration.zero;
    }

    return duration;
  }

  int? get remainingDays {
    final duration = remaining;

    if (duration == null) {
      return null;
    }

    if (duration == Duration.zero) {
      return 0;
    }

    return duration.inDays + 1;
  }

  bool get hasAccess =>
      status == LicenseStatus.demo || status == LicenseStatus.licensed;
}
