# Feature Specification: Student Labs Integration

**Feature Branch**: `018-student-labs`
**Created**: 2026-04-11
**Status**: Draft
**Input**: User description: "Phase 4: Student — Labs - Fully integrate the student lab workflow: list, detail, instructions, submission, and view grade"

---

## Clarifications

### Session 2026-04-11

- Q: Lab detail screen navigation pattern? → A: Separate full screen (LabDetailScreen) pushed onto navigation stack, with same UI structure, colors, and design language as the existing lab list screen (≥85% visual similarity)
- Q: Submission form presentation pattern? → A: Bottom sheet slides up from bottom when student taps "Submit" button, overlaying the lab detail screen (consistent with existing lab_details_sheet.dart pattern)
- Q: Submission analytics/tracking scope? → A: Track submit/success and submit-fail events only locally for debugging and SC-003 validation

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse and View Labs List (Priority: P1)

As a student enrolled in a course with labs, I want to see a list of all available labs for that course so I can understand what lab work is assigned, their due dates, and their current status.

**Why this priority**: This is the entry point to the entire labs workflow. Without visibility into assigned labs, students cannot plan their lab work or know what's expected of them. This is the foundational discovery step that enables all subsequent interactions.

**Independent Test**: Can be fully tested by enrolling a student in a course with published labs and verifying the labs list displays correctly with all metadata (title, due date, max score, status badges, course context).

**Acceptance Scenarios**:

1. **Given** a student is enrolled in a course with published labs, **When** they navigate to the Labs screen and select that course, **Then** they see a list of all published labs for that course with title, lab number, due date, max score, and status badge
2. **Given** a course has no published labs, **When** a student selects that course, **Then** they see an empty state message indicating no labs are available yet
3. **Given** a student has multiple enrolled courses with labs, **When** they open the Labs screen, **Then** they see a course selector dropdown populated from their actual enrolled courses
4. **Given** labs have different statuses (published, closed), **When** viewing the labs list, **Then** each lab displays a color-coded status badge indicating its current state

---

### User Story 2 - View Lab Instructions and Materials (Priority: P2)

As a student who needs to complete a lab, I want to view detailed instructions and access any attached materials (documents, files) so I understand exactly what work is required.

**Why this priority**: Lab instructions are the core content that guides student work. Without clear access to instructions and supporting materials, students cannot complete lab assignments even if they can see the lab exists. This directly impacts academic success.

**Independent Test**: Can be fully tested by selecting any lab from the list and verifying that all instructions (text and file-based) render correctly with proper ordering and file previews/downloads work.

**Acceptance Scenarios**:

1. **Given** a student taps a lab from the labs list, **When** they select a lab, **Then** a separate full-screen detail view opens (LabDetailScreen) with the same UI structure, colors, and design language as the lab list screen
2. **Given** a lab has text-based instructions, **When** a student opens the lab detail view, **Then** they see the instructions rendered with proper formatting (markdown rendering if applicable) in the order specified by the instructor
3. **Given** a lab has attached instruction files (Google Drive documents), **When** a student views the lab detail, **Then** they see a grid of files with "Open" and "Download" buttons for each file
4. **Given** a lab has both text instructions and file attachments, **When** a student opens the lab detail, **Then** both text and file instructions are displayed together in the correct order (by orderIndex)
5. **Given** a student has been marked present for a lab session, **When** they view the lab detail, **Then** they see an attendance badge indicating their attendance status

---

### User Story 3 - Submit Lab Work (Priority: P3)

As a student ready to complete a lab, I want to submit my work (as text, file upload, or both) so the instructor/TA can evaluate my completion of the lab requirements.

**Why this priority**: This is the core action that completes the lab workflow. Without submission capability, the entire labs feature is non-functional for students. This directly impacts students' ability to receive grades for their work.

**Independent Test**: Can be fully tested by opening a published lab, entering text and/or uploading a file, submitting, and verifying the submission is recorded by the backend.

**Acceptance Scenarios**:

1. **Given** a lab is published and accepting submissions, **When** a student taps the "Submit" button on the lab detail screen, **Then** a bottom sheet slides up from the bottom of the screen containing text input (textarea) and file upload options
2. **Given** a student has filled in the submission form in the bottom sheet, **When** they tap the submit button, **Then** their work is uploaded to the backend and they receive confirmation of successful submission
3. **Given** a lab is past its due date but still accepting late submissions, **When** a student submits, **Then** the submission is recorded with a "late" indicator and the student is informed their submission is late
4. **Given** a lab is closed or archived, **When** a student opens the lab detail, **Then** the "Submit" button is hidden or disabled, preventing the bottom sheet from opening
5. **Given** a student attempts to upload a file, **When** the file exceeds size limits or is an unsupported type, **Then** they see a clear error message explaining the issue before the submission is attempted

