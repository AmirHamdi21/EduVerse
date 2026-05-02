import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/attendance/attendance_cubit.dart';
import 'package:edu_verse/bloc/attendance/attendance_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/attendance/student_attendance_summary_model.dart';
import 'package:edu_verse/models/attendance/student_face_reference_model.dart';
import 'package:edu_verse/services/api/attendance_service.dart';

/// Fake AttendanceService that returns pre-configured results.
class _FakeAttendanceService implements AttendanceService {
  ServiceResult<List<StudentAttendanceSummaryModel>> myAttendanceResult =
      ServiceResult<List<StudentAttendanceSummaryModel>>.success(
        const <StudentAttendanceSummaryModel>[],
      );

  ServiceResult<List<StudentFaceReferenceModel>> faceReferencesResult =
      ServiceResult<List<StudentFaceReferenceModel>>.success(
        const <StudentFaceReferenceModel>[],
      );

  ServiceResult<StudentFaceReferenceModel>? uploadFaceResult;
  ServiceResult<void> deleteFaceResult = ServiceResult<void>.success(null);

  @override
  Future<ServiceResult<List<StudentAttendanceSummaryModel>>> getMyAttendance({
    CancelToken? cancelToken,
  }) async => myAttendanceResult;

  @override
  Future<ServiceResult<List<StudentFaceReferenceModel>>> listMyFaceReferences({
    CancelToken? cancelToken,
  }) async => faceReferencesResult;

