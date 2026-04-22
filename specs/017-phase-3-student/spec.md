# Feature Specification: Phase 3 — Student Assignments

**Feature Branch**: `017-phase-3-student`
**Created**: 2026-04-11
**Status**: Draft
**Input**: Phase 3: Student — Assignments. Fully integrate the student assignment workflow: list, detail, submission, and grade viewing. Replace all mock data with live API calls while preserving ≥85% UI similarity.

---

## Clarifications

### Session 2026-04-11

- **Q**: Should the assignments list include or exclude assignments with status `draft`, `closed`, and `archived`? → **A**: Show `published` and `closed` assignments (closed ones visible for reference); hide `draft` (instructor work-in-progress) and `archived` (historical clutter).
- **Q**: When a student taps an assignment from the list, how should the detail view appear? → **A**: Push a new full-screen route (standard navigation with back button). The detail screen must follow the same UI patterns (colors, structure, component styles) as the remaining app screens, maintaining ≥85% visual similarity.
- **Q**: What does each filter status (Submitted, Pending, Overdue) mean? → **A**: Based on the student's submission state relative to the due date: Submitted = student has a submission, Pending = no submission and due date has not yet passed, Overdue = no submission and due date has passed.
- **Q**: Where should the submission form appear when the student wants to submit? → **A**: Modal bottom sheet (slides up over the detail screen, dismissible by swiping down).
- **Q**: For file-type submissions, what file sources should the student be able to pick from? → **A**: Both local device storage (standard file picker) and Google Drive picker (student can choose from either source).

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Browse and Filter Assignments (Priority: P1)

As a student, I want to see all my assignments for my enrolled courses, with the ability to filter by submission status (All, Submitted, Pending, Overdue) and search by title, so that I can quickly find the assignments I need to work on.

**Why this priority**: This is the entry point for all assignment interactions. Without a functional assignment list, students cannot discover or navigate to individual assignments. It replaces the current placeholder/mock data with real academic tasks.

**Independent Test**: Can be fully tested by loading the Assignments screen and verifying that real assignments appear from the backend, filters correctly narrow the list, and search finds matching assignments. Delivers immediate value by giving students visibility into their academic workload.

**Acceptance Scenarios**:

1. **Given** the student is logged in and enrolled in at least one course, **When** they navigate to the Assignments screen, **Then** assignments from all their enrolled courses load from the backend and display in a list/card view.
2. **Given** assignments are displayed, **When** the student taps a status filter (All, Submitted, Pending, Overdue), **Then** only assignments matching that status are shown.
3. **Given** assignments are displayed, **When** the student types into the search bar, **Then** the list filters in real-time to show only assignments whose title or description matches the search text.
4. **Given** the student has no assignments for their enrolled courses, **When** they navigate to the Assignments screen, **Then** an empty state message is displayed indicating no assignments are available.
5. **Given** the student has assignments across multiple courses, **When** the screen loads, **Then** summary statistics (Total, Submitted count, Pending count, Overdue count) are displayed accurately.

---

### User Story 2 — View Assignment Details and Instructions (Priority: P2)

As a student, I want to view the full details of a specific assignment including its title, due date, maximum score, submission type, status, formatted instructions (with markdown rendering), and any attached instruction files with preview capability, so that I understand exactly what is required before I submit my work.

**Why this priority**: Students need complete context about an assignment before attempting submission. This includes understanding formatting requirements, reading attached documents, and knowing deadlines. Without this, students cannot properly prepare their submissions.

**Independent Test**: Can be fully tested by tapping an assignment from the list, viewing its details, reading instructions, and previewing any attached instruction files. Delivers value by providing complete assignment context even if submission is not yet available.

**Acceptance Scenarios**:

1. **Given** the student taps an assignment from the list, **When** they tap, **Then** a new full-screen detail route is pushed (with back button) following the same UI patterns as the remaining app screens, displaying the title, due date, maximum score, submission type, status badge, and course name.
2. **Given** the assignment has formatted instructions, **When** the student views the detail screen, **Then** the instructions render with proper markdown formatting (headings, lists, bold text, etc.).
3. **Given** the assignment has attached instruction files (cloud document attachments), **When** the student views the detail screen, **Then** each file is displayed with an inline preview (via embedded web view), an "Open in Drive" link, and a download option.
4. **Given** the assignment has no instruction files, **When** the student views the detail screen, **Then** no file section is shown (the UI space is preserved but hidden gracefully).

---

### User Story 3 — Submit Assignment Work (Priority: P3)

As a student, I want to submit my assignment work using the submission method specified by the instructor (text entry, link/URL, file upload, or any method), so that my work is recorded and available for grading.

**Why this priority**: This is the core action of the assignment workflow — without submission capability, students cannot complete their academic tasks on the mobile app. This replaces the current "feature coming soon" placeholder with actual functionality.

**Independent Test**: Can be fully tested by selecting an assignment, filling in the appropriate submission form based on the assignment's submission type, and submitting successfully. Delivers value by enabling students to complete assignments on mobile.

