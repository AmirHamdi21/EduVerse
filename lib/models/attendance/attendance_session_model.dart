import 'package:equatable/equatable.dart';

import 'attendance_record_model.dart';

/// Maps backend session entity and web LectureAttendanceFlow.tsx session shape.
class AttendanceSessionModel extends Equatable {
  final int id;
  final int sectionId;
  final String sessionDate; // "YYYY-MM-DD"
  final String? sessionType; // "lecture" | "lab" | "tutorial" | "exam"
  final String
  status; // "scheduled" | "in_progress" | "completed" | "cancelled"
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final int? totalMinutes;
  final List<AttendanceRecordModel> records;

  const AttendanceSessionModel({
    required this.id,
    required this.sectionId,
    required this.sessionDate,
    this.sessionType,
    required this.status,
    this.presentCount = 0,
    this.absentCount = 0,
    this.lateCount = 0,
    this.excusedCount = 0,
    this.totalMinutes,
    this.records = const <AttendanceRecordModel>[],
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    final recordsList = json['records'];
    return AttendanceSessionModel(
      id: _toInt(json['id']),
      sectionId: _toInt(json['sectionId']),
      sessionDate: json['sessionDate']?.toString() ?? '',
      sessionType: json['sessionType']?.toString(),
      status: json['status']?.toString() ?? 'scheduled',
      presentCount: _toInt(json['presentCount']),
      absentCount: _toInt(json['absentCount']),
      lateCount: _toInt(json['lateCount']),
      excusedCount: _toInt(json['excusedCount']),
      totalMinutes: json['totalMinutes'] is num
          ? (json['totalMinutes'] as num).toInt()
          : int.tryParse(json['totalMinutes']?.toString() ?? ''),
      records: recordsList is List
          ? recordsList
                .whereType<Map<String, dynamic>>()
                .map(AttendanceRecordModel.fromJson)
                .toList()
          : const <AttendanceRecordModel>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sectionId': sectionId,
    'sessionDate': sessionDate,
    'sessionType': sessionType,
    'status': status,
    'totalMinutes': totalMinutes,
  };

  bool get isOpen => status == 'scheduled' || status == 'in_progress';

  bool get isClosed => status == 'completed' || status == 'cancelled';

  int get totalRecords => records.length;

  AttendanceSessionModel copyWith({
    int? id,
    int? sectionId,
    String? sessionDate,
    String? sessionType,
    String? status,
    int? presentCount,
    int? absentCount,
    int? lateCount,
    int? excusedCount,
    int? totalMinutes,
    List<AttendanceRecordModel>? records,
  }) {
    return AttendanceSessionModel(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      lateCount: lateCount ?? this.lateCount,
      excusedCount: excusedCount ?? this.excusedCount,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      records: records ?? this.records,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
    id,
    sectionId,
    sessionDate,
    sessionType,
    status,
    presentCount,
    absentCount,
    lateCount,
    excusedCount,
    totalMinutes,
    records,
  ];
}
