# Flutter Lab & Assignment Parity Fix Plan

## Purpose

This document is a **Flutter-only implementation plan** for bringing the Flutter project closer to the **website frontend behavior, logic, flow, and fields** for labs and assignments across:

- `student`
- `instructor`
- `ta`

This plan is based on the previously created gap report:

- `D:\Graduation\EduVerse\edu_verse\difference_documentation\lab_assignment_website_backend_vs_flutter_gap_report.md`

The output here is intentionally a **phased execution plan only**. It does **not** execute any changes.

---

## Hard Constraints

### Must not touch

Do **not** modify:

- backend code in `D:\Graduation\backend\last_backend\EduVerse_Backend`
- website frontend code in `D:\Graduation\frontend_tarek\Eduverse-Frontend`

### Allowed scope

Only modify the Flutter project:

- `D:\Graduation\EduVerse\edu_verse`

### Planning rule for parity

If the previous report mentioned a problem in backend or website code:

- **do not plan fixes in those projects**
- only plan Flutter changes needed to:
  - match the active website UX/flow where possible
  - match backend contract where Flutter is currently wrong
  - avoid copying known website implementation bugs into Flutter

### Priority rule

Implementation should prioritize:

1. Flutter correctness against backend contract
2. Flutter parity with the website’s visible user flow
3. Flutter UX discoverability and consistency across roles
4. Cleanup of risky internal Flutter service/state logic

---

## Desired End State

By the end of this plan, the Flutter project should have:

- student assignment behavior that matches the website flow more closely
- student assignment screen with a course filter bar comparable to the student labs course filter flow
- student lab submission behavior that is driven by backend lab configuration rather than hardcoded rules
- assignment and lab list screens that show skeleton-style loading when:
  - the screen first opens
  - the selected course changes from the filter bar
- instructor assignment and lab flows aligned with the fields and workflows exposed on the website
- TA assignment and lab workflows surfaced more clearly and more completely
- mock or misleading Flutter-only placeholder features either:
  - replaced with real integrations, or
  - converted into explicit unsupported states where real parity is not yet possible
- service-layer response parsing and state refresh logic cleaned up so uploads and grading flows are trustworthy

---

## Non-Goals

This plan does **not** include:

- backend API changes
- website bug fixes
- backend permission changes
- redesigning the feature set beyond parity and correctness needs
- unrelated course/quiz/announcement work

---

## Implementation Strategy

The work should be executed in phases so another Codex can implement safely without breaking working flows.

### Recommended sequence

1. Fix shared contract and response-shape issues first.
2. Fix student flows next because they expose the most user-facing parity issues.
3. Fix instructor flows after that.
4. Fix TA discoverability and the mock TA resources area last.
5. End with stabilization, regression testing, and documentation.

### Why this order

- shared API/service fixes reduce duplicate rework
- student flows contain the clearest correctness gaps
- instructor/TA work depends on shared service confidence
- mock TA resources should be handled after core assignment/lab flows are stabilized

---

## Phase Overview

### Phase 0

Contract alignment and implementation scaffolding inside Flutter

### Phase 1

Student assignments parity fixes

### Phase 2

Student labs parity fixes

### Phase 3

Instructor assignments parity fixes

### Phase 4

Instructor labs parity fixes

### Phase 5

TA assignments parity and discoverability fixes

### Phase 6

TA labs and TA resources fixes

### Phase 7

Cross-role stabilization, testing, and documentation

---

# Phase 0: Contract Alignment and Shared Flutter Foundations

## Goal

Clean up Flutter-side contract handling before changing role-specific screens, so later phases build on stable models, services, and state flows.

## Why this phase is first

The report identified several issues that affect multiple roles:

- upload response parsing is unsafe
- some state refresh logic is brittle
- some older model/status mapping can mislead the UI

If these are left unresolved, later feature work will be built on shaky assumptions.

## Main deliverables

- safer assignment upload parsing
- safer lab upload parsing
- explicit typed handling for wrapper responses
- reduced reliance on accidental refresh behavior after uploads
- clear status mapping rules in Flutter models/widgets
- a reusable or shared loading approach for student assignment/lab list screens, visually guided by the student registration loading experience

## Primary Flutter files to inspect and likely modify

