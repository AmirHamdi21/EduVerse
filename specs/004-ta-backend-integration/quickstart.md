# Quickstart: TA Backend Integration

## Summary
The TA integration pulls data directly using the `EnrollmentService` mapped to `/api/enrollments/teaching` and strictly uses `CoursesBloc` for storing the states.

## Getting Started

1. Ensure your backend is running and `eduverse_db` is populated with a TA assignment mapping.
2. Login to the application utilizing an account with the TA role.
3. Observe the loading skeletons.
4. Once loaded, the TA views replicate instructor layouts but safely omit elevated actions.
