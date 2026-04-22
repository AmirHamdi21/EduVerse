import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_verse/utils/submission_event_tracker.dart';

void main() {
  group('SubmissionEventTracker', () {
    late SubmissionEventTracker tracker;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tracker = SubmissionEventTracker();
    });

    test(
      'logSubmission stores successful event and updates success rate',
      () async {
        await tracker.logSubmission('lab-1');

        final events = await tracker.getEvents();
        final successRate = await tracker.getSuccessRate();

        expect(events.length, 1);
        expect(events.first['labId'], 'lab-1');
        expect(events.first['success'], true);
        expect(successRate, 100);
      },
    );

    test(
      'logSubmissionFailure stores error and computes success percentage',
      () async {
        await tracker.logSubmission('lab-1');
        await tracker.logSubmissionFailure('lab-2', 'network error');

        final events = await tracker.getEvents();
        final successRate = await tracker.getSuccessRate();

        expect(events.length, 2);
        expect(events.last['success'], false);
        expect(events.last['error'], 'network error');
        expect(successRate, 50);
      },
    );

    test('prunes events older than 30 days', () async {
      final oldTimestamp = DateTime.now()
          .subtract(const Duration(days: 40))
          .toIso8601String();

      SharedPreferences.setMockInitialValues(<String, Object>{
        'lab_submission_events': <String>[
          jsonEncode(<String, dynamic>{
            'timestamp': oldTimestamp,
            'labId': 'old-lab',
            'success': true,
          }),
        ],
      });

      tracker = SubmissionEventTracker();
      await tracker.logSubmission('new-lab');

      final events = await tracker.getEvents();

      expect(events.length, 1);
      expect(events.first['labId'], 'new-lab');
    });
  });
}
