# Lab and Assignment Features Gap Analysis

## Scope

This report compares the **lab** and **assignment** features across:

- **Backend**: `D:\Graduation\backend\last_backend\EduVerse_Backend`
- **Website frontend**: `D:\Graduation\frontend_tarek\Eduverse-Frontend`
- **Flutter frontend**: `D:\Graduation\EduVerse\edu_verse`

The comparison covers the three target roles:

- `student`
- `instructor`
- `ta`

The goal of this report is to document:

- what the backend and website support today
- what the Flutter app already implements
- what is only partially implemented in Flutter
- what is completely missing in Flutter
- what is implemented incorrectly or with risky backend-contract mismatches

This is intentionally a **planning input document**, not an implementation plan.

---

## Method and Comparison Rules

### Source of truth

1. **Backend source code** was treated as the canonical API and permission baseline.
2. **Active website flows** were used as the main frontend reference.
3. **Inactive or mock website/Flutter screens** were still documented when they can mislead planning or create false confidence.

### Important interpretation notes

- If the **website is also wrong against the backend**, this report explicitly says so instead of treating the website as correct.
- If the **Flutter app is ahead of the active website** in some area, this is also called out.
- TA comparisons focus on the **active website TA dashboard**, which uses shared instructor-style pages rather than older standalone TA mock pages.

### Status labels used in this document

- **Aligned**: Flutter behavior matches the backend baseline closely.
- **Partially implemented**: Flutter covers some of the flow, but not the full expected behavior.
- **Missing**: Flutter does not expose the feature at all.
- **Wrong / risky**: Flutter has a behavior or payload shape that is misleading, incorrect, or likely to fail against the backend contract.

---

## Executive Summary

### Overall picture

The Flutter project already has substantial coverage for assignments and labs, especially for:

- student assignment submission
- instructor assignment management
- instructor lab management
- TA lab management

However, the comparison found several important gaps:

1. **Student lab submission in Flutter is not backend-driven the way the website/backend are**. File validation is hardcoded to `50MB` and a fixed extension list instead of using lab-specific restrictions from the API.
2. **Flutter “Google Drive” assignment submission is only a manual URL wrapper, not real Drive-backed submission**. It does not follow the website/backend file upload flow and should be considered only partially implemented.
3. **TA lab resources in Flutter are a mock/local-only screen**, not a real feature connected to backend lab materials or TA-material endpoints.
4. **Some Flutter upload service methods parse backend upload responses incorrectly**, which is currently masked by later refresh calls but is still a correctness risk.
5. **Flutter student lab detail still tries to load attendance for students**, even though the backend restricts attendance endpoints to instructor/TA/admin roles.

### Important nuance

The website is not a perfect gold standard:

- the active website TA/instructor assignment save flow drops advanced assignment fields such as `maxFileSize`, `allowedFileTypes`, and `latePenalty`
- the website lab attendance payload uses `status` while the backend expects `attendanceStatus`
- website student lab file-type validation appears weaker than intended because it expects extensions with leading dots

So the final planning baseline should be:

- **backend as contract**
- **active website as UX/feature reference**
- **Flutter compared against both**

---

## Backend Capability Baseline

This section summarizes the backend capabilities that matter for the comparison.

### Assignments backend baseline

Backend files reviewed:

- `src/modules/assignments/controllers/assignments.controller.ts`
- `src/modules/assignments/services/assignments.service.ts`
- `src/modules/assignments/dto/create-assignment.dto.ts`
- `src/modules/assignments/entities/assignment.entity.ts`
- `src/modules/assignments/entities/assignment-submission.entity.ts`
- `src/modules/assignments/dto/upload-assignment-files.dto.ts`

#### Assignment capabilities

- list assignments with pagination and filtering
- create assignment
- get assignment details
- update assignment
- delete assignment
- change assignment status
- upload instruction files
- delete instruction files
- upload student submission file
- submit assignment using structured JSON payload
- get current student submission
- get all submissions
- grade submissions
- update central gradebook from grading flow

#### Assignment fields supported by backend

- `title`
- `description`
- `instructions`
- `courseId`
- `dueDate`
- `availableFrom`
- `maxScore`
- `weight`
- `status`
- `submissionType`
- `maxFileSizeMb`
- `allowedFileTypes`
- `lateSubmissionAllowed`
- `latePenaltyPercent`

