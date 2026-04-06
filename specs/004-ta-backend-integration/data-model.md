# Data Model: TA Backend Integration

## Entities

### `TeachingCourseModel` (Existing)
* **Description:** Represents a course assigned to an instructor or TA. Returned by `/api/enrollments/teaching`.
* **Fields:** Identical to the instructor model, strips out student-specific details.

### `TAAssignmentModel`
* **Description:** Represents a specific TA assignment to a section.
* **Fields:** 
  - `id` (int)
  - `sectionId` (int)
  - `userId` (int)
  - `responsibilities` (String?)
  - `assignedAt` (DateTime)
  - `firstName` (String)
  - `lastName` (String)
  - `email` (String)

## Validation Rules
* If `responsibilities` is omitted, UI falls back gracefully.
* UI must verify if the logged-in user is a TA before triggering TA specific endpoints.
