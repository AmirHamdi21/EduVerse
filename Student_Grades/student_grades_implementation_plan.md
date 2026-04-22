# Student Grades — API-Parity Migration Plan

# Backend Path: D:\Graduation\backend\last_backend\EduVerse_Backend
# Website Frontend Path: D:\Graduation\frontend_tarek\Eduverse-Frontend

## Goal

Replace **all mock/demo data** in the Flutter Student Grades feature with **real API calls**, achieving **1:1 feature parity** with the React web frontend — **Student role only**. Also **redesign the PDF export** to use real API data and have a modern, academic, colorful layout.

> [!IMPORTANT]
> **The existing Flutter Grades UI must NOT be changed.** Only the data source is migrated. The PDF service is **fully rewritten** for a modern academic design.

---

## 1. Endpoint Audit Table (Student-Relevant Only)

| # | Path | HTTP | Purpose |
|---|---|---|---|
| S1 | `/api/grades/my` | GET | Fetch authenticated student's own grades |
| S2 | `/api/grades/gpa/{studentId}` | GET | Fetch GPA (semester + cumulative) |
| S3 | `/api/grades/transcript/{studentId}` | GET | Fetch full transcript |

---

## 2. Backend API Response Shapes

### S1: `GET /api/grades/my` → `Grade[]`
```json
{
  "id": 1, "userId": 57, "courseId": 1,
  "gradeType": "assignment",
  "score": "85.00", "maxScore": "100.00", "percentage": "85.00",
  "letterGrade": "B", "feedback": "Great work",
  "isPublished": 1, "gradedAt": "2025-10-15T...",
  "course": { "id": 1, "name": "Data Structures", "code": "CS301", "credits": 3 },
  "assignment": { "id": 3, "title": "Assignment 1" }
}
```

### S2: `GET /api/grades/gpa/{studentId}`
```json
{ "semesterGpa": 3.55, "cumulativeGpa": 3.55 }
```

### S3: `GET /api/grades/transcript/{studentId}`
```json
{
  "studentId": 57, "studentName": "Ahmed Mohamed",
  "cumulativeGpa": 3.55, "totalCredits": 30,
  "semesters": [{ "semesterName": "All Courses", "gpa": 3.55,
    "courses": [{ "courseId": 1, "courseName": "Data Structures", "credits": 3, "letterGrade": "A", "score": 92.00, "maxScore": 100.00 }]
  }]
}
```

---

## 3. Proposed Changes — Phased Implementation

### Phase 1: New API Response Model
#### [NEW] `lib/models/grades/api_grade_response.dart`
Model matching backend `Grade` entity JSON with `fromJson` factories. Includes nested `ApiCourseInfo` and `ApiAssignmentInfo`.

#### [NEW] `lib/models/grades/api_transcript_response.dart`
Model matching `TranscriptResponseDto` with `fromJson`. Includes nested `ApiTranscriptSemester` and `ApiTranscriptCourse`.

---

### Phase 2: New Grades Service
#### [NEW] `lib/services/api/grades_service.dart`
Three methods using `CoreApiClient` + `RetryHelper.execute<T>()`:
- `getMyGrades()` → `ServiceResult<List<ApiGradeResponse>>`
- `getStudentGpa(int)` → `ServiceResult<GradeGpaModel>`
- `getTranscript(int)` → `ServiceResult<ApiTranscriptResponse>`

---

### Phase 3: Grade Normalization Utility
#### [NEW] `lib/services/api/grades_normalizer.dart`
Ports web frontend grouping logic:
- `groupByCourse(List<ApiGradeResponse>)` → `List<CourseGrade>`
- `computeStatistics(List<CourseGrade>)` → `GradeStatistics`
- `mapGradeType(String)` → `AssessmentType`
- `courseColor(int)` → deterministic `Color`

---

### Phase 4: Modify GradesCubit
#### [MODIFY] `lib/bloc/grades/grades_cubit.dart`

