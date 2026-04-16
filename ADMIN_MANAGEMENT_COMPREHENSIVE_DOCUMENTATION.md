# EduVerse Admin Management - Comprehensive Implementation Documentation

Version: 1.0
Date: 2026-04-15
Scope: Admin Management sections for Student Management, Course Management, and Periods and Scheduling (Enrollment Periods, Campus Events, Schedule Templates, Office Hours)

---

## 1. Purpose and Coverage

This document provides a deep implementation-level breakdown of the Admin Management area and answers all requested points:

1. What each file does in the target features.
2. UI structure and behavior per page and per file.
3. Logic and state management used in each file.
4. Backend endpoints used by each feature.
5. Variables used from each endpoint response, their types, and exactly where they are consumed.
6. Detailed click-flow narratives for each button and actionable control.

This is implementation documentation based on source code behavior, not only intended behavior.

---

## 2. Route and Composition Overview

### 2.1 Top-Level Route

Admin dashboard route is mounted under:

- `/admindashboard/:tab`

Handled in:

- `src/pages/admin-dashboard/AdminDashboard.tsx`

### 2.2 Tab keys relevant to this document

- `students` -> Student Management
- `courses` -> Course Management
- `periods` -> Periods and Scheduling

### 2.3 Parent-child wiring

Inside `AdminDashboard.tsx`, tab rendering is done by conditional blocks:

- `activeTab === 'students'` -> `<StudentManagementPage />`
- `activeTab === 'courses'` -> `<CourseManagementPage ...props />`
- `activeTab === 'periods'` -> `<EnrollmentPeriodPage ...props />`

`EnrollmentPeriodPage` then hosts sub-tabs:

- `periods` -> Enrollment Periods main tab
- `events` -> `CampusEventsManagementPage`
- `templates` -> `ScheduleTemplatesPage`
- `office-hours` -> `OfficeHoursManagementPage`

---

## 3. Source File Inventory (Feature Scope)

## 3.1 Orchestration and shared context

| File | Role in system | UI responsibilities | Logic responsibilities |
|---|---|---|---|
| `src/pages/admin-dashboard/AdminDashboard.tsx` | Parent page orchestrator | Sidebar tab navigation, header, tab content mount | Live/mock mode switching, parent state storage, API refresh helpers, prop injection to child pages |
| `src/pages/admin-dashboard/contexts/ThemeContext.tsx` | Theme context | color mode and accent color behavior | exposes `isDark`, `primaryHex`, `primaryColor` |
| `src/pages/admin-dashboard/contexts/LanguageContext.tsx` | Localization context | translated labels and RTL support | exposes `t()`, `language`, `isRTL` |

## 3.2 Student Management

| File | Role | Notes |
|---|---|---|
| `src/pages/admin-dashboard/components/StudentManagementPage.tsx` | Full student management implementation | Includes table, filters, all student modals, query/mutations, local enrollment simulation |
| `src/services/adminService.ts` | Backend API wrapper | Provides student list/search/create/update/delete endpoints |
| `src/pages/admin-dashboard/constants.ts` | Mock and constants | Provides department constant and mock fallback context |

## 3.3 Course Management

| File | Role | Notes |
|---|---|---|
| `src/pages/admin-dashboard/components/CourseManagementPage.tsx` | Full course management implementation | Includes Courses, Staff, Schedule, Exams sub-tabs and multi-step add/edit workflows |
| `src/services/adminService.ts` | API wrapper for course CRUD | create/update/delete/get courses and supporting department/semester calls |
| `src/services/api/client.ts` | Generic API client used directly | Course page uses raw `ApiClient` for many endpoints |
| `src/services/api/enrollmentService.ts` | Additional enrollment endpoint definitions | Useful for endpoint comparisons; course page mostly calls `ApiClient` directly |
| `src/pages/admin-dashboard/constants.ts` | Mock schedule/exam data for local sub-tabs | Schedule and Exams sub-tabs currently mock in CourseManagementPage |

## 3.4 Periods and Scheduling

| File | Role | Notes |
|---|---|---|
| `src/pages/admin-dashboard/components/EnrollmentPeriodPage.tsx` | Parent periods page | Enrollment Periods UI + sub-tab switcher |
| `src/pages/admin-dashboard/components/CampusEventsManagementPage.tsx` | Campus events sub-feature | Event filters, list, CRUD modals, registration expansion |
| `src/pages/admin-dashboard/components/ScheduleTemplatesPage.tsx` | Schedule templates sub-feature | Template CRUD, slot wizard, apply and bulk-apply |
| `src/pages/admin-dashboard/components/OfficeHoursManagementPage.tsx` | Office hours sub-feature | Office hour CRUD, filtering, appointment expansion |
| `src/services/api/scheduleService.ts` | Core API contract for scheduling domain | Campus events, schedule templates, office hours, appointments |
| `src/services/adminService.ts` | Enrollment periods derivation service | Converts semesters into period objects |
| `src/pages/admin-dashboard/components/ExamSchedulePage.tsx` | Separate exam scheduling component | Exported but not mounted in active AdminDashboard periods route |

---

## 4. Student Management - Deep Documentation

## 4.1 Primary implementation file

- `src/pages/admin-dashboard/components/StudentManagementPage.tsx`

### 4.1.1 UI composition

Main UI blocks:

1. Header
- Title and department badge
- Add Student button

2. Filter row
- Search input
- Year filter select
- Status filter select

3. Data table
- Columns: Name, Student ID, Email, Year, Enrolled Courses, Status, Actions
- Loading state row with spinner
- Empty state row

4. Row actions and modal system
- Edit student
- Fix enrollment
- Add course (local)
- Remove course (local)
- Delete student

5. Separate Add Student modal
- Registration form
- Password visibility toggle
- Validation and error display

### 4.1.2 Local state model

| Variable | Type | Purpose | Used in UI |
|---|---|---|---|
| `searchTerm` | `string` | search text | search input and query dependency |
| `yearFilter` | `string` | year filter | year dropdown and computed filtering |
| `statusFilter` | `string` | status filter | status dropdown and computed filtering |
| `activeModal` | `ModalType \| null` | controls action modal | determines which modal content renders |
| `selectedStudent` | `Student \| null` | row context for modal actions | all action modals |
| `selectedCourse` | `string` | selected course in add-course modal | add-course form |
| `page` | `number` | pagination for backend fetch | query key and getStudents args |
| `localEnrollments` | `Record<number, string[]>` | local-only enrollment override map | add/remove course operations and table display |
| `showAddStudentModal` | `boolean` | create-student modal visibility | add-student modal |
| `newStudent` | object | create-student payload draft | add-student form fields |
| `showPassword` | `boolean` | show/hide password | add-student password input |
| `formError` | `string \| null` | create-student error feedback | error banner in modal |

### 4.1.3 Core computed data

- `students` via `useMemo`
  - If mock mode: returns `mockStudents`
  - Else maps API users into `Student` table model
  - Merges backend `enrolledCourses` with local `localEnrollments` overrides

- `filteredStudents` via `useMemo`
  - Applies `yearFilter` and `statusFilter`

- `coursesNotEnrolled`
  - Derived from `availableCourses` minus selected student's enrolled courses

- `conflicts`
  - Derived from local hardcoded `enrollmentConflicts` dictionary

### 4.1.4 Query and mutation layer

