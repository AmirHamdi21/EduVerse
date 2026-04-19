import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/features/courses/bloc/course_list/course_list_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_list/course_list_event.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService({required this.result})
    : super(coreApiClient: CoreApiClient.test());

  final ServiceResult<List<CourseEnrollmentModel>> result;

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses({
    int? semester,
  }) async {
    return result;
  }
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

CourseEnrollmentModel _enrollment() {
  return CourseEnrollmentModel(
    id: '1',
    userId: 7,
    sectionId: 11,
    enrollmentStatus: EnrollmentStatus.enrolled,
    enrollmentDate: DateTime(2026, 1, 1),
    course: CourseModel(
      id: 9,
      departmentId: 1,
      code: 'CS101',
      name: 'Intro to CS',
      credits: 3,
      courseLevel: CourseLevel.freshman,
      courseStatus: CourseStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );
}

@Timeout(Duration(seconds: 30))
void main() {
  group('CourseListBloc', () {
    test('emits loading then loaded when service succeeds', () async {
      final bloc = CourseListBloc(
        enrollmentService: _FakeEnrollmentService(
          result: ServiceResult<List<CourseEnrollmentModel>>.success(
            <CourseEnrollmentModel>[_enrollment()],
          ),
        ),
      );

      bloc.add(const FetchCourses());
      await _flush();
      await _flush();

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);
      expect(bloc.state.courses.length, 1);
      expect(bloc.state.courses.first.course?.courseCode, 'CS101');

      await bloc.close();
    });

    test('emits error when service fails', () async {
      final bloc = CourseListBloc(
        enrollmentService: _FakeEnrollmentService(
          result: ServiceResult<List<CourseEnrollmentModel>>.failure(
            const ServiceError(
              type: ServiceErrorType.network,
              message: 'network down',
            ),
          ),
        ),
      );

      bloc.add(const FetchCourses());
      await _flush();
      await _flush();

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.courses, isEmpty);
      expect(bloc.state.error, contains('network down'));

      await bloc.close();
    });
  });
}
