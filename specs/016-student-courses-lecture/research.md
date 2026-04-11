# Research: Student Courses & Lecture Viewer

**Phase**: 0 - Outline & Research
**Date**: April 10, 2026
**Feature**: Student Courses & Lecture Viewer

## Research Tasks

### Task 1: YouTube Embedding Strategy in Flutter

**Decision**: Use `youtube_player_flutter` package for video playback with WebView fallback

**Rationale**: 
- `youtube_player_flutter` provides native-like YouTube controls, automatic quality selection, fullscreen support, and handles YouTube iframe API complexities
- More reliable than raw WebView for YouTube-specific features (quality selection, captions, playback speed)
- WebView fallback available for edge cases where package fails (deleted videos, region restrictions)
- Aligns with website frontend's YouTube iframe embedding approach
- Package is well-maintained and widely used in Flutter apps

**Alternatives considered**:
1. **Raw WebView with YouTube embed URL**: Simpler but lacks YouTube-specific controls, may have issues with YouTube's iframe restrictions in WebViews
2. **video_player package with direct video URL**: Cannot use YouTube URLs directly, requires separate video hosting infrastructure
3. **External browser via url_launcher**: Breaks user flow by leaving the app, poor UX for inline viewing

**Implementation notes**:
- Extract `videoId` from `material.externalUrl` (YouTube URLs follow pattern: `https://youtube.com/watch?v={videoId}` or `https://youtu.be/{videoId}`)
- Use `YoutubePlayerController` with `autoPlay: false` to respect user's decision to tap before playing
- Handle errors: show "Video unavailable" message if video deleted/private
- Track view via `POST /materials/{id}/view` when user taps to play

---

### Task 2: Google Drive Document Preview Strategy

**Decision**: Use `webview_flutter` with Google Drive preview URL (`https://drive.google.com/file/d/{fileId}/preview`)

**Rationale**:
- Google Drive provides built-in preview rendering via iframe-compatible URLs
- WebView allows inline viewing without leaving the app
- Supports zoom/scroll gestures natively on mobile
- Matches website frontend's approach (renders `<iframe src="{driveViewUrl/preview}">`)
- No authentication required if files are properly permissioned for enrolled students

**Alternatives considered**:
1. **Download and render locally with syncfusion_flutter_pdf or similar**: Complex, requires implementing PDF/document rendering, violates inline preview requirement
2. **Open in external browser via url_launcher**: Breaks user flow, requires app switching, poor UX
3. **Google Drive API with file content download**: Requires additional OAuth setup, complex permission handling

**Implementation notes**:
- Extract Drive file ID from `material.file.driveId` or from URL
- Construct preview URL: `https://drive.google.com/file/d/{fileId}/preview`
- Use `WebViewController` with JavaScript enabled for full preview functionality
- Handle errors: show "Access denied - contact instructor" if permissions insufficient
- Show loading indicator while preview loads
- Provide download button separate from preview (uses `material.file.downloadUrl`)

---

### Task 3: Material Bundle Matching Algorithm (Prefix Matching)

**Decision**: Implement client-side prefix matching by normalizing titles (strip after first parenthesis, hyphen, or bracket)

**Rationale**:
- Backend has no explicit bundle ID; bundles must be detected client-side
- Prefix matching handles common instructor naming patterns:
  - "Week 1 - Introduction", "Week 1 - Slides", "Week 1 - Notes" → all match prefix "Week 1 "
  - "Lecture 5 (Video)", "Lecture 5 (Slides.pdf)", "Lecture 5 (Code)" → all match prefix "Lecture 5 "
- Simple, deterministic, fast (no fuzzy matching overhead)
- Predictable behavior for instructors and students

**Alternatives considered**:
1. **Exact match only**: Too strict, would fail to group materials with slight naming variations
2. **Fuzzy matching (similarity scoring)**: Overly complex, may produce false positives, harder to debug
3. **Backend-defined bundle IDs**: Requires backend schema changes, out of scope for Phase 2

**Implementation notes**:
```dart
String normalizeTitle(String title) {
  // Strip text after first parenthesis, hyphen, or bracket
  final regex = RegExp(r'^[^()\-[\]]+');
  final match = regex.firstMatch(title.trim());
  return match?.group(0)?.trim() ?? title.trim();
}

// Group materials by normalized prefix
Map<String, List<CourseMaterial>> groupIntoBundles(List<CourseMaterial> materials) {
  final groups = <String, List<CourseMaterial>>{};
  for (final material in materials) {
    final prefix = normalizeTitle(material.title);
    groups.putIfAbsent(prefix, () => []).add(material);
  }
  // Only treat as bundle if 2+ materials share prefix
  return groups.map((key, value) => 
    MapEntry(key, value.length >= 2 ? value : []))
    ..removeWhere((key, value) => value.isEmpty);
}
```
- Video materials prioritized as primary preview in bundle
- Documents listed as companion materials selectable within bundle viewer
- Display bundle count in week accordion (e.g., "3 materials" vs "1 video + 2 documents")

