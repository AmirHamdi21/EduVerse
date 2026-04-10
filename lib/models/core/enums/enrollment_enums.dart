enum EnrollmentStatus {
  enrolled('enrolled'),
  waitlisted('waitlisted'),
  dropped('dropped'),
  completed('completed'),
  failed('failed'),
  unknown('unknown');

  const EnrollmentStatus(this.value);

  final String value;

  static EnrollmentStatus fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in EnrollmentStatus.values) {
      if (item.value == normalized) {
        return item;
      }
    }
    return EnrollmentStatus.unknown;
  }

  String toJson() => value;
}

enum DropReason {
  personal('personal'),
  academic('academic'),
  scheduleConflict('schedule_conflict'),
  other('other'),
  unknown('unknown');

  const DropReason(this.value);

  final String value;

  static DropReason fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in DropReason.values) {
      if (item.value == normalized) {
        return item;
      }
    }
    return DropReason.unknown;
  }

  String toJson() => value;
}
