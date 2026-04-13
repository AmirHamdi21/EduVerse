# Quickstart: Phase 7 — Instructor Labs CRUD & Grading

**Date**: 2026-04-13  
**Feature**: Instructor Labs CRUD & Grading  
**Branch**: `021-instructor-labs`

## Getting Started

### Prerequisites

- Flutter 3.x SDK installed
- Dart 3.x available
- Existing EduVerse Flutter project set up (`pubspec.yaml` dependencies installed)
- Phase 1 services completed: `LabService` in `lib/services/api/lab_service.dart`
- Phase 4 student labs completed: `LabModel`, `LabSubmissionModel`, `LabInstructionModel`, `LabAttendanceModel`, enums
- Phase 6 instructor assignments completed: reference patterns in `lib/screens/instructor/assignments/`, `lib/widgets/instructor/assignments/`, `lib/bloc/instructor/instructor_assignments_*`

### Dependencies

No new pub dependencies needed. Phase 7 reuses existing packages:
- `flutter_bloc` — state management
- `dio` — HTTP client (already used by LabService)
- `webview_flutter` — Google Drive preview (already in pubspec.yaml)
- `flutter_markdown` — markdown rendering (already in pubspec.yaml)
- `file_picker` — file selection (already in pubspec.yaml)
- `shared_preferences` — caching (already in pubspec.yaml)

### Running the App

```bash
# From project root (C:\Users\Friends\Desktop\Graduation\EduVerse)
flutter pub get
flutter run
```

### Testing the Feature

1. **Build and run** the app on an emulator or physical device
2. **Log in** as an instructor user (not student, TA, or admin)
3. **Navigate** to the Instructor Labs screen (route: `/instructor/labs`)
4. **Create a lab**: Tap "Create New Lab", fill in title + course, save
5. **Add instructions**: Open lab detail, add text instruction and upload a file instruction
6. **View submissions**: (Requires student submissions — test with existing data or create test submissions via API)
7. **Grade a submission**: Open grading panel, enter score + feedback, save
8. **Mark attendance**: Open attendance sheet, toggle statuses, save
9. **Edit/delete**: Edit lab details, verify changes persist. Delete lab, verify confirmation and removal

### Running Tests

```bash
# Run all tests
flutter test

# Run only Phase 7 tests
flutter test test/unit/bloc/instructor/instructor_labs_cubit_test.dart
flutter test test/unit/bloc/instructor/lab_detail_cubit_test.dart

# Run integration test (if created)
flutter test test/integration/features/labs/instructor_labs_flow_integration_test.dart
```

### Verifying UI Parity

1. Open the **website frontend** at `C:\Users\Friends\Desktop\Graduation\Frontend\Eduverse-Frontend` and navigate to Instructor → Labs
2. Compare the Flutter mobile labs screen with the website labs dashboard:
   - Same card/list structure (adapted for mobile)
   - Same status badge colors
   - Same form fields in create/edit
   - Same grading panel layout (slide-over on website → bottom sheet on mobile)
   - Same attendance sheet structure
3. Verify ≥85% visual similarity using the visual parity checklist

### Key Files to Know

| Purpose | File |
|---|---|
| Main labs list screen | `lib/screens/instructor/labs/instructor_labs_screen.dart` |
| Lab detail screen | `lib/screens/instructor/labs/lab_detail_screen.dart` |
| Labs cubit (list state) | `lib/bloc/instructor/instructor_labs_cubit.dart` |
| Lab detail cubit | `lib/bloc/instructor/lab_detail_cubit.dart` |
| Lab service (API calls) | `lib/services/api/lab_service.dart` |
| Lab model | `lib/models/labs/lab_model.dart` |
| Lab submission model | `lib/models/labs/lab_submission_model.dart` |
| App routes | `lib/config/app_router.dart` |
| Late penalty calculator | `lib/utils/late_penalty_calculator.dart` |

### Troubleshooting

| Issue | Solution |
|---|---|
| "LabService not found" | Ensure Phase 1 is complete: `lib/services/api/lab_service.dart` exists |
| "403 Forbidden on lab creation" | Verify logged-in user has `instructor` role and is enrolled as teacher for the selected course |
| "File upload fails" | Check Dio FormData field name is `file` (not `File` or `attachment`). Do NOT set Content-Type manually |
| "Drive preview not loading" | Verify `iframeUrl` from backend is a valid Google Drive preview URL (contains `/preview` path) |
| "Late penalty not showing" | Verify lab has `dueDate` set and submission `submittedAt` is after `dueDate`. Check `isLate` is `true` |
| "Mock data still visible" | Run grep for `_generateSample`, `_mockLabs`, hardcoded `List<Lab>` literals in instructor labs files — should return zero matches |
