<!--
SYNC IMPACT REPORT
- Version Change: 3.0.0 → 4.0.0 (MAJOR — new feature domain: Courses/Assignments/Labs)
- Modified Principles:
  - I. BLoC State Management First — unchanged
  - II. Strict Data Layer Separation — expanded: added AssignmentService, LabService, SectionService, ScheduleService, MaterialService; added file upload via Dio FormData rules
  - III. Type Safety & Error Handling — expanded: added isLate int/bool divergence, allowedFileTypes JSON-string parsing, decimal field parsing, PaginatedResponse generic
  - IV. Website Feature Parity — expanded: added Courses_Assignments_Labs_Frontend_Documentation.md as source of truth
  - V. Testable Architecture — unchanged
  - VI. Real-Time Communication Integrity — unchanged (still applies to chat)
  - VII. Static Data Elimination — expanded: added courses/assignments/labs mock targets
  - VIII. Aggressive Clarification — expanded: added file upload, grading, attendance clarification areas
- Added Principles:
  - IX. Role-Based Access Control Enforcement (new: UI gating per role matrix)
  - X. File Upload & Google Drive/YouTube Integration (new: FormData, progress, preview rules)
  - XI. Multi-Phase Plan Adherence (new: phase gating against integration plan)
- Added Sections:
  - "Courses, Assignments & Labs Integration Constraints" (replaces chat-only scope)
  - "Role-Based UI Enforcement Matrix" (new table: 15 features × 5 roles)
  - "File Upload & Preview Policy" (new: validation, progress, rendering rules)
  - "Static Data & Mock Removal Policy" (new: 4-step audit process)
- Removed Sections: None
- Templates Requiring Updates:
  - ✅ plan-template.md — Constitution Check updated to reference new principles IX, X, XI
  - ✅ spec-template.md — No changes needed (generic structure)
  - ✅ tasks-template.md — No changes needed (generic structure)
- Follow-up TODOs: None
-->
# EduVerse Flutter Backend Integration Constitution

## Core Principles

### I. BLoC State Management First
All UI state MUST be driven exclusively by reactive BLoC or Cubit classes.
Widgets MUST never perform raw data fetching, direct API calls, or WebSocket
event processing. All network and socket interactions MUST flow through a
dedicated service layer, with results surfaced to the UI solely via
`BlocBuilder`, `BlocConsumer`, or `BlocListener` state transitions
(`loading`, `loaded`, `error`, `connectionStatus`). WebSocket event streams
(e.g., `new_message`, `user_typing`, `message_deleted`) MUST be subscribed
to inside the BLoC/Cubit `init` lifecycle and MUST emit new states — never
directly mutate widget state.

### II. Strict Data Layer Separation
Domain models MUST be strictly separated from raw API response handling.
Every feature starts with strongly-typed Dart models that mirror the exact
backend API response shapes **and** the React website frontend type
interfaces to guarantee cross-platform field parity. The Repository pattern
MUST be utilized through services (e.g., `CourseService`,
`EnrollmentService`, `MaterialService`, `AssignmentService`, `LabService`,
`SectionService`, `ScheduleService`, `SemesterService`, `ChatService`,
`ChatSocketService`, `DiscussionService`). REST services MUST extend or
compose `CoreApiClient` with Dio. WebSocket services MUST be singletons
managing their own connection lifecycle and exposing typed `Stream`s
consumed by BLoCs.

File uploads MUST use `Dio.FormData` with `MultipartFile.fromFile()` and
MUST NOT manually set the `Content-Type` header (Dio auto-generates the
multipart boundary). Upload progress MUST be tracked via
`onSendProgress` and surfaced to the UI through BLoC state emissions.

### III. Type Safety & Error Handling
All API and WebSocket interactions MUST guarantee type safety and gracefully
handle errors. Models MUST use robust `factory` methods for JSON parsing
with safe fallbacks. Network failures, WebSocket disconnections, parsing
errors, and missing relationships MUST fail predictably and bubble up safe
error states to the UI rather than throwing unhandled exceptions. For
real-time features: optimistic UI updates (e.g., appending a sent message
immediately) MUST include deduplication logic to reconcile with
server-confirmed events, and MUST fall back to REST endpoints when the
WebSocket is disconnected.