#### Query
- key: `['admin-students', page, searchTerm, statusFilter]`
- fn: `adminService.getStudents(page, 10, searchTerm)`
- enabled only in live mode (`!isMockMode`)

#### Mutations

1. `updateStudentMutation`
- endpoint wrapper: `adminService.updateUser(id, data)`
- on success: invalidates `['admin-students']`, toast success, close modal

2. `createStudentMutation`
- endpoint wrapper: `adminService.createStudent(data)`
- on success: invalidates students query, resets form, closes modal, success toast with created user name

3. `deleteStudentMutation`
- endpoint wrapper: `adminService.deleteUser(id)`
- on success: invalidates students query, toast success, close modal
- special handling: 404 treated as already removed

---

## 4.2 Student Management Endpoints and Field-Level Variable Usage

## 4.2.1 GET students list

Endpoint:
- `GET /admin/users?role=student&page={page}&size={size}`
- or search mode: `GET /admin/users/search?query={search}`

Called from:
- `adminService.getStudents(page, size, search)`

Expected response shape in code path:
- `{ data: User[]; total: number }`

### Field usage map

| Response field | Type | Mapped variable | Where consumed |
|---|---|---|---|
| `data[]` | `User[]` | `list` in `students` memo | source array for table model creation |
| `total` | `number` | not consumed in StudentManagementPage | currently unused in UI pagination |
| `user.userId` | `number` | `Student.id` | table row key, mutation IDs, `localEnrollments` dictionary key |
| `user.studentId` | `string \| undefined` | `Student.studentId` | Student ID table column; fallback generated if missing |
| `user.firstName` | `string` | part of `Student.name` | Name table column, modal title text |
| `user.lastName` | `string` | part of `Student.name` | Name table column, modal title text |
| `user.email` | `string` | `Student.email` | Email table column, edit modal read-only input |
| `user.year` | `string \| undefined` | `Student.year` | Year column and year filter matching |
| `user.enrolledCourses` | `string[] \| undefined` | `Student.enrolledCourses` | course badges in table and add/remove course logic |
| `user.status` | `string` | `Student.status` normalized to union | status badge styling and status filter matching |
| `user.roles` | `{ roleId:number; roleName:string }[]` | not mapped | unused in this page |

## 4.2.2 POST create student

Endpoint:
- `POST /auth/register`

Called from:
- `adminService.createStudent(data)` where role is forced to `student`

Request body variables:

| Field | Type | Source |
|---|---|---|
| `firstName` | `string` | `newStudent.firstName` |
| `lastName` | `string` | `newStudent.lastName` |
| `email` | `string` | `newStudent.email` |
| `password` | `string` | `newStudent.password` |
| `phone` | `string` optional | `newStudent.phone`, removed if blank |
| `role` | `'student'` | injected in service |

Response usage:

| Response field | Type | Usage |
|---|---|---|
| `user.firstName` | `string` | success toast description |
| `user.lastName` | `string` | success toast description |
| `user.userId` | `number` | not directly consumed in page, list refetched instead |
| `user.email` | `string` | not directly consumed in page, list refetched instead |

## 4.2.3 PUT update student

Endpoint:
- `PUT /admin/users/{id}`

Called from:
- `adminService.updateUser(id, data)`

Request variables used by UI:

| Field | Type | Source |
|---|---|---|
| `firstName` | `string` | edit form state |
| `lastName` | `string` | edit form state |
| `email` | removed before mutate | email intentionally non-editable |
| `phone` | `string` optional | present in edit form but depends on backend acceptance |

Response field usage:
- direct response fields are not used in UI.
- page behavior relies on query invalidation + refetch.

## 4.2.4 DELETE student

Endpoint:
- `DELETE /admin/users/{id}`

Called from:
- `adminService.deleteUser(id)`

Response field usage:
- no response body fields consumed.
- behavior driven by status code and query invalidation.

---

## 4.3 Student Management Button/Control Flow Narratives

### 4.3.1 Add Student

1. Click Add Student -> `showAddStudentModal = true`.
2. Fill form fields -> `newStudent` state updates per input.
3. Submit Create Account:
   - prevents default submit
   - removes empty phone from payload
   - calls `createStudentMutation.mutate(payload)`
4. Success path:
   - invalidate `admin-students`
   - close modal and reset form state
   - show success toast with created user name
5. Error path:
   - set `formError`
   - show error toast
   - keep modal open

### 4.3.2 Edit Student

1. Click row edit icon -> opens `edit-student` modal with selected row.
2. Update first/last name.
3. Save Profile -> calls `updateStudentMutation` with `{id, data}`.
4. Success -> query invalidation + modal close + success toast.
5. Error -> error toast, modal remains open.

### 4.3.3 Add Course (local-only)

1. Click add course icon -> open `add-course` modal.
2. Select course from not-enrolled list.
3. Click Enroll Student -> `handleAddCourse`.
4. `localEnrollments` updates in memory and table reflects change.
5. No backend call; change is lost on page refresh or refetch reset.

### 4.3.4 Remove Course (local-only)

1. Click remove course icon -> open `remove-course` modal.
2. Click course chip/button to remove.
3. `localEnrollments` updates and UI updates immediately.
4. No backend call.

### 4.3.5 Fix Enrollment

1. Click wrench icon -> open `fix-enrollment` modal.
2. Shows entries from hardcoded conflict map.
3. Clicking resolution executes `alert(...)` then closes modal.
4. No backend or persistent state change.

### 4.3.6 Delete Student

1. Click delete icon -> open `delete-student` confirmation.
2. Confirm delete -> run `deleteStudentMutation`.
3. Success -> invalidate query, close modal, success toast.
4. 404 -> treated as already deleted, query invalidated and modal closed.

---

## 5. Course Management - Deep Documentation

## 5.1 Primary implementation file

- `src/pages/admin-dashboard/components/CourseManagementPage.tsx`

### 5.1.1 UI structure

Sub-tabs inside page:

1. Courses
- filter/search/export row
- course cards
- add/edit/delete course modals

2. Staff
- course-staff table
- assign button per row

3. Schedule
- table from local `mockScheduleData`

4. Exams
- table from local `mockExamData`

### 5.1.2 State model

| Variable | Type | Purpose |
|---|---|---|
| `activeSubTab` | `'courses'|'staff'|'schedule'|'exams'` | choose sub-view |
| `activeModal` | `'add-course'|'edit-course'|'staff-assign'|'delete-course'|null` | modal selector |
| `selectedCourse` | `Course \| null` | context for edit/staff/delete |
| `searchTerm` | `string` | filter course cards |
| `departmentFilter` | `string` | filter course cards by dept |
| `statusFilter` | `string` | filter by active/archived |
| `formData` | object | course form values |
| `addStep` | `1|2|3` | add wizard step |
| `editStep` | `1|2|3` | edit wizard step |
| `addCourseId` | `number \| null` | created course ID in add flow |
| `addSectionId` | `number \| null` | created section ID in add flow |
| `sectionFormData` | object | section/schedule fields |
| `addStaffFormData` | object | step-3 staff in add/edit wizard |
| `staffFormData` | object | standalone staff modal fields |
| `semesters` | `SemesterOption[]` | semester dropdown options |
| submitting flags | `boolean` | disable actions during mutation |

### 5.1.3 Core logic functions

