<!--
SYNC IMPACT REPORT
- Version Change: 1.0.0 -> 1.0.1
- Modified Principles: Clarified backend integration constraints by explicitly adding local project paths.
- Added Sections: N/A
- Removed Sections: N/A
- Templates Requiring Updates: ✅ Up to date
- Follow-up TODOs: Determine exact error crashlytics tracking mechanism.
-->
# EduVerse Flutter Courses Integration Constitution

## Core Principles

### I. BLoC State Management First
All UI state must be driven by reactive BLoC or Cubit classes.
Widgets must never perform raw data fetching; they should exclusively listen to `BlocBuilder` or `BlocConsumer` states (`loading`, `loaded`, `error`). The UI must be separated from the business logic entirely.

### II. Strict Data Layer Separation
Domain models must be strictly separated from raw API response handling.
Every feature starts with strongly typed Dart models mirroring the exact `eduverse_db.sql` schema and React frontend shapes. You must implement the Repository pattern utilizing services (e.g. `CourseService`, `EnrollmentService`).

### III. Type Safety & Error Handling
All API interactions must guarantee type safety and gracefully handle errors.
Models should utilize robust factory methods for JSON parsing. Network failures, parsing errors, or missing relationships must fail predictably and bubble up safe error states to the UI rather than throwing unhandled exceptions.

### IV. UI/UX Consistency
The interface must adhere to the existing EduVerse design language.
The integration replaces static mock data but must preserve or enhance the existing responsive widget structures across Student, Instructor, and TA dashboards. Loading skeletons must be used during `loading` states.

### V. Testable Architecture
All services, repositories, and BLoCs must be constructed to be completely testable.
Repositories must be injectable to allow for mocking, ensuring that logic can be tested independently of the UI and network layers.

## Backend Integration Constraints

All backend integration must precisely follow the phases and structures dictated in `courses_backend_integration_plan.md`. The domain models constructed in Flutter must match the properties and behaviors defined in the React Web frontend (`Eduverse-Frontend`) to ensure exact feature parity.

For strict alignment, the implementation MUST reference the following local environment paths to ensure complete parity with the web version and established backend routes:
- **Backend Path:** `D:\Graduation\backend\last_backend\EduVerse_Backend`
- **Frontend Website Path:** `D:\Graduation\frontend tarek\Eduverse-Frontend`

## QA & Review Process

Because this integration operates across three dynamic roles (Student, Instructor, TA), code reviews and QA must manually verify data changes in all three dashboard contexts. Mock static data must be fully eliminated in favor of live API usage before merging.

## Governance

This Constitution supersedes all other generic practices. Any deviations connecting directly to the backend bypassing BLoCs require explicit justification and amendment to this document. All Pull Requests must pass the Core Principle gates.

**Version**: 1.0.1 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-05
