import 'package:equatable/equatable.dart';

class GradeGpaModel extends Equatable {
  final int studentId;
  final double gpa;

  const GradeGpaModel({required this.studentId, required this.gpa});

  factory GradeGpaModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return GradeGpaModel(
      studentId: _parseInt(
        payload['studentId'] ?? payload['userId'] ?? payload['id'],
      ),
      gpa: _parseDouble(payload['gpa'] ?? payload['cumulativeGPA']),
    );
  }

  @override
  List<Object?> get props => <Object?>[studentId, gpa];
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
