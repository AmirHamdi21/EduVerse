import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/api/course_service.dart';
import '../../../../services/api/material_service.dart';
import '../../../../services/api/enrollment_service.dart';
import '../../../../services/api/communication_service.dart';
import '../../../../services/api/public_profile_service.dart';
import '../../../../services/api/office_hours_service.dart';
import '../../../../models/admin/admin_periods_models.dart';
import '../../../../models/courses/instructor_assignment_model.dart';
import '../../../../models/ta/ta_assignment_model.dart';
import '../../../../models/materials/course_material_model.dart';
import '../../../../models/materials/material_bundle_model.dart';
import 'course_detail_event.dart';
import 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final CourseService _courseService;
  final MaterialService _materialService;
  final EnrollmentService? _enrollmentService;
  final CommunicationService? _communicationService;
  final PublicProfileService? _publicProfileService;
  final OfficeHoursService? _officeHoursService;

  CourseDetailBloc({
    required CourseService courseService,
    required MaterialService materialService,
    EnrollmentService? enrollmentService,
    CommunicationService? communicationService,
    PublicProfileService? publicProfileService,
    OfficeHoursService? officeHoursService,
  }) : _courseService = courseService,
       _materialService = materialService,
       _enrollmentService = enrollmentService,
       _communicationService = communicationService,
       _publicProfileService = publicProfileService,
       _officeHoursService = officeHoursService,
       super(const CourseDetailState()) {
    on<LoadCourseDetail>(_onLoadCourseDetail);
    on<LoadStructure>(_onLoadStructure);
    on<LoadMaterials>(_onLoadMaterials);
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
        isLoadingAnnouncements:
            event.courseId != null && _communicationService != null,
        isLoadingStaff: event.sectionId != null && _enrollmentService != null,
        clearError: true,
        clearBookingMessage: true,
      ),
    );

    final futures = <Future<void>>[
      _fetchStructure(event.courseId, emit),
      _fetchMaterials(event.courseId, emit),
    ];

    if (event.courseId != null) {
      futures.add(_fetchAnnouncements(event.courseId, emit));
    }

    if (event.sectionId != null && event.sectionId! > 0) {
      futures.add(_fetchStaff(event.sectionId!, emit));
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
      if (!instructorsResult.isSuccess) {
        throw Exception(
          instructorsResult.error?.message ?? 'Failed to load instructors',
        );
      }

      final tasResult = await _enrollmentService.getSectionTAs(sectionId);
      if (!tasResult.isSuccess) {
        throw Exception(tasResult.error?.message ?? 'Failed to load TAs');
      }

      emit(
        state.copyWith(
          instructors:
              instructorsResult.data ?? const <InstructorAssignmentModel>[],
          teachingAssistants: tasResult.data ?? const <TAAssignmentModel>[],
          isLoadingStaff: false,
          clearError: true,
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