**Courses/Assignments/Labs-specific parsing rules:**
- `lateSubmissionAllowed` (assignments) is `TINYINT(1)` — parse as
  `(value as num) == 1`, NOT as `bool`.
- `isLate` in assignments arrives as `0`/`1` (number); in labs it arrives
  as `true`/`false` (boolean). Models MUST handle both via a safe parser.
- `allowedFileTypes` is a **JSON string** (e.g., `"[\"pdf\",\"zip\"]"`)
  — parse with `jsonDecode()`, NOT treat as a `List` directly.
- `maxScore`, `weight`, `latePenaltyPercent`, `score` are decimal numbers
  that may arrive as strings from some DB drivers — always parse with
  `double.tryParse(value.toString())`.
- Paginated responses MUST be deserialized into a typed
  `PaginatedResponse<T>` with `hasNextPage` / `hasPreviousPage` computed
  properties.

### IV. Website Feature Parity
The Flutter mobile app MUST achieve strict 1:1 feature parity with the
EduVerse React website frontend for every integrated feature.

**Parity rules:**
- If a feature EXISTS on the website but NOT in the Flutter app, it MUST be
  added to the Flutter app.
- If a feature EXISTS in the Flutter app but NOT on the website, it MUST be
  removed from the Flutter app.
- All data models, field names, enum values, and API response shapes in
  Flutter MUST exactly match those defined in the website frontend's
  TypeScript interfaces.
- UI component composition (which widgets compose a feature screen) MUST
  mirror the website's component hierarchy, adapted for Flutter's widget
  tree but preserving the identical logical structure.
- The website frontend documentation is the single source of truth for what
  features and fields MUST exist:
  - Chat: `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md`
  - Courses/Assignments/Labs: `Courses_Assignments_Labs_Frontend_Documentation.md`

### V. Testable Architecture
All services, repositories, and BLoCs MUST be constructed to be completely
testable. Services MUST accept injected dependencies (e.g., `Dio` instance,
`StorageService`) to allow mocking. WebSocket services MUST expose a
test-friendly interface that can be driven without a live server. Logic MUST
be testable independently of the UI and network layers.

### VI. Real-Time Communication Integrity
WebSocket connections MUST follow a strict lifecycle protocol:
- Connect on feature entry with JWT token authentication.
- Auto-reconnect on disconnect (maximum 5 attempts, 1200ms delay between
  attempts, matching the website frontend behavior).
- Expose a typed `connectionStatus` stream (`connected` / `disconnected`)
  consumed by the BLoC to drive UI connection indicators.
- Emit `join_conversation` on conversation select; emit
  `leave_conversation` on conversation deselect.
- Typing indicators MUST auto-stop after 1.5 seconds of inactivity
  (matching website debounce).
- All events MUST be handled idempotently — duplicate events from
  reconnection MUST NOT cause duplicate messages or state corruption.

### VII. Static Data Elimination
ALL static mock data, sample generators, and simulated responses MUST be
fully eliminated before a phase is considered complete.

**Mandatory removal targets per phase:**
- Hardcoded conversation lists, assignment lists, lab lists, course lists,
  material lists, grade tables, attendance records.
- Sample data generators (e.g., `_generateSampleConversations()`,
  `_generateSampleMessages()`, `_generateAvailableUsers()`,
  `_generateSampleAssignments()`, `_generateMockLabs()`).
- Simulated reply logic (`_simulateReply()`, `Future.delayed` fake
  responses).
- Local `setState` data manipulation that bypasses the BLoC.
- Mock user objects, avatar strings, timestamp fabrication, hardcoded
  grade scores, and fake submission data.
- Static enrollment lists, section data, or semester data that is not
  fetched from the backend API.

**Gate rule:** No phase may be marked complete if ANY mock/static data
remains in the files modified or created during that phase. The
`/speckit.implement` step MUST include a final audit grep for residual
mock artifacts including but not limited to:
- `_generateSample`, `_simulateReply`, `_mockMessages`, `_mockLabs`
- `Duration(hours:`, `Duration(minutes:` in data fabrication contexts
- `isMe: true/false` hardcoded message maps
- `setState(() =>` patterns that bypass BLoC
- Hardcoded `List<Assignment>`, `List<Lab>`, `List<Course>` literals
- `TODO: Replace with API` comments (MUST be resolved, not deferred)

