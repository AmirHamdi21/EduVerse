import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SubmissionEventTracker {
  static const String _eventsKey = 'lab_submission_events';

  Future<void> logSubmission(String labId) async {
    await _writeEvent(<String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'labId': labId,
      'success': true,
    });
  }

  Future<void> logSubmissionFailure(String labId, String error) async {
    await _writeEvent(<String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'labId': labId,
      'success': false,
      'error': error,
    });
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final preferences = await SharedPreferences.getInstance();
    final rawEvents = preferences.getStringList(_eventsKey) ?? const <String>[];

    return rawEvents
        .map((raw) => jsonDecode(raw))
        .whereType<Map>()
        .map(
          (event) => event.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  Future<double> getSuccessRate() async {
    final events = await getEvents();
    if (events.isEmpty) {
      return 0;
    }

    final successCount = events
        .where((event) => event['success'] == true)
        .length;
    return (successCount / events.length) * 100;
  }

  Future<void> _writeEvent(Map<String, dynamic> event) async {
    final preferences = await SharedPreferences.getInstance();
    final events = await getEvents();
    events.add(event);

    final prunedEvents = _pruneOldEvents(events);
    final encoded = prunedEvents.map(jsonEncode).toList();

    await preferences.setStringList(_eventsKey, encoded);
  }

  List<Map<String, dynamic>> _pruneOldEvents(
    List<Map<String, dynamic>> events,
  ) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    return events.where((event) {
      final rawTimestamp = event['timestamp']?.toString();
      if (rawTimestamp == null) {
        return false;
      }

      final timestamp = DateTime.tryParse(rawTimestamp);
      if (timestamp == null) {
        return false;
      }

      return timestamp.isAfter(cutoff);
    }).toList();
  }
}
