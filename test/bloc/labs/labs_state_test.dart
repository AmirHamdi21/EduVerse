import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/labs/labs_state.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/lab_enums.dart' as api;
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/labs/lab_model.dart';

CourseModel _course({
  required int id,
  required String code,
  required String name,
}) {
  return CourseModel(
    id: id,
    departmentId: 1,
    code: code,
    name: name,
    credits: 3,
    courseLevel: CourseLevel.freshman,
    courseStatus: CourseStatus.active,
  );
}

LabModel _lab({
  required String id,
  required int courseId,
  required String title,
  required DateTime dueDate,
  required api.LabStatus status,
  String courseCode = 'CS101',
  String courseName = 'Algorithms',
}) {
  return LabModel(
    id: id,
    labId: int.tryParse(id),
    courseId: courseId,
    title: title,
    dueDate: dueDate,
    maxScore: 100,
    status: status,
    course: CourseInfo(id: courseId, name: courseName, code: courseCode),
  );
}

void main() {
  group('LabsState.filteredLabs', () {
    test('filters by selected course id', () {
      final now = DateTime.now();
      final state = LabsState(
        labs: <LabModel>[
          _lab(
            id: '1',
            courseId: 1,
            title: 'Course 1 Lab',
            dueDate: now.add(const Duration(days: 2)),
            status: api.LabStatus.published,
          ),
          _lab(
            id: '2',
            courseId: 2,
            title: 'Course 2 Lab',
            dueDate: now.add(const Duration(days: 2)),
            status: api.LabStatus.published,
          ),
        ],
        selectedCourseId: 1,
      );

      expect(state.filteredLabs.length, 1);
      expect(state.filteredLabs.first.courseId, 1);
    });

    test('applies search query and status filters with sorting', () {
      final now = DateTime.now();
      final state = LabsState(
        labs: <LabModel>[
          _lab(
            id: '1',
            courseId: 1,
            title: 'Binary Search Lab',
            dueDate: now.add(const Duration(days: 2)),
            status: api.LabStatus.published,
          ),
          _lab(
            id: '2',
            courseId: 1,
            title: 'Graph Basics',
            dueDate: now.subtract(const Duration(days: 4)),
            status: api.LabStatus.published,
          ),
          _lab(
            id: '3',
            courseId: 1,
            title: 'Sorting Closed Lab',
            dueDate: now.subtract(const Duration(days: 1)),
            status: api.LabStatus.closed,
          ),
        ],
        selectedCourseId: 1,
        searchQuery: 'lab',
        filter: const LabsFilter(status: LabsDisplayStatus.upcoming),
        sortBy: LabsSortBy.title,
      );

      expect(state.filteredLabs.length, 1);
      expect(state.filteredLabs.first.title, 'Binary Search Lab');
    });

    test('maps backend statuses to summary counters', () {
      final now = DateTime.now();
      final state = LabsState(
        labs: <LabModel>[
          _lab(
            id: '1',
            courseId: 1,
            title: 'Upcoming',
            dueDate: now.add(const Duration(days: 1)),
            status: api.LabStatus.published,
          ),
          _lab(
            id: '2',
            courseId: 1,
            title: 'In Progress',
            dueDate: now.subtract(const Duration(days: 1)),
            status: api.LabStatus.published,
          ),
          _lab(
            id: '3',
            courseId: 1,
            title: 'Missed',
            dueDate: now.subtract(const Duration(days: 3)),
            status: api.LabStatus.published,
          ),
          _lab(
            id: '4',
            courseId: 1,
            title: 'Completed',
            dueDate: now.subtract(const Duration(days: 2)),
            status: api.LabStatus.closed,
          ),
        ],
        selectedCourseId: 1,
      );

      expect(state.upcomingCount, 1);
      expect(state.inProgressCount, 1);
      expect(state.missedCount, 1);
      expect(state.completedCount, 1);
    });
  });

  group('LabsState.availableCourses', () {
    test('returns sorted unique enrolled course names', () {
      final state = LabsState(
        enrolledCourses: <CourseModel>[
          _course(id: 2, code: 'CS202', name: 'Data Structures'),
          _course(id: 1, code: 'CS101', name: 'Algorithms'),
          _course(id: 3, code: 'CS303', name: 'Networks'),
        ],
      );

      expect(state.availableCourses, <String>[
        'Algorithms',
        'Data Structures',
        'Networks',
      ]);
    });
  });
}
