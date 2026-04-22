# Research: Phase 5 — Instructor Courses & Materials Management

**Feature**: 019-instructor-courses-materials
**Date**: April 12, 2026

---

## Research Task 1: Existing Mock Data Audit

### Finding: Mock Data Locations in Phase 5 Scope

| File | Mock Pattern | Lines | Action |
|------|-------------|-------|--------|
| `lib/screens/instructor/courses/instructor_courses_screen.dart` | Static course list literals, hardcoded course names/codes/enrollment counts | ~77KB file | Replace with `EnrollmentService.getTeachingCourses()` via BLoC |
| `lib/screens/instructor/upload_materials/upload_materials_screen.dart` | Static material list, fake upload confirmations, hardcoded material types | ~43KB file | Replace with `MaterialService` upload calls via BLoC |
| `lib/screens/instructor/course_management/course_management_screen.dart` | Static tab data, mock overview stats, fake student lists, mock schedules | Tab-based screen | Replace each tab's data source with live API calls |
| `lib/widgets/instructor/course_management/overview_tab.dart` | Hardcoded stats cards, fake deadlines, mock engagement data | Widget | Wire to live course structure, enrollment, assignment data |
| `lib/widgets/instructor/course_management/materials_tab.dart` | Static material list, fake bundle groups | Widget | Wire to `GET /courses/{id}/materials` with bundle detection |
| `lib/widgets/instructor/course_management/students_tab.dart` | Mock student roster | Widget | Wire to `GET /sections/{sectionId}/students` |
| `lib/widgets/instructor/course_management/assignments_tab.dart` | Placeholder/mock assignment list | Widget | Show "coming soon" placeholder per Q1 clarification |
| `lib/screens/instructor/search/instructor_search_screen.dart` | `_mockData` list variable | Lines 33, 179 | Out of Phase 5 scope — defer to later phase |
| `lib/screens/instructor/notifications/instructor_notifications_screen.dart` | `_loadMockData()` | Lines 38, 41, 245 | Out of Phase 5 scope — defer to later phase |

### Decision
- **Scope boundary**: Only modify files directly in Phase 5 scope (courses listing, materials upload, course management). Search and notifications screens are out of scope.
- **Mock removal strategy**: Replace each mock data source with a BLoC-driven API call. Preserve the UI layout around the data — show empty states when API returns empty lists.

---

## Research Task 2: MaterialService Capabilities Audit

### Current State (`lib/services/api/material_service.dart`)

**Existing methods:**
- `getMaterials(courseId)` — `GET /courses/{courseId}/materials`
- `recordView(materialId)` — `POST /materials/{materialId}/view`

**Missing methods needed for Phase 5:**
- `uploadDocument(courseId, file, weekNumber, title, isPublished)` — `POST /courses/{courseId}/materials/document` (FormData, field name: `document`)
- `uploadVideo(courseId, file, weekNumber, title, isPublished, onSendProgress)` — `POST /courses/{courseId}/materials/video` (FormData, field name: `video`)
- `uploadTextLink(courseId, title, url, weekNumber, type, isPublished)` — `POST /courses/{courseId}/materials` (JSON)
- `updateMaterial(materialId, updates)` — `PUT /courses/{courseId}/materials/{materialId}` (JSON)
- `deleteMaterial(materialId)` — `DELETE /courses/{courseId}/materials/{materialId}`
- `toggleVisibility(materialId, isPublished)` — `PATCH /courses/{courseId}/materials/{materialId}/visibility`
- `getCourseStructure(courseId)` — `GET /courses/{courseId}/structure`
- `createStructureItem(courseId, title, weekNumber)` — `POST /courses/{courseId}/structure`
- `updateStructureItem(itemId, updates)` — `PUT /courses/{courseId}/structure/{itemId}`
- `deleteStructureItem(itemId)` — `DELETE /courses/{courseId}/structure/{itemId}`
- `reorderStructureItems(courseId, itemIds)` — `PATCH /courses/{courseId}/structure/reorder`

