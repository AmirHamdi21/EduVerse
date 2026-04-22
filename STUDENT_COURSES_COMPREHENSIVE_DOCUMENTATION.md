# EduVerse Student Courses - Comprehensive Implementation Documentation

## 1. Purpose and Coverage

This document provides implementation-level documentation for the Student Courses feature in EduVerse frontend, with the same style/depth as the admin comprehensive documentation.

It focuses on the real, current code behavior (not intended design only), including:

1. Student Courses entry orchestration from the student dashboard container.
2. My Class screen (`ClassTab`) and its internal course-card behavior.
3. Registration screen (`CourseRegistration`) and all enrollment/drop workflows.
4. Course Details screen (`CourseView`) including materials, structure, announcements, and staff navigation.
5. Public instructor/TA profile screen (`PublicProfileView`) and office-hours appointment booking flow.
6. Shared small components and support layers that directly impact the above pages.
7. Backend endpoints, request variables, response fields, field-to-variable mapping, and where each field is consumed.
8. Button/control click flows step-by-step.

### 1.1 Explicitly In Scope

- Route orchestration and tab routing in `StudentDashboard`.
- The full path: My Class -> Course Details -> Instructor/TA profile -> Appointment booking.
- Registration catalog filtering, enroll modal, section selection, and dropping registered courses.
- Service-layer contracts used by these pages.
- Context/hook support behavior (`LanguageContext`, `ThemeContext`, `useApi`).

### 1.2 Out of Scope (except where they influence course flow)

- Non-course tabs (analytics, AI tab internals, payments internals, etc.).
- Instructor and admin dashboard implementations (except shared API contract references).

---

## 2. Route and Composition Overview

### 2.1 Top-Level Student Dashboard Routes

Defined in `src/App.jsx`:

1. `/studentdashboard`
2. `/studentdashboard/:tab`
3. `/studentdashboard/:tab/:id`

All three routes mount `StudentDashboard`, and the page behavior is then driven by pathname parsing inside `StudentDashboard.tsx`.

### 2.2 Course-Relevant Tab Keys and Route Patterns

In `StudentDashboard.tsx`, the course-relevant tabs are:

- `myclass`
- `registration`
- `profile` (used for public profile route when `:id` exists)

Key route patterns used by the student courses flow:

1. `/studentdashboard/myclass`
2. `/studentdashboard/myclass/:id` (course details fullscreen mode)
3. `/studentdashboard/registration`
4. `/studentdashboard/profile/:id` (public profile + booking)

### 2.3 Parent-Child Wiring (High-Level)

1. `StudentDashboard` chooses active content by `activeTab` derived from URL segment.
2. For `myclass` tab:
   - Renders `ClassTab` when no selected course fullscreen state.
   - Renders `CourseViewPage` when `viewingCourseId` is set.
3. For `registration` tab:
   - Renders `CourseRegistration`.
4. For `profile/:id` route pattern:
   - Renders `PublicProfileView` (public staff profile and booking).

### 2.4 End-to-End User Navigation Chain (Main Course Journey)

1. User enters `/studentdashboard/myclass`.
2. `ClassTab` fetches enrolled courses and renders cards.
3. User clicks `View Course` or `Materials`.
4. Parent `StudentDashboard` navigates to `/studentdashboard/myclass/{courseId}` and renders `CourseViewPage`.
5. In `CourseViewPage`, user can click instructor/TA card.
6. `CourseViewPage` navigates to `/studentdashboard/profile/{staffId}` with `location.state` containing `staff` and `course` context.
7. `PublicProfileView` loads staff profile and (if instructor) allows office-hours booking.

---

## 3. Source File Inventory (Feature Scope)

## 3.1 Routing and Orchestration

| File | UI Responsibility | Core Logic Responsibility |
| --- | --- | --- |
| `src/App.jsx` | Exposes student dashboard routes | Route patterns and mounting `StudentDashboard` |
| `src/pages/student-dashboard/StudentDashboard.tsx` | Main dashboard shell, tab content switch, sidebar/header composition | URL-driven tab parsing, course fullscreen route sync, course open/back callbacks, notification polling |

## 3.2 My Class Screen

| File | UI Responsibility | Core Logic Responsibility |
| --- | --- | --- |
| `src/pages/student-dashboard/components/ClassTab.tsx` | Enrolled courses grid and card UI | Fetches my courses, maps API payload to card model, fallback behavior, per-card button actions |

## 3.3 Registration Screen

| File | UI Responsibility | Core Logic Responsibility |
| --- | --- | --- |
| `src/pages/student-dashboard/components/CourseRegistration.tsx` | Catalog list, filters, selected-course panel, registered courses sidebar, confirmation modal | Fetches available + enrolled courses, filtering, enroll/drop mutations, section selection validation, credit checks |
| `src/components/shared/CustomDropdown.tsx` | Custom select dropdown for department/level filters | Open/close state, option selection callback, outside-click handling |

## 3.4 Course Details Screen

| File | UI Responsibility | Core Logic Responsibility |
| --- | --- | --- |
| `src/pages/student-dashboard/pages/CourseView.tsx` | Course header, preview panel, tabs, content structure tree, staff cards | Enrollment matching, materials/structure loading, bundle-aware selection, announcements sorting, track-view side effect, staff navigation |
| `src/utils/materialBundles.ts` | No direct UI; supports grouped lecture display | Parses and groups material naming patterns into lecture bundles with video/doc/instructions extraction |

## 3.5 Public Profile + Appointment Booking Screen

| File | UI Responsibility | Core Logic Responsibility |
| --- | --- | --- |
| `src/pages/student-dashboard/pages/PublicProfileView.tsx` | Staff profile card, contact/socials, office-hour slots list, booking form | Fetch profile, fetch available slots, fetch student appointments, duplicate booking prevention, reservation mutation |

## 3.6 Shared UI Dependencies Used by This Feature

| File | UI Responsibility | Core Logic Responsibility |
| --- | --- | --- |
| `src/components/shared/DashboardSidebar.tsx` | Left navigation tabs and grouped sections | Group collapse/expand behavior, active-tab routing callback, compact/fullscreen sidebar behavior |
| `src/components/shared/DashboardHeader.tsx` | Header actions (search, notifications, profile menu, language/theme/color) | Notification menu state/read handling, theme/language/color callbacks, mobile/desktop interaction variants |

## 3.7 Hooks, Contexts, and API Layers

| File | Responsibility |
| --- | --- |
| `src/hooks/useApi.ts` | Generic fetch lifecycle (`data`, `loading`, `error`, `refetch`) |
| `src/pages/student-dashboard/contexts/LanguageContext.tsx` | Translation keys and RTL/LTR direction handling |
| `src/pages/student-dashboard/contexts/ThemeContext.tsx` | Light/dark mode and accent-color persistence/sync |
| `src/services/api/enrollmentService.ts` | Enrollment, available courses, section staff endpoints + types |
| `src/services/api/courseService.ts` | Materials/structure endpoints + helpers (preview/download URL) |
| `src/services/api/announcementService.ts` | Announcements endpoint + type definitions |
| `src/services/api/userService.ts` | Public profile endpoint |
| `src/services/api/scheduleService.ts` | Office-hours slots/appointments endpoints + types |
| `src/services/api/gradesService.ts` | GPA endpoint used by student container stats |
| `src/services/api/notificationService.ts` | Header unread count endpoint used by student container |
| `src/services/api/client.ts` | `ApiClient` and axios `client` auth/error behavior |
| `src/services/api/config.ts` | API base URL and token key definitions |

---

## 4. StudentDashboard Container - Deep Documentation

## 4.1 Primary Implementation File

- `src/pages/student-dashboard/StudentDashboard.tsx`

### 4.1.1 UI Composition

Main layout sections:

1. Dashboard shell wrapper
   - Applies theme classes and RTL direction.
   - Hosts sidebar + main content.

2. `DashboardSidebar`
   - Receives tab definitions, active tab, tab-change callback.
   - Switches to compact mode when course details are fullscreen.