1. `loadCourseSectionDetails(course)`
- Loads section, schedules, instructors, and TAs for selected course.
- Populates `sectionFormData`, `addStaffFormData`, and `staffFormData`.

2. `ensureSectionWithSchedule(courseId, existingSectionId?)`
- Creates section if missing, otherwise updates section.
- Deletes existing schedules for section.
- Creates one new schedule from form values.
- Returns ensured section ID.

3. `syncStaffAssignments(sectionId, instructorId, taIds)`
- Fetches current assigned instructor/TAs.
- Deletes stale assignments.
- Adds missing instructor and TA assignments.

4. `handleEditCourseFlow()`
- PATCH course metadata.
- ensure section/schedule.
- sync staff assignments.
- refresh list and close modal.

5. Add wizard helpers
- `handleAddCourseStep1Next()` creates course.
- `handleAddCourseStep2Next()` creates section and schedule.
- `handleCreateCourseFlow()` assigns staff and finalizes.

---

## 5.2 Course Management Endpoints and Response Variable Mapping

Note: this feature uses both `adminService` and direct `ApiClient` calls.

## 5.2.1 Parent refresh and enrichment (AdminDashboard)

Endpoint set used by `refreshCourses()`:

1. `GET /courses`
2. `GET /sections/course/{courseId}`
3. `GET /enrollments/section/{sectionId}/instructor`
4. `GET /enrollments/section/{sectionId}/tas`

### Field-level map

| Endpoint field | Type | Mapped variable | Used in UI |
|---|---|---|---|
| `course.id` | `number` | `base.id` | card actions, edit/delete target IDs |
| `course.code` | `string` | `base.code` | course code badge |
| `course.name` | `string` | `base.name` | card title |
| `course.department.name` | `string` | `base.department` | filters and card metadata |
| `course.credits` | `number` | `base.credits` | card credits display and forms |
| `course.status` | `string` | `base.status` uppercase | status filters and edit form |
| `course.level` | `string` | `base.level` uppercase | edit/add forms |
| `section.id/sectionId` | `number` | `base.sectionId` | used for staff/schedule follow-up calls |
| `section.currentEnrollment` | `number` | `base.enrolled` | enrollment progress UI |
| `section.maxCapacity` | `number` | `base.capacity` | enrollment progress UI |
| `instructorPayload.instructor.fullName` | `string` | `base.instructor` | card metadata and staff table |
| `instructorPayload.instructorId` | `number` | `base.instructorId` | staff assignment defaults |
| `tas[].userId` | `number[]` | `base.taIds` | staff assignment defaults |
| `tas[].fullName` | `string[]` | `base.taNames` | card/staff table display |

## 5.2.2 Add Course flow endpoints

### Step 1: create course
- `POST /courses`

Request fields:

| Field | Type | Source |
|---|---|---|
| `code` | `string` | `formData.code` |
| `name` | `string` | `formData.name` |
| `description` | `string` | generated from name/code |
| `credits` | `number` | `formData.credits` |
| `level` | `string` | `formData.level` |
| `departmentId` | `number` | hardcoded `1` in this flow |

Response fields consumed:

| Field | Type | Usage |
|---|---|---|
| `id` or `courseId` | `number` | set `addCourseId` for step chaining |

### Step 2: create section and schedule

1. `POST /sections`

Request:
- `courseId`, `semesterId`, `sectionNumber`, `maxCapacity`, `location`

Response consumed:
- `sectionId` or `id` -> set `addSectionId`

2. `POST /schedules/section/{sectionId}`

Request:
- `dayOfWeek`, `startTime`, `endTime`, `room`, `scheduleType`

Response fields are not directly consumed.

### Step 3: assign staff

1. `POST /enrollments/sections/{sectionId}/instructors`
- body: `{ userId }`

2. `POST /enrollments/sections/{sectionId}/tas`
- body: `{ userId }` per TA

Response fields are not directly consumed; refresh call rebuilds UI state.

## 5.2.3 Edit Course flow endpoints

1. `PATCH /courses/{id}`
- updates name/description/credits/status/level

2. `GET /schedules/section/{sectionId}`
- fetch existing schedules before replace

3. `DELETE /schedules/{scheduleId}`
- removes old schedules

4. `POST /schedules/section/{sectionId}`
- inserts new schedule from form

5. `GET /enrollments/sections/{sectionId}/instructors`
6. `GET /enrollments/sections/{sectionId}/tas`
7. `DELETE /enrollments/sections/{sectionId}/instructors/{assignmentId}`
8. `POST /enrollments/sections/{sectionId}/instructors`
9. `DELETE /enrollments/sections/{sectionId}/tas/{assignmentId}`
10. `POST /enrollments/sections/{sectionId}/tas`

Field consumption highlights:

| Field | Type | Usage |
|---|---|---|
| assignment `id` | `number` | delete stale staff mapping |
| assignment `userId` | `number` | compare current vs desired staff |

## 5.2.4 Staff modal endpoints

When assigning staff directly:

- if no section, calls `ensureSectionWithSchedule` first (section/schedule endpoints above)
- then calls same sync endpoints to align instructor and TA assignments

## 5.2.5 Delete course endpoint

- `DELETE /courses/{id}`

Used in:
- delete modal confirm action (calls parent `onDeleteCourse`)

Response fields not consumed.

## 5.2.6 Semester and section detail support endpoints

- `GET /semesters`
  - used to populate `semesters` options (`id`, `name`)

- `GET /sections/{sectionId}`
  - consumed fields: `sectionNumber`, `maxCapacity`, `location`, `semesterId` or `semester.id`

- `GET /schedules/section/{sectionId}`
  - consumed fields: `dayOfWeek`, `startTime`, `endTime`, `room`

---

## 5.3 Course Management Button/Control Flow Narratives

## 5.3.1 Header buttons by sub-tab

- Courses sub-tab: Add Course button opens 3-step wizard modal.
- Schedule sub-tab: Add Schedule button currently visual only (no handler).
- Exams sub-tab: Add Exam button currently visual only (no handler).

## 5.3.2 Courses tab controls

1. Search input
- updates `searchTerm`
- filters cards by `course.name` or `course.code`

2. Department filter
- updates `departmentFilter`
- filters by exact department string

3. Status filter
- updates `statusFilter`
- filters by normalized status string

4. Export button
- currently visual only in this page (no export implementation)

## 5.3.3 Add Course wizard (Courses tab)

### Step 1 (Course)

Buttons:
- Cancel -> close modal
- Next -> `handleAddCourseStep1Next`

Flow:
1. validate code/name present
2. create course API call
3. store `addCourseId`
4. move to step 2

### Step 2 (Section)

Buttons:
- Back -> step 1
- Skip -> sets `addSectionId=null`, move to step 3
- Next -> `handleAddCourseStep2Next`

Flow with Next:
1. require `addCourseId`
2. create section
3. create schedule for section
4. store `addSectionId`
5. move to step 3

### Step 3 (Staff)

Buttons:
- Back -> step 2
- Skip -> clear staff and call create flow
- Create Course -> `handleCreateCourseFlow`

Flow:
1. if staff selected but no section -> throws error
2. assign instructor (optional)
3. assign each TA (optional)
4. call `onRefreshCourses`
5. success toast and close

## 5.3.4 Edit Course 3-step flow

Buttons:
- Cancel always available
- Back/Next navigate steps
- Save at step 3 executes `handleEditCourseFlow`

