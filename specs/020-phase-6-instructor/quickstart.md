# Quickstart: Phase 6 — Instructor Assignments CRUD & Grading

**Date**: 2026-04-12
**Branch**: `020-phase-6-instructor`

---

## Prerequisites

1. Flutter SDK 3.x installed
2. Dart 3.9.2+ available
3. Backend API running (EduVerse backend on port 3001)
4. Phase 1 completed — `AssignmentService` exists at `lib/services/api/assignment_service.dart`

## Setup

```bash
# 1. Switch to feature branch
git checkout 020-phase-6-instructor

# 2. Install dependencies (no new packages needed)
flutter pub get

# 3. Verify baseline tests pass
flutter test
# Expected: 181 passed, 0 failed

# 4. Verify AssignmentService exists
ls lib/services/api/assignment_service.dart
```

## Key Files to Know

### Services (already exist from Phase 1)
- `lib/services/api/assignment_service.dart` — All assignment API calls
- `lib/services/api/enrollment_service.dart` — Teaching courses list
- `lib/services/api/core_api_client.dart` — Dio wrapper with auth

### Models (already exist from Phase 1)
- `lib/models/assignments/assignment_model.dart` — Assignment entity
- `lib/models/assignments/assignment_submission_model.dart` — Submission entity
- `lib/models/core/enums/assignment_enums.dart` — AssignmentStatus, SubmissionStatus, SubmissionType
- `lib/models/core/drive_file_model.dart` — Google Drive file entity
- `lib/models/instructor/teaching_course_model.dart` — Teaching course entity

### Files to Modify (remove mock data)
- `lib/bloc/instructor/grading_center_cubit.dart` — Remove `_generateDemoCourses()`, `_generateDemoSubmissions()`, replace with live API
- `lib/bloc/instructor/grading_center_state.dart` — Align types
- `lib/models/instructor/submission_model.dart` — Replace with `AssignmentSubmissionModel`
- `lib/models/instructor/grading_model.dart` — Remove mock types
- `lib/config/app_router.dart` — Add routes for new screens

### New Files to Create
- `lib/bloc/instructor/instructor_assignments_cubit.dart`
- `lib/bloc/instructor/instructor_assignments_state.dart`
- `lib/screens/instructor/assignments/instructor_assignments_screen.dart`
- `lib/screens/instructor/assignments/assignment_submissions_screen.dart`
- `lib/screens/instructor/assignments/submission_grading_screen.dart`
- `lib/screens/instructor/create_assignment_screen.dart`
- `lib/widgets/instructor/assignments/` (7 widget files)
- `lib/utils/late_penalty_calculator.dart`

## Development Workflow

```bash
# After making changes, run:
flutter analyze

# Run tests
flutter test

# Run specific test file
flutter test test/unit/bloc/instructor/instructor_assignments_cubit_test.dart

# Run integration test
flutter test test/integration/features/assignments/instructor_assignments_flow_integration_test.dart

# Mock data audit (should return zero matches in modified files)
findstr /S /N /I "_generateDemo\|_generateSample\|_mockMessages\|Duration(hours:" lib\bloc\instructor\grading_center_cubit.dart
```

## UI Preservation Rule

**≥85% visual similarity** — All existing instructor screen colors, layout structure, card designs, navigation patterns, and component hierarchies must remain unchanged. Only replace mock data with live API data and add new screens that follow the existing design language.

## Testing Strategy

1. **Unit tests**: Test cubit state transitions, late penalty calculations, model parsing
2. **Widget tests**: Test screen rendering with mock services, form validation, filter behavior
3. **Integration tests**: Test full flow: select course → view assignments → create assignment → view submissions → grade submission

## Common Gotchas

- `lateSubmissionAllowed` is `int` (0/1), NOT `bool` — parse as `(value as num) == 1`
- `isLate` in submissions is `int` (0/1), NOT `bool` — same parsing rule
- `allowedFileTypes` is a JSON string `'["pdf","zip"]'`, NOT a `List` — parse with `jsonDecode()`
- All decimal fields (`maxScore`, `weight`, `score`, `latePenaltyPercent`) may arrive as strings — always use `double.tryParse(value.toString())`
- FormData uploads: use `Dio.FormData` with `MultipartFile.fromFile()`, do NOT set `Content-Type` manually (Dio auto-generates boundary)
- Pagination: `AssignmentService.getAll()` returns `PaginatedResponse<T>` — use `page` and `limit` params
