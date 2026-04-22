enum LabStatus {
  draft('draft'),
  published('published'),
  closed('closed'),
  archived('archived'),
  unknown('unknown');

  const LabStatus(this.value);

  final String value;

  static LabStatus fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in LabStatus.values) {
      if (item.value == normalized) {
        return item;
      }
    }
    return LabStatus.unknown;
  }

  String toJson() => value;
}

enum LabAttendanceStatus {
  present('present'),
  absent('absent'),
  excused('excused'),
  late('late'),
  unknown('unknown');

  const LabAttendanceStatus(this.value);

  final String value;

  static LabAttendanceStatus fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in LabAttendanceStatus.values) {
      if (item.value == normalized) {
        return item;
      }
    }
    return LabAttendanceStatus.unknown;
  }

  String toJson() => value;
}
