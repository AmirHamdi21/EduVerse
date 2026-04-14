# Feature Specification: TA — Courses, Assignments & Labs Integration

**Feature Branch**: `022-ta-courses-assignments-labs`
**Created**: 2026-04-14
**Status**: Draft
**Input**: User description: "Phase 8: TA — Courses, Assignments & Labs Integration. Read integration plan, frontend docs, and backend API docs. The UI of changed screens must remain the same (same colors, same structure) — only static/mockup data is to be deleted with its space preserved in the UI. Overall UI after this phase must be at least 85% of the past UI. Follow the remaining UI patterns of the app screens."

## Clarifications

### Session 2026-04-14

- Q: Should TA screens reuse existing Instructor/Student screens or be built as separate dedicated TA screens? → A: Hybrid approach — reuse Instructor CRUD screens for assignment/lab management; build new TA-specific course list and course detail screens with modern, colorful UI matching existing TA screen design patterns.
- Q: Should all 9 course detail sub-tabs use live API data or a mix of live API and managed/mock state? → A: All 9 sub-tabs attempt live API fetches first; show structured empty states when data or endpoints are unavailable. For endpoints not found in documentation files, inspect the backend project at `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`.
- Q: Is TA permission scope course-wide or section-specific? → A: Section-scoped — TA only sees students, submissions, labs, and data for the specific sections they are assigned to within a course.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — TA Views Assigned Courses & Course Details (Priority: P1)

A Teaching Assistant opens the app, navigates to their Courses screen, and sees the courses they are assigned to (section-scoped). Tapping a course opens a detail screen with 9 sub-tabs — each attempting live API data fetches and showing structured empty states when data or endpoints are unavailable: overview statistics, sections and labs, lectures, materials, assignments, grading, attendance, students, and announcements. The TA-specific course screens use a modern, colorful UI design consistent with the existing TA screen patterns in the app. The TA can browse and review all course-related information but cannot modify course-level structure or settings.

**Why this priority**: This is the foundational screen TAs use to understand their assignments. Without live course data, TAs cannot see what they are responsible for. It provides the entry point for all other TA workflows.

**Independent Test**: A TA with teaching_assistant role can log in, see their assigned courses fetched from the backend, tap a course, and view all 9 sub-tabs populated with live API data. Even without assignment/lab grading implemented, the course browsing experience is functional.

**Acceptance Scenarios**:

1. **Given** a TA is logged in, **When** they open the Courses screen, **Then** they see their assigned courses fetched from the backend with no mock data
2. **Given** a TA sees their courses list, **When** they tap a course, **Then** they see the course detail screen with 9 sub-tabs populated from live API data
3. **Given** a TA is on a course detail sub-tab, **When** the sub-tab data is loading, **Then** they see a loading indicator and the UI space is preserved (no layout collapse)

---

### User Story 2 — TA Creates, Edits, and Deletes Assignments (Priority: P1)

A TA navigates to an assigned course (section-scoped) and creates a new assignment using the shared Instructor assignment creation form, filling out all required fields (title, description, instructions, due date, max score, weight, submission type, file constraints, late penalty, status). They can also edit existing assignments and delete them with confirmation. All actions call the live backend API. The TA reuses the existing Instructor CRUD screen components for assignment management.

**Why this priority**: TAs need to create and manage assignments as part of their teaching duties. This is a core academic function that replaces the current static placeholder screens.

**Independent Test**: A TA can create an assignment with all fields, see it appear in the assignment list, edit it to change a field, and delete it with a confirmation dialog. Each action is verifiable via the API response.

**Acceptance Scenarios**:

1. **Given** a TA is on an assignments screen for a course, **When** they tap "Create Assignment", **Then** they see a form with all required fields and can submit to create an assignment via the backend
2. **Given** a TA sees an assignment they created, **When** they tap "Edit", **Then** the form is pre-populated with existing values and they can save changes
3. **Given** a TA sees an assignment, **When** they tap "Delete", **Then** they see a confirmation dialog and the assignment is removed after confirming

---