`handleEditCourseFlow` sequence:
1. patch course metadata
2. ensure/create section and replace schedule
3. sync instructor and TA assignments
4. refresh parent courses
5. close modal and toast

## 5.3.5 Staff sub-tab assign button flow

1. click Assign in row -> open `staff-assign` modal
2. modal preloads current instructor/TAs and section data
3. if no section, user can enter section/schedule values in same modal
4. click Assign Staff -> `handleStaffAssign`
5. section ensured, then staff sync executed
6. refresh and close

## 5.3.6 Delete course flow

1. click delete icon on card
2. confirmation modal opens
3. click Delete Course:
- calls parent `onDeleteCourse(selectedCourse.id)`
- close modal immediately
- parent mutation handles backend delete and refresh

## 5.3.7 Schedule and Exams sub-tabs

- data source is local arrays (`mockScheduleData`, `mockExamData`)
- no backend calls in current implementation
- read-only tables in this page

---

## 6. Periods and Scheduling - Deep Documentation

## 6.1 Parent composition

Primary file:
- `src/pages/admin-dashboard/components/EnrollmentPeriodPage.tsx`

Sub-tab keys:
- `periods`
- `events`
- `templates`
- `office-hours`

Child pages mounted by tab:

- `periods`: internal enrollment period UI in same file
- `events`: `CampusEventsManagementPage`
- `templates`: `ScheduleTemplatesPage`
- `office-hours`: `OfficeHoursManagementPage`

---

## 6.2 Enrollment Periods Core Tab

### 6.2.1 Data source and parent flow

In `AdminDashboard.tsx`:

- Query `['admin-periods']` calls `adminService.getEnrollmentPeriods()` only when active tab is `periods` and not mock mode.
- Local state `enrollmentPeriodsData` stores displayed periods.
- Add/edit/delete handlers mutate local parent state directly.

In `adminService.getEnrollmentPeriods()`:

1. Calls `GET /semesters`.
2. Derives period rows from semester registration dates.
3. Hardcodes two departments in derivation logic.
4. Calculates period status from date comparison.

### 6.2.2 Enrollment Periods state model (child page)

| Variable | Type | Purpose |
|---|---|---|
| `activeSubTab` | `SubTabKey` | sub-page switch |
| `activeModal` | `'add-period'|'edit-period'|'delete-period'|null` | modal control |
| `selectedPeriod` | `EnrollmentPeriod \| null` | edit/delete target |
| `statusFilter` | `string` | status filtering |
| `formData` | object | add/edit period draft |

### 6.2.3 Enrollment Period endpoint and field usage

Endpoint:
- `GET /semesters`

Semesters fields used in derivation:

| Field | Type | Used for |
|---|---|---|
| `id` | `number` | generated period IDs indirectly (counter) |
| `name` | `string` | `period.semester` |
| `registrationStart` | `string \| undefined` | `period.startDate` fallback logic |
| `registrationEnd` | `string \| undefined` | `period.endDate` fallback logic |
| `startDate` | `string` | fallback for registration fields |

Derived period fields consumed in UI:

| Field | Type | Where consumed |
|---|---|---|
| `id` | `number` | React keys and edit/delete IDs |
| `department` | `string` | filtered by admin department |
| `semester` | `string` | card badge/title and modal defaults |
| `startDate` | `string` | date range display and status computation |
| `endDate` | `string` | date range display and status computation |
| `totalStudents` | `number` | registration ratio and stats |
| `registeredStudents` | `number` | registration ratio and stats |
| `status` | `'active'|'upcoming'|'closed'` | filter, badges, active-only section |
| `description` | `string` | card description and edit form |

### 6.2.4 Enrollment Period action flows

1. Open Period button
- opens add modal
- submit computes status from dates
- calls parent `onAddPeriod` (local state append)

2. Edit Period button
- opens modal prefilled from selected period
- submit recalculates status
- calls parent `onEditPeriod` (local state map replace)

3. Delete Period button
- opens confirmation
- confirm calls parent `onDeletePeriod` (local state filter remove)

Note: Add/edit/delete here are local state changes; no create/update/delete backend endpoint is called.

---

## 6.3 Campus Events Sub-Tab

Primary file:
- `src/pages/admin-dashboard/components/CampusEventsManagementPage.tsx`

### 6.3.1 UI structure

1. Header with Create Event button
2. Filter grid:
- search
- event type
- status
- department scope
- from/to dates
3. Events table with expandable registration rows
4. Create/Edit modal
5. Delete confirmation modal

### 6.3.2 State model

| Variable | Type | Purpose |
|---|---|---|
| `activeModal` | `'create'|'edit'|'delete'|'registrations'|null` | modal control |
| `selectedEvent` | `CampusEvent \| null` | edit/delete context |
| `expandedRegistrations` | `number \| null` | expanded row event ID |
| filter states | string/number | query params and local filtering |
| `page` | `number` | pagination query |
| `formData` | object | event form draft |
| `tagInput` | `string` | temporary tag input |

### 6.3.3 Endpoints and field-level response usage

#### A) List events

Endpoint:
- `GET /campus-events`

Query variables:
- `page`, `limit`, `search`, `eventType`, `status`, `fromDate`, `toDate`, `scopeId`

List response type:
- `PaginatedResponse<CampusEvent>`

Field usage map:

| Response field | Type | Usage in UI |
|---|---|---|
| `eventId` | `number` | row key, edit/delete target, expansion target |
| `title` | `string` | table title column |
| `description` | `string \| null` | search matching and edit form populate |
| `eventType` | `string` | type label and filter matching |
| `scopeId` | `number \| null` | edit form scope prefill |
| `startDatetime` | `string` | start datetime display and form prefill |
| `endDatetime` | `string` | form prefill and duration context |
| `location` | `string \| null` | location column and form prefill |
| `building` | `string \| null` | location composite display and form prefill |
| `room` | `string \| null` | location composite display and form prefill |
| `isMandatory` | `boolean` | mandatory badge |
| `registrationRequired` | `boolean` | registration behavior and attendee display |
| `maxAttendees` | `number \| null` | attendee ratio display and form field |
| `color` | `string` | color dot and form color picker |
| `status` | `string` | status badge and filter |
| `tags` | `string[] \| null` | form tags editing |
| `registrationCount` | `number` | attendees column |
| `spotsRemaining` | `number \| null` | not directly displayed currently |
| `organizer` | object | not directly rendered in current table |
| `createdAt`/`updatedAt` | `string` | not directly rendered in table |
| `meta.total/page/limit/totalPages` | numbers | pagination controls |

#### B) Create event

Endpoint:
- `POST /campus-events`

Request variables:

| Field | Type | Source |
|---|---|---|
| `title` | `string` | form |
| `description` | `string` optional | form |
| `eventType` | union string | form |
| `scopeId` | `number` optional | only when not university_wide |
| `startDatetime` | `string` ISO | converted from datetime-local |
| `endDatetime` | `string` ISO | converted from datetime-local |
| `location` | `string` optional | form |
| `building` | `string` optional | form |
| `room` | `string` optional | form |
| `isMandatory` | `boolean` | form |
| `registrationRequired` | `boolean` | form |
| `maxAttendees` | `number` optional | form |
| `color` | `string` | form |
| `status` | union string | form |
| `tags` | `string[]` optional | form |

Response fields are not directly consumed; list query is invalidated.

#### C) Update event

