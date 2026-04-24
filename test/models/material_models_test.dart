import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/materials/assignment_model.dart';
import 'package:edu_verse/models/materials/announcement_model.dart';
import 'package:edu_verse/models/materials/discussion_thread_model.dart';

void main() {
  group('CourseMaterialModel', () {
    test('fromJson parses complete payload', () {
      final json = {
        'materialId': 'mat-1',
        'courseId': '1',
        'fileId': 'file-abc',
        'driveFileId': 'drive-xyz',
        'materialType': 'video',
        'title': 'Lecture 1 Recording',
        'description': 'Full recording of lecture 1',
        'externalUrl': 'https://example.com/video',
        'youtubeVideoId': 'dQw4w9WgXcQ',
        'orderIndex': 1,
        'weekNumber': 1,
        'viewCount': 150,
        'downloadCount': 42,
        'uploadedBy': 5,
        'isPublished': true,
        'publishedAt': '2026-01-10T08:00:00.000Z',
        'createdAt': '2026-01-09T08:00:00.000Z',
        'updatedAt': '2026-01-10T08:00:00.000Z',
      };

      final model = CourseMaterialModel.fromJson(json);

      expect(model.materialId, 'mat-1');
      expect(model.materialType, 'video');
      expect(model.isPublished, true);
      expect(model.viewCount, 150);
      expect(model.youtubeVideoId, 'dQw4w9WgXcQ');
    });

    test('fromJson handles isPublished as int (1)', () {
      final json = {
        'materialId': 'mat-2',
        'courseId': '1',
        'materialType': 'document',
        'title': 'Syllabus',
        'isPublished': 1,
        'createdAt': '2026-01-09T08:00:00.000Z',
      };

      final model = CourseMaterialModel.fromJson(json);
      expect(model.isPublished, true);
    });

    test('fromJson handles isPublished as int (0)', () {
      final json = {
        'materialId': 'mat-3',
        'courseId': '1',
        'materialType': 'slide',
        'title': 'Draft Slides',
        'isPublished': 0,
        'createdAt': '2026-01-09T08:00:00.000Z',
      };

      final model = CourseMaterialModel.fromJson(json);
      expect(model.isPublished, false);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'materialId': 'mat-4',
        'courseId': '1',
        'materialType': 'link',
        'title': 'External Resource',
        'isPublished': false,
        'createdAt': '2026-01-09T08:00:00.000Z',
      };

      final model = CourseMaterialModel.fromJson(json);

      expect(model.fileId, isNull);
      expect(model.driveFileId, isNull);
      expect(model.description, isNull);
      expect(model.externalUrl, isNull);
      expect(model.youtubeVideoId, isNull);
      expect(model.weekNumber, isNull);
      expect(model.viewCount, isNull);
      expect(model.downloadCount, isNull);
      expect(model.uploadedBy, isNull);
      expect(model.publishedAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('toJson round-trips correctly', () {
      final json = {
        'materialId': 'mat-1',
        'courseId': '1',
        'materialType': 'document',
        'title': 'Test',
        'isPublished': true,
        'createdAt': '2026-01-09T08:00:00.000Z',
      };

      final model = CourseMaterialModel.fromJson(json);
      final output = model.toJson();

      expect(output['materialId'], 'mat-1');
      expect(output['isPublished'], true);
    });
  });

  group('AssignmentModel', () {
    test('fromJson parses complete payload', () {
      final json = {
        'id': 'asgn-1',
        'courseId': '1',
        'title': 'Homework 1',
        'description': 'Complete exercises 1-10',
        'dueDate': '2026-02-15T23:59:59.000Z',
        'maxScore': '100',
        'weight': '10',
        'status': 'published',
        'submissionType': 'file',
        'latePenalty': 5.5,
        'course': {
          'courseId': 1,
          'courseCode': 'CS101',
          'courseName': 'Intro to CS',
          'credits': 3,
        },
        'createdAt': '2026-01-20T08:00:00.000Z',
        'updatedAt': '2026-01-20T08:00:00.000Z',
      };

      final model = AssignmentModel.fromJson(json);

      expect(model.id, 'asgn-1');
      expect(model.title, 'Homework 1');
      expect(model.status, 'published');
      expect(model.submissionType, 'file');
      expect(model.latePenalty, 5.5);
      expect(model.course, isNotNull);
      expect(model.course!.courseCode, 'CS101');
      expect(model.dueDate, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'asgn-2',
        'courseId': '1',
        'title': 'Quiz 1',
        'maxScore': '50',
        'weight': '5',
        'status': 'draft',
        'submissionType': 'text',
        'createdAt': '2026-01-20T08:00:00.000Z',
        'updatedAt': '2026-01-20T08:00:00.000Z',
      };

      final model = AssignmentModel.fromJson(json);

      expect(model.description, isNull);
      expect(model.dueDate, isNull);
      expect(model.latePenalty, isNull);
      expect(model.course, isNull);
    });

    test('fromJson handles numeric maxScore and weight', () {
      final json = {
        'id': 'asgn-3',
        'courseId': '1',
        'title': 'Midterm',
        'maxScore': 100,
        'weight': 30,
        'status': 'published',
        'submissionType': 'file',
        'createdAt': '2026-01-20T08:00:00.000Z',
        'updatedAt': '2026-01-20T08:00:00.000Z',
      };

      final model = AssignmentModel.fromJson(json);

      expect(model.maxScore, '100');
      expect(model.weight, '30');
    });
  });

  group('AnnouncementModel', () {
    test('fromJson parses complete payload', () {
      final json = {
        'id': 'ann-1',
        'courseId': '1',
        'title': 'Midterm Schedule',
        'content': 'The midterm will be held on March 15.',
        'createdBy': 5,
        'priority': 'high',
        'publishedAt': '2026-02-01T10:00:00.000Z',
        'expiresAt': '2026-03-16T00:00:00.000Z',
        'createdAt': '2026-02-01T10:00:00.000Z',
        'updatedAt': '2026-02-01T10:00:00.000Z',
      };

      final model = AnnouncementModel.fromJson(json);

      expect(model.id, 'ann-1');
      expect(model.title, 'Midterm Schedule');
      expect(model.priority, 'high');
      expect(model.expiresAt, isNotNull);
      expect(model.createdBy, 5);
    });

    test('fromJson handles missing expiresAt', () {
      final json = {
        'id': 'ann-2',
        'courseId': '1',
        'title': 'Welcome',
        'content': 'Welcome to the course!',
        'createdBy': 5,
        'priority': 'low',
        'publishedAt': '2026-01-10T00:00:00.000Z',
        'createdAt': '2026-01-10T00:00:00.000Z',
        'updatedAt': '2026-01-10T00:00:00.000Z',
      };

      final model = AnnouncementModel.fromJson(json);
      expect(model.expiresAt, isNull);
    });

    test('fromJson tolerates stringified numeric fields from backend', () {
      final json = {
        'id': '3001',
        'courseId': '44',
        'title': 'Backend shape changed',
        'content': 'Numbers are serialized as strings.',
        'createdBy': '15',
        'priority': 'urgent',
        'isPublished': '1',
        'isPinned': '0',
        'viewCount': '12',
        'createdAt': '2026-04-01T10:00:00.000Z',
        'updatedAt': '2026-04-01T10:00:00.000Z',
        'author': {
          'userId': '15',
          'firstName': 'Mona',
          'lastName': 'Ali',
          'email': 'mona@eduverse.test',
        },
        'course': {'id': '44', 'name': 'Networks', 'code': 'CS330'},
      };

      final model = AnnouncementModel.fromJson(json);

      expect(model.createdBy, 15);
      expect(model.isPublished, 1);
      expect(model.isPinned, 0);
      expect(model.viewCount, 12);
      expect(model.author?.userId, 15);
      expect(model.author?.displayName, 'Mona Ali');
      expect(model.course?.displayLabel, 'Networks (CS330)');
    });
  });

  group('DiscussionThreadModel', () {
    test('fromJson parses complete payload', () {
      final json = {
        'id': 'disc-1',
        'forumId': 'forum-1',
        'title': 'Question about HW1',
        'content': 'Can someone explain exercise 3?',
        'createdBy': 42,
        'isPinned': true,
        'isLocked': false,
        'replyCount': 5,
        'createdAt': '2026-01-20T14:00:00.000Z',
        'updatedAt': '2026-01-21T10:00:00.000Z',
      };

      final model = DiscussionThreadModel.fromJson(json);

      expect(model.id, 'disc-1');
      expect(model.forumId, 'forum-1');
      expect(model.isPinned, true);
      expect(model.isLocked, false);
      expect(model.replyCount, 5);
    });

    test('fromJson handles isPinned/isLocked as int', () {
      final json = {
        'id': 'disc-2',
        'forumId': 'forum-1',
        'title': 'Locked Thread',
        'content': 'This thread is locked.',
        'createdBy': 5,
        'isPinned': 0,
        'isLocked': 1,
        'replyCount': 0,
        'createdAt': '2026-01-20T14:00:00.000Z',
        'updatedAt': '2026-01-20T14:00:00.000Z',
      };

      final model = DiscussionThreadModel.fromJson(json);

      expect(model.isPinned, false);
      expect(model.isLocked, true);
    });

    test('toJson round-trips correctly', () {
      final json = {
        'id': 'disc-1',
        'forumId': 'forum-1',
        'title': 'Test',
        'content': 'Content',
        'createdBy': 1,
        'isPinned': false,
        'isLocked': false,
        'replyCount': 0,
        'createdAt': '2026-01-20T14:00:00.000Z',
        'updatedAt': '2026-01-20T14:00:00.000Z',
      };

      final model = DiscussionThreadModel.fromJson(json);
      final output = model.toJson();

      expect(output['id'], 'disc-1');
      expect(output['isPinned'], false);
      expect(output['replyCount'], 0);
    });
  });
}
