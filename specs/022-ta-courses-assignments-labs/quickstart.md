# Quickstart: TA — Courses, Assignments & Labs Integration

**Date**: 2026-04-14

## Running the App

```bash
# From project root
flutter run
```

## Testing TA Features

### Prerequisites

1. **TA User Account**: Ensure a user with `teaching_assistant` role exists in the backend and is assigned to at least one course section.
2. **Backend Running**: Backend must be running on configured port (default `3001`).
3. **Login**: Log in with the TA user credentials.

### Testing TA Course List

1. Navigate to **Courses** from TA dashboard
2. Verify courses appear from live API (no mock data)
3. Tap a course to open detail screen with 9 sub-tabs
4. Verify each sub-tab attempts API fetch and shows appropriate state (data, empty, error)

### Testing TA Assignment Management

1. Navigate to a course's **Assignments** sub-tab
2. Tap **Create Assignment** → form opens (reuses Instructor form)
3. Fill fields and submit → verify assignment appears in list
4. Tap assignment → view submissions
5. Select a pending submission → enter score (0-maxScore, step 0.5) and feedback → save
6. Verify submission status updates to "graded"

### Testing TA Lab Management

1. Navigate to **Labs** from TA dashboard
2. Verify labs appear from live API (no mock data)
3. Tap **Create Lab** → form opens (reuses Instructor form)
4. Fill fields and submit → verify lab appears in list
5. Tap lab → view detail with submissions tab
6. Select pending submission → grade → verify status updates
7. Open attendance → mark student status → save → verify persistence

### Testing File Upload

1. Open a lab detail → navigate to instructions management
2. Upload an instruction file → verify it appears with preview/download links
3. Upload a TA material → verify it is not visible to students

## Running Tests

> **Note**: Test directories `test/unit/bloc/ta/`, `test/unit/models/assignments/`,
> `test/unit/models/labs/`, and `test/widget/ta/` will be **created as part of this phase's
> implementation** (T027, T038 add model unit tests; no pre-existing TA test files). Running
> `flutter test test/unit/bloc/ta/` before those files are created will exit silently with
> zero tests (not a failure). Always run `flutter test` (all tests) to confirm no regressions.

```bash
# Unit tests for TA Cubits (created during Phase 2)
flutter test test/unit/bloc/ta/

# Model unit tests for isLate parsing (created by T027 and T038)
flutter test test/unit/models/assignments/
flutter test test/unit/models/labs/

# Widget tests for TA screens (created during Phase 3)
flutter test test/widget/ta/

# All tests — use this to confirm no regressions after each phase
flutter test
```

## Key Files Modified/Created

| File | Purpose |
|---|---|
| `lib/screens/ta/courses/ta_courses_list_screen.dart` | Course list (live API) |
| `lib/screens/ta/courses/ta_course_detail_screen.dart` | Course detail (9 sub-tabs) |
| `lib/screens/ta/labs/ta_labs_list_screen.dart` | Labs list (live API) |
| `lib/screens/ta/labs/ta_lab_detail_screen.dart` | Lab detail (grading, attendance) |
| `lib/bloc/ta/ta_courses_cubit.dart` | TA course BLoC |
| `lib/bloc/ta/ta_labs_cubit.dart` | TA labs BLoC |
| `lib/widgets/ta/courses/ta_course_overview_tab.dart` | Overview sub-tab |
| 7 new sub-tab widgets | Sections & Labs, Lectures, Materials, Assignments, Grading, Attendance, Students, Announcements |

## Troubleshooting

| Issue | Solution |
|---|---|
| "No courses found" | Verify TA is assigned to at least one section via backend |
| 403 Forbidden on assignment creation | Verify user has `teaching_assistant` role in JWT |
| Empty sub-tabs | Expected if backend has no data for that endpoint; check backend logs |
| File upload fails | Check file size (50MB docs, 10MB images max), verify Google Drive auth |
| Mock data still showing | Run mock audit: grep for `_generateSample`, `_mock`, `Future.delayed` in TA files |