### VIII. Aggressive Clarification
During the `/speckit.clarify` step, the specification MUST be interrogated
with a minimum of 5 targeted clarification questions covering:
1. **Field parity** — Are all backend response fields mapped to model
   properties? Are any website-only fields missing? Do all enum values
   match exactly between backend, website, and Flutter?
2. **Role behavior** — Does each role (student, instructor, TA, admin,
   IT admin) see the correct UI elements and permissions? Are CRUD
   buttons hidden/shown per the role-based access matrix?
3. **Edge cases** — What happens on network failure, empty states, token
   expiration, file upload failure, Google Drive/YouTube auth errors,
   and large data volumes (pagination)?
4. **Deletion scope** — Which existing Flutter files, widgets, models,
   and static data generators will be deleted or replaced? Are there
   any orphan screens that exist only in Flutter with no website
   equivalent?
5. **API coverage** — Are all backend endpoints handled? Are file upload
   endpoints using the correct FormData field names (`file`, `video`,
   `document`)? Are submission upload endpoints distinct from text
   submission endpoints? Is the grading endpoint correctly called with
   `score` and `feedback` parameters?

This ensures no ambiguity survives into the implementation phase.

### IX. Role-Based Access Control Enforcement
The Flutter UI MUST enforce role-based access control that exactly mirrors
the website frontend's permission matrix and the backend's `@Roles()`
guards.

**Non-negotiable rules:**
- UI elements (buttons, forms, menu items) that perform write operations
  MUST be conditionally rendered based on the authenticated user's role.
- The role check MUST happen at the **widget level** (not just API level)
  to prevent users from seeing actions they cannot perform.
- The role matrix defined in `Courses_Assignments_Labs_Frontend_Documentation.md`
  (Section 1.3: Feature Availability Matrix) and
  `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md` (Section 8: Role-Based
  Access Matrix) are the authoritative sources.
- If the backend returns `403 Forbidden`, the UI MUST display an
  appropriate error message — but the UI SHOULD prevent the request from
  being made in the first place by hiding the action.

**Key role restrictions to enforce:**
- Students: Can submit, view own submissions/grades. CANNOT create/edit/
  delete assignments, labs, or courses.
- Instructors: Full CRUD on assignments and labs for their courses. Can
  grade. Can upload materials. CANNOT delete courses.
- TAs: Grade-only for assignments and labs. CANNOT create, edit, or
  delete assignments. CANNOT delete labs. Eye (view) button only.
- Admin (Dept Head): Course lifecycle CRUD, section/schedule management,
  staff assignment. NO assignment or lab management.
- IT Admin: NO courses/assignments/labs features at all.

### X. File Upload & Google Drive/YouTube Integration
All file upload interactions MUST follow strict patterns:

**Upload rules:**
- Assignment instruction files: `POST /assignments/{id}/instructions/upload`
  with FormData field name `file`.
- Assignment submission files: `POST /assignments/{id}/submissions/upload`
  with FormData field name `file`.
- Lab instruction files: `POST /labs/{id}/instructions/upload` with
  FormData field name `file`.
- Lab submission files: `POST /labs/{id}/submissions/upload` with FormData
  field name `file`.
- Course material documents: `POST /courses/{id}/materials/document` with
  FormData field name `document`.
- Course material videos: `POST /courses/{id}/materials/video` with
  FormData field name `video`.

**Preview rules:**
- Google Drive documents MUST be previewed using the
  `getCourseMaterialPreviewUrl()` logic — extracting the Drive file ID
  and constructing `https://drive.google.com/file/d/{id}/preview`.
- YouTube videos MUST be rendered via `youtube_player_flutter` package
  or `WebView` with the embed URL from `material.externalUrl`.
- YouTube thumbnails MUST use `https://img.youtube.com/vi/{videoId}/mqdefault.jpg`.

**Error handling:**
- YouTube OAuth errors MUST display: "YouTube not authorized. Please
  contact admin to set up YouTube integration."
- Google Drive upload failures MUST display a retry option.
- File validation (size limits, allowed types) MUST happen **client-side
  before upload** to avoid unnecessary network traffic.

