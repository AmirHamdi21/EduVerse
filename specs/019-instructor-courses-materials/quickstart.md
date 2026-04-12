# Quickstart: Phase 5 — Instructor Courses & Materials Management

**Feature**: 019-instructor-courses-materials
**Date**: April 12, 2026

---

## Prerequisites

1. **Backend running**: `http://<host>:3001` (default port 3001)
2. **Flutter SDK**: 3.x with Dart 3.x
3. **Dependencies installed**: `flutter pub get`
4. **Authenticated user**: Login as an **instructor** role user (not student, not admin)
5. **YouTube OAuth**: Configured by IT Admin (video uploads will fail gracefully if not configured)
6. **Google Drive API**: Configured and accessible (document uploads depend on this)

---

## Setup Steps

### 1. Start the Backend

```bash
# From backend directory
npm run start:dev
# Verify: curl http://localhost:3001/api/courses
```

### 2. Verify Instructor User

```bash
# Login and get JWT token
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "instructor@example.com", "password": "password"}'

# Test teaching courses endpoint
curl http://localhost:3001/api/enrollments/teaching \
  -H "Authorization: Bearer <token>"
```

### 3. Run Flutter App

```bash
# From project root
flutter run
# Or for specific device:
flutter run -d chrome  # Web
flutter run -d windows  # Windows desktop
flutter run -d <device-id>  # Mobile device
```

### 4. Navigate to Instructor Courses

1. Login as instructor
2. Navigate to Courses screen (via drawer or navigation)
3. Verify teaching courses load from API (not mock data)

---

## Verification Checklist

### Teaching Courses Screen
- [ ] Course cards show real data from `GET /enrollments/teaching`
- [ ] Empty state shows when instructor has no teaching assignments
- [ ] Error state with retry option when API fails
- [ ] Course code, name, semester, enrolled count, capacity displayed correctly

### Materials Upload Screen
- [ ] Course selector dropdown populated from teaching courses
- [ ] Text/Link upload creates material with JSON body
- [ ] Document upload shows progress and creates material via FormData `document` field
- [ ] Video upload shows progress bar and creates material via FormData `video` field
- [ ] Bundle upload uploads video + documents sequentially with step-by-step progress
- [ ] Manual bundle grouping option available during upload
- [ ] File validation rejects files exceeding size limits before upload

### Materials Library (Course Management → Materials Tab)
- [ ] Materials grouped by week number
- [ ] Bundles auto-detected by stripping known suffixes from titles
- [ ] YouTube thumbnails visible for video materials
- [ ] Type badges (video, document, link, slide) displayed
- [ ] Toggle visibility (published/unpublished) works
- [ ] Edit title works (individual and bundle-level)
- [ ] Delete works (individual and bundle-level) with confirmation
- [ ] Bundle-level operations show partial-failure handling if some calls fail

### Course Structure Management
- [ ] Create structure item (title + week number)
- [ ] Edit structure item title
- [ ] Reorder structure items
- [ ] Delete structure item (with warning if materials associated)

### Course Detail Screen
- [ ] Overview tab: live stats (student count, avg grade, engagement metrics)
- [ ] Overview tab: upcoming deadlines from assignments and labs APIs
- [ ] Overview tab: section schedules displayed
- [ ] Lectures tab: materials organized by week with bundles
- [ ] Assignments tab: "coming soon" placeholder
- [ ] Grading tab: "coming soon" placeholder
- [ ] Students tab: live student list from sections API

---

## Testing Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widgets/instructor/instructor_courses_screen_test.dart

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format lib/
```

---

## Common Issues

### Video Upload Fails with "YouTube not authorized"
- **Cause**: YouTube OAuth not configured by IT Admin
- **Fix**: Contact IT Admin to configure YouTube integration. Show error message to user.

### Document Upload Fails with 400/500
- **Cause**: Google Drive API issue or invalid file type
- **Fix**: Verify file type is allowed (PDF, DOCX, PPTX, etc.). Retry after checking backend logs.

### Teaching Courses Returns Empty List
- **Cause**: User not assigned as instructor to any course sections
- **Fix**: Use Admin role to assign instructor to a course section via `POST /enrollments/sections/{sectionId}/instructors`

### Materials Not Grouping into Bundles
- **Cause**: Titles don't share a common base after stripping known suffixes
- **Fix**: Ensure titles follow convention: "{BaseTitle} - Video", "{BaseTitle} - Slides", etc.

---

## Key File Locations

| Component | Path |
|-----------|------|
| Instructor Courses Screen | `lib/screens/instructor/courses/instructor_courses_screen.dart` |
| Upload Materials Screen | `lib/screens/instructor/upload_materials/upload_materials_screen.dart` |
| Course Management Screen | `lib/screens/instructor/course_management/course_management_screen.dart` |
| InstructorCoursesBloc | `lib/bloc/instructor/instructor_courses_bloc.dart` |
| MaterialsBloc | `lib/bloc/materials/materials_bloc.dart` |
| CourseStructureBloc | `lib/bloc/course_structure/course_structure_bloc.dart` |
| MaterialService | `lib/services/api/material_service.dart` |
| CourseService | `lib/services/api/course_service.dart` |
| BundleDetector | `lib/utils/bundle_detector.dart` |
| FileValidator | `lib/utils/file_validator.dart` |
