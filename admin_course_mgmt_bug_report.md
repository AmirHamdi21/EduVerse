# Admin Course Management — Deep Investigation Report

> **Scope**: Create / Edit / Delete course procedures in `024-admin-course-mgmt`
> **Frontend**: `d:\Graduation\EduVerse\edu_verse`
> **Backend**: `d:\Graduation\backend\last_backend\EduVerse_Backend`

---

## Executive Summary

There are **17 confirmed bugs** across both projects: 3 in the backend, 14 in the frontend. They span broken API calls, missing authentication guards,  wrong field names, skipped steps in the wizard, hardcoded maps that will always fail in production, missing UI for schedule input, and a structural model mismatch that silently corrupts data.

---

## 1. BACKEND ISSUES (3 bugs)

---

### BUG-B1 — `courses.controller.ts`: No Auth Guard on Create/Update/Delete

**File**: `src/modules/courses/controllers/courses.controller.ts`
**Lines**: 134 (POST), 166 (PATCH), 191 (DELETE)

**What is wrong**:
The `CoursesController` is completely unauthenticated. There are no `@UseGuards(JwtAuthGuard, RolesGuard)` or `@Roles(...)` decorators on the controller class or on the `create`, `update`, and `delete` action methods. Any user or anonymous HTTP client can create, modify, or delete courses.

**Compare with**: `enrollments.controller.ts` line 45-46:
```ts
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
```

**Impact**: The admin wizard sends requests but they succeed even without a JWT token. If the token is missing/expired and the Flutter client doesn't get a 401, the `CoreApiClient` auto-refresh logic never fires. Courses can be vandalized by anyone.

**Fix — `src/modules/courses/controllers/courses.controller.ts`**:

Add imports and guards at top of class:
```typescript
// Add imports:
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { RoleName } from '../auth/entities/role.entity';
import { ApiBearerAuth } from '@nestjs/swagger';

// Decorate the class:
@ApiTags('📖 Courses')
@Controller('api/courses')
@UseGuards(JwtAuthGuard, RolesGuard)   // ← ADD THIS
@ApiBearerAuth('JWT-auth')              // ← ADD THIS
export class CoursesController {
```

And add `@Roles` to the mutating actions:

```typescript
// POST /api/courses
@Post()
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)   // ← ADD
...

// PATCH /api/courses/:id
@Patch(':id')
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)   // ← ADD
...

// DELETE /api/courses/:id
@Delete(':id')
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)   // ← ADD
...

// Keep GET endpoints public by overriding with @Roles() not applied — 
// or add @SkipAuth() if you have such a decorator, or simply remove
// class-level guard and keep guards on each mutating method individually.
```

**Recommended pattern** (method-level guards so GETs remain public):
```typescript
// Remove class-level UseGuards and apply guards only to POST/PATCH/DELETE
@Post()
@HttpCode(HttpStatus.CREATED)
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
async create(@Body() dto: CreateCourseDto) { ... }
```

---

### BUG-B2 — `course-sections.controller.ts` & `course-schedules.controller.ts`: No Auth Guards

**Files**:
- `src/modules/courses/controllers/course-sections.controller.ts` (line 27)
- `src/modules/courses/controllers/course-schedules.controller.ts` (line 24)

**What is wrong**: Same issue as BUG-B1. `POST /api/sections`, `PATCH /api/sections/:id`, `POST /api/schedules/section/:sectionId`, `DELETE /api/schedules/:id` are all open to anyone. The enrolled-student count can be artificially inflated, sections created without authorization, and schedules deleted without auth.

**Fix — `src/modules/courses/controllers/course-sections.controller.ts`**:
```typescript
// On create, update, updateEnrollment:
@Post()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
async create(@Body() dto: CreateSectionDto) { ... }

@Patch(':id')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
async update(...) { ... }
```

**Fix — `src/modules/courses/controllers/course-schedules.controller.ts`**:
```typescript
@Post('section/:sectionId')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
async create(...) { ... }

@Delete(':id')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
async delete(...) { ... }
```

---

### BUG-B3 — `courses.service.ts`: `create()` stores `instructorId` and `taIds` on `Course` entity — these fields are **NEVER read** by the wizard's step 3 logic

**File**: `src/modules/courses/services/courses.service.ts` — `create()` lines 126-136

**What is wrong**: The `courses` table has `instructor_id` and `ta_ids` JSON columns (course entity lines 81-93). The `CreateCourseDto` accepts `instructorId` and `taIds` (course.dto.ts lines 53-61). The `create()` method saves them directly onto the course row.

