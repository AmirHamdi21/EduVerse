# Feature Specification: Student Courses Phase 1 - Design System Foundation and Courses Shell

**Feature Branch**: `025-courses-shell-foundation`  
**Created**: April 16, 2026  
**Status**: Draft  
**Input**: User description: "Read C:\Users\Friends\Desktop\Graduation\EduVerse\Student_Courses_UI_Redesign_Documentation_Plan.md and create a specification for the Phase 1: Design System Foundation & Courses Screen Shell. Also enforce backend endpoint investigation using C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend, including required/optional request parameters and exact response shapes, and update related models/services/UI bindings when needed."

## Clarifications

### Session 2026-04-16

- Q: Should Phase 1 include new Join Course flow UX, or keep current behavior while only auditing related endpoints? → A: Keep Join Course behavior unchanged in Phase 1 (visual redesign only), and audit related endpoints without adding new join-flow UI.
- Q: Should filters and other backend-integrated behaviors be changed to strictly follow backend response shape and request parameters? → A: Yes. Filters and all backend-integrated behaviors MUST follow backend response shape and parameters, and UI options MUST be adjusted accordingly.
- Q: Should Phase 1 use backend-first model/service parsing with minimal temporary compatibility, and should the new UI strictly match the Phase 1 redesign plan? → A: Yes. Use backend-first parsing now and keep only minimal temporary compatibility where needed to avoid breakage, and the new UI MUST match the Phase 1 redesign specification in Student_Courses_UI_Redesign_Documentation_Plan.md.
- Q: How should `401`/`403` responses be handled for enrolled-courses endpoints? → A: Show a dedicated auth/session state with a clear message and re-authenticate action, instead of treating it as a generic network error.
- Q: Should Phase 1 include a semester filter control in the UI because `/api/enrollments/my-courses` supports `semester`? → A: Yes. Add a semester filter control in Phase 1 and wire it to the backend `semester` query parameter.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View My Courses in the Redesigned Shell (Priority: P1)

As a student, I want to open my courses screen and immediately see my enrolled courses in the redesigned layout so I can understand my current academic workload at a glance.

**Why this priority**: This is the core value of the phase. Without the main course shell and live data rendering, the redesign does not deliver user value.

**Independent Test**: Sign in as a student with active enrollments, open the courses screen, and verify the redesigned shell renders live data, loading state, and fallback states without static mock lists.

**Acceptance Scenarios**:

1. **Given** an authenticated student has enrolled courses, **When** the courses screen is opened, **Then** the redesigned shell displays those courses from the backend and not from static data.
2. **Given** the initial fetch is still in progress, **When** the screen is opened, **Then** the user sees a loading shell that preserves the final layout structure.
3. **Given** no enrolled courses are returned, **When** data loading completes, **Then** the user sees a dedicated empty state that preserves the page structure and calls to action.

---

### User Story 2 - Find Courses with Search, Filter, and Sort (Priority: P1)

As a student, I want to search, filter, and sort my course list in the redesigned shell so I can quickly locate the course I need.

**Why this priority**: Discoverability is a primary task on this screen and directly impacts time-to-task for students.

**Independent Test**: Use a dataset with mixed statuses, names, and credits; apply search/filter/sort controls independently and verify each operation updates visible results correctly.

**Acceptance Scenarios**:

1. **Given** multiple courses are displayed, **When** a search query is entered, **Then** only matching courses remain visible.
2. **Given** backend-supported status values for the enrolled-courses endpoint, **When** a status filter is selected, **Then** the UI only offers backend-supported statuses and applies filtering against those returned values.
3. **Given** the student selects a semester in the semester filter control, **When** the list is refreshed, **Then** the screen fetches and displays courses using the selected backend `semester` parameter.
4. **Given** a sort option is selected, **When** the list is refreshed, **Then** courses are presented in the selected order consistently.

---

