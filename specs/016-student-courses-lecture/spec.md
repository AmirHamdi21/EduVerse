# Feature Specification: Student Courses & Lecture Viewer

**Feature Branch**: `016-student-courses-lecture`
**Created**: April 10, 2026
**Status**: Draft
**Input**: User description: "Phase 2: Student — Courses & Lecture Viewer - Read courses_assignments_labs_integration_plan.md, Courses_Assignments_Labs_Frontend_Documentation.md and COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md and create a specification for Phase 2"

## Clarifications

### Session 2026-04-10

- Q: How should navigation between course list → course detail → content view work? → A: Mixed approach: Course list uses stack navigation (tap → push detail). Course detail screen has tabs (Structure, Materials, Progress) for switching views within the same course context.
- Q: What should be the timeout threshold for API calls before showing error states? → A: 10 seconds for standard endpoints (courses, structure), 30 seconds for material-related calls (materials, view tracking).
- Q: How strict should bundle matching be when titles are similar but not identical? → A: Prefix match: strip text after first parenthesis, hyphen, or bracket, then compare remaining prefix (e.g., "Week 1 - Intro" and "Week 1 - Slides" both match "Week 1 ").

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Enrolled Courses List (Priority: P1)

As a student, I want to see my currently enrolled courses with live data from the backend so that I can access my active courses and their information.

**Why this priority**: This is the entry point for all course-related activities. Without seeing enrolled courses, students cannot navigate to course content, lectures, or materials. This is the foundation of the student course experience.

**Independent Test**: Can be fully tested by fetching enrolled courses from the API and displaying them in a list with course code, name, instructor, and schedule information. Delivers immediate value by showing students their real course roster.

**Acceptance Scenarios**:

1. **Given** the student is logged in and has enrolled courses, **When** they navigate to the Courses screen, **Then** they see a list of all their enrolled courses with course code, name, instructor name, and schedule details fetched from the backend API.

2. **Given** the student is logged in but has no enrolled courses, **When** they navigate to the Courses screen, **Then** they see a friendly message indicating no enrollments with guidance on how to browse available courses.

3. **Given** the student's enrollment data is loading, **When** they open the Courses screen, **Then** they see a loading indicator and the course list appears once the API responds.

4. **Given** the student taps on a course from the list, **When** the course detail screen opens, **Then** they see a tabbed interface with Structure, Materials, and Progress tabs within the same course context.

---

### User Story 2 - Browse Course Structure with Week-Based Accordion (Priority: P2)

As a student, I want to view my course's organized weekly structure with lectures and materials grouped by week so that I can navigate through the course content in a logical sequence.

**Why this priority**: Students need to understand how course content is organized over time. The week-based structure is critical for academic planning and helps students track their progress through the semester.

**Independent Test**: Can be fully tested by fetching course structure from `GET /courses/{id}/structure` and displaying materials grouped by week with expandable accordion sections. Delivers value by showing students the course organization.

**Acceptance Scenarios**:

1. **Given** the student has selected a course and is on the Structure tab, **When** they view the course content, **Then** they see materials organized by week in an expandable accordion layout with week numbers and titles.

2. **Given** a week section has multiple materials on the Structure tab, **When** the student expands that week, **Then** they see all materials for that week including videos, documents, and bundles with appropriate type indicators.

3. **Given** the course has no structured weeks yet, **When** the student views the Structure tab, **Then** they see a message indicating that course content has not been organized by the instructor yet.

---

### User Story 3 - Watch Lecture Videos (Priority: P3)

As a student, I want to watch lecture videos embedded from YouTube within the course content so that I can learn from video lectures without leaving the app.

**Why this priority**: Video lectures are a primary content delivery method in modern education. Students must be able to watch videos seamlessly as part of their learning workflow.

**Independent Test**: Can be fully tested by clicking a video material and having it play in an embedded YouTube player within the app. Delivers value by enabling video-based learning.