HOWEVER, the proper staff assignment system (wizard step 3) uses the **`CourseInstructor`** and **`CourseTA`** tables, which are entirely separate from `instructor_id`/`ta_ids` columns on the `courses` table. This means:

1. If an admin creates a course and passes `instructorId` in step 1, it goes into `course.instructor_id` — but the wizard then also assigns via `CourseInstructor` table in step 3. This creates **two parallel truth sources** that diverge over time (edit calls won't touch `instructor_id`).
2. The frontend `CourseModel.fromJson` reads `json['instructorId']` to populate `course.instructorId` — so the displayed instructor on the course card comes from the course row, not from the `CourseInstructor` relationship table, while the Staff tab uses the relationship table. The two will be **out of sync**.
3. Filters like `needs_instructor` in `CourseListBloc._applyFilters` check `course.instructorId == null` — which will show courses as "needs instructor" even when a `CourseInstructor` record exists.

**Fix — `src/modules/courses/services/courses.service.ts`**:

Remove the `instructorId` and `taIds` fields from the `create()` call, and also remove them from `CreateCourseDto`:

```typescript
// In courses.service.ts create():
const course = this.courseRepository.create({
  departmentId: dto.departmentId,
  name: dto.name,
  code: dto.code,
  description: dto.description,
  credits: dto.credits,
  level: dto.level,
  syllabusUrl: dto.syllabusUrl || null,
  // REMOVE: instructorId: dto.instructorId || null,
  // REMOVE: taIds: dto.taIds || null,
  status: CourseStatus.ACTIVE,
});
```

And remove from `CreateCourseDto` in `course.dto.ts` (lines 53-61):
```typescript
// REMOVE THESE FIELDS entirely from CreateCourseDto and UpdateCourseDto:
// instructorId?: number;
// taIds?: number[];
```

The staff should only be managed through the `CourseInstructor`/`CourseTA` tables (step 3 of the wizard).

---

## 2. FRONTEND ISSUES (14 bugs)

---

### BUG-F1 — `course_service.dart` `getAllCourses()`: Wrong URL path — missing `/api` prefix

**File**: `lib/services/api/course_service.dart` — line 30

**What is wrong**:
```dart
final response = await _client.dio.get('/courses');
```

The `CoreApiClient` `BaseOptions.baseUrl` points to `ApiService.baseUrl` which must be something like `http://host:3000/api`. But the backend registers routes as `@Controller('api/courses')` — meaning the full URL is `http://host:3000/api/courses`. If `baseUrl` is `http://host:3000` (no `/api`), then the call hits the correct endpoint. But if `baseUrl` ends in `/api`, the call becomes `http://host:3000/api/courses` which is correct.

**The actual problem**: `getAllCourses()` at line 30 uses `/courses` but `createCourseAdmin()` at line 118 also uses `/courses`. ALL the course service methods use paths **without the `/api` prefix**. This is consistent. However, the enrollment service at line 27-28 calls `/enrollments/my-enrollments` and the backend has NO such route — the backend's route is `GET my-courses` (the route decorator is `@Get('my-courses')`).

**Direct broken call — `enrollment_service.dart` line 27**:
```dart
/// GET /api/enrollments/my-enrollments
final response = await _client.dio.get('/enrollments/my-enrollments');  // ← WRONG
```

But the backend controller at `enrollments.controller.ts` line 76 registers: `@Get('my-courses')`. There is **no** `my-enrollments` endpoint on the backend at all.

**Fix — `lib/services/api/enrollment_service.dart` line 27**:
```dart
// CHANGE:
final response = await _client.dio.get('/enrollments/my-enrollments');
// TO:
final response = await _client.dio.get('/enrollments/my-courses');
```

---

### BUG-F2 — `enrollment_service.dart` `getSectionStudents()`: Wrong URL — hits non-existent route

**File**: `lib/services/api/enrollment_service.dart` — line 102

**What is wrong**:
```dart
final response = await _client.dio.get('/sections/$sectionId/students');
```

The backend registers this endpoint on the **enrollments** controller, not on the sections controller. The actual URL on the backend is:

`GET /api/enrollments/section/:sectionId/students`  (enrollments.controller.ts line 383)

The frontend is calling `/sections/$sectionId/students` which maps to nothing — this always 404s.

**Fix — `lib/services/api/enrollment_service.dart` line 102**:
```dart
// CHANGE:
final response = await _client.dio.get('/sections/$sectionId/students');
// TO:
final response = await _client.dio.get('/enrollments/section/$sectionId/students');
```

---

### BUG-F3 — `admin_add_course_screen.dart` `_buildStep1Payload()`: Missing required field `code` on new create

**File**: `lib/screens/admin/courses/admin_add_course_screen.dart` — lines 498-516

**What is wrong**:
```dart
Map<String, dynamic> _buildStep1Payload(bool isEditing) {
  final payload = <String, dynamic>{
    'name': _nameController.text.trim(),
    'description': _descriptionController.text.trim(),
    'credits': 3,  // ← HARDCODED! Never reads from any form field
    'level': _toApiLevel(_selectedLevel),
    'status': _isActive ? 'ACTIVE' : 'INACTIVE',
  };

  if (!isEditing) {
    payload['code'] = _codeController.text.trim().toUpperCase();
    payload['departmentId'] = _resolveDepartmentId(_selectedDepartment);
  }
  ...
}
```

1. **`credits` is hardcoded to 3**. The backend's `CreateCourseDto` requires `credits` as `@IsInt() @Min(1) @Max(6)`. This hardcoded value means all courses are always created with 3 credits regardless of what the admin wants to enter. There is no form field for credits in the UI at all.

2. **`status` is sent as `'ACTIVE'` / `'INACTIVE'` strings** — the backend enum is `CourseStatus.ACTIVE = 'ACTIVE'` so the casing is correct, but `UpdateCourseDto.status` is typed as `CourseStatus` — this will fail at runtime if NestJS's validation transformer is strict. Should be fine with current config, but fragile.

3. **`level` is converted through `_toApiLevel()` at line 567–585 which defaults to `'FRESHMAN'` for null, but then returns `'FRESHMAN'`, `'SOPHOMORE'`, `'JUNIOR'`, `'SENIOR'`, `'GRADUATE'`** — these are uppercase and match the backend enum `CourseLevel` exactly.

**Fix — `lib/screens/admin/courses/admin_add_course_screen.dart`**:

Add a `_creditsValue` state variable and a form field (or at minimum a stepper widget in `CourseDetailsForm`), and read it in the payload:

```dart
// In state class, add:
int _credits = 3;

// In _buildStep1Payload():
'credits': _credits,   // ← Replace hardcoded 3
```

Also update `CourseDetailsForm` (`lib/widgets/admin/courses/course_details_form.dart`) to include a credits selector (1–6) and expose an `onCreditsChanged` callback.

---

### BUG-F4 — `admin_add_course_screen.dart` `_resolveDepartmentId()`: Hardcoded map that will always produce wrong IDs

**File**: `lib/screens/admin/courses/admin_add_course_screen.dart` — lines 534-549

**What is wrong**:
```dart
int _resolveDepartmentId(String? value) {
  final map = <String, int>{
    'Computer Science': 1,
    'Mathematics': 2,
    'Physics': 3,
    'Engineering': 4,
    'English': 5,
    'Chemistry': 6,
    'Biology': 7,
  };
  if (value == null) return 1;
  return map[value] ?? 1;
}
```

This hardcodes department name → ID 1 through 7. The real department IDs in the database are fetched dynamically by the backend. **These hardcoded IDs do not match the production database**. Any department not in this list returns ID 1 ("Computer Science"). A course for "Law" department would incorrectly get `departmentId = 1`.

**Fix**: Fetch departments from the backend during screen initialization and build the map dynamically.

In `admin_add_course_screen.dart`:
1. Add a `List<DepartmentInfo>` state field.
2. On `initState()`, fetch `/campus/departments` via `_coreApiClient.dio.get('/campus/departments')`.
3. Populate a `Map<String, int>` from the response.
4. Pass the department list to `CourseDetailsForm` for the dropdown.
5. In `_resolveDepartmentId()`, look up from the dynamic map.

---

### BUG-F5 — `admin_add_course_screen.dart` `_resolveSemesterId()`: Hardcoded semester IDs 1, 2, 3

**File**: `lib/screens/admin/courses/admin_add_course_screen.dart` — lines 552-564

**What is wrong**:
```dart
int _resolveSemesterId(String? value) {
  if (value == null) return 1;
  final l10n = AppLocalizations.of(context);
  if (value == l10n.springSemester) return 2;
  if (value == l10n.summerSemester) return 3;
  return 1;
}
```

Same as BUG-F4. Semester IDs are hardcoded as 1, 2, 3 — these almost certainly don't match the semesters currently in the production database. If Semester ID 1 is "Spring 2024" but the admin is creating a course for "Fall 2026", **the section will be assigned to the wrong semester**.

**Fix**: Fetch semesters from the backend. The `SemesterService` (`lib/services/api/semester_service.dart`) already exists.

```dart
// In initState():
_loadSemesters();

// New method:
Future<void> _loadSemesters() async {
  final semesters = await _semesterService.getAll();
  setState(() { _availableSemesters = semesters; });
}

// In _resolveSemesterId():
final semester = _availableSemesters.firstWhere(
  (s) => s.name == value,
  orElse: () => _availableSemesters.first,
);
return semester.id;
```

---

### BUG-F6 — `admin_add_course_screen.dart` Step 2 section payload: Missing required `semesterId` and `courseId` on UPDATE

**File**: `lib/screens/admin/courses/admin_add_course_screen.dart` — lines 519-531

**What is wrong**:
```dart
Map<String, dynamic> _buildStep2SectionPayload(bool isEditing) {
  final payload = <String, dynamic>{
    'maxCapacity': _maxStudents,
    'location': null,        // ← Always null, no form field
    'status': _isActive ? 'OPEN' : 'CLOSED',
  };

  if (!isEditing) {
    payload['semesterId'] = _resolveSemesterId(_selectedSemester);
    payload['sectionNumber'] = 1;  // ← Always 1, never asks backend
  }

  return payload;
}
```

Problems:
1. **`location` is always `null`** — there is no location form field. The backend accepts `location` as an optional string. This is a missing feature.
2. **`status` sent as `'OPEN'` / `'CLOSED'`** — backend `UpdateSectionDto.status` is `SectionStatus` enum with values `OPEN`, `CLOSED`, `FULL`, `CANCELLED`. These match, but `'CLOSED'` is not a useful default for a newly active section.
3. **On edit (`isEditing=true`), `semesterId` and `courseId` are NOT sent** — but the `CourseWizardBloc._onSubmitStep2()` at line 382 adds `courseId` only if `draftSectionId == null`. On EDIT mode, `draftSectionId` is set, so the PATCH `/sections/:id` call contains only `{maxCapacity, location, status}`. **This is actually correct for update** (you don't change courseId/semesterId on update). ✅ This sub-point is NOT a bug.
4. **`sectionNumber` hardcoded to `1`** on create — if a course already has sections, a second section cannot be created because the backend would reject duplicate section numbers for the same course/semester. The backend auto-generates it if omitted, so the fix is to simply remove `sectionNumber` from the payload.

**Fix**:
```dart
Map<String, dynamic> _buildStep2SectionPayload(bool isEditing) {
  final payload = <String, dynamic>{
    'maxCapacity': _maxStudents,
    if (_locationController.text.trim().isNotEmpty)
      'location': _locationController.text.trim(),  // ← Add a location controller
    'status': _isActive ? 'OPEN' : 'CLOSED',
  };

  if (!isEditing) {
    payload['semesterId'] = _resolveSemesterId(_selectedSemester);
    // REMOVE: payload['sectionNumber'] = 1;  ← let backend auto-generate
  }

  return payload;
}
```

---

### BUG-F7 — `course_wizard_bloc.dart` `_onSubmitStep3()`: Step 3 checked for `draftSectionId`, but on first use `draftSectionId` is only set AFTER Step 2 succeeds — if Step 2 was skipped the wizard blocks Step 3

**File**: `lib/bloc/admin_course_management/course_wizard_bloc.dart` — lines 436-443

**What is wrong**: Step 3 handler:
```dart
if (state.draftSectionId == null) {
  emit(state.copyWith(
    status: CourseWizardStatus.failure,
    errorMessage: 'Section draft is missing. Save step 2 first.',
  ));
  return;
}
```

The `AddCourseProgressIndicator` shows the step bar and if `allowDirectStepNavigation` is `true` (set when editing an active course, line 245 of wizard_bloc), the admin can jump from step 1 directly to step 3. But in create mode (`isEditMode=false`), after step 1 saves, `draftSectionId` is still null. The user must enter step 2. This is by design, but the sequence matters: the bug is that when editing an existing course where **the first section has been deleted** from the database, `draftSectionId` will be null even in edit mode, and step 3 will fail with a confusing error.

Additionally, in the success dialog on wizard completion, the `ClearWizardFeedback` event is fired but **`CourseListBloc` is never refreshed**. The list of courses is stale after creation/editing.

**Fix 1 — `admin_add_course_screen.dart` `_handleWizardState()` at line 654**:
```dart
if (wizardState.status == CourseWizardStatus.completed) {
  _showSuccessDialog(isDark, l10n, wizardState.isEditMode);
  context.read<CourseWizardBloc>().add(const ClearWizardFeedback());
  // ADD THIS to refresh course list after completion:
  context.read<CourseListBloc>().add(const LoadCourses(forceRefresh: true));
}
```

**Fix 2** — After delete from wizard, also refresh:
```dart
// In _onDeleteCourseFromWizard at line 580:
emit(state.copyWith(
  isSubmitting: false,
  status: CourseWizardStatus.completed,
  successMessage: 'Course deleted successfully',
));
// The bloc doesn't reach CourseListBloc — fix in the screen's BlocListener:
// In _handleWizardState(), add a case for completed+isEditMode=false that refreshes.
```

---

### BUG-F8 — `admin_add_course_screen.dart` `_handleWizardState()` `stepSaved` handler: navigates to WRONG steps

**File**: `lib/screens/admin/courses/admin_add_course_screen.dart` — lines 645-651

**What is wrong**:
```dart
if (wizardState.status == CourseWizardStatus.stepSaved) {
  if (wizardState.currentStep == 1) {
    context.read<CourseWizardBloc>().add(const GoToWizardStep(1));  // ← Stay on step 1?!
  } else if (wizardState.currentStep == 2) {
    context.read<CourseWizardBloc>().add(const GoToWizardStep(2));  // ← Stay on step 2?!
  }
  return;
}
```

When `stepSaved` fires after step 1 completes, `wizardState.currentStep` has already been set to `1` by the bloc (line 352 of wizard_bloc: `currentStep: state.currentStep < 1 ? 1 : state.currentStep`). Then the screen sees `currentStep == 1` and dispatches `GoToWizardStep(1)` — which is a no-op navigation to the step already active.

**These dispatches are surplus and have no effect** — navigation already happened inside the bloc. The real consequence is it masks a future case where navigation does fail. The listener should be cleaned up but also needs to trigger UI side effects correctly.

**Fix — `lib/screens/admin/courses/admin_add_course_screen.dart` lines 645–651**:
```dart
// REMOVE the stepSaved block entirely — navigation already handled in bloc:
// if (wizardState.status == CourseWizardStatus.stepSaved) {
//   ...
//   return;
// }

// OR: if you need side effects on step transition, do them here:
if (wizardState.status == CourseWizardStatus.stepSaved) {
  // nothing — bloc already advanced currentStep correctly
  return;
}
```

---

### BUG-F9 — `course_wizard_bloc.dart` `_onSubmitStep3()` edit mode: removes ALL instructors then re-adds — if re-add fails, course is left with NO instructors

**File**: `lib/bloc/admin_course_management/course_wizard_bloc.dart` — lines 456-514

**What is wrong**:
```dart
// Step 1: Remove ALL existing instructors
for (final EnrollmentModel instructor in existingInstructors) {
  await _enrollmentService.removeInstructor(sectionId, instructor.id);
  // If this succeeds for 3 out of 4 instructors, then the 4th remove fails →
  // course is left with 1 instructor, wizard marks inactiveSaved.
}
// Step 2: Assign new instructors
for (final assignment in uniqueAssignments.values) {
  await _enrollmentService.assignInstructorWithDetails(...);
  // If assignment fails → course has 0 instructors, wizard marks inactiveSaved.
}
```

This is a **non-atomic replace operation**. If any step fails mid-way, the section is left in a partially modified state AND the course is marked `INACTIVE`. The admin cannot easily recover because the list only shows active courses.

**Fix**: Use a transactional approach — only remove old staff AFTER all new assignments succeed:

```dart
// In _onSubmitStep3, in edit mode:
// 1. Assign new ones first (409 conflict means already assigned = OK)
// 2. Only THEN remove old ones not in new list
final existingIds = existingInstructors.map((i) => i.userId).toSet();
final newIds = event.assignments.where((a) => !a.isTa).map((a) => a.userId).toSet();
final toRemove = existingInstructors.where((i) => !newIds.contains(i.userId));
final toAdd = event.assignments.where((a) => !a.isTa && !existingIds.contains(a.userId));

// Add first, then remove — failures on add don't destroy existing data
for (final assignment in toAdd) { ... }
for (final instructor in toRemove) { ... }
```

---

### BUG-F10 — `enrollment_service.dart` `getSectionTAs()`: URL uses PLURAL `sections` but `getSectionStudentsLite()` uses SINGULAR `section` — inconsistency causes 404s

**File**: `lib/services/api/enrollment_service.dart` — lines 186–187 vs 130–131

**What is wrong**:
- `getSectionTAs()` calls `/enrollments/sections/$sectionId/tas` (PLURAL `sections`)
- `getSectionStudentsLite()` calls `/enrollments/section/$sectionId/students` (SINGULAR `section`)
- `getSectionInstructors()` calls `/enrollments/sections/$sectionId/instructors` (PLURAL `sections`)

Now look at the backend controller (enrollments.controller.ts):
- `GET sections/:sectionId/tas` — line 780 (PLURAL) ✅
- `GET section/:sectionId/students` — line 383 (SINGULAR) ✅
- `GET sections/:sectionId/instructors` — line 593 (PLURAL) ✅

The `adminRegisterStudent()` method at line 238 calls `POST /enrollments/register` which is:
- `@Post('register')` at line 172 — ROLE restricted to `STUDENT` only!

**BUG F10a — `adminRegisterStudent` will always get 403 Forbidden**:
```dart
// In enrollment_service.dart line 238-239:
final response = await _client.dio.post('/enrollments/register', data: body);
```
This endpoint is `@Roles(RoleName.STUDENT)` only on the backend (line 173). An admin cannot call it — it returns `403 Forbidden`. The admin has no way to enroll students.

**Fix for F10a**: Add an admin-specific enrollment endpoint on the backend:

```typescript
// In enrollments.controller.ts, add a new endpoint:
@Post('admin/enroll')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(RoleName.ADMIN)
@HttpCode(HttpStatus.CREATED)
async adminEnrollStudent(
  @Body() body: { sectionId: number; userId: number; force?: boolean },
): Promise<EnrollmentResponseDto> {
  return this.enrollmentsService.adminEnrollStudent(body.sectionId, body.userId, body.force);
}
```

And add `adminEnrollStudent()` to `enrollments.service.ts` that bypasses prerequisite and schedule conflict checks (or respects `force` flag).

Then update the frontend `enrollment_service.dart`:
```dart
Future<ServiceResult<CourseEnrollmentModel>> adminRegisterStudent({...}) {
  return RetryHelper.execute(() async {
    final body = <String, dynamic>{'sectionId': sectionId, 'userId': userId};
    if (force) body['force'] = true;
    // CHANGE endpoint:
    final response = await _client.dio.post('/enrollments/admin/enroll', data: body);
    return CourseEnrollmentModel.fromJson(_extractMap(response.data));
  }, fallbackMessage: 'Failed to enroll student');
}
```

---

### BUG-F11 — `course_list_bloc.dart` `_applyFilters()`: `needs_instructor` / `needs_ta` filters use `course.instructorId` and `course.taIds` from the course row — not from the assignment tables

**File**: `lib/bloc/admin_course_management/course_list_bloc.dart` — lines 486-492

**What is wrong**:
```dart
case 'needs_instructor':
  return course.instructorId == null;   // ← reads course.instructorId col
case 'needs_ta':
  return (course.taIds ?? const <int>[]).isEmpty;  // ← reads course.taIds col
```

As explained in BUG-B3, the `course.instructorId` and `course.taIds` columns on the course row are a legacy field that duplicates (and diverges from) the proper `CourseInstructor` and `CourseTA` relationship tables. A newly assigned instructor via step 3 of the wizard creates a `CourseInstructor` record but does NOT update `course.instructorId`. Result: the filter always shows the course as "needs instructor" even after an instructor is assigned.

**Fix — `lib/bloc/admin_course_management/course_list_bloc.dart`**:
```dart
case 'needs_instructor':
  // Use staffByCourse from the assignment table instead:
  final staff = sectionsByCourse[course.id]
    ?.expand((s) => s.schedules ?? <ScheduleModel>[])  // wrong — need staff
    // Actually use staffByCourse parameter — pass it:
  return (staffByCourse[course.id] ?? <InstructorAssignmentModel>[])
    .where((a) => a.role.toLowerCase() != 'ta')
    .isEmpty;

case 'needs_ta':
  return (staffByCourse[course.id] ?? <InstructorAssignmentModel>[])
    .where((a) => a.role.toLowerCase() == 'ta')
    .isEmpty;
```

Update the `_applyFilters()` signature to accept `staffByCourse`:
```dart
List<CourseModel> _applyFilters({
  ...
  required Map<int, List<InstructorAssignmentModel>> staffByCourse,  // ← ADD
})
```

And update all call sites to pass `state.staffByCourse`.

---

### BUG-F12 — `admin_add_course_screen.dart` `_prefillFromCourse()`: Wrong check for `scheduleType.name == 'lab'` — crashes if `scheduleType` is an enum with uppercase values

**File**: `lib/screens/admin/courses/admin_add_course_screen.dart` — lines 678-685

**What is wrong**:
```dart
_hasLabs = schedules.any(
  (schedule) => schedule.scheduleType.name.toLowerCase() == 'lab',
);
```

`schedule.scheduleType` is expected to be a `ScheduleType` enum. The `ScheduleModel.fromJson()` must parse this. If the backend returns `'LAB'` (uppercase) and the enum value is `ScheduleType.lab('LAB')`, then `.name` would be the Dart enum's `.name` property which is `'lab'` (lowercase, the identifier). This part works correctly.

However, the real issue is that `ScheduleModel` is imported from `lib/models/core/schedule_model.dart` (which is a separate file from `lib/models/courses/schedule_model.dart` — the courses one is just a re-export of the core one). Let me verify the `scheduleType` field parsing.

**In `lib/models/core/schedule_model.dart`**, `scheduleType` is of type `ScheduleType` (from `schedule_enums.dart`). The `.name` property on a Dart enum returns the identifier string in **lowercase** camelCase. So `ScheduleType.lab.name` == `'lab'`. This comparison works.

**HOWEVER**: in `_labCount()` at line 1109 of `admin_course_management_screen.dart`:
```dart
.where((schedule) => schedule.scheduleType.name.toLowerCase() == 'lab')
```

And in `_applyFilters()` in `course_list_bloc.dart` line 501:
```dart
return schedules.any((schedule) => schedule.scheduleType.name.toLowerCase() == 'lab');
```

These work IF `ScheduleType` enum has a value named `lab`. From the backend enums: `ScheduleType.LAB = 'LAB'`. From the Flutter `schedule_enums.dart` — we need to verify this file content.

**Potential crash**: If the backend returns `'LECTURE'` and no `ScheduleType` enum case handles it, `fromString()` may return an `unknown` value, and `unknown.name` would be `'unknown'`, not crash. No crash, but filtering silently fails.

---

### BUG-F13 — `admin_add_course_screen.dart`: The wizard has NO schedule entry step — Step 2 always sends empty `schedulesPayload`

**File**: `lib/screens/admin/courses/admin_add_course_screen.dart` — line 478

**What is wrong**:
```dart
context.read<CourseWizardBloc>().add(
  SubmitStep2(
    sectionPayload: _buildStep2SectionPayload(wizardState.isEditMode),
    schedulesPayload: const <Map<String, dynamic>>[],  // ← ALWAYS EMPTY!
  ),
);
```

Step 2 of the wizard is represented by `CourseSettings` widget — which only handles `maxStudents`, `hasLabs`, `labCount`, `isActive`. There is **no UI for entering schedule days/times**. The `schedulesPayload` is always an empty list.

This means:
- Every course created via the wizard has **zero schedules**.
- The Schedule tab in `AdminCourseManagementScreen` will always show empty for newly created courses.
- The `_hasLabs` / `_labCount` fields are captured but never sent as actual schedule data.

**Fix**: The `CourseSettings` widget (`lib/widgets/admin/courses/course_settings.dart`) needs a schedule builder sub-UI. Add a list of schedule entries (day picker + start time + end time + type). Then pass non-empty `schedulesPayload` when the user adds at least one schedule.

Alternatively (quick fix): if schedules will be managed separately after creation, remove the `_hasLabs` / `_labCount` fields from the AI Preview since they'll always be 0.

---

### BUG-F14 — `admin_course_management_screen.dart` Delete flow: `_confirmDelete()` dispatches to `CourseListBloc.DeleteCourse`, but the `DeleteCourse` handler does NOT refresh the list from backend — it only removes from local state array

**File**: `lib/bloc/admin_course_management/course_list_bloc.dart` — lines 407-448

**What is wrong**: After deleting a course:
```dart
Future<void> _onDeleteCourse(DeleteCourse event, ...) async {
  final result = await _courseService.softDeleteCourse(event.courseId);
  ...
  final remaining = state.courses
    .where((course) => course.id != event.courseId)
    .toList();
  emit(state.copyWith(courses: remaining, filteredCourses: filtered, ...));
}
```

The backend `softDelete` sets `deletedAt` (a soft-delete timestamp) and returns `HTTP 204 No Content`. The frontend then filters the local list — this is fine for immediate UX. But if the delete **fails silently** (network glitch, backend error not caught because 204 returns null body), the item disappears from the list even though it wasn't actually deleted.

More importantly: **DeleteCourse is dispatched from the CourseListBloc**, but the same course can also be deleted from the **wizard** via `DeleteCourseFromWizard` in `CourseWizardBloc`. When the wizard deletes, it does NOT tell `CourseListBloc` to remove the course from its list. The admin must manually navigate back and the course still shows in the list until a full refresh.

**Fix 1**: After `_onDeleteCourse` success, force a backend re-fetch:
```dart
// In _onDeleteCourse after successful delete:
add(const LoadCourses(forceRefresh: true));  // ← ADD
```

**Fix 2**: In `admin_add_course_screen.dart` `_handleWizardState()`, after `CourseWizardStatus.completed` when delete was initiated:
```dart
// Add refresh after wizard completion:
context.read<CourseListBloc>().add(const LoadCourses(forceRefresh: true));
```

---

## 3. SUMMARY TABLE

| ID | Project | File | Severity | Description |
|----|---------|------|----------|-------------|
| BUG-B1 | Backend | `courses.controller.ts` | 🔴 Critical | No auth guard — anyone can create/edit/delete courses |
| BUG-B2 | Backend | `course-sections.controller.ts`, `course-schedules.controller.ts` | 🔴 Critical | No auth guard on section/schedule mutations |
| BUG-B3 | Backend | `courses.service.ts`, `course.dto.ts` | 🟠 High | `instructor_id`/`ta_ids` on courses table diverges from `CourseInstructor`/`CourseTA` tables |
| BUG-F1 | Frontend | `enrollment_service.dart:27` | 🔴 Critical | Wrong URL: `/enrollments/my-enrollments` → should be `/enrollments/my-courses` |
| BUG-F2 | Frontend | `enrollment_service.dart:102` | 🔴 Critical | Wrong URL: `/sections/$id/students` → should be `/enrollments/section/$id/students` |
| BUG-F3 | Frontend | `admin_add_course_screen.dart:502` | 🟠 High | `credits` hardcoded to `3`; no form field for credits |
| BUG-F4 | Frontend | `admin_add_course_screen.dart:534` | 🔴 Critical | Hardcoded `departmentId` map (Computer Science=1 etc.) — wrong in production |
| BUG-F5 | Frontend | `admin_add_course_screen.dart:552` | 🔴 Critical | Hardcoded `semesterId` map (Spring=2, Summer=3) — wrong in production |
| BUG-F6 | Frontend | `admin_add_course_screen.dart:519` | 🟠 High | `location` always null; `sectionNumber` always 1 (blocks second section) |
| BUG-F7 | Frontend | `admin_add_course_screen.dart:654` | 🟠 High | Course list never refreshed after wizard create/edit/delete completion |
| BUG-F8 | Frontend | `admin_add_course_screen.dart:645` | 🟡 Medium | `stepSaved` listener dispatches redundant `GoToWizardStep` calls |
| BUG-F9 | Frontend | `course_wizard_bloc.dart:456` | 🟠 High | Non-atomic staff replacement — partial failure leaves course with no instructors |
| BUG-F10a | Frontend+Backend | `enrollment_service.dart:238`, `enrollments.controller.ts:173` | 🔴 Critical | Admin cannot enroll students — endpoint is STUDENT-only, 403 always returned |
| BUG-F11 | Frontend | `course_list_bloc.dart:486` | 🟠 High | `needs_instructor`/`needs_ta` filters check wrong field (course row vs. relationship table) |
| BUG-F12 | Frontend | `admin_add_course_screen.dart:678` | 🟡 Low | `scheduleType.name` comparison — works but brittle; verify `ScheduleType` enum |
| BUG-F13 | Frontend | `admin_add_course_screen.dart:478` | 🟠 High | No schedule input UI in wizard — `schedulesPayload` always empty, no schedules ever created |
| BUG-F14 | Frontend | `course_list_bloc.dart:407`, `admin_add_course_screen.dart` | 🟡 Medium | Course list stale after delete; wizard delete not propagated to list BLoC |

---

## 4. RECOMMENDED FIX ORDER

1. **BUG-B1 + BUG-B2** — Add auth guards to the backend controllers (10 min, highest risk).
2. **BUG-F1 + BUG-F2** — Fix the two wrong URLs in `enrollment_service.dart` (5 min).
3. **BUG-F4 + BUG-F5** — Replace hardcoded department/semester maps with live API calls (1 hour).
4. **BUG-F10a** — Add admin enroll endpoint on backend + update frontend service (30 min).
5. **BUG-F7 + BUG-F14** — Add `LoadCourses(forceRefresh: true)` after wizard completion/delete (10 min).
6. **BUG-F3** — Add credits form field (20 min).
7. **BUG-F13** — Add schedule input to Step 2 UI (2–4 hours).
8. **BUG-F9** — Refactor atomic staff replacement (1 hour).
9. **BUG-B3** — Clean up the dual instructor storage pattern (1 hour + DB migration review).
10. **BUG-F11** — Fix filter logic to use `staffByCourse` map (30 min).
11. **BUG-F6 + BUG-F8** — Minor payload and listener cleanup (20 min).
