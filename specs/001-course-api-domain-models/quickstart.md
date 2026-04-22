# Quickstart: Injecting the Course Network Layer

This document establishes the patterns for how UI engineers should use the newly built Domain Models and BLoC layer inside the Flutter app.

### 1. Initialize the BLoC with the Repository
In your main configuration or provider scope (`main.dart` or route level), provide the `CoursesBloc` with the configured `Dio` client.

```dart
// Provided globally or lazily at the Dashboard route level
BlocProvider(
  create: (context) => CoursesBloc(
    courseService: CourseService(coreApiClient: locator<CoreApiClient>()),
  )..add(StudentCoursesFetched()), // Or InstructorCoursesFetched()
  child: const CoursesScreen(),
)
```

### 2. Consuming States in the UI
Widgets must dynamically adjust based on the current `CoursesState` instead of falling back to the old static arrays.

```dart
BlocBuilder<CoursesBloc, CoursesState>(
  builder: (context, state) {
    if (state is CoursesLoading) {
      if (state.cachedData.isNotEmpty) {
        return _buildList(state.cachedData); // Offline resilience logic
      }
      return const SkeletonLoader(); // Or CircularProgressIndicator()
    } else if (state is CoursesLoaded) {
      return _buildList(state.courses);
    } else if (state is CoursesError) {
      return ErrorDisplayWidget(message: state.message);
    }
    return const SizedBox.shrink();
  },
)
```

### 3. Creating New Models (Data Layer rules)
When pulling data, always create models via the `fromJson` factory methods to guarantee type-safety. Never pass raw JSON `Map<String, dynamic>` payloads beyond the Service repository layer.