### Decision
- All missing methods will be added to `MaterialService` and `CourseService`.
- Video uploads MUST use `Dio.post` with `onSendProgress` callback for real-time progress.
- Document uploads MUST use `Dio.FormData` with field name `document` (not `file`).
- Video uploads MUST use `Dio.FormData` with field name `video` (not `file`).

---

## Research Task 3: CourseService Teaching Courses Endpoint

### Current State (`lib/services/api/course_service.dart`)

**Existing methods:**
- `getAll()` — `GET /courses` (public, paginated)
- `getById(id)` — `GET /courses/{id}`
- `getStructure(courseId)` — `GET /courses/{courseId}/structure`
- `getMaterials(courseId)` — `GET /courses/{courseId}/materials`

**Missing methods:**
- `getTeachingCourses()` — delegated to `EnrollmentService.getTeachingCourses()` (already exists in `enrollment_service.dart`)
- `getSectionStudents(sectionId)` — delegated to `EnrollmentService.getSectionStudents(sectionId)` (already exists)
- Structure CRUD operations — need to be added

### Decision
- `getTeachingCourses()` is already in `EnrollmentService` — reuse it, don't duplicate.
- Course structure CRUD will be added to `CourseService` since structure is a course-level concern.
- `getSectionStudents(sectionId)` is already in `EnrollmentService` — reuse it.

---

## Research Task 4: Bundle Detection Algorithm

### Website Frontend Implementation
The website's `groupMaterialsIntoBundles()` function:
1. Groups materials by `weekNumber`
2. Within each week, strips known suffixes from titles: `" - Video"`, `" - Slides"`, `" - Notes"`, `" - {originalFilename}"`
3. Materials with identical remaining base title form a bundle
4. The first material with type `video` becomes the bundle's primary video
5. Remaining materials become companion documents

### Clarification Q2 Answer
- Use exact prefix match by stripping known suffixes: `" - Video"`, `" - Slides"`, `" - Notes"`, `" - {filename}"`
- Materials with identical remaining base titles form a bundle
- Instructors can also manually group materials during upload (alternative to auto-detection)

### Decision
- Port the website's `groupMaterialsIntoBundles()` logic to Dart as a pure function in `lib/utils/bundle_detector.dart`.
- The function takes `List<CourseMaterialModel>` and returns `List<MaterialBundleModel>`.
- Manual grouping: during upload flow, after selecting files, instructor can assign them to a named group that becomes a bundle.

---

## Research Task 5: File Upload FormData Patterns

### Backend API Endpoints (from COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md)

| Upload Type | Endpoint | Method | FormData Field | Content-Type |
|---|---|---|---|---|
| Document | `POST /courses/{courseId}/materials/document` | `POST` | `document` (file) | `multipart/form-data` |
| Video | `POST /courses/{courseId}/materials/video` | `POST` | `video` (file) | `multipart/form-data` |
| Text/Link | `POST /courses/{courseId}/materials` | `POST` | JSON body | `application/json` |

### Constitution Principle X Rules
- MUST use `Dio.FormData` with `MultipartFile.fromFile()`
- MUST NOT manually set `Content-Type` (Dio auto-generates boundary)
- MUST track via `onSendProgress` for video uploads
- File validation MUST happen client-side before upload

### Decision
- Document uploads: `FormData.fromMap({'document': await MultipartFile.fromFile(file.path), 'title': title, 'weekNumber': weekNumber})`
- Video uploads: `FormData.fromMap({'video': await MultipartFile.fromFile(file.path), 'title': title, 'weekNumber': weekNumber})` with `onSendProgress` callback
- Text/Link: JSON body via `CoreApiClient.post`

---

## Research Task 6: YouTube Upload Flow with Progress

### Backend Behavior
- `POST /courses/{courseId}/materials/video` uploads the video file to YouTube via the backend
- Backend handles YouTube OAuth (configured by IT Admin)
- If OAuth fails → backend returns error → Flutter shows "YouTube not authorized. Contact admin."
- Progress tracking via `onSendProgress` during file upload to backend
- After upload completes, backend returns material object with YouTube embed URL

### Error Handling
- YouTube OAuth error: "YouTube not authorized. Please contact admin to set up YouTube integration."
- Network drop mid-upload: show error, allow retry from beginning
- File too large: client-side validation before upload (no server limit specified for videos — backend handles)

