# Quickstart: Student Courses & Lecture Viewer

**Phase**: 1 - Design & Contracts
**Date**: April 10, 2026
**Feature**: Student Courses & Lecture Viewer

## Prerequisites

- Flutter SDK 3.x installed
- Dart 3.x installed
- Backend API running on `http://localhost:3001` (EduVerse backend)
- Valid student account credentials
- Android emulator / iOS simulator or physical device

## Setup Steps

### 1. Add Dependencies

Add the following to `pubspec.yaml`:

```yaml
dependencies:
  youtube_player_flutter: ^8.1.2
  webview_flutter: ^4.4.2
  flutter_downloader: ^1.11.2
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  flutter_bloc: ^8.1.3
  dio: ^5.4.0
  equatable: ^2.0.5
```

Run:
```bash
flutter pub get
```

### 2. Platform-Specific Configuration

#### Android

**`android/app/src/main/AndroidManifest.xml`**:

Add internet permission (if not already present):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**`android/app/build.gradle`**:

Enable Java 8+ desugaring (required for youtube_player_flutter):
```gradle
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
        coreLibraryDesugaringEnabled true
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.2.2'
}
```

#### iOS

**`ios/Runner/Info.plist`**:

Add storage permissions for downloads:
```xml
<key>NSDownloadsFolderUsageDescription</key>
<string>Download course materials for offline access</string>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

### 3. Initialize Flutter Downloader

In `main.dart` or app initialization:

```dart
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FlutterDownloader.initialize(
    debug: true, // Set false in production
    ignoreSsl: false,
  );
  
  runApp(const EduVerseApp());
}
```

### 4. Register Services and BLoCs

In your dependency injection setup (e.g., `get_it` or manual):

```dart
// Services
final courseService = CourseService(coreApiClient: coreApiClient);
final materialService = MaterialService(coreApiClient: coreApiClient);
final enrollmentService = EnrollmentService(coreApiClient: coreApiClient);

// BLoCs
final courseListBloc = CourseListBloc(enrollmentService: enrollmentService);
final courseDetailBloc = CourseDetailBloc(
  courseService: courseService,
  materialService: materialService,
);
final materialViewerBloc = MaterialViewerBloc(
  materialService: materialService,
);
```

### 5. Test the Feature

#### Test Course List

1. Login as a student with enrolled courses
2. Navigate to Courses screen
3. Verify:
   - Course list loads from API (no mock data)
   - Each course shows: code, name, instructor, schedule
   - Loading indicator appears during API call
   - Error message shown if API fails

```bash
# Run widget tests
flutter test tests/widget/features/courses/course_list_screen_test.dart

# Run unit tests
flutter test tests/unit/features/courses/services/enrollment_service_test.dart
```

#### Test Course Structure

1. Tap on a course from the list
2. Verify:
   - Course detail screen opens with tabs (Structure, Materials, Progress)
   - Week accordion displays on Structure tab
   - First week auto-expanded
   - Materials grouped correctly (bundles detected)

```bash
flutter test tests/widget/features/courses/course_detail_screen_test.dart
flutter test tests/unit/features/courses/bloc/course_detail_bloc_test.dart
```

#### Test Video Playback

1. Tap on a video material in course structure
2. Verify:
   - YouTube video plays in embedded player
   - Playback controls work (play, pause, seek, fullscreen)
   - View recorded via `POST /materials/{id}/view`
   - Video thumbnail displays in list view

```bash
flutter test tests/widget/features/courses/video_player_widget_test.dart
```

#### Test Document Preview

1. Tap on a document material
2. Verify:
   - Document opens in WebView preview (Google Drive)
   - Zoom/scroll gestures work
   - Download button available
   - Download progress shown in UI

```bash
flutter test tests/widget/features/courses/document_preview_widget_test.dart
```

#### Test Offline/Caching

1. Load course structure once
2. Disconnect network (airplane mode)
3. Reload course
4. Verify:
   - Cached structure displays with "Showing cached data" banner
   - No crash or infinite loading
   - Retry button available

### 6. API Verification

Test backend API endpoints directly:

```bash
# Get enrolled courses
curl -H "Authorization: Bearer <student_token>" \
  http://localhost:3001/enrollments/my-courses

# Get course structure
curl -H "Authorization: Bearer <student_token>" \
  http://localhost:3001/courses/5/structure

# Get course materials
curl -H "Authorization: Bearer <student_token>" \
  http://localhost:3001/courses/5/materials

# Record material view
curl -X POST \
  -H "Authorization: Bearer <student_token>" \
  -H "Content-Type: application/json" \
  -d '{"courseId": 5}' \
  http://localhost:3001/materials/101/view
```

### 7. Mock Data Audit

Verify all static data has been eliminated:

```bash
# Search for residual mock patterns in modified files
grep -r "_generateSample" lib/features/courses/
grep -r "_mockCourses" lib/widgets/student/
grep -r "Duration(hours:" lib/features/courses/
grep -r "TODO: Replace with API" lib/features/courses/
```

All commands should return **no results**. If any mock patterns found, they MUST be eliminated before phase completion.

### 8. Responsive Testing

Test at all breakpoints:

```bash
# Mobile portrait (375px)
flutter run --web-browser-flag "--window-size=375,812"

# Tablet portrait (768px)
flutter run --web-browser-flag "--window-size=768,1024"

# Desktop (1024px+)
flutter run --web-browser-flag "--window-size=1280,800"
```

Verify:
- All layouts adapt correctly at each breakpoint
- Touch targets remain minimum 48x48px
- No horizontal scrolling on mobile
- Video player and document preview resize appropriately
- Week accordion readable at all sizes

## Common Issues

### Issue: YouTube player not loading

**Solution**: Ensure `youtube_player_flutter` is properly configured and video URL is valid YouTube format. Check that `videoId` extraction regex matches URL pattern.

### Issue: Google Drive preview shows blank

**Solution**: Verify Drive file has correct permissions (must be accessible to anyone with link or authenticated user). Check that preview URL uses `/preview` not `/view`.

### Issue: Bundle detection not grouping materials

**Solution**: Check that material titles share common prefix before first `(`, `-`, or `[`. Example: "Week 1 - Video" and "Week 1 - Slides" should both normalize to "Week 1 ".

### Issue: Downloads not starting on Android

**Solution**: Verify storage permissions granted at runtime. Check that `flutter_downloader` initialized in `main()`. Ensure download URL is valid.

## Next Steps

After successful testing:
1. Run full test suite: `flutter test`
2. Run linting: `flutter analyze`
3. Run formatter: `dart format .`
4. Proceed to implementation tasks (Phase 2 via `/speckit.tasks`)