**Acceptance Scenarios**:

1. **Given** the assignment submission type is "text", **When** the student opens the submission form (modal bottom sheet), enters text, and taps submit, **Then** the text is submitted to the backend and a success confirmation is shown.
2. **Given** the assignment submission type is "link", **When** the student opens the submission form (modal bottom sheet), enters a valid URL, and taps submit, **Then** the link is submitted and a success confirmation is shown.
3. **Given** the assignment submission type is "file", **When** the student opens the submission form (modal bottom sheet), selects a file from their local device or Google Drive within the allowed size and type constraints, and taps submit, **Then** the file is uploaded to cloud storage through the backend and the submission is recorded with a success confirmation.
4. **Given** the assignment submission type is "any" or "multiple", **When** the student opens the submission form (modal bottom sheet) and chooses any submission method (text, link, or file), **Then** the submission is accepted regardless of the method chosen.
5. **Given** the assignment is past its due date and late submissions are not allowed, **When** the student attempts to submit, **Then** a clear error message explains that the deadline has passed and late submissions are not accepted.
6. **Given** the assignment is past its due date and late submissions are allowed with a penalty, **When** the student submits, **Then** the submission is accepted with a warning that a late penalty will be applied.

---

### User Story 4 — View Existing Submission and Grade (Priority: P3)

As a student, I want to view my previous submission for an assignment, including my score, instructor feedback, submission date, and whether it was marked as late, so that I can understand my performance and know if resubmission is allowed.

**Why this priority**: After submitting or being graded, students need to see their results. This provides closure to the assignment workflow and informs students whether they can improve their grade through resubmission.

**Independent Test**: Can be fully tested by viewing an assignment for which a submission already exists and verifying that submission content, score, feedback, and status are displayed correctly.

**Acceptance Scenarios**:

1. **Given** the student has already submitted the assignment, **When** they open the assignment detail screen, **Then** their existing submission is displayed with submission content, submission date, and status.
2. **Given** the student's submission has been graded, **When** they view their submission, **Then** the score (out of maximum score), instructor feedback, and grading date are displayed.
3. **Given** the student's submission was late, **When** they view their submission, **Then** a late badge/indicator is shown.
4. **Given** the student's submission has been graded and resubmission is allowed, **When** they view their submission, **Then** an option to resubmit is available.
5. **Given** the student's submission has been graded and resubmission is not allowed, **When** they view their submission, **Then** no resubmission option is shown (read-only view).

---

### Edge Cases

- **No enrolled courses**: If the student is not enrolled in any courses, the assignments screen shows an empty state with a message suggesting the student enroll in courses.
- **Assignment past deadline with no late submission allowed**: The submission form is disabled or hidden, with a clear message that the deadline has passed.
- **File upload exceeds maximum file size**: The student receives an error message indicating the file is too large, with the maximum allowed size displayed.
- **File type not in allowed list**: The student receives an error message listing the allowed file types for this assignment.
- **Network failure during submission**: The student receives an error message and their submission data is preserved in the form so they can retry without re-entering everything.
- **Assignment status is "closed"**: The assignment is visible for reference but the submission form is disabled or hidden, with a clear message that the assignment is no longer accepting submissions.
- **Instruction file fails to load preview**: A fallback "Open in Drive" link is shown when the inline preview fails to load.
- **Backend returns unexpected submission type enum**: The app handles unknown submission types gracefully by showing all available submission methods.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch the student's assignments from the backend, filtered by the student's enrolled course IDs, and display only assignments with status `published` or `closed` (assignments with status `draft` or `archived` are hidden).
- **FR-002**: System MUST display summary statistics showing Total assignments, Submitted count, Pending count, and Overdue count based on the fetched assignments list.
- **FR-003**: System MUST provide a search input that filters assignments by title and description text (client-side filtering).
- **FR-004**: System MUST provide status filter buttons with options: All, Submitted, Pending, Overdue — filtering based on the student's submission state relative to the assignment due date: Submitted = student has a submission, Pending = no submission and due date not yet passed, Overdue = no submission and due date has passed.
- **FR-005**: System MUST fetch individual assignment details when the student selects an assignment from the list.
- **FR-006**: System MUST render assignment instructions with markdown formatting support (headings, lists, bold, italic, code blocks, links).
- **FR-007**: System MUST display assignment instruction files (cloud document attachments) with inline preview capability, plus "Open in Drive" and download links.
- **FR-008**: System MUST fetch the student's existing submission for an assignment when viewing assignment details.
- **FR-009**: System MUST present the submission form as a modal bottom sheet (sliding up over the detail screen, dismissible), and render the appropriate input based on the assignment's configured submission type:
  - Text-only → text input area
  - Link-only → URL input with validation
  - File-only → file picker with size and type validation
  - Any/Multiple → all three options available for student to choose