#### Assignment role baseline

- **Student**: view assignments, upload/submit work, view own submission
- **Instructor**: full CRUD, status changes, instruction-file management, submission review, grading
- **TA**: same operational assignment management/grading permissions as instructor for relevant endpoints

### Labs backend baseline

Backend files reviewed:

- `src/modules/labs/controllers/labs.controller.ts`
- `src/modules/labs/services/labs.service.ts`
- `src/modules/labs/entities/lab.entity.ts`
- `src/modules/labs/entities/lab-submission.entity.ts`
- `src/modules/labs/entities/lab-instruction.entity.ts`
- `src/modules/labs/dto/index.ts`
- `src/modules/labs/dto/upload-lab-files.dto.ts`

#### Lab capabilities

- list labs with pagination and filtering
- create lab
- get lab details
- update lab
- delete lab
- change lab status
- get/add/update/delete instructions
- upload instruction file
- upload TA material
- submit lab work through JSON
- upload student submission file
- get student submissions
- get my submissions
- grade lab submissions
- mark attendance
- get attendance
- update central gradebook from grading flow

#### Lab fields supported by backend

- `courseId`
- `title`
- `description`
- `labNumber`
- `dueDate`
- `availableFrom`
- `maxScore`
- `weight`
- `status`
- `allowedFileTypes`
- `maxFileSizeMb`

#### Important lab-specific backend notes

- Labs have explicit **instruction CRUD**, unlike assignments where instruction files are mostly file uploads.
- Labs support **attendance**.
- Labs support **TA material upload** via `POST /labs/:id/ta-materials/upload`.
- Backend `MarkLabAttendanceDto` expects `attendanceStatus`, not `status`.
- Backend lab submissions track lateness with `isLate`, but labs do **not** expose assignment-style late penalty configuration in the same way assignments do.

---

## Active Website Baseline

This section documents the active website behavior used for comparison.

### Active website TA/instructor architecture

The active website TA dashboard uses:

- `src/pages/shared-dashboard/components/SharedAssignmentsPage.tsx`
- `src/pages/shared-dashboard/components/SharedLabsPage.tsx`

This means the active TA website flow is mostly aligned with the instructor-style shared pages, not the older standalone TA mock pages.

### Website assignment baseline

Key files reviewed:

- `src/services/api/assignmentService.ts`
- `src/pages/student-dashboard/components/assignments/AssignmentsPage.tsx`
- `src/pages/student-dashboard/components/assignments/AssignmentView.tsx`
- `src/pages/student-dashboard/components/assignments/SubmissionForm.tsx`
- `src/pages/student-dashboard/components/assignments/assignmentService.ts`
- `src/pages/instructor-dashboard/components/instructor-assignments/AssignmentCreateEdit.tsx`
- `src/pages/shared-dashboard/components/SharedAssignmentsPage.tsx`
- `src/pages/ta-dashboard/components/AssignmentGradingPage.tsx`

#### Website strengths

- student assignments support text/link/file submission
- active student file submission follows the backend pattern:
  - upload file to `/submissions/upload`
  - then submit using `fileId`
- student assignment detail shows file restrictions and late-penalty information
- instructor/TA shared assignment dashboard supports list/create/edit/delete/status/submissions/grading
- instructor create/edit screen exposes advanced fields such as file-size limit, allowed types, and late penalty

#### Website caveats

- In `SharedAssignmentsPage.tsx`, the active save payload omits:
  - `maxFileSize`
  - `allowedFileTypes`
  - `latePenalty`
  - `availableFrom`
- So the active website **shows** advanced assignment settings in parts of the UI, but its main shared save flow does not fully persist them.
- Some older website helper methods still post file `FormData` directly to `/assignments/:id/submit`, which does not match the backend contract. These appear legacy compared to the active student flow.

### Website lab baseline

Key files reviewed:

- `src/services/api/labService.ts`
- `src/pages/student-dashboard/components/labs/LabList.tsx`
- `src/pages/student-dashboard/components/labs/LabView.tsx`
- `src/pages/student-dashboard/components/labs/SubmissionForm.tsx`
- `src/pages/instructor-dashboard/components/labs/LabsDashboard.tsx`
- `src/pages/instructor-dashboard/components/labs/InstructionEditor.tsx`
- `src/pages/instructor-dashboard/components/labs/hooks/useLabAttendance.ts`
- `src/pages/shared-dashboard/components/SharedLabsPage.tsx`

