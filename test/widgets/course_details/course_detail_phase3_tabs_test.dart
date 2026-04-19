import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_event.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/enums/lab_enums.dart' as lab_api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/models/materials/announcement_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/widgets/student/course_details/announcements_tab_content.dart';
import 'package:edu_verse/widgets/student/course_details/assignments_tab_content.dart';
import 'package:edu_verse/widgets/student/course_details/labs_tab_content.dart';
import 'package:edu_verse/widgets/student/course_details/prerequisites_tab_content.dart';

class _FakeCourseService extends CourseService {
  _FakeCourseService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseStructureModel>> getCourseStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    return const <CourseStructureModel>[];
  }
}

class _FakeMaterialService extends MaterialService {
  _FakeMaterialService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    return const <CourseMaterialModel>[];
  }
}

class _FakeAssignmentService extends AssignmentService {
  final List<AssignmentModel> assignments;
  final Map<int, AssignmentSubmissionModel?> submissionsByAssignmentId;

  _FakeAssignmentService({
    this.assignments = const <AssignmentModel>[],
    this.submissionsByAssignmentId = const <int, AssignmentSubmissionModel?>{},
  }) : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    api.AssignmentStatus? status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    final data = courseId == null
        ? assignments
        : assignments.where((item) => item.courseId == courseId).toList();

    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      PaginatedResponse<AssignmentModel>(
        data: data,
        total: data.length,
        page: 1,
        limit: data.isEmpty ? 1 : data.length,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<AssignmentSubmissionModel>> getMySubmission(
    dynamic assignmentId,
  ) async {
    final id = assignmentId is int
        ? assignmentId
        : int.tryParse(assignmentId.toString()) ?? 0;

    final submission = submissionsByAssignmentId[id];
    if (submission == null) {
      return ServiceResult<AssignmentSubmissionModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'submission not found',
        ),
      );
    }

    return ServiceResult<AssignmentSubmissionModel>.success(submission);
  }
}

class _FakeLabService extends LabService {
  final List<LabModel> labs;
  final Map<int, List<LabSubmissionModel>?> submissionsByLabId;

  _FakeLabService({
    this.labs = const <LabModel>[],
    this.submissionsByLabId = const <int, List<LabSubmissionModel>?>{},
  }) : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<LabModel>>> getAll({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final data = courseId == null
        ? labs
        : labs.where((item) => item.courseId == courseId).toList();

    return ServiceResult<List<LabModel>>.success(data);
  }

  @override
  Future<ServiceResult<List<LabSubmissionModel>>> getMySubmission(
    dynamic labId,
  ) async {
    final id = labId is int ? labId : int.tryParse(labId.toString()) ?? 0;
    final submissions = submissionsByLabId[id];
    if (submissions == null) {
      return ServiceResult<List<LabSubmissionModel>>.success(
        const <LabSubmissionModel>[],
      );
    }

    return ServiceResult<List<LabSubmissionModel>>.success(submissions);
  }
}

class _FakeCommunicationService extends CommunicationService {
  final List<AnnouncementModel> announcements;