3. Main content area
   - Hides header in chat/fullscreen course mode.
   - Renders either:
     - `CourseViewPage` (when `viewingCourseId` exists), or
     - tab content panel (`ClassTab`, `CourseRegistration`, etc.).

4. Profile route branch
   - If route resolves to `/studentdashboard/profile/:id`, renders `PublicProfileView`.

### 4.1.2 Local State Model

| Variable | Type | Purpose | Used In UI |
| --- | --- | --- | --- |
| `sidebarOpen` | `boolean` | Mobile sidebar open state | `DashboardSidebar` mobile open/close |
| `viewingCourseId` | `string \| null` | Current selected course for fullscreen details mode | Conditional render of `CourseViewPage` |
| `desktopSidebarExpanded` | `boolean` | Toggle expanded sidebar while in compact/fullscreen mode | `DashboardSidebar` `desktopExpanded` |
| `headerUnreadCount` | `number` | Header notification badge count | `DashboardHeader` `notificationCount` prop |
| `activeTab` | `string` (derived) | Current tab from URL segment | Conditional tab rendering |
| `routeParamId` | `string \| null` (derived) | URL `:id` segment | course/profile route checks |
| `isCourseRoute` | `boolean` (derived) | URL indicates `/myclass/:id` | sync effect for course fullscreen |
| `isCourseFullscreen` | `boolean` (derived) | UI should collapse layout into course details mode | compact sidebar + hidden header behavior |
| `isPublicProfileView` | `boolean` (derived) | Route is `/profile/:id` | Render `PublicProfileView` branch |

### 4.1.3 Core Logic and Computed Behavior

1. URL-driven tab resolution
   - `activeTab` is computed by splitting pathname.
   - Prevents tab state drift because URL is source of truth.

2. Course fullscreen synchronization
   - `useEffect` watches route and sets/clears `viewingCourseId`.
   - Keeps direct URL navigation and UI state aligned.

3. Child-to-parent course navigation contract
   - `ClassTab` receives `onViewCourse`.
   - Parent handles navigation and fullscreen toggling.

4. Header unread polling
   - Calls `NotificationService.getUnreadCount()` immediately and every 30 seconds.
   - Updates header badge without requiring tab refresh.

5. Stats composition for dashboard card values
   - Uses `EnrollmentService.getMyCourses()` and `GradesService.getGpa(userId)`.
   - Computes total credits, active classes, GPA display.

### 4.1.4 Container Endpoints and Field Usage

## 4.1.4.1 GET `/enrollments/my-courses`

Called from:
- `StudentDashboard.tsx` via `useApi(() => EnrollmentService.getMyCourses(), [])`

Consumed fields:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `course.credits` | `number` | `totalCredits` reduce input | Dashboard stats card `Credits Completed` |
| `status` | `string` | `activeClasses` filter input | Dashboard stats card `Active Class` |

## 4.1.4.2 GET `/grades/gpa/{studentId}`

Called from:
- `StudentDashboard.tsx` via `GradesService.getGpa(user.userId)`

Consumed fields:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `cumulativeGpa` | `number` | `gpaValue` | Main GPA card value |
| `semesterGpa` | `number` | `gpaSummary.semesterGpa` | GPA comparison text |

## 4.1.4.3 GET `/notifications/unread-count`

Called from:
- `StudentDashboard.tsx` polling effect via `NotificationService.getUnreadCount()`

Consumed fields:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `count` | `number` | `headerUnreadCount` | Header notification badge |

### 4.1.5 Container Button/Control Flow Narratives

## 4.1.5.1 Sidebar Tab Click

1. User clicks a tab in `DashboardSidebar`.
2. `onTabChange(tabId)` calls `handleTabChange`.
3. Container clears `viewingCourseId` and compact sidebar state.
4. Navigates to `/studentdashboard/{tabId}`.
5. Scrolls content to top.
6. URL re-parsing updates `activeTab` and renders matching page.

## 4.1.5.2 Open Course From Child (`ClassTab` callback)

1. Child calls `onViewCourse(courseId)`.
2. Parent executes `handleViewCourse`.
3. Navigates to `/studentdashboard/myclass/{courseId}`.
4. Sets `viewingCourseId`.
5. Course fullscreen mode activates and `CourseViewPage` renders.

## 4.1.5.3 Back From Course Details

1. `CourseViewPage` back button triggers parent `onBack`.
2. `handleBackFromCourse` navigates to `/studentdashboard/myclass`.
3. Clears `viewingCourseId` and expanded compact sidebar.
4. Returns to course list (`ClassTab`).

## 4.1.5.4 Header Profile Action

1. User chooses profile action in header dropdown.
2. `DashboardHeader` calls `onProfileClick`.
3. Container routes to `handleTabChange('profile')`.
4. If route has no id -> normal dashboard profile tab.
5. If route has `/profile/:id` -> `PublicProfileView` branch is rendered.

---

## 5. My Class (`ClassTab`) - Deep Documentation

## 5.1 Primary Implementation File

- `src/pages/student-dashboard/components/ClassTab.tsx`

### 5.1.1 UI Composition

`ClassTab` renders:

1. Section heading (`Enrolled Courses`, description).
2. Responsive grid of `CourseCard` items.
3. Per-card content blocks:
   - top color bar,
   - course title/code,
   - section + semester + enrollment status,
   - schedule + grade summary,
   - students/credits summary,
   - progress bar,
   - action buttons (`View Course`, `Materials`).

### 5.1.2 Local State and Derived Data Model

`ClassTab` has no manual `useState`, but receives async state from `useApi`.

| Variable | Type | Purpose | Usage |
| --- | --- | --- | --- |
| `enrollments` | `EnrolledCourse[] \| null` | Raw API result | source for `apiCourses` mapping |
| `loading` | `boolean` | Fetch status | loading spinner branch |
| `error` | `string \| null` | Fetch failure | error banner branch |
| `apiCourses` | `Course[]` (derived) | Card-friendly mapped model | grid rendering |
| `courses` | `Course[]` (derived) | Chooses API data or fallback `propCourses/defaultCourses` | final render source |

Mapped `Course` fields in `ClassTab`:

| Field | Type | Source |
| --- | --- | --- |
| `id` | `string` | `e.id` |
| `title` | `string` | `e.course.name` |
| `courseCode` | `string` | `e.course.code` |
| `status` | `string` | `e.status` |
| `sectionNumber` | `string` | `e.section.sectionNumber` |
| `semesterName` | `string` | `e.semester.name` |
| `grade` | `string` | multi-candidate extraction from typed + raw fields |
| `students` | `number` | `e.section.currentEnrollment` |
| `credits` | `number` | `e.course.credits` |
| `progress` | `number` | currently hard-coded to `0` |

### 5.1.3 Core Logic

1. Fetch path
   - Calls `enrollmentService.getMyCourses()` through `useApi`.

2. Grade normalization fallback chain
   - Tries multiple grade candidates (typed and raw object fields), then falls back to `N/A`.

3. Card color assignment
   - Uses `COURSE_COLORS[i % COURSE_COLORS.length]` to cycle palette.

4. Data fallback behavior
   - If API has no courses, component falls back to props or local `defaultCourses` dataset.

### 5.1.4 Endpoint and Field-Level Usage

## 5.1.4.1 GET `/enrollments/my-courses`

Called from:
- `ClassTab.tsx` in `useApi` fetcher.

Field usage map:

| Response field | Type | Mapped variable | Where used |
| --- | --- | --- | --- |
| `id` | `string` | `course.id` | card key and view/material button payload |
| `course.name` | `string` | `course.title` | card title |
| `course.code` | `string` | `course.courseCode` | card subtitle |
| `status` | `string` | `course.status` | enrollment status text |
| `section.sectionNumber` | `string` | `course.sectionNumber` | section badge text |
| `semester.name` | `string` | `course.semesterName` | section row text |
| `section.location` | `string` | `course.room` | mapped but not primary display emphasis |
| `section.currentEnrollment` | `number` | `course.students` | students count row |
| `course.credits` | `number` | `course.credits` | credits row |
| `grade` | `string \| null` | candidate grade source | grade row |
| `finalScore` and raw grade aliases | `unknown` | fallback candidate values | grade fallback resolution |

