import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_verse/bloc/roster/roster_cubit.dart';
import 'package:edu_verse/bloc/roster/roster_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/courses/instructor_assignment_model.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

class _FakeEnrollmentService implements EnrollmentService {
  Duration teachingDelay = Duration.zero;
  Duration studentsDelay = Duration.zero;
  Duration instructorsDelay = Duration.zero;

  ServiceResult<List<TeachingCourseModel>> teachingResult =
      ServiceResult<List<TeachingCourseModel>>.success(<TeachingCourseModel>[
        TeachingCourseModel.fromJson(<String, dynamic>{
          'sectionId': 10,
          'courseId': 20,
          'course': <String, dynamic>{
            'id': 20,
            'departmentId': 1,
            'code': 'CS401',
            'name': 'Compiler Design',
            'credits': 3,
            'level': 'senior',
            'status': 'active',
          },
          'section': <String, dynamic>{
            'id': 10,
            'courseId': 20,
            'semesterId': 2,
            'sectionNumber': 'A1',
            'maxCapacity': 40,
            'currentEnrollment': 2,
            'status': 'active',
          },
          'semester': <String, dynamic>{
            'id': 2,
            'name': 'Spring 2026',
            'term': 'spring',
            'year': 2026,
          },
        }),
      ]);

  ServiceResult<List<SectionStudentModel>> sectionStudentsResult =
      ServiceResult<List<SectionStudentModel>>.success(<SectionStudentModel>[
        SectionStudentModel.fromJson(<String, dynamic>{
          'userId': 2,
          'status': 'completed',
          'enrollmentDate': '2026-02-01T00:00:00Z',
          'user': <String, dynamic>{
            'userId': 2,
            'fullName': 'Yara Hassan',
            'email': 'yara@eduverse.test',
          },
        }),
        SectionStudentModel.fromJson(<String, dynamic>{
          'userId': 1,
          'status': 'enrolled',
          'enrollmentDate': '2026-01-10T00:00:00Z',
          'user': <String, dynamic>{
            'userId': 1,
            'fullName': 'Ahmed Adel',
            'email': 'ahmed@eduverse.test',
          },
        }),
      ]);

  ServiceResult<List<InstructorAssignmentModel>> sectionInstructorsResult =
      ServiceResult<List<InstructorAssignmentModel>>.success(
        <InstructorAssignmentModel>[
          InstructorAssignmentModel.fromJson(<String, dynamic>{
            'id': 1,
            'sectionId': 10,
            'userId': 99,
            'role': 'primary',
            'firstName': 'Tarek',
            'lastName': 'Mahmoud',
            'email': 'tarek@eduverse.test',
          }),
        ],
      );

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    if (teachingDelay > Duration.zero) {
      await Future<void>.delayed(teachingDelay);
    }
    return teachingResult;
  }

  @override
  Future<ServiceResult<List<SectionStudentModel>>> getSectionStudentsLite(
    dynamic sectionId,
  ) async {
    if (studentsDelay > Duration.zero) {
      await Future<void>.delayed(studentsDelay);
    }
    return sectionStudentsResult;
  }

  @override
  Future<ServiceResult<List<InstructorAssignmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) async {
    if (instructorsDelay > Duration.zero) {
      await Future<void>.delayed(instructorsDelay);
    }
    return sectionInstructorsResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RosterCubit', () {
    late _FakeEnrollmentService fakeEnrollmentService;
    late RosterCubit cubit;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      fakeEnrollmentService = _FakeEnrollmentService();
      cubit = RosterCubit(enrollmentService: fakeEnrollmentService);
    });

    tearDown(() async {
      await cubit.close();
    });

    test(
      'loadCourses auto-selects a section and resolves instructor info',
      () async {
        await cubit.loadCourses();

        expect(cubit.state.coursesStatus, RosterStatus.loaded);
        expect(cubit.state.selectedSectionId, 10);
        expect(cubit.state.studentsStatus, RosterStatus.loaded);
        expect(cubit.state.students.first.displayName, 'Yara Hassan');
        expect(cubit.state.instructorName, 'Tarek Mahmoud');
        expect(cubit.state.instructorEmail, 'tarek@eduverse.test');
      },
    );

    test(
      'filteredStudents searches identity fields and sorts by status when selected',
      () async {
        await cubit.loadCourses();
        cubit.setSearchQuery('ahmed');
        expect(cubit.state.filteredStudents.length, 1);
        expect(cubit.state.filteredStudents.first.displayName, 'Ahmed Adel');

        cubit.setSearchQuery('');
        cubit.setSortField(RosterSortField.status);
        expect(cubit.state.sortField, RosterSortField.status);
        expect(cubit.state.filteredStudents.first.status, 'completed');
      },
    );

    test('updateNote persists notes by section and student', () async {
      await cubit.loadCourses();
      await cubit.updateNote(userId: 1, note: 'Needs follow-up on attendance.');

      expect(cubit.state.noteForStudent(1), 'Needs follow-up on attendance.');

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('roster_notes_v1');
      expect(raw, isNotNull);
      expect(raw, contains('10:1'));
    });

    test('surfaces errors when course loading fails', () async {
      fakeEnrollmentService
          .teachingResult = ServiceResult<List<TeachingCourseModel>>.failure(
        const ServiceError(type: ServiceErrorType.network, message: 'Offline'),
      );

      await cubit.loadCourses();

      expect(cubit.state.coursesStatus, RosterStatus.error);
      expect(cubit.state.errorMessage, contains('Offline'));
    });

    test(
      'does not emit after close while async loads are still running',
      () async {
        fakeEnrollmentService.teachingDelay = const Duration(milliseconds: 10);
        fakeEnrollmentService.studentsDelay = const Duration(milliseconds: 10);
        fakeEnrollmentService.instructorsDelay = const Duration(
          milliseconds: 10,
        );

        final future = cubit.loadCourses();
        await cubit.close();

        await expectLater(future, completes);
      },
    );
  });
}
