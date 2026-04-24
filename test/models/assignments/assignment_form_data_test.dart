import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/assignments/assignment_form_data.dart';
import 'package:edu_verse/models/core/drive_file_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;

void main() {
  group('AssignmentFormData', () {
    test('parses and serializes availableFrom with instruction files', () {
      final json = <String, dynamic>{
        'title': 'Assignment',
        'description': 'Description',
        'instructions': 'Read carefully',
        'instructionFiles': <Map<String, dynamic>>[
          <String, dynamic>{
            'driveFileId': 4,
            'driveId': 'drive-4',
            'fileName': 'rubric.pdf',
            'downloadUrl': 'https://example.com/download',
            'webViewLink': 'https://example.com/view',
          },
        ],
        'availableFrom': '2026-04-24T08:30:00.000Z',
        'dueDate': '2026-04-30T23:59:00.000Z',
        'maxScore': 100,
        'weight': 15,
        'submissionType': 'file',
        'maxFileSizeMb': 20,
        'allowedFileTypes': '["pdf","zip"]',
        'latePenaltyPercent': 10,
        'status': 'published',
        'courseId': 9,
      };

      final data = AssignmentFormData.fromJson(json);

      expect(data.availableFrom, DateTime.parse('2026-04-24T08:30:00.000Z'));
      expect(data.instructionFiles, hasLength(1));
      expect(data.allowedFileTypes, <String>['pdf', 'zip']);

      final encoded = data.toJson();
      expect(encoded['availableFrom'], '2026-04-24T08:30:00.000Z');
      expect(encoded['allowedFileTypes'], '["pdf","zip"]');
    });

    test('copyWith keeps availableFrom unless overridden', () {
      final original = AssignmentFormData(
        title: 'Original',
        availableFrom: DateTime.utc(2026, 4, 24, 8, 30),
        dueDate: DateTime.utc(2026, 4, 30, 23, 59),
        maxScore: 100,
        submissionType: api.SubmissionType.file,
        status: api.AssignmentStatus.draft,
        courseId: 3,
        instructionFiles: const <DriveFileModel>[
          DriveFileModel(
            driveFileId: 1,
            driveId: 'drive-1',
            fileName: 'brief.pdf',
            webViewLink: 'https://example.com/view',
            downloadUrl: 'https://example.com/download',
            iframeUrl: 'https://example.com/preview',
          ),
        ],
      );

      final copied = original.copyWith(title: 'Updated');

      expect(copied.title, 'Updated');
      expect(copied.availableFrom, original.availableFrom);
      expect(copied.instructionFiles, original.instructionFiles);
    });
  });
}