#### Website strengths

- student labs support viewing details and submitting text/file work
- lab submissions use the backend-compatible upload-then-submit flow
- instructor/TA labs support create/edit/delete/status management
- instructor/TA lab detail supports instruction CRUD
- instructor/TA lab detail supports grading
- instructor/TA lab detail supports attendance management

#### Website caveats

- `LabService.markAttendance()` posts `{ userId, status, notes }`, but backend expects `{ userId, attendanceStatus, notes }`
- website student lab file-type validation appears brittle because it expects extensions with a leading dot, while backend/admin forms typically store values like `pdf,docx,zip`
- the website has TA/lab-resources style components, but the active TA dashboard uses shared lab pages instead

---

## Flutter Baseline

Key Flutter files reviewed included:

- `lib/services/api/assignment_service.dart`
- `lib/services/api/lab_service.dart`
- student screens/widgets for assignments and labs
- instructor screens/cubits/forms for assignments and labs
- TA screens/cubits for assignments, grading, labs, and lab resources

### High-level Flutter maturity

- **Assignments**: generally strong for student and instructor, moderate for TA, with the biggest issue being Drive submission semantics.
- **Labs**: generally strong for instructor and TA, weaker for student correctness due to hardcoded validation and student attendance fetch behavior.
- **TA resources**: not production-ready.

---

## Detailed Comparison by Role

# Student Role

## Student Assignments

### Backend + website expectation

Expected student assignment behavior from backend and active website:

- list assignments for enrolled courses
- open assignment detail
- view instructions and instruction files
- see due date, submission type, file limits, allowed file types, late-submission rules
- submit text
- submit link
- upload file and submit with backend-generated `fileId`
- view own latest submission

### Flutter status

Relevant Flutter files:

- `lib/screens/student/assignments_screen.dart`
- `lib/screens/student/assignment_detail_screen.dart`
- `lib/widgets/student/assignments/submission_form_sheet.dart`
- `lib/widgets/student/assignments/drive_file_picker.dart`
- `lib/services/api/assignment_service.dart`
- `lib/bloc/assignments/assignment_bloc.dart`

### What is aligned

- assignment list/detail flow exists
- own submission retrieval exists
- text submission exists
- link submission exists
- local file submission exists
- file-size and allowed-type validation use assignment data from the backend
- late-submission UI reflects `lateSubmissionAllowed` and `latePenaltyPercent`

### Partially implemented in Flutter

- **Drive submission**
  - Flutter exposes a “Pick From Google Drive” flow.
  - But this is not real backend-backed Drive integration.
  - It is a WebView plus manual URL parsing in `drive_file_picker.dart`.
  - When the user picks a Drive item, Flutter submits the Drive `webViewLink` as `submissionLink`, not as a backend-managed uploaded file / `fileId`.
  - This means the UX exists, but the implementation does not match the website/backend file-upload model.

### Wrong / risky in Flutter

- **Upload response parsing**
  - `AssignmentService.submitFile()` posts correctly to `/assignments/$id/submissions/upload`.
  - But it parses the entire upload response directly into `AssignmentSubmissionModel`.
  - Backend upload responses are wrappers containing fields like `submission`, `driveFile`, and `isLate`.
  - This is risky because the immediate parsed object shape is not the real submission payload.
  - Current flow is partially protected because the bloc refreshes with `getMySubmission()` after upload.

- **Legacy status remapping inside model**
  - `AssignmentModel` still maps API statuses like `published`, `closed`, and `archived` to older UI status concepts such as `pending`, `submitted`, and `graded`.
  - This is not a backend contract match and can produce misleading visual state if reused broadly.

### Missing in Flutter

- No true backend-backed Drive picker / Drive upload workflow equivalent to the website’s file upload flow.
- No evidence of assignment `availableFrom` being surfaced clearly in the student assignment UI.

### Assessment

Student assignments in Flutter are **mostly functional**, but the Drive path should be treated as **partially implemented and semantically wrong**, not complete.

