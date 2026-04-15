# Feature Specification: Admin — Course Management

**Feature Branch**: `024-admin-course-mgmt`
**Created**: April 15, 2026
**Status**: Draft
**Input**: User description: "Read D:\Graduation\EduVerse\edu_verse\courses_assignments_labs_integration_plan.md, D:\Graduation\EduVerse\edu_verse\Courses_Assignments_Labs_Frontend_Documentation.md and  D:\Graduation\EduVerse\edu_verse\COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md and create a specification for the Phase 9: Admin — Course Management\n\nNote: the ui of the changes screens must be the same ( same colors same structure) but the static or mockup data only to be deleted with it space in the ui but the overall ui after each phase must be at least 85% of the past ui and follow the remaining ui of the app screens. see the rules in the constitution to understand more."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View and Filter Courses (Priority: P1)

As a Department Head (Admin), I want to view all courses and filter them by department or status so that I can easily find the course I need to manage.

**Why this priority**: Without the ability to list and find courses, the admin cannot perform any other management tasks. This is the entry point for the feature.

**Independent Test**: Can be fully tested by loading the course list and applying different filters to see the results update correctly.

**Acceptance Scenarios**:

1. **Given** the admin is on the course management dashboard, **When** the page loads, **Then** all existing courses are displayed fetched from the live API, with no static mockup data holding the space.
2. **Given** the admin is viewing the course list, **When** they apply a department or status filter, **Then** the list updates to show only courses matching the selected filters.
3. **Given** a search term is entered, **When** the search is executed, **Then** courses matching the search term by name or code are displayed.

---

### User Story 2 - Create Course Wizard (Priority: P1)

As an Admin, I want to use a 3-step wizard to create a new course, its sections, schedules, and assign staff, so that I can set up a complete course offering in one fluid process.

**Why this priority**: Course creation is the core capability for curriculum management.

**Independent Test**: Can be fully tested by going through the 3-step wizard and verifying the course, section, schedule, and staff are created in the backend.

**Acceptance Scenarios**:

1. **Given** the admin initiates course creation, **When** they fill out course details (step 1) and proceed, **Then** the system validates the input and advances to the section/schedule step.
2. **Given** the admin is on step 2, **When** they define section details (capacity, location) and schedule (day, time), **Then** the section and schedule are created.
3. **Given** the admin is on step 3, **When** they assign an instructor and TAs, **Then** the assignments are saved, and the full course setup is complete.

---

### User Story 3 - Edit and Delete Courses (Priority: P2)

As an Admin, I want to edit existing course details, sections, schedules, and staff assignments, and soft-delete courses, so that I can keep the curriculum up to date.

**Why this priority**: Curriculum changes frequently, requiring updates and removals of outdated courses.

**Independent Test**: Can be fully tested by modifying an existing course and verifying the changes persist, and soft-deleting a course and verifying it no longer appears in the active list.

**Acceptance Scenarios**:

1. **Given** the admin selects to edit a course, **When** they update the course details in the wizard, **Then** the changes are saved and reflected in the course list.
2. **Given** the admin selects to delete a course, **When** they confirm the deletion, **Then** the course is soft-deleted and removed from the active view.

---

### User Story 4 - Manage Student Enrollments (Priority: P2)

As an Admin, I want to manually enroll students, drop students from courses (even after deadlines), and approve retake requests, so that I can resolve enrollment issues and exceptions.

**Why this priority**: Admins need to handle edge cases and special requests that students cannot perform themselves.

**Independent Test**: Can be fully tested by manually enrolling a student, dropping a student past the deadline, and verifying the enrollment status updates.

**Acceptance Scenarios**:

1. **Given** the admin is viewing a section's student list, **When** they select to drop a student, **Then** the student's enrollment is successfully dropped, bypassing normal student deadlines.
2. **Given** a student needs to be enrolled manually, **When** the admin adds them to a section, **Then** the student is enrolled successfully.

---

### Edge Cases

- What happens when a course is deleted but has active student enrollments? (Soft deletion handles this gracefully, but UI should warn the admin)
- If the API fails during step 2 or 3 of the course creation wizard, the partially created course remains but its status is set to INACTIVE. The Admin can resume setup by editing the course later.

## Clarifications

### Session 2026-04-15
- Q: If the 3-step course creation wizard fails during Step 2 or 3, how should the frontend handle the partially created course? -> A: Course remains, but status is set to INACTIVE. Admin can edit it later.
- Q: How should the system behave if an admin manually enrolls a student into a section that has a schedule conflict? -> A: Warn but allow (save the enrollment after admin confirms the warning).
- Q: Maintain old 1-instructor UI or expand to multi-instructors per backend capabilities? -> A: Expand the UI to support multi-instructors and multi-TAs (Backend Parity).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the list of courses fetched from the backend API, preserving the existing UI layout and structure.
- **FR-002**: System MUST remove all static/mockup data from the course management screens while maintaining the UI spacing and overall structure.
- **FR-003**: System MUST provide a 3-step wizard for course creation: Course Details, Section & Schedule, and Staff Assignment.
- **FR-004**: System MUST allow editing of existing courses by pre-populating the 3-step wizard with live data.
- **FR-005**: System MUST allow admins to soft-delete courses after a confirmation prompt.
- **FR-006**: System MUST allow admins to manually enroll and drop students from sections, bypassing standard student deadlines or limitations, and MUST provide a warning override for schedule conflicts.
- **FR-007**: System MUST allow admins to assign and unassign multiple instructors (with specific roles like primary, co_instructor) and TAs to course sections, expanding the old single-instructor UI.
- **FR-008**: System MUST display 4 sub-tabs in the course management view: Courses, Staff, Schedule, and Exams.

### Key Entities

- **Course**: Represents an academic offering with code, name, department, credits, level, and status.
- **Section**: A specific instance of a course offered in a semester, with capacity and location.
- **Schedule**: The designated times and days a section meets.
- **Enrollment**: The link between a user (student, instructor, TA) and a course section.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Admins can successfully create a complete course (with section, schedule, and staff) in under 3 minutes using the wizard.
- **SC-002**: 100% of mock/static data is removed and replaced with dynamic data loading from the backend API.
- **SC-003**: Admins can successfully drop a student from a course past the standard drop deadline without system errors.

## Assumptions

- The backend API endpoints for course, section, schedule, and enrollment management are fully implemented and available.
- The existing UI components (like `AddCourseBottomBar` and `CourseDetailsForm`) can be refactored into a sequential 3-step wizard workflow without losing their visual design or intent.
- At least 85% of the visual UI elements from the mockup stages will be reusable for the dynamic versions.





