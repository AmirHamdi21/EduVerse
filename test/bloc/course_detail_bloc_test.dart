import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_event.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/courses/instructor_assignment_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/materials/announcement_model.dart';
import 'package:edu_verse/models/student/public_profile_model.dart';
import 'package:edu_verse/models/ta/ta_assignment_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
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
    CancelToken? cancelToken,
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
    CancelToken? cancelToken,
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

class _FakeAssignmentService extends AssignmentService {
  final List<AssignmentModel> assignments;
  final Map<int, AssignmentSubmissionModel?> submissionsByAssignmentId;
  final bool failGetAll;
  final bool failGetMySubmission;

  _FakeAssignmentService({
    this.assignments = const <AssignmentModel>[],
    this.submissionsByAssignmentId = const <int, AssignmentSubmissionModel?>{},
    this.failGetAll = false,
    this.failGetMySubmission = false,
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
    CancelToken? cancelToken,
  }) async {
    if (failGetAll) {
      return ServiceResult<PaginatedResponse<AssignmentModel>>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'assignments endpoint failed',
        ),
      );
    }

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
    dynamic assignmentId, {
    CancelToken? cancelToken,
  }) async {
    if (failGetMySubmission) {
      return ServiceResult<AssignmentSubmissionModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'assignment submission endpoint failed',
        ),
      );
    }

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
  final bool failGetAll;
  final bool failGetMySubmission;

  _FakeLabService({
    this.labs = const <LabModel>[],
    this.submissionsByLabId = const <int, List<LabSubmissionModel>?>{},
    this.failGetAll = false,
    this.failGetMySubmission = false,
  }) : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<LabModel>>> getAll({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
    CancelToken? cancelToken,
  }) async {
    if (failGetAll) {
      return ServiceResult<List<LabModel>>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'labs endpoint failed',
        ),
      );
    }

    final data = courseId == null
        ? labs
        : labs.where((item) => item.courseId == courseId).toList();
    return ServiceResult<List<LabModel>>.success(data);
  }

  @override
  Future<ServiceResult<List<LabSubmissionModel>>> getMySubmission(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    if (failGetMySubmission) {
      return ServiceResult<List<LabSubmissionModel>>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'lab submission endpoint failed',
        ),
      );
    }

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

  _FakeCommunicationService({required this.announcements})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByCourseId(
    dynamic courseId, {
    CancelToken? cancelToken,
  }) async {
    return announcements;
  }
}

class _FakeEnrollmentService extends EnrollmentService {
  final List<InstructorAssignmentModel> instructors;
  final List<TAAssignmentModel> tas;
  final bool failTAs;

  _FakeEnrollmentService({
    required this.instructors,
    required this.tas,
    this.failTAs = false,
  }) : super(coreApiClient: CoreApiClient.test());

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
    if (failTAs) {
      return ServiceResult<List<TAAssignmentModel>>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'tas endpoint failed',
        ),
      );
    }

    return ServiceResult<List<TAAssignmentModel>>.success(tas);
  }
}

class _FakePublicProfileService extends PublicProfileService {
  final PublicProfileModel profile;
  final bool throwsError;

