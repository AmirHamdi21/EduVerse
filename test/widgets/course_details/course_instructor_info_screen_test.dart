import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_event.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/courses/instructor_assignment_model.dart';
import 'package:edu_verse/models/materials/announcement_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/student/public_profile_model.dart';
import 'package:edu_verse/models/ta/ta_assignment_model.dart';
import 'package:edu_verse/screens/student/course_instructor_info_screen.dart';
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
  }) async {
    return const <CourseMaterialModel>[];
  }
}

class _StubEnrollmentService extends EnrollmentService {
  _StubEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<InstructorAssignmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<InstructorAssignmentModel>>.success(
      const <InstructorAssignmentModel>[
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
    );
  }

  @override
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<TAAssignmentModel>>.success(<TAAssignmentModel>[
      TAAssignmentModel(
        id: 2,
        sectionId: 11,
        userId: 9,
        assignedAt: DateTime(2026, 4, 1),
        firstName: 'Omar',
        lastName: 'Samir',
        email: 'omar@eduverse.test',
      ),
    ]);
  }
}

class _StubCommunicationService extends CommunicationService {
  _StubCommunicationService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByCourseId(
    dynamic courseId,
  ) async {
    return const <AnnouncementModel>[];
  }
}

class _StubPublicProfileService extends PublicProfileService {
  _StubPublicProfileService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<PublicProfileModel> getPublicProfile(dynamic userId) async {
    return const PublicProfileModel(
      userId: 7,
      firstName: 'Lina',
      lastName: 'Ali',
      email: 'lina@eduverse.test',
      role: 'Instructor',
      officeLocation: 'C-305',
      bio: 'Distributed systems and operating systems.',
    );
  }
}

class _SpyOfficeHoursService extends OfficeHoursService {
  final List<OfficeHourSlotModel> slots;
  final List<OfficeHourAppointmentModel> _appointments;

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
  }) async {
    return PaginatedResult<OfficeHourSlotModel>(
      items: slots,
      meta: const PaginationMeta(page: 1, limit: 10, total: 1, totalPages: 1),
    );
  }

  @override
  Future<List<OfficeHourAppointmentModel>> getMyAppointments() async {
    return List<OfficeHourAppointmentModel>.from(_appointments);
  }

  @override
  Future<OfficeHourAppointmentModel> bookAppointment({
    required int slotId,
    required String appointmentDate,
    String? topic,
    String? notes,
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

CoursesBloc _buildCoursesBloc(OfficeHoursService officeHoursService) {
  return CoursesBloc(
    courseService: _StubCourseService(),
    enrollmentService: _StubEnrollmentService(),
    materialService: _StubMaterialService(),
    communicationService: _StubCommunicationService(),
    publicProfileService: _StubPublicProfileService(),
    officeHoursService: officeHoursService,
  );
}

Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets(
    'renders profile slots and appointments',
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
        appointments: const <OfficeHourAppointmentModel>[
          OfficeHourAppointmentModel(
            appointmentId: 77,
            studentName: 'A Student',
            topic: 'Capstone Review',
            appointmentDate: null,
            status: 'pending',
          ),
        ],
      );

      final coursesBloc = _buildCoursesBloc(officeHoursService);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CoursesBloc>.value(
            value: coursesBloc,
            child: const CourseInstructorInfoScreen(
              instructorId: 7,
              instructorName: 'Lina Ali',
              sectionId: 11,
              courseId: 101,
            ),
          ),
        ),
      );
      await _pumpUi(tester);

      expect(find.text('Instructor Info & Booking'), findsOneWidget);
      expect(find.text('Lina Ali'), findsWidgets);
      expect(find.text('Office Hour Slots'), findsOneWidget);
      expect(find.textContaining('10:00 - 11:00'), findsOneWidget);
      expect(find.text('My Appointments'), findsOneWidget);
      expect(find.text('Capstone Review'), findsOneWidget);

      coursesBloc.close();
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  testWidgets(
    'books appointment through dialog',
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

      final coursesBloc = _buildCoursesBloc(officeHoursService);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CoursesBloc>.value(
            value: coursesBloc,
            child: const CourseInstructorInfoScreen(
              instructorId: 7,
              instructorName: 'Lina Ali',
              sectionId: 11,
              courseId: 101,
            ),
          ),
        ),
      );
      await _pumpUi(tester);

      final detailBloc = BlocProvider.of<CourseDetailBloc>(
        tester.element(find.byType(CustomScrollView)),
      );
      detailBloc
        ..add(const LoadOfficeHourSlots(instructorId: 7))
        ..add(
          const BookOfficeHourAppointment(
            slotId: 5,
            appointmentDate: '2026-04-20',
            instructorId: 7,
            topic: 'Capstone guidance',
            notes: 'Need feedback',
          ),
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
