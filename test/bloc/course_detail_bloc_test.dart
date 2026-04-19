import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_event.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/courses/instructor_assignment_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/materials/announcement_model.dart';
import 'package:edu_verse/models/student/public_profile_model.dart';
import 'package:edu_verse/models/ta/ta_assignment_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
import 'package:edu_verse/services/api/public_profile_service.dart';

class _FakeCourseService extends CourseService {
  final List<CourseStructureModel> structure;
  final bool throwsError;

  _FakeCourseService({required this.structure, this.throwsError = false})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseStructureModel>> getCourseStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    if (throwsError) {
      throw Exception('structure failed');
    }
    return structure;
  }
}

class _FakeMaterialService extends MaterialService {
  final List<CourseMaterialModel> materials;
  final bool throwsError;

  _FakeMaterialService({required this.materials, this.throwsError = false})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    if (throwsError) {
      throw Exception('materials failed');
    }

    if (weekNumber == null) {
      return materials;
    }

    return materials.where((m) => m.weekNumber == weekNumber).toList();
  }
}

class _FakeCommunicationService extends CommunicationService {
  final List<AnnouncementModel> announcements;

  _FakeCommunicationService({required this.announcements})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByCourseId(
    dynamic courseId,
  ) async {
    return announcements;
  }
}

class _FakeEnrollmentService extends EnrollmentService {
  final List<InstructorAssignmentModel> instructors;
  final List<TAAssignmentModel> tas;

  _FakeEnrollmentService({required this.instructors, required this.tas})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<InstructorAssignmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<InstructorAssignmentModel>>.success(instructors);
  }

  @override
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<TAAssignmentModel>>.success(tas);
  }
}

class _FakePublicProfileService extends PublicProfileService {
  final PublicProfileModel profile;

  _FakePublicProfileService({required this.profile})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<PublicProfileModel> getPublicProfile(dynamic userId) async {
    return profile;
  }
}

class _FakeOfficeHoursService extends OfficeHoursService {
  final List<OfficeHourSlotModel> slots;
  final List<OfficeHourAppointmentModel> appointments;

  _FakeOfficeHoursService({required this.slots, required this.appointments})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<PaginatedResult<OfficeHourSlotModel>> getSlots({
    int page = 1,
    int limit = 10,
    int? instructorId,
    String? dayOfWeek,
  }) async {
    return PaginatedResult<OfficeHourSlotModel>(
      items: slots,
      meta: const PaginationMeta(),
    );
  }

  @override
  Future<List<OfficeHourAppointmentModel>> getMyAppointments() async {
    return appointments;
  }

  @override
  Future<OfficeHourAppointmentModel> bookAppointment({
    required int slotId,
    required String appointmentDate,
    String? topic,
    String? notes,
  }) async {
    return OfficeHourAppointmentModel(
      appointmentId: 99,
      studentName: 'Student',
      topic: topic ?? 'No topic provided',
      appointmentDate: DateTime.tryParse(appointmentDate),
      status: 'booked',
    );
  }
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  group('CourseDetailBloc', () {
    test('loads structure and materials and computes bundles', () async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(
          structure: <CourseStructureModel>[
            CourseStructureModel(
              organizationId: 1,
              courseId: '1',
              materialId: 'm1',
              organizationType: 'video',
              title: 'Week 1 - Intro Video',
              weekNumber: 1,
              orderIndex: 0,
            ),
            CourseStructureModel(
              organizationId: 2,
              courseId: '1',
              materialId: 'm2',
              organizationType: 'document',
              title: 'Week 1 - Intro Slides',
              weekNumber: 1,
              orderIndex: 1,
            ),
          ],
        ),
        materialService: _FakeMaterialService(
          materials: <CourseMaterialModel>[
            CourseMaterialModel(
              materialId: 'm1',
              courseId: '1',
              materialType: 'video',
              title: 'Week 1 - Intro Video',
              weekNumber: 1,
              isPublished: true,
              createdAt: DateTime(2026, 1, 1),
            ),
            CourseMaterialModel(
              materialId: 'm2',
              courseId: '1',
              materialType: 'document',
              title: 'Week 1 - Intro Slides',
              weekNumber: 1,
              isPublished: true,
              createdAt: DateTime(2026, 1, 1),
            ),
          ],
        ),
      );

      bloc.add(const LoadCourseDetail(courseId: 1, initialTabIndex: 2));
      await _flush();
      await _flush();

      expect(bloc.state.selectedTabIndex, 2);
      expect(bloc.state.structure.length, 2);
      expect(bloc.state.materials.length, 2);
      expect(bloc.state.bundles.length, 1);
      expect(bloc.state.error, isNull);

      await bloc.close();
    });

