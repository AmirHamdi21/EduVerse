import 'package:equatable/equatable.dart';

import '../../../../models/core/course_model.dart';
import '../../../../models/core/course_structure_model.dart';
import '../../../../models/materials/course_material_model.dart';
import '../../../../models/materials/material_bundle_model.dart';
import '../../../../models/materials/announcement_model.dart';
import '../../../../models/courses/instructor_assignment_model.dart';
import '../../../../models/ta/ta_assignment_model.dart';
import '../../../../models/student/public_profile_model.dart';
import '../../../../models/admin/admin_periods_models.dart';

class CourseDetailState extends Equatable {
  final CourseModel? course;
  final List<CourseStructureModel> structure;
  final List<CourseMaterialModel> materials;
  final Map<String, MaterialBundleModel> bundles;
  final List<AnnouncementModel> announcements;
  final List<InstructorAssignmentModel> instructors;
  final List<TAAssignmentModel> teachingAssistants;
  final PublicProfileModel? selectedProfile;
  final List<OfficeHourSlotModel> officeHourSlots;
  final List<OfficeHourAppointmentModel> appointments;
  final int selectedWeekIndex;
  final bool isLoadingStructure;
  final bool isLoadingMaterials;
  final bool isLoadingAnnouncements;
  final bool isLoadingStaff;
  final bool isLoadingProfile;
  final bool isLoadingOfficeHours;
  final bool isLoadingAppointments;
  final bool isBookingAppointment;
  final String? error;
  final String? bookingMessage;
  final int selectedTabIndex;

  const CourseDetailState({
    this.course,
    this.structure = const <CourseStructureModel>[],
    this.materials = const <CourseMaterialModel>[],
    this.bundles = const <String, MaterialBundleModel>{},
    this.announcements = const <AnnouncementModel>[],
    this.instructors = const <InstructorAssignmentModel>[],
    this.teachingAssistants = const <TAAssignmentModel>[],
    this.selectedProfile,
    this.officeHourSlots = const <OfficeHourSlotModel>[],
    this.appointments = const <OfficeHourAppointmentModel>[],
    this.selectedWeekIndex = 0,
    this.isLoadingStructure = false,
    this.isLoadingMaterials = false,
    this.isLoadingAnnouncements = false,
    this.isLoadingStaff = false,
    this.isLoadingProfile = false,
    this.isLoadingOfficeHours = false,
    this.isLoadingAppointments = false,
    this.isBookingAppointment = false,
    this.error,
    this.bookingMessage,
    this.selectedTabIndex = 0,
  });

  CourseDetailState copyWith({
    CourseModel? course,
    List<CourseStructureModel>? structure,
    List<CourseMaterialModel>? materials,
    Map<String, MaterialBundleModel>? bundles,
    List<AnnouncementModel>? announcements,
    List<InstructorAssignmentModel>? instructors,
    List<TAAssignmentModel>? teachingAssistants,
    PublicProfileModel? selectedProfile,
    bool clearSelectedProfile = false,
    List<OfficeHourSlotModel>? officeHourSlots,
    List<OfficeHourAppointmentModel>? appointments,
    int? selectedWeekIndex,
    bool? isLoadingStructure,
    bool? isLoadingMaterials,
    bool? isLoadingAnnouncements,
    bool? isLoadingStaff,
    bool? isLoadingProfile,
    bool? isLoadingOfficeHours,
    bool? isLoadingAppointments,
    bool? isBookingAppointment,
    String? error,
    bool clearError = false,
    String? bookingMessage,
    bool clearBookingMessage = false,
    int? selectedTabIndex,
  }) {
    return CourseDetailState(
      course: course ?? this.course,
      structure: structure ?? this.structure,
      materials: materials ?? this.materials,
      bundles: bundles ?? this.bundles,
      announcements: announcements ?? this.announcements,
      instructors: instructors ?? this.instructors,
      teachingAssistants: teachingAssistants ?? this.teachingAssistants,
      selectedProfile: clearSelectedProfile
          ? null
          : (selectedProfile ?? this.selectedProfile),
      officeHourSlots: officeHourSlots ?? this.officeHourSlots,
      appointments: appointments ?? this.appointments,
      selectedWeekIndex: selectedWeekIndex ?? this.selectedWeekIndex,
      isLoadingStructure: isLoadingStructure ?? this.isLoadingStructure,
      isLoadingMaterials: isLoadingMaterials ?? this.isLoadingMaterials,
      isLoadingAnnouncements:
          isLoadingAnnouncements ?? this.isLoadingAnnouncements,
      isLoadingStaff: isLoadingStaff ?? this.isLoadingStaff,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      isLoadingOfficeHours: isLoadingOfficeHours ?? this.isLoadingOfficeHours,
      isLoadingAppointments:
          isLoadingAppointments ?? this.isLoadingAppointments,
      isBookingAppointment: isBookingAppointment ?? this.isBookingAppointment,
      error: clearError ? null : (error ?? this.error),
      bookingMessage: clearBookingMessage
          ? null
          : (bookingMessage ?? this.bookingMessage),
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  bool get isLoading =>
      isLoadingStructure ||
      isLoadingMaterials ||
      isLoadingAnnouncements ||
      isLoadingStaff ||
      isLoadingProfile ||
      isLoadingOfficeHours ||
      isLoadingAppointments ||
      isBookingAppointment;

  @override
  List<Object?> get props => <Object?>[
    course,
    structure,
    materials,
    bundles,
    announcements,
    instructors,
    teachingAssistants,
    selectedProfile,
    officeHourSlots,
    appointments,
    selectedWeekIndex,
    isLoadingStructure,
    isLoadingMaterials,
    isLoadingAnnouncements,
    isLoadingStaff,
    isLoadingProfile,
    isLoadingOfficeHours,
    isLoadingAppointments,
    isBookingAppointment,
    error,
    bookingMessage,
    selectedTabIndex,
  ];
}