### XI. Multi-Phase Plan Adherence
All Courses/Assignments/Labs backend integration work MUST follow the
phased plan defined in `courses_assignments_labs_integration_plan.md`.

**Phase gating rules:**
- Phase 1 (Foundation) MUST be completed before any UI integration phase.
- Each phase produces a separate Spec-Kit specification via
  `/speckit.specify`.
- A phase MUST NOT be marked complete until:
  1. All static data in modified files has been replaced with live API data.
  2. All acceptance criteria from the plan are verified.
  3. Website parity for that phase's scope has been confirmed.
  4. Role-based UI enforcement has been verified for all affected roles.
- Phases 2–4 (Student scope) MAY proceed in parallel after Phase 1.
- Phases 5–7 (Instructor scope) MAY proceed in parallel after Phase 1.
- Phase 8 (TA) depends on Phases 6 and 7 for reusable grading components.
- Phase 9 (Admin) depends only on Phase 1.
- Phase 10 (Parity Audit) MUST be the final phase.

**Cross-reference documents:**
- Backend API: `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`
- Website frontend: `Courses_Assignments_Labs_Frontend_Documentation.md`
- Integration plan: `courses_assignments_labs_integration_plan.md`

## Chat Integration Constraints

All chat backend integration MUST precisely follow the phases and structures
dictated in `CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md`. The domain models
constructed in Flutter MUST match the properties and behaviors defined in
the React Web frontend (`Eduverse-Frontend`) and the backend API
documentation (`Flutter_Chat_API_Docs_BACKEND.md`) to ensure exact feature
parity.

For strict alignment, the implementation MUST reference the following local
environment paths to ensure complete parity with the web version and
established backend routes:
- **Backend Path:** `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`
- **Frontend Website Path:** `C:\Users\Friends\Desktop\Graduation\Frontend\Eduverse-Frontend`
- **Backend API Docs:** `Flutter_Chat_API_Docs_BACKEND.md` (in project root)
- **Website Feature Docs:** `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md` (in project root)
- **Integration Plan:** `CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md` (in project root)

## Courses, Assignments & Labs Integration Constraints

All Courses/Assignments/Labs backend integration MUST precisely follow the
10-phase plan defined in `courses_assignments_labs_integration_plan.md`.
The domain models constructed in Flutter MUST match the properties and
behaviors defined in the React Web frontend and the backend API
documentation to ensure exact feature parity.

For strict alignment, the implementation MUST reference the following:
- **Backend Path:** `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`
- **Frontend Website Path:** `C:\Users\Friends\Desktop\Graduation\Frontend\Eduverse-Frontend`
- **Backend API Docs:** `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md` (in project root)
- **Website Feature Docs:** `Courses_Assignments_Labs_Frontend_Documentation.md` (in project root)
- **Integration Plan:** `courses_assignments_labs_integration_plan.md` (in project root)
- **Database Schema:** `eduverse_db.sql` (in project root)

**Scope:** Five roles interact with this feature:
- **Student** — View courses, submit assignments/labs, view grades, watch lectures
- **Instructor** — CRUD assignments/labs, grade, upload materials, manage course structure
- **TA** — Grade assignments/labs (read-only, no CRUD), view courses/materials
- **Admin (Dept Head)** — CRUD courses, manage sections/schedules, assign staff
- **IT Admin** — No courses/assignments/labs features (system admin only)

## Feature Parity Rules

The following rules govern what is added and removed during integration:

| Condition | Action | Justification |
|-----------|--------|---------------|
| Feature on website, missing in Flutter | MUST add to Flutter | Website is truth |
| Feature in Flutter, missing on website | MUST remove from Flutter | Website is truth |
| Field in website model, missing in Flutter model | MUST add field | Data parity |
| Enum value in Flutter, absent in backend | MUST remove enum value | Backend is truth |
| Widget in Flutter with no website equivalent | MUST delete widget | No orphan UI |
| Mobile-specific UX patterns (e.g., pull-to-refresh, swipe gestures) | Excusable exception | Mobile UX standards supersede strict parity if the action operates purely on local state or is a standard mobile interaction pattern |
| Backend endpoint not used by website | MUST still implement if it serves a mobile-specific need (e.g., push notifications) | Backend completeness |
| WebSocket event in backend, not handled in Flutter | MUST handle event | Full coverage |

