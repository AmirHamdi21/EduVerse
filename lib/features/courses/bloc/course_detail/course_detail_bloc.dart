import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/assignments/assignment_model.dart';
import '../../../../models/assignments/assignment_submission_model.dart';
import '../../../../models/core/enrollment_model.dart';
import '../../../../services/api/course_service.dart';
import '../../../../services/api/material_service.dart';
import '../../../../services/api/enrollment_service.dart';
import '../../../../services/api/communication_service.dart';
import '../../../../services/api/assignment_service.dart';
import '../../../../services/api/lab_service.dart';
import '../../../../services/api/public_profile_service.dart';
import '../../../../services/api/office_hours_service.dart';
import '../../../../models/admin/admin_periods_models.dart';
import '../../../../models/courses/instructor_assignment_model.dart';
import '../../../../models/labs/lab_model.dart';
import '../../../../models/labs/lab_submission_model.dart';
import '../../../../models/ta/ta_assignment_model.dart';
import '../../../../models/materials/course_material_model.dart';
import '../../../../models/materials/material_bundle_model.dart';
import 'course_detail_event.dart';
import 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final CourseService _courseService;
  final MaterialService _materialService;
  final AssignmentService? _assignmentService;
  final LabService? _labService;
  final EnrollmentService? _enrollmentService;
  final CommunicationService? _communicationService;
  final PublicProfileService? _publicProfileService;
  final OfficeHoursService? _officeHoursService;

  CourseDetailBloc({
    required CourseService courseService,
    required MaterialService materialService,
    AssignmentService? assignmentService,
    LabService? labService,
    EnrollmentService? enrollmentService,
    CommunicationService? communicationService,
    PublicProfileService? publicProfileService,
    OfficeHoursService? officeHoursService,
  }) : _courseService = courseService,
       _materialService = materialService,
       _assignmentService = assignmentService,
       _labService = labService,
       _enrollmentService = enrollmentService,
       _communicationService = communicationService,
       _publicProfileService = publicProfileService,
       _officeHoursService = officeHoursService,
       super(const CourseDetailState()) {
    on<LoadCourseDetail>(_onLoadCourseDetail);
    on<LoadStructure>(_onLoadStructure);
    on<LoadMaterials>(_onLoadMaterials);
    on<LoadAssignments>(_onLoadAssignments);
    on<LoadLabs>(_onLoadLabs);
    on<LoadAssignmentSubmissions>(_onLoadAssignmentSubmissions);
    on<LoadLabSubmissions>(_onLoadLabSubmissions);
    on<LoadPrerequisites>(_onLoadPrerequisites);
    on<ExpandWeek>(_onExpandWeek);
    on<SwitchTab>(_onSwitchTab);
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<LoadSectionStaff>(_onLoadSectionStaff);
    on<LoadInstructorProfile>(_onLoadInstructorProfile);
    on<LoadOfficeHourSlots>(_onLoadOfficeHourSlots);
    on<LoadMyAppointments>(_onLoadMyAppointments);
    on<BookOfficeHourAppointment>(_onBookOfficeHourAppointment);
  }

  Future<void> _onLoadCourseDetail(
    LoadCourseDetail event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTabIndex: event.initialTabIndex,
        isLoadingStructure: true,
        isLoadingMaterials: true,
        isLoadingAssignments: true,
        isLoadingLabs: true,
        isLoadingAssignmentSubmissions: false,
        isLoadingLabSubmissions: false,
        isLoadingPrerequisites: false,
        isLoadingAnnouncements:
            event.courseId != null && _communicationService != null,
        isLoadingStaff:
            event.sectionId != null &&
            event.sectionId! > 0 &&
            _enrollmentService != null,
        usedAssignmentsMaterialsFallback: false,
        usedLabsMaterialsFallback: false,
        prerequisites: event.prerequisites ?? const <EnrollmentPrerequisite>[],
        clearError: true,
        clearBookingMessage: true,
      ),
    );

    final futures = <Future<void>>[
      _fetchStructure(event.courseId, emit),
      _fetchMaterials(event.courseId, emit),
      _fetchAssignments(event.courseId, emit),
      _fetchLabs(event.courseId, emit),
    ];

    if (event.courseId != null) {
      futures.add(_fetchAnnouncements(event.courseId, emit));
    }

    if (event.sectionId != null && event.sectionId! > 0) {
      futures.add(_fetchStaff(event.sectionId!, emit));
    }

    if (event.prerequisites != null) {
      futures.add(_fetchPrerequisitesFromPayload(event.prerequisites!, emit));
    }

    await Future.wait<void>(futures);
  }

  Future<void> _onLoadStructure(
    LoadStructure event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingStructure: true, clearError: true));
    await _fetchStructure(event.courseId, emit);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingMaterials: true, clearError: true));
    await _fetchMaterials(event.courseId, emit, weekNumber: event.weekNumber);
  }

  Future<void> _onLoadAssignments(
    LoadAssignments event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingAssignments: true,
        usedAssignmentsMaterialsFallback: false,
        clearError: true,
      ),
    );
    await _fetchAssignments(event.courseId, emit);
  }

  Future<void> _onLoadLabs(
    LoadLabs event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingLabs: true,
        usedLabsMaterialsFallback: false,
        clearError: true,
      ),
    );
    await _fetchLabs(event.courseId, emit);
  }

  Future<void> _onLoadAssignmentSubmissions(
    LoadAssignmentSubmissions event,
    Emitter<CourseDetailState> emit,
  ) async {
    final assignmentService = _assignmentService;
    if (assignmentService == null || event.assignments.isEmpty) {
      emit(
        state.copyWith(
          isLoadingAssignmentSubmissions: false,
          assignmentSubmissions: const <int, AssignmentSubmissionModel?>{},
        ),
      );
      return;
    }

    emit(
      state.copyWith(isLoadingAssignmentSubmissions: true, clearError: true),
    );
    try {
      final snapshots = <int, AssignmentSubmissionModel?>{};
      for (final assignment in event.assignments) {
        final assignmentId = assignment.assignmentId;
        if (assignmentId <= 0) {
          continue;
        }

        final result = await assignmentService.getMySubmission(assignmentId);
        if (!result.isSuccess) {
          snapshots[assignmentId] = null;
          continue;
        }

        snapshots[assignmentId] = _normalizeAssignmentSubmission(result.data);
      }

      emit(
        state.copyWith(
          assignmentSubmissions: snapshots,
          isLoadingAssignmentSubmissions: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingAssignmentSubmissions: false,
          error: _toMessage(e),
        ),
      );
    }
  }

  Future<void> _onLoadLabSubmissions(
    LoadLabSubmissions event,
    Emitter<CourseDetailState> emit,
  ) async {
    final labService = _labService;
    if (labService == null || event.labs.isEmpty) {
      emit(
        state.copyWith(
          isLoadingLabSubmissions: false,
          labSubmissions: const <int, LabSubmissionModel?>{},
        ),
      );
      return;
    }

    emit(state.copyWith(isLoadingLabSubmissions: true, clearError: true));

    try {
      final snapshots = <int, LabSubmissionModel?>{};
      for (final lab in event.labs) {
        final labId = lab.labId ?? int.tryParse(lab.id) ?? 0;
        if (labId <= 0) {
          continue;
        }

        final result = await labService.getMySubmission(labId);
        if (!result.isSuccess) {
          snapshots[labId] = null;
          continue;
        }

        final items = result.data ?? const <LabSubmissionModel>[];
        if (items.isEmpty) {
          snapshots[labId] = null;
          continue;
        }

        final sorted = items.toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        snapshots[labId] = _normalizeLabSubmission(sorted.first);
      }

      emit(
        state.copyWith(
          labSubmissions: snapshots,
          isLoadingLabSubmissions: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingLabSubmissions: false, error: _toMessage(e)),
      );
    }
  }

  Future<void> _onLoadPrerequisites(
    LoadPrerequisites event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingPrerequisites: true, clearError: true));
    await _fetchPrerequisitesFromPayload(event.prerequisites, emit);
  }

  void _onExpandWeek(ExpandWeek event, Emitter<CourseDetailState> emit) {
    emit(state.copyWith(selectedWeekIndex: event.weekIndex));
  }

  void _onSwitchTab(SwitchTab event, Emitter<CourseDetailState> emit) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }

  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingAnnouncements: true, clearError: true));
    await _fetchAnnouncements(event.courseId, emit);
  }

  Future<void> _onLoadSectionStaff(
    LoadSectionStaff event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingStaff: true, clearError: true));
    await _fetchStaff(event.sectionId, emit);
  }

  Future<void> _onLoadInstructorProfile(
    LoadInstructorProfile event,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_publicProfileService == null) {
      add(LoadOfficeHourSlots(instructorId: event.userId));
      return;
    }

    emit(
      state.copyWith(
        isLoadingProfile: true,
        clearError: true,
        clearBookingMessage: true,
      ),
    );

    try {
      final profile = await _publicProfileService.getPublicProfile(
        event.userId,
      );
      emit(
        state.copyWith(
          selectedProfile: profile,
          isLoadingProfile: false,
          clearError: true,
        ),
      );

      add(LoadOfficeHourSlots(instructorId: event.userId));
    } catch (e) {
      emit(state.copyWith(isLoadingProfile: false, error: _toMessage(e)));
      add(LoadOfficeHourSlots(instructorId: event.userId));
    }
  }

  Future<void> _onLoadOfficeHourSlots(
    LoadOfficeHourSlots event,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_officeHoursService == null) {
      return;
    }

    emit(state.copyWith(isLoadingOfficeHours: true, clearError: true));

    try {
      final response = await _officeHoursService.getSlots(
        instructorId: event.instructorId,
        limit: 50,
      );

      final slots = response.items.where((slot) => slot.isActive).toList()
        ..sort((a, b) {
          final dayCompare = _dayRank(
            a.dayOfWeek,
          ).compareTo(_dayRank(b.dayOfWeek));
          if (dayCompare != 0) {
            return dayCompare;
          }
          return a.startTime.compareTo(b.startTime);
        });

      emit(
        state.copyWith(
          officeHourSlots: slots,
          isLoadingOfficeHours: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingOfficeHours: false, error: _toMessage(e)));
    }
  }

  Future<void> _onLoadMyAppointments(
    LoadMyAppointments event,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_officeHoursService == null) {
      return;
    }

    emit(state.copyWith(isLoadingAppointments: true, clearError: true));

    try {
      final appointments = await _officeHoursService.getMyAppointments();
      appointments.sort((a, b) {
        final left = a.appointmentDate ?? DateTime(1970);
        final right = b.appointmentDate ?? DateTime(1970);
        return right.compareTo(left);
      });

      emit(
        state.copyWith(
          appointments: appointments,
          isLoadingAppointments: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingAppointments: false, error: _toMessage(e)));
    }
  }

  Future<void> _onBookOfficeHourAppointment(
    BookOfficeHourAppointment event,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_officeHoursService == null) {
      return;
    }

    emit(
      state.copyWith(
        isBookingAppointment: true,
        clearError: true,
        clearBookingMessage: true,
      ),
    );

    try {
      final appointment = await _officeHoursService.bookAppointment(
        slotId: event.slotId,
        appointmentDate: event.appointmentDate,
        topic: event.topic,
        notes: event.notes,
      );

      final updated = <int, OfficeHourAppointmentModel>{
        for (final item in state.appointments) item.appointmentId: item,
      };
      updated[appointment.appointmentId] = appointment;

      emit(
        state.copyWith(
          appointments: updated.values.toList(),
          isBookingAppointment: false,
          bookingMessage: 'Appointment booked successfully.',
          clearError: true,
        ),
      );

      add(const LoadMyAppointments());
      if (event.instructorId != null) {
        add(LoadOfficeHourSlots(instructorId: event.instructorId!));
      }
    } catch (e) {
      emit(state.copyWith(isBookingAppointment: false, error: _toMessage(e)));
    }
  }

  Future<void> _fetchStructure(
    dynamic courseId,
    Emitter<CourseDetailState> emit,
  ) async {
    try {
      final structure = await _courseService.getCourseStructure(courseId);
      emit(
        state.copyWith(
          structure: structure,
          isLoadingStructure: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingStructure: false, error: _toMessage(e)));
    }
  }

  Future<void> _fetchMaterials(
    dynamic courseId,
    Emitter<CourseDetailState> emit, {
    int? weekNumber,
  }) async {
    try {
      final materials = await _materialService.getMaterials(
        courseId,
        weekNumber: weekNumber,
      );

      final merged = _mergeMaterials(
        existing: state.materials,
        incoming: materials,
      );

      emit(
        state.copyWith(
          materials: merged,
          bundles: MaterialBundleModel.detectBundles(merged),
          isLoadingMaterials: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMaterials: false, error: _toMessage(e)));
    }
  }

  Future<void> _fetchAssignments(
    dynamic courseId,
    Emitter<CourseDetailState> emit,
  ) async {
    final normalizedCourseId = _parsePositiveInt(courseId);
    if (normalizedCourseId == null) {
      emit(
        state.copyWith(
          assignments: const <AssignmentModel>[],
          assignmentSubmissions: const <int, AssignmentSubmissionModel?>{},
          isLoadingAssignments: false,
          isLoadingAssignmentSubmissions: false,
        ),
      );
      return;
    }

    List<AssignmentModel> assignments = const <AssignmentModel>[];
    var usedFallback = false;
    String? primaryError;

    if (_assignmentService != null) {
      final response = await _assignmentService.getAll(
        courseId: normalizedCourseId,
        page: 1,
        limit: 100,
      );

      if (response.isSuccess && response.data != null) {
        assignments = response.data!.data
            .map(_normalizeAssignment)
            .toList(growable: false);
      } else {
        primaryError = response.error?.message;
      }
    }

    if (assignments.isEmpty) {
      usedFallback = true;
      try {
        final materials = await _materialService.getMaterials(
          courseId,
          materialType: 'assignment',
        );

        assignments = materials
            .where(_isAssignmentMaterial)
            .map(
              (material) =>
                  _fromMaterialAsAssignment(material, normalizedCourseId),
            )
            .map(_normalizeAssignment)
            .toList(growable: false);
      } catch (e) {
        emit(
          state.copyWith(
            assignments: const <AssignmentModel>[],
            assignmentSubmissions: const <int, AssignmentSubmissionModel?>{},
            isLoadingAssignments: false,
            isLoadingAssignmentSubmissions: false,
            usedAssignmentsMaterialsFallback: usedFallback,
            error: primaryError ?? _toMessage(e),
          ),
        );
        return;
      }
    }

    emit(
      state.copyWith(
        assignments: assignments,
        isLoadingAssignments: false,
        usedAssignmentsMaterialsFallback: usedFallback,
        clearError: true,
      ),
    );

    if (_assignmentService == null || assignments.isEmpty) {
      emit(
        state.copyWith(
          assignmentSubmissions: const <int, AssignmentSubmissionModel?>{},
          isLoadingAssignmentSubmissions: false,
        ),
      );
      return;
    }

    add(LoadAssignmentSubmissions(assignments: assignments));
  }

  Future<void> _fetchLabs(
    dynamic courseId,
    Emitter<CourseDetailState> emit,
  ) async {
    final normalizedCourseId = _parsePositiveInt(courseId);
    if (normalizedCourseId == null) {
      emit(
        state.copyWith(
          labs: const <LabModel>[],
          labSubmissions: const <int, LabSubmissionModel?>{},
          isLoadingLabs: false,
          isLoadingLabSubmissions: false,
        ),
      );
      return;
    }

    List<LabModel> labs = const <LabModel>[];
    var usedFallback = false;
    String? primaryError;

    if (_labService != null) {
      final response = await _labService.getAll(
        courseId: normalizedCourseId,
        page: 1,
        limit: 100,
      );

      if (response.isSuccess && response.data != null) {
        labs = response.data!.map(_normalizeLab).toList(growable: false);
      } else {
        primaryError = response.error?.message;
      }
    }

    if (labs.isEmpty) {
      usedFallback = true;
      try {
        final materials = await _materialService.getMaterials(
          courseId,
          materialType: 'lab',
        );

        labs = materials
            .where(_isLabMaterial)
            .map((material) => _fromMaterialAsLab(material, normalizedCourseId))
            .map(_normalizeLab)
            .toList(growable: false);
      } catch (e) {
        emit(
          state.copyWith(
            labs: const <LabModel>[],
            labSubmissions: const <int, LabSubmissionModel?>{},
            isLoadingLabs: false,
            isLoadingLabSubmissions: false,
            usedLabsMaterialsFallback: usedFallback,
            error: primaryError ?? _toMessage(e),
          ),
        );
        return;
      }
    }

    emit(
      state.copyWith(
        labs: labs,
        isLoadingLabs: false,
        usedLabsMaterialsFallback: usedFallback,
        clearError: true,
      ),
    );

    if (_labService == null || labs.isEmpty) {
      emit(
        state.copyWith(
          labSubmissions: const <int, LabSubmissionModel?>{},
          isLoadingLabSubmissions: false,
        ),
      );
      return;
    }

    add(LoadLabSubmissions(labs: labs));
  }

  Future<void> _fetchPrerequisitesFromPayload(
    List<EnrollmentPrerequisite> prerequisites,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        prerequisites: prerequisites,
        isLoadingPrerequisites: false,
        clearError: true,
      ),
    );
  }

  Future<void> _fetchAnnouncements(
    dynamic courseId,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_communicationService == null) {
      emit(state.copyWith(isLoadingAnnouncements: false));
      return;
    }

    try {
      final announcements = await _communicationService
          .getAnnouncementsByCourseId(courseId);
      announcements.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      emit(
        state.copyWith(
          announcements: announcements,
          isLoadingAnnouncements: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingAnnouncements: false, error: _toMessage(e)));
    }
  }

  Future<void> _fetchStaff(
    dynamic sectionId,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_enrollmentService == null) {
      emit(state.copyWith(isLoadingStaff: false));
      return;
    }

    try {
      final instructorsResult = await _enrollmentService.getSectionInstructors(
        sectionId,
      );
      final tasResult = await _enrollmentService.getSectionTAs(sectionId);

      final parsedSectionId = _parsePositiveInt(sectionId);

      List<InstructorAssignmentModel> resolvedInstructors;
      if (instructorsResult.isSuccess) {
        resolvedInstructors =
            instructorsResult.data ?? const <InstructorAssignmentModel>[];
      } else {
        resolvedInstructors = parsedSectionId == null
            ? const <InstructorAssignmentModel>[]
            : state.instructors
                  .where((item) => item.sectionId == parsedSectionId)
                  .toList(growable: false);
      }

      List<TAAssignmentModel> resolvedTeachingAssistants;
      if (tasResult.isSuccess) {
        resolvedTeachingAssistants =
            tasResult.data ?? const <TAAssignmentModel>[];
      } else {
        resolvedTeachingAssistants = parsedSectionId == null
            ? const <TAAssignmentModel>[]
            : state.teachingAssistants
                  .where((item) => item.sectionId == parsedSectionId)
                  .toList(growable: false);
      }

      final hasAnySuccess = instructorsResult.isSuccess || tasResult.isSuccess;
      if (hasAnySuccess) {
        emit(
          state.copyWith(
            instructors: resolvedInstructors,
            teachingAssistants: resolvedTeachingAssistants,
            isLoadingStaff: false,
            clearError: true,
          ),
        );
        return;
      }

      final messages = <String>[
        if (instructorsResult.error?.message != null &&
            instructorsResult.error!.message.trim().isNotEmpty)
          instructorsResult.error!.message.trim(),
        if (tasResult.error?.message != null &&
            tasResult.error!.message.trim().isNotEmpty)
          tasResult.error!.message.trim(),
      ];

      emit(
        state.copyWith(
          isLoadingStaff: false,
          error: messages.isEmpty
              ? 'Failed to load section staff'
              : messages.join(' | '),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingStaff: false, error: _toMessage(e)));
    }
  }

  List<CourseMaterialModel> _mergeMaterials({
    required List<CourseMaterialModel> existing,
    required List<CourseMaterialModel> incoming,
  }) {
    if (existing.isEmpty) {
      return incoming;
    }

    final map = <String, CourseMaterialModel>{
      for (final material in existing) material.materialId: material,
    };

    for (final material in incoming) {
      map[material.materialId] = material;
    }

    final merged = map.values.toList();
    merged.sort((a, b) {
      final weekCompare = (a.weekNumber ?? 0).compareTo(b.weekNumber ?? 0);
      if (weekCompare != 0) return weekCompare;
      return (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
    });

    return merged;
  }

  int? _parsePositiveInt(dynamic value) {
    if (value is int && value > 0) {
      return value;
    }

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null && parsed > 0) {
      return parsed;
    }

    return null;
  }

  bool _isAssignmentMaterial(CourseMaterialModel material) {
    final type = material.materialType.trim().toLowerCase();
    return type == 'assignment' || type == 'homework';
  }

  bool _isLabMaterial(CourseMaterialModel material) {
    final type = material.materialType.trim().toLowerCase();
    return type == 'lab' || type == 'laboratory';
  }

  AssignmentModel _fromMaterialAsAssignment(
    CourseMaterialModel material,
    int courseId,
  ) {
    final dueDate =
        material.publishedAt ?? material.updatedAt ?? material.createdAt;

    return AssignmentModel(
      id: material.materialId,
      assignmentId: int.tryParse(material.materialId) ?? 0,
      courseId: int.tryParse(material.courseId) ?? courseId,
      title: material.title,
      description: material.description,
      courseName: '',
      courseCode: '',
      instructorName: '',
      type: AssignmentType.other,
      status: AssignmentStatus.pending,
      priority: AssignmentPriority.medium,
      dueDate: dueDate,
      assignedDate: material.createdAt,
      maxGrade: 0,
      instructions: material.description == null
          ? null
          : <String>[material.description!],
      createdAt: material.createdAt,
    );
  }

  LabModel _fromMaterialAsLab(CourseMaterialModel material, int courseId) {
    final dueDate =
        material.publishedAt ?? material.updatedAt ?? material.createdAt;

    return LabModel(
      id: material.materialId,
      labId: int.tryParse(material.materialId),
      courseId: int.tryParse(material.courseId) ?? courseId,
      title: material.title,
      description: material.description,
      dueDate: dueDate,
      availableFrom: material.createdAt,
      maxScore: 0,
      createdAt: material.createdAt,
      updatedAt: material.updatedAt,
    );
  }

  AssignmentModel _normalizeAssignment(AssignmentModel model) {
    return model.copyWith(maxGrade: _normalizeScore(model.maxGrade));
  }

  LabModel _normalizeLab(LabModel model) {
    return model.copyWith(maxScore: _normalizeScore(model.maxScore));
  }

  AssignmentSubmissionModel? _normalizeAssignmentSubmission(
    AssignmentSubmissionModel? submission,
  ) {
    if (submission == null) {
      return null;
    }

    final payload = submission.toJson();
    payload['isLate'] = submission.isLate;
    if (submission.score != null) {
      payload['score'] = _normalizeScore(submission.score!);
    }
    return AssignmentSubmissionModel.fromJson(payload);
  }

  LabSubmissionModel? _normalizeLabSubmission(LabSubmissionModel? submission) {
    if (submission == null) {
      return null;
    }

    return LabSubmissionModel.fromJson(submission.toJson()).copyWith(
      score: submission.score == null
          ? null
          : _normalizeScore(submission.score!),
      isLate: submission.isLate,
    );
  }

  double _normalizeScore(double score) {
    if (score.isNaN || score.isInfinite || score < 0) {
      return 0;
    }
    return score;
  }

  String _toMessage(Object error) {
    final raw = error.toString();
    return raw
        .replaceAll('Exception: ', '')
        .replaceAll('DioException ', '')
        .trim();
  }

  int _dayRank(String day) {
    switch (day.trim().toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 8;
    }
  }
}
