enum CourseLevel {
  freshman('FRESHMAN'),
  sophomore('SOPHOMORE'),
  junior('JUNIOR'),
  senior('SENIOR'),
  graduate('GRADUATE'),
  unknown('unknown');

  const CourseLevel(this.value);

  final String value;

  static CourseLevel fromString(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in CourseLevel.values) {
      if (item.value.toUpperCase() == normalized) {
        return item;
      }
    }
    return CourseLevel.unknown;
  }

  String toJson() => value;
}

enum CourseStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  archived('ARCHIVED'),
  unknown('unknown');

  const CourseStatus(this.value);

  final String value;

  static CourseStatus fromString(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in CourseStatus.values) {
      if (item.value.toUpperCase() == normalized) {
        return item;
      }
    }
    return CourseStatus.unknown;
  }

  String toJson() => value;
}

enum SectionStatus {
  open('OPEN'),
  closed('CLOSED'),
  full('FULL'),
  cancelled('CANCELLED'),
  unknown('unknown');

  const SectionStatus(this.value);

  final String value;

  static SectionStatus fromString(String value) {
    final normalized = value.trim().toUpperCase();
    for (final item in SectionStatus.values) {
      if (item.value.toUpperCase() == normalized) {
        return item;
      }
    }
    return SectionStatus.unknown;
  }

  String toJson() => value;
}
