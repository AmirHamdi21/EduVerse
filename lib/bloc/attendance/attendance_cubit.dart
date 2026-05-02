import 'dart:io';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/attendance/student_attendance_summary_model.dart';
import '../../services/api/attendance_service.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState>
    with SafeRouteCubitMixin<AttendanceState> {
  final AttendanceService _attendanceService;
  late final RouteRequestController _attendanceRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _faceReferencesRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _faceUploadRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _faceDeleteRequest = trackRouteRequest(
    RouteRequestController(),
  );

  AttendanceCubit({required AttendanceService attendanceService})
    : _attendanceService = attendanceService,
      super(AttendanceState());

  Future<void> loadAttendance() async {
    final requestId = _attendanceRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _attendanceService.getMyAttendance(
        cancelToken: _attendanceRequest.token,
      );
      if (!isRequestCurrent(_attendanceRequest, requestId)) {
        return;
      }

      if (result.isSuccess && result.data != null) {
        final apiSummaries = result.data!;
        final records = _mapApiToRecords(apiSummaries);
        final courseAttendances = _mapApiToCourseAttendances(apiSummaries);
        final statistics = _calculateStatisticsFromApi(apiSummaries, records);
        emitIfOpen(
          state.copyWith(
            isLoading: false,
            allRecords: records,
            filteredRecords: _applyFilters(
              records,
              selectedCourseId: state.selectedCourseId,
              filterOption: state.filterOption,
              searchQuery: state.searchQuery,
            ),
            courseAttendances: courseAttendances,
            statistics: statistics,
          ),
        );
      } else {
        emitIfOpen(
          state.copyWith(
            isLoading: false,
            errorMessage: result.error?.message ?? 'Failed to load attendance',
          ),
        );
      }
    } catch (e) {
      if (!isRequestCurrent(_attendanceRequest, requestId)) {
        return;
      }
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load attendance: $e',
        ),
      );
    }
  }

  void setSelectedDate(DateTime date) {
    final filtered = _filterRecordsByDate(state.allRecords, date);
    emit(state.copyWith(selectedDate: date, filteredRecords: filtered));
  }

  void setSelectedCourse(String? courseId) {
    final selectedCourseId = courseId;
    emit(
      state.copyWith(
        selectedCourseId: selectedCourseId,
        clearSelectedCourse: selectedCourseId == null,
        filteredRecords: _applyFilters(
          state.allRecords,
          selectedCourseId: selectedCourseId,
          filterOption: state.filterOption,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  void setFilter(FilterOption option) {
    emit(
      state.copyWith(
        filterOption: option,
        filteredRecords: _applyFilters(
          state.allRecords,
          selectedCourseId: state.selectedCourseId,
          filterOption: option,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  void setViewMode(ViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void setSearchQuery(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filteredRecords: _applyFilters(
          state.allRecords,
          selectedCourseId: state.selectedCourseId,
          filterOption: state.filterOption,
          searchQuery: query,
        ),
      ),
    );
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> loadFaceReferences() async {
    final requestId = _faceReferencesRequest.begin();
    final result = await _attendanceService.listMyFaceReferences(
      cancelToken: _faceReferencesRequest.token,
    );
    if (!isRequestCurrent(_faceReferencesRequest, requestId)) {
      return;
    }

    if (result.isSuccess && result.data != null) {
      emitIfOpen(
        state.copyWith(
          faceReferences: result.data!,
          clearFaceUploadError: true,
        ),
      );
    } else {
      emitIfOpen(
        state.copyWith(
          faceUploadError:
              result.error?.message ?? 'Failed to load face references',
        ),
      );
    }
  }

  Future<void> uploadFaceReference(File image) async {
    final requestId = _faceUploadRequest.begin();
    emitIfOpen(
      state.copyWith(isFaceUploading: true, clearFaceUploadError: true),
    );

    final result = await _attendanceService.uploadMyFaceReference(
      image,
      cancelToken: _faceUploadRequest.token,
    );
    if (!isRequestCurrent(_faceUploadRequest, requestId)) {
      return;
    }

    if (result.isSuccess && result.data != null) {
      emitIfOpen(
        state.copyWith(
          isFaceUploading: false,
          faceReferences: [result.data!, ...state.faceReferences],
        ),
      );
    } else {
      emitIfOpen(
        state.copyWith(
          isFaceUploading: false,
          faceUploadError:
              result.error?.message ?? 'Failed to upload face reference',
        ),
      );
    }
  }

  Future<void> deleteFaceReference(int id) async {
    final requestId = _faceDeleteRequest.begin();
    final result = await _attendanceService.deleteMyFaceReference(
      id,
      cancelToken: _faceDeleteRequest.token,
    );
    if (!isRequestCurrent(_faceDeleteRequest, requestId)) {
      return;
    }

    if (result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          faceReferences: state.faceReferences
              .where((e) => e.id != id)
              .toList(),
        ),
      );
    } else {
      emitIfOpen(
        state.copyWith(
          faceUploadError:
              result.error?.message ?? 'Failed to delete face reference',
        ),
      );
    }
  }

  AttendanceStatus _filterOptionToStatus(FilterOption option) {
    switch (option) {
      case FilterOption.present:
        return AttendanceStatus.present;
      case FilterOption.absent:
        return AttendanceStatus.absent;
      case FilterOption.late:
        return AttendanceStatus.late;
      case FilterOption.excused:
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.present;
    }
  }

  List<AttendanceRecord> _applyFilters(
    List<AttendanceRecord> source, {
    required String? selectedCourseId,
    required FilterOption filterOption,
    required String searchQuery,
  }) {
    var filtered = source;

    if (selectedCourseId != null) {
      filtered = filtered.where((r) => r.courseId == selectedCourseId).toList();
    }

    if (filterOption != FilterOption.all) {
      final status = _filterOptionToStatus(filterOption);
      filtered = filtered.where((r) => r.status == status).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.courseName.toLowerCase().contains(q) ||
            r.courseCode.toLowerCase().contains(q) ||
            (r.lectureTitle?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return filtered;
  }

  List<AttendanceRecord> _filterRecordsByDate(
    List<AttendanceRecord> records,
    DateTime date,
  ) {
    return records.where((r) {
      return r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day;
    }).toList();
  }

  List<CourseAttendance> _mapApiToCourseAttendances(
    List<StudentAttendanceSummaryModel> summaries,
  ) {
    final gradientColors = [
      [0xFF3B82F6, 0xFF06B6D4],
      [0xFF2563EB, 0xFF38BDF8],
      [0xFF0EA5E9, 0xFF22C55E],
      [0xFF1D4ED8, 0xFF06B6D4],
      [0xFF0284C7, 0xFF60A5FA],
      [0xFF0891B2, 0xFF2DD4BF],
    ];
    return summaries.asMap().entries.map((entry) {
      return CourseAttendance.fromApi(
        entry.value,
        gradientColors[entry.key % gradientColors.length],
      );
    }).toList();
  }

  List<AttendanceRecord> _mapApiToRecords(
    List<StudentAttendanceSummaryModel> summaries,
  ) {
    final List<AttendanceRecord> records = <AttendanceRecord>[];
    final now = DateTime.now();

    for (var i = 0; i < summaries.length; i++) {
      final summary = summaries[i];
      final statuses = <AttendanceStatus>[
        ...List<AttendanceStatus>.filled(
          summary.attended,
          AttendanceStatus.present,
        ),
        ...List<AttendanceStatus>.filled(
          summary.absent,
          AttendanceStatus.absent,
        ),
        ...List<AttendanceStatus>.filled(
          summary.lateCount,
          AttendanceStatus.late,
        ),
        ...List<AttendanceStatus>.filled(
          summary.excused,
          AttendanceStatus.excused,
        ),
      ];

      for (var j = 0; j < statuses.length; j++) {
        final fallbackDate = now.subtract(Duration(days: i * 4 + j));
        final parsedLastClassDate = DateTime.tryParse(
          summary.lastClassDate ?? '',
        );
        final date = (parsedLastClassDate ?? fallbackDate).subtract(
          Duration(days: j),
        );
        final status = statuses[j];

        records.add(
          AttendanceRecord(
            id: '${summary.courseId}_${date.millisecondsSinceEpoch}_$j',
            courseId: summary.courseId.toString(),
            courseName: summary.courseName,
            courseCode: summary.courseCode,
            date: date,
            status: status,
            lectureTitle: 'Session ${j + 1}',
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endTime: const TimeOfDay(hour: 10, minute: 30),
            note: status == AttendanceStatus.absent
                ? 'Absent'
                : status == AttendanceStatus.excused
                ? 'Excused'
                : null,
          ),
        );
      }
    }

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  AttendanceStatistics _calculateStatisticsFromApi(
    List<StudentAttendanceSummaryModel> summaries,
    List<AttendanceRecord> records,
  ) {
    final totalClasses = summaries.fold<int>(
      0,
      (sum, s) => sum + s.totalClasses,
    );
    final presentCount = summaries.fold<int>(0, (sum, s) => sum + s.attended);
    final absentCount = summaries.fold<int>(0, (sum, s) => sum + s.absent);
    final lateCount = summaries.fold<int>(0, (sum, s) => sum + s.lateCount);
    final excusedCount = summaries.fold<int>(0, (sum, s) => sum + s.excused);

    final overallPercentage = totalClasses > 0
        ? ((presentCount + lateCount + excusedCount) / totalClasses) * 100.0
        : 0.0;

    return AttendanceStatistics(
      totalClasses: totalClasses,
      presentCount: presentCount,
      absentCount: absentCount,
      lateCount: lateCount,
      excusedCount: excusedCount,
      overallPercentage: overallPercentage,
      weeklyTrend: _buildWeeklyTrend(records),
    );
  }

  List<WeeklyAttendance> _buildWeeklyTrend(List<AttendanceRecord> records) {
    if (records.isEmpty) {
      return const <WeeklyAttendance>[];
    }

    final now = DateTime.now();
    final List<WeeklyAttendance> trend = <WeeklyAttendance>[];

    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: i * 7 + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekRecords = records.where((r) {
        return !r.date.isBefore(weekStart) && !r.date.isAfter(weekEnd);
      }).toList();

      if (weekRecords.isEmpty) continue;

      final attended = weekRecords
          .where(
            (r) =>
                r.status == AttendanceStatus.present ||
                r.status == AttendanceStatus.late ||
                r.status == AttendanceStatus.excused,
          )
          .length;

      trend.add(
        WeeklyAttendance(
          week: 'W${8 - i}',
          percentage: (attended / weekRecords.length) * 100,
        ),
      );
    }

    return trend;
  }
}
