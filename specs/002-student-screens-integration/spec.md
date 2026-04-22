# Feature Specification: Student Screens & Widgets Integration

**Feature Branch**: `002-student-screens-integration`  
**Created**: 2026-04-05  
**Status**: Draft  
**Input**: User description: "Read courses_backend_integration_plan.md and create a specification for the Phase 2: Student Screens & Widgets Integration"

## Clarifications

### Session 2026-04-05
- Q: Do we need to implement infinite scrolling for the student courses list, or does the API return all enrollments at once? → A: Single Payload (assume all courses arrive at once).
- Q: How should the application communicate to the student that they are viewing cached data after a failed network refresh? → A: Snackbar Warning ("Offline: Showing cached data").
- Q: If the web frontend/API does not provide a course thumbnail, what should the Flutter app display on the course card? → A: Initials Placeholder (Course Code on a solid color).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Enrolled Courses (Priority: P1)

As a student, I want to see my actual live enrolled courses on my dashboard and courses screen so that I can see the real representation of my classes instead of static mockups.

**Why this priority**: Viewing enrolled courses is the core functionality of the student dashboard. Without this, no other dynamic features matter.

**Independent Test**: Can be fully tested by opening the student courses list screen. It should display the live data from the server.

**Acceptance Scenarios**:

1. **Given** the student is logged in, **When** they navigate to the Courses screen, **Then** a loading indicator appears while data is fetched.
2. **Given** the courses are fetched successfully, **When** the screen renders, **Then** a list of the student's actual courses is displayed.
3. **Given** the network request fails, **When** the error is caught, **Then** an error message or cached courses are displayed as a fallback.
4. **Given** the student has no enrolled courses, **When** the fetch is complete, **Then** an "empty state" message is displayed.

---

### User Story 2 - Filter and Sort Live Courses (Priority: P2)

As a student, I want to filter and sort my enrolled courses based on live data categories (e.g., active, completed, progress) so that I can easily find the course I need.

**Why this priority**: Required for usability when students have multiple courses. Relies heavily on migrating away from static mockups to backend-derived statistics.

**Independent Test**: Tested by applying a filter (e.g., "Active") to the populated live courses list and verifying only matching courses remain.

**Acceptance Scenarios**:

1. **Given** the list of live courses is loaded, **When** the user applies a filter, **Then** the list updates dynamically based on the course properties.
2. **Given** the list of live courses is loaded, **When** the user sorts the list, **Then** the sorting uses actual calculated progress metrics or status flags from the backend data.

---

### User Story 3 - View Live Course Details (Priority: P3)

As a student, I want to tap on a course card and see its course details populated by the live API, so that I can prepare for browsing the structure and materials securely.

**Why this priority**: Connects the list view and the detail view, seamlessly passing the appropriate live course information downward.

**Independent Test**: Can be tested by clicking a course in the list and verifying the details screen renders without crashing, using the dynamic data.

**Acceptance Scenarios**:

1. **Given** the student is viewing the courses list, **When** they tap on a course, **Then** the app navigates to the details screen, passing the selected live course.
2. **Given** the student is on the details screen, **When** they view the header, **Then** the title, code, credits, and instructor information correctly match the live course selected.

### Edge Cases

- **Offline Refresh**: If a user attempts to refresh the course list while offline and the network fails, the app briefly displays a Snackbar warning ("Offline: Showing cached data") and continues showing the cached list.
- **Missing Course Imagery**: If a course lacks a provided thumbnail image, the UI generates a placeholder displaying the Course Code (e.g., "CS101") on a solid colored background.
- **Pagination Strategy**: The backend is assumed to return all enrolled courses in a single payload. Infinite scrolling logic is not implemented for the student dashboard.
- How does the UI handle courses with extremely long titles or missing optional descriptions?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch and display enrolled courses using the live system instead of static mockups.
- **FR-002**: System MUST render course cards dynamically using live data.
- **FR-003**: System MUST update generic display components (such as filter bars, list views, and sort widgets) to rely on properties coming from the live domain model representation.
- **FR-004**: System MUST intercept state changes (loading, loaded, error) and reflect them accurately in the UI.
- **FR-005**: System MUST perform in-memory filtering and sorting based on live data locally on the UI layer.
- **FR-006**: System MUST strictly mirror the data presentation, structure, and fields displayed in the existing integrated React web frontend (`Eduverse-Frontend`) to ensure cross-platform parity.
- **FR-007**: System MUST exclusively use the unified domain models recently established in the project (retrieved via existing API integrations) to populate the UI, rather than creating new custom structures.

### Key Entities 

- **Live Course**: The representation of the course returned from the backend.
- **Course Enrollment**: The linkage between the student and a specific course.
- **Courses State**: The current status of the data fetch process (e.g. idle, fetching, loaded, processing error).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of static dummy data models are removed from the student experience.
- **SC-002**: Student dashboard and courses screen load seamlessly using remote data within 2 seconds of the backend response.
- **SC-003**: No UI crashes occur when displaying empty course titles, descriptions, or null instructor fields due to missing backend data.
- **SC-004**: Users can filter their enrolled courses and the UI reflects the filtered selection instantly (under 100ms response time).

## Assumptions

- The central system for user enrollments is fully functional and reachable.
- The global data flow architecture established in previous phases is operating flawlessly.
- Image assets or default generic images exist to replace any missing online images gracefully on course cards.
- The system will handle offline states utilizing the caching strategies established previously.