### User Story 3 — TA Grades Assignment Submissions (Priority: P1)

A TA opens an assignment's submissions list (section-scoped — only students from their assigned sections), sees all student submissions with filtering and sorting, selects a pending submission, and grades it by entering a score and optional feedback. The grade is saved to the backend and the submission status updates. The TA reuses the existing Instructor grading panel screen components.

**Why this priority**: Grading is the primary daily workflow for TAs. Without this, TAs cannot perform their core academic function of evaluating student work.

**Independent Test**: A TA can load submissions for an assignment, filter to see only ungraded submissions, select one, enter a score and feedback, save the grade, and see the submission status update to "graded".

**Acceptance Scenarios**:

1. **Given** a TA opens an assignment, **When** they view submissions, **Then** they see all student submissions with student name, submission date, status, and score (if graded)
2. **Given** a TA sees a submission list, **When** they filter by "Ungraded", **Then** only submissions with status "submitted" are shown
3. **Given** a TA selects a pending submission, **When** they enter a score (0 to maxScore) and feedback, **Then** the grade is saved and the submission status changes to "graded"

---

### User Story 4 — TA Creates, Edits, and Views Labs (Priority: P2)

A TA navigates to the Labs screen (section-scoped), sees all labs for their assigned course sections, and can create new labs, edit existing labs, and view lab details. The TA reuses the existing Instructor CRUD screen components for lab management. The lab creation form includes all required fields. Lab deletion is available with confirmation.

**Why this priority**: Labs are a parallel academic deliverable to assignments. TAs need to manage labs independently to support course delivery.

**Independent Test**: A TA can create a lab, see it in the labs list, edit it, and view its details with instructions and submission data.

**Acceptance Scenarios**:

1. **Given** a TA is on the Labs screen, **When** they tap "Create Lab", **Then** they see a form with course selection, title, description, dates, max score, weight, and status
2. **Given** a TA sees a lab, **When** they tap "Edit", **Then** the form is pre-populated and they can save changes
3. **Given** a TA sees a lab, **When** they tap "View Submissions", **Then** they see all student submissions for that lab

---

### User Story 5 — TA Grades Lab Submissions (Priority: P2)

A TA opens a lab's submissions (section-scoped — only students from their assigned sections), selects a pending submission, and grades it with a score and feedback. The grade is saved and the lab submission status updates. The TA can also view all submission attempts with their scores. The TA reuses the existing Instructor lab grading screen components.

**Why this priority**: Lab grading is a core TA responsibility parallel to assignment grading. Without this, TAs cannot evaluate student lab work.

**Independent Test**: A TA can load lab submissions, select a pending submission, enter a score and feedback, save, and see the updated status.

**Acceptance Scenarios**:

1. **Given** a TA opens a lab, **When** they view submissions, **Then** they see all student submissions with name, date, status, and score
2. **Given** a TA selects a pending lab submission, **When** they enter a score (0 to maxScore) and feedback, **Then** the grade is saved and status updates
3. **Given** a TA has graded a lab submission, **When** they re-open it, **Then** they see their previous score and feedback for review or re-grading

---

### User Story 6 — TA Marks Lab Attendance (Priority: P2)

A TA opens a lab's attendance sheet (section-scoped — only students from their assigned sections), sees all enrolled students, and marks each student's attendance status (present, absent, excused, late). Attendance records are saved to the backend. The TA reuses the existing Instructor attendance sheet screen components.

**Why this priority**: Attendance tracking is part of lab management. TAs need this to maintain accurate records of student participation.

**Independent Test**: A TA can open attendance for a lab, mark statuses for students, save, and verify the records persist.

**Acceptance Scenarios**:

1. **Given** a TA opens a lab's attendance, **When** they view the sheet, **Then** they see all enrolled students with their current attendance status
2. **Given** a TA marks attendance for a student, **When** they save, **Then** the attendance record is persisted in the backend
3. **Given** a TA reopens attendance, **When** they view the sheet, **Then** they see previously saved attendance records

---

### User Story 7 — TA Uploads Lab Instructions and TA Materials (Priority: P3)