---

### Task 4: Caching Strategy for Course Structure

**Decision**: Use `shared_preferences` for lightweight metadata caching, with in-memory cache for active course structure during session

**Rationale**:
- Course structure changes infrequently (instructors update weekly at most)
- `shared_preferences` provides persistent cache across app restarts
- In-memory cache (`Map<String, CourseStructure>`) avoids repeated serialization during active viewing
- Fast subsequent loads (<1s vs 2-3s for fresh API call)
- Simple key-value storage sufficient for structure data (no complex queries needed)
- Aligns with existing Flutter app patterns

**Alternatives considered**:
1. **Hive database**: Overkill for this use case, adds dependency complexity, better for large datasets
2. **No caching**: Violates FR-018 (faster subsequent loads), poor UX on slow connections
3. **SQLite (sqflite)**: Excessive for simple structure caching, requires migration management

**Implementation notes**:
- Cache key: `course_structure_{courseId}_{lastUpdatedHash}`
- Store serialized JSON string of course structure in `shared_preferences`
- Invalidate cache when:
  - User manually pulls to refresh
  - Backend returns newer `updatedAt` timestamp
  - User logs out (clear all course caches)
- Fallback to cache on network failure with "Showing cached data" banner
- Cache size limit: keep last 10 viewed courses, evict oldest on overflow
- TTL (time-to-live): 7 days (force refresh weekly to catch instructor updates)

---

### Task 5: Download Management for Offline Access

**Decision**: Use `flutter_downloader` package with `path_provider` for managing offline document downloads

**Rationale**:
- `flutter_downloader` provides native download manager integration (Android DownloadManager, iOS NSURLSessionDownloadTask)
- Background downloads continue even if app minimized
- Built-in progress tracking, pause/resume, retry on failure
- System notification for download completion (mobile standard)
- `path_provider` provides platform-appropriate storage paths (Documents/Downloads directory)
- Aligns with mobile OS download patterns

**Alternatives considered**:
1. **Dio direct download**: Simpler but no background execution, stops if app minimized, no system notifications
2. **flutter_file_downloader**: Less mature, fewer features than flutter_downloader
3. **No download feature**: Violates FR-006 (offline access requirement), poor UX for students with limited connectivity

**Implementation notes**:
- Download button on document material cards/preview viewer
- Show download progress in UI (linear progress bar)
- Store downloaded file metadata in `shared_preferences` for offline access list
- Provide "Downloads" section in course detail screen for accessing offline materials
- Handle storage permissions (Android runtime permission, iOS Info.plist configuration)
- Validate file integrity after download (check file size matches expected)
- Delete downloaded files when user clears cache or unenrolls from course

---

## Summary of Decisions

| Unknown | Decision | Impact |
|---------|----------|--------|
| YouTube embedding | `youtube_player_flutter` with WebView fallback | Video playback UX, package dependency |
| Drive document preview | `webview_flutter` with `/preview` URL | Document viewing UX, package dependency |
| Bundle matching | Client-side prefix matching (strip after `(`, `-`, `[`) | No backend changes, deterministic grouping |
| Caching strategy | `shared_preferences` + in-memory cache | Fast subsequent loads, offline support |
| Download management | `flutter_downloader` + `path_provider` | Background downloads, offline access |

## Dependencies to Add

Add to `pubspec.yaml`:
```yaml
dependencies:
  youtube_player_flutter: ^8.1.2  # YouTube video playback
  youtube_player_iframe: ^4.0.4   # Alternative iframe-based player (if needed)
  webview_flutter: ^4.4.2         # Google Drive document preview
  flutter_downloader: ^1.11.2     # Background download management
  path_provider: ^2.1.1           # Platform storage paths
  shared_preferences: ^2.2.2      # Lightweight caching
  flutter_bloc: ^8.1.3            # State management (already in project)
  dio: ^5.4.0                     # HTTP client (already in project)
```

## Next Steps

- Proceed to Phase 1: Design & Contracts
- Generate `data-model.md` with all entities, fields, validation rules
- Generate API contracts in `/contracts/` directory
- Generate `quickstart.md` for testing setup
