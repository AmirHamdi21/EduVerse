# Quickstart: Student Labs Integration

**Feature**: 018-student-labs
**Date**: 2026-04-11

---

## Prerequisites

1. **Backend running**: EduVerse backend API must be running on `http://<host>:3001`
2. **Student account**: Test with a student user account that is enrolled in at least one course with published labs
3. **Phase 1 complete**: `LabService`, `EnrollmentService`, and all domain models must exist and compile
4. **Dependencies installed**: Run `flutter pub get` to ensure all packages are available

## Required Dependencies

New dependencies for this feature:

```yaml
flutter_markdown: ^0.6.18    # Markdown rendering for lab instructions
file_picker: ^6.1.1          # File picker for lab submission uploads
```

Add to `pubspec.yaml` and run `flutter pub get`.

## Testing Setup

### 1. Create Test Data (Backend)

Via backend API or admin panel, ensure the following exists:

- A course with at least 2 published labs
- Each lab should have:
  - At least 1 text instruction (markdown formatted)
  - At least 1 attached Google Drive file (instruction file)
  - A due date in the future (for active submission testing)
  - A due date in the past (for late submission testing)

### 2. Test Student Account

Log in as a student user who is:
- Enrolled in the test course (status = `enrolled`)
- Has NOT yet submitted the test labs (for fresh submission testing)
- Optionally: has an existing graded submission (for grade viewing testing)

### 3. Run the App

```bash
flutter run
```

Navigate to the **Labs** tab on the student dashboard.

## Testing Checklist

### Labs List Screen
- [ ] Course selector dropdown shows enrolled courses from API (no mock data)
- [ ] Selecting a course loads its labs from backend
- [ ] Labs display with correct title, lab number, due date, max score, status badge
- [ ] Empty state shows when course has no labs
- [ ] Search and filter work with live data
- [ ] Stat cards (Upcoming, In Progress, Completed, Missed) show accurate counts
- [ ] Tapping a lab opens the full-screen LabDetailScreen

### Lab Detail Screen
- [ ] Lab title, description, metadata display correctly
- [ ] Text instructions render with markdown formatting
- [ ] Instruction files display in a grid with "Open" and "Download" buttons
- [ ] Instruction file previews load in WebView
- [ ] Attendance badge shows if student was marked present
- [ ] "Submit" button is visible for published labs
- [ ] "Submit" button is hidden/disabled for closed/archived labs
- [ ] Late warning shows when submitting past due date

### Lab Submission
- [ ] Tapping "Submit" opens bottom sheet
- [ ] Text input (textarea) works for text submission
- [ ] File picker opens and allows file selection
- [ ] File upload shows progress indicator
- [ ] Submission succeeds and confirmation is shown
- [ ] Late submission is marked with "Late" indicator
- [ ] File validation rejects oversized/unsupported files with clear error

### Submission History
- [ ] All submission attempts are visible
- [ ] Graded submissions show score and feedback
- [ ] Pending submissions show "Submitted" status
- [ ] Late submissions show "Late" badge
- [ ] Multiple attempts are distinguishable

### Error States
- [ ] Network error shows retry option on labs list
- [ ] Network error shows retry option on lab detail
- [ ] Failed submission shows error message with retry option
- [ ] Google Drive file loading failure shows "Open in Drive" fallback

## Known Limitations

- **Backend enrollment check missing**: The backend does NOT validate enrollment for lab submissions. Frontend implements its own validation as a compensating control.
- **No attempt limit**: Students can submit unlimited attempts (no server-side cap enforced).
- **No resubmission restriction**: Graded submissions can be resubmitted (no server-side lock).

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Labs list shows empty | Verify student is enrolled in a course with published labs; check `GET /labs?courseId={id}` response |
| File preview not loading | Verify `DriveFileModel.iframeUrl` is valid; check WebView JavaScript is enabled |
| Submission fails with 400 | Check lab status — must be `published`; check due date logic |
| File upload fails | Verify file size < 50MB; check Google Drive integration is configured on backend |
| Markdown not rendering | Verify `flutter_markdown` package is installed; check `instructionText` contains valid markdown |