### User Story 3 - Recover from Network and Data Variations (Priority: P2)

As a student, I want clear feedback when the network fails or results are temporarily unavailable so I can recover quickly without confusion.

**Why this priority**: Reliability and confidence are essential for academic workflows; users need clear recovery actions.

**Independent Test**: Simulate offline, cached-data, and backend-failure conditions; verify the screen shows the correct state and allows retry.

**Acceptance Scenarios**:

1. **Given** the backend request fails and cached data exists, **When** the screen is opened, **Then** cached results are shown with an offline warning.
2. **Given** the backend request fails and no cached data exists, **When** loading ends, **Then** a dedicated error state with retry action is shown.
3. **Given** user filters produce no matches, **When** the controls are applied, **Then** a no-results state appears with a one-action reset path.
4. **Given** the backend responds with `401` or `403`, **When** the courses request fails, **Then** the screen shows a dedicated auth/session state with an explicit action to re-authenticate.

---

### User Story 4 - Keep Visual Continuity During Redesign (Priority: P2)

As a student, I want the redesigned courses shell to feel consistent with the existing app so the new design is clearer without feeling unfamiliar.

**Why this priority**: Phase 1 must improve visual quality while preserving expected navigation and usability patterns.

**Independent Test**: Compare before/after screenshots for the screen shell and verify structure, spacing intent, and continuity thresholds are preserved while applying the new design system tokens.

**Acceptance Scenarios**:

1. **Given** the redesigned shell is implemented, **When** visual review is performed, **Then** major layout structure remains recognizable while using the updated design tokens.
2. **Given** dark and light themes are supported, **When** theme is toggled, **Then** all shell components maintain legibility and consistent hierarchy.

### Edge Cases

- Backend returns enrollment items with missing nested course/section/semester fields.
- Backend status values evolve or differ from prior UI expectations; filters must still align to audited backend-supported values without stale hardcoded options.
- Selected semester returns an empty list while other semesters contain courses; UI must clearly distinguish this from global no-courses state.
- Authentication is valid but role is not student; access must fail predictably.
- Access token is expired or invalid; UI must show auth/session recovery action instead of generic retry-only error.
- Network is unstable and the first fetch fails but retry succeeds.
- Search/filter/sort controls are changed rapidly during a loading-to-loaded transition.

## Clarification Evidence *(mandatory)*

- **Clarification Count**: 12
- **Resolved Questions Summary**:
  - Q1: Is Phase 1 limited to shell and design foundation only? -> Yes. Course card redesign and deeper details are excluded from this phase.
  - Q2: Should live data source change for this phase? -> No. Continue using student enrollments as the primary source.
  - Q3: Which role is in scope? -> Student role only for this phase.
  - Q4: Should join action behavior be redesigned now? -> No behavioral redesign; preserve existing entrypoint behavior while restyling shell button.
  - Q5: Should a semester filter UI control be included in Phase 1 because the backend supports `semester`? -> Yes. Add and wire a semester filter control to the backend parameter.
  - Q6: How should missing nested fields be handled? -> Keep resilient rendering with safe fallbacks and non-crashing states.
  - Q7: How should offline with cache be handled? -> Show cached list plus explicit offline warning.
  - Q8: How should offline without cache be handled? -> Show dedicated error state with retry action.
  - Q9: Should empty-data and filter-no-results share one state? -> No, keep them distinct for clarity.
  - Q10: When must static fallback data be removed? -> In the same phase where live integration succeeds for modified files.
  - Q11: How should logic complexity be controlled? -> Keep non-trivial transforms in named, testable functions instead of monolithic view methods.
  - Q12: How deep must backend inspection go? -> For each related endpoint, verify method/path, auth/roles, required/optional params, and exact response shape from backend source.
- **Open Questions**: None

## Backend Endpoint Contract Audit *(mandatory for backend-integrated features)*