- **FR-010**: System MUST submit text and link submissions as structured data to the backend.
- **FR-011**: System MUST submit file submissions through the backend's file upload mechanism, allowing the student to pick files from either their local device storage or Google Drive.
- **FR-012**: System MUST validate file size against the assignment's maximum file size setting before upload.
- **FR-013**: System MUST validate file extension against the assignment's allowed file types list before upload (when specified).
- **FR-014**: System MUST prevent submission when the assignment deadline has passed AND late submissions are not allowed, displaying an appropriate error message.
- **FR-015**: System MUST allow submission after the deadline when late submissions are allowed, and display a warning that a late penalty will be applied.
- **FR-016**: System MUST display the student's existing submission (content, score, feedback, late status, submission date) when one exists.
- **FR-017**: System MUST display a late indicator when the student's submission is marked as late.
- **FR-018**: System MUST show the score as a fraction of earned points over maximum points when the submission has been graded.
- **FR-019**: System MUST provide a resubmission option when the student's latest submission has been graded (creates a new attempt).
- **FR-020**: System MUST handle network errors gracefully with user-friendly error messages and preserve form data on failure so the student can retry.
- **FR-021**: System MUST display an empty state when the student has no assignments across their enrolled courses.
- **FR-022**: System MUST preserve the existing UI layout, colors, structure, and visual design with at least 85% visual similarity — only mock data is replaced with live data.
- **FR-023**: System MUST be fully responsive across mobile phones, tablets, and desktop screens, with data tables converting to card-based list views on smaller screens.
- **FR-024**: System MUST ensure all interactive elements maintain a minimum touch target size for accessibility.

### Key Entities *(include if feature involves data)*

- **Assignment**: Represents a task assigned to students within a course. Key attributes: title, description, instructions (markdown-formatted), due date, maximum score, weight in grading, submission type (text/file/link/any), late submission policy (allowed/not allowed, penalty percentage), status (draft/published/closed/archived — only `published` and `closed` are visible to students), and associated instruction files (cloud storage attachments).
- **Assignment Submission**: Represents a student's work submitted for an assignment. Key attributes: submission content (text, link, or file reference), submission date, status (submitted/graded/returned/resubmit), score (when graded), instructor feedback, late status, attempt number (for resubmissions). The "Pending" and "Overdue" filter states are derived from this entity: Pending = no submission exists and due date not yet passed; Overdue = no submission exists and due date has passed.
- **Instruction File**: A cloud storage file attached to an assignment as part of the instructions. Key attributes: file ID, file name, web view link, preview URL, download URL.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Students can view their assignments list within 3 seconds of navigating to the Assignments screen (measured from navigation to first render of assignment cards).
- **SC-002**: Students can submit an assignment (text, link, or file) in under 2 minutes from opening the assignment detail screen to seeing the success confirmation.
- **SC-003**: 95% of assignment submissions are successfully recorded on the first attempt without requiring a retry (measured as successful backend responses divided by total submission attempts).
- **SC-004**: Students can accurately identify the due date, submission type, and maximum score for any assignment within 5 seconds of opening the assignment detail screen.
- **SC-005**: File uploads for assignments up to 10MB complete successfully in under 30 seconds on a standard mobile data connection.
- **SC-006**: The modified assignment screens maintain at least 85% visual similarity to the pre-integration UI (measured by comparing layout structure, color usage, component placement, and navigation patterns).
- **SC-007**: All screens are fully functional and tested at mobile portrait width (375px), tablet portrait width (768px), and desktop width (1024px+), with no horizontal scrolling and minimum touch targets maintained.

---

## Assumptions

- The student is already authenticated and has a valid access token from the existing authentication system.
- The student is enrolled in at least one course section with an active enrollment status for assignments to be visible.
- The backend API endpoints for assignment listing, detail retrieval, submission, file upload, and submission retrieval are operational and return data in the documented format.
- Cloud document preview URLs provided by the backend are valid and accessible without additional authentication beyond the initial token.
- The existing assignment service class (created in Phase 1) is available and functional for making backend calls.
- The existing assignment-related data models accurately represent the backend response schemas.
- Students have stable internet connectivity sufficient for loading assignment data and uploading files (minimum mobile data connection assumed).
- File uploads are handled through the backend's cloud storage integration — the mobile app does not directly interact with cloud storage APIs.
- The packages for web view embedding and markdown rendering (added in earlier phases) are available for rendering document previews and formatted instructions.
- File submission picking supports both local device storage (platform file picker) and Google Drive (via web view-based Drive picker) as file sources.
- No real-time or push notification features are in scope for this phase — assignment status updates require manual screen refresh.
- The assignment list is fetched for all enrolled courses; course-level filtering within the assignments screen is out of scope unless explicitly included in the existing UI.
- Markdown rendering for instructions uses standard styling that matches the existing app theme.
- The existing UI already has placeholder spaces for stats cards, search bar, status filters, assignment cards, and submission forms — these spaces will be populated with live data rather than redesigned.
- Late submission penalty percentage is applied by the backend during grading; the mobile app only displays the warning, it does not calculate the penalty itself.
