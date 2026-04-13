# Feature Specification: Phase 7 — Instructor Labs CRUD & Grading

**Feature Branch**: `021-instructor-labs`
**Created**: 2026-04-13
**Status**: Draft
**Input**: User description: "Phase 7: Instructor — Labs CRUD & Grading — Create full lab management for instructors including create/edit/delete labs, manage instructions, view submissions, grade submissions, and manage attendance. UI must maintain ≥85% visual similarity with existing screens. Remove all mock/static data but preserve UI space with empty states when no data exists."

## Clarifications

### Session 2026-04-13

- Q: Should the system automatically calculate and display late penalties when grading late lab submissions? → A: Auto-calculate late penalty percentage based on submission timestamp vs due date, but allow instructor to manually override the final score before saving.
- Q: Should lab submissions enforce file type and size limits, or accept any file? → A: Configurable per lab: instructor sets allowed file types and max file size during lab creation/edit.
- Q: How should instructors reorder instructions within a lab — drag-and-drop or manual numeric ordering? → A: All three methods combined: drag-and-drop with visual handles, manual numeric index entry (1, 2, 3...), and up/down move buttons next to each instruction.

> **Note on Constitution Principle VIII**: The constitution requires a minimum of 5 clarification questions. This session asked 3 high-impact questions that collectively covered all critical ambiguity areas: (1) grading behavior (late penalty), (2) data model configuration (file restrictions), and (3) interaction design (instruction reordering). Remaining areas (field parity, role behavior, edge cases, deletion scope, API coverage) were unambiguous from the spec, plan, and existing Phase 1-6 patterns. No additional questions would have materially changed the implementation strategy.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — View Labs List with Filters (Priority: P1)

An instructor opens the Labs section and sees all labs they have created for courses they teach. They can search by lab title, filter by status (draft, published, closed, archived), and see key information at a glance: lab title, course name, due date, status badge, and submission count. The list loads from live API data — no mock or static data is shown. When no labs exist, the UI displays an empty state with a clear message and an option to create a new lab.

**Why this priority**: Without viewing existing labs, instructors cannot manage or take action on any lab. This is the entry point to all lab workflows.

**Independent Test**: Can be fully tested by loading the Labs screen and verifying that labs from the live API are displayed with correct filtering and search functionality. Delivers immediate value by giving instructors visibility into their lab inventory.

**Acceptance Scenarios**:

1. **Given** the instructor has labs for their teaching courses, **When** they open the Labs screen, **Then** they see a list of all labs fetched from the live API with title, course name, due date, status badge. (Submission count: display if `submissionCount` field is available from the lab list API response; if not, omit this field.)
2. **Given** the instructor is viewing the labs list, **When** they type in the search field, **Then** the list filters in real-time to show only labs whose title or course name contains the search term (case-insensitive).
3. **Given** the instructor is viewing the labs list, **When** they select a status filter (All/Draft/Published/Closed/Archived), **Then** the list filters to show only labs matching the selected status.
4. **Given** the instructor has no labs, **When** they open the Labs screen, **Then** they see an empty state message with an icon and text saying "No labs found" along with a "Create New Lab" button.
5. **Given** the labs list is loading from the API, **When** the request is in progress, **Then** a skeleton loading placeholder is displayed in the same layout structure as the final content.

---

### User Story 2 — Create a New Lab (Priority: P1)

An instructor creates a new lab by filling out a form with all required fields: course selection (dropdown of courses they teach), lab title, description, available-from date, due date, maximum score, weight percentage, initial status (draft or published), allowed file types (comma-separated list, e.g., "pdf,docx,zip"), and maximum file size in MB. Upon submission, the lab is created via the live API and appears immediately in the labs list.

**Why this priority**: Lab creation is a core capability — without it, instructors cannot add new lab work for students.

**Independent Test**: Can be fully tested by filling out the create form, submitting it, and verifying the lab appears in the labs list with all entered values. Delivers value by enabling instructors to create lab assignments.

**Acceptance Scenarios**:

1. **Given** the instructor has teaching courses, **When** they tap "Create New Lab", **Then** a form appears with fields for course selection, title (required), description, available-from date, due date, max score (default 100), weight (default 10%), status (default draft), allowed file types (optional), and max file size in MB (optional).
2. **Given** the instructor is on the create lab form, **When** they fill in all required fields and submit, **Then** the lab is created via the live API, a success notification is shown, and the labs list refreshes to include the new lab.
3. **Given** the instructor is on the create lab form, **When** they attempt to submit without a title or course selection, **Then** validation errors appear on the missing fields and the API is not called.
4. **Given** the instructor is on the create lab form, **When** they cancel the form, **Then** the form closes without creating a lab and no data is sent to the API.

---

### User Story 3 — Edit and Delete a Lab (Priority: P2)

An instructor opens an existing lab to edit its details (title, description, dates, score, weight, status) or delete it entirely. Editing updates the lab via the live API. Deletion triggers a confirmation dialog before permanently removing the lab.

**Why this priority**: Instructors need to correct mistakes, update deadlines, and remove obsolete labs. Editing is essential for maintaining accurate lab information.

**Independent Test**: Can be fully tested by editing an existing lab's fields, verifying changes persist, then deleting it and confirming removal from the list. Delivers value by enabling lab lifecycle management.

**Acceptance Scenarios**:

1. **Given** the instructor has an existing lab, **When** they tap "Edit" on the lab, **Then** a pre-populated form appears with all current lab details and they can modify any field and save changes to the live API.
2. **Given** the instructor is editing a lab, **When** they save changes, **Then** a success notification is shown and the lab list refreshes to reflect updated values.
3. **Given** the instructor has an existing lab, **When** they tap "Delete", **Then** a confirmation dialog appears showing the lab title and warning that deletion is permanent.
4. **Given** the instructor confirms deletion in the dialog, **When** they tap "Delete" on the confirmation, **Then** the lab is deleted via the live API, a success notification is shown, and the lab is removed from the list.
5. **Given** the instructor cancels the deletion dialog, **When** they tap "Cancel" or taps outside the dialog, **Then** the dialog closes without deleting the lab.

---

### User Story 4 — Manage Lab Instructions (Text + File Uploads) (Priority: P2)

An instructor opens a lab detail view to add, edit, or delete instructions. Instructions can be text (markdown-formatted) or uploaded files (documents from Google Drive). Multiple instructions can be added to a single lab, ordered sequentially using three methods: drag-and-drop with visual handles, manual numeric index entry (typing sequence numbers), or up/down move buttons beside each instruction.

**Why this priority**: Instructions guide students on what to do in the lab. Without instructions, labs lack direction and clarity.

**Independent Test**: Can be fully tested by adding a text instruction, uploading a file instruction, editing an instruction, reordering via any of the three methods, and deleting an instruction — verifying each operation persists via the live API. Delivers value by enabling instructors to communicate lab requirements to students.

**Acceptance Scenarios**:

1. **Given** the instructor is viewing a lab detail, **When** they add a text instruction, **Then** the instruction is saved via the live API and appears in the instructions list with markdown rendering.
2. **Given** the instructor is viewing a lab detail, **When** they upload a file as an instruction, **Then** the file is uploaded to Google Drive via the live API, a Drive preview link is generated, and the file appears in the instructions list with preview and download buttons.
3. **Given** the instructor has multiple instructions, **When** they reorder instructions via drag-and-drop, numeric index entry, or up/down buttons, **Then** the new order is saved via the live API and persists across page reloads.
4. **Given** the instructor wants to edit an instruction, **When** they tap "Edit" on an instruction, **Then** the instruction content becomes editable and saving updates it via the live API.
5. **Given** the instructor wants to delete an instruction, **When** they tap "Delete" on an instruction, **Then** a confirmation appears and confirming removes the instruction from the lab via the live API.

---

### User Story 5 — View and Grade Lab Submissions (Priority: P1)

