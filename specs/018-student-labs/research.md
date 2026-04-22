# Research: Student Labs Integration

**Feature**: 018-student-labs
**Date**: 2026-04-11

---

## Research Task 1: LabModel Cleanup Strategy

**Question**: The existing `LabModel` has dual-purpose fields — legacy UI-facing fields (used by the current demo-driven UI) and backend API fields (added in Phase 1). Which fields to remove vs keep?

**Decision**: Remove all legacy UI-only fields that have no backend API equivalent. Keep all backend-facing fields. Map computed/display-only fields to derived values from backend data.

**Rationale**:
- The constitution (Principle VII) mandates complete elimination of mock/static data
- The spec (FR-023) requires removing all static/mock lab data
- Keeping legacy fields would perpetuate the dual-model confusion and increase maintenance burden
- Fields like `courseName`, `courseCode`, `instructorName` can be derived from the nested `course` object (which contains `code`, `name`, and `instructorId`)
- The legacy `LabStatus` enum (upcoming/inProgress/completed/missed) should be replaced with the backend-facing `LabStatus` from `lab_enums.dart` (draft/published/closed/archived)
- `location`, `virtualLink`, `type` (LabType) have no backend equivalent — these are website-only or Flutter-only concepts and should be removed

**Alternatives considered**:
- Keep legacy fields for backwards compatibility → Rejected: violates Principle VII, perpetuates tech debt
- Create separate `LabApiModel` and `LabUiModel` → Rejected: unnecessary indirection; one cleaned model is sufficient

**Resolved from clarification session**: Lab detail opens in a **separate full screen** (`LabDetailScreen`) with the same UI structure and colors as the lab list screen. The existing `LabDetailsSheet` (bottom sheet) will be replaced.

---

## Research Task 2: Course Selector Integration

**Question**: How to combine `EnrollmentService.getMyCourses()` with `LabService.getAll()` in the labs list screen?

**Decision**: The `LabsCubit` will manage course selection state. On initialization, it fetches enrolled courses via `EnrollmentService.getMyCourses()`. The first course with labs (or the first course) is auto-selected. When the user changes course selection, `LabsCubit.selectCourse(courseId)` fires, which calls `LabService.getAll(courseId: courseId)` and emits a new state with filtered labs.

**Rationale**:
- This matches the website's `LabInstructions` container pattern: course selector dropdown → filtered lab list
- `EnrollmentService` already exists from Phase 1 with `getMyCourses()` endpoint
- `LabService.getAll({courseId})` already supports courseId query parameter
- BLoC-driven approach ensures course selection and lab list are in a single reactive state
- Course selector dropdown in the UI reads from `LabsState.enrolledCourses` (populated once) and `LabsState.selectedCourseId` (triggers lab fetch)

**Alternatives considered**:
- Separate `CourseSelectorCubit` → Rejected: unnecessary; course selection is tightly coupled to lab list
- Fetch all labs without courseId filter, filter client-side → Rejected: inefficient for large datasets; backend supports filtering

---

## Research Task 3: Submission Event Tracking

**Question**: Design lightweight local event logging mechanism for SC-003 validation (≥95% submission success rate).

**Decision**: Create a simple `SubmissionEventTracker` utility that logs submission attempts to `shared_preferences`. Each log entry contains: timestamp (ISO 8601), lab ID, success/failure status, error message (if failure). The tracker exposes a `getEvents()` method for debugging and a `getSuccessRate()` method for validating SC-003. Events older than 30 days are automatically pruned on next write.

**Rationale**:
- `shared_preferences` is already a project dependency (Phase 2)
- Lightweight — no new dependencies needed
- Survives app restarts (unlike in-memory maps)
- Sufficient for debugging and SC-003 validation
- Not a full analytics system — just a local debug log
- Pruning prevents unbounded storage growth

