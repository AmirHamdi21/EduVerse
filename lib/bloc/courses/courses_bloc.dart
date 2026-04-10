import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'courses_event.dart';
import 'courses_state.dart';
import '../../services/api/course_service.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/material_service.dart';
import '../../services/api/communication_service.dart';
import '../../common/service_error.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/core/course_model.dart';
import '../../models/core/course_structure_model.dart';
import '../../models/instructor/teaching_course_model.dart';

/// Central BLoC for all course-related state management.
///
/// Routes events to the appropriate service and emits predictable
/// state transitions: Initial → Loading (with optional cache) → Loaded | Error.
///
/// Integrates [SharedPreferences] for offline-cache persistence so that
/// previously fetched data can be shown while a fresh fetch is in progress.
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final CourseService _courseService;
  final EnrollmentService _enrollmentService;
  final MaterialService _materialService;
  final CommunicationService _communicationService;

  // ── Cache keys ─────────────────────────────────────────────────────────────
  static const _cacheKeyEnrollments = 'courses_cache_enrollments';
  static const _cacheKeyAllCourses = 'courses_cache_all';
  static const _cacheKeyTeaching = 'courses_cache_teaching';
  static const _cacheKeyStructurePrefix = 'courses_cache_structure_';

  CoursesBloc({
    required CourseService courseService,
    required EnrollmentService enrollmentService,
    required MaterialService materialService,
    required CommunicationService communicationService,
  }) : _courseService = courseService,
       _enrollmentService = enrollmentService,
       _materialService = materialService,
       _communicationService = communicationService,
       super(const CoursesInitial()) {
    on<StudentCoursesFetched>(_onStudentCoursesFetched);
    on<InstructorCoursesFetched>(_onInstructorCoursesFetched);
    on<AllCoursesFetched>(_onAllCoursesFetched);
    on<CourseStructureFetched>(_onCourseStructureFetched);
    on<CourseMaterialsFetched>(_onCourseMaterialsFetched);
    on<AnnouncementsFetched>(_onAnnouncementsFetched);
    on<AssignmentsFetched>(_onAssignmentsFetched);
    on<CoursesRefreshed>(_onCoursesRefreshed);
    on<TACoursesFetched>(_onTACoursesFetched);
  }

  // ── Student Courses ────────────────────────────────────────────────────

  Future<void> _onStudentCoursesFetched(
    StudentCoursesFetched event,
    Emitter<CoursesState> emit,
  ) async {
    // Load cached data first for offline resilience
    final cached = await _loadCachedEnrollments();
    emit(CoursesLoading(cachedData: cached));

    try {
      final enrollmentsResult = await _enrollmentService.getMyCourses();
      if (!enrollmentsResult.isSuccess || enrollmentsResult.data == null) {
        throw Exception(
          enrollmentsResult.error?.message ?? 'Failed to load courses',
        );
      }

      final enrollments = enrollmentsResult.data!;
      await _cacheEnrollments(enrollments);
      emit(CoursesLoaded(enrollments: enrollments));
    } catch (e) {
      if (cached.isNotEmpty) {
        emit(CoursesLoaded(enrollments: cached));
      } else {
        emit(CoursesError(message: _sanitizeError(e)));
      }
    }
  }

  // ── Instructor Courses ─────────────────────────────────────────────────────

  Future<void> _onInstructorCoursesFetched(
    InstructorCoursesFetched event,
    Emitter<CoursesState> emit,
  ) async {
    final cached = await _loadCachedTeachingCourses();
    emit(CoursesLoading(cachedData: cached));

    try {
      final teachingCoursesResult = await _enrollmentService
          .getTeachingCourses();
      if (!teachingCoursesResult.isSuccess ||
          teachingCoursesResult.data == null) {
        throw Exception(
          teachingCoursesResult.error?.message ??
              'Failed to load teaching courses',
        );
      }

      final teachingCourses = teachingCoursesResult.data!;
      await _cacheTeachingCourses(teachingCourses);
      emit(InstructorCoursesLoaded(teachingCourses: teachingCourses));
    } catch (e) {
      if (cached.isNotEmpty) {
        emit(InstructorCoursesLoaded(teachingCourses: cached));
      } else {
        emit(CoursesError(message: _sanitizeError(e)));
      }
    }
  }

  // ── TA Courses ──────────────────────────────────────────────────────────

  Future<void> _onTACoursesFetched(
    TACoursesFetched event,
    Emitter<CoursesState> emit,
  ) async {
    final cached = await _loadCachedTeachingCourses();
    emit(CoursesLoading(cachedData: cached));

    try {
      final teachingCoursesResult = await _enrollmentService
          .getTeachingCourses();
      if (!teachingCoursesResult.isSuccess ||
          teachingCoursesResult.data == null) {
        throw Exception(
          teachingCoursesResult.error?.message ??
              'Failed to load teaching courses',
        );
      }

      final teachingCourses = teachingCoursesResult.data!;
      await _cacheTeachingCourses(teachingCourses);
      emit(TACoursesLoaded(teachingCourses: teachingCourses));
    } catch (e) {
      if (cached.isNotEmpty) {
        emit(TACoursesLoaded(teachingCourses: cached));
      } else {
        emit(CoursesError(message: _sanitizeError(e)));
      }
    }
  }

  // ── All Courses (Catalog) ──────────────────────────────────────────────

  Future<void> _onAllCoursesFetched(
    AllCoursesFetched event,
    Emitter<CoursesState> emit,
  ) async {
    final cached = await _loadCachedCourses();
    emit(CoursesLoading(cachedData: cached));

    try {
      final courses = await _courseService.getAllCourses();
      await _cacheCourses(courses);
      emit(AllCoursesLoaded(courses: courses));
    } catch (e) {
      if (cached.isNotEmpty) {
        emit(AllCoursesLoaded(courses: cached));
      } else {
        emit(CoursesError(message: _sanitizeError(e)));
      }
    }
  }

  // ── Course Structure ───────────────────────────────────────────────────

  Future<void> _onCourseStructureFetched(
    CourseStructureFetched event,
    Emitter<CoursesState> emit,
  ) async {
    // T005a/T007: Cache-first pattern for <2s load target (SC-003)
    final cached = await _loadCachedStructure(event.courseId);
    if (cached.isNotEmpty) {
      // Emit cached data immediately for instant UI rendering
      emit(CourseStructureLoaded(structure: cached));
    } else {
      emit(const CoursesLoading());
    }

    try {
      final structure = await _courseService.getCourseStructure(event.courseId);
      await _cacheStructure(event.courseId, structure);
      emit(CourseStructureLoaded(structure: structure));
    } catch (e) {
      if (cached.isNotEmpty) {
        // Already showing cached data, keep it visible
        emit(CourseStructureLoaded(structure: cached));
      } else {
        emit(CoursesError(message: _sanitizeError(e)));
      }
    }
  }

  // ── Course Materials ───────────────────────────────────────────────────

  Future<void> _onCourseMaterialsFetched(
    CourseMaterialsFetched event,
    Emitter<CoursesState> emit,
  ) async {
    emit(const CoursesLoading());

    try {
      final materials = await _materialService.getMaterials(
        event.courseId,
        materialType: event.materialType,
        weekNumber: event.weekNumber,
      );
      emit(CourseMaterialsLoaded(materials: materials));
    } catch (e) {
      emit(CoursesError(message: _sanitizeError(e)));
    }
  }

  // ── Announcements ─────────────────────────────────────────────────────

  Future<void> _onAnnouncementsFetched(
    AnnouncementsFetched event,
    Emitter<CoursesState> emit,
  ) async {
    emit(const CoursesLoading());

    try {
      final announcements = await _communicationService.getAnnouncements();
      emit(AnnouncementsLoaded(announcements: announcements));
    } catch (e) {
      emit(CoursesError(message: _sanitizeError(e)));
    }
  }

  // ── Assignments ────────────────────────────────────────────────────────

  Future<void> _onAssignmentsFetched(
    AssignmentsFetched event,
    Emitter<CoursesState> emit,
  ) async {
    emit(const CoursesLoading());

    try {
      final assignments = await _communicationService.getAssignments();
      emit(AssignmentsLoaded(assignments: assignments));
    } catch (e) {
      emit(CoursesError(message: _sanitizeError(e)));
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────

  Future<void> _onCoursesRefreshed(
    CoursesRefreshed event,
    Emitter<CoursesState> emit,
  ) async {
    // Re-dispatch the appropriate fetch based on current state type.
    // Default to student courses fetch.
    add(const StudentCoursesFetched());
  }

  // ── SharedPreferences Cache Helpers ────────────────────────────────────

  Future<List<CourseEnrollmentModel>> _loadCachedEnrollments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKeyEnrollments);
      if (raw == null) return [];
      final List decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => CourseEnrollmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheEnrollments(
    List<CourseEnrollmentModel> enrollments,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(enrollments.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKeyEnrollments, encoded);
    } catch (_) {
      // Silently fail — caching is best-effort.
    }
  }

  Future<List<CourseModel>> _loadCachedCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKeyAllCourses);
      if (raw == null) return [];
      final List decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheCourses(List<CourseModel> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(courses.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKeyAllCourses, encoded);
    } catch (_) {
      // Silently fail — caching is best-effort.
    }
  }

  // ── Teaching Courses Cache ───────────────────────────────────────────────

  Future<List<TeachingCourseModel>> _loadCachedTeachingCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKeyTeaching);
      if (raw == null) return [];
      final List decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => TeachingCourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheTeachingCourses(List<TeachingCourseModel> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(courses.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKeyTeaching, encoded);
    } catch (_) {
      // Silently fail — caching is best-effort.
    }
  }

  // ── Course Structure Cache ────────────────────────────────────────────────

  Future<List<CourseStructureModel>> _loadCachedStructure(
    dynamic courseId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_cacheKeyStructurePrefix$courseId');
      if (raw == null) return [];
      final List decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => CourseStructureModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheStructure(
    dynamic courseId,
    List<CourseStructureModel> structure,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(structure.map((e) => e.toJson()).toList());
      await prefs.setString('$_cacheKeyStructurePrefix$courseId', encoded);
    } catch (_) {
      // Silently fail — caching is best-effort.
    }
  }

  // ── Error Sanitization ─────────────────────────────────────────────────

  /// T013: Enhanced error sanitization with 403 Forbidden awareness.
  /// When a TA attempts a restricted action, the backend returns 403.
  /// Instead of showing a cryptic error, we surface a user-friendly message.
  String _sanitizeError(Object error) {
    // T013: Detect DioException 403 for graceful TA permission handling
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 403) {
        return 'You do not have permission to perform this action';
      }
      if (statusCode == 404) {
        return 'The requested resource was not found';
      }
      if (statusCode != null && statusCode >= 500) {
        return 'Server error. Please try again later';
      }
    }

    if (error is ServiceError) {
      return error.message;
    }

    final raw = error.toString();
    // Strip Dart Exception wrapper for cleaner UI messages
    return raw
        .replaceAll('Exception: ', '')
        .replaceAll('DioException ', '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .trim();
  }
}
