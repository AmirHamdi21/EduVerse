import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/drive_file_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/lab_enums.dart' as api;
import 'package:edu_verse/models/core/lab_attendance_model.dart';
import 'package:edu_verse/models/core/lab_instruction_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/screens/student/lab_detail_screen.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/student/labs/instruction_viewer.dart';

class _FakeLabService extends LabService {
  _FakeLabService({required this.lab, required this.attendance})
    : super(coreApiClient: CoreApiClient.test());

  final LabModel lab;
  final List<LabAttendanceModel> attendance;

  @override
  Future<ServiceResult<LabModel>> getById(
    dynamic id, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<LabModel>.success(lab);
  }

  @override
  Future<ServiceResult<List<LabInstructionModel>>> getInstructions(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<LabInstructionModel>>.success(
      const <LabInstructionModel>[],
    );
  }

  @override
  Future<ServiceResult<List<LabSubmissionModel>>> getMySubmission(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<LabSubmissionModel>>.success(
      const <LabSubmissionModel>[],
    );
  }

  @override
  Future<ServiceResult<List<LabAttendanceModel>>> getAttendance(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<LabAttendanceModel>>.success(attendance);
  }
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses({
    int? semester,
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<CourseEnrollmentModel>>.success(
      const <CourseEnrollmentModel>[],
    );
  }
}

CourseModel _course(int id) {
  return CourseModel(
    id: id,
    departmentId: 1,
    code: 'CS$id',
    name: 'Course $id',
    credits: 3,
    courseLevel: CourseLevel.freshman,
    courseStatus: CourseStatus.active,
  );
}

LabModel _detailLab() {
  return LabModel(
    id: 'lab-1',
    labId: 1,
    courseId: 1,
    title: 'Detail Lab',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    maxScore: 100,
    status: api.LabStatus.published,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('renders markdown text and file action buttons', (
    WidgetTester tester,
  ) async {
    final instructions = <LabInstructionModel>[
      const LabInstructionModel(
        id: 1,
        labId: 1,
        instructionText: '## Step 1\nWrite code',
        orderIndex: 0,
      ),
      LabInstructionModel(
        id: 2,
        labId: 1,
        file: const DriveFileModel(
          driveFileId: 1,
          driveId: 'drive-id',
          fileName: 'lab-guide.pdf',
          webViewLink: 'https://drive.google.com/file/d/drive-id/view',
          downloadUrl:
              'https://drive.google.com/uc?id=drive-id&export=download',
          iframeUrl: 'https://drive.google.com/file/d/drive-id/preview',
        ),
        orderIndex: 1,
      ),
    ];

    await tester.pumpWidget(
      _wrap(InstructionViewer(instructions: instructions, isDark: false)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Write code'), findsOneWidget);
    expect(find.text('lab-guide.pdf'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
  });

  testWidgets('shows empty state when no instructions exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const InstructionViewer(
          instructions: <LabInstructionModel>[],
          isDark: false,
        ),
      ),
    );

    expect(find.text('No instructions provided yet.'), findsOneWidget);
  });

  testWidgets('LabDetailScreen renders attendance badge when present', (
    WidgetTester tester,
  ) async {
    final lab = _detailLab();
    final labService = _FakeLabService(
      lab: lab,
      attendance: const <LabAttendanceModel>[
        LabAttendanceModel(
          id: 1,
          labId: 1,
          userId: 7,
          attendanceStatus: api.LabAttendanceStatus.present,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
        home: BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(storageService: StorageService()),
          child: LabDetailScreen(
            labId: lab.id,
            labService: labService,
            enrollmentService: _FakeEnrollmentService(),
            lab: lab,
            enrolledCourses: <CourseModel>[_course(lab.courseId)],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Attendance: Present'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Attendance: Present'), findsOneWidget);
  });
}