### Decision
- Use `Dio.post` with `onSendProgress: (sent, total) => emit progress event`
- Progress UI updates every 500ms (throttled from raw callback frequency)
- On error: emit error state with retry capability
- After success: refresh materials list from API (do NOT optimistically append per Constitution Principle X)

---

## Research Task 7: Existing BLoC Architecture

### Current `CoursesBloc` State
- Exists at `lib/bloc/courses/courses_bloc.dart`
- Currently handles general course listing (public courses)
- Does NOT handle instructor-specific teaching courses

### Decision
- Extend `CoursesBloc` with instructor-specific events:
  - `LoadTeachingCourses` → calls `EnrollmentService.getTeachingCourses()`
  - `LoadCourseMaterials` → calls `MaterialService.getMaterials()`
  - `UploadMaterial` → calls appropriate upload method
  - `UpdateMaterial` → calls `MaterialService.updateMaterial()`
  - `DeleteMaterial` → calls `MaterialService.deleteMaterial()`
  - `ToggleMaterialVisibility` → calls `MaterialService.toggleVisibility()`
  - `LoadCourseStructure` → calls `CourseService.getStructure()`
  - `CreateStructureItem`, `UpdateStructureItem`, `DeleteStructureItem`, `ReorderStructureItems`

- Alternatively, create a new `InstructorCoursesBloc` to keep concerns separate from the public `CoursesBloc`.
- **Decision**: Create new `InstructorCoursesBloc` under `lib/bloc/instructor/` to avoid polluting the public courses BLoC with instructor logic. This follows V. Testable Architecture.

---

## Research Task 8: UI Preservation Strategy (Constitution Principle XII)

### Constraint: ≥85% Visual Similarity

| Screen | Current Layout | Change Strategy |
|--------|---------------|-----------------|
| `instructor_courses_screen.dart` | Grid/list of course cards with mock data | Replace mock data source with BLoC stream; keep card widgets, grid layout, colors, spacing identical; show empty state when no courses |
| `upload_materials_screen.dart` | Upload form with static material types | Wire up real upload flows; keep form structure, colors, button placements; add progress bars where they didn't exist |
| `course_management_screen.dart` | Tab-based layout with mock tab content | Wire live data to each tab; keep TabBar, tab structure, colors; show "coming soon" for Assignments/Grading tabs |
| `overview_tab.dart` | Stats cards with fake numbers | Wire live stats from API; keep card layout, colors, icon usage |
| `materials_tab.dart` | Static material list | Wire live materials with bundle detection; keep list/card layout |
| `students_tab.dart` | Mock student roster | Wire live student list; keep table/card layout |

### Decision
- No widget tree reorganizations.
- No color/theme changes.
- No layout type changes (Row→Column, GridView→ListView, etc.).
- Only change: data source (mock → BLoC → API) and add empty/placeholder states where mock data was removed.

---

## Summary of Decisions

| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| Create `InstructorCoursesBloc` instead of extending `CoursesBloc` | Separation of concerns, testability, avoids bloating public BLoC | Extend existing BLoC (rejected: would mix student/public/instructor concerns) |
| Add missing methods to `MaterialService` and `CourseService` | Single responsibility, services extend existing patterns | Create new `MaterialUploadService` (rejected: MaterialService already handles materials) |
| Bundle detection as pure function in `lib/utils/bundle_detector.dart` | Reusable, testable, no side effects | Inline detection in widget (rejected: hard to test, violates separation) |
| Client-side file validation before upload | Avoids unnecessary network traffic per Constitution X | Server-side only validation (rejected: wasteful of bandwidth) |
| "Coming soon" placeholders for Assignments/Grading tabs | Preserves UI structure for Phase 6/7, prevents jarring UX changes | Omit tabs entirely (rejected: violates Q1 clarification answer) |
| Parallel API calls for bundle edit/delete with partial-failure tracking | Performance + correctness | Sequential calls (rejected: too slow for bundles with 5+ materials) |
| Progress updates throttled to 500ms | Smooth UI without excessive rebuilds | Raw callback frequency (rejected: causes janky UI) |