---

### User Story 4 - View Submission Grades and Feedback (Priority: P4)

As a student who has submitted lab work, I want to see my grade, any feedback provided, and all my submission attempts so I can understand my performance and improve if needed.

**Why this priority**: This completes the feedback loop in the learning process. While not blocking the core submission workflow, it's essential for students to track their progress and understand their grades.

**Independent Test**: Can be fully tested by submitting lab work, having an instructor grade it, and verifying the student can see their score, feedback, and submission status.

**Acceptance Scenarios**:

1. **Given** a student has submitted lab work that has been graded, **When** they open the lab detail view, **Then** they see their score (e.g., "85/100"), feedback text from the instructor/TA, and the graded date
2. **Given** a student has submitted lab work that hasn't been graded yet, **When** they open the lab detail view, **Then** they see a "Pending" or "Submitted" status indicator with their submission date
3. **Given** a student has made multiple submission attempts for the same lab, **When** they view their submissions, **Then** they see all attempts with their respective scores, feedback, and dates
4. **Given** a student's submission was marked late, **When** they view their submission details, **Then** they see a "Late" badge/indicator alongside their submission

---

### Edge Cases

- **What happens when the lab due date passes but the lab status is still "published"?**: Students should still be able to submit, but the submission is marked as late (isLate = true). The frontend displays a late warning if the current time is past the due date.
- **How does the system handle network failures during file submission upload?**: The submission form displays an error message and allows the student to retry without losing their text input (if any). File uploads show progress indicators.
- **What happens when a student tries to submit to a lab in a course they're not actively enrolled in?**: Frontend validates enrollment status before allowing submission and displays an error if the student is not enrolled (even though backend currently lacks this check).
- **How does the system handle a lab with no instructions at all?**: The lab detail view shows a message "No instructions provided yet" instead of an empty space.
- **What happens when Google Drive instruction files cannot be loaded (network issue, permissions error)?**: File previews show an error state with a retry button and a direct "Open in Drive" fallback link.
- **How are very large lab instruction files (e.g., 50MB+) handled?**: Files display size information and download buttons, but preview attempts show a warning that the file may take time to load.
- **How are submission failures tracked for debugging?**: Each submission attempt (success or failure) is logged locally with timestamp, lab ID, and error details. This enables developers to diagnose recurring failures and validate the ≥95% submission success rate target (SC-003) without relying solely on backend analytics.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch the student's enrolled courses from the backend (`GET /enrollments/my-courses`) and display them in a course selector dropdown on the Labs screen
- **FR-002**: System MUST fetch labs for the selected course from the backend (`GET /labs?courseId={id}`) and display them in a list with title, lab number, due date, max score, and status badge
- **FR-003**: System MUST display an empty state when a course has no published labs, preserving the UI layout space
- **FR-004**: System MUST fetch lab details (`GET /labs/{id}`) and display title, lab number, description, due date, max score, weight, and status when a student selects a lab
- **FR-005**: System MUST fetch lab instructions (`GET /labs/{id}/instructions`) and render text instructions in order (by `orderIndex`) using markdown formatting
- **FR-006**: System MUST display instruction files (Google Drive attachments) in a responsive grid with "Open" and "Download" buttons, and render file previews via embedded WebView using the file's iframe URL
- **FR-007**: System MUST display an attendance badge on the lab detail view if the student has been marked present for that lab session
- **FR-008**: System MUST provide a submission form with text input (textarea) for text-based lab submissions
- **FR-009**: System MUST provide a file upload mechanism (file picker) for file-based lab submissions
- **FR-010**: System MUST submit text-only lab data via the backend text submission endpoint (`POST /labs/{id}/submit`) with the `submissionText` field
- **FR-011**: System MUST submit file-based lab work via the backend file upload endpoint (`POST /labs/{id}/submissions/upload`) using FormData with the `file` field (Constitution Principle X: do NOT manually set Content-Type header)
- **FR-012**: System MUST validate frontend enrollment in the lab's course before allowing submission (compensating for backend gap — `checkEnrollment()` defined in tasks.md T019, submission gated in T033)
- **FR-013**: System MUST display a late submission warning when the current time is past the lab's due date
- **FR-014**: System MUST disable or hide the submission form when the lab status is "closed" or "archived"
- **FR-015**: System MUST fetch the student's submission attempts via the backend my-submission endpoint (`GET /labs/{id}/submissions/my`) and display all attempts with scores, feedback, submission dates, and late indicators
- **FR-016**: System MUST display a graded badge with score (e.g., "85/100") when a submission has been graded
- **FR-017**: System MUST display instructor/TA feedback text when a submission has been graded
- **FR-018**: System MUST handle file upload errors (size limits, type restrictions) with clear error messages before attempting backend submission
- **FR-019**: System MUST show upload progress indicators during file submission uploads
- **FR-020**: System MUST preserve all existing UI colors, layout structure, and component styles with ≥85% visual similarity to the pre-integration screen
- **FR-021**: System MUST be fully responsive across mobile phones (<600px), tablets (600px-1024px), and desktop (>1024px) viewports — applies to all screens: LabsScreen, LabDetailScreen, LabSubmissionSheet, InstructionViewer, and SubmissionHistoryView
- **FR-022**: System MUST remove all static/mock lab data from the UI and replace with live API data, preserving the UI space (showing empty states when no data exists)
- **FR-023**: System MUST correctly parse `isLate` as a boolean value (true/false) from the backend response, not as a number (Constitution Principle III)
- **FR-024**: System MUST track submission success and submission-failure events locally (including timestamp, lab ID, and error details on failure) for debugging and validating SC-003 (≥95% submission success rate)

