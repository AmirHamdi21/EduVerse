import 'package:equatable/equatable.dart';

import 'enums/lab_enums.dart';

class LabAttendanceModel extends Equatable {
  final int id;
  final int labId;
  final int userId;
  final LabAttendanceStatus attendanceStatus;
  final DateTime? checkInTime;
  final String? notes;
  final int? markedBy;
  final DateTime? createdAt;

  const LabAttendanceModel({
    required this.id,
    required this.labId,
    required this.userId,
    required this.attendanceStatus,
    this.checkInTime,
    this.notes,
    this.markedBy,
    this.createdAt,
  });

  factory LabAttendanceModel.fromJson(Map<String, dynamic> json) {
    return LabAttendanceModel(
      id: _parseInt(json['id']),
      labId: _parseInt(json['labId']),
      userId: _parseInt(json['userId']),
      attendanceStatus: LabAttendanceStatus.fromString(
        json['attendanceStatus']?.toString() ?? 'unknown',
      ),
      checkInTime: json['checkInTime'] != null
          ? DateTime.tryParse(json['checkInTime'].toString())
          : null,
      notes: json['notes']?.toString(),
      markedBy: _parseNullableInt(json['markedBy']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'labId': labId,
      'userId': userId,
      'attendanceStatus': attendanceStatus.toJson(),
      'checkInTime': checkInTime?.toIso8601String(),
      'notes': notes,
      'markedBy': markedBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    labId,
    userId,
    attendanceStatus,
    checkInTime,
    notes,
    markedBy,
    createdAt,
  ];
}