- `lib/services/api/assignment_service.dart`
- `lib/services/api/lab_service.dart`
- `lib/models/assignments/assignment_submission_model.dart`
- `lib/models/labs/lab_submission_model.dart`
- `lib/models/assignments/assignment_model.dart`
- `lib/bloc/assignments/assignment_bloc.dart`
- `lib/bloc/lab_detail/lab_detail_cubit.dart`
- `lib/bloc/instructor/instructor_assignments_cubit.dart`
- `lib/bloc/instructor/lab_detail_cubit.dart`
- `lib/bloc/ta/ta_labs_cubit.dart`
- `lib/screens/student/student_registration_screen.dart`
- related student registration loading/skeleton widgets used as the design reference

## Detailed tasks

### 0.1 Document the real Flutter-side response shapes used by upload endpoints

- Review the response bodies currently returned by:
  - assignment submission upload
  - lab submission upload
  - assignment instruction upload
  - lab instruction upload
  - TA material upload
- Confirm which endpoints return:
  - direct entity payloads
  - `{ data: ... }`
  - wrapper objects such as `{ submission, driveFile, isLate }`
- Add a local implementation note in code comments or internal docs if needed.

### 0.2 Introduce explicit parsing helpers for upload wrappers

- Add Flutter-side parsing helpers or small DTO-style adapters for upload responses.
- Do not parse wrapper payloads directly into `AssignmentSubmissionModel` or `LabSubmissionModel`.
- Normalize the code so the service either:
  - returns a dedicated upload-result object, or
  - extracts and returns the nested submission model intentionally

### 0.3 Refactor assignment upload flow to use deterministic data

- Ensure `AssignmentService.submitFile()` has a reliable return type.
- Ensure the bloc does not depend on a structurally incorrect intermediate model.
- Keep the final refresh if still needed, but make it a correctness guard rather than a workaround.

### 0.4 Refactor lab upload flow to use deterministic data

- Apply the same cleanup pattern to `LabService.submitFile()`.
- Ensure submission upload results and post-upload refresh behavior are explicit.

### 0.5 Review and reduce misleading assignment status remapping

- Audit `AssignmentModel` legacy status mapping.
- Identify where UI components rely on remapped legacy statuses instead of real API statuses.
- Update the implementation plan for those widgets so UI reflects backend status intentionally.
- Avoid breaking any older screens that still require legacy mapping unless they are in scope for lab/assignment parity.

### 0.6 Audit refresh-after-success logic in TA/instructor flows

- Review places where success states are emitted and then a refresh method is called.
- Confirm whether refresh methods require a now-invalid prior state.
- Prepare targeted cleanup tasks for:
  - TA lab grading refresh
  - assignment submission refresh paths
  - lab detail refresh paths

### 0.7 Define a shared student academic loading pattern

- Inspect the loading presentation used in the student registration screen.
- Decide whether assignments and labs should:
  - reuse an existing skeleton widget directly, or
  - create a new shared skeleton widget inspired by the student registration loading style
- Keep the visual language aligned with student registration so the loading experience feels consistent across student-facing list screens.
- Plan for this loading pattern to be used in:
  - student assignments screen
  - student labs screen
  - course filter changes on both screens

## Acceptance criteria

- No upload endpoint in Flutter parses a wrapper payload directly into the wrong model.
- Services expose predictable result shapes.
- Role flows no longer rely on hidden “refresh fixes broken parse” behavior.
- Status rendering rules are clear enough that later UI phases can safely build on them.

## Risks

- Small parsing changes can affect many screens at once.
- Existing UI may be silently relying on the current accidental behavior.

## Suggested validation

- Run focused tests or manual checks for:
  - student assignment file submission
  - student lab file submission
  - instructor assignment instruction upload
  - instructor lab instruction upload

---

# Phase 1: Student Assignments Parity Fixes

## Goal

Bring the Flutter student assignment experience closer to the website behavior, while keeping backend correctness.

## Main deliverables

- improved parity for assignment detail and submission flow
- clear handling of text/link/file submission paths
- correct handling of Drive-related behavior in Flutter
- clearer late-submission and restriction messaging
- a course filter bar on the student assignments screen aligned with the student labs filter pattern
- skeleton-style loading for student assignments when the screen opens and when the selected course changes

## Primary Flutter files to inspect and likely modify

