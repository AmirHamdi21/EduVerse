# Research: TA — Courses, Assignments & Labs Integration

**Date**: 2026-04-14
**Phase**: Phase 0 — Research

## Decision 1: TA Course Detail Sub-Tabs — Data Source Strategy

**Context**: The spec requires 9 sub-tabs on TA course detail, all attempting live API fetches. Some sub-tabs (Overview, Sections & Labs, Assignments, Students) have known backend endpoints. Others (Lectures, Materials, Grading, Attendance, Announcements) may need endpoint discovery.

**Decision**: All 9 sub-tabs follow the same pattern:
1. Attempt live API fetch via service call on tab activation
2. On success: render data using existing widget patterns
3. On 404 or "endpoint not found": render structured empty state ("No {data} available for this course")
4. On other errors: render error state with retry button

**Rationale**: This ensures consistency, avoids mock data, and gracefully handles missing backend endpoints. The backend project path (`C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`) is available for endpoint discovery during implementation.

**Alternatives considered**:
- A: Only live API for known endpoints, mock for unknown — rejected (violates Constitution Principle VII)
- B: All mock with TODO comments — rejected (violates Constitution Principle VII)
- C: All live API with empty state fallback — **selected**

**Resolved sub-tabs with known endpoints**:

| Sub-Tab | Primary Endpoint(s) | Notes |
|---|---|---|
| **Overview** | `GET /enrollments/teaching` (course info), `GET /sections/{id}/students` (student count), `GET /assignments?courseId={id}` (assignment count), `GET /labs?courseId={id}` (lab count) | Stats aggregated from multiple sources |
| **Sections & Labs** | `GET /sections/course/{courseId}`, `GET /labs?courseId={id}` | Read-only section display + lab list |
| **Lectures** | `GET /courses/{id}/structure` | Week-based structure with lectures |
| **Materials** | `GET /courses/{id}/materials` | Published materials only |
| **Assignments** | `GET /assignments?courseId={id}` + `GET /assignments/{id}/submissions` | Assignment list with submission counts |
| **Grading** | `GET /assignments?courseId={id}` + `GET /assignments/{id}/submissions` | Pending grading tasks aggregated |
| **Attendance** | `GET /labs/{id}/attendance` (per lab) | Aggregated across all course labs |
| **Students** | `GET /sections/{sectionId}/students` | Section-scoped student roster |
| **Announcements** | **Needs backend discovery** — may not exist as separate endpoint; could be part of communication service | If no endpoint exists, show empty state |

**Announcements endpoint status**: No dedicated announcements endpoint found in documented API docs. During implementation, check `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend` for any announcement controller. If none exists, the Announcements sub-tab shows an empty state with "Announcements are not available for this course."

---

## Decision 2: Screen Architecture — Hybrid Approach

**Context**: Clarification session resolved that TA should reuse Instructor CRUD screens and build TA-specific course screens.

**Decision**:
- **Assignment CRUD**: Reuse `widgets/instructor/assignments/assignment_create_form.dart`, `assignment_card.dart`, `grading_panel.dart`, `submission_list_item.dart` — these components are already role-agnostic (they just need data + callbacks)
- **Lab CRUD**: Reuse `widgets/instructor/labs/lab_create_form.dart`, `lab_card.dart`, `grading_panel.dart`, `attendance_sheet.dart`, `instruction_manager.dart`, `instruction_file_uploader.dart`
- **Course List & Detail**: Build new TA-specific screens with `TAColors` and existing TA widget patterns

**Rationale**: Instructor CRUD components are already built, tested, and connected to live APIs. Reusing them avoids duplication and ensures TA assignment/lab management behaves identically to instructor management. Course screens need TA-specific UI because the website's TA CoursesPage has a different layout than the instructor's CoursesPage.

**Alternatives considered**:
- A: All new TA screens — rejected (duplicates Phase 6/7 work)
- B: All shared screens with role-based rendering — rejected (too complex, violates separation)
- C: Hybrid — **selected**

---

## Decision 3: Mock Data Removal Strategy

**Context**: Audit identified 2 CRITICAL and 1 HIGH priority files needing mock data removal.

**Decision**: Removal order and replacement strategy:

| File | Current State | Replacement |
|---|---|---|
| `ta_labs_list_screen.dart` | Full mock (6 labs, 3 courses, fake names) | New `TALabsCubit` + `LabService.getAll()` |
| `ta_lab_detail_screen.dart` | Full mock (5 `_getMock*()` methods) | New `TALabDetailCubit` + `LabService.getById()`, `getSubmissions()`, `getAttendance()` |
| `ta_course_detail_screen.dart` | Partial (BLoC for course, empty/hardcoded for tabs) | Wire each tab to its own service call |

