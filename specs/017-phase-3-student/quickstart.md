# Quick Start: Phase 3 — Student Assignments

**Date**: 2026-04-11

---

## Prerequisites

1. **Phase 1 complete**: `AssignmentService`, `AssignmentModel`, `AssignmentSubmissionModel`, and enums already exist in the codebase
2. **Flutter SDK 3.x** installed
3. **Backend running** on `http://<host>:3001` with assignments seeded
4. **Authenticated session**: Student user with active JWT token
5. **Enrolled in courses**: Student must have at least one course section with "enrolled" status

---

## Running the Feature

### 1. Start the Flutter app

```bash
flutter run
```

### 2. Navigate to Assignments

From the student dashboard, tap the **Assignments** navigation item.

### 3. Expected Behavior

- **Loading state**: Skeleton loader or circular progress indicator
- **Loaded state**: List of assignments from enrolled courses with stats cards (Total, Submitted, Pending, Overdue)
- **Empty state**: Message indicating no assignments if none exist
- **Filter**: Tap All/Submitted/Pending/Overdue buttons to filter the list
- **Search**: Type in the search bar to filter by title/description
- **Detail**: Tap an assignment card → full-screen detail view opens
- **Submit**: Tap "Submit" button → modal bottom sheet appears with appropriate input
- **View grade**: If submission is graded, score and feedback are displayed

---

## Key Files Modified/Created

| File | Action | Purpose |
|---|---|---|
| `lib/bloc/assignments/assignment_bloc.dart` | CREATE | BLoC for assignment state management |
| `lib/bloc/assignments/assignment_event.dart` | CREATE | Events: FetchAssignments, SelectAssignment, SubmitAssignment |
| `lib/bloc/assignments/assignment_state.dart` | CREATE | States: Initial, Loading, Loaded, Error |
| `lib/screens/student/assignments_screen.dart` | MODIFY | Replace mock data with BLoC integration |
| `lib/widgets/student/assignments/assignment_list_card.dart` | CREATE | Individual assignment card widget |
| `lib/widgets/student/assignments/assignment_detail_body.dart` | CREATE | Detail content layout |
| `lib/widgets/student/assignments/submission_form_sheet.dart` | CREATE | Modal bottom sheet for submission |
| `lib/widgets/student/assignments/my_submission_view.dart` | CREATE | Display existing submission and grade |

---

## Testing the Feature

### Unit Tests

```bash
flutter test tests/unit/bloc/assignments/assignment_bloc_test.dart
flutter test tests/unit/services/assignment_service_test.dart
flutter test tests/unit/models/assignment_model_test.dart
```

### Widget Tests

```bash
flutter test tests/widget/screens/assignments_screen_test.dart
```

### Manual Testing Checklist

- [ ] Assignment list loads from backend (no mock data)
- [ ] Stats cards show correct counts (Total, Submitted, Pending, Overdue)
- [ ] Status filter buttons work correctly
- [ ] Search bar filters by title/description
- [ ] Empty state shows when no assignments exist
- [ ] Tapping assignment card opens detail screen
- [ ] Detail screen shows title, due date, max score, submission type, status
- [ ] Markdown instructions render correctly
- [ ] Instruction files show inline preview + Open/Download links
- [ ] Submission form appears as modal bottom sheet
- [ ] Text submission works
- [ ] Link submission works with URL validation
- [ ] File submission works with local file picker
- [ ] File size validation prevents oversized uploads
- [ ] File type validation prevents wrong types
- [ ] Late submission warning displays when applicable
- [ ] Blocked submission when past deadline and late not allowed
- [ ] Existing submission displays correctly (content, score, feedback)
- [ ] Late badge shows on late submissions
- [ ] Resubmission option available when graded
- [ ] UI maintains ≥85% visual similarity to pre-integration state
- [ ] Screen works at 375px, 768px, and 1024px+ widths
- [ ] All touch targets are minimum 48x48 logical pixels