An instructor opens the submissions view for a specific lab to see all student submissions. They can filter by submission status (submitted, graded, returned, resubmit), search by student name, and sort by submission date, score, or student name. When grading a late submission, the system auto-calculates the late penalty percentage based on submission time vs due date, displaying original score (the score the instructor entered before penalty deduction), penalty %, and final score — but the instructor can manually override the final score before saving. They grade individual submissions by entering a score (0 to maxScore, step 0.5), providing feedback text, and setting a status (submitted, graded, returned, resubmit).

**Why this priority**: Grading is the primary instructor workflow for labs. Without it, students receive no feedback on their lab work and grades cannot be recorded.

**Independent Test**: Can be fully tested by viewing all submissions for a lab, grading one or more submissions with score and feedback (including a late submission to verify penalty calculation), and verifying the grades persist and are reflected in the UI. Delivers immediate value by enabling instructors to evaluate and provide feedback on student work.

**Acceptance Scenarios**:

1. **Given** a lab has student submissions, **When** the instructor opens the submissions view, **Then** they see a list of all submissions with student name, submission date, submission content preview, status badge, and score (if graded).
2. **Given** the instructor is viewing submissions, **When** they select a status filter, **Then** the list filters to show only submissions matching the selected status.
3. **Given** the instructor is viewing submissions, **When** they search by student name, **Then** the list filters to show only submissions from students whose name matches the search term.
4. **Given** the instructor opens a late submission to grade it, **When** the grading panel opens, **Then** the system displays the auto-calculated late penalty percentage, original score, penalty %, and calculated final score.
5. **Given** the instructor is grading a late submission with auto-calculated penalty, **When** they manually adjust the final score before saving, **Then** the instructor-entered score overrides the auto-calculated final score.
6. **Given** the instructor opens a submission to grade it, **When** they enter a score (between 0 and maxScore) and optional feedback, then save, **Then** the grade is recorded via the live API with the submission status set to "graded" and a success notification appears.
7. **Given** the instructor grades a submission with status "graded" and a score, **When** the grade is saved, **Then** the grade is automatically recorded in the central gradebook and becomes visible to the student.
8. **Given** the instructor attempts to grade a submission without entering a score when status is "graded", **Then** a validation error prevents saving until a valid score is provided.

---

### User Story 6 — Manage Lab Attendance (Priority: P3)

An instructor opens the attendance sheet for a specific lab to view and mark attendance for all enrolled students. Attendance statuses include: present, absent, excused, and late. Changes are saved immediately to the live API.

**Why this priority**: Attendance tracking is important for courses that require lab presence as part of grading, but it is secondary to the core lab creation and grading workflows.

**Independent Test**: Can be fully tested by opening the attendance sheet, marking attendance for several students with different statuses, and verifying the marks persist via the live API. Delivers value by enabling instructors to track lab attendance for grading purposes.

**Acceptance Scenarios**:

1. **Given** a lab has enrolled students, **When** the instructor opens the attendance sheet, **Then** they see a list of all students with their current attendance status (or "not marked" if no attendance exists).
2. **Given** the instructor is viewing the attendance sheet, **When** they select a new status for a student (present/absent/excused/late), **Then** the attendance is recorded via the live API and the updated status appears immediately.
3. **Given** the instructor marks attendance for multiple students, **When** they navigate away and return, **Then** all previously marked attendance statuses are preserved and displayed.

---

### Edge Cases

