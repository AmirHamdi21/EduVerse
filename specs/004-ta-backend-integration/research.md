# Research: TA Backend Integration Constraints and Permissions

## Decision: Roles/Data Fetching mapping
**Decision**: Reuse `TeachingCourseModel` globally for `/api/enrollments/teaching`
**Rationale**: API docs confirm the TA response shares identical DTOs as the Instructor, so creating a separate TA model is redundant.
**Alternatives considered**: Building a specific `TACourseModel` (rejected due to duplication and future syncing overhead).

## Decision: External Interactions
**Decision**: Fallback universally to `url_launcher`.
**Rationale**: Easiest way to handle potentially diverse external material types without bloated in-app viewers.
**Alternatives considered**: Creating native in-app PDF/Video renderers (rejected due to scope constraints in v1).