**Acceptance Scenarios**:

1. **Given** the student is viewing course materials and sees a video lecture, **When** they tap on it, **Then** the YouTube video plays in an embedded player with standard playback controls (play, pause, seek, fullscreen).

2. **Given** the student is watching a video on a mobile device, **When** they rotate to landscape, **Then** the video player adjusts to fill the wider screen appropriately.

3. **Given** the student's internet connection is slow, **When** they attempt to play a video, **Then** they see appropriate buffering indicators and can adjust video quality if the YouTube player supports it.

---

### User Story 4 - View and Download Course Documents (Priority: P4)

As a student, I want to preview course documents (PDFs, slides, handouts) inline via Google Drive preview and download them for offline access so that I can study course materials.

**Why this priority**: Documents are essential course materials. Students need both inline preview for quick reference and download capability for offline study.

**Independent Test**: Can be fully tested by clicking a document material and viewing it in an embedded Google Drive preview iframe, with an option to download. Delivers value by providing access to written course materials.

**Acceptance Scenarios**:

1. **Given** the student is viewing course materials and sees a document, **When** they tap on it, **Then** the document opens in an inline Google Drive preview showing the content without requiring external apps.

2. **Given** the student is previewing a document, **When** they tap the download button, **Then** the document downloads to their device with a success notification.

3. **Given** the student is on a mobile device with limited screen space, **When** they view a document preview, **Then** they can zoom and scroll through the document using touch gestures.

---

### User Story 5 - Track Material Views and See Progress (Priority: P5)

As a student, I want the system to track when I view course materials and show my viewing progress so that I can monitor my engagement with course content.

**Why this priority**: Progress tracking helps students stay organized and motivated. It also enables instructors to see engagement analytics.

**Independent Test**: Can be fully tested by viewing a material and confirming that a view is recorded via `POST /materials/{id}/view`, with a progress indicator updating on the UI. Delivers value through engagement visibility.

**Acceptance Scenarios**:

1. **Given** the student clicks to view a material (video or document), **When** the material opens, **Then** the system automatically records a view event and shows updated view count.

2. **Given** the student has viewed multiple materials in a week, **When** they look at the week section, **Then** they can see which materials they have already accessed.

---

### Edge Cases

- What happens when a YouTube video is deleted or made private? The system should show a clear error message indicating the video is unavailable.
- How does the system handle Google Drive documents that require additional permissions? The system should show an access denied message with instructions to contact the instructor.
- What happens when the student has no internet connectivity? The system should show cached course structure where available and display appropriate offline indicators with retry options.
- How does the system handle very large courses with 20+ weeks of materials? The accordion should lazy-load week sections to maintain performance.
- What happens when material metadata is incomplete (missing title, type, or URL)? The system should show placeholder content and log the issue for instructor review.
- What happens when an API call exceeds the timeout threshold (10s standard, 30s material-related)? The system should show a timeout error with a clear retry button and optional "Try again later" guidance.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch student's enrolled courses from `GET /enrollments/my-courses` and display course code, name, instructor, and schedule information
- **FR-002**: System MUST fetch course structure from `GET /courses/{id}/structure` and organize materials by week in an expandable accordion layout
- **FR-003**: System MUST fetch course materials from `GET /courses/{id}/materials` and display them with appropriate type indicators (video, document, link, etc.)
- **FR-004**: Users MUST be able to play embedded YouTube videos by clicking on video materials within the course content view
- **FR-005**: Users MUST be able to preview Google Drive documents inline using iframe-based preview for document materials
- **FR-006**: Users MUST be able to download course materials to their device for offline access
- **FR-007**: System MUST record material views via `POST /materials/{id}/view` when a student opens a material
- **FR-008**: System MUST display material metadata including view count, download count, and material type badges
- **FR-009**: System MUST group related materials into bundles when multiple materials share the same base title (video + companion documents). Bundle detection uses prefix matching: strip text after first parenthesis, hyphen, or bracket, then compare remaining prefix.
- **FR-010**: System MUST display YouTube video thumbnails (using `img.youtube.com/vi/{videoId}/mqdefault.jpg`) for video materials in list views
- **FR-011**: System MUST support responsive layouts that adapt appropriately at mobile (<600px), tablet (600px-1024px), and desktop (>1024px) breakpoints
- **FR-012**: System MUST maintain minimum 48x48px touch targets for all interactive elements on mobile and tablet views
- **FR-013**: System MUST display course progress indicators showing which materials the student has accessed
- **FR-014**: System MUST handle loading states with appropriate skeleton loaders or progress indicators during API calls
- **FR-015**: System MUST display user-friendly error messages when API calls fail (after 10s timeout for standard endpoints, 30s for material-related calls), with retry options
- **FR-016**: System MUST auto-select and expand the first week section when a student first views course content
- **FR-017**: System MUST support text scaling from 1.0x to 1.3x without layout breakage
- **FR-018**: System MUST cache course structure data locally to enable faster subsequent loads and basic offline viewing

