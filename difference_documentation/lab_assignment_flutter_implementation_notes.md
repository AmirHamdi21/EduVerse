# Flutter Lab/Assignment Implementation Notes

## Scope

These notes summarize the key Flutter-only decisions made while aligning lab and assignment behavior with the website/backend baseline.

All work was limited to:

- `D:\Graduation\EduVerse\edu_verse`

No backend or website code was modified.

---

## Important Decisions

### 1. Drive behavior for student assignments

The old Flutter flow could make a pseudo-Drive path look like a real file-upload path.

Final Flutter behavior:

- device file upload remains the real file path
- link submission remains the link path
- the misleading Drive-as-file path was removed from the student assignment submission flow

Reason:

- this avoids claiming website-equivalent Drive upload behavior when Flutter does not actually have that integration

### 2. Student lab file validation

Student lab upload validation now uses backend lab configuration instead of hardcoded values.

Final Flutter behavior:

- file-size validation uses `lab.maxFileSizeMb`
- allowed extensions use `lab.allowedFileTypes`
- helper text is rendered from the lab configuration

Reason:

- this matches the backend-driven contract and avoids incorrect hardcoded restrictions

### 3. Assignment and lab list loading

Student assignment and lab list screens now use skeleton-style loading.

Trigger points:

- first screen load
- course filter change

Reference:

- student registration loading style

Reason:

- this prevents stale content from being shown as if it belongs to the newly selected course

### 4. Instructor assignment authoring

The Flutter assignment create/edit flow now includes `availableFrom`.

Final Flutter behavior:

- `availableFrom` is represented in the form model
- `availableFrom` is editable in the create/edit form
- edit mode preserves and displays it correctly
- due date must be after `availableFrom`
- all lifecycle statuses are selectable in the form

### 5. Instructor lab instructions

Invalid generic fallback behavior for lab instruction updates/deletes was removed.

Final Flutter behavior:

- instruction changes rely on valid instruction-oriented backend paths only
- failure states now surface honestly instead of attempting unsupported generic lab updates

### 6. TA assignments

TA assignment management is now exposed through a dedicated top-level route.

Final Flutter behavior:

- `/ta/assignments` is available
- TA drawer links to it
- the page supports:
  - course-based assignment browsing
  - create
  - edit
  - delete
  - status change
  - open submissions
  - jump to grading center

Reason:

- this reduces fragmentation between course detail and grading-only entry points

### 7. TA resources and TA materials

The old TA lab resources screen was a mock placeholder.

Final Flutter behavior:

- the mock screen was replaced with an explicit unsupported/redirecting state
- instructor lab detail exposes TA-material upload using the real existing upload endpoint
- the UI is explicit that Flutter currently does not expose a reliable list/read TA-material library

Reason:

- this keeps the feature honest and avoids fake resource analytics or fake inventories

---

## Verification Summary

Focused verification completed:

- targeted `flutter analyze` on the modified files
- assignment flow regression tests
- instructor lab detail cubit tests
- assignment service/lab upload contract tests
- create assignment widget test

Full-project `flutter analyze` still returns the repository’s pre-existing warning/info backlog outside this work.