A TA adds text instructions and uploads files to a lab. They can also upload TA-only materials (answer keys, rubrics) that are visible only to instructors and TAs.

**Why this priority**: Supporting materials and instructions are needed for labs but are a secondary workflow compared to grading and CRUD.

**Independent Test**: A TA can add a text instruction to a lab, upload an instruction file, and upload a TA material file. Each upload is verifiable via API.

**Acceptance Scenarios**:

1. **Given** a TA is editing a lab, **When** they add a text instruction, **Then** it appears in the lab's instructions list
2. **Given** a TA uploads an instruction file, **When** the upload completes, **Then** the file is linked to the lab and visible to students
3. **Given** a TA uploads a TA material file, **When** the upload completes, **Then** the file is visible only to instructors and TAs

---

### Edge Cases

- What happens when a TA tries to create an assignment for a course they are not assigned to? The backend should reject the request with a 403 Forbidden response.
- How does the system handle a TA grading a submission that was already graded by another TA or instructor? The system should allow re-grading and show the previous grader's name and date.
- What happens when a TA tries to delete a lab that has existing student submissions? The backend should allow deletion but the frontend should warn about data loss.
- How does the system handle late lab submissions when the lab's due date has passed? The backend auto-marks `isLate` based on the submission timestamp.
- What happens when a TA tries to upload a file that exceeds the size limit? The frontend should validate file size before upload and show an error message.
- How does the system handle a TA whose assignment to a course was revoked mid-session? The TA should lose access to that course's data on next refresh.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display TA's assigned courses fetched from the backend via the teaching courses endpoint, with no mock or static data
- **FR-002**: System MUST provide 9 sub-tabs on the TA course detail screen: Overview, Sections & Labs, Lectures, Materials, Assignments, Grading, Attendance, Students, Announcements
- **FR-003**: System MUST allow TAs to create assignments with all required fields: title, description, instructions (markdown-supported), due date, max score, weight, submission type (text/file/link/any), max file size, allowed file types, late penalty percentage, and status
- **FR-004**: System MUST allow TAs to edit existing assignments, pre-populating all fields with current values
- **FR-005**: System MUST allow TAs to delete assignments with a confirmation dialog before deletion
- **FR-006**: System MUST display all assignment submissions for a given assignment with student name, email, submission date, attempt number, late indicator, score (if graded), and status
- **FR-007**: System MUST allow TAs to filter assignment submissions by status (All, Graded, Ungraded) and by lateness (All, Late, On Time)
- **FR-008**: System MUST allow TAs to grade assignment submissions by entering a score (0 to maxScore, step 0.5) and optional feedback text
- **FR-009**: System MUST save grades to the backend and update the submission status to "graded"
- **FR-010**: System MUST display TA's assigned labs fetched from the backend with no mock or static data
- **FR-011**: System MUST allow TAs to create labs with fields: course ID, title, description, available from date, due date, max score, weight, and status
- **FR-012**: System MUST allow TAs to edit existing labs, pre-populating all fields with current values
- **FR-013**: System MUST allow TAs to view lab submissions with student details, submission date, status, and score
- **FR-014**: System MUST allow TAs to grade lab submissions with a score (0 to maxScore, step 0.5), optional feedback, and a status field (submitted, graded, returned, resubmit)
- **FR-015**: System MUST allow TAs to mark lab attendance for enrolled students with status values: present, absent, excused, late
- **FR-016**: System MUST allow TAs to add text instructions to labs
- **FR-017**: System MUST allow TAs to upload instruction files to labs (visible to students)
- **FR-018**: System MUST allow TAs to upload TA-only materials to labs (visible only to instructors and TAs)
- **FR-019**: System MUST preserve the existing UI structure with at least 85% visual similarity — only mock/static data is removed, not layout, colors, or component structure
- **FR-020**: System MUST show empty states in UI spaces where mock data was previously displayed (no collapsed or missing UI sections when no data exists)
- **FR-021**: System MUST handle `isLate` as a number (0/1) for assignment submissions and as a boolean (true/false) for lab submissions
- **FR-022**: System MUST enforce role-based access — only users with the `teaching_assistant` role can access TA screens
- **FR-023**: System MUST support responsive layouts for mobile phones (< 600px), tablets (600px-1024px), and desktops (> 1024px)
- **FR-024**: System MUST maintain minimum 48x48px touch targets for all interactive elements

