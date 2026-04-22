# Feature Specification: Instructor Screens & Widgets Integration

**Feature Branch**: `003-instructor-courses-integration`  
**Created**: 2026-04-05  
**Status**: Draft  
**Input**: User description: "Read courses_backend_integration_plan.md and create a specification for the Phase 3: Instructor Screens & Widgets Integration, also you can see the courses related info of the backend in the Flutter_Courses_API_Docs.md"

## Clarifications

### Session 2026-04-06

- Q: How should the `avgEngagement` metric be populated on the Instructor's Top Stats Board? → A: Option A - Hide/omit the `avgEngagement` stat from the UI for now until the backend supports it.
- Q: Does the `teaching` endpoint return an array of the exact same `EnrollmentModel` shape, or does it return a different data structure? → A: Option C - It returns a completely different `TeachingCourseModel` shape.
- Q: Should the system cache `TeachingCourseModel` data locally so the instructor can view their assigned courses when offline? → A: Option A - Yes, implement offline caching for the instructor courses (same as student parity).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Assigned Teaching Courses (Priority: P1)

As an instructor, I want to see a live list of courses and sections assigned to me, so that I can manage my teaching schedule and course materials.

**Why this priority**: Core functionality; instructors cannot perform any other tasks without seeing their courses first.

**Independent Test**: Can be fully tested by logging in as an instructor and verifying the dashboard displays data fetched from the backend API rather than mock data.

**Acceptance Scenarios**:

1. **Given** I am an authenticated instructor, **When** I navigate to the Instructor Courses screen, **Then** a loading indicator appears while data is fetched.
2. **Given** the fetch is successful, **When** the page renders, **Then** it accurately displays all assigned sections.
3. **Given** the fetch fails, **When** the data cannot be loaded, **Then** an error message is displayed with a retry button.

---

### User Story 2 - View Real-Time Course Stats (Priority: P2)

As an instructor, I want to see dynamic statistics for my courses (e.g., total enrolled students), so that I can quickly assess the status of my classes.

**Why this priority**: Essential for the Top Stats Board in the dashboard, replacing static placeholders with accurate metrics based on actual section enrollments.

**Independent Test**: Can be fully tested by verifying that numbers in the Top Stats Board match aggregated data from the connected backend models.

**Acceptance Scenarios**:

1. **Given** I am an instructor viewing the dashboard, **When** the assigned courses load, **Then** the Top Stats Board dynamically calculates and displays total students based on the current enrollment in assigned sections.

---

### Edge Cases

- What happens when an instructor has zero assigned courses? The system MUST display an empty state matching the UI theme.
- How does the system handle a failed network request when fetching teaching courses? The system MUST fall back to cached local data if available. If no cache exists, it MUST show an error state and provide a retry mechanism.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch the instructor's assigned courses from the corresponding backend endpoint.
- **FR-002**: System MUST dynamically calculate the Top Stats Board values (e.g., total students) using the data stream from the backend.
- **FR-003**: System MUST manage UI states (loading, loaded, error) during data fetching operations.
- **FR-004**: System MUST transition instructor course data representation to use the newly defined `TeachingCourseModel`.
- **FR-005**: System MUST implement offline caching for the fetched teaching courses to allow the instructor to view their assigned sections without internet connectivity.

### Key Entities *(include if feature involves data)*

- **Teaching Course Entity**: Represents the mapping of the instructor to their assigned sections, streamlining data by excluding student-specific enrollment details.
- **Course Entity**: The main course data (name, code, credits).
- **Section Entity**: Contains the current enrollment and capacity details used for stats calculations.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Instructor dashboard renders 100% of courses from the live backend API instead of static mock files.
- **SC-002**: Top Stats Board accurately reflects the sum of enrolled students from all assigned sections.
- **SC-003**: Application encounters 0 crashes when network errors occur, correctly displaying error UI instead.

## Assumptions

- Authentication and base domain models setup from earlier phases are already complete and functional.
- The backend endpoint for instructor courses returns data structurally mapping to the unified course and section models.
