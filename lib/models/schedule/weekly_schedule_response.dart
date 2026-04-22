import 'package:equatable/equatable.dart';

import 'daily_schedule_response.dart';

class WeeklyScheduleResponse extends Equatable {
  final String weekStart;
  final String weekEnd;
  final List<DailyScheduleResponse> days;

  const WeeklyScheduleResponse({
    required this.weekStart,
    required this.weekEnd,
    required this.days,
  });

  factory WeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    final days = json['days'] is List
        ? json['days'] as List
        : const <dynamic>[];

    return WeeklyScheduleResponse(
      weekStart: _asString(json['weekStart']),
      weekEnd: _asString(json['weekEnd']),
      days: days
          .whereType<Map<String, dynamic>>()
          .map(DailyScheduleResponse.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'weekStart': weekStart,
      'weekEnd': weekEnd,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => <Object?>[weekStart, weekEnd, days];
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  final output = value.toString().trim();
  return output.isEmpty ? fallback : output;
}
