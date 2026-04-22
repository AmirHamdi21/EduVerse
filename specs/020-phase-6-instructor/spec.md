# Feature Specification: Phase 6 — Instructor Assignments CRUD & Grading

**Feature Branch**: `020-phase-6-instructor`
**Created**: 2026-04-12
**Status**: Draft
**Input**: User description: "Phase 6: Instructor — Assignments CRUD & Grading"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Create and Manage Assignments (Priority: P1)

An instructor selects a course they teach, creates a new assignment with all required fields (title, description, instructions, due date, max score, weight, submission type, file size limits, allowed file types, late penalty, status), uploads instruction files to Google Drive, and publishes the assignment. The instructor can later edit the assignment or transition its status through the workflow (draft → published → closed → archived).

**Why this priority**: Without the ability to create assignments, the rest of the workflow (submission viewing, grading) has no data to operate on. This is the foundational capability for the entire assignment management lifecycle.

**Independent Test**: Can be fully tested by creating an assignment with all fields, verifying it appears in the assignment list, and confirming the backend persists the data correctly — delivers immediate value as instructors can begin creating coursework.

**Acceptance Scenarios**:

1. **Given** the instructor is on the Assignments screen and has selected a teaching course, **When** they tap "Create Assignment", fill in required fields (title, due date, max score), optionally fill other fields, and save, **Then** the assignment is created and appears in the assignment list with its initial status.
2. **Given** an assignment exists in draft status, **When** the instructor edits it and changes status to "published", **Then** the status updates and the assignment becomes visible to enrolled students.
3. **Given** an assignment is in published status, **When** the instructor transitions it to "closed", **Then** the assignment no longer accepts new submissions and the UI reflects the closed state.
4. **Given** an assignment has instruction files, **When** the instructor uploads additional instruction files, **Then** files are uploaded and appear in the assignment's instruction files list with Open and Download actions.

---

### User Story 2 — View and Filter Submissions (Priority: P2)

An instructor taps an assignment from the list, which navigates to a dedicated full-screen submissions list page. The list is paginated (20 submissions per page with a "Load More" button for additional pages). The instructor can filter by submission status (all, graded, ungraded, late), sort by student name, submission date, or score, and search by student name or email. Each submission entry shows the student's name, submission date, status (submitted/graded/returned/resubmit), a late indicator if applicable, and score if graded.

**Why this priority**: Instructors need to efficiently navigate potentially large submission sets to find specific students or identify ungraded work. Without filtering, grading becomes impractical for courses with many students.

**Independent Test**: Can be fully tested by loading submissions for an assignment, applying filters, and verifying the displayed list matches the filter criteria — delivers immediate value as instructors can organize their grading workload.

**Acceptance Scenarios**:

1. **Given** an assignment has multiple student submissions, **When** the instructor opens the submissions list, **Then** all submissions are displayed with student name, submission date, status, and score (if graded).
2. **Given** the submissions list is displayed, **When** the instructor applies a "Ungraded" filter, **Then** only submissions with status other than "graded" are shown.
3. **Given** the submissions list is displayed, **When** the instructor enters a student name in the search field, **Then** the list filters to show only submissions matching that student's name or email.
4. **Given** the submissions list is displayed, **When** the instructor taps a column header (e.g., "Date"), **Then** the list sorts by that column in ascending or descending order.

---

### User Story 3 — Grade Individual Submissions (Priority: P3)

An instructor taps a submission from the submissions list, which navigates to a dedicated full-screen grading panel. The instructor reviews the submitted content (text, link, or file), enters a score (0 to maxScore), optionally writes feedback, and saves the grade. The system automatically calculates and displays any late penalty if applicable. The instructor can later revisit and modify the grade.

**Why this priority**: Grading is the core academic workflow that completes the assignment lifecycle. While it depends on Stories 1 and 2, it delivers independent value — an instructor could theoretically grade submissions from assignments created outside the mobile app.

**Independent Test**: Can be fully tested by opening a submission, entering a score and feedback, saving, and verifying the grade is persisted and reflected in the submissions list — delivers immediate value as students receive their grades.

**Acceptance Scenarios**:

1. **Given** a student has submitted text content, **When** the instructor opens the submission for grading, **Then** the submission text is displayed in a readable format alongside the student's info and submission timestamp.
2. **Given** a student has submitted a file, **When** the instructor opens the submission for grading, **Then** the file can be previewed or downloaded for review.
3. **Given** a submission is open for grading, **When** the instructor enters a score (0 to maxScore, step 0.5) and taps "Save Grade", **Then** the grade is persisted, the submission status updates to "graded", and the updated grade is reflected in the submissions list.
4. **Given** a student submitted late, **When** the instructor views the grading panel, **Then** the late penalty percentage and final score calculation are displayed (e.g., "Original Score: 90, Late Penalty: 10%, Final Score: 81").
5. **Given** a submission has already been graded, **When** the instructor opens it again, **Then** the existing grade and feedback are displayed and can be modified.
6. **Given** a grade has been saved successfully, **When** the grading completes, **Then** the screen navigates back to the submissions list and the updated grade is visible in the submission entry.

