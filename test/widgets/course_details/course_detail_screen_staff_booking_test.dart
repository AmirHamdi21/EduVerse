import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/features/courses/screens/course_detail_screen.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_event.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/courses/instructor_assignment_model.dart';
import 'package:edu_verse/models/materials/announcement_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/student/public_profile_model.dart';
import 'package:edu_verse/models/ta/ta_assignment_model.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
import 'package:edu_verse/services/api/public_profile_service.dart';

class _StubCourseService extends CourseService {
  _StubCourseService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseStructureModel>> getCourseStructure(
    dynamic courseId, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    return const <CourseStructureModel>[];
  }
}

class _StubMaterialService extends MaterialService {
  _StubMaterialService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
    CancelToken? cancelToken,
  }) async {
    return const <CourseMaterialModel>[];
  }
}

class _StubEnrollmentService extends EnrollmentService {
  final List<InstructorAssignmentModel> instructors;
  final List<TAAssignmentModel> tas;

  _StubEnrollmentService({required this.instructors, required this.tas})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<InstructorAssignmentModel>>> getSectionInstructors(
    dynamic sectionId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<InstructorAssignmentModel>>.success(instructors);
  }

  @override
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<TAAssignmentModel>>.success(tas);
  }
}

class _StubCommunicationService extends CommunicationService {
  final List<AnnouncementModel> announcements;

  _StubCommunicationService({required this.announcements})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByCourseId(
    dynamic courseId, {
    CancelToken? cancelToken,
  }) async {
    return announcements;
  }
}

class _StubPublicProfileService extends PublicProfileService {
  final PublicProfileModel profile;
  int requests = 0;

  _StubPublicProfileService({required this.profile})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<PublicProfileModel> getPublicProfile(
    dynamic userId, {
    CancelToken? cancelToken,
  }) async {
    requests += 1;
    return profile;
  }
}

class _SpyOfficeHoursService extends OfficeHoursService {
  final List<OfficeHourSlotModel> slots;
  final List<OfficeHourAppointmentModel> _appointments;

  int slotLoadCalls = 0;
  int bookingCalls = 0;
  int? lastBookedSlotId;
  String? lastBookedDate;
  String? lastBookedTopic;
  String? lastBookedNotes;

  _SpyOfficeHoursService({
    required this.slots,
    List<OfficeHourAppointmentModel> appointments =
        const <OfficeHourAppointmentModel>[],
  }) : _appointments = List<OfficeHourAppointmentModel>.from(appointments),
       super(coreApiClient: CoreApiClient.test());

  @override
  Future<PaginatedResult<OfficeHourSlotModel>> getSlots({
    int page = 1,
    int limit = 10,
    int? instructorId,
    String? dayOfWeek,
    CancelToken? cancelToken,
  }) async {
    slotLoadCalls += 1;
    return PaginatedResult<OfficeHourSlotModel>(
      items: slots,
      meta: const PaginationMeta(page: 1, limit: 10, total: 1, totalPages: 1),
    );
  }

  @override
  Future<List<OfficeHourAppointmentModel>> getMyAppointments({
    CancelToken? cancelToken,
  }) async {
    return List<OfficeHourAppointmentModel>.from(_appointments);
  }

