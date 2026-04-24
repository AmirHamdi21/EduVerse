import 'package:equatable/equatable.dart';

import '../../common/utils/student_registration_filters.dart';
import '../../models/admin/admin_periods_models.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/registration/registration_available_course_model.dart';
import '../../models/registration/registration_available_section_model.dart';

class StudentRegistrationState extends Equatable {
  final List<RegistrationAvailableCourseModel> availableCourses;
  final List<CourseEnrollmentModel> enrolledCourses;
  final List<EnrollmentPeriodModel> enrollmentPeriods;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isEnrolling;
  final bool isDropping;
  final String? activeDropEnrollmentId;
  final String searchQuery;
  final String selectedDepartment;
  final String selectedLevel;
  final int? selectedCourseId;
  final int? selectedSectionId;
  final String? successMessage;
  final String? errorMessage;

  const StudentRegistrationState({
    this.availableCourses = const <RegistrationAvailableCourseModel>[],
    this.enrolledCourses = const <CourseEnrollmentModel>[],
    this.enrollmentPeriods = const <EnrollmentPeriodModel>[],
    this.isInitialLoading = true,
    this.isRefreshing = false,
    this.isEnrolling = false,
    this.isDropping = false,
    this.activeDropEnrollmentId,
    this.searchQuery = '',
    this.selectedDepartment = StudentRegistrationFilters.allFilterValue,
    this.selectedLevel = StudentRegistrationFilters.allFilterValue,
    this.selectedCourseId,
    this.selectedSectionId,
    this.successMessage,
    this.errorMessage,
  });

  StudentRegistrationState copyWith({
    List<RegistrationAvailableCourseModel>? availableCourses,
    List<CourseEnrollmentModel>? enrolledCourses,
    List<EnrollmentPeriodModel>? enrollmentPeriods,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isEnrolling,
    bool? isDropping,
    String? activeDropEnrollmentId,
    String? searchQuery,
    String? selectedDepartment,
    String? selectedLevel,
    int? selectedCourseId,
    int? selectedSectionId,
    String? successMessage,
    String? errorMessage,
    bool clearDropId = false,
    bool clearSelectedCourseId = false,
    bool clearSelectedSectionId = false,
    bool clearSuccessMessage = false,
    bool clearErrorMessage = false,
  }) {
    return StudentRegistrationState(
      availableCourses: availableCourses ?? this.availableCourses,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      enrollmentPeriods: enrollmentPeriods ?? this.enrollmentPeriods,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isEnrolling: isEnrolling ?? this.isEnrolling,
      isDropping: isDropping ?? this.isDropping,
      activeDropEnrollmentId: clearDropId
          ? null
          : (activeDropEnrollmentId ?? this.activeDropEnrollmentId),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedCourseId: clearSelectedCourseId
          ? null
          : (selectedCourseId ?? this.selectedCourseId),
      selectedSectionId: clearSelectedSectionId
          ? null
          : (selectedSectionId ?? this.selectedSectionId),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  RegistrationAvailableCourseModel? get selectedCourse {
    if (selectedCourseId == null) {
      return null;
    }
    try {
      return availableCourses.firstWhere((c) => c.id == selectedCourseId);
    } catch (_) {
      return null;
    }
  }

  RegistrationAvailableSectionModel? get selectedSection {
    final course = selectedCourse;
    final sectionId = selectedSectionId;
    if (course == null || sectionId == null) {
      return null;
    }
    try {
      return course.sections.firstWhere((s) => s.id == sectionId);
    } catch (_) {
      return null;
    }
  }

  List<RegistrationAvailableCourseModel> get filteredAvailableCourses {
    return StudentRegistrationFilters.applyFilters(
      courses: availableCourses,
      searchQuery: searchQuery,
      selectedDepartment: selectedDepartment,
      selectedLevel: selectedLevel,
    );
  }

  List<String> get departmentOptions {
    return StudentRegistrationFilters.deriveDepartmentOptions(availableCourses);
  }

  List<String> get levelOptions {
    return StudentRegistrationFilters.deriveLevelOptions(availableCourses);
  }

  StudentRegistrationStats get stats {
    return StudentRegistrationFilters.buildStats(
      enrolledCourses: enrolledCourses,
      availableCourses: availableCourses,
    );
  }

  EnrollmentPeriodModel? get currentPeriod {
    if (enrollmentPeriods.isEmpty) {
      return null;
    }

    EnrollmentPeriodModel? active;
    EnrollmentPeriodModel? upcoming;
    for (final period in enrollmentPeriods) {
      final status = period.status.trim().toLowerCase();
      if (status == 'active' || status == 'open') {
        active = period;
        break;
      }
      if (upcoming == null && status == 'upcoming') {
        upcoming = period;
      }
    }

    return active ?? upcoming ?? enrollmentPeriods.first;
  }

  @override
  List<Object?> get props => <Object?>[
    availableCourses,
    enrolledCourses,
    enrollmentPeriods,
    isInitialLoading,
    isRefreshing,
    isEnrolling,
    isDropping,
    activeDropEnrollmentId,
    searchQuery,
    selectedDepartment,
    selectedLevel,
    selectedCourseId,
    selectedSectionId,
    successMessage,
    errorMessage,
  ];
}