  @override
  Future<ServiceResult<StudentFaceReferenceModel>> uploadMyFaceReference(
    File image, {
    CancelToken? cancelToken,
  }) async =>
      uploadFaceResult ??
      ServiceResult<StudentFaceReferenceModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'Not configured',
        ),
      );

  @override
  Future<ServiceResult<void>> deleteMyFaceReference(
    int id, {
    CancelToken? cancelToken,
  }) async => deleteFaceResult;

  // --- Stubs for unused methods ---
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void main() {
  group('AttendanceCubit', () {
    late _FakeAttendanceService fakeService;
    late AttendanceCubit cubit;

    setUp(() {
      fakeService = _FakeAttendanceService();
      cubit = AttendanceCubit(attendanceService: fakeService);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state has default values', () {
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.allRecords, isEmpty);
      expect(cubit.state.courseAttendances, isEmpty);
      expect(cubit.state.statistics, isNull);
      expect(cubit.state.faceReferences, isEmpty);
      expect(cubit.state.isFaceUploading, isFalse);
    });

    test('loadAttendance emits loading then success', () async {
      fakeService.myAttendanceResult =
          ServiceResult<List<StudentAttendanceSummaryModel>>.success([
            StudentAttendanceSummaryModel.fromJson(<String, dynamic>{
              'courseId': 1,
              'courseName': 'CS 101',
              'courseCode': 'CS101',
              'totalClasses': 20,
              'attended': 18,
              'absent': 1,
              'late': 1,
              'excused': 0,
              'percentage': 90.0,
            }),
          ]);

      final loadFuture = cubit.loadAttendance();

      // Should be loading immediately
      expect(cubit.state.isLoading, isTrue);

      await loadFuture;

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.courseAttendances.length, 1);
      expect(cubit.state.courseAttendances.first.courseName, 'CS 101');
      expect(cubit.state.allRecords, isNotEmpty);
      expect(cubit.state.statistics, isNotNull);
      expect(cubit.state.statistics!.totalClasses, 20);
    });

    test('loadAttendance emits error on failure', () async {
      fakeService.myAttendanceResult =
          ServiceResult<List<StudentAttendanceSummaryModel>>.failure(
            const ServiceError(
              type: ServiceErrorType.network,
              message: 'No internet',
            ),
          );

      await cubit.loadAttendance();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, contains('No internet'));
    });

    test('setFilter updates filtered records', () async {
      fakeService.myAttendanceResult =
          ServiceResult<List<StudentAttendanceSummaryModel>>.success([
            StudentAttendanceSummaryModel.fromJson(<String, dynamic>{
              'courseId': 1,
              'courseName': 'CS',
              'courseCode': 'CS101',
              'totalClasses': 10,
              'attended': 5,
              'absent': 3,
              'late': 1,
              'excused': 1,
              'percentage': 70.0,
            }),
          ]);

      await cubit.loadAttendance();
      final allCount = cubit.state.filteredRecords.length;

      cubit.setFilter(FilterOption.present);
      final presentOnly = cubit.state.filteredRecords;
      expect(presentOnly.length, lessThanOrEqualTo(allCount));
      expect(
        presentOnly.every((r) => r.status == AttendanceStatus.present),
        isTrue,
      );
    });

    test('setSelectedCourse filters by course', () async {
      fakeService.myAttendanceResult =
          ServiceResult<List<StudentAttendanceSummaryModel>>.success([
            StudentAttendanceSummaryModel.fromJson(<String, dynamic>{
              'courseId': 1,
              'courseName': 'CS',
              'courseCode': 'CS101',
              'totalClasses': 5,
              'attended': 3,
              'absent': 2,
              'percentage': 60.0,
            }),
            StudentAttendanceSummaryModel.fromJson(<String, dynamic>{
              'courseId': 2,
              'courseName': 'Math',
              'courseCode': 'MATH200',
              'totalClasses': 5,
              'attended': 5,
              'percentage': 100.0,
            }),
          ]);

      await cubit.loadAttendance();

      cubit.setSelectedCourse('1');
      expect(
        cubit.state.filteredRecords.every((r) => r.courseId == '1'),
        isTrue,
      );

      cubit.setSelectedCourse(null);
      expect(cubit.state.filteredRecords.length, cubit.state.allRecords.length);
    });

    test('setViewMode updates view mode', () {
      cubit.setViewMode(ViewMode.list);
      expect(cubit.state.viewMode, ViewMode.list);

      cubit.setViewMode(ViewMode.calendar);
      expect(cubit.state.viewMode, ViewMode.calendar);
    });

    test('setSelectedTab updates tab index', () {
      cubit.setSelectedTab(2);
      expect(cubit.state.selectedTabIndex, 2);
    });

    test('clearError clears errorMessage', () async {
      fakeService.myAttendanceResult =
          ServiceResult<List<StudentAttendanceSummaryModel>>.failure(
            const ServiceError(
              type: ServiceErrorType.server,
              message: 'Server error',
            ),
          );
      await cubit.loadAttendance();
      expect(cubit.state.errorMessage, isNotNull);

      cubit.clearError();
      expect(cubit.state.errorMessage, isNull);
    });

    test('loadFaceReferences populates state', () async {
      fakeService.faceReferencesResult =
          ServiceResult<List<StudentFaceReferenceModel>>.success([
            StudentFaceReferenceModel.fromJson(<String, dynamic>{
              'id': 1,
              'userId': 42,
              'storagePath': '/faces/42/photo.jpg',
              'isPrimary': true,
            }),
          ]);

      await cubit.loadFaceReferences();

      expect(cubit.state.faceReferences.length, 1);
      expect(cubit.state.faceReferences.first.isPrimary, isTrue);
    });

    test('deleteFaceReference removes from state', () async {
      fakeService.faceReferencesResult =
          ServiceResult<List<StudentFaceReferenceModel>>.success([
            StudentFaceReferenceModel.fromJson(<String, dynamic>{
              'id': 1,
              'userId': 42,
              'storagePath': '/faces/42/photo.jpg',
            }),
            StudentFaceReferenceModel.fromJson(<String, dynamic>{
              'id': 2,
              'userId': 42,
              'storagePath': '/faces/42/photo2.jpg',
            }),
          ]);

      await cubit.loadFaceReferences();
      expect(cubit.state.faceReferences.length, 2);

      fakeService.deleteFaceResult = ServiceResult<void>.success(null);
      await cubit.deleteFaceReference(1);

      expect(cubit.state.faceReferences.length, 1);
      expect(cubit.state.faceReferences.first.id, 2);
    });
  });
}
