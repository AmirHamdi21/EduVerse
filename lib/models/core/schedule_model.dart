import 'package:equatable/equatable.dart';

import 'enums/schedule_enums.dart';

class ScheduleModel extends Equatable {
  final int id;
  final int sectionId;
  final DayOfWeek dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? building;
  final ScheduleType scheduleType;
  final DateTime? createdAt;

  const ScheduleModel({
    required this.id,
    required this.sectionId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.building,
    required this.scheduleType,
    this.createdAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: _parseInt(json['id']),
      sectionId: _parseInt(json['sectionId']),
      dayOfWeek: DayOfWeek.fromString(
        json['dayOfWeek']?.toString() ?? 'unknown',
      ),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      room: json['room']?.toString(),
      building: json['building']?.toString(),
      scheduleType: ScheduleType.fromString(
        json['scheduleType']?.toString() ?? 'unknown',
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sectionId': sectionId,
      'dayOfWeek': dayOfWeek.toJson(),
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'building': building,
      'scheduleType': scheduleType.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    sectionId,
    dayOfWeek,
    startTime,
    endTime,
    room,
    building,
    scheduleType,
    createdAt,
  ];
}
