import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/assignments/assignment_form_data.dart';
import '../../models/assignments/assignment_model.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../models/core/paginated_response.dart';
import '../../services/api/assignment_service.dart';
import '../../services/api/enrollment_service.dart';
import 'instructor_assignments_state.dart';

class InstructorAssignmentsCubit extends Cubit<InstructorAssignmentsState>
    with SafeRouteCubitMixin<InstructorAssignmentsState> {
  InstructorAssignmentsCubit({
    required AssignmentService assignmentService,
    required EnrollmentService enrollmentService,
  }) : _assignmentService = assignmentService,
       _enrollmentService = enrollmentService,
       super(const InstructorAssignmentsState());

  final AssignmentService _assignmentService;
  final EnrollmentService _enrollmentService;

  late final RouteRequestController _coursesRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _assignmentsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _mutationRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _submissionsRequest = trackRouteRequest(
    RouteRequestController(),
  );

  Future<void> loadTeachingCourses({int? preferredCourseId}) async {
    final requestId = _coursesRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final result = await _enrollmentService.getTeachingCourses(
      cancelToken: _coursesRequest.token,
    );
    if (!isRequestCurrent(_coursesRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage:
              result.error?.message ?? 'Failed to load teaching courses',
        ),
      );
      return;
    }

    final courses = result.data!;
    int? selectedCourseId = state.selectedCourseId;

    final hasPreferred =
        preferredCourseId != null &&
        courses.any((course) => course.courseId == preferredCourseId);
    if (hasPreferred) {
      selectedCourseId = preferredCourseId;
    }

    final hasSelected =
        selectedCourseId != null &&
        courses.any((course) => course.courseId == selectedCourseId);
    if (!hasSelected) {
      selectedCourseId = hasPreferred ? preferredCourseId : null;
    }

    emitIfOpen(
      state.copyWith(
        teachingCourses: courses,
        selectedCourseId: selectedCourseId,
        isLoading: false,
        clearError: true,
      ),
    );

    await loadAssignments(page: 1, limit: 20);
  }

  Future<void> selectCourse(int? courseId) async {
    emitIfOpen(
      state.copyWith(
        selectedCourseId: courseId,
        currentPage: 1,
        hasMorePages: false,
        clearAssignments: true,
        clearError: true,
      ),
    );

    await loadAssignments(page: 1, limit: 20);
  }

  Future<void> loadAssignments({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    final courseId = state.selectedCourseId;

    final requestId = _assignmentsRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    if (courseId != null) {
      final result = await _assignmentService.getAll(
        courseId: courseId,
        page: page,
        limit: limit,
        status: state.statusFilter,
        sortBy: 'dueDate',
        sortOrder: 'ASC',
        cancelToken: _assignmentsRequest.token,
      );
      if (!isRequestCurrent(_assignmentsRequest, requestId)) {
        return;
      }

      if (!result.isSuccess || result.data == null) {
        emitIfOpen(
          state.copyWith(
            isLoading: false,
            errorMessage: result.error?.message ?? 'Failed to load assignments',
          ),
        );
        return;
      }

      final fetchedPage = result.data!;
      final mergedItems = page == 1 || refresh
          ? fetchedPage.data
          : <AssignmentModel>[
              ...(state.assignments?.data ?? const <AssignmentModel>[]),
              ...fetchedPage.data,
            ];

      final mergedPage = PaginatedResponse<AssignmentModel>(
        data: mergedItems,
        total: fetchedPage.total,
        page: fetchedPage.page,
        limit: fetchedPage.limit,
        totalPages: fetchedPage.totalPages,
      );

      emitIfOpen(
        state.copyWith(
          assignments: mergedPage,
          currentPage: fetchedPage.page,
          hasMorePages: fetchedPage.hasNextPage,
          isLoading: false,
          clearError: true,
        ),
      );
      return;
    }

    final courseIds = state.teachingCourses
        .map((course) => course.courseId)
        .where((id) => id > 0)
        .toSet()
        .toList(growable: false);

    if (courseIds.isEmpty) {
      emitIfOpen(
        state.copyWith(
          assignments: const PaginatedResponse<AssignmentModel>(
            data: <AssignmentModel>[],
            total: 0,
            page: 1,
            limit: 20,
            totalPages: 0,
          ),
          currentPage: page,
          hasMorePages: false,
          isLoading: false,
          clearError: true,
        ),
      );
      return;
    }

    final results = await Future.wait(
      courseIds.map(
        (id) => _assignmentService.getAll(
          courseId: id,
          page: 1,
          limit: 100,
          status: state.statusFilter,
          sortBy: 'dueDate',
          sortOrder: 'ASC',
          cancelToken: _assignmentsRequest.token,
        ),
      ),
    );
    if (!isRequestCurrent(_assignmentsRequest, requestId)) {
      return;
    }

    final mergedById = <int, AssignmentModel>{};
    for (final result in results) {
      if (!result.isSuccess || result.data == null) {
        continue;
      }
      for (final assignment in result.data!.data) {
        mergedById[assignment.assignmentId] = assignment;
      }
    }

    final mergedItems = mergedById.values.toList(growable: false)
      ..sort((left, right) {
        final leftDue = left.dueDate;
        final rightDue = right.dueDate;
        final dueCompare = leftDue.compareTo(rightDue);
        if (dueCompare != 0) {
          return dueCompare;
        }
        return left.title.toLowerCase().compareTo(right.title.toLowerCase());
      });

    emitIfOpen(
      state.copyWith(
        assignments: PaginatedResponse<AssignmentModel>(
          data: mergedItems,
          total: mergedItems.length,
          page: page,
          limit: max(limit, mergedItems.length),
          totalPages: mergedItems.isEmpty ? 0 : page,
        ),
        currentPage: page,
        hasMorePages: false,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMorePages || state.isLoading) {
      return;
    }

    await loadAssignments(page: state.currentPage + 1, limit: 20);
  }

  Future<void> createAssignment(AssignmentFormData formData) async {
    final requestId = _mutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final result = await _assignmentService.create(
      formData.toJson(),
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to create assignment',
        ),
      );
      return;
    }

    final created = result.data!;
    final current = state.assignments;
    final updatedItems = <AssignmentModel>[
      created,
      ...(current?.data ?? const <AssignmentModel>[]),
    ];

    emitIfOpen(
      state.copyWith(
        assignments: PaginatedResponse<AssignmentModel>(
          data: updatedItems,
          total: (current?.total ?? 0) + 1,
          page: current?.page ?? 1,
          limit: current?.limit ?? 20,
          totalPages: current?.totalPages ?? 1,
        ),
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> updateAssignment(int id, AssignmentFormData formData) async {
    final requestId = _mutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final result = await _assignmentService.update(
      id,
      formData.toJson(),
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to update assignment',
        ),
      );
      return;
    }

    final updated = result.data!;
    final current = state.assignments;
    if (current == null) {
      emitIfOpen(state.copyWith(isLoading: false, clearError: true));
      return;
    }

    final replaced = current.data.map((item) {
      if (item.assignmentId == id || item.id == id.toString()) {
        return updated;
      }
      return item;
    }).toList();

    emitIfOpen(
      state.copyWith(
        assignments: PaginatedResponse<AssignmentModel>(
          data: replaced,
          total: current.total,
          page: current.page,
          limit: current.limit,
          totalPages: current.totalPages,
        ),
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> deleteAssignment(int id) async {
    final requestId = _mutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final result = await _assignmentService.delete(
      id,
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess) {
      final statusCode = result.error?.statusCode;
      final message = switch (statusCode) {
        403 => 'You are not allowed to delete this assignment',
        404 => 'Assignment not found or already deleted',
        _ => result.error?.message ?? 'Failed to delete assignment',
      };

      debugPrint(
        'InstructorAssignmentsCubit.deleteAssignment failed '
        '(id=$id, statusCode=$statusCode): ${result.error?.message}',
      );

      emitIfOpen(state.copyWith(isLoading: false, errorMessage: message));
      return;
    }

    final current = state.assignments;
    if (current == null) {
      emitIfOpen(state.copyWith(isLoading: false, clearError: true));
      return;
    }

    final remaining = current.data
        .where((item) => item.assignmentId != id && item.id != id.toString())
        .toList();

    emitIfOpen(
      state.copyWith(
        assignments: PaginatedResponse<AssignmentModel>(
          data: remaining,
          total: remaining.length,
          page: current.page,
          limit: current.limit,
          totalPages: current.totalPages,
        ),
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> updateStatus(int id, api.AssignmentStatus status) async {
    final requestId = _mutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final result = await _assignmentService.updateStatus(
      id,
      status,
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage:
              result.error?.message ?? 'Failed to update assignment status',
        ),
      );
      return;
    }

    final updated = result.data!;
    final current = state.assignments;
    if (current == null) {
      emitIfOpen(state.copyWith(isLoading: false, clearError: true));
      return;
    }

    final replaced = current.data.map((item) {
      if (item.assignmentId == id || item.id == id.toString()) {
        return updated;
      }
      return item;
    }).toList();

    emitIfOpen(
      state.copyWith(
        assignments: PaginatedResponse<AssignmentModel>(
          data: replaced,
          total: current.total,
          page: current.page,
          limit: current.limit,
          totalPages: current.totalPages,
        ),
        isLoading: false,
        clearError: true,
      ),
    );
  }

  void setSearchQuery(String query) {
    emitIfOpen(state.copyWith(searchQuery: query));
  }

  Future<void> setStatusFilter(api.AssignmentStatus? status) async {
    emitIfOpen(
      state.copyWith(statusFilter: status, currentPage: 1, hasMorePages: false),
    );
    await loadAssignments(page: 1, limit: 20);
  }

  Future<void> loadSubmissions(
    int assignmentId, {
    int page = 1,
    int limit = 20,
  }) async {
    final requestId = _submissionsRequest.begin();
    emitIfOpen(
      state.copyWith(
        submissionsLoading: true,
        activeSubmissionsAssignmentId: assignmentId,
        clearError: true,
        clearSubmissions: page == 1 && state.submissions.isEmpty,
      ),
    );

    final result = await _assignmentService.getSubmissions(
      assignmentId,
      cancelToken: _submissionsRequest.token,
    );
    if (!isRequestCurrent(_submissionsRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          submissionsLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load submissions',
        ),
      );
      return;
    }

    final all = result.data!.toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    final start = (page - 1) * limit;
    final end = min(start + limit, all.length);

    if (start >= all.length) {
      emitIfOpen(
        state.copyWith(
          submissionsLoading: false,
          submissionsPage: page,
          hasMoreSubmissions: false,
          clearError: true,
        ),
      );
      return;
    }

    final nextPageItems = all.sublist(start, end);
    final mergedItems = page == 1
        ? nextPageItems
        : <AssignmentSubmissionModel>[...state.submissions, ...nextPageItems];

    emitIfOpen(
      state.copyWith(
        submissions: mergedItems,
        submissionsPage: page,
        hasMoreSubmissions: end < all.length,
        submissionsLoading: false,
        clearError: true,
      ),
    );
  }

  List<AssignmentSubmissionModel> filterSubmissions(
    List<AssignmentSubmissionModel> source, {
    required String filter,
    String query = '',
  }) {
    final normalizedFilter = filter.trim().toLowerCase();
    final normalizedQuery = query.trim().toLowerCase();

    return source.where((item) {
      final first = item.user?.firstName.trim() ?? '';
      final last = item.user?.lastName.trim() ?? '';
      final studentName = '$first $last'.trim().toLowerCase();

      final matchesQuery =
          normalizedQuery.isEmpty || studentName.contains(normalizedQuery);

      final isGraded =
          item.submissionStatus == api.SubmissionStatus.graded ||
          item.submissionStatus == api.SubmissionStatus.returned;
      final isUngraded =
          item.submissionStatus == api.SubmissionStatus.submitted ||
          item.submissionStatus == api.SubmissionStatus.resubmit ||
          item.submissionStatus == api.SubmissionStatus.unknown;

      final matchesFilter =
          normalizedFilter == 'all' ||
          (normalizedFilter == 'graded' && isGraded) ||
          (normalizedFilter == 'ungraded' && isUngraded) ||
          (normalizedFilter == 'late' && item.isLate);

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<AssignmentSubmissionModel> filterActiveSubmissions({
    String filter = 'all',
    String query = '',
  }) {
    return filterSubmissions(state.submissions, filter: filter, query: query);
  }

  Future<void> gradeSubmission(
    int submissionId,
    double score,
    String? feedback,
  ) async {
    final assignmentId = state.activeSubmissionsAssignmentId;
    if (assignmentId == null) {
      emitIfOpen(
        state.copyWith(errorMessage: 'No assignment selected for grading'),
      );
      return;
    }

    final requestId = _mutationRequest.begin();
    emitIfOpen(state.copyWith(submissionsLoading: true, clearError: true));

    final result = await _assignmentService.gradeSubmission(
      assignmentId,
      submissionId,
      score,
      feedback: feedback,
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          submissionsLoading: false,
          errorMessage: result.error?.message ?? 'Failed to save grade',
        ),
      );
      return;
    }

    final updatedSubmissions = state.submissions.map((submission) {
      if (submission.id != submissionId) {
        return submission;
      }

      return AssignmentSubmissionModel(
        id: submission.id,
        assignmentId: submission.assignmentId,
        userId: submission.userId,
        submissionText: submission.submissionText,
        submissionLink: submission.submissionLink,
        fileId: submission.fileId,
        submissionStatus: api.SubmissionStatus.graded,
        isLate: submission.isLate,
        attemptNumber: submission.attemptNumber,
        submittedAt: submission.submittedAt,
        score: score,
        feedback: feedback,
        gradedBy: submission.gradedBy,
        gradedAt: DateTime.now(),
        user: submission.user,
        driveFile: submission.driveFile,
      );
    }).toList();

    emitIfOpen(
      state.copyWith(
        submissions: updatedSubmissions,
        submissionsLoading: false,
        clearError: true,
      ),
    );
  }
}