Endpoint:
- `PUT /campus-events/{id}`

Request fields are partial version of create payload.

Response handling:
- no direct field usage; relies on query invalidation.

#### D) Delete event

Endpoint:
- `DELETE /campus-events/{id}`

Response fields:
- not consumed in UI beyond success/failure.

#### E) Registrations expansion

Endpoint:
- `GET /campus-events/{id}/registrations`

Consumed response fields:

| Field | Type | Usage |
|---|---|---|
| `summary.registered` | `number` | summary row |
| `summary.attended` | `number` | summary row |
| `summary.cancelled` | `number` | summary row |
| `summary.noShow` | `number` | summary row |
| `registrations[].registrationId` | `number` | registration item key |
| `registrations[].user.firstName` | `string` | registration item display |
| `registrations[].user.lastName` | `string` | registration item display |
| `registrations[].user.email` | `string` | registration item display |

### 6.3.4 Campus Events action flow highlights

- Create Event: open modal -> fill form -> submit -> create mutation -> invalidate events query.
- Edit Event: open with prefilled data -> submit update -> invalidate query.
- Delete Event: open confirm -> delete mutation -> invalidate query.
- Registration expand: toggle row -> conditional query executes only when expanded and not in mock mode.

---

## 6.4 Schedule Templates Sub-Tab

Primary file:
- `src/pages/admin-dashboard/components/ScheduleTemplatesPage.tsx`

### 6.4.1 UI structure

1. Header with Create Template button
2. Filter panel (search, type, department, active state)
3. Templates table
4. Modal families:
- Create/Edit 3-step wizard
- Delete confirmation
- Apply single-section
- Bulk apply multi-section

### 6.4.2 State model

| Variable | Type | Purpose |
|---|---|---|
| `activeModal` | `'create'|'edit'|'delete'|'apply'|'bulk-apply'|null` | modal control |
| `selectedTemplate` | `ScheduleTemplate \| null` | modal context |
| `wizardStep` | `1|2|3` | create/edit wizard step |
| filter states | strings/numbers | list query params |
| `page` | `number` | pagination |
| `formData` | object | template metadata draft |
| `slots` | `TemplateSlotInput[]` | slot editor data |
| apply states | values | single/bulk apply payload data |

### 6.4.3 Endpoints and response-variable usage

#### A) List templates

Endpoint:
- `GET /schedule-templates`

Query variables:
- `page`, `limit`, `search`, `scheduleType`, `departmentId`, `isActive`

Response:
- `PaginatedResponse<ScheduleTemplate>`

Field usage map:

| Field | Type | Usage |
|---|---|---|
| `templateId` | `number` | table key, action target IDs |
| `name` | `string` | template title column |
| `description` | `string \| null` | subtitle display |
| `department.departmentName` | `string` | department column |
| `scheduleType` | `string` | type badge |
| `isActive` | `boolean` | active/inactive status badge |
| `creator.firstName` | `string` optional | created-by display |
| `creator.lastName` | `string` optional | created-by display |
| `slots.length` | `number` | slots count column |
| `createdAt`/`updatedAt` | `string` | not directly displayed in list |
| `meta.totalPages` | `number` | pagination footer |
| `meta.page` | `number` | pagination display |

#### B) Create template

Endpoint:
- `POST /schedule-templates`

Request fields:

| Field | Type | Source |
|---|---|---|
| `name` | `string` | formData |
| `description` | `string` optional | formData |
| `departmentId` | `number` optional | formData |
| `scheduleType` | `'LECTURE'|'LAB'|'TUTORIAL'|'HYBRID'` | formData |
| `isActive` | `boolean` | formData |
| `slots[]` | array | mapped from slot editor |
| `slots[].dayOfWeek` | `string` | slot state |
| `slots[].startTime` | `string` | slot state |
| `slots[].endTime` | `string` | slot state |
| `slots[].slotType` | union string | slot state |
| `slots[].building` | `string` optional | slot state |
| `slots[].room` | `string` optional | slot state |

Response field usage:
- no direct field consumption; list query invalidated.

#### C) Update template

Endpoint:
- `PUT /schedule-templates/{templateId}`

Request fields used by current implementation:
- only metadata (`name`, `description`, `departmentId`, `scheduleType`, `isActive`)

Important behavior note:
- slots edited in UI are not sent in update payload in current code path.

#### D) Delete template

Endpoint:
- `DELETE /schedule-templates/{templateId}`

Response not directly consumed.

#### E) Apply template to section

Endpoint:
- `POST /schedule-templates/apply`

Request fields:
- `templateId`, `sectionId`, `building` optional, `room` optional

Response fields consumed:

| Field | Type | Usage |
|---|---|---|
| `schedulesCreated` | `number` | success toast message |
| `sectionId` | `number` | informational only |
| `message` | `string` | informational (implicit) |

#### F) Bulk apply template

Endpoint:
- `POST /schedule-templates/apply/bulk`

Request fields:
- `templateId`, `sectionIds[]`, optional overrides

Response fields consumed:

| Field | Type | Usage |
|---|---|---|
| `successful` | `number` | success toast summary |
| `failed` | `number` | success toast summary |
| `errors[]` | array | per-section error toasts |
| `errors[].sectionId` | `number` | toast text |
| `errors[].message` | `string` | toast text |

### 6.4.4 Schedule Templates button flows

- Create Template -> open wizard -> step validation -> slot editing -> confirm -> create mutation.
- Edit Template -> modal prefilled from selected row -> optional slot modifications in UI -> submit metadata update mutation.
- Delete Template -> confirm modal -> delete mutation.
- Apply -> choose one section and optional overrides -> apply mutation.
- Bulk Apply -> multi-select sections -> bulk apply mutation -> result toasts.

---

## 6.5 Office Hours Sub-Tab

Primary file:
- `src/pages/admin-dashboard/components/OfficeHoursManagementPage.tsx`

### 6.5.1 UI structure

1. Header with Add Office Hour
2. Filters:
- search
- instructor/TA
- day
- mode
- role
3. Office hours table
4. expandable appointment detail rows
5. create/edit modal
6. delete confirmation modal

### 6.5.2 State model

| Variable | Type | Purpose |
|---|---|---|
| `activeModal` | `'create'|'edit'|'delete'|null` | modal selector |
| `selectedSlot` | `OfficeHourWithInstructor \| null` | edit/delete context |
| `expandedAppointments` | `number \| null` | appointment row expansion |
| filter states | string/number | list filtering/query |
| `page` | `number` | pagination |
| `formData` | object | create/edit payload draft |

### 6.5.3 Endpoints and response-variable usage

#### A) Fetch instructors/TAs

Data source:
- `adminService.getUsers({ page, size })` looped client-side for large pull

Response fields used:

| Field | Type | Usage |
|---|---|---|
| `id` or `userId` | `number` | option value and lookup key |
| `firstName` | `string` | dropdown label and avatar initials |
| `lastName` | `string` | dropdown label and avatar initials |
| `email` | `string` | contextual display |
| `roles`/`role`/`userType` | strings | eligibility filtering (`instructor` or `ta`) |

#### B) List office hours

Endpoint via service fallback:
- `GET /office-hours` (or fallback `GET /office-hours/slots`)

Query params used:
- `instructorId`, `dayOfWeek`, `page`, `limit`

Response type:
- `PaginatedResponse<OfficeHoursSlot>`

