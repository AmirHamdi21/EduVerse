# Research: Phase 3 — Student Assignments

**Date**: 2026-04-11
**Feature**: Student Assignment workflow integration (list → detail → submit → view grade)

---

## Decision 1: BLoC Architecture for Assignment State Management

**Context**: The existing `assignments_screen.dart` currently uses `StatefulWidget` with mock data. Need to determine the BLoC structure.

**Decision**: Create `AssignmentBloc` with three states: `AssignmentInitial`, `AssignmentLoading`, `AssignmentLoaded`, `AssignmentError`. Events: `FetchAssignments`, `SelectAssignment`, `SubmitAssignment`, `RefreshAssignments`.

**Rationale**: 
- The existing `AssignmentService` returns `ServiceResult<PaginatedResponse<AssignmentModel>>` which maps cleanly to BLoC states
- Three-state pattern (loading/loaded/error) matches the existing app's BLoC patterns (see `bloc/courses/`, `bloc/labs/`)
- Single BLoC handles both list and detail (detail is just selecting from loaded list or fetching by ID)
- Submission is a separate event that emits its own loading/success/error states

**Alternatives considered**:
- Separate `AssignmentListBloc` + `AssignmentDetailBloc` — rejected as overkill; detail is just a selection from the list
- Cubit instead of BLoC — rejected because events provide clearer audit trail for submission actions

---

## Decision 2: Status Filter Derivation Logic (Submitted/Pending/Overdue)

**Context**: The clarification session determined filters are based on submission state, not assignment status. Need to determine the derivation algorithm.

**Decision**: 
- **Submitted**: Student has an existing submission record for this assignment (check via `getMySubmission()` result or local cache of submissions)
- **Pending**: No submission exists AND `dueDate` is in the future (or null)
- **Overdue**: No submission exists AND `dueDate` is in the past

**Implementation approach**:
1. Fetch all assignments for enrolled courses
2. For each assignment, check if a submission exists (optimistic: check `assignment.submission` field from the list response; pessimistic: call `getMySubmission()` per assignment)
3. Compare `dueDate` with `DateTime.now()` for pending/overdue classification
4. Compute stats: Total = all assignments, Submitted = count with submissions, Pending = count without submissions and not overdue, Overdue = count without submissions and past due

**Rationale**: 
- The `AssignmentModel` already has an `isOverdue` computed property that checks `dueDate.isBefore(DateTime.now())` combined with status
- The backend's paginated assignment list response includes course relation but does NOT include student submission data — so `getMySubmission()` calls will be needed per assignment for accurate status
- **Optimization**: Batch the `getMySubmission()` calls during list load; cache results in BLoC state

**Alternatives considered**:
- Rely solely on `assignment.submission` field from list response — rejected because the backend list endpoint may not include submission data
- Server-side filtering — rejected because the backend `GET /assignments` doesn't support submission-state filtering

---

## Decision 3: File Picker Implementation for Submissions

**Context**: File submissions need to support both local device and Google Drive sources.

**Decision**: 
- **Local files**: Use `file_picker` package to select from device storage
- **Google Drive files**: Use `webview_flutter` to render a Google Drive file picker interface, or leverage the existing Drive file selection pattern from the website (Drive file ID → backend upload)

**Implementation approach**:
1. In the submission form modal bottom sheet, show two tabs: "From Device" and "From Google Drive"
2. "From Device" → `FilePicker.platform.pickFiles()` with type constraints from `assignment.allowedFileTypes`
3. "From Google Drive" → WebView to `https://drive.google.com/` picker or use the existing Drive integration pattern
4. Selected file → validate size against `assignment.maxFileSizeMb` → call `AssignmentService.submitFile()`

**Rationale**: 
- `file_picker` is the standard Flutter package for device file selection
- The backend already handles Google Drive upload via the submission endpoint — the app just needs to send the file bytes
- Client-side validation before upload prevents unnecessary network traffic

**Alternatives considered**:
- Google Drive API direct integration — rejected because it requires separate OAuth; the backend already handles Drive integration
- Image picker only — rejected because assignments may require PDF, DOCX, etc.

---

## Decision 4: Markdown Rendering for Assignment Instructions

**Context**: Assignment instructions support markdown formatting. Need a rendering solution.

**Decision**: Use `flutter_markdown` package to render `assignment.instructionsText` (the markdown string from the backend).

**Rationale**: 
- `flutter_markdown` is the standard Flutter markdown renderer, supports all common markdown syntax (headings, lists, bold, italic, code blocks, links)
- Styling can be customized via `MarkdownStyleSheet` to match the app's theme
- Already used in other parts of the app (if applicable) or easily integrable

**Alternatives considered**:
- Custom markdown parser — rejected as reinventing the wheel
- WebView to render HTML — rejected as overkill for text-only markdown

---

## Decision 5: Google Drive Instruction File Preview

**Context**: Assignment instruction files need inline preview capability.

**Decision**: Use `webview_flutter` to render the Google Drive preview URL: `https://drive.google.com/file/d/{driveFileId}/preview`.

**Rationale**: 
- The `DriveFileModel` already contains `webViewLink` and `downloadUrl` fields from the backend
- WebView provides the most faithful preview experience for various file types (PDF, DOC, PPT, etc.)
- Fallback to "Open in Drive" link if WebView fails

**Alternatives considered**:
- Native PDF viewer — rejected because it only supports PDF, not other document types
- Download-and-view — rejected because it consumes storage and doesn't provide inline preview

---

## Decision 6: Navigation Pattern for Assignment Detail

**Context**: Clarification session determined full-screen route push for detail view.

**Decision**: Use `Navigator.push()` to navigate from the assignment list card to the detail screen. The detail screen uses the same theme, colors, and app bar structure as the rest of the app.

**Rationale**: 
- Matches the Phase 2 pattern for course list → course detail navigation
- Provides full screen real estate for complex detail content (instructions, files, submission, grade)
- Back button returns to list naturally

**Implementation**: 
- The list card `onTap` calls `Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignment: assignment)))`
- The detail screen uses `Scaffold` with `AppBar` matching the app theme

---

## Decision 7: Submission Form Modal Bottom Sheet

**Context**: Clarification session determined modal bottom sheet for submission form.

**Decision**: Use `showModalBottomSheet` with `isScrollControlled: true` to present the submission form. The sheet contains a `TabBar` for different submission types (when `submissionType` is "any" or "multiple") or the single appropriate input.

**Rationale**: 
- Keeps the student in context of assignment details while submitting
- Dismissible by swiping down (good UX for accidental taps)
- Matches existing Flutter app patterns for forms and dialogs

**Implementation**:
- `showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SubmissionFormSheet(assignment: assignment))`
- The sheet has a fixed height (80% of screen) with scrollable content inside