---

### User Story 4 — Delete Assignments (Priority: P4)

An instructor deletes an assignment they no longer need. The system requires explicit confirmation before deletion to prevent accidental data loss.

**Why this priority**: Cleanup and lifecycle management. Lower priority because deletion is destructive and infrequent, but necessary for course maintenance.

**Independent Test**: Can be fully tested by deleting an assignment and confirming it no longer appears in the list — delivers immediate value by keeping courses organized.

**Acceptance Scenarios**:

1. **Given** an assignment exists, **When** the instructor taps "Delete", **Then** a confirmation dialog appears showing the assignment title and warning about permanent deletion.
2. **Given** the confirmation dialog is displayed, **When** the instructor confirms, **Then** the assignment is permanently removed and no longer appears in the list.
3. **Given** the confirmation dialog is displayed, **When** the instructor cancels, **Then** the dialog closes and the assignment remains unchanged.

---

### Edge Cases

- **No teaching courses**: If the instructor has no teaching courses assigned, the Assignments screen shows an empty state with guidance ("You are not assigned to teach any courses").
- **No assignments for course**: If a course has no assignments, an empty state is shown with a prominent "Create First Assignment" call-to-action.
- **No submissions yet**: If an assignment has zero submissions, the submissions list shows an empty state ("No submissions yet").
- **Network failure during grade save**: If the grading API call fails, the UI displays an error message and retains the entered score/feedback so the instructor can retry without re-entering data.
- **Instruction file upload failure**: If an instruction file upload fails (network error, auth failure, quota exceeded), the UI displays an error message with a "Retry" button. No automatic retry is attempted. Partial upload state is cleaned up on failure.
- **Large submission lists (pagination)**: For assignments with more than 20 submissions, only the first page (20 items) loads initially. The instructor taps "Load More" to fetch subsequent pages. If a page load fails, a retry option is shown without clearing previously loaded pages.
- **Max score changed after submissions exist**: If the instructor changes maxScore after some submissions are graded, existing grades are NOT automatically recalculated — the UI shows a warning.
- **Large submission files**: File previews for very large files (>50MB) may fail gracefully with a download-only fallback.
- **Concurrent grading**: If two instructors grade the same submission simultaneously, the last save wins — the UI shows the most recently saved grade after refresh.
- **Assignment status blocks grading**: If an assignment is in "draft" status, submissions cannot exist (students cannot see draft assignments). If status is "archived", submissions are read-only (no new grades can be saved).

---

## Clarifications

### Session 2026-04-12

- Q: How should the submissions list and grading panel be presented on mobile? → A: Dedicated full-screen pages with push/pop navigation — tap assignment → push submissions list screen → tap submission → push grading screen.
- Q: How should large submission lists (>100) be handled? → A: Paginated loading with "Load More" button, 20 submissions per page.
- Q: What does "any" submission type mean for the student? → A: Student chooses exactly one method (text, file, or link) per submission attempt. **Note: backend enum value is `multiple`, NOT `any` — "any" is user-facing terminology.**
- Q: What happens when an instruction file upload to Google Drive fails? → A: Show error immediately with manual "Retry" button — no auto-retry.
- Q: Which submission statuses count as "ungraded" for the filter? → A: `submitted` and `resubmit` only — `returned` is excluded (already graded).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a list of the instructor's teaching courses, allowing the instructor to select which course's assignments to manage.
- **FR-002**: System MUST display all assignments for the selected course in a card-based layout showing title, status badge, due date, submission type, and max score.
- **FR-003**: System MUST provide a "Create Assignment" action that opens a form with all required fields: title (required), description, instructions (Markdown-supported), due date (required), max score (required, default 100), weight (default 10), submission type (text/file/link/multiple, required, default file; "multiple" means the student may choose exactly one submission method per attempt), max file size (MB), allowed file types (comma-separated), late penalty (0-100), and status (draft/published/closed/archived, required, default draft).
- **FR-004**: System MUST persist created assignments so they appear immediately in the assignment list and are visible to enrolled students when published.
- **FR-005**: System MUST allow editing existing assignments, pre-populating the form with all current field values.
- **FR-006**: System MUST support uploading instruction files that are stored in the cloud file system, and display uploaded instruction files with Open and Download actions.
- **FR-007**: System MUST enforce assignment status transitions following the one-way workflow: draft → published → closed → archived. The UI MUST only offer valid next-status transitions.
- **FR-008**: System MUST update assignment status when the instructor selects a status transition action.
- **FR-009**: System MUST delete assignments only after explicit user confirmation through a dialog showing the assignment title.
- **FR-010**: System MUST fetch all student submissions for an assignment and display them in a filterable, sortable list.
- **FR-011**: System MUST filter submissions by status (all, graded, ungraded, late) where "ungraded" includes submissions with status `submitted` and `resubmit` only — excluding `returned` (already graded) and `graded`. The filter MUST also support text search by student name or email.
- **FR-012**: System MUST sort submissions by student name, submission date, score, or status, with toggle between ascending and descending order.
- **FR-013**: System MUST display a grading panel for individual submissions showing: student info (name, email), submission content (text rendered, link clickable, file previewed or download link), score input (0 to maxScore, step 0.5), late penalty auto-calculation display, feedback textarea, and save action.
- **FR-014**: System MUST persist grades for submissions, updating the submission status to "graded" and storing the score and feedback.
- **FR-015**: System MUST calculate and display late penalties based on the assignment's late penalty percentage and the number of days late.
- **FR-016**: System MUST handle grading errors by displaying a user-friendly error message and retaining the entered score/feedback for retry.
- **FR-017**: System MUST show grading statistics (total submissions, pending count, graded count, late count, average grade) for the selected assignment.
- **FR-018**: System MUST NOT allow students, TAs, admins, or IT admins to access the instructor assignment CRUD and grading UI — access MUST be gated to users with the `instructor` role only.

