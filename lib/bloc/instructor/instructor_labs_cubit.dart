import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/instructor/teaching_course_model.dart';
import '../../models/labs/lab_model.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/lab_service.dart';
import 'instructor_labs_state.dart';

class InstructorLabsCubit extends Cubit<InstructorLabsState> {
  InstructorLabsCubit({
    required LabService labService,
    required EnrollmentService enrollmentService,
  }) : _labService = labService,
       _enrollmentService = enrollmentService,
       super(const InstructorLabsInitial());

  final LabService _labService;
  final EnrollmentService _enrollmentService;

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
    final result = await _enrollmentService.getTeachingCourses();
    if (!result.isSuccess || result.data == null) {
      if (state is! InstructorLabsLoaded) {
        emit(
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
    emit(const InstructorLabsLoading());

    final parsedCourseId = courseId != null
        ? int.tryParse(courseId)
        : _selectedCourseId;
    _selectedCourseId = parsedCourseId;

    final result = await _labService.getAllPaginated(
      courseId: parsedCourseId,
      page: 1,
      limit: 50,
    );

    if (!result.isSuccess || result.data == null) {
      emit(
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

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;
    final result = await _labService.getAllPaginated(
      courseId: _selectedCourseId,
      page: nextPage,
      limit: 50,
    );

    final refreshedState = state;
    if (refreshedState is! InstructorLabsLoaded) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(refreshedState.copyWith(isLoadingMore: false));
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
    final result = await _labService.create(data);
    if (!result.isSuccess || result.data == null) {
      return result.error?.message ?? 'Failed to create lab';
    }

    final created = result.data!;
    if (_selectedCourseId == null || created.courseId == _selectedCourseId) {
      _labs = <LabModel>[created, ..._labs];
      _emitLoaded();
    }

    return null;
  }

  Future<String?> updateLab(String labId, Map<String, dynamic> data) async {
    final id = int.tryParse(labId) ?? labId;
    final result = await _labService.update(id, data);
    if (!result.isSuccess || result.data == null) {
      return result.error?.message ?? 'Failed to update lab';
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

    return null;
  }

  Future<String?> deleteLab(String labId) async {
    final id = int.tryParse(labId) ?? labId;
    final result = await _labService.delete(id);
    if (!result.isSuccess) {
      return result.error?.message ?? 'Failed to delete lab';
    }

    _labs = _labs
        .where((lab) => !_matchesLabId(lab, labId))
        .toList(growable: false);
    _emitLoaded();

    return null;
  }

  void _emitLoaded({bool isLoadingMore = false}) {
    final filtered = _applyFilters(_labs);

    emit(
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
