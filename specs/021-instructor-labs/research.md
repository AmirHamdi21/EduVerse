# Research: Phase 7 — Instructor Labs CRUD & Grading

**Date**: 2026-04-13  
**Feature**: Instructor Labs CRUD & Grading  
**Branch**: `021-instructor-labs`

## Research Tasks & Decisions

### Task 1: Existing Instructor Lab Infrastructure Assessment

**Question**: What instructor lab files already exist vs what needs to be built?

**Finding**: Zero instructor lab screens, widgets, BLoCs, or routes exist. All must be built from scratch.

**Decision**: Build all 17 new files following Phase 6 instructor assignment patterns exactly.

**Rationale**: The Explore agent confirmed no `lib/screens/instructor/labs/`, `lib/widgets/instructor/labs/`, or `lib/bloc/instructor/instructor_labs_*` files exist. App router has no `/instructor/labs` routes.

**Alternatives considered**: 
- Reuse TA lab screens → Rejected: TA labs use mock data, different UI pattern (table vs cards)
- Reuse student lab screens → Rejected: Student screens are read-only, instructor needs full CRUD

---

### Task 2: Phase 6 Pattern Reuse Strategy

**Question**: Which Phase 6 instructor assignment components can be directly reused/adapted for labs?

**Finding**: All Phase 6 assignment components have direct lab equivalents:

| Phase 6 Assignment Component | Phase 7 Lab Equivalent | Reuse Strategy |
|---|---|---|
| `instructor_assignments_screen.dart` | `instructor_labs_screen.dart` | Same layout, replace AssignmentModel → LabModel, assignment filters → lab filters |
| `assignment_card.dart` | `lab_card.dart` | Same card structure, assignment fields → lab fields (add due date, submission count) |
| `assignment_status_badge.dart` | `lab_status_badge.dart` | Direct reuse: AssignmentStatus and LabStatus have identical enum values (draft/published/closed/archived) |
| `assignment_create_form.dart` | `lab_create_form.dart` | Same form structure, assignment fields → lab fields (remove submissionType, maxFileSize, allowedFileTypes → add as lab-level config) |
| `grading_panel.dart` | `grading_panel.dart` (labs) | Same slide-over panel, adapt AssignmentSubmissionModel → LabSubmissionModel, add late penalty display |
| `instruction_file_uploader.dart` | `instruction_file_uploader.dart` | Direct reuse — same FormData upload pattern |
| `submission_list_item.dart` | `submission_list_item.dart` (labs) | Same list item structure, adapt submission model |
| `submission_content_viewer.dart` | `submission_content_viewer.dart` (labs) | Direct reuse — same text/file/Drive preview logic |
| `late_penalty_calculator.dart` | `late_penalty_calculator.dart` | Direct reuse — same calculation logic applies to labs |

**Decision**: Copy-and-adapt pattern. Do NOT import assignment widgets directly — create lab-specific variants that mirror the assignment UX but use lab data models.

**Rationale**: Maintains clean separation between assignment and lab domains. Prevents tight coupling. Allows future lab-specific customization without breaking assignment UI.

---

### Task 3: Lab Model Field Additions (allowedFileTypes, maxFileSizeMb)

**Question**: Does the existing LabModel need field additions to support the clarified spec?

**Finding**: Current `lib/models/labs/lab_model.dart` does NOT have `allowedFileTypes` or `maxFileSizeMb` fields. These were added during clarification (Q2) as configurable per-lab settings.

**Decision**: Add two optional fields to LabModel:
```dart
final String? allowedFileTypes;  // Comma-separated: "pdf,docx,zip"
final double? maxFileSizeMb;     // Max file size in MB
```

**Rationale**: These fields align with the AssignmentModel's `allowedFileTypes` and `maxFileSizeMb` pattern. Backend API docs show the lab creation endpoint accepts these fields. Student submission enforcement (FR-021) depends on these fields being present on the lab.

**Alternatives considered**:
- Store as separate config object → Rejected: adds unnecessary complexity, backend stores on lab record
- Use JSON array for allowedFileTypes → Rejected: backend accepts comma-separated string, consistent with assignment model

---

### Task 4: Late Penalty Calculation — Client vs Server

**Question**: Should late penalty be calculated client-side or does the backend return it?

**Finding**: Backend grading endpoint `PATCH /labs/{labId}/submissions/{subId}/grade` accepts `{score, feedback, status}`. It does NOT accept a `latePenaltyPercent` field. However, the lab submission response includes `isLate` (boolean) and `submittedAt` (timestamp). The lab record includes `dueDate`.

**Decision**: Calculate late penalty client-side in the grading panel using `lib/utils/late_penalty_calculator.dart`. Display auto-calculated penalty but allow manual override of the final score. The submitted `score` field is the final score (after any override) — the penalty is UI-only for instructor transparency.

**Rationale**: Matches Phase 6 assignment grading behavior. Backend does not auto-calculate penalties — it's a presentation concern. The instructor sees: "Original Score: 90, Late Penalty: 10% (-9 points), Final Score: 81" but can override the final score to any value before saving.

**Alternatives considered**:
- Backend calculates → Rejected: backend API doesn't support penalty field in grading request
- No penalty display → Rejected: contradicts clarification Q1 answer (auto-calculate with override)