  _FakePublicProfileService({required this.profile, this.throwsError = false})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<PublicProfileModel> getPublicProfile(
    dynamic userId, {
    CancelToken? cancelToken,
  }) async {
    if (throwsError) {
      throw Exception('profile failed');
    }
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
    CancelToken? cancelToken,
  }) async {
    return PaginatedResult<OfficeHourSlotModel>(
      items: slots,
      meta: const PaginationMeta(),
    );
  }

  @override
  Future<List<OfficeHourAppointmentModel>> getMyAppointments({
    CancelToken? cancelToken,
  }) async {
    return appointments;
  }

  @override
  Future<OfficeHourAppointmentModel> bookAppointment({
    required int slotId,
    required String appointmentDate,
    String? topic,
    String? notes,
    CancelToken? cancelToken,
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
    test(
      'loads structure and materials and computes bundles',
      () async {
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
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'expand week and switch tab update state',
      () async {
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
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'error from service is surfaced in state',
      () async {
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
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

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
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'keeps instructor data when TA fetch fails for section staff',
      () async {
        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
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
            tas: const <TAAssignmentModel>[],
            failTAs: true,
          ),
        );

        bloc.add(const LoadSectionStaff(sectionId: 2));
        await _flush();
        await _flush();

        expect(bloc.state.instructors.length, 1);
        expect(bloc.state.instructors.first.userId, 7);
        expect(bloc.state.teachingAssistants, isEmpty);
        expect(bloc.state.isLoadingStaff, isFalse);
        expect(bloc.state.error, isNull);

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'does not keep staff loading when sectionId is non-positive',
      () async {
        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
          ),
          enrollmentService: _FakeEnrollmentService(
            instructors: const <InstructorAssignmentModel>[],
            tas: const <TAAssignmentModel>[],
          ),
        );

        bloc.add(const LoadCourseDetail(courseId: 1, sectionId: 0));
        await _flush();
        await _flush();

        expect(bloc.state.isLoadingStaff, isFalse);
        expect(bloc.state.instructors, isEmpty);
        expect(bloc.state.teachingAssistants, isEmpty);

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
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
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'loads office-hour slots even when instructor profile fails',
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
            throwsError: true,
          ),
          officeHoursService: _FakeOfficeHoursService(
            slots: const <OfficeHourSlotModel>[
              OfficeHourSlotModel(
                slotId: 6,
                instructorId: 7,
                dayOfWeek: 'tuesday',
                startTime: '12:00',
                endTime: '13:00',
                location: 'C307',
                mode: 'in_person',
                maxAppointments: 3,
                currentAppointments: 0,
                isActive: true,
                notes: null,
              ),
            ],
            appointments: const <OfficeHourAppointmentModel>[],
          ),
        );

        bloc.add(const LoadInstructorProfile(userId: 7));
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state.selectedProfile, isNull);
        expect(bloc.state.officeHourSlots.length, 1);
        expect(bloc.state.officeHourSlots.first.instructorId, 7);
        expect(bloc.state.isLoadingOfficeHours, isFalse);

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'loads assignments and labs from dedicated services with submission snapshots',
      () async {
        final assignment = AssignmentModel(
          id: '11',
          assignmentId: 11,
          courseId: 1,
          title: 'Homework 1',
          courseName: 'Algorithms',
          courseCode: 'CS201',
          instructorName: 'Dr. Lina',
          type: AssignmentType.document,
          status: AssignmentStatus.pending,
          priority: AssignmentPriority.medium,
          dueDate: DateTime(2026, 4, 20),
          maxGrade: 100,
          createdAt: DateTime(2026, 4, 1),
        );

        final lab = LabModel(
          id: '21',
          labId: 21,
          courseId: 1,
          title: 'Lab 1',
          dueDate: DateTime(2026, 4, 18),
          maxScore: 50,
          createdAt: DateTime(2026, 4, 1),
        );

        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
          ),
          assignmentService: _FakeAssignmentService(
            assignments: <AssignmentModel>[assignment],
            submissionsByAssignmentId: <int, AssignmentSubmissionModel?>{
              11: AssignmentSubmissionModel(
                id: 501,
                assignmentId: 11,
                userId: 9,
                submissionStatus: api.SubmissionStatus.submitted,
                isLate: true,
                attemptNumber: 1,
                submittedAt: DateTime(2026, 4, 19, 8, 30),
                score: 44,
              ),
            },
          ),
          labService: _FakeLabService(
            labs: <LabModel>[lab],
            submissionsByLabId: <int, List<LabSubmissionModel>?>{
              21: <LabSubmissionModel>[
                LabSubmissionModel(
                  id: 701,
                  labId: 21,
                  userId: 9,
                  submissionStatus: api.SubmissionStatus.graded,
                  isLate: false,
                  submittedAt: DateTime(2026, 4, 18, 12, 0),
                  score: 48,
                ),
              ],
            },
          ),
        );

        bloc.add(const LoadCourseDetail(courseId: 1));
        await _flush();
        await _flush();
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state.assignments.length, 1);
        expect(bloc.state.labs.length, 1);
        expect(bloc.state.usedAssignmentsMaterialsFallback, isFalse);
        expect(bloc.state.usedLabsMaterialsFallback, isFalse);
        expect(bloc.state.assignmentSubmissions[11]?.isLate, isTrue);
        expect(bloc.state.assignmentSubmissions[11]?.score, 44);
        expect(bloc.state.labSubmissions[21]?.score, 48);

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'falls back to materials for assignments and labs when primary endpoints return empty',
      () async {
        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: <CourseMaterialModel>[
              CourseMaterialModel(
                materialId: '501',
                courseId: '1',
                materialType: 'assignment',
                title: 'Fallback Assignment',
                description: 'From materials endpoint',
                isPublished: true,
                createdAt: DateTime(2026, 4, 1),
              ),
              CourseMaterialModel(
                materialId: '601',
                courseId: '1',
                materialType: 'lab',
                title: 'Fallback Lab',
                description: 'From materials endpoint',
                isPublished: true,
                createdAt: DateTime(2026, 4, 1),
              ),
              CourseMaterialModel(
                materialId: '701',
                courseId: '1',
                materialType: 'video',
                title: 'Regular Video',
                isPublished: true,
                createdAt: DateTime(2026, 4, 1),
              ),
            ],
          ),
          assignmentService: _FakeAssignmentService(
            assignments: const <AssignmentModel>[],
          ),
          labService: _FakeLabService(labs: const <LabModel>[]),
        );

        bloc.add(const LoadCourseDetail(courseId: 1));
        await _flush();
        await _flush();
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state.usedAssignmentsMaterialsFallback, isTrue);
        expect(bloc.state.usedLabsMaterialsFallback, isTrue);
        expect(bloc.state.assignments.length, 1);
        expect(bloc.state.assignments.first.title, 'Fallback Assignment');
        expect(bloc.state.labs.length, 1);
        expect(bloc.state.labs.first.title, 'Fallback Lab');

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'falls back to materials when assignments/labs endpoints fail',
      () async {
        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: <CourseMaterialModel>[
              CourseMaterialModel(
                materialId: '801',
                courseId: '1',
                materialType: 'assignment',
                title: 'Fallback Assignment on Error',
                isPublished: true,
                createdAt: DateTime(2026, 4, 1),
              ),
              CourseMaterialModel(
                materialId: '901',
                courseId: '1',
                materialType: 'lab',
                title: 'Fallback Lab on Error',
                isPublished: true,
                createdAt: DateTime(2026, 4, 1),
              ),
            ],
          ),
          assignmentService: _FakeAssignmentService(failGetAll: true),
          labService: _FakeLabService(failGetAll: true),
        );

        bloc.add(const LoadCourseDetail(courseId: 1));
        await _flush();
        await _flush();
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state.usedAssignmentsMaterialsFallback, isTrue);
        expect(bloc.state.usedLabsMaterialsFallback, isTrue);
        expect(
          bloc.state.assignments.map((item) => item.title),
          contains('Fallback Assignment on Error'),
        );
        expect(
          bloc.state.labs.map((item) => item.title),
          contains('Fallback Lab on Error'),
        );

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'keeps null submission snapshots when submission endpoints fail',
      () async {
        final assignment = AssignmentModel(
          id: '31',
          assignmentId: 31,
          courseId: 1,
          title: 'Submission Failure Assignment',
          courseName: 'Algorithms',
          courseCode: 'CS201',
          instructorName: 'Dr. Lina',
          type: AssignmentType.document,
          status: AssignmentStatus.pending,
          priority: AssignmentPriority.medium,
          dueDate: DateTime(2026, 4, 20),
          maxGrade: 100,
          createdAt: DateTime(2026, 4, 1),
        );

        final lab = LabModel(
          id: '41',
          labId: 41,
          courseId: 1,
          title: 'Submission Failure Lab',
          dueDate: DateTime(2026, 4, 18),
          maxScore: 50,
          createdAt: DateTime(2026, 4, 1),
        );

        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
          ),
          assignmentService: _FakeAssignmentService(
            assignments: <AssignmentModel>[assignment],
            failGetMySubmission: true,
          ),
          labService: _FakeLabService(
            labs: <LabModel>[lab],
            failGetMySubmission: true,
          ),
        );

        bloc.add(const LoadCourseDetail(courseId: 1));
        await _flush();
        await _flush();
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state.assignments.length, 1);
        expect(bloc.state.labs.length, 1);
        expect(bloc.state.assignmentSubmissions.containsKey(31), isTrue);
        expect(bloc.state.assignmentSubmissions[31], isNull);
        expect(bloc.state.labSubmissions.containsKey(41), isTrue);
        expect(bloc.state.labSubmissions[41], isNull);

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'stores prerequisites payload from LoadCourseDetail',
      () async {
        final bloc = CourseDetailBloc(
          courseService: _FakeCourseService(
            structure: const <CourseStructureModel>[],
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
          ),
        );

        final prerequisites = <EnrollmentPrerequisite>[
          const EnrollmentPrerequisite(
            id: 1,
            courseId: 1,
            prerequisiteCourseId: 10,
            courseCode: 'CS101',
            courseName: 'Intro to CS',
            isMandatory: true,
            studentCompleted: true,
            studentGrade: 'A',
          ),
        ];

        bloc.add(LoadCourseDetail(courseId: 1, prerequisites: prerequisites));
        await _flush();
        await _flush();

        expect(bloc.state.prerequisites.length, 1);
        expect(bloc.state.prerequisites.first.courseCode, 'CS101');
        expect(bloc.state.prerequisites.first.studentCompleted, isTrue);

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );
  });
}
