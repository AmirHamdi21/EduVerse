# Discussion Forums Quickstart

## Getting Started

1. Ensure the `ChatBloc` or `AuthBloc` injects correct role information into the widget tree.
2. The `DiscussionBloc` should be provided above the respective Role Dashboards, similar to `ChatBloc`.
3. The `DiscussionService` will consume your application's `DioApiClient` configured to endpoint `/api/discussions`.

## Integration Flow

1. Wire up routing `/discussions/:courseId` (or pass `courseId` directly if nested).
2. For global administration tabs (Admin, IT Admin), they won't pass a specific `courseId` or they will have a course dropdown filter to populate `DiscussionBloc`.
3. For individual Course detail tabs (Student, Instructor, TA), pass `courseId` upon entering the `DiscussionScreen` tab.
4. Set the corresponding **UI Accent Colors** and role props via `DiscussionScreen`. No separate implementations allowed.

```dart
// Example routing implementation for a Student:
GoRoute(
  path: 'course/:courseId/discussions',
  builder: (context, state) {
    final courseId = int.parse(state.pathParameters['courseId']!);
    return DiscussionScreen(
      courseId: courseId,
      accentColor: const Color(0xFF3B82F6), // Blue for Student
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  },
),
// Note: Role visibility restrictions (Pin, Lock, etc) are derived dynamically via the current user inside the DiscussionBloc.
```

## Running Tests

All BLoC events and Pagination logic SHOULD be unit tested independently. Ensure you test edge cases for:
- Offset shifting / ID deduplication (`Set`/`List.toSet` matching items on subsequent page loads).
- `isLocked` prevents UI rendering of the reply field and ignores incoming WebSocket events if we had them or disables optimistic dispatch.