- `lib/screens/student/assignments_screen.dart`
- `lib/screens/student/assignment_detail_screen.dart`
- `lib/widgets/student/assignments/submission_form_sheet.dart`
- `lib/widgets/student/assignments/drive_file_picker.dart`
- `lib/bloc/assignments/assignment_bloc.dart`
- `lib/bloc/assignments/assignment_event.dart`
- `lib/bloc/assignments/assignment_state.dart`
- `lib/services/api/assignment_service.dart`
- any shared submission viewer widgets used in assignment detail
- `lib/screens/student/labs_screen.dart`
- any student labs filter widgets that should be mirrored for assignments
- student registration loading/skeleton widgets as the visual loading reference

## Detailed tasks

### 1.1 Audit current student assignment UX against website screens

- Compare Flutter assignment list/detail/submission with:
  - website `AssignmentsPage.tsx`
  - website `AssignmentView.tsx`
  - website `SubmissionForm.tsx`
- Identify missing visual information, especially:
  - submission type summary
  - file size limits
  - allowed file types
  - late penalty information
  - instruction file visibility
- Compare the current student assignments screen structure against the student labs screen so the assignments screen can adopt a comparable course-filter workflow.
- Inspect the student registration loading state and identify the exact loading style to mirror for assignment list loading.

### 1.2 Add a course filter bar to the student assignments screen

Target:

- Student assignments should support course-based filtering similarly to the student labs screen.

Concrete tasks:

- inspect how the student labs screen fetches enrolled courses and binds the selected course from the filter bar
- mirror that pattern in the student assignments screen
- decide whether to share the same filter widget or create an assignments-specific wrapper around the same pattern
- ensure the filter bar:
  - loads enrolled courses
  - selects a sensible default course
  - updates assignment fetching when the selected course changes
  - handles the no-courses case cleanly
- make sure the assignment list state is scoped to the selected course and does not mix stale results between course switches

### 1.3 Add skeleton loading to the student assignments screen

Target behavior:

- show skeleton-style loading when:
  - the assignments screen first opens
  - the user changes the selected course from the filter bar

Concrete tasks:

- use the student registration loading state as the visual reference
- decide whether to implement:
  - a reusable assignment/lab list skeleton widget, or
  - an assignments-specific skeleton that follows the same visual language
- ensure the skeleton replaces list content during active loading rather than showing stale content without feedback
- distinguish between:
  - first load
  - course-switch reload
  - empty state
  - error state
- avoid abrupt flicker when data returns quickly

### 1.4 Improve assignment detail metadata parity

- Ensure the detail screen clearly shows:
  - due date
  - submission type
  - max score
  - weight if already exposed on website
  - file restrictions
  - late-submission allowance and penalty
  - instruction files with open/download behavior

### 1.5 Rework Drive submission behavior

This is the most important assignment-specific parity decision.

#### Implementation rule

Because Flutter currently does not have true website-equivalent Drive integration, the implementation should **not pretend that manual URL entry is equivalent to a real uploaded file flow**.

#### Required plan outcome

Another Codex should choose one of these two Flutter-only implementations:

1. **Preferred**: keep Drive as a link-based submission mode only if the assignment supports links, and label it honestly as link submission.
2. **Fallback**: remove or demote the current “Pick From Google Drive” illusionary file path from file submission UI until a real supported integration exists.

#### Concrete tasks

- Review how the website presents file vs link submission.
- If the current Flutter Drive picker is retained:
  - rename the entry point so it is clearly a link-based submission helper
  - do not present it as equivalent to uploaded file submission
  - ensure it respects assignment submission type rules
- If assignment submission type is `file` only:
  - do not allow the current pseudo-Drive path to masquerade as a file upload
- Update validation and copy accordingly.

### 1.6 Make submission-tab behavior match assignment submission type more strictly

- Ensure Flutter tabs map cleanly to:
  - `text`
  - `link`
  - `file`
  - `multiple`
- Prevent UI states where unsupported submission paths are shown.
- Ensure submission errors are specific to the active mode.

### 1.7 Tighten local file validation behavior

- Keep the existing backend-driven file validation.
- Improve UX messages so they match website expectations more closely.
- Ensure allowed file extensions are rendered consistently.
- Ensure empty/unknown restriction states degrade gracefully.

### 1.8 Improve student submission state after submit

- After successful submit:
  - refresh own submission deterministically
- show updated submission metadata
- avoid stale status chips or stale latest-attempt info
- Confirm behavior for repeated attempts if backend allows them.