Field usage map:

| Field | Type | Usage |
|---|---|---|
| `slotId` | `number` | row key, edit/delete target, expand key |
| `instructorId` | `number` | joins with instructor list for name display |
| `dayOfWeek` | `string` | schedule column |
| `startTime` | `string` | schedule column |
| `endTime` | `string` | schedule column |
| `location` | `string` | location column and edit form |
| `mode` | `'in_person'|'online'|'hybrid'|string` | mode badge and icon |
| `maxAppointments` | `number` | appointments ratio |
| `currentAppointments` | `number` optional | appointments ratio |
| `status` | `string` optional | implied active/inactive behavior |
| `meta.totalPages` | `number` | pagination controls |

Additional local extension fields used in UI when present:
- `building`, `room`, `isRecurring`, `effectiveFrom`, `effectiveUntil`, `notes`, `isActive`

#### C) Create office hour

Endpoint:
- `POST /office-hours` (fallback `/office-hours/slots`)

Request fields:

| Field | Type | Source |
|---|---|---|
| `instructorId` | `number` optional | selected instructor |
| `dayOfWeek` | `string` | form |
| `startTime` | `string` | form |
| `endTime` | `string` | form |
| `location` | `string` | form |
| `building` | `string` optional | form |
| `room` | `string` optional | form |
| `mode` | `'in_person'|'online'|'hybrid'` | form |
| `maxAppointments` | `number` optional | form |
| `isRecurring` | `boolean` optional | form |
| `effectiveFrom` | `string` optional | form |
| `effectiveUntil` | `string` optional | form |
| `notes` | `string` optional | form |

Response fields not directly consumed; refetch used.

#### D) Update office hour

Endpoint:
- `PUT /office-hours/{id}` (fallback `/office-hours/slots/{id}`)

Request body:
- partial of create fields

Response handling:
- no direct field usage; list query invalidation.

#### E) Delete office hour

Endpoint:
- `DELETE /office-hours/{id}` (fallback `/office-hours/slots/{id}`)

Response usage:
- not directly used.

#### F) Office hour appointments (expanded row)

Endpoint:
- `GET /office-hours/appointments?slotId={slotId}`

Response type:
- `PaginatedResponse<OfficeHoursAppointment>`

Field usage map:

| Field | Type | Usage |
|---|---|---|
| `appointmentId` | `number` | row key |
| `student.firstName` | `string` | appointment row display |
| `student.lastName` | `string` | appointment row display |
| `topic` | `string` | appointment row display |
| `appointmentDate` | `string` | appointment row display |
| `status` | union string | appointment badge |

### 6.5.4 Office Hours action flow highlights

- Add Office Hour -> open create modal -> validate instructor and location -> create mutation -> refetch list.
- Edit Office Hour -> open with prefilled selected slot -> update mutation.
- Delete Office Hour -> confirm modal -> delete mutation.
- Expand appointments -> sets `expandedAppointments` -> conditional query fetches appointments.

---

## 7. Cross-Feature Endpoint Catalog (Consolidated)

## 7.1 Student Management endpoints

| Method | Endpoint | Feature action |
|---|---|---|
| GET | `/admin/users?role=student&page={page}&size={size}` | student listing |
| GET | `/admin/users/search?query={search}` | student search |
| POST | `/auth/register` | create student |
| PUT | `/admin/users/{id}` | update student profile |
| DELETE | `/admin/users/{id}` | delete student |

## 7.2 Course Management endpoints

| Method | Endpoint | Feature action |
|---|---|---|
| GET | `/courses` | refresh and render course list |
| POST | `/courses` | add course step 1 |
| PATCH | `/courses/{id}` | edit course metadata |
| DELETE | `/courses/{id}` | delete course |
| GET | `/sections/course/{courseId}` | course-to-section enrichment |
| POST | `/sections` | create section |
| GET | `/sections/{sectionId}` | load section details |
| PATCH | `/sections/{sectionId}` | update section |
| GET | `/schedules/section/{sectionId}` | read existing schedule(s) |
| POST | `/schedules/section/{sectionId}` | create schedule |
| DELETE | `/schedules/{scheduleId}` | replace old schedule |
| GET | `/semesters` | semester dropdown |
| GET | `/enrollments/section/{sectionId}/instructor` | parent course enrichment |
| GET | `/enrollments/section/{sectionId}/tas` | parent course enrichment |
| GET | `/enrollments/sections/{sectionId}/instructors` | sync staff details |
| POST | `/enrollments/sections/{sectionId}/instructors` | assign instructor |
| DELETE | `/enrollments/sections/{sectionId}/instructors/{assignmentId}` | remove instructor |
| GET | `/enrollments/sections/{sectionId}/tas` | sync staff details |
| POST | `/enrollments/sections/{sectionId}/tas` | assign TA |
| DELETE | `/enrollments/sections/{sectionId}/tas/{assignmentId}` | remove TA |

## 7.3 Periods and Scheduling endpoints

### Enrollment Periods

| Method | Endpoint | Action |
|---|---|---|
| GET | `/semesters` | derive period cards |

### Campus Events

| Method | Endpoint | Action |
|---|---|---|
| GET | `/campus-events` | list/filter events |
| POST | `/campus-events` | create event |
| PUT | `/campus-events/{id}` | update event |
| DELETE | `/campus-events/{id}` | delete event |
| GET | `/campus-events/{id}/registrations` | expanded registrations |

### Schedule Templates

| Method | Endpoint | Action |
|---|---|---|
| GET | `/schedule-templates` | list templates |
| GET | `/schedule-templates/{id}` | template details (service-level available) |
| POST | `/schedule-templates` | create template |
| PUT | `/schedule-templates/{id}` | update template metadata |
| DELETE | `/schedule-templates/{id}` | delete template |
| POST | `/schedule-templates/apply` | apply to one section |
| POST | `/schedule-templates/apply/bulk` | apply to multiple sections |

### Office Hours

| Method | Endpoint | Action |
|---|---|---|
| GET | `/office-hours` | list office hours |
| GET | `/office-hours/slots` | fallback list |
| POST | `/office-hours` | create office hour |
| POST | `/office-hours/slots` | fallback create |
| PUT | `/office-hours/{id}` | update office hour |
| PUT | `/office-hours/slots/{id}` | fallback update |
| DELETE | `/office-hours/{id}` | delete office hour |
| DELETE | `/office-hours/slots/{id}` | fallback delete |
| GET | `/office-hours/appointments` | appointment list by slot |
| PATCH | `/office-hours/appointments/{id}` | update appointment status (service-level available) |

---

## 8. Persistence Matrix: Live API vs Local-only vs Mock

| Feature area | Live API fetch | Live API mutations | Local-only behavior | Mock fallback |
|---|---|---|---|---|
| Student list/search/create/update/delete | Yes | Yes | Add/remove course and conflict fixes are local-only | yes |
| Course cards and staff enrichment | Yes | Yes | Schedule and Exams sub-tabs in page are local mock arrays | yes |
| Enrollment Period list | Yes (derived from semesters) | No create/update/delete endpoints called from UI | add/edit/delete periods mutate parent local state only | yes |
| Campus Events | Yes | Yes | none | yes |
| Schedule Templates | Yes | Yes | none for live path | yes |
| Office Hours | Yes | Yes | none for live path | yes |

---