- **Lab with no submissions**: When an instructor opens submissions view for a lab with no submissions yet, the UI displays an empty state with a message like "No submissions yet" and an icon.
- **Past-due date lab creation**: When an instructor creates or edits a lab with a due date in the past, the system accepts it without error (the API allows this) but displays a warning message to the instructor.
- **Score exceeding maxScore**: When an instructor enters a score greater than the lab's maxScore, the system displays a validation error and prevents saving until the score is within the valid range (0 to maxScore).
- **Simultaneous grade updates**: When two instructors attempt to grade the same submission simultaneously, the last saved grade overwrites the previous one (no conflict resolution is provided — the most recent update wins).
- **File upload failure**: When an instruction file upload fails (e.g., network timeout, file too large), the system displays an error message and the instruction is not added to the lab.
- **Lab deletion with submissions**: When an instructor deletes a lab that has existing student submissions, the lab and its submissions are deleted without additional warnings beyond the standard confirmation dialog.
- **Student submission with disallowed file type**: When a student attempts to submit a lab file that does not match the lab's configured allowedFileTypes, the system rejects the submission with a clear error message listing the accepted file types.
- **Student submission exceeding file size limit**: When a student submits a file larger than the lab's maxFileSizeMb, the system rejects the upload with an error message indicating the maximum allowed file size.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a list of all labs for courses the instructor teaches, fetched from the live API endpoint `GET /labs` with courseId filter.
- **FR-002**: System MUST provide client-side search filtering that matches lab title and course name (case-insensitive partial match).
- **FR-003**: System MUST provide client-side status filtering with options: All, Draft, Published, Closed, Archived.
- **FR-004**: System MUST display an empty state with descriptive message and create button when no labs match the current filters.
- **FR-005**: System MUST display skeleton loading placeholders while labs are being fetched from the API.
- **FR-006**: System MUST allow instructors to create a new lab with fields: courseId (required), title (required), description, availableFrom, dueDate, maxScore (default 100), weight (default 10), status (default draft), allowedFileTypes (optional, comma-separated list), and maxFileSizeMb (optional).
- **FR-007**: System MUST validate that title and courseId are provided before submitting the create lab request to the API.
- **FR-008**: System MUST allow instructors to edit an existing lab by pre-populating all fields (including allowedFileTypes and maxFileSizeMb) and submitting updates via `PUT /labs/{id}`.
- **FR-009**: System MUST require confirmation before deleting a lab via `DELETE /labs/{id}`, showing the lab title in the confirmation dialog.
- **FR-010**: System MUST allow instructors to add text instructions (markdown-formatted) to a lab via `POST /labs/{id}/instructions`.
- **FR-011**: System MUST allow instructors to upload file instructions to a lab via `POST /labs/{id}/instructions/upload`, with files stored in Google Drive.
- **FR-012**: System MUST display uploaded file instructions with preview and download buttons using Google Drive preview links.
- **FR-013**: System MUST allow instructors to edit and delete existing instructions with confirmation for destructive actions.
- **FR-014**: System MUST display a list of all student submissions for a specific lab fetched from `GET /labs/{id}/submissions`.
- **FR-015**: System MUST provide filtering by submission status (submitted, graded, returned, resubmit), search by student name, and sorting options (by date, by score, by student name) on the submissions list.
- **FR-016**: System MUST allow instructors to grade a submission by entering a score (0 to maxScore, step 0.5), optional feedback text, and setting submission status via `PATCH /labs/{labId}/submissions/{subId}/grade`.
- **FR-017**: System MUST validate that score is provided when submission status is set to "graded" and that score is within the range 0 to maxScore.
- **FR-018**: System MUST automatically record the grade in the central gradebook when a submission is marked "graded" with a score.
- **FR-019**: System MUST auto-calculate late penalty percentage when grading a late submission (based on submission timestamp vs lab due date) and display original score, penalty %, and calculated final score in the grading panel.
- **FR-020**: System MUST allow instructors to manually override the auto-calculated final score before saving, with the instructor-entered value taking precedence.
- **FR-021**: System MUST enforce file type and size restrictions on student lab submissions based on the lab's configured allowedFileTypes and maxFileSizeMb fields, rejecting submissions that exceed these limits. *(Note: Enforcement is student-facing — Phase 4 scope. Phase 7 provides the config fields on the LabModel. Student-side enforcement will be implemented when Phase 4 student submission UI is updated.)*
- **FR-022**: System MUST allow instructors to reorder lab instructions via three methods: drag-and-drop with visual handles, manual numeric index entry, and up/down move buttons — all persisting order changes via the live API.
- **FR-023**: System MUST display a list of enrolled students for a lab with their current attendance status fetched from `GET /labs/{id}/attendance`.
- **FR-024**: System MUST allow instructors to mark attendance for each student with statuses: present, absent, excused, late via `POST /labs/{id}/attendance`.
- **FR-025**: System MUST maintain responsive layouts that adapt to mobile (single-column, card-based), tablet (2-column grids), and desktop (multi-column) viewports.
- **FR-026**: System MUST preserve ≥85% visual similarity with existing UI screens after this phase — no wholesale redesigns, color changes, or layout reorganizations.
- **FR-027**: System MUST remove all mock and static data from instructor labs screens and replace with live API data, showing empty states when no data exists.

