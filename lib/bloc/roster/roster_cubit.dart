import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/courses/instructor_assignment_model.dart';
import '../../services/api/enrollment_service.dart';
import 'roster_state.dart';

/// Shared Cubit for instructor/TA roster screens.
///
/// Keeps the website-parity fields and local note state in one place so both
/// role-specific screens stay aligned.
class RosterCubit extends Cubit<RosterState> {
  static const String _notesStorageKey = 'roster_notes_v1';

  final EnrollmentService _enrollmentService;

  RosterCubit({required EnrollmentService enrollmentService})
    : _enrollmentService = enrollmentService,
      super(const RosterState());

  void _emitSafely(RosterState nextState) {
    if (!isClosed) {
      emit(nextState);
    }
  }

  Future<void> loadCourses() async {
    if (isClosed) {
      return;
    }

    _emitSafely(
      state.copyWith(coursesStatus: RosterStatus.loading, clearError: true),
    );

    try {
      final result = await _enrollmentService.getTeachingCourses();
      if (isClosed) {
        return;
      }

      if (!result.isSuccess || result.data == null) {
        _emitSafely(
          state.copyWith(
            coursesStatus: RosterStatus.error,
            errorMessage: result.error?.message ?? 'Failed to load courses',
          ),
        );
        return;
      }

      final courses = result.data!;
      final currentSectionId = state.selectedSectionId;
      final nextSelectedSectionId =
          currentSectionId != null &&
              courses.any((course) => course.sectionId == currentSectionId)
          ? currentSectionId
          : (courses.isNotEmpty ? courses.first.sectionId : null);

      _emitSafely(
        state.copyWith(
          courses: courses,
          coursesStatus: RosterStatus.loaded,
          selectedSectionId: nextSelectedSectionId,
          clearError: true,
        ),
      );

      if (nextSelectedSectionId != null) {
        await selectCourse(nextSelectedSectionId, preserveSearch: true);
      } else {
        if (isClosed) {
          return;
        }

        _emitSafely(
          state.copyWith(
            students: const [],
            studentsStatus: RosterStatus.loaded,
            clearInstructorName: true,
            clearInstructorEmail: true,
          ),
        );
      }
    } catch (e) {
      if (isClosed) {
        return;
      }

      _emitSafely(
        state.copyWith(
          coursesStatus: RosterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> selectCourse(
    int sectionId, {
    bool preserveSearch = false,
  }) async {
    if (isClosed) {
      return;
    }

    _emitSafely(
      state.copyWith(
        selectedSectionId: sectionId,
        studentsStatus: RosterStatus.loading,
        students: const [],
        searchQuery: preserveSearch ? state.searchQuery : '',
        clearError: true,
      ),
    );

    try {
      final studentsResult = await _enrollmentService.getSectionStudentsLite(
        sectionId,
      );
      final instructorsResult = await _enrollmentService.getSectionInstructors(
        sectionId,
      );
      if (isClosed) {
        return;
      }

      if (!studentsResult.isSuccess || studentsResult.data == null) {
        _emitSafely(
          state.copyWith(
            studentsStatus: RosterStatus.error,
            errorMessage:
                studentsResult.error?.message ?? 'Failed to load students',
          ),
        );
        return;
      }

      final notes = await _loadNotes();
      if (isClosed) {
        return;
      }

      final primaryInstructor = _pickPrimaryInstructor(instructorsResult.data);

      _emitSafely(
        state.copyWith(
          students: studentsResult.data!,
          studentsStatus: RosterStatus.loaded,
          notesByKey: notes,
          instructorName: primaryInstructor?.fullName,
          instructorEmail: primaryInstructor?.email,
          clearInstructorName: primaryInstructor == null,
          clearInstructorEmail: primaryInstructor == null,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }

      _emitSafely(
        state.copyWith(
          studentsStatus: RosterStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setSearchQuery(String query) {
    _emitSafely(state.copyWith(searchQuery: query));
  }

  void setViewMode(RosterViewMode viewMode) {
    _emitSafely(state.copyWith(viewMode: viewMode));
  }

  void setSortField(RosterSortField sortField) {
    final nextDirection = state.sortField == sortField
        ? (state.sortDirection == RosterSortDirection.asc
              ? RosterSortDirection.desc
              : RosterSortDirection.asc)
        : RosterSortDirection.asc;

    _emitSafely(
      state.copyWith(sortField: sortField, sortDirection: nextDirection),
    );
  }

  Future<void> updateNote({required int userId, required String note}) async {
    final sectionId = state.selectedSectionId;
    if (sectionId == null) {
      return;
    }

    final key = RosterState.noteKeyFor(sectionId, userId);
    final nextNotes = <String, String>{...state.notesByKey};
    final trimmed = note.trim();

    if (trimmed.isEmpty) {
      nextNotes.remove(key);
    } else {
      nextNotes[key] = trimmed;
    }

    _emitSafely(state.copyWith(notesByKey: nextNotes));
    await _persistNotes(nextNotes);
  }

  Future<void> refresh() async {
    await loadCourses();
  }

  InstructorAssignmentModel? _pickPrimaryInstructor(
    List<InstructorAssignmentModel>? instructors,
  ) {
    if (instructors == null || instructors.isEmpty) {
      return null;
    }

    for (final instructor in instructors) {
      if (instructor.role.toLowerCase() == 'primary') {
        return instructor;
      }
    }

    return instructors.first;
  }

  Future<Map<String, String>> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <String, String>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        );
      }
    } catch (_) {
      // Ignore malformed local cache and overwrite it on the next save.
    }

    return <String, String>{};
  }

  Future<void> _persistNotes(Map<String, String> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesStorageKey, jsonEncode(notes));
  }
}