---

## Student Labs

### Backend + website expectation

Expected student lab behavior from backend and active website:

- list labs
- view lab detail
- view lab instructions
- submit text and/or file depending on lab configuration
- use backend-configured file rules
- view own submissions

### Flutter status

Relevant Flutter files:

- `lib/screens/student/labs_screen.dart`
- `lib/screens/student/lab_detail_screen.dart`
- `lib/widgets/student/labs/lab_submission_sheet.dart`
- `lib/services/api/lab_service.dart`
- `lib/bloc/lab_detail/lab_detail_cubit.dart`

### What is aligned

- lab list/detail flow exists
- student can view instructions
- student can submit text
- student can upload a file
- student can view own submissions/history
- late-state banner exists

### Partially implemented in Flutter

- **Lab submission validation**
  - The feature exists, but Flutter does not use lab-specific backend restrictions.
  - `lab_submission_sheet.dart` hardcodes:
    - `50MB`
    - a fixed extension allowlist
  - This means the submission flow is only partially aligned with backend-configured labs.

### Wrong / risky in Flutter

- **Hardcoded validation instead of API-driven validation**
  - This is one of the most important student-lab gaps.
  - Backend and website are designed around lab-specific `allowedFileTypes` and `maxFileSizeMb`.
  - Flutter ignores those values in the student lab submission sheet.
  - Result:
    - Flutter may reject valid files
    - Flutter may allow files that the backend lab configuration did not intend
    - different labs cannot enforce different restrictions properly

- **Student attendance fetch**
  - `LabDetailCubit.loadAttendance()` calls the attendance endpoint from the student flow.
  - Backend attendance routes are instructor/TA/admin oriented.
  - The student flow should not rely on this endpoint as part of normal lab detail behavior.
  - Even if the app fails silently, this is still an incorrect role-level integration.

- **Upload response parsing**
  - Same pattern as assignments: `LabService.submitFile()` parses the upload wrapper directly into `LabSubmissionModel`.
  - Current behavior is partly masked by later refresh calls.

### Missing in Flutter

- No fully backend-driven student lab file validation equivalent to the intended lab configuration model.

### Assessment

Student labs in Flutter are **present but not contract-correct**. The largest issue is that file validation is **hardcoded instead of per-lab**, which makes the feature operationally incomplete even though the screens exist.

---

# Instructor Role

## Instructor Assignments

### Backend + website expectation

Expected instructor assignment behavior:

- list/filter assignments
- create assignment
- edit assignment
- delete assignment
- change status
- upload instruction files
- view submissions
- grade submissions
- persist assignment configuration fields such as submission type, file limits, and late penalty

### Flutter status

Relevant Flutter files:

- `lib/screens/instructor/assignments/instructor_assignments_screen.dart`
- `lib/screens/instructor/create_assignment_screen.dart`
- `lib/widgets/instructor/assignments/assignment_create_form.dart`
- `lib/widgets/instructor/assignments/instruction_file_uploader.dart`
- `lib/screens/instructor/assignments/assignment_submissions_screen.dart`
- `lib/bloc/instructor/instructor_assignments_cubit.dart`

### What is aligned

- instructor assignment list exists
- assignment filtering exists
- create exists
- edit exists
- delete exists
- status update exists
- instruction file upload exists
- submissions list exists
- grading exists
- form supports:
  - `submissionType`
  - `maxFileSizeMb`
  - `allowedFileTypes`
  - `latePenaltyPercent`
  - `status`
  - `weight`
  - `maxScore`

### Flutter stronger-than-website note

The Flutter instructor assignment flow is actually **more complete than the active website shared save flow** in one important area:

- Flutter persists advanced assignment settings through `AssignmentFormData.toJson()`
- active website `SharedAssignmentsPage.tsx` drops several of those advanced fields when saving

So for instructor assignments, Flutter is not the weak side in every comparison.

### Partially implemented in Flutter

- **Status editing**
  - The instructor form exposes mainly `draft` and `published` directly.
  - The broader backend status lifecycle includes `closed` and `archived`.
  - Flutter can still update status from list-level actions, but the editing experience is not fully symmetric with the backend lifecycle.

### Missing in Flutter