| Endpoint | Method | Consumer (Screen/BLoC/Service) | Required Params | Optional Params | Response Shape Notes |
|----------|--------|--------------------------------|-----------------|-----------------|----------------------|
| `/api/enrollments/my-courses` | GET | Student Courses shell data source | Bearer token, authenticated `student` role | `semester` query number | Returns array of enrollment records containing top-level enrollment fields and nested `course`, `section`, `semester`, with optional `instructor` and `prerequisites`; service currently selects active/completed enrollment records for this view. |
| `/api/enrollments/available` | GET | Join-course endpoint audit only for Phase 1 (no new join UX behavior) | Bearer token, authenticated `student` role | `departmentId`, `semesterId`, `search`, `level`, `page`, `limit` | Returns available course options including sections, prerequisite summaries, and enrollment eligibility indicators. |
| `/api/enrollments/register` | POST | Join-course endpoint audit only for Phase 1 (no new join UX behavior) | Bearer token, authenticated `student` role, request body with `sectionId` (number >= 1) | None | Returns enrollment response payload aligned with student enrollment representation. |

**Audit Source Paths**:
- `Student_Courses_UI_Redesign_Documentation_Plan.md`
- `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\controllers\enrollments.controller.ts`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\services\enrollments.service.ts` (including response-construction methods `buildEnrollmentResponse`, `buildInstructorEnrollmentView`, and `buildInstructorResponse`)
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enrollment-response.dto.ts`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\available-courses.dto.ts`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enroll-course.dto.ts`

**Response Mapper Verification Scope (Phase 1)**:
- Endpoint contract audit MUST inspect response-construction logic in addition to controllers/services/DTO signatures.
- For enrollments, mapper verification MUST include `buildEnrollmentResponse`, `buildInstructorEnrollmentView`, and `buildInstructorResponse` in `enrollments.service.ts`.
- Contract output MUST include mapper-to-model field evidence (`backend response field -> Flutter model/property`) for every consumed field in this page scope.

**Semester Option Source Decision (Phase 1)**:
- Semester selector options MUST be derived from `enrollment.semester` fields returned by `/api/enrollments/my-courses`.
- Phase 1 MUST NOT depend on a separate `/semesters` endpoint for student Courses shell rendering.
- If semester metadata is missing from returned enrollments, the UI MUST show `All Semesters` only and preserve valid query behavior.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST deliver a redesigned student courses shell for Phase 1 that preserves existing primary course-list behavior.
- **FR-002**: The system MUST render course shell data from live backend enrollment data, not from static or mock course lists.
- **FR-003**: The system MUST provide distinct states for loading, loaded, empty, filtered-no-results, and error outcomes.
- **FR-004**: The system MUST allow students to search visible courses using case-insensitive matching over `course.code`, `course.name`, `section.sectionNumber`, and `semester.name`, and optional instructor full name when present, with deterministic precedence: exact/prefix code match first, then title contains, then section/semester/instructor contains.
- **FR-005**: The system MUST allow students to filter courses by backend-supported enrollment statuses, with deterministic mapping only for statuses present in audited endpoint responses.
- **FR-006**: The system MUST allow students to sort visible courses by title, credit load, and enrollment recency.
- **FR-007**: The system MUST implement the Phase 1 courses-shell UI to match the design requirements documented in `Student_Courses_UI_Redesign_Documentation_Plan.md` (including layout structure, spacing intent, visual states, and token usage).
- **FR-008**: The system MUST preserve existing localization behavior for courses shell headings, subtitles, and control hints.
- **FR-009**: The system MUST show an explicit offline warning when cached content is presented due to connectivity failure.
- **FR-010**: The system MUST provide an immediate retry pathway from error states without forcing user navigation away from the screen.
- **FR-011**: The system MUST remove static/mock/fallback data paths from all modified Phase 1 files once live integration is confirmed.
- **FR-012**: The system MUST perform a page-level endpoint contract audit against `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend` before phase completion.
- **FR-013**: The system MUST capture required and optional request parameters, exact response shapes, and response-construction mapper methods for each endpoint used by this page.
- **FR-014**: The system MUST update affected models, service mappings, or UI bindings when endpoint contracts and current client parsing differ, and document mapper-to-model field evidence for each changed mapping.
- **FR-015**: The system MUST keep non-trivial filtering, sorting, and status-derivation logic in named testable functions.
- **FR-016**: The system MUST keep Join Course behavior unchanged in Phase 1 (visual redesign only), while still auditing related enrollment endpoints for required/optional parameters and response shape compatibility.
- **FR-017**: The system MUST adjust or remove integration-dependent UI options when they are not supported by audited backend response shape or request parameters.
- **FR-018**: The system MUST prioritize audited backend contracts for parsing and parameter handling, and allow only minimal temporary compatibility logic needed to prevent runtime breakage during transition.
- **FR-019**: The system MUST handle `401`/`403` responses with a dedicated auth/session state and re-authentication action, distinct from generic network-error handling.
- **FR-020**: The system MUST include a semester filter control in Phase 1 and pass the selected value through the backend `semester` query parameter for enrolled-courses fetches.
- **FR-021**: The system MUST enforce widget-level role-based access control for the Courses screen and controls, and render an authorization-restricted state for authenticated users without student access.
- **FR-022**: The system MUST source semester filter options from `enrollment.semester` values in `my-courses` responses; when absent, the UI MUST fall back to `All Semesters` only without crashes.

