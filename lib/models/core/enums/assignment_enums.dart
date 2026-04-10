enum AssignmentStatus {
  draft('draft'),
  published('published'),
  closed('closed'),
  archived('archived'),
  unknown('unknown');

  const AssignmentStatus(this.value);

  final String value;

  static AssignmentStatus fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in AssignmentStatus.values) {
      if (item.value == normalized) {
        return item;
      }
    }
    return AssignmentStatus.unknown;
  }

  String toJson() => value;
}

enum SubmissionType {
  file('file'),
  text('text'),
  link('link'),
  multiple('multiple'),
  unknown('unknown');

  const SubmissionType(this.value);

  final String value;

  static SubmissionType fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in SubmissionType.values) {
      if (item.value == normalized) {
        return item;
      }
    }
    return SubmissionType.unknown;
  }

  String toJson() => value;
}

enum SubmissionStatus {
  submitted('submitted'),
  graded('graded'),
  returned('returned'),
  resubmit('resubmit'),
  unknown('unknown');

  const SubmissionStatus(this.value);

  final String value;

  static SubmissionStatus fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final item in SubmissionStatus.values) {
      if (item.value == normalized) {
        return item;
      }
    }
    return SubmissionStatus.unknown;
  }

  String toJson() => value;
}
