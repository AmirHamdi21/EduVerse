# Feature Specification: Instructor — Courses & Materials Management

**Feature Branch**: `019-instructor-courses-materials`
**Created**: April 12, 2026
**Status**: Draft
**Input**: User description: "Phase 5: Instructor — Courses & Materials Management. Integrate instructor's course management and full materials upload system with live API data, preserving ≥85% UI similarity."

## Clarifications

### Session 2026-04-12

- **Q1**: Should Assignments and Grading sub-tabs be present in Phase 5 or omitted? → **A**: Include all 5 sub-tabs (Overview, Lectures, Assignments, Grading, Students); Assignments and Grading show placeholder/empty states with "coming soon" messaging.
- **Q2**: What bundle detection algorithm should be used? → **A**: Exact prefix match by stripping known suffixes (" - Video", " - Slides", " - Notes", " - {filename}"); materials with identical remaining base form a bundle. Additionally, instructors can manually group materials during upload.
- **Q3**: What does "engagement metrics" mean in the course overview? → **A**: Two metrics: (1) aggregate material view/download counts across the course, and (2) assignment submission rate (submitted vs. enrolled students).
- **Q4**: How should bundle-level edit/delete operations work? → **A**: Parallel individual API calls per material (one `PUT` or `DELETE` each); track successes vs failures; show partial-success/partial-error UI feedback.
- **Q5**: Should Phase 5 fetch assignments and labs for upcoming deadlines? → **A**: Yes — read-only fetch via `GET /assignments?courseId={id}` and `GET /labs?courseId={id}` to populate deadline cards in the course overview.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Teaching Courses List (Priority: P1)

An instructor opens the app and navigates to their Courses screen. They see a list of all course sections they are assigned to teach, loaded from the live backend API. Each course card displays the course code, name, semester, enrolled student count, capacity, average grade percentage, and attendance rate. The instructor can tap any course to drill into its detail view. If the instructor has no teaching assignments, they see an empty state message instead of static placeholder data.

**Why this priority**: This is the entry point for all instructor workflows. Without live course data, instructors cannot navigate to manage materials, view students, or perform any course-related tasks.

**Independent Test**: Can be fully tested by logging in as an instructor with teaching assignments and verifying the course list populates from the API with accurate enrollment counts and course metadata. Delivers immediate value by showing real course assignments.

**Acceptance Scenarios**:

1. **Given** an instructor is authenticated and has teaching assignments, **When** they open the Courses screen, **Then** they see their course sections loaded from the live API with course code, name, semester, enrolled count, capacity, average grade, and attendance rate.
2. **Given** an instructor has no teaching assignments, **When** they open the Courses screen, **Then** they see an empty state message ("No courses assigned yet") instead of mock data.
3. **Given** the API request fails or times out, **When** the instructor opens the Courses screen, **Then** they see an error state with a retry option.

---

### User Story 2 — Upload Course Materials (All 4 Types) (Priority: P1)

An instructor selects a course, navigates to the materials upload screen, and uploads course materials. The system supports four distinct upload types: (1) Text/Link — a metadata-only material entry with a title and URL, (2) File — uploading a document (PDF, DOCX, PPTX, etc.) to Google Drive, (3) Video — uploading a video file to YouTube with a real-time progress bar, and (4) Bundle — uploading a video plus multiple companion documents as a cohesive group. For video and bundle uploads, the instructor sees a progress indicator. After upload completes, the materials appear in the materials library view.

**Why this priority**: This is the core instructor capability — without the ability to upload lecture videos, documents, and bundles, the course lacks content for students to consume. Video upload to YouTube and bundle upload are the most complex but most critical upload types.

**Independent Test**: Can be fully tested by uploading each of the four material types independently and verifying they appear in the materials library afterward. Each upload type delivers standalone value (e.g., uploading a single PDF document is useful on its own).

**Acceptance Scenarios**:

