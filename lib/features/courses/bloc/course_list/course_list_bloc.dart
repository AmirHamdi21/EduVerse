import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/core/enrollment_model.dart';
import '../../../../services/api/enrollment_service.dart';
import 'course_list_event.dart';
import 'course_list_state.dart';

class CourseListBloc extends Bloc<CourseListEvent, CourseListState> {
  final EnrollmentService _enrollmentService;

  CourseListBloc({required EnrollmentService enrollmentService})
    : _enrollmentService = enrollmentService,
      super(const CourseListState()) {
    on<FetchCourses>(_onFetchCourses);
    on<RefreshCourses>(_onRefreshCourses);
  }

  Future<void> _onFetchCourses(
    FetchCourses event,
    Emitter<CourseListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _enrollmentService.getMyCourses();

    if (result.isSuccess) {
      emit(
        state.copyWith(
          courses: result.data ?? const <CourseEnrollmentModel>[],
          isLoading: false,
          hasMore: false,
          currentPage: 1,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        courses: const <CourseEnrollmentModel>[],
        error: result.error?.message ?? 'Failed to load courses',
      ),
    );
  }

  Future<void> _onRefreshCourses(
    RefreshCourses event,
    Emitter<CourseListState> emit,
  ) async {
    add(const FetchCourses());
  }
}
