# Research: Phase 1 — Foundation (API Services & Domain Models)

**Feature**: 015-phase-1-foundation
**Date**: 2026-04-10

---

## Decision 1: HTTP Client Architecture & Retry Strategy

**Decision**: All new services will use the existing `CoreApiClient` with a wrapper that adds retry-with-exponential-backoff for transient errors (5xx, network timeouts). Non-transient errors (401, 403, 404, 409) will NOT be retried.

**Rationale**: 
- `CoreApiClient` already handles JWT token injection and automatic token refresh with retry on 401. 
- Adding retry logic at the service level (not the interceptor level) gives us per-request control and proper error classification.
- Max 3 attempts with exponential backoff (1s → 2s → 4s) is a reasonable default that balances reliability with user experience.

**Alternatives considered**:
- Add retry as a Dio interceptor — rejected because we need fine-grained control over which HTTP codes trigger retry and need to return typed error objects to callers.
- Use a third-party retry package (e.g., `retry` package) — rejected to avoid additional dependency; the logic is simple enough to implement inline.

---

## Decision 2: Error Object Design

**Decision**: Services will return a typed `ServiceResult<T>` class (NOT `Either` from dartz, NOT throwing exceptions) for all results. The class contains:
- `isSuccess`: bool
- `data`: T? (present when isSuccess)
- `error`: ServiceError? (present when !isSuccess)

`ServiceError` contains:
- `type`: enum (`network`, `auth`, `server`, `parsing`)
- `statusCode`: int? (HTTP status code when applicable)
- `message`: String (human-readable)
- `originalError`: dynamic? (for debugging)

**Rationale**:
- BLoCs consume service results — returning a result wrapper instead of throwing keeps the BLoC/state machine clean.
- Avoids adding the `dartz` dependency; a simple generic class is sufficient.
- Type classification enables UI to show appropriate error messages (e.g., "No internet" vs "Session expired" vs "Server error").
- Matches the existing pattern in the app where BLoCs emit `error` states with payloads.

**Alternatives considered**:
- Using `Either<ServiceError, T>` from `dartz` — rejected to avoid adding functional programming dependency for a simple use case.
- Throwing custom exception types — rejected because BLoCs would need try/catch blocks for each exception type, making them verbose.

---

## Decision 3: PaginatedResponse Scope

**Decision**: Only `AssignmentService.getAll()` returns `PaginatedResponse<AssignmentModel>`. All other list methods across all 6 services return `List<T>`.

**Rationale**: 
- The backend API docs show that only `GET /api/assignments` returns the `{data: [...], meta: {...}}` paginated shape.
- All other endpoints (enrollments, sections, schedules, semesters, labs) return plain arrays.
- Building `PaginatedResponse<T>` as a generic utility still makes sense — it's reusable if future endpoints add pagination.

**Alternatives considered**:
- Make all list methods return `PaginatedResponse<T>` — rejected because the backend doesn't return pagination metadata for most endpoints; forcing it would require fabricating meta data.

---

## Decision 4: DriveFileModel Field Mapping

**Decision**: Map backend field names to frontend-expected names:
- Backend `driveFileId` → model `driveFileId` (int)
- Backend `driveId` → model `driveId` (String)
- Backend `fileName` → model `fileName` (String)
- Backend `webViewLink` → model `webViewLink` (String)
- Backend `webContentLink` → model `downloadUrl` (String)
- Model `iframeUrl` computed from `driveId`: `https://drive.google.com/file/d/{driveId}/preview`

**Rationale**: 
- The Flutter frontend already uses `downloadUrl` and `iframeUrl` naming conventions from existing code.
- Computing `iframeUrl` from `driveId` avoids relying on the backend to provide a preview URL variant.
- `webContentLink` is the download URL from Google Drive API — renaming to `downloadUrl` is clearer.

**Alternatives considered**:
- Use exact backend field names — rejected because existing Flutter widgets already reference `downloadUrl` and `iframeUrl`.
- Store only `driveId` and construct all URLs at runtime — rejected because `webViewLink` and `fileName` are useful metadata.

---