### 1.9 Review list filtering against website expectations

- Verify that draft/archived visibility rules are consistent with student expectations.
- Keep student-facing list logic limited to publishable/visible assignment states.

## Acceptance criteria

- Student can view assignments with website-equivalent core metadata.
- Student can filter assignments by course from a filter bar similar to the labs screen.
- Student sees skeleton loading for assignment list loading and course-switch reloads.
- Text, link, and file submission modes behave consistently with assignment configuration.
- Drive behavior is no longer misleading.
- Assignment detail clearly communicates file restrictions and late-submission rules.
- Submission state refreshes correctly after success.

## Risks

- Drive behavior change may alter existing user expectations if users were relying on manual URL entry.
- UI copy changes may require localization updates.

## Suggested validation

- assignment with `text` submission only
- assignment with `link` submission only
- assignment with `file` submission only
- assignment with `multiple`
- assignment past due with late allowed
- assignment past due with late blocked

---

# Phase 2: Student Labs Parity Fixes

## Goal

Replace the hardcoded Flutter student lab behavior with backend-configured, website-aligned submission logic.

## Main deliverables

- dynamic lab file validation
- correct role boundaries for attendance
- lab detail parity improvements where needed
- cleaner submission-state handling
- skeleton-style loading for student labs when the screen opens and when the selected course changes

## Primary Flutter files to inspect and likely modify

- `lib/screens/student/labs_screen.dart`
- `lib/screens/student/lab_detail_screen.dart`
- `lib/widgets/student/labs/lab_submission_sheet.dart`
- `lib/bloc/lab_detail/lab_detail_cubit.dart`
- `lib/services/api/lab_service.dart`
- `lib/models/labs/lab_model.dart`
- related student lab widgets
- student registration loading/skeleton widgets as the visual loading reference

## Detailed tasks

### 2.1 Replace hardcoded student lab file validation

Current problem:

- `lab_submission_sheet.dart` hardcodes:
  - `50MB`
  - a fixed extension allowlist

Target behavior:

- use `lab.maxFileSizeMb`
- use `lab.allowedFileTypes`
- handle unrestricted labs cleanly

Concrete implementation tasks:

- remove the static max-size constant
- remove the static extension set as the source of truth
- add helper methods that:
  - parse backend `allowedFileTypes`
  - normalize dotted and non-dotted extensions
  - render readable UI text for accepted types
- update validation errors to mention the real configured limits

### 2.2 Add skeleton loading to the student labs screen

Target behavior:

- show skeleton-style loading when:
  - the labs screen first opens
  - the user changes the selected course from the filter bar

Concrete tasks:

- inspect the current labs screen loading transitions
- replace plain spinners or abrupt list swaps with a skeleton-style loading experience aligned with student registration loading
- ensure the loading state applies to both:
  - initial enrolled-course + lab load
  - course-change lab reload
- ensure stale cards are not shown as if they belong to the newly selected course while fresh data is loading
- keep empty and error states visually distinct from loading

### 2.3 Align submission helper text with lab configuration

- Replace the hardcoded support message under the file picker.
- Show:
  - configured max size if present
- configured allowed file types if present
- reasonable fallback text if the lab allows generic upload

### 2.4 Remove student attendance fetch from normal lab-detail flow

- Review where `loadAttendance()` is called for student lab detail.
- Stop calling attendance endpoints from the student flow.
- If the UI currently displays attendance status based on that endpoint:
- either remove that block for students
- or gate it behind a role-safe condition if another data source exists

### 2.5 Keep student lab detail focused on student-owned data

- Ensure student lab detail primarily loads:
  - lab details
  - instructions
  - own submissions
- Avoid loading instructor/TA operational data for students.

### 2.6 Improve own-submission display parity

- Check whether the student sees:
  - latest submission
  - past submissions if available
  - submission timestamps
  - late markers
  - grade/feedback if returned
- Adjust UI to match the website’s practical visibility level where applicable.

### 2.7 Validate submission UX for labs without restrictions

- Ensure labs with no configured `allowedFileTypes` or `maxFileSizeMb` still work cleanly.
- Prevent over-validation.

## Acceptance criteria

- Student lab validation uses backend-provided lab rules.
- Student lab UI no longer shows hardcoded file rules.
- Student sees skeleton loading on lab screen entry and course-switch reloads.
- Student flow no longer calls attendance APIs unnecessarily.
- Student lab submission and post-submit refresh behavior are reliable.

