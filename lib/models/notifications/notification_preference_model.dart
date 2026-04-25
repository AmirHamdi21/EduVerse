class NotificationPreferenceModel {
  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;
  final bool announcementEmail;
  final bool gradeEmail;
  final bool assignmentEmail;
  final bool messageEmail;
  final int deadlineReminderDays;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  const NotificationPreferenceModel({
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.announcementEmail = true,
    this.gradeEmail = true,
    this.assignmentEmail = true,
    this.messageEmail = true,
    this.deadlineReminderDays = 2,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      emailEnabled: _parseBool(json['emailEnabled'], fallback: true),
      pushEnabled: _parseBool(json['pushEnabled'], fallback: true),
      smsEnabled: _parseBool(json['smsEnabled']),
      announcementEmail: _parseBool(json['announcementEmail'], fallback: true),
      gradeEmail: _parseBool(json['gradeEmail'], fallback: true),
      assignmentEmail: _parseBool(json['assignmentEmail'], fallback: true),
      messageEmail: _parseBool(json['messageEmail'], fallback: true),
      deadlineReminderDays:
          _parseInt(json['deadlineReminderDays']) ?? 2,
      quietHoursStart: json['quietHoursStart']?.toString(),
      quietHoursEnd: json['quietHoursEnd']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'announcementEmail': announcementEmail,
      'gradeEmail': gradeEmail,
      'assignmentEmail': assignmentEmail,
      'messageEmail': messageEmail,
      'deadlineReminderDays': deadlineReminderDays,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  NotificationPreferenceModel copyWith({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? announcementEmail,
    bool? gradeEmail,
    bool? assignmentEmail,
    bool? messageEmail,
    int? deadlineReminderDays,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferenceModel(
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      announcementEmail: announcementEmail ?? this.announcementEmail,
      gradeEmail: gradeEmail ?? this.gradeEmail,
      assignmentEmail: assignmentEmail ?? this.assignmentEmail,
      messageEmail: messageEmail ?? this.messageEmail,
      deadlineReminderDays:
          deadlineReminderDays ?? this.deadlineReminderDays,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

bool _parseBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
