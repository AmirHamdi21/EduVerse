enum ScheduleType {
  lecture('LECTURE'),
  lab('LAB'),
  tutorial('TUTORIAL'),
  exam('EXAM'),
  unknown('unknown');

  const ScheduleType(this.value);

  final String value;

  static ScheduleType fromString(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in ScheduleType.values) {
      if (item.value.toUpperCase() == normalized) {
        return item;
      }
    }
    return ScheduleType.unknown;
  }

  String toJson() => value;
}

enum DayOfWeek {
  monday('MONDAY'),
  tuesday('TUESDAY'),
  wednesday('WEDNESDAY'),
  thursday('THURSDAY'),
  friday('FRIDAY'),
  saturday('SATURDAY'),
  sunday('SUNDAY'),
  unknown('unknown');

  const DayOfWeek(this.value);

  final String value;

  static DayOfWeek fromString(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in DayOfWeek.values) {
      if (item.value.toUpperCase() == normalized) {
        return item;
      }
    }
    return DayOfWeek.unknown;
  }

  String toJson() => value;
}
