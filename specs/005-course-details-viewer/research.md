# Course Detail Drill-down & Material Viewer - Research

## Schema Payload Resolution
**Decision**: We will model two separate models in Dart mapping directly to the backend implementations: `CourseStructureModel` (mapping `LectureSectionLab`) and `CourseMaterialModel` (mapping `CourseMaterial`).

**Rationale**: The robust backend schema separates the "structural organization" (the module holder) from the "actual material file/link". The `CourseStructureModel` includes an `organizationType` (lecture, lab, section, tutorial) and optionally links to a `CourseMaterialModel` which dictates how Flutter should render the download/link (using `materialType`, `externalUrl`, `youtubeVideoId`, `fileId`). We will recreate these precisely using `freezed`. The backend's `GET /api/courses/:id/structure` natively returns `{ data: [...items], byWeek: { 1: [...], 2: [...] } }`, allowing our Flutter app to parse the `byWeek` grouping effortlessly to render the lists linearly.

**Alternatives considered**: 
- We considered flattening the payload locally, but utilizing the `byWeek` grouping natively sent by the controller dramatically cuts down on Dart-side looping and mapping operations.
- Considered using generic UI mapping, but decided mapping strictly to Freezed entities is necessary to ensure `courses_backend_integration_plan.md`'s constitutional "Strict Data Layer Separation" rule.