### Key Entities

- **Lab**: Represents a lab assignment within a course. Has a title, description, lab number, due date, available-from date, max score, weight (percentage of grade), and status (draft/published/closed/archived). Belongs to one course. Contains multiple instructions.
- **LabInstruction**: Represents a single instruction step or attached file for a lab. Can be text-based (markdown format) or file-based (Google Drive attachment). Has an order index that determines display sequence. Belongs to one lab.
- **LabSubmission**: Represents a student's submitted work for a lab. Contains submission text and/or an uploaded file reference (Google Drive). Has a status (submitted/graded/returned/resubmit), optional score, optional feedback text, submission date, and late indicator (boolean). A student may have multiple submission attempts for the same lab.
- **DriveFile**: Represents a Google Drive file used as a lab instruction or submitted work. Has a Drive file ID, filename, web viewer link, embeddable iframe URL, and download URL.
- **CourseEnrollment**: Represents a student's enrollment in a course section. Has enrollment status (enrolled/waitlisted/dropped/completed/failed), enrollment date, and references the course, section, and semester objects. Used to validate that a student is actively enrolled before allowing lab submission (FR-012 → tasks.md T019/T033).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Students can view their enrolled courses and select a course to see its labs within 2 seconds of screen load on a standard mobile connection (3G/4G speeds)
- **SC-002**: Lab instructions (text and file-based) render correctly 100% of the time when the backend returns valid data
- **SC-003**: Students can successfully submit lab work (text and/or file) with a success rate of ≥95% on the first attempt
- **SC-004**: File uploads up to 50MB complete successfully with visible progress indication and no data loss on network interruption (retry capability)
- **SC-005**: Students can view their graded lab submissions (score and feedback) within 1 second of opening the lab detail view for already-graded submissions

---

## Assumptions

- Students have stable internet connectivity sufficient for API calls and file uploads (minimum 3G connectivity assumed)
- The existing authentication system (JWT tokens via `CoreApiClient`) will be reused for all lab-related API calls
- The LabService created in Phase 1 is complete and functional with all endpoints listed in the backend API documentation
- Lab instruction text may contain markdown formatting and should be rendered accordingly
- Google Drive files are accessible to authenticated students with appropriate permissions (no additional OAuth flow needed beyond existing auth)
- File upload size limits follow the website defaults (50MB for documents) unless otherwise specified by the backend
- The `isLate` field in lab submission responses is a boolean (true/false), consistent with the website frontend's handling
- Students can only submit labs for courses they are actively enrolled in (enrollment status = 'enrolled')
- Multiple submission attempts for the same lab are allowed and all should be visible to the student
- The UI structure (card layouts, list structures, navigation patterns) from the existing labs screen will be preserved — only mock data is replaced with live API data
- Empty states should match the existing app's empty state design patterns (icons, text, and layout consistent with other screens)
- Lab submission does not support link submissions (unlike assignments which support text/file/link/any) — only text and file submission types are available
- The backend's missing enrollment check for lab submissions is a known gap — frontend implements its own validation as a compensating control
- Existing app theme (colors, typography, spacing) will be used without modification to maintain ≥85% visual similarity