    test('expand week and switch tab update state', () async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(
          structure: const <CourseStructureModel>[],
        ),
        materialService: _FakeMaterialService(
          materials: const <CourseMaterialModel>[],
        ),
      );

      bloc.add(const ExpandWeek(weekIndex: 3));
      await _flush();
      expect(bloc.state.selectedWeekIndex, 3);

      bloc.add(const SwitchTab(tabIndex: 1));
      await _flush();
      expect(bloc.state.selectedTabIndex, 1);

      await bloc.close();
    });

    test('error from service is surfaced in state', () async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(
          structure: const <CourseStructureModel>[],
          throwsError: true,
        ),
        materialService: _FakeMaterialService(
          materials: const <CourseMaterialModel>[],
          throwsError: true,
        ),
      );

      bloc.add(const LoadCourseDetail(courseId: 7));
      await _flush();
      await _flush();

      expect(bloc.state.error, isNotNull);
      expect(bloc.state.isLoadingStructure, isFalse);
      expect(bloc.state.isLoadingMaterials, isFalse);

      await bloc.close();
    });

    test(
      'loads announcements and section staff when sectionId is provided',
      () async {
        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
          ),
          communicationService: _FakeCommunicationService(
            announcements: <AnnouncementModel>[
              AnnouncementModel(
                id: 'a1',
                courseId: '1',
                title: 'Exam update',
                content: 'Exam moved to next week',
                createdBy: 2,
                priority: 'high',
                publishedAt: DateTime(2026, 4, 1),
                createdAt: DateTime(2026, 4, 1),
                updatedAt: DateTime(2026, 4, 1),
              ),
            ],
          ),
          enrollmentService: _FakeEnrollmentService(
            instructors: const <InstructorAssignmentModel>[
              InstructorAssignmentModel(
                id: 1,
                sectionId: 2,
                userId: 7,
                role: 'primary',
                firstName: 'Lina',
                lastName: 'Ali',
                email: 'lina@eduverse.test',
              ),
            ],
            tas: <TAAssignmentModel>[
              TAAssignmentModel(
                id: 1,
                sectionId: 2,
                userId: 8,
                assignedAt: DateTime(2026, 4, 1),
                firstName: 'Omar',
                lastName: 'Samir',
                email: 'omar@eduverse.test',
              ),
            ],
          ),
        );

        bloc.add(const LoadCourseDetail(courseId: 1, sectionId: 2));
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state.announcements.length, 1);
        expect(bloc.state.instructors.length, 1);
        expect(bloc.state.teachingAssistants.length, 1);

        await bloc.close();
      },
    );

    test(
      'loads instructor profile and books office-hour appointment',
      () async {
        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
          ),
          publicProfileService: _FakePublicProfileService(
            profile: const PublicProfileModel(
              userId: 7,
              firstName: 'Lina',
              lastName: 'Ali',
              email: 'lina@eduverse.test',
            ),
          ),
          officeHoursService: _FakeOfficeHoursService(
            slots: const <OfficeHourSlotModel>[
              OfficeHourSlotModel(
                slotId: 5,
                instructorId: 7,
                dayOfWeek: 'monday',
                startTime: '10:00',
                endTime: '11:00',
                location: 'C305',
                mode: 'in_person',
                maxAppointments: 4,
                currentAppointments: 1,
                isActive: true,
                notes: null,
              ),
            ],
            appointments: const <OfficeHourAppointmentModel>[
              OfficeHourAppointmentModel(
                appointmentId: 42,
                studentName: 'Student',
                topic: 'Project',
                appointmentDate: null,
                status: 'pending',
              ),
            ],
          ),
        );

        bloc.add(const LoadInstructorProfile(userId: 7));
        await _flush();
        await _flush();

        expect(bloc.state.selectedProfile, isNotNull);
        expect(bloc.state.officeHourSlots, isNotEmpty);

        bloc.add(
          const BookOfficeHourAppointment(
            slotId: 5,
            instructorId: 7,
            appointmentDate: '2026-04-22',
            topic: 'Capstone guidance',
          ),
        );
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state.isBookingAppointment, isFalse);
        expect(bloc.state.bookingMessage, isNotNull);
        expect(bloc.state.appointments, isNotEmpty);

        await bloc.close();
      },
    );
  });
}
