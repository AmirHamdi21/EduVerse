# Flutter Lab/Assignment Phase 7 Audit

## Purpose

This note records the Phase 7 stabilization work completed after implementing the lab and assignment parity plan in Flutter.

It is focused on:

- regression verification
- navigation consistency
- delivery-prep notes
- plan coverage review

---

## Verification Run

### Analyzer

Commands run:

- `flutter analyze lib/models/assignments/assignment_form_data.dart lib/widgets/instructor/assignments/assignment_create_form.dart lib/screens/instructor/create_assignment_screen.dart lib/bloc/ta/ta_courses_cubit.dart lib/screens/ta/assignments/ta_assignment_submissions_screen.dart lib/screens/ta/courses/ta_course_detail_screen.dart lib/screens/ta/assignments/ta_assignments_screen.dart lib/config/app_router.dart lib/widgets/ta/dashboard/ta_drawer.dart lib/screens/instructor/labs/lab_detail_screen.dart`
- `flutter analyze`

Results:

- focused analyze for the modified Phase 3 to Phase 7 files passed with no issues
- full-project analyze still exits non-zero because the repository already contains a large pre-existing warning/info backlog outside this work
- the latest full-project run reported `960 issues found`, but they are not new hard analyzer failures introduced by this parity work

### Tests

Commands run:

- `flutter test test/bloc/assignments/assignment_phase7_e2e_test.dart`
- `flutter test test/unit/bloc/instructor/lab_detail_cubit_test.dart`
- `flutter test test/widget/screens/create_assignment_screen_test.dart`
- `flutter test test/services/api/assignment_service_test.dart test/services/api/lab_service_upload_contract_test.dart`

Results:

- all listed tests passed

Additional regression coverage added:

- `test/models/assignments/assignment_form_data_test.dart`

This covers:

- `availableFrom` parsing
- `availableFrom` serialization
- `copyWith` preservation of the new field and instruction files

---

## Phase 7 Cleanup Applied

### Navigation consistency

Applied fixes:

- the TA top-level assignments route remains available at `/ta/assignments`
- TA drawer links directly to the new assignments page
- TA dashboard task-center “View all” now goes to `/ta/assignments` instead of the stale `/ta/tasks` route
- TA search “Pending grading” quick action now routes to `/ta/grading`
- TA search result taps for submission results now route to `/ta/grading`

### Empty/loading/error state review

Confirmed in the implemented Flutter changes:

- student assignments screen has a course filter and skeleton loading on initial load and course change
- student labs screen has skeleton loading on initial load and course change
- TA assignments screen includes loading, empty, error, retry, and create-first-assignment states
- TA lab resources screen is no longer a mock UI disguised as real functionality
- instructor lab TA-material upload uses explicit upload-only messaging instead of implying a browsable resource library

### Delivery notes

Key implementation constraints preserved:

- no backend code was modified
- no website frontend code was modified
- all changes remain inside the Flutter project only

---

## Plan Coverage Review

### Completed against the plan definition of done

- student assignment flow is no longer misleading about Drive/file behavior
- student assignments screen now has a course filter bar aligned with the labs filter flow
- student assignments and labs screens now show skeleton-style loading on first load and course changes
- student lab file validation is backend-driven
- student lab flow no longer fetches attendance from the student detail path
- instructor assignment form now includes `availableFrom`
- instructor lab instruction management no longer relies on the invalid generic fallback path
- TA assignment management now has a clear top-level access path
- TA lab grading refresh was stabilized
- TA resources are no longer mock-disguised functionality
- all parity work stayed inside Flutter

### Completed from Phase 7

- regression verification commands were run
- router/navigation consistency was reviewed and tightened
- implementation notes were added
- focused verification was documented for handoff

### Residual limitations to keep in mind

- full-project `flutter analyze` still reports the repo’s pre-existing warning/info backlog
- TA material support is intentionally upload-only where the accessible Flutter/backend surface does not provide a reliable list/read experience
- localization in these flows still follows the project’s broader mixed pattern; this pass focused on parity, correctness, and stabilization rather than a full localization refactor

---

## Recommended Next QA Pass

Manual QA should still cover:

- student assignment filter switching and submission variants
- student lab submission with different backend-configured restrictions
- instructor assignment create/edit with `availableFrom`
- instructor TA-material upload from lab detail
- TA assignments create/edit/delete/status changes
- TA grading center and TA assignment submissions navigation

