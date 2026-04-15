import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/core/enums/course_enums.dart';
import '../../models/courses/course_model.dart';
import '../../models/courses/instructor_assignment_model.dart';
import '../../models/courses/schedule_model.dart';
import '../../models/courses/section_model.dart';
import '../../models/ta/ta_assignment_model.dart';
import '../../services/api/course_service.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/schedule_service.dart';
import '../../services/api/section_service.dart';

enum CourseListStatus { initial, loading, success, failure }

class CourseListState extends Equatable {
  static const Object _unset = Object();

  final CourseListStatus status;
  final List<CourseModel> courses;
  final List<CourseModel> filteredCourses;
  final Map<int, List<SectionModel>> sectionsByCourse;
  final Map<int, List<ScheduleModel>> schedulesByCourse;
  final Map<int, List<InstructorAssignmentModel>> staffByCourse;
  final int? selectedCourseId;
  final String selectedFilter;
  final String searchQuery;
  final String sortBy;
  final bool sortAscending;
  final String? selectedDepartment;
  final bool isDetailsLoading;
  final String? errorMessage;
  final String? detailsErrorMessage;

  const CourseListState({
    this.status = CourseListStatus.initial,
    this.courses = const <CourseModel>[],
    this.filteredCourses = const <CourseModel>[],
    this.sectionsByCourse = const <int, List<SectionModel>>{},
    this.schedulesByCourse = const <int, List<ScheduleModel>>{},
    this.staffByCourse = const <int, List<InstructorAssignmentModel>>{},
    this.selectedCourseId,
    this.selectedFilter = 'all',
    this.searchQuery = '',
    this.sortBy = 'name',
    this.sortAscending = true,
    this.selectedDepartment,
    this.isDetailsLoading = false,
    this.errorMessage,
    this.detailsErrorMessage,
  });

  CourseListState copyWith({
    CourseListStatus? status,
    List<CourseModel>? courses,
    List<CourseModel>? filteredCourses,
    Map<int, List<SectionModel>>? sectionsByCourse,
    Map<int, List<ScheduleModel>>? schedulesByCourse,
    Map<int, List<InstructorAssignmentModel>>? staffByCourse,
    Object? selectedCourseId = _unset,
    String? selectedFilter,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    Object? selectedDepartment = _unset,
    bool? isDetailsLoading,
    Object? errorMessage = _unset,
    Object? detailsErrorMessage = _unset,
  }) {
    return CourseListState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      sectionsByCourse: sectionsByCourse ?? this.sectionsByCourse,
      schedulesByCourse: schedulesByCourse ?? this.schedulesByCourse,
      staffByCourse: staffByCourse ?? this.staffByCourse,
      selectedCourseId: selectedCourseId == _unset
          ? this.selectedCourseId
          : selectedCourseId as int?,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      selectedDepartment: selectedDepartment == _unset
          ? this.selectedDepartment
          : selectedDepartment as String?,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      detailsErrorMessage: detailsErrorMessage == _unset
          ? this.detailsErrorMessage
          : detailsErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    courses,
    filteredCourses,
    sectionsByCourse,
    schedulesByCourse,
    staffByCourse,
    selectedCourseId,
    selectedFilter,
    searchQuery,
    sortBy,
    sortAscending,
    selectedDepartment,
    isDetailsLoading,
    errorMessage,
    detailsErrorMessage,
  ];
}

abstract class CourseListEvent extends Equatable {
  const CourseListEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadCourses extends CourseListEvent {
  final bool forceRefresh;

  const LoadCourses({this.forceRefresh = false});

  @override
  List<Object?> get props => <Object?>[forceRefresh];
}

class FilterCourses extends CourseListEvent {
  final String? selectedFilter;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final String? selectedDepartment;

  const FilterCourses({
    this.selectedFilter,
    this.searchQuery,
    this.sortBy,
    this.sortAscending,
    this.selectedDepartment,
  });

  @override
  List<Object?> get props => <Object?>[
    selectedFilter,
    searchQuery,
    sortBy,
    sortAscending,
    selectedDepartment,
  ];
}

class SelectCourse extends CourseListEvent {
  final int? courseId;

