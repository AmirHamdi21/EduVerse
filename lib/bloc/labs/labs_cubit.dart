import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/core/course_model.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/core/enums/enrollment_enums.dart';
import '../../models/core/enums/lab_enums.dart' as api;
import '../../models/labs/lab_model.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/lab_service.dart';
import 'labs_state.dart';

class LabsCubit extends Cubit<LabsState> {
  LabsCubit({
    required EnrollmentService enrollmentService,
    required LabService labService,
  }) : _enrollmentService = enrollmentService,
       _labService = labService,
       super(const LabsState());

  final EnrollmentService _enrollmentService;
  final LabService _labService;

  EnrollmentService get enrollmentService => _enrollmentService;
  LabService get labService => _labService;

  Future<void> loadEnrolledCourses({int? preselectedCourseId}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _enrollmentService.getMyCourses();
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load enrolled courses',
        ),
      );
      return;
    }

    final courses = _extractEnrolledCourses(result.data!);
    if (courses.isEmpty) {
      emit(
        state.copyWith(
          enrolledCourses: const <CourseModel>[],
          labs: const <LabModel>[],
          isLoading: false,
          clearError: true,
          clearSelectedCourseId: true,
          clearSelectedCourse: true,
        ),
      );
      return;
    }

    final selectedCourseId = _resolveSelectedCourseId(
      courses,
      preselectedCourseId: preselectedCourseId,
    );
    final selectedCourse = courses.firstWhere(
      (course) => course.id == selectedCourseId,
    );

    emit(
      state.copyWith(
        enrolledCourses: courses,
        selectedCourseId: selectedCourseId,
        selectedCourse: selectedCourse,
        isLoading: false,
        clearError: true,
      ),
    );

    await selectCourse(selectedCourseId);
  }

  Future<void> selectCourse(int? courseId) async {
    if (courseId == null) {
      emit(
        state.copyWith(
          isLoading: false,
          labs: const <LabModel>[],
          clearSelectedCourseId: true,
          clearSelectedCourse: true,
        ),
      );
      return;
    }

    final selectedCourse = state.enrolledCourses
        .where((course) => course.id == courseId)
        .cast<CourseModel?>()
        .firstWhere((course) => course != null, orElse: () => null);

    emit(
      state.copyWith(
        selectedCourseId: courseId,
        selectedCourse: selectedCourse,
        isLoading: true,
        clearError: true,
      ),
    );

    final result = await _labService.getAll(courseId: courseId);
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load labs',
        ),
      );
      return;
    }

    final labs = result.data!
        .where((lab) => lab.status != api.LabStatus.draft)
        .toList();

    emit(state.copyWith(labs: labs, isLoading: false, clearError: true));
  }

  Future<void> refreshLabs() async {
    await selectCourse(state.selectedCourseId);
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilter(LabsFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void clearFilters() {
    emit(state.copyWith(filter: const LabsFilter()));
  }

  void setSortBy(LabsSortBy sortBy) {
    if (state.sortBy == sortBy) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortBy: sortBy, sortAscending: true));
    }
  }

  void setViewMode(LabsViewMode viewMode) {
    emit(state.copyWith(viewMode: viewMode));
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  int _resolveSelectedCourseId(
    List<CourseModel> courses, {
    int? preselectedCourseId,
  }) {
    if (preselectedCourseId != null &&
        courses.any((course) => course.id == preselectedCourseId)) {
      return preselectedCourseId;
    }

    final current = state.selectedCourseId;
    if (current != null && courses.any((course) => course.id == current)) {
      return current;
    }
    return courses.first.id;
  }

  List<CourseModel> _extractEnrolledCourses(
    List<CourseEnrollmentModel> enrollments,
  ) {
    final byId = <int, CourseModel>{};
    for (final enrollment in enrollments) {
      if (enrollment.enrollmentStatus != EnrollmentStatus.enrolled) {
        continue;
      }

      final course = enrollment.course;
      if (course == null) {
        continue;
      }

      byId[course.id] = course;
    }

    final courses = byId.values.toList();
    courses.sort((a, b) => a.name.compareTo(b.name));
    return courses;
  }
}