## Risks

- Some labs may have empty or malformed `allowedFileTypes`; normalization must be defensive.
- Removing attendance fetch may require small UI adjustments if something on the screen assumed it existed.

## Suggested validation

- lab with `allowedFileTypes=pdf,docx`
- lab with no `allowedFileTypes`
- lab with small custom `maxFileSizeMb`
- late lab submission
- student viewing lab with multiple prior submissions

---

# Phase 3: Instructor Assignments Parity Fixes

## Goal

Close the remaining instructor assignment gaps in Flutter so the create/edit/manage flow is complete, explicit, and aligned with the website feature set and backend contract.

## Main deliverables

- instructor assignment form parity review
- missing field support where needed
- clearer lifecycle/status handling
- stronger create/edit UX consistency

## Primary Flutter files to inspect and likely modify

- `lib/screens/instructor/assignments/instructor_assignments_screen.dart`
- `lib/screens/instructor/create_assignment_screen.dart`
- `lib/widgets/instructor/assignments/assignment_create_form.dart`
- `lib/widgets/instructor/assignments/instruction_file_uploader.dart`
- `lib/bloc/instructor/instructor_assignments_cubit.dart`
- `lib/models/assignments/assignment_form_data.dart`
- `lib/models/assignments/assignment_model.dart`
- route wiring in `lib/config/app_router.dart`

## Detailed tasks

### 3.1 Reconcile assignment form fields with website + backend

Audit Flutter create/edit form against:

- website `AssignmentCreateEdit.tsx`
- backend assignment DTO/entity fields

Confirm the Flutter form covers:

- title
- description
- instructions
- course
- due date and time
- max score
- weight
- submission type
- max file size
- allowed file types
- late penalty percent
- status
- instruction files

Then identify the missing fields that should be added in Flutter.

### 3.2 Add `availableFrom` if absent

- If not already represented in `AssignmentFormData` and UI, add it.
- Ensure create/edit flows preserve it.
- Ensure display/serialization format matches the existing Flutter backend client conventions.

### 3.3 Improve status lifecycle ergonomics

- Review whether instructor can explicitly manage:
  - `draft`
  - `published`
  - `closed`
  - `archived`
- Decide whether this belongs:
  - in the form
  - in list-level action menus
  - or both
- Make the UX consistent rather than half-form / half-list.

### 3.4 Verify instruction-file management parity

- Confirm instructor can:
  - upload instruction files
  - view them
  - remove them
  - keep them during edit
- Ensure edit mode always loads the latest instruction-file state before rendering the form.

### 3.5 Improve assignment list metadata parity

- Review whether the list/cards should show more website-like context:
  - due date
  - status
  - submission count or grading count
  - course/section context where appropriate
- Keep changes scoped to parity, not redesign.

### 3.6 Verify grading/submissions screen alignment

- Ensure instructor submission management still works after Phase 0 parsing cleanup.
- Review:
  - sorting
  - filtering
  - score entry
  - feedback entry
  - post-grade refresh

## Acceptance criteria

- Instructor assignment create/edit form covers the intended website/backend field set.
- Status handling is clear and complete.
- Instruction-file management is stable in both create and edit flows.
- Submission and grading flow remains intact after shared service cleanup.

## Risks

- Adding fields like `availableFrom` may require changes in form validation, serialization, and edit initialization at the same time.

## Suggested validation

- create assignment with file restrictions
- edit assignment with existing instruction files
- move assignment through multiple statuses
- grade one or more submissions after Phase 0 service changes

---

# Phase 4: Instructor Labs Parity Fixes

## Goal

Complete instructor lab parity in Flutter, especially around instruction management correctness and TA-material support.

## Main deliverables

- correct instruction management behavior
- active TA-material upload support if Flutter can expose it safely
- cleaner lab detail workflows

## Primary Flutter files to inspect and likely modify

- `lib/screens/instructor/labs/instructor_labs_screen.dart`
- `lib/screens/instructor/labs/lab_detail_screen.dart`
- `lib/widgets/instructor/labs/lab_create_form.dart`
- `lib/widgets/instructor/labs/instruction_manager.dart`
- `lib/widgets/instructor/labs/attendance_sheet.dart`
- `lib/bloc/instructor/instructor_labs_cubit.dart`
- `lib/bloc/instructor/lab_detail_cubit.dart`
- `lib/services/api/lab_service.dart`

