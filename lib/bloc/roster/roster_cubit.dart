import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api/enrollment_service.dart';
import 'roster_state.dart';

/// Shared Cubit for managing the Roster screen state.
///
/// Used by both the Instructor Roster and TA Roster screens.
/// Fetches courses from `/enrollments/teaching` and students from
/// `/enrollments/section/{sectionId}/students`.
class RosterCubit extends Cubit<RosterState> {
  final EnrollmentService _enrollmentService;

  RosterCubit({required EnrollmentService enrollmentService})
    : _enrollmentService = enrollmentService,
      super(const RosterState());

  /// Load the instructor/TA's teaching assignments (courses + sections).
  Future<void> loadCourses() async {
    emit(state.copyWith(coursesStatus: RosterStatus.loading));

    try {
      final result = await _enrollmentService.getTeachingCourses();

      if (result.isSuccess && result.data != null) {
        final courses = result.data!;
        emit(
          state.copyWith(courses: courses, coursesStatus: RosterStatus.loaded),
        );

        // Auto-select first course if available
        if (courses.isNotEmpty) {
          selectCourse(courses.first.sectionId);
        }
      } else {
        emit(
          state.copyWith(
            coursesStatus: RosterStatus.error,
            errorMessage: result.error?.message ?? 'Failed to load courses',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          coursesStatus: RosterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Select a course and load its students.
  Future<void> selectCourse(int sectionId) async {
    emit(
      state.copyWith(
        selectedSectionId: sectionId,
        studentsStatus: RosterStatus.loading,
        students: [],
        searchQuery: '',
      ),
    );

    try {
      final result = await _enrollmentService.getSectionStudentsLite(sectionId);

      if (result.isSuccess && result.data != null) {
        emit(
          state.copyWith(
            students: result.data!,
            studentsStatus: RosterStatus.loaded,
          ),
        );
      } else {
        emit(
          state.copyWith(
            studentsStatus: RosterStatus.error,
            errorMessage: result.error?.message ?? 'Failed to load students',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          studentsStatus: RosterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update the search query for filtering students.
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Refresh: reload courses and current section students.
  Future<void> refresh() async {
    await loadCourses();
  }
}