### Key Entities *(include if feature involves data)*

- **Student Course Enrollment View Item**: Represents one enrolled course record as seen by the student, including enrollment metadata and nested course, section, and semester context.
- **Courses Shell View State**: Represents the user-visible screen state (loading, loaded, cached-offline, empty, no-filter-results, error) and the transitions among them.
- **Course List Controls State**: Represents search text, selected filter, and selected sort options that shape the rendered list.
- **Endpoint Contract Record**: Represents audited endpoint details including auth scope, required vs optional inputs, and canonical response field expectations.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of Phase 1 modified files in the student courses shell contain no static/mock/fallback course data paths after completion.
- **SC-002**: In acceptance testing, at least 95% of first-attempt course screen loads for authenticated students show a valid state (loaded, empty, cached-offline, or error) without crashes.
- **SC-003**: Using the benchmark protocol defined in `quickstart.md` (standard dataset + target device profile), search/filter/sort interactions achieve p50 <= 2.0s and p95 <= 10.0s.
- **SC-004**: Error-state recovery succeeds within one manual retry for at least 90% of transient-failure test runs.
- **SC-005**: Visual parity audit records a similarity score >= 85% using required before/after screenshot pairs and checklist scoring protocol defined in `quickstart.md`.
- **SC-006**: Endpoint audit documentation for this page includes all in-scope endpoints with required/optional parameters and response-shape notes before planning closes.
- **SC-007**: In authentication-failure tests, 100% of `401`/`403` responses for courses-shell fetches display the dedicated auth/session recovery state rather than a generic network error state.
- **SC-008**: In semester-filter tests, selecting a semester results in requests using the `semester` parameter and returns semester-scoped results with correct empty-state behavior.
- **SC-009**: Website parity audit matrix for Phase 1 shell components and fields records 100% pass for all in-scope parity checks before phase closure.

## Assumptions

- Primary flow targets authenticated students, but the screen MUST still handle authenticated non-student roles via explicit widget-level access restriction behavior.
- Phase 1 scope is limited to design foundation and courses shell; deeper course-card redesign belongs to the next planned phase.
- Existing backend enrollment endpoints remain available at stable paths and continue returning arrays for student enrollments.
- Join-course flow behavior is preserved as-is in Phase 1; full enrollment-flow UX changes are handled in a later phase.
- Existing localization keys for the student courses screen remain valid and reusable during the redesign.