- **`availableFrom` field in create/edit form**
  - Backend supports it.
  - It was not found as a real field in the main Flutter instructor assignment form.

- **Website-like section-oriented dashboard structure**
  - Website shared assignments operate with section/course context more explicitly.
  - Flutter instructor assignments appear primarily course-based rather than section-first.
  - This is more of a UX difference than a backend gap, but it matters for parity planning.

### Wrong / risky in Flutter

- The upload-response parsing issue described in student assignments also exists at service level and should still be treated as a correctness risk for instructor-visible state consistency.

### Assessment

Instructor assignments in Flutter are **largely complete** and in some places **better aligned with backend assignment settings than the active website flow**. The main remaining gaps are `availableFrom`, full lifecycle editing ergonomics, and service-layer correctness cleanup.

---

## Instructor Labs

### Backend + website expectation

Expected instructor lab behavior:

- list/filter labs
- create/edit/delete labs
- change lab status
- instruction CRUD
- instruction file upload
- view submissions
- grade submissions
- mark attendance
- access TA-material upload where supported

### Flutter status

Relevant Flutter files:

- `lib/screens/instructor/labs/instructor_labs_screen.dart`
- `lib/screens/instructor/labs/lab_detail_screen.dart`
- `lib/widgets/instructor/labs/lab_create_form.dart`
- `lib/widgets/instructor/labs/instruction_manager.dart`
- `lib/widgets/instructor/labs/attendance_sheet.dart`
- `lib/bloc/instructor/instructor_labs_cubit.dart`
- `lib/bloc/instructor/lab_detail_cubit.dart`
- `lib/services/api/lab_service.dart`

### What is aligned

- instructor lab list exists
- create/edit/delete exists
- status management exists
- instruction text CRUD exists
- instruction file upload exists
- submissions review exists
- grading exists
- attendance exists

### Partially implemented in Flutter

- **TA material support**
  - The service method `uploadTaMaterial()` exists in Flutter.
  - But no active instructor lab UI was found that exposes TA-material upload.
  - Backend supports it.
  - The website codebase also has a `TaMaterialUpload.tsx` component, but it does not appear to be part of the main active shared-lab flow.
  - So this is best classified as backend-supported but not clearly surfaced in active Flutter UI.

### Wrong / risky in Flutter

- **Instruction fallback update/delete logic**
  - `LabDetailCubit` contains fallback logic that calls `PUT /labs/:id` with an embedded `instructions` array.
  - Backend `UpdateLabDto` does not support nested `instructions` updates.
  - Backend expects instruction changes through dedicated instruction endpoints.
  - Therefore, this fallback path is likely ineffective and should be considered wrong or unreliable.

- **Lab grading UI shows late-penalty calculations**
  - Flutter grading widgets include late-penalty logic patterns similar to assignments.
  - Backend labs do not expose assignment-style late-penalty configuration.
  - If this UI is interpreted as real configurable lab penalty behavior, it can become misleading.

### Missing in Flutter

- No confirmed active instructor UI for TA-material upload despite backend support.

### Assessment

Instructor labs in Flutter are **feature-rich and close to the backend baseline**, but TA-material UI exposure and the fallback instruction-update strategy are notable gaps/risk areas.

---

# TA Role

## TA Assignments

### Backend + website expectation

Expected TA assignment behavior from backend and active website:

- manage assignments for assigned sections/courses
- create/edit/delete assignments
- view submissions
- grade submissions
- operate from a dedicated assignments area in the TA dashboard

### Flutter status

Relevant Flutter files:

- `lib/screens/ta/courses/ta_course_detail_screen.dart`
- `lib/screens/ta/assignments/ta_assignment_submissions_screen.dart`
- `lib/screens/ta/grading/ta_grading_center_screen.dart`
- `lib/bloc/ta/ta_assignment_submissions_cubit.dart`
- `lib/services/api/assignment_service.dart`
- `lib/config/app_router.dart`

### What is aligned

- TA can create assignments
- TA can edit assignments
- TA can delete assignments
- TA can open assignment submissions
- TA can grade assignments
- TA has a grading center that aggregates submissions across assigned courses

### Partially implemented in Flutter