## Detailed tasks

### 4.1 Reconcile lab create/edit fields with website + backend

Audit Flutter lab create/edit against:

- website lab create/edit flows
- backend lab DTO/entity fields

Confirm coverage of:

- title
- description
- lab number
- due date
- available from
- max score
- weight
- status
- allowed file types
- max file size

Add or adjust any missing field wiring in Flutter.

### 4.2 Remove invalid instruction fallback strategy

Current problem:

- `LabDetailCubit` fallback tries to update instructions through generic lab update payloads.

Target behavior:

- instruction edits and deletes should rely on proper instruction endpoints only
- if those fail, Flutter should show a useful error instead of attempting a likely-invalid fallback

Concrete tasks:

- remove or replace `_fallbackUpdateInstruction()`
- remove or replace `_fallbackDeleteInstruction()`
- adjust UI messaging for failure states
- keep instruction order handling consistent with supported backend methods only

### 4.3 Verify instruction manager parity

- Ensure instructor can:
  - add text instruction
  - edit text instruction
  - delete instruction
  - upload instruction file
  - reorder instructions if already supported by backend calls
- Ensure all actions refresh visible state reliably.

### 4.4 Add active TA-material upload UI if feasible in Flutter

Important planning rule:

- This is a Flutter-only enhancement using the existing Flutter service and existing backend endpoint.
- Do not modify backend or website.

Concrete tasks:

- inspect whether `LabService.uploadTaMaterial()` is stable enough after Phase 0
- add an instructor-visible entry point in lab detail if not already present
- define where TA materials should live in the UI:
  - dedicated tab
  - section within lab detail
  - instructor-only/TA-only materials card
- show upload progress, success/error states, and resulting file links if the endpoint returns useful metadata

If listing TA materials is not supported clearly by current APIs:

- implement upload-only support with honest UI messaging
- do not fake a full resource library without real data support

### 4.5 Verify attendance flow after changes

- Ensure marking attendance still works cleanly.
- Confirm payloads use the correct field names already used by Flutter.
- Review whether notes support is needed for parity; if omitted, document as intentional if the website UI also keeps notes minimal in practice.

## Acceptance criteria

- Instructor labs do not rely on invalid instruction-update fallback behavior.
- Instruction CRUD remains stable.
- TA-material upload is surfaced in Flutter if supported by the existing Flutter service/backend path.
- Lab create/edit fields are aligned with the intended website/backend model.

## Risks

- TA-material feature may be upload-capable but not list-capable depending on accessible APIs.
- Removing fallback logic may expose hidden failures that were previously swallowed.

## Suggested validation

- add/edit/delete text instruction
- upload instruction file
- reorder instructions if supported
- upload TA material
- mark attendance after lab detail refreshes

---

# Phase 5: TA Assignments Parity and Discoverability Fixes

## Goal

Make TA assignment functionality easier to find and closer to the website’s dashboard-centered organization without rewriting the entire TA architecture.

## Main deliverables

- clearer TA assignment entry points
- less fragmented TA assignment management
- preserved grading and create/edit/delete functionality

## Primary Flutter files to inspect and likely modify

- `lib/screens/ta/courses/ta_course_detail_screen.dart`
- `lib/screens/ta/assignments/ta_assignment_submissions_screen.dart`
- `lib/screens/ta/grading/ta_grading_center_screen.dart`
- `lib/config/app_router.dart`
- any TA dashboard navigation widgets

## Detailed tasks

### 5.1 Audit current TA assignment entry points

- List all current ways a TA can reach assignment functionality.
- Confirm whether those paths are:
  - course detail only
  - grading center only
  - hidden behind non-obvious tabs

### 5.2 Add a dedicated TA assignments route or landing surface

Target:

- TA should have a top-level, discoverable assignments area comparable in usability to the website TA dashboard’s assignments tab.

Implementation options:

1. Add a dedicated `/ta/assignments` route.
2. Add a stronger dashboard entry card that opens a real TA assignments screen.
3. Reuse existing course/assignment widgets under a unified TA assignments page.

Recommended direction:

- add a dedicated TA assignments page or route, because this produces the cleanest parity and reduces fragmentation.

### 5.3 Reuse existing assignment management pieces instead of duplicating logic

