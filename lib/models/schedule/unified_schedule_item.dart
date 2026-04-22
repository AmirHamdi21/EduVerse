import 'package:equatable/equatable.dart';

import '../admin/admin_periods_models.dart';
import 'daily_schedule_response.dart';
import 'schedule_enums.dart';

class UnifiedScheduleItem extends Equatable {
  final String id;
  final ScheduleItemKind kind;
  final String date;
  final String startTime;
  final String endTime;
  final String title;
  final String? subtitle;
  final String? location;
  final String color;
  final String? courseCode;
  final int? courseId;

  final ClassScheduleItem? classItem;
  final ExamScheduleItem? examItem;
  final PersonalEventItem? eventItem;
  final CampusEventScheduleItem? campusEventItem;
  final OfficeHourSlotModel? officeHoursSlot;

  final bool? isMandatory;
  final bool? registrationRequired;

  const UnifiedScheduleItem({
    required this.id,
    required this.kind,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.subtitle,
    this.location,
    required this.color,
    this.courseCode,
    this.courseId,
    this.classItem,
    this.examItem,
    this.eventItem,
    this.campusEventItem,
    this.officeHoursSlot,
    this.isMandatory,
    this.registrationRequired,
  });

  UnifiedScheduleItem copyWith({
    String? id,
    ScheduleItemKind? kind,
    String? date,
    String? startTime,
    String? endTime,
    String? title,
    String? subtitle,
    String? location,
    String? color,
    String? courseCode,
    int? courseId,
    ClassScheduleItem? classItem,
    ExamScheduleItem? examItem,
    PersonalEventItem? eventItem,
    CampusEventScheduleItem? campusEventItem,
    OfficeHourSlotModel? officeHoursSlot,
    bool? isMandatory,
    bool? registrationRequired,
  }) {
    return UnifiedScheduleItem(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      location: location ?? this.location,
      color: color ?? this.color,
      courseCode: courseCode ?? this.courseCode,
      courseId: courseId ?? this.courseId,
      classItem: classItem ?? this.classItem,
      examItem: examItem ?? this.examItem,
      eventItem: eventItem ?? this.eventItem,
      campusEventItem: campusEventItem ?? this.campusEventItem,
      officeHoursSlot: officeHoursSlot ?? this.officeHoursSlot,
      isMandatory: isMandatory ?? this.isMandatory,
      registrationRequired: registrationRequired ?? this.registrationRequired,
    );
  }

  factory UnifiedScheduleItem.fromJson(Map<String, dynamic> json) {
    return UnifiedScheduleItem(
      id: _asString(json['id']),
      kind: ScheduleItemKind.fromString(_asString(json['kind'])),
      date: _asString(json['date']),
      startTime: _asString(json['startTime']),
      endTime: _asString(json['endTime']),
      title: _asString(json['title']),
      subtitle: _nullableString(json['subtitle']),
      location: _nullableString(json['location']),
      color: _asString(json['color'], fallback: '#3b82f6'),
      courseCode: _nullableString(json['courseCode']),
      courseId: _parseNullableInt(json['courseId']),
      classItem: _asMap(json['classItem']) == null
          ? null
          : ClassScheduleItem.fromJson(_asMap(json['classItem'])!),
      examItem: _asMap(json['examItem']) == null
          ? null
          : ExamScheduleItem.fromJson(_asMap(json['examItem'])!),
      eventItem: _asMap(json['eventItem']) == null
          ? null
          : PersonalEventItem.fromJson(_asMap(json['eventItem'])!),
      campusEventItem: _asMap(json['campusEventItem']) == null
          ? null
          : CampusEventScheduleItem.fromJson(_asMap(json['campusEventItem'])!),
      officeHoursSlot: _asMap(json['officeHoursSlot']) == null
          ? null
          : OfficeHourSlotModel.fromJson(_asMap(json['officeHoursSlot'])!),
      isMandatory: _parseNullableBool(json['isMandatory']),
      registrationRequired: _parseNullableBool(json['registrationRequired']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'kind': kind.toJson(),
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      'subtitle': subtitle,
      'location': location,
      'color': color,
      'courseCode': courseCode,
      'courseId': courseId,
      'classItem': classItem?.toJson(),
      'examItem': examItem?.toJson(),
      'eventItem': eventItem?.toJson(),
      'campusEventItem': campusEventItem?.toJson(),
      'officeHoursSlot': officeHoursSlot == null
          ? null
          : <String, dynamic>{
              'slotId': officeHoursSlot!.slotId,
              'instructorId': officeHoursSlot!.instructorId,
              'dayOfWeek': officeHoursSlot!.dayOfWeek,
              'startTime': officeHoursSlot!.startTime,
              'endTime': officeHoursSlot!.endTime,
              'location': officeHoursSlot!.location,
              'mode': officeHoursSlot!.mode,
              'maxAppointments': officeHoursSlot!.maxAppointments,
              'currentAppointments': officeHoursSlot!.currentAppointments,
              'isActive': officeHoursSlot!.isActive,
              'notes': officeHoursSlot!.notes,
            },
      'isMandatory': isMandatory,
      'registrationRequired': registrationRequired,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    kind,
    date,
    startTime,
    endTime,
    title,
    subtitle,
    location,
    color,
    courseCode,
    courseId,
    classItem,
    examItem,
    eventItem,
    campusEventItem,
    officeHoursSlot,
    isMandatory,
    registrationRequired,
  ];
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  final output = value.toString().trim();
  return output.isEmpty ? fallback : output;
}

String? _nullableString(dynamic value) {
  final output = _asString(value);
  return output.isEmpty ? null : output;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

bool? _parseNullableBool(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }
  return null;
}