**Widget-level model replacements**:

| Local Model | Replacement Canonical Model |
|---|---|
| `TALabListItem` (in ta_labs_list_screen.dart) | `LabModel` from `lib/models/labs/lab_model.dart` |
| `TACourseWithLabs` (in ta_labs_list_screen.dart) | Derived from `TeachingCourseModel` + `LabModel[]` |
| `TALabDetail` (in ta_lab_detail_screen.dart) | `LabModel` + `LabSubmissionModel[]` |
| `TALabSubmission` (in ta_lab_submissions_tab.dart) | `LabSubmissionModel` from `lib/models/labs/lab_submission_model.dart` |
| `TASubmissionStatus` enum | `SubmissionStatus` from `lib/models/labs/lab_submission_model.dart` |
| `TALabSession`, `TALabStudent` | `LabAttendanceModel` from `lib/models/core/lab_attendance_model.dart` |
| `TAAttendanceStatus` enum | `LabAttendanceStatus` from `lib/models/core/lab_attendance_model.dart` |
| `TAGradingTask` | `AssignmentSubmissionModel` from `lib/models/assignments/assignment_submission_model.dart` |
| `TALabTaskItem`, `TALabQuestion`, `TALabActivityItem` | Remove — replaced by real data from BLoC |
| `TAUpcomingTask`, `TARecentActivity` | Keep as lightweight DTOs if parent provides data from BLoC |

**Rationale**: Reusing canonical models ensures type consistency across the app and avoids the proliferation of duplicate local models.

---

## Decision 4: Section-Scoped Data Access

**Context**: Clarification resolved that TA scope is section-specific.

**Decision**: Backend is assumed to already filter API responses by the TA's assigned sections (the backend knows which sections a TA is assigned to via `/enrollments/sections/{id}/tas`). The frontend does NOT need additional client-side filtering for section scope. However, if any endpoint returns course-wide data, the frontend must filter by section IDs obtained from the TA's teaching course model.

**Rationale**: The backend has the source of truth for TA section assignments. Frontend should not reimplement access control.

**Risk**: If backend does NOT filter by section for some endpoints, the frontend may show data beyond the TA's scope. During implementation, verify each endpoint's response scope.

---

## Decision 5: BLoC Architecture for TA Features

**Context**: Existing `CoursesBloc` handles student/instructor/TA events in one class. Adding more TA-specific events would bloat it.

**Decision**: Create dedicated TA Cubits following Phase 4/6/7 patterns:
- `TACoursesCubit` — manages TA course list state (may reuse existing `CoursesBloc` if `TACoursesFetched` event already handles it adequately)
- `TALabsCubit` — manages TA labs list (fetch, filter, search)
- Reuse existing `InstructorAssignmentsCubit` for TA assignment management (same data model, same operations)
- Reuse existing `InstructorLabsCubit` + `LabDetailCubit` for TA lab management

**Rationale**: Following established patterns from Phase 4/6/7 ensures consistency. Reusing instructor cubits for CRUD avoids duplication.

**Alternatives considered**:
- A: Add TA events to existing CoursesBloc — rejected (bloated, hard to test)
- B: All new cubits — rejected (unnecessary duplication for CRUD)
- C: Hybrid (new cubits for list views, reuse instructor for CRUD) — **selected**

---

## Decision 6: File Upload Endpoints for TA

**Context**: TAs can upload lab instruction files and TA-only materials.

**Decision**:
- Lab instruction files: `POST /labs/{id}/instructions/upload` with FormData field `file` (same as Instructor)
- TA materials: `POST /labs/{id}/ta-materials/upload` with FormData field `file`
- Both use `Dio.FormData` with `MultipartFile.fromFile()`, progress via `onSendProgress`
- Client-side validation: documents max 50MB, images max 10MB

**Rationale**: These endpoints already exist from Phase 7 (Instructor Labs). TA uses the same endpoints with the same FormData format.

---

## Decision 7: Announcements Sub-Tabs Fallback

**Context**: No dedicated announcements endpoint found in API documentation.

**Decision**: If no announcements endpoint exists in the backend after inspecting `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`:
- Announcements sub-tab renders a structured empty state: "Announcements are not available for this course"
- The empty state uses the same visual style as other empty sub-tabs (matching TA design patterns)
- A TODO comment is NOT left in the code — the empty state IS the correct behavior when no backend support exists

**Rationale**: Empty states are preferred over mock data or broken API calls. The sub-tab still exists for website parity but gracefully handles missing data.
