# Student Screens Integration Guide

This guide describes how to connect the existing User Interface widgets for the Student context to the live `CoursesBloc` architecture established in Phase 1.

## Quick Actions

1. **Delete the Mock Models**
   Navigate to `lib/widgets/student/courses/` and completely remove `course_model.dart` and `mock_data.dart` (or similar files containing hardcoded arrays of student courses).
   
2. **Setup BLoC Builder in Core Screens**
   In `lib/screens/student/courses_screen.dart`, wrap the central `ListView`/`Column` in a `BlocBuilder<CoursesBloc, CoursesState>`:
   ```dart
   BlocBuilder<CoursesBloc, CoursesState>(
     builder: (context, state) {
       if (state is CoursesLoading && state.cachedEnrollments == null) {
         return const Center(child: CircularProgressIndicator());
       }
       // Access list logic
       final enrollments = state is CoursesLoaded 
           ? state.enrollments 
           : (state is CoursesLoading ? state.cachedEnrollments ?? [] : []);
       
       if (enrollments.isEmpty) { ... return EmptyStateWidget ... }
       
       return CoursesListView(enrollments: enrollments);
     }
   );
   ```

3. **Update Error States & Tooling**
   Use a `BlocListener` to trap network errors or offline sync issues where cache is already populated, emitting a Snackbar warning: "Offline: Showing cached data".

4. **Pass Live Properties down to Widgets**
   Refactor `CoursesListView` and Course Cards to accept `CourseEnrollmentModel`. Populate frontend UI components strictly driven by `enrollments[index].course`.