### 5.1.5 Button/Control Flow Narratives

## 5.1.5.1 `View Course` Button

1. User clicks `View Course` on card.
2. Card calls `onViewCourse?.(course.id)`.
3. Parent `StudentDashboard` navigates to `/studentdashboard/myclass/{courseId}`.
4. `CourseViewPage` mounts and begins full course data loading.

## 5.1.5.2 `Materials` Button

1. User clicks `Materials` on same card.
2. Uses exact same callback and id as `View Course`.
3. Result is same navigation to course details page (not a separate material-only page).

## 5.1.5.3 Three-Dot `MoreVertical` Button

1. User clicks top-right menu icon.
2. No click handler is currently attached.
3. No state change and no side effect.

## 5.1.5.4 Loading and Error Branches

1. While fetching, page shows centered spinner.
2. On fetch error, page renders error banner and no cards.
3. On success, grid renders mapped cards.

---

## 6. Course Registration (`CourseRegistration`) - Deep Documentation

## 6.1 Primary Implementation File

- `src/pages/student-dashboard/components/CourseRegistration.tsx`

### 6.1.1 UI Composition

Main blocks:

1. Header
   - title + subtitle.

2. Stats cards
   - credits enrolled,
   - courses registered,
   - waitlist count.

3. Left panel: course catalog
   - search input,
   - department dropdown,
   - level dropdown,
   - course result cards with status tags and enroll actions.

4. Right panel: student schedule/registered list
   - registered courses summary,
   - drop action per registered item,
   - selected course detail card.

5. Modal: registration confirmation
   - selected course summary,
   - section picker,
   - capacity availability,
   - credit warning,
   - cancel/confirm actions,
   - error feedback block.

### 6.1.2 Local State Model

| Variable | Type | Purpose | Used In UI |
| --- | --- | --- | --- |
| `searchQuery` | `string` | Free-text filtering | catalog search input |
| `selectedDepartment` | `string` | Department filter selection | dropdown + filter logic |
| `selectedLevel` | `string` | Level filter selection | dropdown + filter logic |
| `selectedCourse` | `Course \| null` | Catalog item currently highlighted | right-side details card |
| `showPrereqsFor` | `string \| null` | Which course prerequisite popup is open | prereq tooltip display |
| `availableCourses` | `ApiAvailableCourse[]` | Raw API available list | mapped into `mappedApiCourses` |
| `showConfirmModal` | `boolean` | Enrollment modal visibility | modal branch |
| `courseToRegister` | `Course \| null` | Course being enrolled | modal content |
| `selectedSectionId` | `string` | Selected section id in modal | payload source + button enable |
| `submitting` | `boolean` | In-flight enroll mutation | confirm button text/disable |
| `droppingId` | `string \| null` | Current drop mutation target | drop button loading text |
| `enrollError` | `string` | Enroll mutation error text | modal error block |

Derived/computed data:

| Variable | Type | Purpose |
| --- | --- | --- |
| `mappedApiCourses` | `Course[]` | API shape normalized for UI cards |
| `registeredCourses` | `RegisteredCourse[]` | My enrollments reshaped for sidebar |
| `totalCredits` | `number` | sum of registered course credits |
| `departmentOptions` | `DropdownOption[]` | dynamic dropdown options |
| `levelOptions` | `DropdownOption[]` | dynamic dropdown options |
| `filteredCourses` | `Course[]` | search + department + level filtered list |
| `selectedCourseSections` | `ApiAvailableCourse['sections']` | sections in modal |
| `selectedSection` | `section \| undefined` | selected section details |

### 6.1.3 Core Logic Functions

1. `handleRegister(course)`
   - Opens confirmation modal.
   - Resets section selection and error state.

2. `confirmRegistration()`
   - Validates selected course/section.
   - Posts enrollment with `sectionId`.
   - Refetches both available and enrolled datasets.
   - Shows success/error toast and handles modal state reset.

3. `handleDrop(enrollmentId)`
   - Sends drop request.
   - Refetches both datasets.
   - Shows success/error toast.

4. `isAlreadyRegistered(courseCode)`
   - Prevents duplicate enroll action for already-registered course codes.

5. `getApiErrorMessage(error)`
   - Extracts backend `response.data.message` when present.

### 6.1.4 Endpoints and Field-Level Response Usage

## 6.1.4.1 GET `/enrollments/available`

Called from:
- `CourseRegistration.tsx` via `useApi`

Request variables:
- none

Field usage map:

| Response field | Type | Mapped variable | Where consumed |
| --- | --- | --- | --- |
| `id` | `string` | `course.id` | card key and selection id |
| `code` | `string` | `course.code` | card code tag and duplicate check |
| `name` | `string` | `course.title` | card title |
| `enrollmentStatus` | `'enrolled' \| 'not_enrolled' \| 'waitlisted'` | `course.enrollmentStatus` | status badge and enroll branch |
| `canEnroll` | `boolean` | `course.canEnroll` | prerequisite-required branch |
| `credits` | `number` | `course.credits` | card stats + credit warning math |
| `departmentName` | `string` | `course.department` | card subtitle + filter source |
| `level` | `string` | `course.level` | level tag + filter source |
| `description` | `string` | `course.description` | selected-course details panel |
| `sections[]` | `AvailableCourseSection[]` | `course.sections` | modal section list |
| `sections[0].sectionNumber` | `string` | `course.scheduleLabel` | card schedule summary |
| `sections[0].location` | `string` | `course.roomLabel` | card room summary |
| `sections[0].maxCapacity` | `number` | `course.capacity` | card capacity and modal display |
| `sections[0].currentEnrollment` | `number` | `course.enrolled` | card enrollment count |
| `sections[].availableSeats` | `number` | `section.availableSeats` | modal disable/full check |

## 6.1.4.2 GET `/enrollments/my-courses`

Called from:
- `CourseRegistration.tsx` via second `useApi`

Field usage map:

| Response field | Type | Mapped variable | Where consumed |
| --- | --- | --- | --- |
| `id` | `string` | `registeredCourse.id` | drop payload and list key |
| `course.code` | `string` | `registeredCourse.code` | sidebar course label |
| `course.name` | `string` | `registeredCourse.title` | sidebar title |
| `course.credits` | `number` | credit sum input | `totalCredits` stats and warning math |
| `status` | `string` | `registeredCourse.status` | waitlist badge logic |
| `section.sectionNumber` | `string` | `scheduleLabel` part | sidebar schedule text |
| `semester.name` | `string` | `scheduleLabel` part | sidebar schedule text |

## 6.1.4.3 POST `/enrollments/register`

Called from:
- `confirmRegistration()`

Request body:

```ts
{
  sectionId: number // from selectedSectionId string converted to Number
}
```

Response usage:
- Response body not directly rendered.
- Success triggers refetch of available/enrolled lists.

## 6.1.4.4 DELETE `/enrollments/{enrollmentId}`

Called from:
- `handleDrop(enrollmentId)`

Path variable source:
- `registeredCourse.id`

Response usage:
- Message not directly rendered.
- Success triggers same dual refetch.

### 6.1.5 Button/Control Flow Narratives

## 6.1.5.1 Search Input

1. User types text.
2. `searchQuery` updates on every change.
3. `filteredCourses` recomputes using title/code/department contains logic.
4. Catalog list rerenders.

## 6.1.5.2 Department/Level Dropdowns

1. User opens `CustomDropdown`.
2. User selects option.
3. `selectedDepartment` or `selectedLevel` updates.
4. `filteredCourses` recomputes and rerenders list.

## 6.1.5.3 Catalog Card Click

1. User clicks a course card body.
2. `selectedCourse` is set.
3. Right-side details card updates to selected course.

## 6.1.5.4 Prerequisites Info Toggle

1. User clicks prerequisites chip (if rendered).
2. `showPrereqsFor` toggles between current course id and null.
3. Floating prerequisite panel opens/closes.

## 6.1.5.5 `Enroll` Button (Catalog)

1. User clicks `Enroll`.
2. `handleRegister` sets `courseToRegister` and opens modal.
3. Modal shows sections and summary.