---

### Task 5: FormData Field Names for Lab Instruction Uploads

**Question**: What FormData field name should be used for lab instruction file uploads?

**Finding**: Constitution Principle X specifies:
- Lab instruction files: `POST /labs/{id}/instructions/upload` with FormData field name `file`
- Lab submission files: `POST /labs/{id}/submissions/upload` with FormData field name `file`

Backend API docs confirm the same field names.

**Decision**: Use `file` as the FormData field name for all lab file uploads (instructions + submissions + TA materials).

**Rationale**: Matches backend expectations and Constitution Principle X. Consistent with assignment upload pattern.

---

### Task 6: Google Drive Preview URL Construction

**Question**: How to construct Google Drive preview URLs for lab instruction files?

**Finding**: Existing `DriveFileModel` from Phase 1 includes `iframeUrl` (preview URL), `downloadUrl`, and `webViewLink`. The backend returns these fields when uploading files to Google Drive via `POST /labs/{id}/instructions/upload`.

**Decision**: Use `iframeUrl` for WebView preview, `downloadUrl` for direct download, `webViewLink` for "Open in Drive" button. Reuse existing preview logic from Phase 6 assignment instruction viewer.

**Rationale**: Consistent with assignment and material preview patterns across the app. Backend provides all three URL variants.

---

### Task 7: BLoC Architecture — Single vs Dual Cubits

**Question**: Should instructor labs use one cubit (list + detail combined) or two separate cubits?

**Finding**: Phase 6 instructor assignments uses `InstructorAssignmentsCubit` (list view) and `LabDetailCubit` would be needed for the detail view (instructions, submissions, attendance are separate concerns from the list).

**Decision**: Two cubits:
- `InstructorLabsCubit` — manages labs list state (loading, loaded with List<LabModel>, error, search/filter state)
- `LabDetailCubit` — manages single lab detail state (lab model, instructions list, submissions list, attendance list, loading states for each)

**Rationale**: Separation of concerns. List view and detail view have different state shapes and lifecycle. List cubit can be disposed when navigating to detail, avoiding stale state. Matches Phase 6 pattern (InstructorAssignmentsCubit + AssignmentSubmissionsCubit).

---

### Task 8: Route Structure for Instructor Labs

**Question**: What route paths should be used for instructor labs screens?

**Finding**: Existing instructor assignment routes follow pattern:
- `/instructor/assignments` → list screen
- `/instructor/assignments/:assignmentId/submissions` → submissions screen
- `/instructor/assignments/:assignmentId/submissions/:submissionId/grading` → grading screen

**Decision**:
- `/instructor/labs` → `InstructorLabsScreen` (list with search/filter)
- `/instructor/labs/:labId` → `LabDetailScreen` (detail with instructions/submissions/attendance)

**Rationale**: Matches assignment route pattern. Single detail screen handles all three sub-views (instructions, submissions, attendance) via internal tabs — avoids deep nesting of routes.

---

### Task 9: Mock Data Audit Targets

**Question**: Which existing files might contain mock lab data that needs removal?

**Finding**: TA lab screens (`lib/screens/ta/labs/`, `lib/widgets/ta/labs/`) use mock data but are out of scope for Phase 7 (TA is Phase 8). No instructor lab mock data exists because no instructor lab screens exist yet.

**Decision**: Phase 7 will have zero mock data by construction. No removal needed — all new files will use live API data from LabService.

**Rationale**: Clean slate. The mock data elimination policy (Constitution Principle VII) is satisfied by never introducing mock data.

---

### Task 10: Testing Strategy

**Question**: What tests should be created for Phase 7?

**Finding**: Phase 6 includes unit tests for cubits and widget tests for screens. Shared service (LabService) already has its own tests.

**Decision**: 
- Unit tests: `instructor_labs_cubit_test.dart`, `lab_detail_cubit_test.dart`
- Widget tests: Screen-level tests for `InstructorLabsScreen` and `LabDetailScreen`
- Integration test: `instructor_labs_flow_integration_test.dart` (end-to-end: list → create → edit → delete → grade)

**Rationale**: Covers BLoC state transitions, widget rendering, and full user flow. Matches Phase 6 test coverage pattern.

---

## Consolidated Decisions Summary

| # | Decision | Rationale |
|---|---|---|
| 1 | All 17 files are new builds | Zero instructor lab infrastructure exists |
| 2 | Copy-and-adapt Phase 6 patterns | Clean separation, prevents coupling, enables future customization |
| 3 | Add allowedFileTypes + maxFileSizeMb to LabModel | Required by clarification Q2, matches assignment model pattern |
| 4 | Client-side late penalty calculation | Backend doesn't calculate; UI-only transparency feature |
| 5 | FormData field name: `file` for all lab uploads | Matches backend API and Constitution Principle X |
| 6 | Use DriveFileModel URLs for preview | Existing pattern, backend provides all variants |
| 7 | Two cubits (list + detail) | Separation of concerns, different state shapes |
| 8 | Routes: `/instructor/labs`, `/instructor/labs/:labId` | Matches assignment route pattern |
| 9 | Zero mock data by construction | Clean slate, no removal needed |
| 10 | Unit tests for cubits, widget tests for screens | Matches Phase 6 test coverage pattern |