  const SelectCourse(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadCourseDetails extends CourseListEvent {
  final int courseId;
  final bool forceRefresh;

  const LoadCourseDetails(this.courseId, {this.forceRefresh = false});

  @override
  List<Object?> get props => <Object?>[courseId, forceRefresh];
}

class DeleteCourse extends CourseListEvent {
  final int courseId;

  const DeleteCourse(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class CourseListBloc extends Bloc<CourseListEvent, CourseListState> {
  final CourseService _courseService;
  final SectionService _sectionService;
  final ScheduleService _scheduleService;
  final EnrollmentService _enrollmentService;

  CourseListBloc({
    required CourseService courseService,
    required SectionService sectionService,
    required ScheduleService scheduleService,
    required EnrollmentService enrollmentService,
  }) : _courseService = courseService,
       _sectionService = sectionService,
       _scheduleService = scheduleService,
       _enrollmentService = enrollmentService,
       super(const CourseListState()) {
    on<LoadCourses>(_onLoadCourses);
    on<FilterCourses>(_onFilterCourses);
    on<SelectCourse>(_onSelectCourse);
    on<LoadCourseDetails>(_onLoadCourseDetails);
    on<DeleteCourse>(_onDeleteCourse);
  }

  Future<void> _onLoadCourses(
    LoadCourses event,
    Emitter<CourseListState> emit,
  ) async {
    emit(state.copyWith(status: CourseListStatus.loading, errorMessage: null));

    try {
      final courses = await _courseService.getAllCourses();
      final filtered = _applyFilters(
        courses: courses,
        selectedFilter: state.selectedFilter,
        searchQuery: state.searchQuery,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        selectedDepartment: state.selectedDepartment,
        sectionsByCourse: state.sectionsByCourse,
        staffByCourse: state.staffByCourse,
      );

      int? selectedCourseId = state.selectedCourseId;
      if (selectedCourseId == null ||
          !filtered.any((course) => course.id == selectedCourseId)) {
        selectedCourseId = filtered.isEmpty ? null : filtered.first.id;
      }

      emit(
        state.copyWith(
          status: CourseListStatus.success,
          courses: courses,
          filteredCourses: filtered,
          selectedCourseId: selectedCourseId,
          errorMessage: null,
        ),
      );

      if (selectedCourseId != null) {
        add(LoadCourseDetails(selectedCourseId));
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: CourseListStatus.failure,
          errorMessage: _toErrorMessage(error),
        ),
      );
    }
  }

  void _onFilterCourses(FilterCourses event, Emitter<CourseListState> emit) {
    final selectedFilter = event.selectedFilter ?? state.selectedFilter;
    final searchQuery = event.searchQuery ?? state.searchQuery;
    final sortBy = event.sortBy ?? state.sortBy;
    final sortAscending = event.sortAscending ?? state.sortAscending;

    final selectedDepartment = event.selectedDepartment == ''
        ? null
        : (event.selectedDepartment ?? state.selectedDepartment);

    final filtered = _applyFilters(
      courses: state.courses,
      selectedFilter: selectedFilter,
      searchQuery: searchQuery,
      sortBy: sortBy,
      sortAscending: sortAscending,
      selectedDepartment: selectedDepartment,
      sectionsByCourse: state.sectionsByCourse,
      staffByCourse: state.staffByCourse,
    );

    int? selectedCourseId = state.selectedCourseId;
    if (selectedCourseId == null ||
        !filtered.any((course) => course.id == selectedCourseId)) {
      selectedCourseId = filtered.isEmpty ? null : filtered.first.id;
    }

    emit(
      state.copyWith(
        selectedFilter: selectedFilter,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortAscending: sortAscending,
        selectedDepartment: selectedDepartment,
        filteredCourses: filtered,
        selectedCourseId: selectedCourseId,
      ),
    );

    if (selectedCourseId != null &&
        !state.sectionsByCourse.containsKey(selectedCourseId)) {
      add(LoadCourseDetails(selectedCourseId));
    }
  }

  void _onSelectCourse(SelectCourse event, Emitter<CourseListState> emit) {
    emit(state.copyWith(selectedCourseId: event.courseId));
    if (event.courseId != null &&
        !state.sectionsByCourse.containsKey(event.courseId)) {
      add(LoadCourseDetails(event.courseId!));
    }
  }

  Future<void> _onLoadCourseDetails(
    LoadCourseDetails event,
    Emitter<CourseListState> emit,
  ) async {
    if (!event.forceRefresh &&
        state.sectionsByCourse.containsKey(event.courseId) &&
        state.schedulesByCourse.containsKey(event.courseId) &&
        state.staffByCourse.containsKey(event.courseId)) {
      return;
    }

    emit(state.copyWith(isDetailsLoading: true, detailsErrorMessage: null));

    final sectionsResult = await _sectionService.getByCourse(event.courseId);
    if (sectionsResult.isFailure || sectionsResult.data == null) {
      emit(
        state.copyWith(
          isDetailsLoading: false,
          detailsErrorMessage:
              sectionsResult.error?.message ?? 'Failed to load course details',
        ),
      );
      return;
    }

    final sections = sectionsResult.data!;
    final schedules = <ScheduleModel>[];
    final staffAssignments = <InstructorAssignmentModel>[];

    for (final section in sections) {
      final scheduleResult = await _scheduleService.getBySection(section.id);
      if (scheduleResult.isSuccess && scheduleResult.data != null) {
        schedules.addAll(scheduleResult.data!);
      }

      final instructorsResult = await _enrollmentService.getSectionInstructors(
        section.id,
      );
      if (instructorsResult.isSuccess && instructorsResult.data != null) {
        for (final assignment in instructorsResult.data!) {
          staffAssignments.add(
            InstructorAssignmentModel(
              id: assignment.id,
              sectionId: assignment.sectionId,
              userId: assignment.userId,
              role: assignment.role,
              responsibilities: null,
              assignedAt: null,
              firstName: assignment.user?.firstName ?? '',
              lastName: assignment.user?.lastName ?? '',
              email: assignment.user?.email ?? '',
            ),
          );
        }
      }

      final taResult = await _enrollmentService.getSectionTAs(section.id);
      if (taResult.isSuccess && taResult.data != null) {
        for (final ta in taResult.data!) {
          staffAssignments.add(_taToInstructorAssignment(ta));
        }
      }
    }

    final nextSections = Map<int, List<SectionModel>>.from(
      state.sectionsByCourse,
    )..[event.courseId] = sections;

    final nextSchedules = Map<int, List<ScheduleModel>>.from(
      state.schedulesByCourse,
    )..[event.courseId] = schedules;

    final nextStaff = Map<int, List<InstructorAssignmentModel>>.from(
      state.staffByCourse,
    )..[event.courseId] = staffAssignments;

    final filtered = _applyFilters(
      courses: state.courses,
      selectedFilter: state.selectedFilter,
      searchQuery: state.searchQuery,
      sortBy: state.sortBy,
      sortAscending: state.sortAscending,
      selectedDepartment: state.selectedDepartment,
      sectionsByCourse: nextSections,
      staffByCourse: nextStaff,
    );

    emit(
      state.copyWith(
        sectionsByCourse: nextSections,
        schedulesByCourse: nextSchedules,
        staffByCourse: nextStaff,
        filteredCourses: filtered,
        isDetailsLoading: false,
        detailsErrorMessage: null,
      ),
    );
  }

  Future<void> _onDeleteCourse(
    DeleteCourse event,
    Emitter<CourseListState> emit,
  ) async {
    final result = await _courseService.softDeleteCourse(event.courseId);
    if (result.isFailure) {
      emit(
        state.copyWith(
          errorMessage: result.error?.message ?? 'Failed to delete course',
        ),
      );
      return;
    }

    final remaining = state.courses
        .where((course) => course.id != event.courseId)
        .toList();

    final filtered = _applyFilters(
      courses: remaining,
      selectedFilter: state.selectedFilter,
      searchQuery: state.searchQuery,
      sortBy: state.sortBy,
      sortAscending: state.sortAscending,
      selectedDepartment: state.selectedDepartment,
      sectionsByCourse: state.sectionsByCourse,
      staffByCourse: state.staffByCourse,
    );

    int? selectedCourseId = state.selectedCourseId;
    if (selectedCourseId == event.courseId ||
        (selectedCourseId != null &&
            !filtered.any((course) => course.id == selectedCourseId))) {
      selectedCourseId = filtered.isEmpty ? null : filtered.first.id;
    }

    emit(
      state.copyWith(
        courses: remaining,
        filteredCourses: filtered,
        selectedCourseId: selectedCourseId,
      ),
    );

    add(const LoadCourses(forceRefresh: true));
  }

  List<CourseModel> _applyFilters({
    required List<CourseModel> courses,
    required String selectedFilter,
    required String searchQuery,
    required String sortBy,
    required bool sortAscending,
    required String? selectedDepartment,
    required Map<int, List<SectionModel>> sectionsByCourse,
    required Map<int, List<InstructorAssignmentModel>> staffByCourse,
  }) {
    final query = searchQuery.trim().toLowerCase();

    final filtered = courses.where((course) {
      if (selectedDepartment != null &&
          selectedDepartment.isNotEmpty &&
          (course.departmentName ?? '') != selectedDepartment) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchesQuery =
            course.name.toLowerCase().contains(query) ||
            course.code.toLowerCase().contains(query) ||
            (course.departmentName ?? '').toLowerCase().contains(query);

        if (!matchesQuery) {
          return false;
        }
      }

      switch (selectedFilter) {
        case 'active':
          return course.courseStatus == CourseStatus.active;
        case 'inactive':
          return course.courseStatus == CourseStatus.inactive;
        case 'needs_instructor':
          return !_hasInstructor(course, staffByCourse);
        case 'needs_ta':
          return !_hasTeachingAssistant(course, staffByCourse);
        case 'ai_flagged':
          return course.courseStatus == CourseStatus.inactive ||
              !_hasInstructor(course, staffByCourse) ||
              !_hasTeachingAssistant(course, staffByCourse);
        case 'lab_based':
          final sections = sectionsByCourse[course.id] ?? course.sections;
          if (sections == null || sections.isEmpty) {
            return false;
          }
          return sections.any((section) {
            final schedules = section.schedules ?? const <ScheduleModel>[];
            return schedules.any(_isLabSchedule);
          });
        case 'all':
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      int result;
      switch (sortBy) {
        case 'code':
          result = a.code.compareTo(b.code);
          break;
        case 'students':
          final aStudents = _studentCountFor(a, sectionsByCourse);
          final bStudents = _studentCountFor(b, sectionsByCourse);
          result = aStudents.compareTo(bStudents);
          break;
        case 'grade':
          result = a.code.compareTo(b.code);
          break;
        case 'name':
        default:
          result = a.name.compareTo(b.name);
          break;
      }
      return sortAscending ? result : -result;
    });

    return filtered;
  }

  int _studentCountFor(
    CourseModel course,
    Map<int, List<SectionModel>> sectionsByCourse,
  ) {
    final sections = sectionsByCourse[course.id] ?? course.sections;
    if (sections == null || sections.isEmpty) {
      return 0;
    }

    var total = 0;
    for (final section in sections) {
      total += section.currentEnrollment;
    }
    return total;
  }

  InstructorAssignmentModel _taToInstructorAssignment(TAAssignmentModel model) {
    return InstructorAssignmentModel(
      id: model.id,
      sectionId: model.sectionId,
      userId: model.userId,
      role: 'ta',
      responsibilities: model.responsibilities,
      assignedAt: model.assignedAt,
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
    );
  }

  String _toErrorMessage(Object error) {
    final raw = error.toString();
    return raw.replaceAll('Exception: ', '').trim();
  }

  bool _hasInstructor(
    CourseModel course,
    Map<int, List<InstructorAssignmentModel>> staffByCourse,
  ) {
    final staff = staffByCourse[course.id];
    if (staff != null) {
      return staff.any((assignment) => assignment.role.toLowerCase() != 'ta');
    }
    return course.instructorId != null;
  }

  bool _hasTeachingAssistant(
    CourseModel course,
    Map<int, List<InstructorAssignmentModel>> staffByCourse,
  ) {
    final staff = staffByCourse[course.id];
    if (staff != null) {
      return staff.any((assignment) => assignment.role.toLowerCase() == 'ta');
    }
    return (course.taIds ?? const <int>[]).isNotEmpty;
  }

  bool _isLabSchedule(ScheduleModel schedule) {
    return schedule.scheduleType.toJson().toUpperCase() == 'LAB';
  }
}