## 6.1.5.6 Section Row Click (Modal)

1. User selects a section.
2. `selectedSectionId` updates.
3. Confirm button enable conditions reevaluated.

## 6.1.5.7 `Cancel` Button (Modal)

1. Closes modal.
2. Clears `courseToRegister` and `enrollError`.

## 6.1.5.8 `Confirm` Button (Modal)

1. Validates selected section exists.
2. Sets `submitting=true`.
3. Calls enroll endpoint.
4. On success:
   - refetches available and my courses,
   - shows success toast,
   - closes modal,
   - resets temporary state.
5. On error:
   - extracts API message,
   - sets `enrollError`,
   - shows error toast,
   - keeps modal open.
6. Finally sets `submitting=false`.

## 6.1.5.9 `Drop` Button (Registered Sidebar)

1. User clicks drop next to registered course.
2. Sets `droppingId` for that row.
3. Calls drop endpoint.
4. On success: dual refetch + success toast.
5. On error: error toast.
6. Clears `droppingId`.

---

## 7. Course Details (`CourseView`) - Deep Documentation

## 7.1 Primary Implementation File

- `src/pages/student-dashboard/pages/CourseView.tsx`

Primary support files:

- `src/services/api/courseService.ts`
- `src/services/api/enrollmentService.ts`
- `src/services/api/announcementService.ts`
- `src/utils/materialBundles.ts`

### 7.1.1 UI Composition

Main sections:

1. Header area
   - back button,
   - course metadata chips,
   - enrollment and semester summary.

2. Left main panel
   - preview container with optional selected material/bundle render,
   - top-right `Generate AI Notes` button,
   - tab strip (`overview`, `notes`, `announcements`, `reviews`),
   - tab content blocks.

3. Right panel
   - course content progress card,
   - structure tree (weeks -> lessons) or fallback flat material list.

4. Staff sub-section in overview tab
   - instructor/TA cards leading to `PublicProfileView` route.

### 7.1.2 Local State Model

| Variable | Type | Purpose |
| --- | --- | --- |
| `activeTab` | `string` | active content tab |
| `expandedSection` | `string \| null` | currently expanded week in sidebar |
| `selectedLesson` | `string \| null` | selected lesson/material key |
| `selectedMaterial` | `CourseMaterial \| null` | currently previewed material |
| `selectedBundleKey` | `string \| null` | selected lecture bundle key |
| `selectedBundleDocumentId` | `string \| null` | selected document within bundle |
| `enrollment` | `EnrolledCourse \| null` | matched student enrollment record |
| `structureResponse` | `CourseStructureResponse` | course organization payload |
| `materialsResponse` | `CourseMaterialsResponse` | materials payload (published-filtered) |
| `pageLoading` | `boolean` | initial course data loading state |
| `announcementsLoading` | `boolean` | announcements loading state |
| `pageError` | `string \| null` | critical load error |
| `courseAnnouncements` | `Announcement[]` | sorted course-specific announcements |
| `expandedAnnouncementId` | `string \| null` | read-more toggle target |
| `sectionInstructor` | `SectionStaffMember \| null` | mapped instructor profile data |
| `sectionTAs` | `SectionStaffMember[]` | mapped TA profile data |
| `staffLoading` | `boolean` | staff fetch state |
| `staffError` | `string \| null` | staff fetch error |

Key derived values:

| Variable | Type | Purpose |
| --- | --- | --- |
| `resolvedCourseId` | `string` | canonical course id for materials/structure/trackView |
| `courseSections` | `CourseSection[]` | week-grouped lessons for sidebar tree |
| `bundleData` | `{bundles,singles,bundleByMaterialId}` | grouped lecture render support |
| `selectedMaterialPreviewUrl` | `string \| null` | iframe preview source |
| `selectedBundleDocumentPreviewUrl` | `string \| null` | bundle document preview source |
| `fallbackMaterialItems` | `MaterialListItem[]` | flat deduped list when structure unavailable |

### 7.1.3 Core Logic Phases

## Phase A: Enrollment resolution and initial course load

1. Route id is read from `useParams` fallback chain.
2. Fetches all student enrollments.
3. Matches enrollment by multiple ids/codes.
4. If not found -> page error branch.
5. If found -> resolve course id.
6. Parallel fetch structure + materials.
7. Filters materials to `isPublished === 1`.
8. Initializes expanded first week and resets selection state.

## Phase B: Announcements loading

1. Runs when `resolvedCourseId` is available.
2. Calls announcements endpoint with `courseId` query.
3. Sorts pinned first, then newest by publish/create timestamp.
4. Stores sorted array for announcements tab.

## Phase C: Section staff loading

1. Runs when `enrollment.section.id` exists.
2. Parallel fetch instructor + TAs.
3. Normalizes response into `SectionStaffMember` shape.
4. Displays in overview tab with profile navigation actions.

## Phase D: Material and bundle selection

1. On lesson/material click, tries bundle lookup.
2. If bundle exists:
   - sets bundle key,
   - picks initial document,
   - picks bundle video or first doc for preview,
   - selected lesson key format becomes `bundle:{key}`.
3. If no bundle:
   - sets direct material selection.
4. Fires non-blocking track-view call when course id exists.

### 7.1.4 Endpoints and Field-Level Variable Usage

## 7.1.4.1 GET `/enrollments/my-courses` (Course match stage)

Called from:
- initial load in `CourseView`

Field usage map:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `id` | `string` | enrollment lookup candidate | route id matching |
| `course.id` | `string` | `resolvedCourseId` source | structure/material fetch + trackView |
| `course.code` | `string` | enrollment lookup candidate | route id matching fallback |
| `course.name` | `string` | display title | header and welcome text |
| `course.description` | `string` | overview text | About section |
| `course.credits` | `number` | metadata chip | header badges |
| `course.level` | `string` | metadata chip | header badges |
| `section.id` | `string` | staff endpoint param | instructor/TA fetch |
| `section.sectionNumber` | `string` | section badge/detail | header + overview section info |
| `section.currentEnrollment` | `number` | enrollment stat | header `students enrolled` |
| `section.location` | `string` | location text | header + section info |
| `semester.name` | `string` | semester text | header chip + semester panel |
| `semester.startDate/endDate` | `string` | formatted date range | semester panel |
| `status` | `string` | status badge text | header chip |
| `enrollmentDate` | `string` | formatted date text | header info row |
| `prerequisites` | `unknown[]` | overview prerequisites list | prerequisite cards |

## 7.1.4.2 GET `/courses/{courseId}/structure`

Called from:
- initial load parallel block

Field usage map:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `data[]` | `CourseStructure[]` | `structureResponse.data` | base structure storage |
| `byWeek` | `Record<string, CourseStructure[]>` | `structureResponse.byWeek` | right-side week accordion render |
| `organizationId` | `string` | `lesson.id` | lesson key |
| `title` | `string` | lesson title | sidebar lesson label |
| `organizationType` | enum | icon and type labels | lesson icon/type rendering |
| `materialId` | `string \| null` | linkage to materials | click behavior and open material/bundle |
| `orderIndex` | `number` | sort key | ordering lessons within week |
| `weekNumber` | `number` | week group key | `Week {n}` sections |

## 7.1.4.3 GET `/courses/{courseId}/materials`

Called from:
- initial load parallel block with params `{ page:1, limit:200 }`

Filtered behavior:
- only `item.isPublished === 1` retained for student view.

Field usage map:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `data[]` | `CourseMaterial[]` | `materialsResponse.data` | preview and list source |
| `meta.total` | `number` | `materialsCount` | progress summary text |
| `materialId` | `string` | selection key | material/bundle open logic |
| `title` | `string` | labels | list rows and preview headers |
| `materialType` | enum | render branching | video/doc/link/other viewer branch |
| `description` | `string` | preview text | preview description |
| `externalUrl` | `string \| null` | iframe/link target | video embed and link open |
| `driveViewUrl` / `driveDownloadUrl` / `driveFileId` | url/id | preview url source | iframe document preview |
| `weekNumber` | `number \| null` | grouping metadata | fallback list week tag |
| `orderIndex` | `number` | sort order | bundle grouping order |
| `fileName` | `string` | bundle suffix fallback | title parsing in bundle util |
| `isPublished` | `number` | filter condition | keep only published items |

