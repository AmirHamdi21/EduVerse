# Admin User & Course Management Rebuild Plan (Flutter)

Date: 2026-04-16
Scope approved by user:
- User Management scope: student CRUD only.
- Deletion strategy: replace internals, keep existing file/class names for UI compatibility.
- Course scope: redesigned admin course flow at `/admin/courses` only.
- Excluded: legacy add-course admin flow/BLoC refactor, unrelated admin modules.

## 1. Objective

Rebuild the Flutter integration layer behind:
- `lib/screens/admin/users/admin_user_management_screen.dart`
- `lib/screens/admin/courses/admin_course_management_screen.dart`

while keeping UI structure and navigation intact, so behavior matches website implementation and backend contracts exactly for create/edit/delete/list workflows.

## 2. Root Cause Summary

Primary failure pattern is backend DTO whitelist enforcement:
- Backend global validation in `D:/Graduation/backend/last_backend/EduVerse_Backend/src/main.ts` uses:
  - `whitelist: true`
  - `forbidNonWhitelisted: true`

This means extra or wrong keys produce 400 responses. Current Flutter integration sends invalid keys in several operations.

## 3. Authoritative Endpoint Contract Matrix

### 3.1 User Management (Student CRUD)

1. `GET /api/admin/users`
- Required: none
- Optional query: `page`, `size`, `sort`, `status`, `role`, `campusId`
- Notes: for student list use `role=student`
- Success: paginated object with `data` list + pagination metadata

2. `GET /api/admin/users/search`
- Required query: `query`
- Optional: none
- Success: plain array of user rows (not always paginated wrapper)

3. `POST /api/auth/register`
- Required body: `email`, `password`, `firstName`, `lastName`
- Optional body: `phone`, `role`
- Notes: role should be `student` for this feature
- Success: registration payload containing user + tokens

4. `PUT /api/admin/users/:id`
- Required path: `id`
- Allowed body keys: `firstName`, `lastName`, `phone`, `profilePictureUrl`, `campusId`
- Important: do not send `year`/`status` here

5. `PUT /api/admin/users/:id/status`
- Required path: `id`
- Required body: `status`
- Allowed status values: `active`, `inactive`, `suspended`, `pending`

6. `DELETE /api/admin/users/:id`
- Required path: `id`
- Success: `204`

### 3.2 Course Management (Redesigned flow parity)

1. `GET /api/courses`
- Optional query: `page`, `limit`, `departmentId`, `level`, `status`, `search`
- Success shape: `{ data: [...], meta: ... }` (defensive parsing still needed)

2. `POST /api/courses`
- Required body: `departmentId`, `name`, `code`, `description`, `credits`, `level`
- Optional body: `syllabusUrl`
- Important: do not send `status` on create

3. `PATCH /api/courses/:id`
- Allowed body: `name`, `description`, `credits`, `level`, `syllabusUrl`, `status`
- Important: do not send `code` or `departmentId` in patch

4. `DELETE /api/courses/:id`
- Success: `204`

5. `GET /api/sections/course/:courseId`
- Optional query: `semesterId`

6. `GET /api/sections/:id`

7. `POST /api/sections`
- Required body: `courseId`, `semesterId`, `maxCapacity`
- Optional body: `sectionNumber`, `currentEnrollment`, `location`

8. `PATCH /api/sections/:id`
- Allowed body: `maxCapacity`, `currentEnrollment`, `location`, `status`
- Important: do not send `semesterId`/`sectionNumber` in patch

9. `GET /api/schedules/section/:sectionId`

10. `POST /api/schedules/section/:sectionId`
- Required body: `dayOfWeek`, `startTime`, `endTime`, `scheduleType`
- Optional body: `room`, `building`

11. `DELETE /api/schedules/:id`

12. Instructor assignment endpoints
- `GET /api/enrollments/sections/:sectionId/instructors`
- `POST /api/enrollments/sections/:sectionId/instructors` body: `userId` (+ optional `role`)
- `DELETE /api/enrollments/sections/:sectionId/instructors/:assignmentId`

13. TA assignment endpoints
- `GET /api/enrollments/sections/:sectionId/tas`
- `POST /api/enrollments/sections/:sectionId/tas` body: `userId` (+ optional `responsibilities`)
- `DELETE /api/enrollments/sections/:sectionId/tas/:assignmentId`

14. Summary endpoints used by website-style enrichment
- `GET /api/enrollments/section/:sectionId/instructor`
- `GET /api/enrollments/section/:sectionId/tas`

15. Lookups
- `GET /api/semesters`
- `GET /api/departments`

## 4. Implementation Phases

### Phase A - Data Contracts First
- Rebuild and normalize admin user/course models in-place.
- Keep existing class names and public members used by the two screens.
- Remove stale/invalid parsing assumptions not aligned with backend shape.

### Phase B - Services In-Place Rebuild

User service (`admin_student_management_service.dart`):
- Keep method signatures for screen compatibility.
- Rewrite payload shaping to strict DTO-compatible keys.
- Add dedicated status update method for `PUT /admin/users/:id/status`.

Course service (`admin_course_management_service.dart`):
- Keep method signatures expected by screen.
- Rewrite create/update payloads to DTO-safe keys.
- Preserve website-like orchestration:
  - create/update course
  - ensure section and replace schedule
  - sync instructor/TA assignments using delete-diff-add pattern
- Preserve defensive parsing:
  - wrapped/unwrapped arrays
  - id from `id | courseId | sectionId | data.id`

### Phase C - UI Compatibility Wiring (Minimal)

User screen:
- Keep layout/widgets intact.
- On edit submit:
  - call profile update with allowed keys only
  - call status endpoint separately if changed
- Update create-password validation to backend rules (minimum 8 + complexity).

Course screen:
- Keep layout and 3-step wizard intact.
- Ensure all step actions route through rebuilt service methods.
- Keep section optionality and staff sync behavior unchanged from UI perspective.

### Phase D - Cleanup and Hardening
- Remove obsolete helper branches in rebuilt files.
- Keep routes/import paths stable.
- Keep changes limited to approved scope.

### Phase E - Verification
1. Analyzer on touched files.
2. Widget tests for admin user/course impacted tests.
3. Manual flow verification checklist:
   - User list/search/create/edit/delete
   - Course list/create/edit/delete
   - Section+schedule create/replace
   - Instructor/TA sync add/remove
4. Payload audit: confirm no non-whitelisted keys are sent.

## 5. Planned Flutter File Touch List

Core rewrite:
- `lib/models/admin/admin_student_management_models.dart`
- `lib/models/admin/admin_course_management_models.dart`
- `lib/services/api/admin_student_management_service.dart`
- `lib/services/api/admin_course_management_service.dart`

Compatibility wiring:
- `lib/screens/admin/users/admin_user_management_screen.dart`
- `lib/screens/admin/courses/admin_course_management_screen.dart`

Validation/tests:
- `test/widgets/admin/users/admin_user_management_screen_test.dart`
- `test/widgets/admin/courses/course_staff_assignment_test.dart` (regression verification)

## 6. Non-Goals (Explicitly Excluded)

- No UI redesign work.
- No backend code modifications.
- No refactor of legacy admin add-course flow (`admin_add_course_screen.dart`) in this task.
- No changes to unrelated admin modules (events, office hours, periods, etc.).

## 7. Completion Criteria

Implementation is complete when:
- Student CRUD and course CRUD flows on Flutter behave like website behavior.
- No backend 400 errors from DTO whitelist violations in these flows.
- Rebuilt layers compile cleanly and tests relevant to touched scope pass.
- Existing UI remains visually/functionally consistent with redesigned screens.