  @override
  Future<OfficeHourAppointmentModel> bookAppointment({
    required int slotId,
    required String appointmentDate,
    String? topic,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    bookingCalls += 1;
    lastBookedSlotId = slotId;
    lastBookedDate = appointmentDate;
    lastBookedTopic = topic;
    lastBookedNotes = notes;

    final booked = OfficeHourAppointmentModel(
      appointmentId: 100 + bookingCalls,
      studentName: 'Test Student',
      topic: topic?.trim().isNotEmpty == true
          ? topic!.trim()
          : 'No topic provided',
      appointmentDate: DateTime.tryParse(appointmentDate),
      status: 'booked',
    );

    _appointments.insert(0, booked);
    return booked;
  }
}

CourseEnrollmentModel _sampleEnrollment() {
  return CourseEnrollmentModel.fromJson(<String, dynamic>{
    'id': 1,
    'userId': 42,
    'sectionId': 11,
    'status': 'enrolled',
    'enrollmentDate': '2026-04-01T00:00:00.000Z',
    'course': <String, dynamic>{
      'id': 101,
      'departmentId': 1,
      'code': 'CS101',
      'name': 'Introduction to CS',
      'credits': 3,
      'level': 'beginner',
      'status': 'active',
      'departmentName': 'Computer Science',
    },
    'section': <String, dynamic>{
      'id': 11,
      'courseId': 101,
      'semesterId': 2,
      'sectionNumber': 'A',
      'maxCapacity': 35,
      'currentEnrollment': 24,
      'status': 'active',
    },
    'semester': <String, dynamic>{'id': 2, 'name': 'Spring 2026'},
  });
}

CoursesBloc _buildCoursesBloc({
  required EnrollmentService enrollmentService,
  required CommunicationService communicationService,
  required PublicProfileService publicProfileService,
  required OfficeHoursService officeHoursService,
}) {
  return CoursesBloc(
    courseService: _StubCourseService(),
    enrollmentService: enrollmentService,
    materialService: _StubMaterialService(),
    communicationService: communicationService,
    publicProfileService: publicProfileService,
    officeHoursService: officeHoursService,
  );
}

Widget _buildTestApp(CoursesBloc coursesBloc) {
  return MaterialApp(
    home: BlocProvider<CoursesBloc>.value(
      value: coursesBloc,
      child: CourseDetailScreen(
        enrollment: _sampleEnrollment(),
        initialTabIndex: 2,
      ),
    ),
  );
}

Finder _textFieldByLabel(String label) {
  return find.byWidgetPredicate((widget) {
    return widget is TextField && widget.decoration?.labelText == label;
  });
}

Finder _verticalScrollable() {
  return find.byWidgetPredicate((widget) {
    return widget is Scrollable && widget.axisDirection == AxisDirection.down;
  });
}

Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
}