## 7.1.4.4 POST `/courses/{courseId}/materials/{materialId}/view`

Called from:
- `handleMaterialClick`

Request variables:

| Variable | Type | Source |
| --- | --- | --- |
| `courseId` | `string` | `resolvedCourseId` |
| `materialId` | `string` | clicked lesson/material id |

Response usage:
- response is ignored in UI; call is fire-and-forget for analytics.

## 7.1.4.5 GET `/announcements?courseId={id}`

Called from:
- announcements effect

Field usage map:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `id` | `string` | key | announcement cards |
| `title` | `string` | heading | announcements tab item title |
| `content` | `string` | body | read-more text block |
| `isPinned` | `number` | sort + badge | pinned-first sorting and pin icon |
| `priority` | enum/string | badge class/value | urgency badge |
| `publishedAt` / `createdAt` | `string` | sort/date render | chronological order + footer date |
| `course.name` | `string` | footer label | origin label |
| `author.firstName/lastName/email` | strings | footer author text | author identity footer |

## 7.1.4.6 GET `/enrollments/section/{sectionId}/instructor`

Called from:
- section staff effect

Field usage map:

| Response field | Type | Mapped variable | Usage |
| --- | --- | --- | --- |
| `instructorId` | `number \| null` | fallback id source | sectionInstructor mapping |
| `instructor.userId` | `number` | `sectionInstructor.id` | profile route id |
| `instructor.fullName` | `string` | `sectionInstructor.fullName` | staff card name |
| `instructor.email` | `string` | `sectionInstructor.email` | staff card contact |

## 7.1.4.7 GET `/enrollments/section/{sectionId}/tas`

Called from:
- section staff effect

Field usage map:

| Response field | Type | Mapped variable | Usage |
| --- | --- | --- | --- |
| `userId` | `number` | `ta.id` | profile route id |
| `fullName` | `string` | `ta.fullName` | TA card name |
| `email` | `string` | `ta.email` | TA card contact |

## 7.1.4.8 GET `/courses/{courseId}/materials/{materialId}/download` (URL helper)

Generated via:
- `materialService.getDownloadUrl(courseId, materialId)`

Usage:
- `window.open(downloadUrl, '_blank')` from bundle document `Open` button.

### 7.1.5 Button/Control Flow Narratives

## 7.1.5.1 Back Button (`Back to My Classes`)

1. User clicks back.
2. Calls parent `onBack`.
3. Parent navigates to `/studentdashboard/myclass`.
4. Course fullscreen state is cleared.

## 7.1.5.2 Course Content Lesson Click

1. User opens week and clicks lesson row.
2. `handleOpenLesson` checks `lesson.materialId`.
3. Delegates to `handleMaterialClick(materialId)`.
4. Material is resolved and preview state is updated.
5. Track-view endpoint fires asynchronously.

## 7.1.5.3 Bundle Document Row Click

1. User clicks document title inside selected bundle.
2. Updates `selectedBundleDocumentId`.
3. Bundle document iframe preview switches.

## 7.1.5.4 Bundle `Open` Button

1. User clicks `Open` beside bundle document.
2. Download URL is generated from course/material ids.
3. Browser opens resource in new tab/window.

## 7.1.5.5 Tab Button (`overview/notes/announcements/reviews`)

1. User clicks tab.
2. `activeTab` updates.
3. Matching tab content branch renders.
4. `notes` and `reviews` currently show placeholder text.

## 7.1.5.6 Announcement `Read more` Toggle

1. User clicks `Read more`.
2. `expandedAnnouncementId` toggles for clicked item.
3. Body truncation class toggles line clamp.

## 7.1.5.7 Instructor/TA Card Click

1. User clicks staff card in overview section.
2. Calls `handleOpenStaffProfile(staff)`.
3. Navigates to `/studentdashboard/profile/{staff.id}`.
4. Passes `location.state` containing `staff` and current `course` context.

## 7.1.5.8 `Generate AI Notes` Button

1. Button is visible in preview area.
2. No `onClick` handler is currently bound.
3. No side effect occurs (placeholder UI only).

## 7.1.5.9 Week Section Header Click

1. User clicks week accordion header.
2. Toggles `expandedSection` between week id and null.
3. Shows/hides child lessons.

---

## 8. Public Profile + Office-Hours Booking (`PublicProfileView`) - Deep Documentation

## 8.1 Primary Implementation File

- `src/pages/student-dashboard/pages/PublicProfileView.tsx`

### 8.1.1 UI Composition

Sections:

1. Back action
   - `navigate(-1)` to previous page.

2. Profile card
   - display name,
   - role labels,
   - optional course context from navigation state,
   - profile bio,
   - contact email,
   - social links.

3. Office Hours card
   - role-gated section (`isInstructor` only),
   - available slots list,
   - selected slot booking form (date/topic/notes),
   - reserve action.

### 8.1.2 Local State Model

| Variable | Type | Purpose |
| --- | --- | --- |
| `profile` | `PublicUserProfile \| null` | staff public profile payload |
| `profileLoading` | `boolean` | profile loading state |
| `profileError` | `string \| null` | profile fetch error |
| `slots` | `OfficeHoursSlot[]` | available office-hour slots |
| `loadingSlots` | `boolean` | slot loading state |
| `slotsError` | `string \| null` | slot fetch error |
| `bookedKeys` | `Set<string>` | dedupe keys for already-booked slot/date combinations |
| `selectedSlotId` | `number \| null` | selected slot in UI |
| `booking` | `boolean` | booking mutation state |
| `appointmentDate` | `string` | date field for reservation payload |
| `topic` | `string` | required booking topic |
| `notes` | `string` | optional booking notes |

Derived values:

| Variable | Type | Purpose |
| --- | --- | --- |
| `staffId` | `number` | resolved from route id or navigation state |
| `isInstructor` | `boolean` | gate to show/hide booking feature |
| `socialLinks` | `{key,value}[]` | filtered non-empty social links |
| `contactEmail` | `string` | profile/state fallback email |
| `displayName` | `string` | profile/state fallback display name |
| `selectedSlot` | `OfficeHoursSlot \| null` | selected slot data for form payload |

### 8.1.3 Core Logic

1. Profile load effect
   - validates `staffId`, fetches profile, handles auth/forbidden errors.

2. Student appointments load effect
   - fetches existing appointments,
   - builds `bookedKeys` ignoring cancelled appointments.

3. Instructor slot load effect
   - only runs if `isInstructor` and valid staff id,
   - fetches available slots and removes inactive entries.

4. Slot selection effect
   - auto-populates appointment date based on selected slot weekday.

5. Booking mutation logic
   - validates slot/date/topic,
   - prevents duplicate slot-date booking via `bookedKeys`,
   - posts reservation,
   - on success resets form and refreshes slots.

### 8.1.4 Endpoints and Field-Level Response Usage

## 8.1.4.1 GET `/users/{userId}/public`

Called from:
- profile load effect via `UserService.getPublicProfile(staffId)`

Field usage map:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `userId` | `number` | id context | profile identity |
| `fullName` | `string` | `displayName` source | main page heading |
| `firstName`/`lastName` | `string` | `displayName` fallback | heading fallback assembly |
| `email` | `string` | `contactEmail` | contact card |
| `bio` | `string \| null` | bio content | bio section |
| `roles` | `string[]` | `isInstructor` check and role text | booking gate + subtitle |
| `socialLinks` | `Record<string,string\|null>` | `socialLinks[]` | social link list |

## 8.1.4.2 GET `/office-hours/slots?instructorId={id}`

Called from:
- `loadAvailableOfficeHours(instructorId)` via `ScheduleService.getAvailableOfficeHours`