### Key Entities

- **Assignment**: Represents a coursework task assigned by an instructor to a course. Key attributes: title, description, instructions (Markdown), due date, max score, weight, submission type (text/file/link/multiple), max file size, allowed file types, late penalty percent, status (draft/published/closed/archived), instruction files (Google Drive references). Belongs to a Course. Has many Submissions.
- **Assignment Submission**: Represents a student's work submitted for an assignment. Key attributes: student info (name, email), submission text, submission link, submission file (Google Drive reference), submission status (submitted/graded/returned/resubmit), score, feedback, graded-by info, graded timestamp, late flag, submission timestamp. Belongs to an Assignment and a Student.
- **Instruction File**: Represents a file uploaded by the instructor as part of assignment instructions. Key attributes: Drive file ID, file name, web view link, iframe preview URL, download URL, upload timestamp. Belongs to an Assignment.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Instructors can create a complete assignment with all fields filled in under 2 minutes from form open to successful save confirmation.
- **SC-002**: Instructors can grade a single submission (review content, enter score, add feedback, save) in under 60 seconds for text/link submissions and under 90 seconds for file submissions requiring preview loading.
- **SC-003**: Assignment list loads and renders within 2 seconds of course selection for courses with up to 50 assignments.
- **SC-004**: The first page of submissions (20 items) loads and renders within 2 seconds of assignment selection. Additional pages load within 1 second each when the instructor taps "Load More".
- **SC-005**: All modified and new screens maintain ≥85% visual similarity to the pre-integration UI, with no wholesale redesigns or layout reorganizations.
- **SC-006**: Zero static/mock data remains in any files modified or created during this phase — all data is fetched from the live backend API.
- **SC-007**: 100% of assignment CRUD operations (create, read, update, delete, status change) succeed on the first attempt under normal network conditions.
- **SC-008**: 100% of grade save operations persist successfully and the updated grade is immediately reflected in the submissions list without requiring a full screen refresh.
- **SC-009**: Late penalty calculations display correctly for 100% of late submissions, matching the formula: Final Score = Original Score × (1 - (latePenaltyPercent × daysLate / 100)).

---

## Assumptions

- The instructor user has a valid JWT token and is authenticated before accessing the Assignments screen.
- The `AssignmentService` from Phase 1 is already implemented and provides methods: `getAll()`, `getById()`, `create()`, `update()`, `delete()`, `updateStatus()`, `getSubmissions()`, `gradeSubmission()`, `uploadInstructionFile()`.
- The backend's `POST /assignments/{id}/instructions/upload` endpoint accepts `multipart/form-data` with a field named `file` and returns an `InstructionFile` object with `driveId`, `fileName`, `webViewLink`, `iframeUrl`, and `downloadUrl`.
- Google Drive file preview URLs are accessible to students without additional authentication (the Drive files are shared appropriately by the backend).
- The existing `GradingCenterCubit`, `GradingCenterState`, and grading-related widgets (`GradeDialog`, `SubmissionCard`, etc.) will be refactored/reused rather than replaced entirely — their structure will be adapted to use live API data instead of mock data.
- The existing `CreateAssignment` widget will be adapted to connect to the live API rather than being rebuilt from scratch — form fields and validation logic will be preserved.
- Responsive design adjustments follow the project's existing responsive design patterns (mobile-first, adaptive layouts for tablet/desktop).
- File size and type validation happens client-side before upload to minimize unnecessary network requests.
- The `instructor` role is the only role with access to this feature — role checking happens at the widget level to prevent non-instructors from seeing assignment management actions.
- Course selection for assignment creation uses the instructor's teaching courses from `GET /enrollments/teaching` — no courses outside this list can have assignments created by this instructor.
- Assignment deletion is permanent (not soft-delete) from the student perspective — once deleted, students can no longer see or submit to the assignment.
- The existing app theme, color palette, typography, and spacing system will be used without modification.
