# Codex Prompt: Student Grades API Migration + PDF Redesign

# Backend Path: D:\Graduation\backend\last_backend\EduVerse_Backend
# Website Frontend Path: D:\Graduation\frontend_tarek\Eduverse-Frontend

## Objective
Migrate EduVerse Flutter mobile Grades feature from mock data to real API calls (Student role only). Also redesign the PDF export to use real data with a modern academic layout. Do NOT modify any UI widgets.

## Endpoints (Student-only)
1. `GET /api/grades/my` → `Grade[]` (flat list, one per assessment)
2. `GET /api/grades/gpa/{studentId}` → `{ semesterGpa, cumulativeGpa }`
3. `GET /api/grades/transcript/{studentId}` → `TranscriptResponseDto`

## Project Patterns (MUST follow)
- `CoreApiClient` (lib/services/api/core_api_client.dart) — Dio client with auth interceptor, token refresh
- `RetryHelper.execute<T>()` (lib/common/retry_helper.dart) — wraps API calls with 3 retries + exponential backoff
- `ServiceResult<T>` (lib/common/service_error.dart) — success/failure wrapper
- `StorageService` (lib/services/storage_service.dart) — `getUserData()` returns user info including `userId`, `fullName`
- Existing models: `GradeGpaModel`, `CourseGrade`, `AssessmentGrade`, `GradeStatistics`, `GradeTrendPoint`, `SemesterModel`
- Existing enums: `GradeLetter`, `AssessmentType` with extensions for `.label`, `.color`, `.icon`, `.gpa`

## Tasks (in dependency order)

### Task 1: Create `lib/models/grades/api_grade_response.dart`
Model matching backend `Grade` entity JSON. Key fields:
- `id` (int), `userId` (int), `courseId` (int)
- `gradeType` (String — 'assignment'|'quiz'|'lab'|'exam'|'final'|'participation'|'project'|'other')
- `assignmentId?` (int?), `quizId?` (int?), `labId?` (int?)
- `score` (double — parse from decimal string like "85.00")
- `maxScore` (double — parse from decimal string)
- `percentage?` (double?), `letterGrade?` (String?), `feedback?` (String?)
- `gradedBy?` (int?), `gradedAt?` (DateTime?)
- `isPublished` (int — 0 or 1)
- `createdAt` (DateTime), `updatedAt` (DateTime)
- Nested `course` → `ApiCourseInfo` { id, name, code, credits }
- Nested `assignment?` → `ApiAssignmentInfo?` { id, title }
- Include `fromJson` factory constructors. Use safe parsing (tryParse for numbers).

### Task 2: Create `lib/models/grades/api_transcript_response.dart`
Model matching `TranscriptResponseDto`. Fields:
- `studentId` (int), `studentName` (String), `cumulativeGpa` (double), `totalCredits` (int)
- `semesters` → List of `ApiTranscriptSemester` { semesterId, semesterName, gpa, courses }
- Each course → `ApiTranscriptCourse` { courseId, courseName, credits, letterGrade, score, maxScore }
- Include `fromJson` factories.

### Task 3: Create `lib/services/api/grades_service.dart`
```dart
class GradesService {
  final CoreApiClient _client;
  GradesService({required CoreApiClient coreApiClient}) : _client = coreApiClient;

  Future<ServiceResult<List<ApiGradeResponse>>> getMyGrades() async {
    return RetryHelper.execute(() async {
      final response = await _client.dio.get('/grades/my');
      final list = (response.data as List).map((e) => ApiGradeResponse.fromJson(e as Map<String, dynamic>)).toList();
      return list;
    }, fallbackMessage: 'Failed to load grades');
  }

  Future<ServiceResult<GradeGpaModel>> getStudentGpa(int studentId) async {
    return RetryHelper.execute(() async {
      final response = await _client.dio.get('/grades/gpa/$studentId');
      return GradeGpaModel.fromJson(response.data as Map<String, dynamic>);
    }, fallbackMessage: 'Failed to load GPA');
  }

  Future<ServiceResult<ApiTranscriptResponse>> getTranscript(int studentId) async {
    return RetryHelper.execute(() async {
      final response = await _client.dio.get('/grades/transcript/$studentId');
      return ApiTranscriptResponse.fromJson(response.data as Map<String, dynamic>);
    }, fallbackMessage: 'Failed to load transcript');
  }
}
```

### Task 4: Create `lib/services/api/grades_normalizer.dart`
Port web frontend grouping logic (GradesTranscript.tsx lines 640-663):
- `groupByCourse(List<ApiGradeResponse>)` → `List<CourseGrade>`: Group by courseId, each grade becomes an AssessmentGrade
- Map `gradeType` string → `AssessmentType` enum: assignment→assignment, quiz→quiz, lab→lab, exam→exam, final→finalExam, participation→participation, project→project, other→exam
- `isPublished == 1` maps to `isGraded = true`
- `weight`: not in API — compute as `(maxScore / totalMaxScoreInCourse) * 100`
- Generate deterministic course color from courseId using a color palette
- `computeStatistics(List<CourseGrade>)` → `GradeStatistics`
- Course `instructor` field not in API — use empty string or "Instructor"

### Task 5: Modify `lib/bloc/grades/grades_cubit.dart`
- Add `GradesService? _gradesService` parameter to constructor
- In `loadGrades()`:
  - If `_gradesService != null`, call `_gradesService.getMyGrades()`:
    - On success: use `GradesNormalizer.groupByCourse()` to convert to `List<CourseGrade>`
    - On failure: fall back to `_generateDemoCourses()` (keep as private fallback)
  - Use `GradesNormalizer.computeStatistics()` for statistics
  - Call GPA endpoint for real GPA overlay (existing pattern)