Field usage map:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `slotId` | `number` | slot key and selection id | slot button key and payload slotId |
| `dayOfWeek` | `string` | date auto-fill source | `getNextDateForDay` |
| `startTime` / `endTime` | `string` | display values | slot card time label |
| `location` | `string` | display text | slot detail text |
| `mode` | enum/string | display text | slot detail text |
| `maxAppointments` | `number` | capacity display | `x/y booked` badge |
| `currentAppointments` | `number` | capacity display | `x/y booked` badge |
| `meetingUrl` | `string \| null` | flag | `Meeting link available` text |
| `status` | `string` | filter condition | inactive slots removed |

## 8.1.4.3 GET `/office-hours/my-appointments`

Called from:
- appointments load effect via `ScheduleService.getMyOfficeHoursAppointments()`

Field usage map:

| Response field | Type | Local variable | Usage |
| --- | --- | --- | --- |
| `slotId` | `number` | booking-key part | duplicate prevention set |
| `appointmentDate` | `string` | booking-key part | duplicate prevention set |
| `status` | `string` | exclusion condition | cancelled entries ignored |

## 8.1.4.4 POST `/office-hours/appointments`

Called from:
- `reserveAppointment()`

Request payload:

```ts
{
  slotId: number,
  appointmentDate: string, // YYYY-MM-DD
  topic: string,
  notes?: string
}
```

Payload variable source:

| Payload field | Source variable |
| --- | --- |
| `slotId` | `selectedSlot.slotId` |
| `appointmentDate` | `appointmentDate` input state |
| `topic` | `topic.trim()` |
| `notes` | `notes.trim() || undefined` |

Response usage:
- Response object is not directly rendered.
- Success updates local dedupe set and triggers slot reload.

### 8.1.5 Button/Control Flow Narratives

## 8.1.5.1 Back Button

1. User clicks `Back`.
2. Calls `navigate(-1)`.
3. Returns to previous page (typically `CourseView`).

## 8.1.5.2 Social Link Click

1. User clicks a social entry.
2. Opens external link in new tab with `noopener noreferrer`.

## 8.1.5.3 Slot Button Click

1. User clicks slot row.
2. `selectedSlotId` is set.
3. Form panel appears.
4. Appointment date auto-fills to next matching weekday.

## 8.1.5.4 Reserve Appointment Button

1. Validates selected slot exists.
2. Validates date exists.
3. Validates non-empty topic.
4. Builds booking key and checks duplicate set.
5. If duplicate -> info toast and abort.
6. If valid -> posts booking payload.
7. On success:
   - success toast,
   - clear slot selection,
   - reset notes/topic,
   - add key to dedupe set,
   - refetch available slots.
8. On error:
   - error toast with API message.

---

## 9. Shared Components and Supporting Layers - Deep Documentation

## 9.1 `DashboardSidebar.tsx`

### UI Responsibility

- Renders grouped tab navigation.
- Supports desktop fixed sidebar + mobile drawer.
- Supports compact mode when course is in fullscreen state.

### Core Logic

1. Groups tabs by `group` using `groupTabs()`.
2. Maintains collapsed groups with local `Set<string>`.
3. Emits `onTabChange(tab.id)` on tab click.
4. Handles mobile close animation before firing `onMobileClose`.
5. Supports compact desktop overlay expansion (`desktopExpanded`).

### Important Feature Impact

- All course-flow page changes depend on this component dispatching tab changes.
- In course fullscreen mode, compact behavior alters available layout space and header visibility assumptions.

## 9.2 `DashboardHeader.tsx`

### UI Responsibility

- Global search entry.
- Notification bell with dropdown list.
- Profile menu with language, theme, accent color, and profile action.
- Separate desktop/mobile interaction layouts.

### Core Logic

1. Notification state
   - If `notificationCount` prop is provided, badge uses that; otherwise uses local unread count from internal list.
   - `markAsRead` and `markAllAsRead` mutate local dropdown state.

2. Profile dropdown actions
   - `onSetLanguage('en'|'ar')` from buttons.
   - `onToggleTheme()` from switch.
   - `onSetPrimaryColor(color.id)` from color picker.
   - `handleProfileClick()` -> `onProfileClick` callback or fallback `/profile` navigation.

3. Outside click handling
   - closes profile and notifications dropdowns.

### Important Feature Impact

- Language/theme/color controls directly affect course pages through context updates and CSS class/theme variables.
- Profile action transitions into profile tab/route behavior used by course flow.

## 9.3 `CustomDropdown.tsx`

### UI Responsibility

- Reusable dropdown used by registration filters.

### Core Logic

1. Maintains `isOpen`.
2. Detects outside click to close.
3. On option click:
   - calls `onChange(option.value)`,
   - optionally calls `onSelectOption(option)`,
   - closes list.

### Important Feature Impact

- Registration filtering behavior depends on accurate dropdown state and callback dispatch.

## 9.4 `LanguageContext.tsx`

### Behavior Used by Student Courses

1. Holds `language` in localStorage (`eduverse-language`).
2. Applies `document.documentElement.dir` and `lang`.
3. Exposes `t(key)` for translation strings used heavily in `ClassTab` and `CourseRegistration`.
4. Exposes `isRTL` to flip layout behavior where needed.

## 9.5 `ThemeContext.tsx`

### Behavior Used by Student Courses

1. Persists theme under `eduverse-student-theme`.
2. Applies/removes `dark` class on root element.
3. Manages accent color (`primaryColor`, `primaryHex`).
4. Syncs accent changes across dashboards via custom event `eduverse-color-change`.

## 9.6 `useApi.ts`

### Behavior

1. Generic async fetch state:
   - `data`, `loading`, `error`, and `refetch`.
2. Auto-fetches by default (`immediate=true`) and re-fetches when dependencies change.
3. Converts caught errors to string message.

### Feature Impact

- `ClassTab`, `CourseRegistration`, and `StudentDashboard` statistics rely on this hook for lifecycle and refetch semantics.

## 9.7 API Client Layers (`client.ts`, `config.ts`)

### Base URL and Auth

- Development API base is `/api` (`config.ts`).
- `ApiClient` and axios `client` inject `Authorization: Bearer {accessToken}`.
- `401` responses clear tokens and redirect to `/login`.

### Request/Response Handling

- `ApiClient` supports `params`, JSON and FormData payloads.
- Parses JSON/text responses.
- Converts server-side errors into thrown `Error` with message extraction.

### Feature Impact

- All endpoints documented in this file run through these auth/error policies.

## 9.8 `materialBundles.ts`

### Responsibility

- Converts flat material arrays into lecture bundle structures when titles follow `Base - Suffix` pattern.

### Core logic

1. `parseBundleTitle(title)` extracts base/suffix.
2. Groups candidates by `weekNumber + baseTitle` key.
3. Promotes group to bundle when multi-item or video-like content present.
4. Determines bundle video, documents, instruction text, and publish state.
5. Returns `bundleByMaterialId` for fast lookup from `CourseView`.

### Feature Impact

- Drives bundle-specific preview, deduped lesson rendering, and multi-document experience in `CourseView`.

---

## 10. Cross-Feature Endpoint Catalog (Consolidated)

| Area | Method | Endpoint | Called From |
| --- | --- | --- | --- |
| Dashboard stats | GET | `/enrollments/my-courses` | `StudentDashboard`, `ClassTab`, `CourseRegistration`, `CourseView` |
| Dashboard stats | GET | `/grades/gpa/{studentId}` | `StudentDashboard` |
| Header count | GET | `/notifications/unread-count` | `StudentDashboard` polling effect |
| Registration | GET | `/enrollments/available` | `CourseRegistration` |
| Registration | POST | `/enrollments/register` | `CourseRegistration` |
| Registration | DELETE | `/enrollments/{enrollmentId}` | `CourseRegistration` |
| Course details | GET | `/courses/{courseId}/structure` | `CourseView` |
| Course details | GET | `/courses/{courseId}/materials` | `CourseView` |
| Course details | POST | `/courses/{courseId}/materials/{materialId}/view` | `CourseView` |
| Course details | GET (URL open) | `/courses/{courseId}/materials/{materialId}/download` | `CourseView` bundle docs |
| Course details | GET | `/announcements?courseId={id}` | `CourseView` |
| Course details | GET | `/enrollments/section/{sectionId}/instructor` | `CourseView` |
| Course details | GET | `/enrollments/section/{sectionId}/tas` | `CourseView` |
| Public profile | GET | `/users/{userId}/public` | `PublicProfileView` |
| Booking | GET | `/office-hours/slots?instructorId={id}` | `PublicProfileView` |
| Booking | GET | `/office-hours/my-appointments` | `PublicProfileView` |
| Booking | POST | `/office-hours/appointments` | `PublicProfileView` |