- **Dedicated TA assignment dashboard**
  - Website TA flow exposes assignments through the TA dashboard’s active shared assignments page.
  - Flutter does not expose a clear dedicated `/ta/assignments` route in the router.
  - TA assignment management exists, but it is split across:
    - course detail
    - grading center
    - submission screen
  - So the capability exists, but the top-level information architecture is less complete than the website’s active TA dashboard.

### Missing in Flutter

- No obvious dedicated TA assignments landing page equivalent to the active website dashboard tab/page.

### Wrong / risky in Flutter

- The same assignment upload-response parsing issue exists at the shared service layer.
- TA assignment parity is harder to reason about because the feature is fragmented across multiple screens rather than centered in one main TA assignments workspace.

### Assessment

TA assignments in Flutter are **functionally more complete than they first appear**, but they are **less discoverable and less dashboard-centered** than the active website implementation.

---

## TA Labs

### Backend + website expectation

Expected TA lab behavior:

- list labs for assigned courses
- create/edit/delete labs
- manage instructions
- view submissions
- grade submissions
- mark attendance
- use a TA-friendly lab management surface

### Flutter status

Relevant Flutter files:

- `lib/screens/ta/labs/ta_labs_list_screen.dart`
- `lib/screens/ta/labs/ta_lab_detail_screen.dart`
- `lib/bloc/ta/ta_labs_cubit.dart`
- `lib/services/api/lab_service.dart`

### What is aligned

- dedicated TA labs list exists
- create/edit/delete exists
- instruction management exists
- submissions review exists
- grading exists
- attendance exists

### Partially implemented in Flutter

- **Submission refresh after grading**
  - `TALabsCubit.gradeLabSubmission()` emits success states and then calls `refreshLabSubmissions()`.
  - That refresh relies on being in a detail-loaded state.
  - Depending on the exact current state transition, the refresh can become fragile or no-op.
  - This is not necessarily a guaranteed failure, but it is a state-management risk worth tracking.

### Assessment

TA labs in Flutter are **generally strong** and appear close to or better than the active website TA experience in terms of dedicated role-specific UI.

---

## TA Lab Resources

### Backend + website expectation

Backend supports:

- `POST /labs/:id/ta-materials/upload`

Website codebase contains:

- `src/pages/instructor-dashboard/components/labs/TaMaterialUpload.tsx`
- `src/services/api/labService.ts` support for `uploadTaMaterial()`

But the active website TA dashboard mainly uses shared lab pages, so TA-material UX is not clearly active there either.

### Flutter status

Relevant Flutter file:

- `lib/screens/ta/lab_resources/ta_lab_resources_screen.dart`

### Wrong / risky in Flutter

- This screen is a **mock/local placeholder**, not a real integrated feature.
- Evidence from the file:
  - hardcoded lab names such as `Lab 1`, `Lab 2`, `Lab 3`, `Lab 4`
  - local `_materialsByLab` map filled after `Future.delayed`
  - no real backend fetch
  - no real lab/material identifiers from backend
  - local quality scores and analytics-style values
- This should not be treated as implemented functionality.

### Missing in Flutter

- real TA-material upload and listing flow connected to backend labs
- real permissions-aware TA resource management
- real data fetching for TA lab materials

### Assessment

This feature is **totally missing in production terms** and the existing Flutter screen is **totally wrong as a parity reference** because it is only a mock/demo surface.

---

## Cross-Cutting Contract and Correctness Issues

These issues are important because they affect multiple role flows or can cause misleading confidence during planning.

### 1. Flutter upload response parsing is inconsistent with backend response shape

Affected Flutter services:

- `lib/services/api/assignment_service.dart`
- `lib/services/api/lab_service.dart`

Problem:

- file-upload endpoints return wrapper payloads
- Flutter parses wrapper data directly into submission models

Impact:

- immediate result objects can be structurally wrong
- bugs may be masked by later refresh calls
- error handling and optimistic UI become less trustworthy

### 2. Student lab file validation in Flutter is not backend-driven

Affected Flutter file:

- `lib/widgets/student/labs/lab_submission_sheet.dart`

Problem:

- hardcoded `50MB`
- hardcoded extension list

Impact:

- per-lab restrictions cannot work correctly
- parity with backend-configured lab behavior is broken

### 3. Flutter assignment Drive flow is not true Drive integration

Affected Flutter files:

- `lib/widgets/student/assignments/drive_file_picker.dart`
- `lib/widgets/student/assignments/submission_form_sheet.dart`

Problem:

- manual URL parsing and WebView browsing
- selected Drive file becomes `submissionLink`
- no real backend-managed uploaded file or `fileId`

Impact:

- misleading feature completeness
- not equivalent to website/backend upload semantics

### 4. Flutter student lab flow touches attendance behavior that is not student-owned

Affected Flutter file:

- `lib/bloc/lab_detail/lab_detail_cubit.dart`

Problem:

- student lab detail tries to call attendance retrieval

Impact:

- unnecessary forbidden API traffic
- role boundary confusion in the client

### 5. Flutter instructor lab instruction fallback does not match backend DTO design

Affected Flutter file:

- `lib/bloc/instructor/lab_detail_cubit.dart`

Problem:

- fallback tries to push nested `instructions` through generic lab update

Impact:

- recovery path likely cannot work reliably
- hidden failure mode if direct instruction API calls fail

---

## Website-vs-Backend Caveats That Matter for Flutter Planning

These are important because if planning uses the website alone as the baseline, it may inherit incorrect assumptions.

### 1. Website assignment save flow is incomplete in active shared page

Affected website file:

- `src/pages/shared-dashboard/components/SharedAssignmentsPage.tsx`

Issue:

- active save payload omits advanced assignment settings such as file rules and late penalty

Planning implication:

- Flutter should not be downgraded to match this omission
- backend capabilities should remain the real target

### 2. Website lab attendance payload appears incorrect

Affected website file:

- `src/services/api/labService.ts`

Issue:

- sends `status`
- backend expects `attendanceStatus`

Planning implication:

- the desired fix target should be backend contract parity, not website payload parity

### 3. Website student lab file-type validation may be weaker than intended

Affected website files:

- `src/pages/student-dashboard/components/labs/SubmissionForm.tsx`
- related website lab validation utilities

Issue:

- parsing expects dot-prefixed extensions while backend/admin configuration is often comma-separated plain extensions

Planning implication:

- Flutter should implement backend-driven validation correctly rather than copying website edge-case behavior

---

## Planning-Ready Findings Summary

This section is not a fix plan. It is a compact issue inventory that can be turned into a plan later.

### Highest-risk Flutter gaps

- Student lab file validation is hardcoded instead of backend-driven.
- Assignment Drive submission is only a manual URL/link workflow, not real backend-backed file submission.
- TA lab resources screen is mock-only and should not be counted as implemented.
- Upload service response parsing for assignment/lab file submissions is structurally unsafe.
- Student lab detail includes attendance API behavior outside the student role boundary.

### Medium-risk Flutter gaps

- Instructor assignment form does not clearly expose all backend lifecycle/config fields such as `availableFrom`.
- Instructor labs do not expose a confirmed active TA-material upload UI.
- TA assignment functionality is present but fragmented compared to the website’s dashboard-first organization.
- Instructor lab instruction fallback logic is likely invalid against backend DTO rules.

### Areas where Flutter is already relatively strong

- Instructor assignment CRUD, grading, and instruction-file handling
- TA lab management and grading
- Student assignment file validation for normal local uploads
- Instructor/TA assignment forms persisting advanced assignment settings better than the active website shared page

---

## Final Conclusion

If the comparison baseline is **backend contract + active website behavior**, then the Flutter project is **not missing the entire lab/assignment feature set**. In fact, large parts are already present.

The main problems are more specific:

- some Flutter features are **implemented but not contract-correct**
- some are **feature-complete for one role but not for another**
- some are **real but fragmented in navigation**
- a few are **pure placeholders and should be treated as missing**

The most important planning distinction is:

- **Do not classify every difference as “missing UI.”**
- A significant share of the remaining work is actually:
  - contract cleanup
  - role-boundary correction
  - replacing placeholder flows
  - making validation/data handling backend-driven

---

## Evidence Files Reviewed

### Backend