**What changes:**
1. Constructor accepts `GradesService` alongside existing params
2. `loadGrades()` calls `GradesService.getMyGrades()` + `GradesNormalizer.groupByCourse()` instead of `_generateDemoCourses()`
3. Uses `GradesNormalizer.computeStatistics()` for statistics
4. Calls `GradesService.getStudentGpa()` for real GPA
5. **Remove**: All `_generateDemoCourses()` hardcoded data (~400 lines)
6. **Keep**: `_generateGradeTrend()` and `_generateDemoSemesters()` as fallback (no trend API)
7. **Keep**: All filter/sort/search methods unchanged

---

### Phase 5: Update Screen Injections
#### [MODIFY] `lib/screens/student/grades_screen.dart`

**Line ~174** — Change `BlocProvider.create`:
```dart
// BEFORE
create: (context) => GradesCubit(),

// AFTER
create: (context) => GradesCubit(
  gradesService: GradesService(coreApiClient: CoreApiClient()),
  studentStatsService: StudentStatsService(coreApiClient: CoreApiClient()),
  storageService: StorageService(),
),
```

#### [MODIFY] `lib/screens/student/grade_analysis_screen.dart`

**Line ~48** — Same injection change as above.

---

### Phase 6: Update PDF Report Data Source
#### [MODIFY] `lib/screens/student/grades_screen.dart`

## Check the backend endpoints also and their response that could be used in the pdf structure and verify that every parameter and data is correctly used (backend path: D:\Graduation\backend\last_backend\EduVerse_Backend)

**Lines 122–141** — The `_generatePdfReport()` method constructs `GradeReportData` with **hardcoded student info**. Replace with real data from the cubit/API:

```dart
// BEFORE (lines 123-141):
final reportData = GradeReportData(
  studentName: 'Ahmed Mohamed', // TODO: Get from user profile
  studentId: 'STU-2024-001',
  program: 'Bachelor of Computer Science',
  ...
);

// AFTER:
// Get real user data from StorageService
final storageService = StorageService();
final userData = await storageService.getUserData();
final reportData = GradeReportData(
  studentName: userData?.fullName ?? 'Student',
  studentId: userData?.userId.toString() ?? '',
  program: userData?.program ?? 'Bachelor Program',
  cumulativeGPA: state.statistics?.cumulativeGPA ?? 0,
  semesterGPA: state.semesterGPA,
  totalCredits: state.statistics?.totalCredits ?? 0,
  completedCredits: state.statistics?.completedCredits ?? 0,
  targetCredits: 120,
  currentSemester: state.selectedSemester != null
      ? '${state.selectedSemester!.name} ${state.selectedSemester!.year}'
      : 'Current',
  courses: state.courses,
  semesters: state.semesters,
  gpaTrend: state.gradeTrend,
  statistics: state.statistics,
);
```

---

### Phase 7: Redesign PDF Report Service
#### [MODIFY] `lib/common/services/grade_pdf_service.dart` — **FULL REWRITE** (1840 lines)

> [!IMPORTANT]
> This is the most significant change. The entire `GradePdfReportService` class will be **rewritten** to produce a modern, academic, colorful PDF that clearly presents real student data.

**Current problems with existing PDF:**
1. Hardcoded student info on cover page ("Ahmed Mohamed", "STU-2024-001")
2. Course tables show summary-level data only (course name + grade) — no individual assessment detail
3. No per-course assessment breakdown table in the PDF
4. Performance insights use only course-level percentages
5. GPA trend chart uses synthetic `GradeTrendPoint` data

**New PDF Design Requirements:**

##### Page 1 — Cover Page
- **Keep**: Gradient background, decorative circles, EduVerse branding
- **Change**: Use real `studentName`, `studentId`, `program` from `GradeReportData` (now fed from API)
- **Add**: University name/department if available
- **Add**: "Official Academic Transcript" vs current "Grade Report" title
- **Keep**: Quick stats row (GPA, Credits, Semester)

##### Page 2 — Academic Summary & GPA Analysis
- **Keep**: Academic Performance Summary card with gradient
- **Change**: GPA Analysis section — use real GPA from API instead of synthetic trend
- **Keep**: Grade Distribution section with color-coded grade cards
- **Add**: A "Semester Performance Table" — one row per semester showing semester name, courses count, credits, semester GPA