---

## 11. Response Variable and Type Matrix (Primary Models)

## 11.1 `EnrolledCourse` (from `enrollmentService.ts`)

| Field | Type | Consumed by | Variable/Usage |
| --- | --- | --- | --- |
| `id` | `string` | `ClassTab`, `CourseRegistration`, `CourseView` | card id, drop id, enrollment lookup |
| `status` | `string` | `StudentDashboard`, `ClassTab`, `CourseRegistration`, `CourseView` | active class count, status labels, waitlist display |
| `grade` | `string \| null` | `ClassTab` | grade display candidate |
| `finalScore` | `number \| null` | `ClassTab` | grade fallback candidate |
| `enrollmentDate` | `string` | `CourseView` | enrolled-on text |
| `course.id` | `string` | `CourseView` | resolved course id for materials/structure |
| `course.name` | `string` | all course screens | titles/labels |
| `course.code` | `string` | all course screens | code labels and route matching fallback |
| `course.credits` | `number` | all course screens | stats and card/metadata |
| `course.description` | `string` | `CourseView`, `CourseRegistration` | description panels |
| `course.level` | `string` | `CourseView`, `CourseRegistration` | badges and filters |
| `section.id` | `string` | `CourseView` | staff endpoint parameter |
| `section.sectionNumber` | `string` | `ClassTab`, `CourseRegistration`, `CourseView` | schedule/section labels |
| `section.currentEnrollment` | `number` | `ClassTab`, `CourseView` | students count display |
| `section.location` | `string` | `ClassTab`, `CourseRegistration`, `CourseView` | location/room display |
| `semester.name` | `string` | `ClassTab`, `CourseRegistration`, `CourseView` | semester labels |
| `semester.startDate/endDate` | `string` | `CourseView` | semester date range |
| `prerequisites` | `unknown[]` | `CourseView` | prerequisite cards |

## 11.2 `AvailableCourse` and `AvailableCourseSection`

| Field | Type | Consumed by | Usage |
| --- | --- | --- | --- |
| `id` | `string` | `CourseRegistration` | card key and selected-course id |
| `code` | `string` | `CourseRegistration` | code labels and duplicate-check key |
| `name` | `string` | `CourseRegistration` | course title |
| `description` | `string` | `CourseRegistration` | selected-course details |
| `credits` | `number` | `CourseRegistration` | stats + warning calculation |
| `departmentName` | `string` | `CourseRegistration` | filter source and labels |
| `level` | `string` | `CourseRegistration` | filter source and level chip |
| `canEnroll` | `boolean` | `CourseRegistration` | prerequisite-required branch |
| `enrollmentStatus` | enum | `CourseRegistration` | status chips and action branches |
| `sections[].id` | `string` | `CourseRegistration` | enroll payload source |
| `sections[].sectionNumber` | `string` | `CourseRegistration` | section label |
| `sections[].maxCapacity` | `number` | `CourseRegistration` | capacity labels |
| `sections[].currentEnrollment` | `number` | `CourseRegistration` | enrolled count labels |
| `sections[].availableSeats` | `number` | `CourseRegistration` | modal full-seat disable logic |
| `sections[].location` | `string` | `CourseRegistration` | section location text |
| `sections[].semesterName` | `string` | `CourseRegistration` | section metadata text |

## 11.3 `CourseMaterial` and `CourseStructure`

| Field | Type | Consumed by | Usage |
| --- | --- | --- | --- |
| `materialId` | `string` | `CourseView` | selection and tracking id |
| `materialType` | enum | `CourseView` | preview branch and labels |
| `title` | `string` | `CourseView` | list and preview headings |
| `description` | `string` | `CourseView` | preview text/instructions |
| `externalUrl` | `string \| null` | `CourseView` | video/link open target |
| `driveViewUrl`/`driveDownloadUrl`/`driveFileId` | strings | `CourseView` | document preview URL fallback |
| `isPublished` | `number` | `CourseView` | published filter |
| `weekNumber` | `number \| null` | `CourseView` | grouping and labels |
| `orderIndex` | `number` | `CourseView`, `materialBundles` | sort ordering |
| `organizationId` | `string` | `CourseView` | lesson id |
| `organizationType` | enum | `CourseView` | icon/type labels |
| `materialId` (`CourseStructure`) | `string \| null` | `CourseView` | structure-to-material link |
| `byWeek` | grouped map | `CourseView` | week accordion model |

## 11.4 `Announcement`

| Field | Type | Consumed by | Usage |
| --- | --- | --- | --- |
| `id` | `string` | `CourseView` | item key |
| `title` | `string` | `CourseView` | heading |
| `content` | `string` | `CourseView` | body text and read-more |
| `isPinned` | `number` | `CourseView` | sort + pin indicator |
| `priority` | enum/string | `CourseView` | badge style and text |
| `publishedAt`/`createdAt` | `string` | `CourseView` | sorted order + display date |
| `author` fields | optional strings | `CourseView` | author footer |
| `course` fields | optional | `CourseView` | course/campus label |

## 11.5 Public Profile and Booking Types

| Type | Key fields used |
| --- | --- |
| `PublicUserProfile` | `fullName`, `firstName`, `lastName`, `email`, `bio`, `socialLinks`, `roles` |
| `OfficeHoursSlot` | `slotId`, `dayOfWeek`, `startTime`, `endTime`, `location`, `mode`, `maxAppointments`, `currentAppointments`, `meetingUrl`, `status` |
| `OfficeHoursAppointment` | `slotId`, `appointmentDate`, `status` (for dedupe and cancellation ignore) |
| `CreateOfficeHoursAppointmentPayload` | `slotId`, `appointmentDate`, `topic`, `notes` |

---

## 12. Persistence Matrix: Live API vs Local-Only vs Placeholder

| Feature Area | Behavior | Persistence Mode |
| --- | --- | --- |
| My Class list load | fetch from `/enrollments/my-courses` | Live API |
| My Class fallback cards | uses `defaultCourses` when API empty | Local fallback data |
| My Class menu icon | no handler | Placeholder/no-op |
| Registration catalog | fetch from `/enrollments/available` | Live API |
| Registration enroll/drop | `/enrollments/register`, `/enrollments/{id}` | Live API |
| Course details materials/structure | `/courses/{id}/materials`, `/courses/{id}/structure` | Live API |
| Material view analytics | `/materials/{materialId}/view` | Live API side effect |
| Course announcements | `/announcements?courseId=` | Live API |
| Course notes tab content | static text `coming soon` | Placeholder |
| Course reviews tab content | static text `coming soon` | Placeholder |
| `Generate AI Notes` button | visible but no onClick | Placeholder/no-op |
| Course progress value | hard-coded `0 / materialsCount` | UI placeholder metric |
| Staff profile load | `/users/{id}/public` | Live API |
| Office-hours slots/appointments | `/office-hours/*` endpoints | Live API |
| Header unread notifications | `/notifications/unread-count` polling | Live API |

---

## 13. Known Implementation Gaps and Reliability Notes

1. `CourseView` matching logic checks `item.course?.courseCode`, but typed `EnrolledCourse.course` defines `code`; this suggests compatibility code for inconsistent payloads.
2. `ClassTab` `MoreVertical` button is non-functional (no handler).
3. `ClassTab` `Materials` button performs same action as `View Course`; no separate materials mode.
4. `ClassTab` card progress is currently mapped to `0` for API courses.
5. `CourseRegistration` stats use status checks `registered` and `waitlist`; backend may return different status strings (`enrolled`, `waitlisted`).
6. `CourseRegistration` currently maps `prerequisites` to an empty array in catalog model, so prerequisite badges/details may not reflect backend data.
7. `CourseView` notes and reviews tabs are placeholders.
8. `CourseView` `Generate AI Notes` button is visual only.
9. `CourseView` track-view call swallows errors silently.
10. `PublicProfileView` duplicate booking prevention is client-side set-based; strong dedupe still depends on backend validation.
11. `PublicProfileView` office-hours visibility depends on role detection from profile or navigation state fallback; stale state could affect gating if profile response changes unexpectedly.
12. `StudentDashboard` contains local dummy `courses` array that is not part of active courses flow rendering.