- `src/modules/assignments/controllers/assignments.controller.ts`
- `src/modules/assignments/services/assignments.service.ts`
- `src/modules/assignments/dto/create-assignment.dto.ts`
- `src/modules/assignments/entities/assignment.entity.ts`
- `src/modules/assignments/entities/assignment-submission.entity.ts`
- `src/modules/assignments/dto/upload-assignment-files.dto.ts`
- `src/modules/labs/controllers/labs.controller.ts`
- `src/modules/labs/services/labs.service.ts`
- `src/modules/labs/entities/lab.entity.ts`
- `src/modules/labs/entities/lab-submission.entity.ts`
- `src/modules/labs/entities/lab-instruction.entity.ts`
- `src/modules/labs/dto/index.ts`
- `src/modules/labs/dto/upload-lab-files.dto.ts`

### Website

- `src/services/api/assignmentService.ts`
- `src/services/api/labService.ts`
- `src/pages/student-dashboard/components/assignments/AssignmentsPage.tsx`
- `src/pages/student-dashboard/components/assignments/AssignmentView.tsx`
- `src/pages/student-dashboard/components/assignments/SubmissionForm.tsx`
- `src/pages/student-dashboard/components/assignments/assignmentService.ts`
- `src/pages/student-dashboard/components/labs/LabList.tsx`
- `src/pages/student-dashboard/components/labs/LabView.tsx`
- `src/pages/student-dashboard/components/labs/SubmissionForm.tsx`
- `src/pages/instructor-dashboard/components/instructor-assignments/AssignmentCreateEdit.tsx`
- `src/pages/instructor-dashboard/components/labs/LabsDashboard.tsx`
- `src/pages/instructor-dashboard/components/labs/InstructionEditor.tsx`
- `src/pages/instructor-dashboard/components/labs/hooks/useLabAttendance.ts`
- `src/pages/shared-dashboard/components/SharedAssignmentsPage.tsx`
- `src/pages/shared-dashboard/components/SharedLabsPage.tsx`
- `src/pages/ta-dashboard/TADashboard.tsx`
- `src/pages/ta-dashboard/components/AssignmentGradingPage.tsx`
- `src/pages/ta-dashboard/components/LabResourcesPage.tsx`
- `src/pages/instructor-dashboard/components/labs/TaMaterialUpload.tsx`

### Flutter

- `lib/services/api/assignment_service.dart`
- `lib/services/api/lab_service.dart`
- `lib/screens/student/assignments_screen.dart`
- `lib/screens/student/assignment_detail_screen.dart`
- `lib/widgets/student/assignments/submission_form_sheet.dart`
- `lib/widgets/student/assignments/drive_file_picker.dart`
- `lib/screens/student/labs_screen.dart`
- `lib/screens/student/lab_detail_screen.dart`
- `lib/widgets/student/labs/lab_submission_sheet.dart`
- `lib/bloc/lab_detail/lab_detail_cubit.dart`
- `lib/screens/instructor/assignments/instructor_assignments_screen.dart`
- `lib/screens/instructor/create_assignment_screen.dart`
- `lib/widgets/instructor/assignments/assignment_create_form.dart`
- `lib/widgets/instructor/assignments/instruction_file_uploader.dart`
- `lib/screens/instructor/assignments/assignment_submissions_screen.dart`
- `lib/bloc/instructor/instructor_assignments_cubit.dart`
- `lib/screens/instructor/labs/instructor_labs_screen.dart`
- `lib/screens/instructor/labs/lab_detail_screen.dart`
- `lib/widgets/instructor/labs/lab_create_form.dart`
- `lib/widgets/instructor/labs/instruction_manager.dart`
- `lib/widgets/instructor/labs/attendance_sheet.dart`
- `lib/bloc/instructor/instructor_labs_cubit.dart`
- `lib/bloc/instructor/lab_detail_cubit.dart`
- `lib/screens/ta/courses/ta_course_detail_screen.dart`
- `lib/screens/ta/assignments/ta_assignment_submissions_screen.dart`
- `lib/screens/ta/grading/ta_grading_center_screen.dart`
- `lib/screens/ta/labs/ta_labs_list_screen.dart`
- `lib/screens/ta/labs/ta_lab_detail_screen.dart`
- `lib/bloc/ta/ta_labs_cubit.dart`
- `lib/bloc/ta/ta_assignment_submissions_cubit.dart`
- `lib/screens/ta/lab_resources/ta_lab_resources_screen.dart`
- `lib/config/app_router.dart`