## Role-Based UI Enforcement Matrix

The following matrix MUST be enforced in the Flutter UI. Any screen that
shows an action button for a role not in this matrix is a parity violation.

| Feature | Student | Instructor | TA | Admin | IT Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| **View Courses** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Create/Edit Courses** | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Delete Courses** | ❌ | ❌ | ❌ | ✅ | ❌ |
| **View Assignments** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Create/Edit Assignments** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Submit Assignments** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Grade Assignments** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **View Labs** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Create/Edit Labs** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Submit Labs** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Grade Labs** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Mark Attendance** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Upload Materials** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Assign Staff** | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Manage Sections/Schedules** | ❌ | ❌ | ❌ | ✅ | ❌ |

## File Upload & Preview Policy

File uploads and previews MUST follow these exact patterns:

1. **Before upload**: Validate file size and type client-side:
   - Documents: max 50 MB (pdf, doc, docx, ppt, pptx, xls, xlsx, txt, md, zip)
   - Images: max 10 MB (jpg, jpeg, png, gif, webp, svg)
   - Videos: no client-side size limit (progress-tracked)
2. **During upload**: Show real-time progress bar via `onSendProgress`.
3. **After upload**: Refresh the relevant list (materials, instructions,
   submissions) from the API — do NOT optimistically append.
4. **Preview rendering**:
   - Google Drive files: `WebView` with `/preview` URL variant
   - YouTube videos: `youtube_player_flutter` with `videoId` or `WebView`
     with `embedUrl`
   - External links: open in system browser via `url_launcher`

## Static Data & Mock Removal Policy

Mock data removal is a **non-negotiable gate** for every phase:

1. **Before implementation**: Identify all mock data in files to be
   modified (grep for hardcoded lists, `DateTime.now().subtract()` patterns,
   `Future.delayed` simulations, hardcoded `List<>` literals).
2. **During implementation**: Replace each mock call with a real service
   call through the BLoC.
3. **After implementation**: Run a final audit for residual patterns:
   - `_generateSample`, `_simulateReply`, `_mockMessages`, `_mockLabs`
   - `_mockAssignments`, `_mockCourses`, `_mockGrades`, `_mockSubmissions`
   - `Duration(hours:`, `Duration(minutes:` in data fabrication contexts
   - `isMe: true/false` hardcoded message maps
   - `setState(() =>` patterns that bypass BLoC
   - Hardcoded `List<Assignment>`, `List<Lab>`, `List<Course>` literals
   - `TODO: Replace with API` comments (MUST be resolved, not deferred)
   - Static grade scores, attendance records, or enrollment counts
4. **Verification**: The phase MUST NOT be marked complete until the audit
   returns zero mock residuals in modified files.

## QA & Review Process

Because this integration operates across five dynamic roles (Student,
Instructor, TA, Admin, IT Admin), code reviews and QA MUST manually verify
data changes in all applicable dashboard contexts. Each phase completion
requires:

- Functional verification that real backend data renders correctly.
- WebSocket connection verification for chat features (connect, send,
  receive, reconnect).
- REST API verification for courses/assignments/labs features (CRUD, submit,
  grade, upload).
- Role-based UI verification (correct buttons, permissions, filters per
  role per the enforcement matrix above).
- Mock data elimination audit (zero residual static data).
- Cross-reference with website frontend to confirm visual and data parity.
- File upload verification (progress bar, success/error handling, preview
  after upload).

## Governance

This Constitution supersedes all other generic practices. Any deviations —
including connecting directly to the backend bypassing BLoCs, introducing
static data outside of clearly marked test fixtures, adding Flutter-only
features not present on the website, or skipping the role-based UI
enforcement matrix — require explicit justification and amendment to this
document. All phases MUST pass the Core Principle gates before proceeding
to the next phase.

**Amendment procedure:**
- Any principle change requires an updated version with Sync Impact Report.
- MAJOR version bump for principle removal/redefinition.
- MINOR version bump for new principle or section addition.
- PATCH version bump for clarification or typo fixes.

**Version**: 4.0.0 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-10