## 9. Known Implementation Gaps and Reliability Notes

1. Student add/remove course actions are local-only
- They update `localEnrollments` state and do not call enrollment endpoints.

2. Student Fix Enrollment action is a stub
- Executes `alert()` and closes modal.

3. Enrollment Period create/edit/delete is local state only
- No POST/PUT/DELETE endpoint is invoked for periods.

4. Enrollment periods derivation hardcodes two departments in service
- Other departments are not derived by this function unless service logic is changed.

5. CourseManagementPage Schedule and Exams sub-tabs are mock-only
- They are display sections backed by local arrays in component scope.

6. `ExamSchedulePage.tsx` exists but is not mounted in current AdminDashboard periods route
- exported in components index but not used in active tab rendering path.

7. Schedule Templates edit flow currently updates metadata only
- slots can be edited in UI but slot changes are not included in update payload.

8. Office Hours live filtering mismatch
- query uses instructor/day filters server-side;
- search/mode/role filters are applied in fallback mock function, not on live fetched array in the same way.

9. Campus Events mock objects and strict service types may diverge
- check consistency between `eventId` based runtime use and mock object shape during fallback maintenance.

---

## 10. Button-by-Button Quick Index (All Requested Pages)

## 10.1 Student Management page

- Add Student
- Edit Student
- Add Course (local)
- Remove Course (local)
- Fix Enrollment (stub)
- Delete Student
- Search input
- Year filter
- Status filter

## 10.2 Course Management page

- Add Course (wizard)
- Edit Course (wizard)
- Delete Course
- Staff Assign
- Sub-tab switch buttons
- Course search
- Department filter
- Status filter
- Export button (visual)
- Schedule Add button (visual)
- Exams Add button (visual)

## 10.3 Enrollment Periods core tab

- Open Period
- Edit Period
- Delete Period
- Status filter
- Sub-tab switching to Events/Templates/Office Hours

## 10.4 Campus Events sub-tab

- Create Event
- Edit Event
- Delete Event
- Expand registration row
- Search/type/status/department/date filters
- Pagination previous/next

## 10.5 Schedule Templates sub-tab

- Create Template wizard (step navigation)
- Edit Template wizard
- Delete Template
- Apply Template
- Bulk Apply Template
- Add slot / remove slot
- Search and all filters
- Pagination previous/next

## 10.6 Office Hours sub-tab

- Add Office Hour
- Edit Office Hour
- Delete Office Hour
- Expand appointments
- Search and all filters
- Pagination previous/next

---

## 11. Appendix: Primary Data Models Referenced in These Features

## 11.1 Student table model (component-level)

```ts
interface Student {
  id: number;
  studentId: string;
  name: string;
  email: string;
  year: string;
  enrolledCourses: string[];
  status: 'active' | 'on-hold' | 'graduated';
}
```

## 11.2 Course card model (admin page)

```ts
interface Course {
  id: number;
  code: string;
  name: string;
  department: string;
  semester: string;
  credits: number;
  enrolled: number;
  capacity: number;
  status: string;
  instructor: string;
  instructorId: number;
  taIds: number[];
  taNames?: string[];
  level: string;
  prerequisites: string[];
  sectionId?: number | null;
}
```

## 11.3 Enrollment period model (periods tab)

```ts
interface EnrollmentPeriod {
  id: number;
  department: string;
  semester: string;
  startDate: string;
  endDate: string;
  totalStudents: number;
  registeredStudents: number;
  status: 'active' | 'closed' | 'upcoming';
  description: string;
}
```

## 11.4 Scheduling service models used directly

- `CampusEvent`
- `ScheduleTemplate`
- `ScheduleTemplateSlot`
- `OfficeHoursSlot`
- `OfficeHoursAppointment`
- `PaginatedResponse<T>` and `PaginationMeta`

(Defined in `src/services/api/scheduleService.ts` and consumed in the three scheduling sub-pages.)

---

## 12. Implementation Notes for Future Hardening

1. Move Student course add/remove to real enrollment endpoints to persist data.
2. Add period create/update/delete backend endpoints and wire mutations in `EnrollmentPeriodPage` through parent.
3. Convert CourseManagement Schedule/Exams sub-tabs from mock arrays to API-backed data.
4. Include slots in schedule template update payload when edited.
5. Unify enrollment endpoint path conventions (`section` vs `sections`) to reduce maintenance risk.
6. Add server-side query support for office-hours search/mode/role, or apply complete client-side filters to live data.
7. Add test cases for wizard step transitions and partial skip paths.

---

## 13. Phase Gate Evidence Update (2026-04-16) - Periods and Scheduling (Mobile)

This section records the next-phase hardening gate output for the four newly integrated admin screens:

- `lib/screens/admin/periods/admin_enrollment_periods_screen.dart`
- `lib/screens/admin/events/admin_campus_events_screen.dart`
- `lib/screens/admin/templates/admin_schedule_templates_screen.dart`
- `lib/screens/admin/office_hours/admin_office_hours_screen.dart`

Validation artifacts used in this phase:

- Service contract source: `lib/services/api/admin_periods_service.dart`
- Response mapping source: `lib/models/admin/admin_periods_models.dart`
- Focused widget suites:
  - `test/widgets/admin/periods/admin_enrollment_periods_screen_test.dart`
  - `test/widgets/admin/events/admin_campus_events_screen_test.dart`
  - `test/widgets/admin/templates/admin_schedule_templates_screen_test.dart`
  - `test/widgets/admin/office_hours/admin_office_hours_screen_test.dart`

### 13.1 Manual Flow Checklist (Current Gate Snapshot)

Status legend:

- Code-path: verified by source review and bound callbacks/state.
- Widget-test: verified by targeted widget tests in this phase.
- Manual-run: physical/emulator clickthrough in this session.

#### 13.1.1 Enrollment Periods

| Flow | Code-path | Widget-test | Manual-run |
|---|---|---|---|
| Open screen from route `/admin/enrollment-periods` | Yes | N/A | Pending |
| Pull-to-refresh calls live reload | Yes | N/A | Pending |
| Status chips (`all/active/upcoming/closed`) filter rendered cards | Yes | N/A | Pending |
| Error state shows retry action | Yes | N/A | Pending |
| Empty state renders for no matching periods | Yes | N/A | Pending |
| Period cards show semester, department, date range, progress, registered ratio | Yes | Yes | Pending |

#### 13.1.2 Campus Events

| Flow | Code-path | Widget-test | Manual-run |
|---|---|---|---|
| Open screen from route `/admin/campus-events` | Yes | N/A | Pending |
| Search and status filter trigger list fetch | Yes | N/A | Pending |
| Create modal validation (`title` required, end after start) | Yes | N/A | Pending |
| Create/Edit submit to API and show success/failure snackbar | Yes | N/A | Pending |
| Delete confirmation and delete action | Yes | N/A | Pending |
| Registrations bottom sheet loads and renders attendee rows | Yes | N/A | Pending |
| Pagination previous/next updates current page | Yes | N/A | Pending |
| Event parity chips/counters (mandatory, registration required, capacity, spots) render | Yes | Yes | Pending |

#### 13.1.3 Schedule Templates