### Key Entities

- **Course**: An academic course the TA is assigned to. Has sections, schedules, enrolled students, and links to assignments and labs. TAs access course data at the section level, not the full course scope.
- **Section**: A specific offering of a course (time slot, location, instructor). TAs are assigned to specific sections and can only view/manage data for those sections.
- **Assignment**: A graded deliverable within a course section. Has a title, instructions, due date, max score, submission type, status, and associated student submissions. TAs manage assignments for their assigned sections.
- **Assignment Submission**: A student's work for an assignment. Has submission content (text, link, or file), status, score, feedback, late indicator, and attempt number. TAs only see submissions from students in their assigned sections.
- **Lab**: A practical deliverable within a course section. Has a title, description, instructions, due date, max score, status, attendance records, and associated student submissions. TAs manage labs for their assigned sections.
- **Lab Submission**: A student's work for a lab. Has submission content (text or file), status, score, feedback, late indicator, and submission date. TAs only see submissions from students in their assigned sections.
- **Lab Instruction**: An individual instruction item within a lab. Can be text or an uploaded file. Has an order index for sequencing.
- **Lab Attendance**: A record of a student's presence at a lab session. Has status (present, absent, excused, late) and timestamp. TAs mark attendance for students in their assigned sections.
- **Drive File**: A Google Drive file used for instruction documents, TA materials, or student submissions. Has drive ID, file name, preview URL, and download URL.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: TAs can view their assigned courses list from the backend in under 2 seconds on a standard mobile network connection
- **SC-002**: TAs can create an assignment with all fields and have it saved to the backend in under 3 seconds
- **SC-003**: TAs can grade a single assignment submission (enter score + feedback + save) and see the updated status in under 2 seconds
- **SC-004**: TAs can grade a single lab submission and see the updated status in under 2 seconds
- **SC-005**: All TA screens load with live API data with zero mock or static data present in production builds
- **SC-006**: Modified screens maintain at least 85% visual similarity to their pre-integration state as measured by pixel-diff comparison of layout structure
- **SC-007**: TAs can mark attendance for all students in a lab session and have all records saved in under 5 seconds
- **SC-008**: 95% of TA grading actions complete successfully without API errors on standard network conditions

## Assumptions

- TAs have stable internet connectivity when accessing the app (required for live API calls)
- The existing authentication system (JWT-based) is reused — no new auth mechanism is introduced
- The existing `CoreApiClient` (Dio-based) is reused for all HTTP requests
- The existing `AssignmentService` and `LabService` from Phase 1 provide the necessary backend endpoints
- The TA's role and section assignments are correctly set in the backend — the app does not need to verify or modify roles
- Google Drive integration (file upload, preview) is already configured in the backend and requires no additional setup on the mobile side
- All 9 TA course detail sub-tabs attempt live API data fetches; when endpoints or data are unavailable, structured empty states are shown instead of mock data. Undiscovered endpoints should be identified by inspecting the backend project at `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`
- TA assignment/lab CRUD reuses existing Instructor screen components (same forms, same validation, same UI). TA course list and course detail screens are new, built with modern, colorful UI matching existing TA screen design patterns
- Existing BLoC/Cubit architecture patterns from previous phases are reused for state management
- No new dependencies beyond those already in the project (youtube_player_flutter, webview_flutter, flutter_downloader, path_provider, shared_preferences, flutter_markdown, file_picker) are required for this phase
- The backend correctly enforces role-based and section-scoped access control — the frontend only needs to display appropriate error messages when access is denied
- TA data visibility is section-scoped by the backend — API responses already filter by the TA's assigned sections, so the frontend does not need additional client-side filtering for section scope
