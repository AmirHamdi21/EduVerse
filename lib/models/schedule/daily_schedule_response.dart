import 'package:equatable/equatable.dart';

class CourseBasic extends Equatable {
  final int courseId;
  final String courseCode;
  final String courseName;

  const CourseBasic({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
  });

  factory CourseBasic.fromJson(Map<String, dynamic> json) {
    return CourseBasic(
      courseId: _parseInt(json['courseId'] ?? json['id']),
      courseCode: _asString(
        json['courseCode'] ?? json['code'] ?? json['course_code'],
      ),
      courseName: _asString(
        json['courseName'] ?? json['name'] ?? json['course_name'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'courseCode': courseCode,
      'courseName': courseName,
    };
  }

  @override
  List<Object?> get props => <Object?>[courseId, courseCode, courseName];
}

class ClassScheduleSection extends Equatable {
  final int id;
  final String sectionNumber;
  final CourseBasic? course;

  const ClassScheduleSection({
    required this.id,
    required this.sectionNumber,
    this.course,
  });

  factory ClassScheduleSection.fromJson(Map<String, dynamic> json) {
    final courseMap = _asMap(json['course']);

    return ClassScheduleSection(
      id: _parseInt(json['id']),
      sectionNumber: _asString(
        json['sectionNumber'] ?? json['sectionNo'] ?? json['name'],
      ),
      course: courseMap == null ? null : CourseBasic.fromJson(courseMap),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sectionNumber': sectionNumber,
      'course': course?.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[id, sectionNumber, course];
}

class ClassScheduleItem extends Equatable {
  final String type;
  final int id;
  final int sectionId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? building;
  final String scheduleType;
  final ClassScheduleSection? section;

  const ClassScheduleItem({
    required this.type,
    required this.id,
    required this.sectionId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.building,
    required this.scheduleType,
    this.section,
  });

  factory ClassScheduleItem.fromJson(Map<String, dynamic> json) {
    final sectionMap = _asMap(json['section']);

    return ClassScheduleItem(
      type: _asString(json['type'], fallback: 'class'),
      id: _parseInt(json['id']),
      sectionId: _parseInt(json['sectionId']),
      dayOfWeek: _asString(json['dayOfWeek']),
      startTime: _asString(json['startTime']),
      endTime: _asString(json['endTime']),
      room: _nullableString(json['room']),
      building: _nullableString(json['building']),
      scheduleType: _asString(json['scheduleType'], fallback: 'LECTURE'),
      section: sectionMap == null
          ? null
          : ClassScheduleSection.fromJson(sectionMap),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'id': id,
      'sectionId': sectionId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'building': building,
      'scheduleType': scheduleType,
      'section': section?.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
    type,
    id,
    sectionId,
    dayOfWeek,
    startTime,
    endTime,
    room,
    building,
    scheduleType,
    section,
  ];
}

class PersonalEventItem extends Equatable {
  final String type;
  final int eventId;
  final String title;
  final String? description;
  final String eventType;
  final String startTime;
  final String endTime;
  final String? location;
  final String color;
  final CourseBasic? course;

  const PersonalEventItem({
    required this.type,
    required this.eventId,
    required this.title,
    this.description,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.color,
    this.course,
  });

  factory PersonalEventItem.fromJson(Map<String, dynamic> json) {
    final courseMap = _asMap(json['course']);

    return PersonalEventItem(
      type: _asString(json['type'], fallback: 'event'),
      eventId: _parseInt(json['eventId'] ?? json['id']),
      title: _asString(json['title'], fallback: 'Untitled Event'),
      description: _nullableString(json['description']),
      eventType: _asString(json['eventType'], fallback: 'PERSONAL'),
      startTime: _asString(json['startTime']),
      endTime: _asString(json['endTime']),
      location: _nullableString(json['location']),
      color: _asString(json['color'], fallback: '#8b5cf6'),
      course: courseMap == null ? null : CourseBasic.fromJson(courseMap),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'eventId': eventId,
      'title': title,
      'description': description,
      'eventType': eventType,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'color': color,
      'course': course?.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
    type,
    eventId,
    title,
    description,
    eventType,
    startTime,
    endTime,
    location,
    color,
    course,
  ];
}

class ExamScheduleItem extends Equatable {
  final String type;
  final int examId;
  final int courseId;
  final String examType;
  final String? title;
  final String examDate;
  final String startTime;
  final int durationMinutes;
  final String? location;
  final CourseBasic course;

  const ExamScheduleItem({
    required this.type,
    required this.examId,
    required this.courseId,
    required this.examType,
    this.title,
    required this.examDate,
    required this.startTime,
    required this.durationMinutes,
    this.location,
    required this.course,
  });

  factory ExamScheduleItem.fromJson(Map<String, dynamic> json) {
    final courseMap = _asMap(json['course']);

    return ExamScheduleItem(
      type: _asString(json['type'], fallback: 'exam'),
      examId: _parseInt(json['examId'] ?? json['id']),
      courseId: _parseInt(json['courseId']),
      examType: _asString(json['examType'], fallback: 'exam'),
      title: _nullableString(json['title']),
      examDate: _asString(json['examDate']),
      startTime: _asString(json['startTime']),
      durationMinutes: _parseInt(json['durationMinutes'], fallback: 0),
      location: _nullableString(json['location']),
      course: courseMap != null
          ? CourseBasic.fromJson(courseMap)
          : CourseBasic(
              courseId: _parseInt(json['courseId']),
              courseCode: _asString(json['courseCode'] ?? json['code']),
              courseName: _asString(json['courseName'] ?? json['name']),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'examId': examId,
      'courseId': courseId,
      'examType': examType,
      'title': title,
      'examDate': examDate,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'location': location,
      'course': course.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
    type,
    examId,
    courseId,
    examType,
    title,
    examDate,
    startTime,
    durationMinutes,
    location,
    course,
  ];
}

class CampusEventScheduleItem extends Equatable {
  final String type;
  final int eventId;
  final String title;
  final String? description;
  final String eventType;
  final String startDatetime;
  final String endDatetime;
  final String? location;
  final String color;
  final bool isMandatory;
  final bool registrationRequired;

  const CampusEventScheduleItem({
    required this.type,
    required this.eventId,
    required this.title,
    this.description,
    required this.eventType,
    required this.startDatetime,
    required this.endDatetime,
    this.location,
    required this.color,
    required this.isMandatory,
    required this.registrationRequired,
  });

  factory CampusEventScheduleItem.fromJson(Map<String, dynamic> json) {
    return CampusEventScheduleItem(
      type: _asString(json['type'], fallback: 'campus_event'),
      eventId: _parseInt(json['eventId'] ?? json['id']),
      title: _asString(json['title'], fallback: 'Untitled Event'),
      description: _nullableString(json['description']),
      eventType: _asString(json['eventType'], fallback: 'GENERAL'),
      startDatetime: _asString(json['startDatetime'] ?? json['startDateTime']),
      endDatetime: _asString(json['endDatetime'] ?? json['endDateTime']),
      location: _nullableString(json['location']),
      color: _asString(json['color'], fallback: '#10b981'),
      isMandatory: _parseBool(json['isMandatory']),
      registrationRequired: _parseBool(json['registrationRequired']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'eventId': eventId,
      'title': title,
      'description': description,
      'eventType': eventType,
      'startDatetime': startDatetime,
      'endDatetime': endDatetime,
      'location': location,
      'color': color,
      'isMandatory': isMandatory,
      'registrationRequired': registrationRequired,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    type,
    eventId,
    title,
    description,
    eventType,
    startDatetime,
    endDatetime,
    location,
    color,
    isMandatory,
    registrationRequired,
  ];
}

class DailyScheduleResponse extends Equatable {
  final String date;
  final String dayOfWeek;
  final List<ClassScheduleItem> schedules;
  final List<PersonalEventItem> events;
  final List<ExamScheduleItem> exams;
  final List<CampusEventScheduleItem> campusEvents;

  const DailyScheduleResponse({
    required this.date,
    required this.dayOfWeek,
    required this.schedules,
    required this.events,
    required this.exams,
    required this.campusEvents,
  });

  factory DailyScheduleResponse.fromJson(Map<String, dynamic> json) {
    return DailyScheduleResponse(
      date: _asString(json['date']),
      dayOfWeek: _asString(json['dayOfWeek']),
      schedules: _asList(json['schedules'])
          .whereType<Map<String, dynamic>>()
          .map(ClassScheduleItem.fromJson)
          .toList(growable: false),
      events: _asList(json['events'])
          .whereType<Map<String, dynamic>>()
          .map(PersonalEventItem.fromJson)
          .toList(growable: false),
      exams: _asList(json['exams'])
          .whereType<Map<String, dynamic>>()
          .map(ExamScheduleItem.fromJson)
          .toList(growable: false),
      campusEvents: _asList(json['campusEvents'])
          .whereType<Map<String, dynamic>>()
          .map(CampusEventScheduleItem.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date,
      'dayOfWeek': dayOfWeek,
      'schedules': schedules.map((item) => item.toJson()).toList(),
      'events': events.map((item) => item.toJson()).toList(),
      'exams': exams.map((item) => item.toJson()).toList(),
      'campusEvents': campusEvents.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
    date,
    dayOfWeek,
    schedules,
    events,
    exams,
    campusEvents,
  ];
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

bool _parseBool(dynamic value, {bool fallback = false}) {
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
  return fallback;
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

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const <dynamic>[];
}
