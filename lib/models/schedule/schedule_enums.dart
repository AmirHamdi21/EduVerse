enum ScheduleItemKind {
  classSession('class_session'),
  exam('exam'),
  event('event'),
  campusEvent('campus_event'),
  officeHours('office_hours'),
  unknown('unknown');

  const ScheduleItemKind(this.value);

  final String value;

  static ScheduleItemKind fromString(String value) {
    final normalized = value.trim().toLowerCase();

    for (final item in ScheduleItemKind.values) {
      if (item.value.toLowerCase() == normalized) {
        return item;
      }
    }

    switch (normalized) {
      case 'class':
      case 'classsession':
      case 'class_session':
        return ScheduleItemKind.classSession;
      case 'campusevent':
      case 'campus_event':
        return ScheduleItemKind.campusEvent;
      case 'officehours':
      case 'office_hours':
        return ScheduleItemKind.officeHours;
      default:
        return ScheduleItemKind.unknown;
    }
  }

  String toJson() => value;
}