### Key Entities

- **Course**: Represents an enrolled course with attributes including course code, name, instructor information, schedule details, and enrollment status. Related to CourseStructure and Materials.

- **CourseStructure**: Organizes course content into weeks with week numbers, titles, and associated structure items. Each structure item links to one or more materials. Has a one-to-many relationship with Materials through MaterialBundles.

- **CourseMaterial**: Represents individual course materials (videos, documents, links, text) with attributes including material type, title, external URLs (YouTube, Google Drive), publication status, view count, and download count. Can be standalone or part of a MaterialBundle.

- **MaterialBundle**: A logical grouping of related materials, typically a primary video with companion documents (slides, handouts, code). The bundle has a shared base title and displays materials as a cohesive unit with the video as the primary preview and documents as selectable companions. Bundles are detected using prefix matching: titles are normalized by stripping text after the first parenthesis, hyphen, or bracket, then compared for matches.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Students can view their enrolled courses list with live API data in under 2 seconds on a standard mobile connection
- **SC-002**: Students can navigate from course list to course content and expand any week section in under 3 seconds
- **SC-003**: 95% of students can successfully play a lecture video on the first attempt without errors
- **SC-004**: Students can preview a course document inline in under 2 seconds after tapping on it
- **SC-005**: All screens render correctly and are fully functional at 375px width (mobile portrait), 768px width (tablet portrait), and 1024px+ width (desktop)
- **SC-006**: All interactive elements maintain minimum 48x48px touch targets across mobile and tablet views
- **SC-007**: Students can complete the core workflow (view courses → select course → watch lecture) in 4 taps or fewer
- **SC-008**: Material view tracking records views with 99% accuracy (verified by comparing views logged vs. backend records)
- **SC-009**: Course content displays correctly for courses with up to 20+ weeks of materials without performance degradation (page remains at 60fps during scrolling)
- **SC-010**: 90% of students rate the course content viewing experience as "satisfactory" or better in user testing sessions

## Assumptions

- Students have stable internet connectivity for streaming video and loading documents from external services (YouTube, Google Drive)
- The existing authentication system (JWT Bearer tokens from `POST /api/auth/login`) is already implemented and functional
- Backend APIs documented in `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md` are fully operational and return data matching the documented schemas
- YouTube videos and Google Drive documents are publicly accessible or properly permissioned for enrolled students
- The app already has basic navigation, user profile management, and login functionality
- Video streaming quality and document preview rendering are handled by YouTube and Google Drive services respectively
- Course structure and materials are created and organized by instructors using the website or instructor features
- Mobile phones are the primary device, with tablet and desktop as secondary targets
- Students are already enrolled in courses through the enrollment system (course enrollment is out of scope for this phase)
- Material bundles are identified client-side using prefix matching on base titles; no explicit bundle ID exists in the backend
