# Phase 0: Research

All `NEEDS CLARIFICATION` items were successfully resolved during the prior iteration (`/speckit.clarify`).

- **Decision**: Use `TeachingCourseModel` natively mapped from backend for instructor assignments.
- **Rationale**: Based on API Docs resolution Option C, the endpoint `GET /api/enrollments/teaching` returns a streamlined `TeachingCourseModel` excluding student-specific enrollment details like grades or statuses.
- **Alternatives considered**: Mocking student-specific fields to force `EnrollmentModel` reuse. Rejected as it couples instructor logic to student state unnecessarily and violates architectural clarity.

- **Decision**: Implement offline caching via `HydratedBloc`.
- **Rationale**: Achieves feature parity with Phase 2 Student dashboard design for offline UX, maintaining consistency across roles.