| Flow | Code-path | Widget-test | Manual-run |
|---|---|---|---|
| Open screen from route `/admin/schedule-templates` | Yes | N/A | Pending |
| Search and schedule-type filter trigger list fetch | Yes | N/A | Pending |
| Create/Edit template validation (`name` required) | Yes | N/A | Pending |
| Update payload carries existing slots (hardening parity) | Yes | N/A | Pending |
| Delete confirmation and delete action | Yes | N/A | Pending |
| Apply dialog validates section ID and surfaces result | Yes | N/A | Pending |
| Bulk apply dialog parses section IDs and surfaces success/failure counts | Yes | N/A | Pending |
| Slot preview line and `+N more slots` indicator render | Yes | Yes | Pending |
| Pagination previous/next updates current page | Yes | N/A | Pending |

#### 13.1.4 Office Hours

| Flow | Code-path | Widget-test | Manual-run |
|---|---|---|---|
| Open screen from route `/admin/office-hours` | Yes | N/A | Pending |
| Initial load fetches staff and slot pages | Yes | N/A | Pending |
| Instructor/day filters apply server query; mode/role/search apply local filtering | Yes | N/A | Pending |
| Create/Edit validation (`instructor`, `location`, `HH:mm`) | Yes | N/A | Pending |
| Delete confirmation and delete action | Yes | N/A | Pending |
| Expand appointments fetches and renders appointment cards | Yes | N/A | Pending |
| Pagination previous/next updates current page | Yes | N/A | Pending |
| Slot summary labels (mode, ratio) render localized values | Yes | Yes | Pending |

### 13.2 Endpoint-to-UI Evidence Update (Four-Screen Scope)

#### 13.2.1 Enrollment Periods

| Endpoint | Request fields | Response fields consumed | UI binding evidence |
|---|---|---|---|
| `GET /semesters` | none | `id/semesterId`, `semester/semesterName/name`, `departmentName/department`, `registrationStart/startDate`, `registrationEnd/endDate`, `totalStudents/capacity/total`, `registeredStudents/enrolledStudents/registrationCount`, `description/notes`, `status` (or date-derived fallback) | `AdminPeriodsService.getEnrollmentPeriods` -> `EnrollmentPeriodModel.fromSemesterJson` -> cards/metrics in `AdminEnrollmentPeriodsScreen` (`_buildHeroCard`, `_buildPeriodCard`) |

#### 13.2.2 Campus Events

| Endpoint | Request fields | Response fields consumed | UI binding evidence |
|---|---|---|---|
| `GET /campus-events` | `page`, `limit`, optional `search`, `status` | list fields: `eventId`, `title`, `description`, `eventType`, `startDateTime`, `endDateTime`, `location/building/room`, `isMandatory`, `registrationRequired`, `maxAttendees`, `registrationCount`, `spotsRemaining`, `status`, `tags`; meta: `totalPages` | `AdminPeriodsService.getCampusEvents` -> `CampusEventModel.fromJson` -> list cards/pagination in `AdminCampusEventsScreen` |
| `POST /campus-events` | `title`, `eventType`, `status`, `startDatetime`, `endDatetime`, `isMandatory`, `registrationRequired`, `color`, optional `description`, optional `location`, optional `maxAttendees` | created event payload parsed into `CampusEventModel` and reflected after reload | submit flow in `_openEventForm` (`event == null`) |
| `PUT /campus-events/{id}` | same payload as create | updated event payload parsed into `CampusEventModel` and reflected after reload | submit flow in `_openEventForm` (`event != null`) |
| `DELETE /campus-events/{id}` | path param `id` | success/failure only | `_confirmDelete` action and snackbar feedback |
| `GET /campus-events/{id}/registrations` | path param `id` | `registrationId/id`, `attendeeName` or `user.firstName+lastName`, `attendeeEmail` or `user.email`, `status` | `_showRegistrations` -> `_loadRegistrations` -> ListTile rows |

#### 13.2.3 Schedule Templates

| Endpoint | Request fields | Response fields consumed | UI binding evidence |
|---|---|---|---|
| `GET /schedule-templates` | `page`, `limit`, optional `search`, optional `scheduleType` | list fields: `templateId`, `name`, `description`, `departmentName`, `scheduleType`, `isActive`, `creatorName`, `slotCount`, `slots[]`; meta: `totalPages` | `AdminPeriodsService.getScheduleTemplates` -> `ScheduleTemplateModel.fromJson` -> template cards/pagination in `AdminScheduleTemplatesScreen` |
| `POST /schedule-templates` | `name`, `scheduleType`, `isActive`, optional `description`, `slots` | created template parsed and visible after list refresh | `_openTemplateForm` create branch |
| `PUT /schedule-templates/{id}` | `name`, `scheduleType`, `isActive`, optional `description`, `slots` (existing slots included in hardening pass) | updated template parsed and visible after list refresh | `_openTemplateForm` edit branch |
| `DELETE /schedule-templates/{id}` | path param `id` | success/failure only | `_confirmDelete` action and snackbar feedback |
| `POST /schedule-templates/apply` | `templateId`, `sectionId`, optional `building`, optional `room` | `schedulesCreated` consumed in success snackbar | `_openApplyDialog` |
| `POST /schedule-templates/apply/bulk` | `templateId`, `sectionIds[]`, optional `building`, optional `room` | `successful`, `failed` consumed in result snackbar | `_openBulkApplyDialog` |

#### 13.2.4 Office Hours

| Endpoint | Request fields | Response fields consumed | UI binding evidence |
|---|---|---|---|
| `GET /admin/users` (staff lookup) | `page=1`, `size=100`, `role` in `{instructor, teaching_assistant}`, `status=active` | `userId/id`, `firstName`, `lastName`, `email`, `role/roles` -> `AdminStaffSummaryModel` | `AdminPeriodsService.getStaffMembers` -> staff dropdown/name lookups in `AdminOfficeHoursScreen` |
| `GET /office-hours` (fallback `/office-hours/slots`) | `page`, `limit`, optional `instructorId`, optional `dayOfWeek` | slot fields: `slotId/id`, `instructorId`, `dayOfWeek`, `startTime`, `endTime`, `location`, `mode`, `maxAppointments`, `currentAppointments`, `isActive`, `notes`; meta: `totalPages` | `AdminPeriodsService.getOfficeHours` -> `OfficeHourSlotModel.fromJson` -> slot cards/pagination/filters |
| `POST /office-hours` (fallback `/office-hours/slots`) | `instructorId`, `dayOfWeek`, `startTime`, `endTime`, `location`, `mode`, `isActive`, optional `maxAppointments`, optional `notes` | created slot parsed and visible after reload | `_openSlotForm` create branch |
| `PUT /office-hours/{id}` (fallback `/office-hours/slots/{id}`) | same payload as create | updated slot parsed and visible after reload | `_openSlotForm` edit branch |
| `DELETE /office-hours/{id}` (fallback `/office-hours/slots/{id}`) | path param `id` | success/failure only | `_confirmDelete` action and snackbar feedback |
| `GET /office-hours/appointments` | `slotId`, `page`, `limit` | `appointmentId/id`, `studentName/student`, `topic`, `appointmentDate/scheduledAt/date`, `status` | `_toggleAppointments` -> appointment rows in expanded slot view |

### 13.3 Phase Gate Command Evidence

- Analyzer gate on touched scope: passed (`No issues found`).
- Focused widget gate for four screens: passed (`+4: All tests passed`).
- Localization generation/check gate: passed (`flutter gen-l10n` and post-check `MISSING=0`).

---

End of document.