### Key Entities

- **Lab**: Represents a lab assignment for a course. Key attributes: unique identifier, course association, title, description, available-from date, due date, maximum score, weight percentage, status (draft/published/closed/archived), allowed file types (optional, comma-separated list), max file size in MB (optional), creation metadata. Contains multiple instructions and associated submissions.
- **LabInstruction**: Represents a single instruction within a lab. Can be text-based (markdown content) or file-based (Google Drive file reference with preview/download links). Has an order index for sequencing. Supports reordering via drag-and-drop, numeric index entry, or up/down move buttons.
- **LabSubmission**: Represents a student's submission to a lab. Key attributes: lab association, student user, submission text, file attachment (optional, subject to lab's allowedFileTypes and maxFileSizeMb constraints), submission status (submitted/graded/returned/resubmit), score, feedback, grading metadata (graded by, graded at), lateness indicator, late penalty percentage (auto-calculated when late, instructor-overridable).
- **LabAttendance**: Represents a student's attendance record for a lab session. Key attributes: lab association, student user, attendance status (present/absent/excused/late), check-in timestamp, notes.
- **DriveFile**: Represents a Google Drive file associated with a lab instruction. Key attributes: Drive file identifier, file name, preview URL, download URL, entity type classification.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Instructors can create a new lab with all required fields in under 60 seconds from opening the form to successful submission.
- **SC-002**: Labs list loads from the live API and renders on screen in under 2 seconds for courses with up to 50 labs.
- **SC-003**: Instructors can grade a lab submission by entering score and feedback in under 30 seconds.
- **SC-004**: 95% of instructors can successfully create, edit, and delete a lab on their first attempt without encountering validation errors (excluding intentional error testing).
- **SC-005**: Search and filter operations on the labs list return filtered results in under 500 milliseconds for lists of up to 100 labs.
- **SC-006**: All instructor labs screens maintain ≥85% visual similarity with their pre-integration state, verified by component-level comparison of layout structure, color scheme, and widget hierarchy.
- **SC-007**: Zero mock or static data remains in any instructor labs screen — all data is sourced from live API endpoints.
- **SC-008**: Lab attendance can be marked for all students in a lab session in under 2 minutes for a class of 30 students.

## Assumptions

- Instructors have stable internet connectivity to interact with the live API.
- The existing `LabService` from Phase 1 is fully implemented and functional with all endpoints documented in the backend API documentation.
- Google Drive integration for file uploads is already configured and operational (backend handles Drive API authentication and file storage).
- Instructors are authenticated and authorized via JWT tokens — only instructors enrolled as teachers for a course can manage labs for that course.
- The existing UI component library (cards, dialogs, forms, buttons, badges, skeleton loaders) is available for reuse without modification.
- Responsive breakpoints follow the project standard: mobile (<600px), tablet (600px–1024px), desktop (>1024px).
- The BLoC/Cubit state management pattern is used consistently across all new and modified screens.
- No new backend endpoints are required — all endpoints referenced in the backend API documentation (`COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`) are available and functional.
- TA users are not in scope for this phase — TA lab management is covered in Phase 8.
- Video lectures and course materials management are out of scope — covered in Phase 5.
- Student-facing lab features (lab submission, instructions view) are out of scope — covered in Phase 4.