void main() {
  testWidgets(
    'Staff & Booking tab loads profile and renders slots',
    (WidgetTester tester) async {
      final officeHoursService = _SpyOfficeHoursService(
        slots: const <OfficeHourSlotModel>[
          OfficeHourSlotModel(
            slotId: 5,
            instructorId: 7,
            dayOfWeek: 'monday',
            startTime: '10:00',
            endTime: '11:00',
            location: 'C-305',
            mode: 'in_person',
            maxAppointments: 4,
            currentAppointments: 1,
            isActive: true,
            notes: null,
          ),
        ],
      );

      final coursesBloc = _buildCoursesBloc(
        enrollmentService: _StubEnrollmentService(
          instructors: const <InstructorAssignmentModel>[
            InstructorAssignmentModel(
              id: 1,
              sectionId: 11,
              userId: 7,
              role: 'primary',
              firstName: 'Lina',
              lastName: 'Ali',
              email: 'lina@eduverse.test',
            ),
          ],
          tas: <TAAssignmentModel>[
            TAAssignmentModel(
              id: 2,
              sectionId: 11,
              userId: 9,
              assignedAt: DateTime(2026, 4, 1),
              firstName: 'Omar',
              lastName: 'Samir',
              email: 'omar@eduverse.test',
            ),
          ],
        ),
        communicationService: _StubCommunicationService(
          announcements: <AnnouncementModel>[
            AnnouncementModel(
              id: 'a1',
              courseId: '101',
              title: 'Exam update',
              content: 'Exam moved to next week',
              createdBy: 7,
              priority: 'high',
              publishedAt: DateTime(2026, 4, 1),
              createdAt: DateTime(2026, 4, 1),
              updatedAt: DateTime(2026, 4, 1),
            ),
          ],
        ),
        publicProfileService: _StubPublicProfileService(
          profile: const PublicProfileModel(
            userId: 7,
            firstName: 'Lina',
            lastName: 'Ali',
            email: 'lina@eduverse.test',
            officeLocation: 'C-305',
            bio: 'Distributed systems and operating systems.',
          ),
        ),
        officeHoursService: officeHoursService,
      );

      await tester.pumpWidget(_buildTestApp(coursesBloc));
      await _pumpUi(tester);

      expect(find.text('Latest Announcements'), findsOneWidget);
      expect(find.text('Exam moved to next week'), findsOneWidget);

      final viewProfileButton = find.widgetWithText(TextButton, 'View Profile');
      await _waitForWidget(tester, viewProfileButton);
      await tester.tap(viewProfileButton.first);
      await _pumpUi(tester);

      expect(find.text('Lina Ali'), findsWidgets);
      expect(find.text('Office: C-305'), findsOneWidget);

      final detailBloc = BlocProvider.of<CourseDetailBloc>(
        tester.element(find.byType(TabBarView)),
      );
      detailBloc.add(const LoadOfficeHourSlots(instructorId: 7));
      await _pumpUi(tester);

      expect(officeHoursService.slotLoadCalls, greaterThan(0));

      await tester.scrollUntilVisible(
        find.text('Office Hour Slots'),
        300,
        scrollable: _verticalScrollable().first,
      );
      await _pumpUi(tester);

      expect(find.textContaining('1/4'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Book'), findsOneWidget);

      coursesBloc.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  testWidgets(
    'Staff & Booking tab books slot from UI dialog flow',
    (WidgetTester tester) async {
      final officeHoursService = _SpyOfficeHoursService(
        slots: const <OfficeHourSlotModel>[
          OfficeHourSlotModel(
            slotId: 5,
            instructorId: 7,
            dayOfWeek: 'monday',
            startTime: '10:00',
            endTime: '11:00',
            location: 'C-305',
            mode: 'in_person',
            maxAppointments: 4,
            currentAppointments: 1,
            isActive: true,
            notes: null,
          ),
        ],
      );

      final publicProfileService = _StubPublicProfileService(
        profile: const PublicProfileModel(
          userId: 7,
          firstName: 'Lina',
          lastName: 'Ali',
          email: 'lina@eduverse.test',
        ),
      );

      final coursesBloc = _buildCoursesBloc(
        enrollmentService: _StubEnrollmentService(
          instructors: const <InstructorAssignmentModel>[
            InstructorAssignmentModel(
              id: 1,
              sectionId: 11,
              userId: 7,
              role: 'primary',
              firstName: 'Lina',
              lastName: 'Ali',
              email: 'lina@eduverse.test',
            ),
          ],
          tas: const <TAAssignmentModel>[],
        ),
        communicationService: _StubCommunicationService(
          announcements: const <AnnouncementModel>[],
        ),
        publicProfileService: publicProfileService,
        officeHoursService: officeHoursService,
      );

      await tester.pumpWidget(_buildTestApp(coursesBloc));
      await _pumpUi(tester);

      final viewProfileButton = find.widgetWithText(TextButton, 'View Profile');
      await _waitForWidget(tester, viewProfileButton);
      await tester.tap(viewProfileButton.first);
      await _pumpUi(tester);

      expect(publicProfileService.requests, 1);

      final detailBloc = BlocProvider.of<CourseDetailBloc>(
        tester.element(find.byType(TabBarView)),
      );
      detailBloc.add(const LoadOfficeHourSlots(instructorId: 7));
      await _pumpUi(tester);

      expect(officeHoursService.slotLoadCalls, greaterThan(0));

      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Book'),
        300,
        scrollable: _verticalScrollable().first,
      );
      await _pumpUi(tester);

      final bookButton = find.widgetWithText(FilledButton, 'Book');
      await _waitForWidget(tester, bookButton);
      await tester.tap(bookButton.first);
      await _pumpUi(tester);
      await tester.pumpAndSettle();

      expect(find.text('Select date'), findsOneWidget);

      await tester.tap(find.text('Continue').last);
      await _pumpUi(tester);
      await tester.pumpAndSettle();

      expect(find.text('Book Appointment'), findsOneWidget);

      await tester.enterText(
        _textFieldByLabel('Topic (optional)'),
        'Capstone guidance',
      );
      await tester.enterText(
        _textFieldByLabel('Notes (optional)'),
        'Need feedback',
      );

      await tester.tap(
        find.text('Book').last,
      );
      await _pumpUi(tester);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Capstone guidance'),
        250,
        scrollable: _verticalScrollable().first,
      );
      await _pumpUi(tester);

      expect(officeHoursService.bookingCalls, 1);
      expect(officeHoursService.lastBookedSlotId, 5);
      expect(officeHoursService.lastBookedTopic, 'Capstone guidance');
      expect(officeHoursService.lastBookedNotes, 'Need feedback');
      expect(find.text('Capstone guidance'), findsOneWidget);

      coursesBloc.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