##### Page 3+ — Detailed Course Grades (MAJOR REDESIGN)
- **Keep**: Semester header with gradient and GPA badge
- **REDESIGN**: Course rows — for each course, show:
  - Course name, code, instructor, credits
  - **NEW: Expandable assessment detail table per course** showing each individual assessment:
    - Assessment name, type (badge with color), score/maxScore, percentage, letter grade, feedback
  - Course-level summary row: weighted average, current grade badge, graded/total count
- **Color-code**: Each assessment type gets its own color badge (matching Flutter UI colors)
- **Add**: Published/Draft status indicators per grade

##### Page 4 — Performance Insights & Recommendations
- **Keep**: Strengths / Needs Focus cards
- **Change**: Use real data (from API courses) for top/bottom performers
- **Keep**: Academic Goals (graduation progress)
- **Keep**: Report signature with generation timestamp

**Specific methods to rewrite/add:**

| Method | Lines | Action |
|---|---|---|
| `_buildCoverPage()` | 223-468 | **MODIFY** — real student data, enhanced styling |
| `_buildAcademicSummary()` | 598-657 | **MODIFY** — real data integration |
| `_buildGPAAnalysisSection()` | 737-903 | **MODIFY** — real GPA data |
| `_buildGradeDistributionSection()` | 907-1008 | **MODIFY** — real grade distribution |
| `_buildSemesterCourseSections()` | 1011-1368 | **MAJOR REWRITE** — add per-course assessment detail tables |
| `_buildCourseAssessmentTable()` | N/A | **NEW** — builds a table of individual assessments within each course card |
| `_buildAssessmentTypeBadge()` | N/A | **NEW** — color-coded badge for assessment type |
| `_buildPerformanceInsights()` | 1371-1627 | **MODIFY** — real data |
| `_buildAcademicGoals()` | 1651-1697 | **MODIFY** — real credits from API |
| `_buildReportSignature()` | 1767-1838 | **MODIFY** — real student ID |

**New assessment detail table design (per course):**
```
┌─────────────────────────────────────────────────────────────────┐
│  [Exam Badge] Midterm Exam          42/50   84.0%   B    ✓     │
│  [Quiz Badge] Quiz 1: Arrays        9/10    90.0%   A-   ✓     │
│  [Project]    Graph Algorithms      45/50   90.0%   A-   ✓     │
│  [Lab Badge]  Lab Work              18/20   90.0%   A-   ✓     │
│  [Final]      Final Exam            --/100  --      --   ⏳    │
│─────────────────────────────────────────────────────────────────│
│  Course Average: 88.5%  |  Grade: B+  |  GPA: 3.3  |  4 cr    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. File Change Summary

| Category | File | Status | Est. Lines |
|---|---|---|---|
| Model | `lib/models/grades/api_grade_response.dart` | **NEW** | ~90 |
| Model | `lib/models/grades/api_transcript_response.dart` | **NEW** | ~70 |
| Service | `lib/services/api/grades_service.dart` | **NEW** | ~80 |
| Utility | `lib/services/api/grades_normalizer.dart` | **NEW** | ~120 |
| Cubit | `lib/bloc/grades/grades_cubit.dart` | **MODIFY** | ~200 |
| Screen | `lib/screens/student/grades_screen.dart` | **MODIFY** | ~25 (injection + PDF data) |
| Screen | `lib/screens/student/grade_analysis_screen.dart` | **MODIFY** | ~5 |
| PDF | `lib/common/services/grade_pdf_service.dart` | **FULL REWRITE** | ~2000 |

**Total new files:** 4  
**Total modified files:** 4  
**UI widget files changed:** 0

---

## 5. Verification Plan

### Build Check
```bash
flutter analyze
flutter build apk --debug
```

### Manual Smoke Tests
1. Grades Screen loads real data from API
2. GPA card shows real cumulative/semester GPA
3. Grade details sheet shows real assessments
4. Filter/sort works with real data
5. Grade Analysis screen computes from real data
6. **PDF Export**: Tap PDF button → verify:
   - Cover page shows real student name/ID (not hardcoded)
   - Course tables show real grades from API
   - Each course card includes individual assessment detail rows
   - Assessment type badges are color-coded
   - Grade distribution uses real data
   - Performance insights reference real top/bottom courses
7. Error handling: WiFi off → shows error state
