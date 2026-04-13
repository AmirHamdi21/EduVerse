import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_labs_cubit.dart';
import 'package:edu_verse/bloc/instructor/instructor_labs_state.dart';
import 'package:edu_verse/bloc/instructor/lab_detail_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/models/core/drive_file_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart'
    as assignment_api;
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/lab_enums.dart' as lab_api;
import 'package:edu_verse/models/core/lab_attendance_model.dart';
import 'package:edu_verse/models/core/lab_instruction_model.dart';
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart'
    hide AssignmentModel;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/screens/instructor/labs/instructor_labs_screen.dart';
import 'package:edu_verse/screens/instructor/labs/lab_detail_screen.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/instructor/labs/grading_panel.dart';
import 'package:edu_verse/widgets/instructor/labs/instruction_file_uploader.dart';
import 'package:edu_verse/widgets/instructor/labs/instruction_manager.dart';

class _FakeStorageService extends StorageService {
  _FakeStorageService({this.user});

  final UserDto? user;

  @override
  Future<bool> getDarkMode() async => false;

  @override
  Future<int> getFontSize() async => 1;

  @override
  Future<void> setDarkMode(bool isDark) async {}

  @override
  Future<void> setFontSize(int sizeIndex) async {}

  @override
  Future<UserDto?> getUserData() async => user;
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService(this.courses)
    : super(coreApiClient: CoreApiClient.test());

  final List<TeachingCourseModel> courses;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    return ServiceResult<List<TeachingCourseModel>>.success(courses);
  }
}

class _FakeLabService extends LabService {
  _FakeLabService({
    required this.labs,
    required this.instructions,
    required this.submissions,
    required this.attendance,
    this.listDelay = Duration.zero,
    this.createDelay = Duration.zero,
    this.gradeDelay = Duration.zero,
    this.markAttendanceDelay = Duration.zero,
  }) : super(coreApiClient: CoreApiClient.test());

  final List<LabModel> labs;
  final List<LabInstructionModel> instructions;
  final List<LabSubmissionModel> submissions;
  final List<LabAttendanceModel> attendance;

  final Duration listDelay;
  final Duration createDelay;
  final Duration gradeDelay;
  final Duration markAttendanceDelay;

  int markAttendanceCalls = 0;
  Map<String, dynamic>? lastCreatePayload;
  double? lastGradedScore;

