import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/service_error.dart';
import '../../models/admin/admin_periods_models.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/registration/registration_available_course_model.dart';
import '../../services/api/enrollment_service.dart';
import 'student_registration_state.dart';

class StudentRegistrationCubit extends Cubit<StudentRegistrationState> {
  StudentRegistrationCubit({required EnrollmentService enrollmentService})
    : _enrollmentService = enrollmentService,
      super(const StudentRegistrationState());

  final EnrollmentService _enrollmentService;

  void _safeEmit(StudentRegistrationState nextState) {
    if (isClosed) return;
    emit(nextState);
  }

  Future<void> load() async {
    _safeEmit(
      state.copyWith(
        isInitialLoading: true,
        isRefreshing: false,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );
    await _fetchRegistrationData();
  }

  Future<void> refresh() async {
    _safeEmit(
      state.copyWith(
        isRefreshing: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );
    await _fetchRegistrationData();
  }

  void setSearchQuery(String value) {
    _safeEmit(state.copyWith(searchQuery: value));
  }

  void setDepartment(String value) {
    _safeEmit(state.copyWith(selectedDepartment: value));
  }

  void setLevel(String value) {
    _safeEmit(state.copyWith(selectedLevel: value));
  }

  void selectCourse(int? courseId) {
    _safeEmit(
      state.copyWith(selectedCourseId: courseId, clearSelectedSectionId: true),
    );
  }

  void selectSection(int? sectionId) {
    _safeEmit(state.copyWith(selectedSectionId: sectionId));
  }

  Future<bool> enrollSelectedSection() async {
    final int? sectionId = state.selectedSectionId;
    if (sectionId == null || sectionId <= 0) {
      _safeEmit(
        state.copyWith(
          errorMessage: 'Please select a section first.',
          clearSuccessMessage: true,
        ),
      );
      return false;
    }

    _safeEmit(
      state.copyWith(
        isEnrolling: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _enrollmentService.registerForSection(
      sectionId: sectionId,
    );
    if (isClosed) return false;

    if (!result.isSuccess) {
      _safeEmit(
        state.copyWith(
          isEnrolling: false,
          errorMessage: result.error?.message ?? 'Failed to enroll in section.',
        ),
      );
      return false;
    }

    await _fetchRegistrationData(
      successMessage: 'Successfully enrolled.',
      keepMutationLoading: true,
      clearSelectedSectionId: true,
    );
    _safeEmit(state.copyWith(isEnrolling: false));
    return true;
  }

  Future<bool> dropEnrollment(dynamic enrollmentId) async {
    final String idValue = enrollmentId?.toString() ?? '';
    if (idValue.isEmpty) {
      _safeEmit(
        state.copyWith(
          errorMessage: 'Invalid enrollment id.',
          clearSuccessMessage: true,
        ),
      );
      return false;
    }

    _safeEmit(
      state.copyWith(
        isDropping: true,
        activeDropEnrollmentId: idValue,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _enrollmentService.dropEnrollment(idValue);
    if (isClosed) return false;
    if (!result.isSuccess) {
      _safeEmit(
        state.copyWith(
          isDropping: false,
          clearDropId: true,
          errorMessage: result.error?.message ?? 'Failed to drop course.',
        ),
      );
      return false;
    }

    await _fetchRegistrationData(
      successMessage: 'Course dropped successfully.',
      keepMutationLoading: true,
      clearSelectedSectionId: true,
    );
    _safeEmit(state.copyWith(isDropping: false, clearDropId: true));
    return true;
  }

  void clearMessages() {
    _safeEmit(
      state.copyWith(clearErrorMessage: true, clearSuccessMessage: true),
    );
  }

  Future<void> _fetchRegistrationData({
    String? successMessage,
    bool keepMutationLoading = false,
    bool clearSelectedSectionId = false,
  }) async {
    late final List<dynamic> results;
    try {
      results = await Future.wait<dynamic>(<Future<dynamic>>[
        _enrollmentService.getMyEnrollments(),
        _enrollmentService.getAvailableCourses(),
        _enrollmentService.getEnrollmentPeriods(),
      ]);
      if (isClosed) return;
    } catch (error) {
      if (isClosed) return;
      _safeEmit(
        state.copyWith(
          isInitialLoading: false,
          isRefreshing: false,
          isEnrolling: keepMutationLoading ? state.isEnrolling : false,
          isDropping: keepMutationLoading ? state.isDropping : false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
          clearSuccessMessage: successMessage == null,
          successMessage: successMessage,
          clearSelectedSectionId: clearSelectedSectionId,
          clearDropId: !keepMutationLoading,
        ),
      );
      return;
    }

    final ServiceResult<List<CourseEnrollmentModel>> enrolledResult =
        results[0] as ServiceResult<List<CourseEnrollmentModel>>;
    final ServiceResult<List<RegistrationAvailableCourseModel>>
    availableResult =
        results[1] as ServiceResult<List<RegistrationAvailableCourseModel>>;
    final ServiceResult<List<EnrollmentPeriodModel>> periodsResult =
        results[2] as ServiceResult<List<EnrollmentPeriodModel>>;

    final List<CourseEnrollmentModel> enrolledCourses =
        enrolledResult.data ?? state.enrolledCourses;
    final List<RegistrationAvailableCourseModel> availableCourses =
        availableResult.data ?? state.availableCourses;
    final List<EnrollmentPeriodModel> enrollmentPeriods =
        periodsResult.data ?? state.enrollmentPeriods;

    final String? firstError =
        enrolledResult.error?.message ??
        availableResult.error?.message ??
        periodsResult.error?.message;

    if (firstError != null && firstError.isNotEmpty) {
      _safeEmit(
        state.copyWith(
          availableCourses: List.unmodifiable(availableCourses),
          enrolledCourses: List.unmodifiable(enrolledCourses),
          enrollmentPeriods: List.unmodifiable(enrollmentPeriods),
          isInitialLoading: false,
          isRefreshing: false,
          errorMessage: firstError,
          clearSuccessMessage: successMessage == null,
          successMessage: successMessage,
          clearSelectedSectionId: clearSelectedSectionId,
        ),
      );
      return;
    }

    _safeEmit(
      state.copyWith(
        availableCourses: List.unmodifiable(availableCourses),
        enrolledCourses: List.unmodifiable(enrolledCourses),
        enrollmentPeriods: List.unmodifiable(enrollmentPeriods),
        isInitialLoading: false,
        isRefreshing: false,
        clearErrorMessage: true,
        successMessage: successMessage,
        clearSuccessMessage: successMessage == null,
        clearSelectedSectionId: clearSelectedSectionId,
      ),
    );

    if (!keepMutationLoading) {
      _safeEmit(
        state.copyWith(
          isEnrolling: false,
          isDropping: false,
          clearDropId: true,
        ),
      );
    }
  }
}