## Decision 5: Enum Organization

**Decision**: Organize 13 enums into 4 files by domain:
- `course_enums.dart`: `CourseLevel`, `CourseStatus`, `SectionStatus`
- `schedule_enums.dart`: `ScheduleType`, `DayOfWeek`
- `assignment_enums.dart`: `AssignmentStatus`, `SubmissionType`, `SubmissionStatus`
- `lab_enums.dart`: `LabStatus`, `LabAttendanceStatus`
- `enrollment_enums.dart`: `EnrollmentStatus`, `DropReason`

Each enum gets `fromString(String)` factory and `toJson()` → `String` method. Unknown values fall back to a `.unknown` variant.

**Rationale**: 
- Grouping by domain keeps files small and navigable.
- `fromString()`/`toJson()` pattern is consistent with existing app enums.
- `.unknown` fallback prevents crashes on future backend additions.

**Alternatives considered**:
- Single `enums.dart` file — rejected because it would be too large and harder to maintain.
- No fallback — rejected because the backend could add new enum values and we don't want silent parsing failures.

---

## Decision 6: Existing Model Updates vs New Models

**Decision**: Update existing models in-place (`CourseModel`, `EnrollmentModel`, `SectionModel`, `SemesterModel`, `AssignmentModel`, `LabModel`) rather than creating parallel new versions.

**Rationale**: 
- Existing models are already referenced by many widgets. Creating `_v2` models would require a massive parallel migration.
- The changes are additive (new fields) and safe (nullable new fields, unchanged existing fields).
- `AssignmentModel` and `LabModel` need significant restructuring but the class names should stay the same for import compatibility.

**Alternatives considered**:
- Create `AssignmentModelV2` in a new location — rejected because every import across the app would need updating, creating merge conflicts across all phases.
- Keep existing models and add extension methods — rejected because the field shapes differ too much (e.g., `isLate` type change).

---

## Decision 7: Service Method Return Types

**Decision**: 
- List methods return `List<T>` (or `PaginatedResponse<T>` for assignments).
- Get-by-ID methods return `T`.
- Create/Update/Delete methods return `T` (the created/updated object) or `void` for delete.
- All methods throw `ServiceError` on failure (not raw exceptions).

**Rationale**: 
- Matches the existing `CourseService`, `EnrollmentService` patterns in the app.
- Returning the created/updated object allows callers to update UI state immediately.
- Consistent with the backend API which returns the full object on create/update.

---

## Decision 8: File Upload Methods

**Decision**: Upload methods (`submitFile`, `uploadInstructionFile`, `uploadTaMaterial`) perform real multipart form-data HTTP requests using `Dio.FormData` with `MultipartFile.fromFile()`. The `Content-Type` header is NOT set manually (Dio auto-generates the multipart boundary).

**Rationale**: 
- Matches Constitution Principle X.
- Dio's `FormData` is the standard Flutter approach for multipart uploads.
- Not setting `Content-Type` manually is critical — the boundary must be auto-generated.

---

## Decision 9: Service Registration / DI

**Decision**: New services will be instantiated via the app's existing service locator pattern (if one exists) or created as needed and passed to BLoCs. The `CoreApiClient` is a shared singleton injected into all services.

**Rationale**: 
- The app already uses `CoreApiClient` across `CourseService`, `EnrollmentService`, etc.
- Following the same pattern ensures consistency and testability.

---

## Summary of Resolved Unknowns

| Unknown | Resolution |
|---------|-----------|
| Retry strategy | Exponential backoff, 3 attempts, 5xx + timeouts only |
| Error handling | Typed `ServiceResult<T>` with `isSuccess`/`data`/`error`; `ServiceError` with type classification |
| Pagination scope | Only `AssignmentService.getAll()` |
| DriveFile field mapping | Map `webContentLink`→`downloadUrl`, compute `iframeUrl` |
| Enum organization | 4 domain-specific files with `fromString`/`toJson` |
| Model strategy | Update existing models in-place |
| Upload methods | Real `Dio.FormData` multipart requests |
| Service DI | Shared `CoreApiClient` injection |
