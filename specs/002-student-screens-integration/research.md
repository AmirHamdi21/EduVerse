# Architecture Research: Student Screens Integration

## Context
Phase 2 integrates the live backend data models constructed in Phase 1 into the Student Dashboard and Courses screens. Functional requirements dictate using `CoursesBloc` exclusively, deleting static mock models, and seamlessly supporting caching and filtering.

## Findings & Decisions

### Decision 1: Filtering & Sorting Architecture
- **Decision**: Perform filtering (e.g. Active vs Completed) and sorting entirely in-memory within the UI layer (or a lightweight Cubit wrapper), using the list of `CourseEnrollmentModel` returned by `CoursesBloc`'s successful states.
- **Rationale**: Students have a relatively small number of total enrollments. Filtering in memory allows instantaneous (<100ms) UI updates without costly network roundtrips, matching the performance criteria.
- **Alternatives considered**: Passing filter parameters down to `CoursesBloc` and triggering new fetches. Rejected to avoid network dependency for simple local state reorganizations.

### Decision 2: UI Fallback for Assets
- **Decision**: Generate deterministic abstract gradients via a hash of the `CourseModel.id` for display cases where `thumbnailUrl` is null.
- **Rationale**: The spec requires dynamic handling of omitted backend thumbnails (Q3: Initials Placeholder / Gradients). Generating colors deterministically based on the ID guarantees a specific course always has the same visual placeholder profile across app restarts.
- **Alternatives considered**: Bundling 10-15 static placeholder asset files. Rejected because it unnecessarily inflates app binary size when a simple Flutter `BoxDecoration.gradient` resolves it programmatically.

### Decision 3: Parity with `Eduverse-Frontend` React Application
- **Decision**: Strict alignment to layout and fields. The React application displays Title, Code, Progress Bar, Instructor Name, and Next Due Assignment in cards. Our UI must pipe the data required for these properties out of `CourseEnrollmentModel`.
- **Rationale**: Requirement FR-006 demands strict parity.
- **Alternatives considered**: Diverging to mobile-exclusive layouts. Rejected due to the spec constraint explicitly demanding presentation synchronicity across platforms.