- Reuse:
  - assignment list cards
  - create/edit form
  - submissions/grading screen
- Avoid duplicating instructor logic unless role-specific UI differences require it.

### 5.4 Ensure TA assignments page supports core parity actions

- list assignments across assigned courses or per selected course
- create assignment
- edit assignment
- delete assignment
- open submissions
- open grading center

### 5.5 Improve course context in TA assignment UI

- The website shared page is section-aware.
- Flutter may not need identical architecture, but it should provide enough context:
  - course code
  - course name
  - section if available

### 5.6 Validate grading center after navigation changes

- Ensure the grading center remains a useful aggregated workflow.
- Do not break direct course-detail grading paths.

## Acceptance criteria

- TA has a clear, top-level way to manage assignments.
- Existing TA assignment functionality remains intact.
- Navigation is less fragmented than today.

## Risks

- Router changes can ripple into drawer/sidebar navigation.
- Reusing instructor widgets may require light role-aware adjustments.

## Suggested validation

- open TA assignments from top-level navigation
- create/edit/delete assignment from TA path
- open submissions from TA path
- open grading center from TA path

---

# Phase 6: TA Labs and TA Resources Fixes

## Goal

Finish TA parity for labs and replace the current mock TA lab resources area with a real, honest Flutter implementation strategy.

## Main deliverables

- TA lab flow verification and cleanup
- refresh robustness after grading
- replacement or rework of mock TA lab resources screen

## Primary Flutter files to inspect and likely modify

- `lib/screens/ta/labs/ta_labs_list_screen.dart`
- `lib/screens/ta/labs/ta_lab_detail_screen.dart`
- `lib/bloc/ta/ta_labs_cubit.dart`
- `lib/screens/ta/lab_resources/ta_lab_resources_screen.dart`
- `lib/services/api/lab_service.dart`
- TA navigation/router files

## Detailed tasks

### 6.1 Audit TA labs against active website shared-lab workflow

- Confirm Flutter TA labs already support:
  - create/edit/delete
  - instructions
  - submissions
  - grading
  - attendance
- List any missing small parity items before editing.

### 6.2 Fix TA lab grading refresh fragility

- Review `TALabsCubit.gradeLabSubmission()`.
- Ensure success-state emission does not prevent submission refresh.
- Refactor state transitions so:
  - grading success can still refresh detail data
  - refreshed submissions appear immediately
  - UI toast/snackbar behavior is preserved

### 6.3 Decide the fate of the current TA resources screen

Current state:

- `TALabResourcesScreen` is mock-only and should not remain as if it were real.

Required Flutter-only implementation decision:

Choose one of these two approaches:

1. **Preferred**: replace the mock resource screen with a real TA-material upload screen that uses actual API-backed behavior where possible.
2. **Fallback**: replace the mock screen with a clear “not yet available” or “available through lab detail” state if a full real resource center cannot be built safely from current Flutter-accessible APIs.

Do **not** leave the mock data UI in place.

### 6.4 If implementing real TA-material support, scope it honestly

Possible Flutter-only realistic version:

- select a lab
- upload a TA material file through the existing service
- show upload progress
- show success/failure messaging
- optionally display returned uploaded file metadata if available

If the API/service does not provide enough data to build a true resource library:

- do not fake material counts, quality scores, analytics, or historical lists
- use a simple real upload workflow instead

### 6.5 Align TA resource access with lab detail where appropriate

- Consider whether TA materials should live:
  - inside TA lab detail
  - in a simplified top-level resources screen
  - in both, using the same underlying widget

Recommended direction:

- keep the canonical upload action near lab detail
- only keep a top-level TA resources page if it can be real and not redundant

## Acceptance criteria

- TA lab grading reliably refreshes after grading.
- The mock TA resources screen is removed or replaced.
- Any surviving TA-material UI is real, API-backed, and honest about its scope.

## Risks

- TA materials may be upload-only without clear list/read support.
- Removing the mock screen may require router/menu updates.

## Suggested validation

- TA grades a lab submission and sees updated list/detail state
- TA opens lab detail and uses instruction/attendance actions
- TA opens any remaining resource/material workflow and sees only real data or an explicit unsupported state

---

# Phase 7: Cross-Role Stabilization, Regression Testing, and Delivery Prep

## Goal