  _FakeCommunicationService({this.announcements = const <AnnouncementModel>[]})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByCourseId(
    dynamic courseId,
  ) async {
    return announcements;
  }
}

Future<void> _pumpFrames(WidgetTester tester, {int cycles = 8}) async {
  for (var i = 0; i < cycles; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  testWidgets(
    'AssignmentsTabContent card taps navigate to assignments with course prefilter',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        assignmentService: _FakeAssignmentService(
          assignments: <AssignmentModel>[
            AssignmentModel(
              id: '99',
              assignmentId: 99,
              courseId: 1,
              title: 'Navigation Assignment',
              description: 'Navigate from card action',
              courseName: 'Algorithms',
              courseCode: 'CS201',
              instructorName: 'Dr. Lina',
              type: AssignmentType.document,
              status: AssignmentStatus.pending,
              priority: AssignmentPriority.medium,
              dueDate: DateTime(2026, 4, 28),
              maxGrade: 100,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
        ),
      );

      Map<String, dynamic>? capturedPayload;

      final router = GoRouter(
        initialLocation: '/details',
        routes: <RouteBase>[
          GoRoute(
            path: '/details',
            builder: (context, state) {
              return BlocProvider<CourseDetailBloc>.value(
                value: bloc,
                child: const Scaffold(
                  body: AssignmentsTabContent(isDark: false, courseId: 1),
                ),
              );
            },
          ),
          GoRoute(
            path: '/assignments',
            builder: (context, state) {
              capturedPayload = (state.extra as Map<dynamic, dynamic>?)
                  ?.cast<String, dynamic>();
              return const Scaffold(
                body: Center(child: Text('Assignments Route Hit')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      bloc.add(const LoadAssignments(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      await tester.tap(find.text('View').first);
      await _pumpFrames(tester, cycles: 8);

      expect(find.text('Assignments Route Hit'), findsOneWidget);
      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['courseId'], 1);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'LabsTabContent card taps navigate to labs with course prefilter',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        labService: _FakeLabService(
          labs: <LabModel>[
            LabModel(
              id: '77',
              labId: 77,
              courseId: 1,
              title: 'Navigation Lab',
              description: 'Navigate from card action',
              dueDate: DateTime(2026, 4, 30),
              maxScore: 50,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
        ),
      );

      Map<String, dynamic>? capturedPayload;

      final router = GoRouter(
        initialLocation: '/details',
        routes: <RouteBase>[
          GoRoute(
            path: '/details',
            builder: (context, state) {
              return BlocProvider<CourseDetailBloc>.value(
                value: bloc,
                child: const Scaffold(
                  body: LabsTabContent(isDark: false, courseId: 1),
                ),
              );
            },
          ),
          GoRoute(
            path: '/labs',
            builder: (context, state) {
              capturedPayload = (state.extra as Map<dynamic, dynamic>?)
                  ?.cast<String, dynamic>();
              return const Scaffold(
                body: Center(child: Text('Labs Route Hit')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      bloc.add(const LoadLabs(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      await tester.tap(find.text('Submit Work').first);
      await _pumpFrames(tester, cycles: 8);

      expect(find.text('Labs Route Hit'), findsOneWidget);
      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['courseId'], 1);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'LabsTabContent renders live lab data from CourseDetailBloc',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        labService: _FakeLabService(
          labs: <LabModel>[
            LabModel(
              id: '21',
              labId: 21,
              courseId: 1,
              title: 'Live Lab 1',
              description: 'From labs endpoint',
              dueDate: DateTime(2026, 4, 18),
              maxScore: 50,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
          submissionsByLabId: <int, List<LabSubmissionModel>?>{
            21: <LabSubmissionModel>[
              LabSubmissionModel(
                id: 301,
                labId: 21,
                userId: 5,
                submissionStatus: api.SubmissionStatus.graded,
                isLate: false,
                submittedAt: DateTime(2026, 4, 17),
                score: 45,
              ),
            ],
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: LabsTabContent(isDark: false, courseId: 1),
            ),
          ),
        ),
      );

      bloc.add(const LoadLabs(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      expect(find.text('Live Lab 1'), findsOneWidget);
      expect(find.text('Graded (90%)'), findsOneWidget);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'AssignmentsTabContent renders live assignment data from CourseDetailBloc',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        assignmentService: _FakeAssignmentService(
          assignments: <AssignmentModel>[
            AssignmentModel(
              id: '11',
              assignmentId: 11,
              courseId: 1,
              title: 'Live Assignment 1',
              description: 'From assignments endpoint',
              courseName: 'Algorithms',
              courseCode: 'CS201',
              instructorName: 'Dr. Lina',
              type: AssignmentType.document,
              status: AssignmentStatus.pending,
              priority: AssignmentPriority.medium,
              dueDate: DateTime(2026, 4, 20),
              maxGrade: 100,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
          submissionsByAssignmentId: <int, AssignmentSubmissionModel?>{
            11: AssignmentSubmissionModel(
              id: 401,
              assignmentId: 11,
              userId: 5,
              submissionStatus: api.SubmissionStatus.submitted,
              isLate: false,
              attemptNumber: 1,
              submittedAt: DateTime(2026, 4, 19),
            ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: AssignmentsTabContent(isDark: false, courseId: 1),
            ),
          ),
        ),
      );

      bloc.add(const LoadAssignments(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      expect(find.text('Live Assignment 1'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
      expect(find.text('Feedback'), findsNothing);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'AssignmentsTabContent keeps overdue without submission actionable',
    (tester) async {
      final dueDate = DateTime.now().subtract(const Duration(days: 2));
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        assignmentService: _FakeAssignmentService(
          assignments: <AssignmentModel>[
            AssignmentModel(
              id: '12',
              assignmentId: 12,
              courseId: 1,
              title: 'Overdue Assignment',
              description: 'Needs submission',
              courseName: 'Algorithms',
              courseCode: 'CS201',
              instructorName: 'Dr. Lina',
              type: AssignmentType.document,
              status: AssignmentStatus.pending,
              priority: AssignmentPriority.high,
              dueDate: dueDate,
              maxGrade: 100,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: AssignmentsTabContent(isDark: false, courseId: 1),
            ),
          ),
        ),
      );

      bloc.add(const LoadAssignments(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      expect(find.text('Overdue Assignment'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Submitted'), findsNothing);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'AssignmentsTabContent treats returned submission as actionable',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        assignmentService: _FakeAssignmentService(
          assignments: <AssignmentModel>[
            AssignmentModel(
              id: '13',
              assignmentId: 13,
              courseId: 1,
              title: 'Returned Assignment',
              description: 'Returned for corrections',
              courseName: 'Algorithms',
              courseCode: 'CS201',
              instructorName: 'Dr. Lina',
              type: AssignmentType.document,
              status: AssignmentStatus.pending,
              priority: AssignmentPriority.high,
              dueDate: DateTime(2026, 4, 23),
              maxGrade: 100,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
          submissionsByAssignmentId: <int, AssignmentSubmissionModel?>{
            13: AssignmentSubmissionModel(
              id: 402,
              assignmentId: 13,
              userId: 5,
              submissionStatus: api.SubmissionStatus.returned,
              isLate: false,
              attemptNumber: 1,
              submittedAt: DateTime(2026, 4, 19),
            ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: AssignmentsTabContent(isDark: false, courseId: 1),
            ),
          ),
        ),
      );

      bloc.add(const LoadAssignments(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      expect(find.text('Returned Assignment'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Submitted'), findsNothing);
      expect(find.text('Feedback'), findsNothing);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'AssignmentsTabContent treats unknown submission status as actionable',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        assignmentService: _FakeAssignmentService(
          assignments: <AssignmentModel>[
            AssignmentModel(
              id: '14',
              assignmentId: 14,
              courseId: 1,
              title: 'Unknown Status Assignment',
              description: 'Submission state not yet resolved',
              courseName: 'Algorithms',
              courseCode: 'CS201',
              instructorName: 'Dr. Lina',
              type: AssignmentType.document,
              status: AssignmentStatus.pending,
              priority: AssignmentPriority.high,
              dueDate: DateTime(2026, 4, 24),
              maxGrade: 100,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
          submissionsByAssignmentId: <int, AssignmentSubmissionModel?>{
            14: AssignmentSubmissionModel(
              id: 403,
              assignmentId: 14,
              userId: 5,
              submissionStatus: api.SubmissionStatus.unknown,
              isLate: false,
              attemptNumber: 1,
              submittedAt: DateTime(2026, 4, 19),
            ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: AssignmentsTabContent(isDark: false, courseId: 1),
            ),
          ),
        ),
      );

      bloc.add(const LoadAssignments(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      expect(find.text('Unknown Status Assignment'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Submitted'), findsNothing);
      expect(find.text('Feedback'), findsNothing);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'LabsTabContent keeps draft labs as not started when no submission exists',
    (tester) async {
      final dueDate = DateTime.now().subtract(const Duration(days: 3));
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        labService: _FakeLabService(
          labs: <LabModel>[
            LabModel(
              id: '22',
              labId: 22,
              courseId: 1,
              title: 'Draft Lab',
              description: 'Draft lab should stay not started',
              dueDate: dueDate,
              maxScore: 50,
              status: lab_api.LabStatus.draft,
              createdAt: DateTime(2026, 4, 1),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: LabsTabContent(isDark: false, courseId: 1),
            ),
          ),
        ),
      );

      bloc.add(const LoadLabs(courseId: 1));
      await _pumpFrames(tester, cycles: 12);

      expect(find.text('Draft Lab'), findsOneWidget);
      expect(find.text('Not Started'), findsOneWidget);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'AnnouncementsTabContent renders announcements from CourseDetailBloc',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
        communicationService: _FakeCommunicationService(
          announcements: <AnnouncementModel>[
            AnnouncementModel(
              id: 'a1',
              courseId: '1',
              title: 'Exam postponed',
              content: 'The exam has been moved to next Monday.',
              createdBy: 3,
              priority: 'high',
              publishedAt: DateTime(2026, 4, 22),
              createdAt: DateTime(2026, 4, 22),
              updatedAt: DateTime(2026, 4, 22),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: AnnouncementsTabContent(isDark: false, courseId: 1),
            ),
          ),
        ),
      );

      bloc.add(const LoadAnnouncements(courseId: 1));
      await _pumpFrames(tester, cycles: 10);

      expect(find.text('Exam postponed'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  testWidgets(
    'PrerequisitesTabContent renders enrollment prerequisite payload',
    (tester) async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(),
        materialService: _FakeMaterialService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CourseDetailBloc>.value(
            value: bloc,
            child: const Scaffold(body: PrerequisitesTabContent(isDark: false)),
          ),
        ),
      );

      bloc.add(
        const LoadPrerequisites(
          prerequisites: <EnrollmentPrerequisite>[
            EnrollmentPrerequisite(
              id: 1,
              courseId: 1,
              prerequisiteCourseId: 10,
              courseCode: 'CS101',
              courseName: 'Intro to CS',
              isMandatory: true,
              studentCompleted: true,
              studentGrade: 'A',
            ),
            EnrollmentPrerequisite(
              id: 2,
              courseId: 1,
              prerequisiteCourseId: 11,
              courseCode: 'MATH101',
              courseName: 'Calculus I',
              isMandatory: true,
              studentCompleted: false,
            ),
          ],
        ),
      );

      await _pumpFrames(tester, cycles: 6);

      expect(find.text('1 of 2 prerequisites completed'), findsOneWidget);
      expect(find.text('CS101 - Intro to CS'), findsOneWidget);
      expect(find.text('MATH101 - Calculus I'), findsOneWidget);

      bloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
