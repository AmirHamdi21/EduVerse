import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../common/service_error.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../models/core/enums/lab_enums.dart' as api;
import '../../models/labs/lab_model.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/lab_service.dart';
import 'instructor_labs_state.dart';

class InstructorLabsCubit extends Cubit<InstructorLabsState>
    with SafeRouteCubitMixin<InstructorLabsState> {
  InstructorLabsCubit({
    required LabService labService,
    required EnrollmentService enrollmentService,
  }) : _labService = labService,
       _enrollmentService = enrollmentService,
       super(const InstructorLabsInitial());

  final LabService _labService;
  final EnrollmentService _enrollmentService;
  late final RouteRequestController _coursesRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _labsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _mutationRequest = trackRouteRequest(
    RouteRequestController(),
  );

  List<LabModel> _labs = <LabModel>[];
  List<TeachingCourseModel> _teachingCourses = <TeachingCourseModel>[];
  int? _selectedCourseId;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  int _currentPage = 1;
  bool _hasMorePages = false;

  Future<void> initialize({int? preferredCourseId}) async {
    await loadTeachingCourses(preferredCourseId: preferredCourseId);
    await loadLabs(
      courseId: (preferredCourseId ?? _selectedCourseId)?.toString(),
    );
  }

  Future<void> loadTeachingCourses({int? preferredCourseId}) async {
    final requestId = _coursesRequest.begin();
    final result = await _enrollmentService.getTeachingCourses(
      cancelToken: _coursesRequest.token,
    );
    if (!isRequestCurrent(_coursesRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      if (state is! InstructorLabsLoaded) {
        emitIfOpen(
          InstructorLabsError(
            message: result.error?.message ?? 'Failed to load teaching courses',
          ),
        );
      }
      return;
    }

    _teachingCourses = result.data!;

    final hasPreferred =
        preferredCourseId != null &&
        _teachingCourses.any((course) => course.courseId == preferredCourseId);

    if (hasPreferred) {
      _selectedCourseId = preferredCourseId;
    } else if (_selectedCourseId != null &&
        _teachingCourses.any(
          (course) => course.courseId == _selectedCourseId,
        )) {
      // Keep existing selection.
    } else {
      _selectedCourseId = _teachingCourses.isNotEmpty
          ? _teachingCourses.first.courseId
          : null;
    }
  }

  Future<void> selectCourse(int? courseId) async {
    _selectedCourseId = courseId;
    await loadLabs(courseId: courseId?.toString());
  }

  Future<void> loadLabs({String? courseId}) async {
    final requestId = _labsRequest.begin();
    emitIfOpen(const InstructorLabsLoading());

    final parsedCourseId = courseId != null
        ? int.tryParse(courseId)
        : _selectedCourseId;
    _selectedCourseId = parsedCourseId;

    final result = await _labService.getAllPaginated(
      courseId: parsedCourseId,
      page: 1,
      limit: 50,
      cancelToken: _labsRequest.token,
    );
    if (!isRequestCurrent(_labsRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        InstructorLabsError(
          message: result.error?.message ?? 'Failed to load labs',
        ),
      );
      return;
    }

    _labs = result.data!.data;
    _currentPage = result.data!.page;
    _hasMorePages = result.data!.hasNextPage;

    _emitLoaded();
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! InstructorLabsLoaded) {
      return;
    }
    if (!_hasMorePages || currentState.isLoadingMore) {
      return;
    }

    emitIfOpen(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;
    final requestId = _labsRequest.begin();
    final result = await _labService.getAllPaginated(
      courseId: _selectedCourseId,
      page: nextPage,
      limit: 50,
      cancelToken: _labsRequest.token,
    );
    if (!isRequestCurrent(_labsRequest, requestId)) {
      return;
    }

    final refreshedState = state;
    if (refreshedState is! InstructorLabsLoaded) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(refreshedState.copyWith(isLoadingMore: false));
      return;
    }

    _labs = <LabModel>[..._labs, ...result.data!.data];
    _currentPage = result.data!.page;
    _hasMorePages = result.data!.hasNextPage;

    _emitLoaded(isLoadingMore: false);
  }

  void filterLabs({String? searchQuery, String? status}) {
    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }
    if (status != null) {
      _selectedStatus = status.toLowerCase();
    }
    _emitLoaded();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = 'all';
    _emitLoaded();
  }

  Future<String?> createLab(Map<String, dynamic> data) async {
    final result = await createLabRecord(data);
    if (!result.isSuccess) {
      return result.error?.message ?? 'Failed to create lab';
    }
    return null;
  }

  Future<ServiceResult<LabModel>> createLabRecord(
    Map<String, dynamic> data,
  ) async {
    final requestId = _mutationRequest.begin();
    final result = await _labService.create(
      data,
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return ServiceResult<LabModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'Lab save request was interrupted',
        ),
      );
    }
    if (!result.isSuccess || result.data == null) {
      return ServiceResult<LabModel>.failure(
        result.error ??
            const ServiceError(
              type: ServiceErrorType.server,
              message: 'Failed to create lab',
            ),
      );
    }

    final created = result.data!;
    if (_selectedCourseId == null || created.courseId == _selectedCourseId) {
      _labs = <LabModel>[created, ..._labs];
      _emitLoaded();
    }

    return ServiceResult<LabModel>.success(created);
  }

  Future<String?> updateLab(String labId, Map<String, dynamic> data) async {
    final result = await updateLabRecord(labId, data);
    if (!result.isSuccess) {
      return result.error?.message ?? 'Failed to update lab';
    }
    return null;
  }

  Future<ServiceResult<LabModel>> updateLabRecord(
    String labId,
    Map<String, dynamic> data,
  ) async {
    final id = int.tryParse(labId) ?? labId;
    final requestId = _mutationRequest.begin();
    final result = await _labService.update(
      id,
      data,
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return ServiceResult<LabModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'Lab update request was interrupted',
        ),
      );
    }
    if (!result.isSuccess || result.data == null) {
      return ServiceResult<LabModel>.failure(
        result.error ??
            const ServiceError(
              type: ServiceErrorType.server,
              message: 'Failed to update lab',
            ),
      );
    }

    final updated = result.data!;
    _labs = _labs
        .map((lab) {
          if (_matchesLabId(lab, labId)) {
            return updated;
          }
          return lab;
        })
        .toList(growable: false);
    _emitLoaded();

    return ServiceResult<LabModel>.success(updated);
  }

  Future<String?> deleteLab(String labId) async {
    final id = int.tryParse(labId) ?? labId;
    final requestId = _mutationRequest.begin();
    final result = await _labService.delete(
      id,
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return null;
    }
    if (!result.isSuccess) {
      return result.error?.message ?? 'Failed to delete lab';
    }

    _labs = _labs
        .where((lab) => !_matchesLabId(lab, labId))
        .toList(growable: false);
    _emitLoaded();

    return null;
  }

  Future<String?> updateStatus(String labId, api.LabStatus status) async {
    final id = int.tryParse(labId) ?? labId;
    final requestId = _mutationRequest.begin();
    final result = await _labService.updateStatus(
      id,
      status,
      cancelToken: _mutationRequest.token,
    );
    if (!isRequestCurrent(_mutationRequest, requestId)) {
      return null;
    }
    if (!result.isSuccess || result.data == null) {
      return result.error?.message ?? 'Failed to update lab status';
    }

    final updated = result.data!;
    _labs = _labs
        .map((lab) => _matchesLabId(lab, labId) ? updated : lab)
        .toList(growable: false);
    _emitLoaded();

    return null;
  }

  void _emitLoaded({bool isLoadingMore = false}) {
    final filtered = _applyFilters(_labs);

    emitIfOpen(
      InstructorLabsLoaded(
        labs: _labs,
        filteredLabs: filtered,
        searchQuery: _searchQuery,
        selectedStatus: _selectedStatus,
        currentPage: _currentPage,
        hasMorePages: _hasMorePages,
        isLoadingMore: isLoadingMore,
        teachingCourses: _teachingCourses,
        selectedCourseId: _selectedCourseId,
      ),
    );
  }

  List<LabModel> _applyFilters(List<LabModel> source) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return source
        .where((lab) {
          final matchesStatus =
              _selectedStatus == 'all' || lab.status.value == _selectedStatus;

          if (!matchesStatus) {
            return false;
          }

          if (normalizedQuery.isEmpty) {
            return true;
          }

          final title = lab.title.toLowerCase();
          final description = (lab.description ?? '').toLowerCase();
          final courseName = (lab.course?.name ?? '').toLowerCase();

          return title.contains(normalizedQuery) ||
              description.contains(normalizedQuery) ||
              courseName.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  bool _matchesLabId(LabModel lab, String rawLabId) {
    if (lab.id == rawLabId) {
      return true;
    }

    final parsed = int.tryParse(rawLabId);
    if (parsed == null) {
      return false;
    }

    return lab.labId == parsed;
  }
}