Stabilize all changes, close regressions, and leave the Flutter project ready for implementation handoff and QA.

## Main deliverables

- regression coverage for affected flows
- UI copy cleanup
- router/navigation verification
- concise implementation notes for future maintainers

## Primary Flutter areas to verify

- assignment services and blocs
- lab services and cubits
- instructor routes
- TA routes
- student screens for assignments and labs

## Detailed tasks

### 7.1 Run full manual regression pass for all role flows in scope

Student:

- assignment list
- assignment course filter bar
- assignment screen initial skeleton load
- assignment course-switch skeleton load
- assignment detail
- text/link/file submission
- lab list
- lab screen initial skeleton load
- lab course-switch skeleton load
- lab detail
- lab text/file submission

Instructor:

- assignment create/edit/delete/status
- assignment instruction files
- assignment submissions and grading
- lab create/edit/delete/status
- lab instructions
- lab attendance
- TA-material upload if implemented

TA:

- assignments entry/navigation
- assignment create/edit/delete
- assignment submissions/grading
- grading center
- labs list/detail
- lab grading
- attendance
- resource/material flow

### 7.2 Review localization impact

- Any new UI text, error messages, labels, or helper copy should be added consistently.
- Confirm English and Arabic coverage if the app currently supports both.

### 7.3 Review empty/loading/error states

- Ensure all newly added or corrected flows have:
  - loading indicators
  - skeleton loading where the plan specifically requires it for student assignments and labs
  - empty states
  - retry paths where appropriate
  - non-misleading error copy

### 7.4 Review navigation consistency

- Confirm any new TA assignments route or revised TA resources route is linked from the correct drawer/sidebar/menu.
- Ensure deep links and back navigation are reasonable.

### 7.5 Add concise implementation notes

Inside Flutter documentation or a nearby markdown note, capture:

- why pseudo-Drive file upload was changed or limited
- why student lab validation is now backend-driven
- why mock TA resources were removed/replaced
- any API constraints that shaped the final Flutter-only solution

## Acceptance criteria

- All modified role flows work end-to-end from the Flutter client perspective.
- No placeholder mock resource experience remains disguised as real functionality.
- Navigation and error handling are coherent after the parity changes.

---

## Recommended Task Breakdown for Another Codex

If another Codex is implementing this plan, the safest breakdown is:

### Workstream A

Shared services/models/state cleanup

- Phase 0

### Workstream B

Student parity fixes

- Phase 1
- Phase 2

### Workstream C

Instructor parity fixes

- Phase 3
- Phase 4

### Workstream D

TA parity and resource cleanup

- Phase 5
- Phase 6

### Workstream E

Stabilization and QA

- Phase 7

Important rule:

- If multiple Codex workers are used in parallel, they should own different file groups to avoid merge conflicts.

---

## Suggested Order Inside the Flutter Repo

This is the recommended implementation order inside the codebase:

1. `services` and response parsing
2. `models` and helper normalization
3. `student` widgets/screens
4. `instructor` widgets/screens
5. `ta` widgets/screens and router
6. localization and cleanup
7. regression pass

---

## Definition of Done

This plan is complete when another Codex can implement Flutter-only parity work and satisfy all of the following:

- student assignment flow is not misleading about Drive/file behavior
- student assignments screen has a course filter bar aligned with the labs filter pattern
- student assignments and labs screens show skeleton-style loading on first load and course changes
- student lab file validation is backend-driven
- student lab flow does not use attendance endpoints incorrectly
- instructor assignment form covers intended field parity, including missing fields such as `availableFrom` if absent
- instructor lab instruction management relies only on valid backend-supported flows
- TA assignment management has a clear top-level access path
- TA lab grading refresh is stable
- TA resources are no longer mock-disguised functionality
- all changes stay inside the Flutter project only

---

## Final Implementation Notes

### Most important planning caution

Do **not** use the website as a literal source of truth for every payload detail, because the previous report found some website/backend mismatches.

Instead, the implementing Codex should follow this rule:

- copy the **website user flow and visible feature set**
- preserve **backend contract correctness**
- implement everything **only in Flutter**

### Most important execution caution

Do not treat every missing parity item as a new screen problem. In several places, the real work is:

- service parsing cleanup
- role-boundary cleanup
- removing misleading mock behavior
- changing hardcoded UI logic to backend-driven logic

That distinction should guide the real implementation effort.
