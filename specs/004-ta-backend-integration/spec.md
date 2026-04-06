# Feature Specification: TA Backend Integration

**Feature Branch**: `004-ta-backend-integration`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "Read courses_backend_integration_plan.md and create a specification for the Phase 4: TA (Teaching Assistant) Screens & Widgets Integration"

## Clarifications

### Session 2026-04-06

- Q: Should the TA UI proactively hide or disable destructive actions compared to the Instructor dashboard? → A: Proactively hide/disable unauthorized edit actions in the UI

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Assigned Courses List (Priority: P1)

As a Teaching Assistant, I want to see a list of courses I am assigned to assist with, so that I know which courses require my attention.

**Why this priority**: It is the foundational view for the TA role. Without seeing assigned courses, the TA cannot perform any course-specific duties.

**Independent Test**: Can be fully tested by logging in as a TA and ensuring the dashboard lists exact assigned courses returned from the backend `/api/enrollments/ta` (or equivalent) endpoint.

**Acceptance Scenarios**:

1. **Given** I am logged in as a TA, **When** I navigate to my Courses dashboard, **Then** I see the list of courses fetched from the live API, avoiding any static mock data.
2. **Given** I have no assigned courses, **When** I view the courses list, **Then** I see a "no courses assigned" empty state.

---

### User Story 2 - Access Live Course Sub-tabs (Priority: P1)

As a Teaching Assistant, I want to view dynamic data within the course's sub-tabs (Overview, Labs, Grading, Discussions), so that I can see real-time updates and metrics for the section I'm assisting.

**Why this priority**: Displaying accurate data context inside the course is the core value proposition of backend integration for the TA dashboard.

**Independent Test**: Can be tested by selecting a course from the list and verifying that the sub-tabs populate their fields via the injected BLoC model instance, with no legacy placeholder text.

**Acceptance Scenarios**:

1. **Given** I am viewing an assigned course, **When** I switch between Overview, Grading, Labs, and Discussions tabs, **Then** all statistics and details correspond to the live backend data.
2. **Given** the backend is slow or loading, **When** I open a course tab, **Then** I see a loading indicator until the BLoC state is `loaded`.

---

### User Story 3 - Interact with Course Materials (Priority: P2)

As a Teaching Assistant, I want to distinguish between material types (Video, Document, Quiz) and be able to open or download them, so that I can review the content provided to the students.

**Why this priority**: Essential for TA duties involving verifying content, though slightly less critical than seeing the overview and metrics.

**Independent Test**: Can be tested by clicking on different material items in a course and verifying that the app correctly identifies the component and launches the associated URL.

**Acceptance Scenarios**:

1. **Given** a course contains mixed materials, **When** I view the course structure, **Then** items are correctly labeled as Videos, Documents, or Quizzes based on backend data.
2. **Given** I click a downloadable document material, **When** the external action triggers, **Then** the app uses robust fallback logic (like `url_launcher`) to open the `fileId` or URL securely.

---

### User Story 4 - Trigger Action Handlers (Priority: P2)

As a Teaching Assistant, I want to use Quick Actions inside the course page to jump to grading or scheduling, so that I can quickly perform my administrative tasks.

**Why this priority**: Enhances usability and speed but isn't part of the core data rendering loop.

**Independent Test**: Can be tested by tapping any available quick action and observing if the correct backend route abstraction or specific sub-screen is initiated.

**Acceptance Scenarios**:

1. **Given** I look at the Quick Actions menu in a course, **When** I trigger an action, **Then** it hits the proper app route that corresponds to the backend capabilities for my role.

## Edge Cases

- What happens when a network error occurs while fetching the assigned courses? The app should display a user-friendly error state with a retry button instead of a crash.
- How does the system handle an assigned course that lacks any material or structural details? It should gracefully show "No Content Yet" indicators without rendering broken UI cards.
- What happens if the `url_launcher` fails to find an application that can open the given external URL or file? The system will need to display an actionable error message ("Cannot open link").

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST retrieve and display only the courses assigned to the authenticated TA.
- **FR-002**: System MUST use global, reusable models (e.g., `TeachingCourseModel`) through the application's BLoC state management to pass data to TA sub-tabs.
- **FR-003**: System MUST identify and correctly display course material types based on the backend `organizationType` field.
- **FR-004**: System MUST successfully delegate file/link openings to the OS using `url_launcher` or standard external intents.
- **FR-005**: System MUST cleanly transition all layout containers in `ta_course_overview_tab.dart`, `ta_course_grading_tab.dart`, etc., to use dynamic object data rather than static constants.
- **FR-006**: System MUST proactively hide or disable destructive/unauthorized edit actions in the UI if the current user profile is a TA without specific elevated permissions.

### Key Entities

- **TA Assigned Course**: Represents a section of a course assigned to the TA. Inherits shape from the newly unified `TeachingCourseModel`.
- **Course Material**: Represents the individual structural content item mapping to `organizationType` (Video, Document, Quiz).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of hardcoded mockup data instances are removed from the TA course dashboard and sub-tab widgets.
- **SC-002**: The TA Course list strictly correlates to the same assigned list seen on the existing Web Frontend for an equivalent user.
- **SC-003**: Clicking an external material link opens successfully on the first attempt without UI freezes or crashes.

## Assumptions

- Universal domain models (`TeachingCourseModel`, `EnrollmentModel`) from Phase 1 are fully merged and available.
- The `CoursesBloc` handles role-based discrimination correctly and can emit a cleanly filtered state for the TA.
- The user's authentication and base URL configuration are already reliably set up.
- The TA endpoints follow the same DTO pattern mapped in the Web Frontend API responses.