1. **Given** an instructor is on the materials upload screen for a specific course, **When** they upload a text/link material, **Then** the material is created with title, URL, and metadata, and appears in the materials library.
2. **Given** an instructor is on the materials upload screen, **When** they upload a document file (PDF, DOCX, etc.), **Then** the file is uploaded to Google Drive, the material is created, and it appears in the materials library.
3. **Given** an instructor is on the materials upload screen, **When** they upload a video file, **Then** they see a real-time progress bar during upload, the video is uploaded to YouTube, and the material appears in the materials library with a playable video thumbnail.
4. **Given** an instructor is on the materials upload screen, **When** they upload a bundle (video + multiple documents), **Then** they see step-by-step progress, all files are uploaded, and the materials appear in the materials library (bundle grouping is applied by the materials library's auto-detection in User Story 3). The instructor can also choose to manually group materials during the upload flow instead of relying on auto-detection.

---

### User Story 3 — Manage Materials Library (View, Toggle Visibility, Edit, Delete) (Priority: P2)

An instructor views their course's materials library, which is organized by week with material bundles detected automatically. They can toggle individual materials' visibility (published/unpublished), edit material titles, and delete materials. For bundles, they can toggle visibility for all items in the bundle, edit titles of all items, or delete the entire bundle. The instructor sees YouTube thumbnail previews for video materials and type badges for all material types.

**Why this priority**: After uploading materials, instructors need to organize, curate, and control what students see. Visibility toggling is essential for drafting materials before publishing them to students.

**Independent Test**: Can be fully tested by viewing an existing materials library, toggling a material's visibility, editing its title, and deleting it. Each action can be verified independently.

**Acceptance Scenarios**:

1. **Given** a course has materials, **When** an instructor views the materials library, **Then** materials are grouped by week number with bundles detected automatically by stripping known suffixes (" - Video", " - Slides", " - Notes", " - {filename}") from material titles and grouping materials with identical remaining base titles.
2. **Given** a material is published, **When** the instructor toggles its visibility off, **Then** the material becomes hidden from students but remains visible to the instructor with an "unpublished" indicator.
3. **Given** a material exists, **When** the instructor edits its title, **Then** the title updates and the change persists in the backend.
4. **Given** a material exists, **When** the instructor deletes it with confirmation, **Then** the material is removed from the library and the backend.
5. **Given** a bundle of materials exists, **When** the instructor toggles bundle visibility, **Then** all materials in the bundle are toggled simultaneously.

---

### User Story 4 — Manage Course Structure (Week-Based Accordion) (Priority: P2)

An instructor views and manages their course structure, which organizes materials into a week-based hierarchy. They can create new structure items (e.g., "Week 1: Introduction", "Week 2: Foundations"), edit existing structure item titles and order, reorder structure items via drag or step controls, and delete structure items. When structure items are created or edited, materials can be associated with them by week number.

**Why this priority**: Course structure provides the organizational backbone for materials. Without it, materials appear as a flat list without temporal context, making navigation harder for students.

**Independent Test**: Can be fully tested by creating a new structure item, editing its title, reordering it, and deleting it. Each CRUD operation can be verified independently.

**Acceptance Scenarios**:

1. **Given** a course has no structure items, **When** the instructor creates a new structure item with a title and week number, **Then** the item appears in the course structure list.
2. **Given** structure items exist, **When** the instructor edits a structure item's title, **Then** the title updates and reflects in the backend.
3. **Given** multiple structure items exist, **When** the instructor reorders them, **Then** the order updates and persists.
4. **Given** a structure item exists with no materials associated, **When** the instructor deletes it with confirmation, **Then** the item is removed from the course structure.

---

### User Story 5 — View Course Detail with Live Data (Priority: P3)

An instructor drills into a specific course to see a detailed overview with live data. The course detail screen has 5 sub-tabs: Overview, Lectures, Assignments, Grading, and Students. The Overview tab shows: course details (code, credits, level, section, semester, status), upcoming deadlines (assignments and labs due soon, fetched read-only from the live API), student count from section enrollment, average grade percentage, engagement metrics (aggregate material view/download counts and assignment submission rate — submitted vs. enrolled students), and section schedules (day, time, location, building, schedule type). The Lectures sub-tab shows materials organized by week. The Assignments and Grading sub-tabs display placeholder states with "coming soon" messaging to preserve UI structure for future phases. The Students sub-tab shows enrolled students.

**Why this priority**: Provides a comprehensive course snapshot and serves as the navigation hub for other course management screens. Lower priority than upload/library because instructors can still function by going directly to the materials upload screen.

**Independent Test**: Can be fully tested by navigating to a course detail screen and verifying that all displayed data (student count, schedules, upcoming deadlines, engagement metrics) comes from the live API rather than static data.

**Acceptance Scenarios**:

1. **Given** an instructor selects a course from their teaching list, **When** the course detail screen loads, **Then** course metadata, section info, and semester data are loaded from the live API.
2. **Given** a course section has schedules, **When** the instructor views the course detail, **Then** they see the schedule(s) with day of week, start/end time, room, building, and schedule type badge.
3. **Given** a course has enrolled students, **When** the instructor views the Students sub-tab, **Then** they see the list of students enrolled in that course's section(s) from the live API.
4. **Given** a course has published assignments and/or labs with upcoming due dates, **When** the instructor views the Overview tab, **Then** they see upcoming deadline cards populated from the live assignments and labs APIs.
5. **Given** a course has materials and assignments, **When** the instructor views the Overview tab, **Then** they see aggregate material view/download counts and the assignment submission rate (submitted count vs. enrolled student count).
6. **Given** the Assignments or Grading sub-tabs are not in Phase 5 scope, **When** the instructor navigates to those sub-tabs, **Then** they see a placeholder state with "coming soon" messaging instead of mock data.

---

### User Story 6 — View Section Students (Priority: P3)

An instructor navigates to the Students sub-tab within a course detail to see all students enrolled in that course's section(s). Each student entry shows their name, email, enrollment status, current grade, and attendance rate. This allows the instructor to see who is enrolled and track individual student performance.

**Why this priority**: Useful for instructor awareness but not critical for the primary workflow of uploading and managing materials.

**Independent Test**: Can be fully tested by viewing the Students tab for a course section with enrolled students and verifying the student list, names, and grades come from the live API.

**Acceptance Scenarios**:

1. **Given** a course section has enrolled students, **When** the instructor views the Students tab, **Then** they see a list of students with name, email, enrollment status, grade, and attendance rate.
2. **Given** a course section has no enrolled students, **When** the instructor views the Students tab, **Then** they see an empty state message ("No students enrolled yet").

---

### Edge Cases

- **Video upload fails mid-way** (network drop, YouTube API error): The system must show an error message, allow retry from the beginning, and clean up any partially uploaded state.
- **File exceeds size limit** (documents max 50MB, images max 10MB): The system must validate file size client-side before upload begins and show a clear error message if the file is too large.
- **Deleting a structure item with associated materials**: The system must warn the instructor that materials will become ungrouped (not deleted) and require explicit confirmation.
- **Concurrent uploads** (instructor uploads multiple files simultaneously): Each upload must be tracked independently with its own progress indicator and success/error state.
- **Teaching courses API returns empty list**: Show an empty state with a helpful message, not mock data or a loading spinner indefinitely.
- **YouTube OAuth token expiration during upload**: Show an actionable error message ("YouTube authentication expired — please try again") and do not crash.
- **Partial bundle edit/delete failure** (some parallel API calls succeed, others fail): Track which materials succeeded vs. failed; show a summary UI ("3 of 5 materials deleted successfully — 2 failed, retry?"); allow retry on failed items only; leave successfully processed materials in their new state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch the instructor's teaching courses from the live API (`GET /enrollments/teaching`) and display them with course code, name, semester, section info, enrolled count, capacity, average grade, and attendance rate.
- **FR-002**: System MUST display an empty state (not mock data) when the instructor has no teaching assignments.
- **FR-003**: System MUST support four distinct material upload types: Text/Link (metadata only), File (document to Google Drive), Video (video to YouTube), and Bundle (video + multiple documents uploaded sequentially).
- **FR-004**: System MUST show real-time upload progress for video and bundle uploads, with step-by-step status labels (e.g., "Uploading video...", "Uploading document 1 of 3...").
- **FR-005**: System MUST validate file sizes client-side before upload begins (documents max 50MB, images max 10MB, videos per backend limits) and display a clear error if limits are exceeded.
- **FR-006**: System MUST associate uploaded materials with a specific course and week number (structure item) when applicable.
- **FR-007**: System MUST display the materials library for a course, grouping materials by week number and auto-detecting bundles by stripping known suffixes (" - Video", " - Slides", " - Notes", " - {filename}") from material titles and grouping materials with identical remaining base titles.
- **FR-008**: System MUST allow instructors to toggle material visibility (published/unpublished) for individual materials and all materials in a bundle simultaneously.
- **FR-009**: System MUST allow instructors to edit material titles and delete materials, for both individual items and entire bundles; bundle-level operations execute parallel individual API calls per material (one `PUT` or `DELETE` each), track successes vs failures, and show partial-success/partial-error UI feedback with retry option for failed items.
- **FR-010**: System MUST display YouTube thumbnail previews for video materials using the standard YouTube thumbnail URL pattern.
- **FR-011**: System MUST support course structure CRUD: create, edit, reorder, and delete week-based structure items.
- **FR-012**: System MUST prevent deletion of structure items that have associated materials without warning the instructor that materials will become ungrouped.
- **FR-013**: System MUST load and display section schedules (day, time, room, building, schedule type) for each teaching course.
- **FR-014**: System MUST load and display enrolled students for a course section from the live API (`GET /sections/:sectionId/students`).
- **FR-015**: System MUST display material type badges (video, document, link, slide, etc.) for all materials in the library.
- **FR-016**: System MUST handle upload failures gracefully with error messages and retry capability, without leaving orphan UI state.
- **FR-017**: System MUST auto-generate bundle names at upload time using the convention `"{Title} - Video"` for videos and `"{Title} - {fileName}"` for companion documents (this governs upload-time naming, not detection-time grouping).
- **FR-018**: System MUST only display published materials to students; instructors can see both published and unpublished materials with clear visual distinction (e.g., faded appearance, "unpublished" badge, or eye icon with strikethrough).
- **FR-019**: System MUST load course detail overview data (student count, average grade, schedules, upcoming deadlines) from live APIs, not static data. Engagement metrics MUST include: (1) aggregate material view/download counts, and (2) assignment submission rate computed as (number of enrolled students who submitted at least one assignment / total enrolled students) × 100.
- **FR-020**: System MUST display all 5 course detail sub-tabs (Overview, Lectures, Assignments, Grading, Students) with the Assignments and Grading sub-tabs showing placeholder "coming soon" states to preserve UI structure for future phases.
- **FR-021**: System MUST allow instructors to manually group materials into bundles during the upload flow as an alternative to automatic suffix-based detection.
- **FR-022**: System MUST fetch upcoming assignment and lab deadlines read-only from `GET /assignments?courseId={id}` and `GET /labs?courseId={id}` to populate deadline cards in the course overview, without performing any write operations.

### Key Entities

- **Teaching Course**: Represents a course section the instructor is assigned to teach. Contains course metadata (code, name, credits, level, department), section info (section number, capacity, location, status), semester info (name, start/end dates), and aggregated stats (enrolled count, average grade, attendance rate).
- **Course Material**: Represents a learning resource attached to a course. Can be a video (hosted on YouTube), a document (hosted on Google Drive), a link, or text. Has properties: title, type, URL/embed link, week number, published status, view count, download count.
- **Material Bundle**: A logical grouping of materials that share a common base title and week number. Auto-detected by stripping known suffixes (" - Video", " - Slides", " - Notes", " - {filename}") from material titles and grouping materials with identical remaining base titles. Can also be created manually by the instructor during upload. Contains one video material and zero or more companion document materials. Managed as a unit for visibility, editing, and deletion — bundle-level operations execute parallel individual API calls per material with partial-failure tracking.
- **Course Structure Item**: Represents a week or module within a course. Has a title (e.g., "Week 1: Introduction"), week number, sort order, and optional description. Materials are associated with structure items by week number.
- **Section Schedule**: Represents a recurring session time for a course section. Has day of week, start time, end time, room, building, and schedule type (lecture, lab, tutorial, exam).
- **Enrolled Student**: Represents a student enrolled in a course section. Has name, email, enrollment status, current grade, and attendance rate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Instructors can view their full teaching course list from the live API in under 2 seconds on a standard mobile connection.
- **SC-002**: Instructors can successfully upload a 100MB video file to YouTube with a visible progress bar that updates at least every 500ms, completing within the backend's video processing time.
- **SC-003**: Instructors can successfully upload a bundle (1 video + up to 5 documents) with step-by-step progress feedback, with all materials appearing in the library within 30 seconds of upload completion.
- **SC-004**: Materials library displays materials grouped by week with bundles correctly detected in 100% of cases where materials share a base title prefix. Base title matching normalizes whitespace (trim, collapse runs) and is case-insensitive.
- **SC-005**: Instructors can toggle material visibility, edit titles, and delete materials with changes reflected in the backend within 1 second.
- **SC-006**: Course structure CRUD operations (create, edit, reorder, delete) complete successfully and persist within 1 second per operation.
- **SC-007**: Upload failure rate is below 5% under normal network conditions, and 100% of failures show a clear error message with a retry option.
- **SC-008**: All screens maintain at least 85% visual similarity to their pre-integration state — no redesigns, color changes, or layout reorganizations beyond replacing mock data with live API data and empty states.
- **SC-009**: Section student list loads and displays within 2 seconds for courses with up to 100 enrolled students.
- **SC-010**: Zero instances of static/mock data displayed in any Phase 5 screen when the API returns valid data.

## Assumptions

- Instructors have stable internet connectivity sufficient for file uploads (video uploads may require several minutes depending on file size and connection speed).
- The backend YouTube OAuth integration is already configured by an IT Admin — if upload fails due to auth, the instructor sees an error telling them to contact the admin.
- Google Drive API is configured and accessible — file uploads rely on the backend's existing Google Drive integration.
- The existing `CourseService` and `MaterialService` from Phase 1 provide the base HTTP client layer; this phase builds on those services.
- Material bundle detection logic (`groupMaterialsIntoBundles`) is ported from the website frontend and reused from Phase 2 implementation.
- File type validation uses MIME types and extension checks consistent with the website frontend (documents: PDF, DOCX, PPTX, XLSX; images: JPG, PNG, GIF; videos: MP4, MOV, AVI).
- The app's existing navigation structure (bottom nav for student, drawer/tabs for instructor) is already in place and does not need modification.
- Instructor role permissions are enforced by the backend — the Flutter app does not need to implement server-side authorization checks beyond including the JWT token.
- Empty states should match the existing app's empty state design patterns (illustration + message + optional action button).