  @override
  Future<ServiceResult<PaginatedResponse<LabModel>>> getAllPaginated({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    if (listDelay > Duration.zero) {
      await Future<void>.delayed(listDelay);
    }

    if (page > 1) {
      return ServiceResult<PaginatedResponse<LabModel>>.success(
        const PaginatedResponse<LabModel>(
          data: <LabModel>[],
          total: 0,
          page: 2,
          limit: 50,
          totalPages: 2,
        ),
      );
    }

    return ServiceResult<PaginatedResponse<LabModel>>.success(
      PaginatedResponse<LabModel>(
        data: labs,
        total: labs.length,
        page: 1,
        limit: limit,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<LabModel>> create(Map<String, dynamic> data) async {
    lastCreatePayload = data;
    if (createDelay > Duration.zero) {
      await Future<void>.delayed(createDelay);
    }

    final created = LabModel(
      id: 'created-1',
      labId: 999,
      courseId: (data['courseId'] as int?) ?? 56,
      title: data['title']?.toString() ?? 'Created Lab',
      description: data['description']?.toString(),
      dueDate: DateTime.tryParse(data['dueDate']?.toString() ?? ''),
      availableFrom: DateTime.tryParse(data['availableFrom']?.toString() ?? ''),
      maxScore: (data['maxScore'] as num?)?.toDouble() ?? 100,
      weight: (data['weight'] as num?)?.toDouble() ?? 10,
      status: lab_api.LabStatus.fromString(
        data['status']?.toString() ?? 'draft',
      ),
    );

    return ServiceResult<LabModel>.success(created);
  }

  @override
  Future<ServiceResult<LabModel>> getById(dynamic id) async {
    final found = labs.firstWhere(
      (lab) => lab.id == id.toString(),
      orElse: () => labs.first,
    );
    return ServiceResult<LabModel>.success(found);
  }

  @override
  Future<ServiceResult<List<LabInstructionModel>>> getInstructions(
    dynamic labId,
  ) async {
    return ServiceResult<List<LabInstructionModel>>.success(instructions);
  }

  @override
  Future<ServiceResult<List<LabSubmissionModel>>> getSubmissions(
    dynamic labId,
  ) async {
    return ServiceResult<List<LabSubmissionModel>>.success(submissions);
  }

  @override
  Future<ServiceResult<List<LabAttendanceModel>>> getAttendance(
    dynamic labId,
  ) async {
    return ServiceResult<List<LabAttendanceModel>>.success(attendance);
  }

  @override
  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic labId,
    dynamic submissionId,
    double score, {
    String status = 'graded',
    String? feedback,
  }) async {
    if (gradeDelay > Duration.zero) {
      await Future<void>.delayed(gradeDelay);
    }

    lastGradedScore = score;
    return ServiceResult<Map<String, dynamic>>.success(<String, dynamic>{
      'ok': true,
    });
  }

  @override
  Future<ServiceResult<LabAttendanceModel>> markAttendance(
    dynamic labId,
    Map<String, dynamic> data,
  ) async {
    markAttendanceCalls++;
    if (markAttendanceDelay > Duration.zero) {
      await Future<void>.delayed(markAttendanceDelay);
    }

    return ServiceResult<LabAttendanceModel>.success(
      LabAttendanceModel(
        id: markAttendanceCalls,
        labId: int.tryParse(labId.toString()) ?? 1,
        userId: int.tryParse(data['userId']?.toString() ?? '') ?? 0,
        attendanceStatus: lab_api.LabAttendanceStatus.fromString(
          data['attendanceStatus']?.toString() ?? 'present',
        ),
      ),
    );
  }
}

TeachingCourseModel _teachingCourse({int courseId = 56}) {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 7,
    'courseId': courseId,
    'role': 'instructor',
    'enrolledCount': 22,
    'capacity': 30,
    'course': <String, dynamic>{
      'id': courseId,
      'departmentId': 1,
      'code': 'CS$courseId',
      'name': 'Course $courseId',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 12,
      'courseId': courseId,
      'semesterId': 2,
      'sectionNumber': 'A',
      'maxCapacity': 30,
      'currentEnrollment': 22,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 2,
      'name': 'Fall 2026',
      'term': 'fall',
      'year': 2026,
    },
  });
}

LabModel _lab(
  int id, {
  int courseId = 56,
  String? title,
  lab_api.LabStatus status = lab_api.LabStatus.published,
  DateTime? dueDate,
}) {
  return LabModel(
    id: id.toString(),
    labId: id,
    courseId: courseId,
    title: title ?? 'Lab $id',
    description: 'Description for Lab $id',
    dueDate: dueDate ?? DateTime(2026, 5, 1).add(Duration(days: id)),
    maxScore: 100,
    weight: 10,
    status: status,
    course: CourseInfo(
      id: courseId,
      name: 'Course $courseId',
      code: 'CS$courseId',
    ),
  );
}

LabSubmissionModel _submission({
  required int id,
  bool isLate = false,
  DateTime? submittedAt,
  assignment_api.SubmissionStatus status =
      assignment_api.SubmissionStatus.submitted,
}) {
  return LabSubmissionModel(
    id: id,
    labId: 1,
    userId: 100 + id,
    submissionStatus: status,
    isLate: isLate,
    submittedAt: submittedAt ?? DateTime(2026, 5, 1),
    submissionText: 'Submission body for $id',
    user: UserInfo(
      userId: 100 + id,
      firstName: 'Student',
      lastName: id == 1 ? 'One' : 'Two',
      email: 'student$id@example.com',
    ),
  );
}

LabAttendanceModel _attendanceRecord({required int userId}) {
  return LabAttendanceModel(
    id: userId,
    labId: 1,
    userId: userId,
    attendanceStatus: lab_api.LabAttendanceStatus.present,
    user: UserInfo(
      userId: userId,
      firstName: 'Learner',
      lastName: '$userId',
      email: 'learner$userId@example.com',
    ),
  );
}

UserDto _userWithRole(String roleName) {
  return UserDto(
    userId: 1,
    email: '$roleName@example.com',
    firstName: 'Role',
    lastName: 'User',
    roles: <RoleModel>[RoleModel(roleId: 1, roleName: roleName)],
  );
}

Widget _buildLabsHost({
  required _FakeLabService labService,
  required _FakeEnrollmentService enrollmentService,
  required StorageService storageService,
}) {
  return MaterialApp(
    home: InstructorLabsScreen(
      labService: labService,
      enrollmentService: enrollmentService,
      storageService: storageService,
    ),
  );
}

Widget _buildLabDetailHost({
  required _FakeLabService labService,
  required StorageService storageService,
}) {
  return MaterialApp(
    home: LabDetailScreen(
      labId: labService.labs.first.id,
      labService: labService,
      storageService: storageService,
    ),
  );
}

void _setViewport(WidgetTester tester, Size logicalSize) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = logicalSize;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

Finder _buttonByLabel(String label) {
  return find.ancestor(
    of: find.text(label).first,
    matching: find.byType(ButtonStyleButton),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 9 verification (T037-T040)', () {
    testWidgets('T038: labs CRUD controls are visible for instructor only', (
      WidgetTester tester,
    ) async {
      final labService = _FakeLabService(
        labs: <LabModel>[_lab(1)],
        instructions: const <LabInstructionModel>[],
        submissions: const <LabSubmissionModel>[],
        attendance: const <LabAttendanceModel>[],
      );
      final enrollmentService = _FakeEnrollmentService(<TeachingCourseModel>[
        _teachingCourse(),
      ]);

      await tester.pumpWidget(
        _buildLabsHost(
          labService: labService,
          enrollmentService: enrollmentService,
          storageService: _FakeStorageService(
            user: _userWithRole('instructor'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create New Lab'), findsOneWidget);
      expect(find.byTooltip('Edit lab'), findsOneWidget);
      expect(find.byTooltip('Delete lab'), findsOneWidget);

      await tester.pumpWidget(
        _buildLabsHost(
          labService: labService,
          enrollmentService: enrollmentService,
          storageService: _FakeStorageService(user: _userWithRole('student')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create New Lab'), findsNothing);
      expect(find.byTooltip('Edit lab'), findsNothing);
      expect(find.byTooltip('Delete lab'), findsNothing);
    });

    testWidgets(
      'T038: grading and attendance interactions are blocked for non-instructor roles',
      (WidgetTester tester) async {
        final labService = _FakeLabService(
          labs: <LabModel>[_lab(1)],
          instructions: const <LabInstructionModel>[],
          submissions: <LabSubmissionModel>[_submission(id: 1)],
          attendance: <LabAttendanceModel>[_attendanceRecord(userId: 101)],
        );

        await tester.pumpWidget(
          _buildLabDetailHost(
            labService: labService,
            storageService: _FakeStorageService(user: _userWithRole('student')),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Submissions'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Student One'));
        await tester.pumpAndSettle();

        expect(find.text('Save Grade'), findsNothing);

        await tester.tap(find.text('Attendance'));
        await tester.pumpAndSettle();

        final presentChip = tester.widget<ChoiceChip>(
          find.widgetWithText(ChoiceChip, 'Present').first,
        );
        expect(presentChip.onSelected, isNull);
      },
    );

    testWidgets(
      'T037: labs list and detail screens render across 375/768/1024 without overflow and with minimum touch targets',
      (WidgetTester tester) async {
        final sizes = <Size>[
          const Size(375, 812),
          const Size(768, 1024),
          const Size(1024, 1366),
        ];

        for (final size in sizes) {
          _setViewport(tester, size);

          final labsService = _FakeLabService(
            labs: <LabModel>[_lab(1), _lab(2), _lab(3)],
            instructions: <LabInstructionModel>[
              const LabInstructionModel(
                id: 1,
                labId: 1,
                instructionText: 'Read and implement.',
                orderIndex: 0,
              ),
            ],
            submissions: <LabSubmissionModel>[_submission(id: 1)],
            attendance: <LabAttendanceModel>[_attendanceRecord(userId: 101)],
          );

          await tester.pumpWidget(
            _buildLabsHost(
              labService: labsService,
              enrollmentService: _FakeEnrollmentService(<TeachingCourseModel>[
                _teachingCourse(),
              ]),
              storageService: _FakeStorageService(
                user: _userWithRole('instructor'),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Lab Management'), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is SingleChildScrollView &&
                  widget.scrollDirection == Axis.horizontal,
            ),
            findsNothing,
          );

          final createButtonSize = tester.getSize(
            _buttonByLabel('Create New Lab').first,
          );
          expect(createButtonSize.height, greaterThanOrEqualTo(48));

          final statusChipSize = tester.getSize(
            find.widgetWithText(ChoiceChip, 'All').first,
          );
          expect(statusChipSize.height, greaterThanOrEqualTo(48));

          await tester.pumpWidget(
            _buildLabDetailHost(
              labService: labsService,
              storageService: _FakeStorageService(
                user: _userWithRole('instructor'),
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Attendance'));
          await tester.pumpAndSettle();

          final attendanceChipSize = tester.getSize(
            find.widgetWithText(ChoiceChip, 'Present').first,
          );
          expect(attendanceChipSize.height, greaterThanOrEqualTo(48));

          expect(tester.takeException(), isNull);
        }
      },
    );

    // testWidgets(
    //   'T039: instruction uploader shows progress and file instructions expose preview controls',
    //   (WidgetTester tester) async {
    //     final tempDir = await Directory.systemTemp.createTemp(
    //       'instruction_uploader_test',
    //     );
    //     final file = File('${tempDir.path}${Platform.pathSeparator}upload.txt');
    //     await file.writeAsString('upload content');

    //     const pickerChannel = MethodChannel(
    //       'miguelruivo.flutter.plugins.filepicker',
    //     );

    //     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    //         .setMockMethodCallHandler(pickerChannel, (MethodCall call) async {
    //           if (call.method == 'any' || call.method == 'pickFiles') {
    //             return <Map<String, dynamic>>[
    //               <String, dynamic>{
    //                 'name': 'upload.txt',
    //                 'path': file.path,
    //                 'size': await file.length(),
    //               },
    //             ];
    //           }
    //           return null;
    //         });

    //     addTearDown(() async {
    //       TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    //           .setMockMethodCallHandler(pickerChannel, null);
    //       if (await tempDir.exists()) {
    //         await tempDir.delete(recursive: true);
    //       }
    //     });

    //     final uploadCompleter = Completer<void>();

    //     await tester.pumpWidget(
    //       MaterialApp(
    //         home: Scaffold(
    //           body: InstructionFileUploader(
    //             nextOrderIndex: 1,
    //             onUpload: (pickedFile, orderIndex, onProgress) async {
    //               expect(orderIndex, 1);
    //               expect(pickedFile.path, file.path);
    //               onProgress(0.5);
    //               await uploadCompleter.future;
    //             },
    //           ),
    //         ),
    //       ),
    //     );

    //     await tester.tap(find.text('Upload Instruction File'));
    //     await tester.pump();

    //     expect(find.byType(LinearProgressIndicator), findsOneWidget);

    //     uploadCompleter.complete();
    //     await tester.pumpAndSettle();

    //     expect(find.byType(LinearProgressIndicator), findsNothing);

    //     final cubit = LabDetailCubit(
    //       labService: _FakeLabService(
    //         labs: <LabModel>[_lab(1)],
    //         instructions: const <LabInstructionModel>[],
    //         submissions: const <LabSubmissionModel>[],
    //         attendance: const <LabAttendanceModel>[],
    //       ),
    //     );
    //     addTearDown(cubit.close);

    //     await tester.pumpWidget(
    //       BlocProvider<LabDetailCubit>.value(
    //         value: cubit,
    //         child: MaterialApp(
    //           home: Scaffold(
    //             body: InstructionManager(
    //               labId: '1',
    //               canManage: true,
    //               instructions: <LabInstructionModel>[
    //                 LabInstructionModel(
    //                   id: 2,
    //                   labId: 1,
    //                   file: const DriveFileModel(
    //                     driveFileId: 3,
    //                     driveId: 'drive-file-id',
    //                     fileName: 'guide.pdf',
    //                     webViewLink: 'https://drive.example/view',
    //                     downloadUrl: 'https://drive.example/download',
    //                     iframeUrl: 'https://drive.example/preview',
    //                   ),
    //                   orderIndex: 0,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     );

    //     await tester.pumpAndSettle();

    //     expect(find.text('Preview'), findsOneWidget);
    //     expect(find.text('Open in Drive'), findsOneWidget);
    //     expect(find.text('Download'), findsOneWidget);
    //   },
    // );

    testWidgets(
      'T040: late penalty is displayed, final score override is saved, and grading interaction is under 30 seconds',
      (WidgetTester tester) async {
        final dueDate = DateTime(2026, 4, 1, 10, 0, 0);
        final lateSubmission = _submission(
          id: 1,
          isLate: true,
          submittedAt: dueDate.add(const Duration(days: 2)),
        );

        double? savedFinalScore;
        double? savedLatePenaltyPercent;
        assignment_api.SubmissionStatus? savedStatus;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LabGradingPanel(
                submission: lateSubmission,
                maxScore: 100,
                dueDate: dueDate,
                onSave:
                    (finalScore, feedback, status, latePenaltyPercent) async {
                      savedFinalScore = finalScore;
                      savedLatePenaltyPercent = latePenaltyPercent;
                      savedStatus = status;
                    },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        await tester.enterText(find.byType(TextFormField).at(0), '80');
        await tester.pump();

        expect(find.textContaining('Late Penalty:'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField).at(1), '79');
        await tester.enterText(find.byType(TextFormField).at(2), 'Well done');

        await tester.tap(_buttonByLabel('Save Grade').first);
        await tester.pumpAndSettle();

        stopwatch.stop();

        expect(savedFinalScore, 79);
        expect(savedLatePenaltyPercent, isNotNull);
        expect(savedLatePenaltyPercent, greaterThan(0));
        expect(savedStatus, assignment_api.SubmissionStatus.submitted);
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 30)));
      },
    );

    testWidgets(
      'T040: lab creation flow completes under 60 seconds and list load/search performance thresholds are met',
      (WidgetTester tester) async {
        final loadService = _FakeLabService(
          labs: List<LabModel>.generate(100, (index) => _lab(index + 1)),
          instructions: const <LabInstructionModel>[],
          submissions: const <LabSubmissionModel>[],
          attendance: const <LabAttendanceModel>[],
          listDelay: const Duration(milliseconds: 60),
        );

        _setViewport(tester, const Size(768, 1024));

        final loadStopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          _buildLabsHost(
            labService: loadService,
            enrollmentService: _FakeEnrollmentService(<TeachingCourseModel>[
              _teachingCourse(),
            ]),
            storageService: _FakeStorageService(
              user: _userWithRole('instructor'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        loadStopwatch.stop();

        final labsContext = tester.element(find.byType(Scaffold).first);
        final labsCubit = BlocProvider.of<InstructorLabsCubit>(labsContext);
        final loadedState = labsCubit.state as InstructorLabsLoaded;
        expect(loadedState.labs.length, 100);
        expect(loadStopwatch.elapsed, lessThan(const Duration(seconds: 2)));

        final filterStopwatch = Stopwatch()..start();
        await tester.enterText(find.byType(TextField).first, 'Lab 99');
        await tester.pump();
        filterStopwatch.stop();

        final filteredState = labsCubit.state as InstructorLabsLoaded;
        expect(filteredState.filteredLabs.length, 1);
        expect(
          filterStopwatch.elapsed,
          lessThan(const Duration(milliseconds: 500)),
        );

        final createStopwatch = Stopwatch()..start();
        await tester.tap(_buttonByLabel('Create New Lab').first);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).first,
          'Performance Lab',
        );
        await tester.tap(_buttonByLabel('Create Lab').first);
        await tester.pumpAndSettle();
        createStopwatch.stop();

        expect(find.text('Lab created successfully.'), findsOneWidget);
        expect(createStopwatch.elapsed, lessThan(const Duration(seconds: 60)));
      },
    );

    test(
      'T040: attendance marking for 30 students completes under 2 minutes',
      () async {
        final attendanceRecords = List<LabAttendanceModel>.generate(
          30,
          (index) => _attendanceRecord(userId: index + 1),
        );

        final labService = _FakeLabService(
          labs: <LabModel>[_lab(1)],
          instructions: const <LabInstructionModel>[],
          submissions: const <LabSubmissionModel>[],
          attendance: attendanceRecords,
          markAttendanceDelay: const Duration(milliseconds: 2),
        );

        final cubit = LabDetailCubit(labService: labService);
        addTearDown(cubit.close);

        await cubit.loadLabDetail('1');
        await cubit.loadAttendance('1');

        final updates = List<AttendanceData>.generate(
          30,
          (index) => AttendanceData(
            userId: index + 1,
            attendanceStatus: lab_api.LabAttendanceStatus.present,
          ),
        );

        final stopwatch = Stopwatch()..start();
        await cubit.markAttendance('1', updates);
        stopwatch.stop();

        expect(labService.markAttendanceCalls, 30);
        expect(stopwatch.elapsed, lessThan(const Duration(minutes: 2)));
      },
    );
  });
}