**Alternatives considered**:
- In-memory map only → Rejected: lost on app restart; insufficient for post-session debugging
- Remote analytics service → Rejected: overkill for this feature; adds external dependency
- Sentry/crash reporting integration → Rejected: not part of project scope; violates technology-agnostic spec

---

## Research Task 4: Google Drive Preview Pattern

**Question**: Confirm existing app's pattern for Google Drive file preview in lab instructions.

**Decision**: Use `webview_flutter` package with the Drive file's `iframeUrl` (already present in `DriveFileModel`). The existing `CoreApiClient` and Phase 2 course material preview already use this pattern. The `iframeUrl` field in `DriveFileModel` contains the Google Drive preview URL (format: `https://drive.google.com/file/d/{id}/preview`). Render in a `WebView` widget with JavaScript enabled.

**Rationale**:
- `webview_flutter` is already a dependency (Phase 2)
- `DriveFileModel` already has `iframeUrl` field
- Consistent with Phase 2 course material preview pattern
- No new packages needed
- Fallback: "Open in Drive" button launches system browser with `webViewLink`

**Alternatives considered**:
- `youtube_player_flutter` for Drive files → Rejected: only works for YouTube videos
- Native document viewer → Rejected: platform-specific; WebView is cross-platform
- Download and open externally → Rejected: breaks user flow; WebView provides inline preview

---

## Additional Research: Markdown Rendering for Lab Instructions

**Question**: How to render markdown-formatted lab instruction text?

**Decision**: Use the `flutter_markdown` package (`flutter_markdown: ^0.6.18`) to render `LabInstructionModel.instructionText` as formatted markdown. This is a standard Flutter package for markdown rendering and supports headings, lists, code blocks, and emphasis — all common in lab instructions.

**Rationale**:
- Standard, well-maintained Flutter package
- Lightweight (no native dependencies)
- Supports all markdown features needed for lab instructions
- Matches the website's use of React markdown rendering for assignment/lab instructions

**Alternatives considered**:
- Custom regex-based parser → Rejected: error-prone; reinvents the wheel
- `markdown` package without Flutter widget → Rejected: need a widget, not just a parser
- Plain `Text` widget with no formatting → Rejected: violates website parity (website renders markdown)

---

## Additional Research: Existing BLoC Pattern Compatibility

**Question**: Can the existing `LabsCubit` pattern be extended for API-driven data loading?

**Decision**: Yes. The existing `LabsCubit` already has the right state shape (`LabsState` with `labs` list, `isLoading`, `error`, `searchQuery`, `filter`, `sortBy`). The only change needed is replacing `_generateDemoLabs()` with `LabService.getAll(courseId)` and adding `selectedCourseId` + `enrolledCourses` fields to `LabsState`. The filtering, searching, and sorting logic in `LabsState.filteredLabs` is already correct and reusable.

**Rationale**:
- Minimizes blast radius — only data source changes, not state shape
- Preserves existing UI components that depend on `LabsState` fields
- Reduces regression risk — filtering/searching logic untested but already implemented
- Aligns with constitution Principle XII (UI Consistency) — same state, same UI

**Alternatives considered**:
- Create entirely new `LabsApiCubit` → Rejected: duplicative; existing cubit can be rewired
- Full BLoC rewrite → Rejected: unnecessary; incremental change is sufficient

---

## Summary of Decisions

| Decision | Choice | Impact |
|----------|--------|--------|
| LabModel cleanup | Remove legacy fields, keep backend fields | Cleaner model, no dual-purpose confusion |
| Course selector | Managed by LabsCubit, auto-select first course | Single reactive state, no extra cubits |
| Submission tracking | shared_preferences-based event log | Lightweight, survives restarts, debuggable |
| Drive preview | WebView with iframeUrl from DriveFileModel | Consistent with Phase 2, no new deps |
| Markdown rendering | flutter_markdown package | Standard, lightweight, matches website |
| BLoC approach | Rewire existing LabsCubit, create new LabDetailCubit | Minimal blast radius, new screen gets own cubit |