---

## 14. Button-by-Button Quick Index (Requested Pages)

## 14.1 StudentDashboard Container

| Control | Handler | Result |
| --- | --- | --- |
| Sidebar tab item | `handleTabChange(tabId)` | route change + clears selected course |
| Header profile click | `handleTabChange('profile')` | opens profile tab/branch |
| Course open callback from child | `handleViewCourse(courseId)` | route to course details fullscreen |
| Back callback from CourseView | `handleBackFromCourse()` | return to `/myclass` |

## 14.2 My Class (`ClassTab`)

| Control | Handler | Result |
| --- | --- | --- |
| `View Course` | `onViewCourse?.(course.id)` | opens course details |
| `Materials` | `onViewCourse?.(course.id)` | same as view course |
| `MoreVertical` | none | no action |

## 14.3 Registration (`CourseRegistration`)

| Control | Handler | Result |
| --- | --- | --- |
| Search input | `setSearchQuery` | filters catalog |
| Department dropdown | `setSelectedDepartment` | filters catalog |
| Level dropdown | `setSelectedLevel` | filters catalog |
| Course card click | `setSelectedCourse` | updates details panel |
| Prereq chip | toggle `showPrereqsFor` | opens/closes prereq popup |
| Enroll button | `handleRegister` | opens modal |
| Section row in modal | `setSelectedSectionId` | selects enrollment section |
| Modal cancel | inline close/reset logic | closes modal and clears errors |
| Modal confirm | `confirmRegistration` | enroll API + refetch + toast |
| Drop button | `handleDrop(course.id)` | drop API + refetch + toast |

## 14.4 Course Details (`CourseView`)

| Control | Handler | Result |
| --- | --- | --- |
| Back | `onBack` | returns to My Class |
| Tab buttons | `setActiveTab(tab)` | switches content section |
| Week header | `setExpandedSection(...)` | expand/collapse week |
| Lesson row | `handleOpenLesson` | opens material/bundle + track view |
| Bundle document title | `setSelectedBundleDocumentId` | switches document preview |
| Bundle `Open` | `window.open(downloadUrl)` | opens download/document URL |
| Announcement read toggle | `setExpandedAnnouncementId(...)` | show more/less text |
| Instructor/TA card | `handleOpenStaffProfile` | opens public profile booking page |
| `Generate AI Notes` | none | no action |

## 14.5 Public Profile + Booking (`PublicProfileView`)

| Control | Handler | Result |
| --- | --- | --- |
| Back | `navigate(-1)` | returns to previous screen |
| Social link | anchor open new tab | external profile open |
| Slot row | `setSelectedSlotId(slot.slotId)` | shows booking form and auto date |
| Date input | `setAppointmentDate` | updates payload date |
| Topic input | `setTopic` | updates payload topic |
| Notes textarea | `setNotes` | updates payload notes |
| Reserve appointment | `reserveAppointment` | validate + post booking + reset/refresh |

---

## 15. Appendix: Primary Data Models Referenced

## 15.1 Enrollment Types (simplified)

```ts
interface EnrolledCourse {
  id: string;
  userId: number;
  sectionId: string;
  status: string;
  grade: string | null;
  finalScore: number | null;
  enrollmentDate: string;
  canDrop: boolean;
  dropDeadline: string | null;
  course: {
    id: string;
    name: string;
    code: string;
    description: string;
    credits: number;
    level: string;
  };
  section: {
    id: string;
    sectionNumber: string;
    maxCapacity: number;
    currentEnrollment: number;
    location: string;
  };
  semester: {
    id: string;
    name: string;
    startDate: string;
    endDate: string;
  };
  prerequisites: unknown[];
}

interface AvailableCourse {
  id: string;
  name: string;
  code: string;
  description: string;
  credits: number;
  level: string;
  departmentId: string;
  departmentName: string;
  canEnroll: boolean;
  enrollmentStatus: 'enrolled' | 'not_enrolled' | 'waitlisted';
  prerequisites: unknown[];
  sections: AvailableCourseSection[];
}
```

## 15.2 Course Materials and Structure (simplified)

```ts
interface CourseMaterial {
  materialId: string;
  courseId: string;
  materialType: 'document' | 'video' | 'lecture' | 'slide' | 'reading' | 'link' | 'other';
  title: string;
  description?: string;
  externalUrl?: string | null;
  driveViewUrl?: string | null;
  driveDownloadUrl?: string | null;
  driveFileId?: string | null;
  fileName?: string | null;
  orderIndex?: number;
  weekNumber?: number | null;
  isPublished: number;
  createdAt: string;
}

interface CourseStructure {
  organizationId: string;
  courseId: string;
  materialId: string | null;
  organizationType: 'lecture' | 'lab' | 'section' | 'tutorial';
  title: string;
  weekNumber: number;
  orderIndex: number;
}
```

## 15.3 Announcements (simplified)

```ts
interface Announcement {
  id: string;
  courseId: string | null;
  title: string;
  content: string;
  priority?: 'low' | 'medium' | 'high' | 'urgent' | string;
  isPinned?: number;
  isPublished: number;
  publishedAt?: string;
  createdAt?: string;
  author?: {
    userId?: number;
    firstName?: string;
    lastName?: string;
    email?: string;
  };
  course?: {
    id?: string;
    name?: string;
    code?: string;
  } | null;
}
```

## 15.4 Public Profile and Office Hours (simplified)

```ts
interface PublicUserProfile {
  userId: number;
  email: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  profilePictureUrl?: string | null;
  bio?: string | null;
  socialLinks?: Record<string, string | null> | null;
  roles?: string[];
}

interface OfficeHoursSlot {
  slotId: number;
  instructorId: number;
  dayOfWeek: string;
  startTime: string;
  endTime: string;
  location: string;
  mode: 'in_person' | 'online' | 'hybrid' | string;
  maxAppointments: number;
  currentAppointments?: number;
  meetingUrl?: string | null;
  status?: 'active' | 'inactive' | string;
}

interface CreateOfficeHoursAppointmentPayload {
  slotId: number;
  appointmentDate: string;
  topic: string;
  notes?: string;
}
```

---

## 16. Implementation Notes for Future Hardening

1. Standardize enrollment status values across backend/frontend (`enrolled` vs `registered`, `waitlisted` vs `waitlist`) to prevent count/filter inconsistencies.
2. Add strict model normalization layer for course id/enrollment id ambiguity before routing to `CourseView`.
3. Replace placeholder controls (`Generate AI Notes`, notes/reviews tabs, more menu) with implemented flows or hide behind feature flags.
4. Add optimistic UI and rollback strategy for enroll/drop and booking actions where appropriate.
5. Add explicit backend-level duplicate booking guard response messaging and surface it consistently in profile booking UI.
6. Add pagination or incremental loading for course materials beyond fixed `limit=200`.
7. Align `isPublished` representation (number vs boolean) through service normalization.
8. Move repeated data-transform logic (registration and class tab mapping) into typed selectors/utilities to reduce drift.

---

## 17. Quick Feature Summary

The Student Courses feature is implemented as a URL-driven, container-orchestrated flow where:

1. `StudentDashboard` owns route/tab state and fullscreen transitions.
2. `ClassTab` lists enrolled courses and opens details.
3. `CourseRegistration` manages enroll/drop with filters and section-level confirmation.
4. `CourseView` is the data-dense course details hub for materials/structure/announcements/team.
5. `PublicProfileView` extends the flow into instructor office-hours booking.

All critical user actions in this flow are connected to live API endpoints through the shared authenticated API client layer, with clear placeholders documented where implementation is not yet complete.
