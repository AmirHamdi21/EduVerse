# Qwen Code Context: EduVerse Flutter App

**Project**: EduVerse - Flutter Mobile App
**Date**: April 10, 2026
**Updated**: Phase 2 - Student Courses & Lecture Viewer

## Technology Stack

- **Language**: Dart 3.x with Flutter 3.x
- **State Management**: flutter_bloc (BLoC/Cubit pattern)
- **HTTP Client**: Dio (with CoreApiClient wrapper)
- **Video Playback**: youtube_player_flutter (YouTube embedding)
- **Document Preview**: webview_flutter (Google Drive preview)
- **Downloads**: flutter_downloader + path_provider
- **Caching**: shared_preferences (lightweight), in-memory maps for active sessions
- **Testing**: flutter test (unit, widget, integration)

## Architecture Patterns

### BLoC State Management (Constitution Principle I)
- All UI state driven by BLoC/Cubit classes
- No widget-level API calls
- States: loading, loaded, error, connectionStatus
- Events trigger service calls, emit new states

### Repository Pattern (Constitution Principle II)
- Services: CourseService, MaterialService, EnrollmentService
- All services extend/compose CoreApiClient with Dio
- Domain models separate from API responses
- Factory methods for JSON parsing with safe defaults

### Type Safety Rules (Constitution Principle III)
- Decimal fields: `double.tryParse(value.toString())`
- Enum parsing: `Enum.values.firstWhere(... orElse: default)`
- Paginated responses: `PaginatedResponse<T>` with computed properties
- Safe nullable casting throughout

## New Dependencies (Phase 2)

```yaml
youtube_player_flutter: ^8.1.2    # YouTube video playback
webview_flutter: ^4.4.2           # Google Drive document preview
flutter_downloader: ^1.11.2       # Background downloads
path_provider: ^2.1.1             # Platform storage paths
shared_preferences: ^2.2.2        # Lightweight caching
```

## API Endpoints (Phase 2 Scope)

- `GET /enrollments/my-courses` - Student's enrolled courses
- `GET /courses/{id}/structure` - Week-based course structure
- `GET /courses/{id}/materials` - Course materials list
- `POST /materials/{id}/view` - Record material view

**Timeouts**: 10s standard endpoints, 30s material-related calls

## Feature: Student Courses & Lecture Viewer

### Scope
- View enrolled courses (live API, no mock data)
- Browse course structure (week-based accordion)
- Watch lecture videos (YouTube embedded player)
- View/download documents (Google Drive preview)
- Material bundle viewer (prefix matching algorithm)
- Progress tracking (view count, access indicators)

### Key Files
- `lib/features/courses/` - Feature module (models, services, blocs, screens)
- `lib/widgets/student/course_details/` - Course detail widgets
- `lib/widgets/student/course_list/` - Course list widgets
- Tests mirror source structure under `tests/`

### Constitution Principles Applied
- I. BLoC State Management
- II. Strict Data Layer Separation
- III. Type Safety & Error Handling
- IV. Website Feature Parity (1:1 with website frontend)
- VII. Static Data Elimination (all mock data removed)
- IX. Role-Based Access Control (student read-only)
- X. File Upload & Google Drive/YouTube Integration
- XI. Multi-Phase Plan Adherence (Phase 2 of 10)

## Code Style

- Use `const` constructors for widgets where possible
- Widget classes: `PascalCase` extends `StatelessWidget` or `StatefulWidget`
- BLoC classes: `*Bloc` suffix, events: `*Event`, states: `*State`
- Service classes: `*Service` suffix
- Model classes: `*Model` suffix
- Private helpers: `_camelCase`
- String interpolation: `'Value: $value'` not `'Value: ' + value`

## Testing Standards

- Unit tests for BLoCs, services, models
- Widget tests for screens, widgets
- Integration tests for API flows
- Mock services for testing without live API
- Test files mirror source: `lib/x/y.dart` → `tests/unit/x/y_test.dart`