- Remove the hardcoded demo CourseGrade/AssessmentGrade data from `_generateDemoCourses()` — replace with empty list or keep as absolute fallback
- Keep `_generateGradeTrend()` and `_generateDemoSemesters()` (no API for these)
- Keep ALL filter/sort/search/viewMode methods unchanged

### Task 6: Modify `lib/screens/student/grades_screen.dart`
**Line ~174** — Change BlocProvider injection:
```dart
create: (context) => GradesCubit(
  gradesService: GradesService(coreApiClient: CoreApiClient()),
  studentStatsService: StudentStatsService(coreApiClient: CoreApiClient()),
  storageService: StorageService(),
),
```

**Lines 122-141** — In `_generatePdfReport()`, replace hardcoded student info:
```dart
// Replace these hardcoded values:
//   studentName: 'Ahmed Mohamed',
//   studentId: 'STU-2024-001',
//   program: 'Bachelor of Computer Science',
// With real data from StorageService:
final storageService = StorageService();
final userData = await storageService.getUserData();
// Then use: userData?.fullName, userData?.userId.toString(), userData?.program
```

### Task 7: Modify `lib/screens/student/grade_analysis_screen.dart`
**Line ~48** — Same BlocProvider injection as Task 6.

### Task 8: Redesign `lib/common/services/grade_pdf_service.dart` — FULL REWRITE
This is a 1840-line file that generates the PDF. Rewrite it with these requirements:

**Keep unchanged:**
- `GradeReportData` class (lines 10-83) — keep the data model as-is, it already accepts `List<CourseGrade>` etc.
- `generateAndShareReport()` method signature (lines 109-125)
- Google Fonts loading pattern (lines 142-150)
- Color palette constants (lines 87-101) — but add more colors

**Redesign the PDF layout:**

**Page 1 — Cover Page** (`_buildCoverPage`):
- Keep gradient background with decorative circles
- Use real `data.studentName` and `data.studentId` (already passed, just verify no hardcoded override)
- Add "Official Academic Transcript" subtitle
- Quick stats row: Cumulative GPA, Credits Earned, Total Courses

**Page 2 — Academic Summary** (`_buildAcademicSummary`, `_buildGPAAnalysisSection`, `_buildGradeDistributionSection`):
- Keep gradient summary card
- GPA trend bar chart using real `gpaTrend` data
- Grade distribution with color-coded cards
- ADD: Semester Performance Summary Table — one row per semester: name, course count, credits, GPA

**Page 3+ — Detailed Course Grades** (`_buildSemesterCourseSections`) — MAJOR REDESIGN:
- Semester header with gradient + GPA badge (keep)
- For each course, create a **course card** with:
  - Header row: course name, code, credits, overall grade badge
  - **Assessment detail table** (NEW): one row per assessment showing:
    - Type badge (color-coded: exam=indigo, quiz=purple, assignment=blue, project=green, lab=teal, presentation=amber, midterm=pink, final=red, participation=gray)
    - Assessment name
    - Score column: "42/50"
    - Percentage column: "84.0%"
    - Letter grade badge (color-coded)
    - Status: ✓ Published or ⏳ Pending
    - Feedback text (if any, in smaller italic font)
  - Footer row: Course weighted average, grade, GPA points, credit hours
  - Alternate row colors for readability

**Page 4 — Insights & Goals** (`_buildPerformanceInsights`, `_buildAcademicGoals`, `_buildReportSignature`):
- Keep Strengths / Needs Focus split cards
- Keep graduation progress bars
- Keep signature with real student ID and timestamp

**Assessment type color mapping for PDF badges:**
```dart
static const _examColor = PdfColor.fromInt(0xFF6366F1);      // Indigo
static const _quizColor = PdfColor.fromInt(0xFF8B5CF6);      // Purple
static const _assignmentColor = PdfColor.fromInt(0xFF3B82F6); // Blue
static const _projectColor = PdfColor.fromInt(0xFF10B981);    // Green
static const _labColor = PdfColor.fromInt(0xFF14B8A6);        // Teal
static const _presentationColor = PdfColor.fromInt(0xFFF59E0B); // Amber
static const _midtermColor = PdfColor.fromInt(0xFFEC4899);    // Pink
static const _finalExamColor = PdfColor.fromInt(0xFFEF4444);  // Red
static const _participationColor = PdfColor.fromInt(0xFF64748B); // Slate
```

**New helper methods needed:**
- `_buildCourseDetailCard(CourseGrade course)` — renders one course with its assessment table
- `_buildAssessmentRow(AssessmentGrade assessment, bool isEven)` — one table row
- `_buildAssessmentTypeBadge(AssessmentType type)` — small color-coded pill badge
- `_buildGradeLetterBadge(GradeLetter grade)` — color-coded grade pill
- `_buildSemesterSummaryTable(GradeReportData data)` — semester overview table

## Do NOT Change
- `grade_card.dart`, `grade_details_sheet.dart`, `grades_filter_sheet.dart` — UI widgets
- `grades_state.dart` — state class
- Any UI layout or design in the screens
- `GradeReportData` class structure in the PDF service

## VERIFICATION
After all changes, run:
```bash
cd D:\Graduation\EduVerse\edu_verse
flutter analyze
flutter build apk --debug