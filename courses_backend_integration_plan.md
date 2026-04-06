# Courses Backend Integration Plan (Flutter App)

This document provides a comprehensive, multi-phase development plan for integrating the **Courses** feature from the backend into the EduVerse Flutter application. It replaces the static mockup data across Student, Instructor, and TA dashboards with live data fetched from the backend. 

The integration will match the data structure used by the web frontend. This plan specifies the exact paths and files to be touched so that the transition from static mockup files to the final responsive version is seamless.

## Relevant External Paths
- **Backend Path:** `D:\Graduation\backend\last_backend\EduVerse_Backend`  
  *Contains the REST APIs and database schema (`eduverse_db.sql`).*
- **Frontend Web Path:** `D:\Graduation\frontend tarek\Eduverse-Frontend`  
  *Reference for API integration (`CourseView.tsx`, `CoursesPage.tsx` from `src/pages/.../components`).*

---

## User Review Required
> [!IMPORTANT]
> Please review the comprehensive file list identified in **Phase 2** through **Phase 5**. Once approved, this plan will serve as the master reference for the `spec-kit` workflow. 

---

## Phase 1: API Client, Domain Models & Global Config
**Goal:** Map the backend database schemas and REST APIs to unified Dart models, and create the necessary service/repository classes tailored for the Flutter app.

### Proposed Changes
#### [NEW] `lib/models/course_model.dart`
#### [NEW] `lib/models/enrollment_model.dart`
#### [NEW] `lib/models/course_material_model.dart`
#### [NEW] `lib/models/course_structure_model.dart`
#### [NEW] `lib/services/api/course_service.dart`
#### [NEW] `lib/services/api/enrollment_service.dart`
#### [NEW] `lib/services/api/material_service.dart`
#### [NEW] `lib/bloc/courses/courses_bloc.dart`
#### [NEW] `lib/bloc/courses/courses_state.dart`
#### [NEW] `lib/bloc/courses/courses_event.dart`

- **Tasks:**
  - Create global, reusable models representing the backend tables (`courses`, `enrollments`, `course_materials`).
  - Create the API services matching the payload structure shown in the React Web frontend context (`enrollmentService.getMyCourses()`).
  - Set up a globally accessible BLoC or specific BLoCs mapped to the user roles.

---

## Phase 2: Student Screens & Widgets Integration
**Goal:** Replace static initialization in the Student Dashboard and Courses screens with BLoC states consuming live data.

### Proposed Changes
#### [DELETE] `lib/widgets/student/courses/course_model.dart`
#### [MODIFY] `lib/screens/student/courses_screen.dart`
#### [MODIFY] `lib/screens/student/course_details_screen.dart`
#### [MODIFY] `lib/widgets/student/courses/courses_list_view.dart`
#### [MODIFY] `lib/widgets/student/courses/course_filter_bar.dart`
#### [MODIFY] `lib/widgets/student/courses/course_search_bar.dart`
#### [MODIFY] `lib/widgets/student/courses/filter_button.dart`
#### [MODIFY] `lib/widgets/student/courses/sort_button.dart`

- **Tasks:**
  - Remove the hardcoded `_initializeCourses()` array from `courses_screen.dart`.
  - Integrate `BlocBuilder` to handle states (`loading`, `loaded`, `error`).
  - Pipe the newly created universal `CourseModel` to all student course widgets.
  - Make dynamic filters and sorting based on real backend data calculations (e.g., progress based on total materials).

---

## Phase 3: Instructor Screens & Widgets Integration
**Goal:** Transition the Instructor interface to dynamic properties and actual stats aggregation.

### Proposed Changes
#### [DELETE] `lib/models/instructor/instructor_course_model.dart`
#### [DELETE] `lib/models/instructor/extended_course_model.dart`
#### [MODIFY] `lib/screens/instructor/courses/instructor_courses_screen.dart`
#### [MODIFY] `lib/widgets/instructor/courses/courses_barrel.dart`

- **Tasks:**
  - Delete `instructor_course_model.dart` and `extended_course_model.dart` as they hold hardcoded data models. Use the universal models from Phase 1.
  - Remove `_getDemoCourses()` list initialization.
  - Dynamically calculate the Top Stats Board (`totalStudents`, `avgEngagement`).
  - Render lists using the Live API stream.

---

## Phase 4: TA (Teaching Assistant) Screens & Widgets Integration
**Goal:** Update the TA role screens so that they view live courses relevant to the specific sections they are assisting.

### Proposed Changes
#### [MODIFY] `lib/screens/ta/courses/ta_courses_list_screen.dart`
#### [MODIFY] `lib/screens/ta/courses/ta_course_detail_screen.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_course_discussions_tab.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_course_grading_tab.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_course_insights_card.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_course_labs_tab.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_course_overview_tab.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_course_quick_actions.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_course_stats_cards.dart`
#### [MODIFY] `lib/widgets/ta/courses/ta_courses_barrel.dart`

- **Tasks:**
  - Connect the `TA Courses List` to the backend equivalent of "assigned courses for TA".
  - Refactor all sub-tabs (`overview`, `grading`, `labs`, `discussions`) to read from the BLoC model instance rather than local dummy data.
  - Update quick action handlers to point to the correct backend route abstractions.

---

## Phase 5: Course Detail Drill-down & Material Viewer
**Goal:** Verify access to actual structural endpoints (week-by-week) across all roles.

### Proposed Changes
#### [MODIFY] Existing detail view screens across all 3 roles (e.g., Student `course_details_screen.dart`, Instructor management screens, TA `ta_course_detail_screen.dart`).

- **Tasks:**
  - Build out the drill-down views using the newly created `StructureService`.
  - Differentiate between Videos, Documents, and Quizzes matching the backend's `organizationType`.
  - Connect external URLs or utilize Flutter's `url_launcher` to download materials (`fileId`).

---

## Verification Plan

### Automated Tests
- N/A at this stage (API responses will be checked via debug logs).

### Manual Verification
- Log in as a Student, evaluate empty state and accurate enrolled courses mirroring the Web version.
- Log in as an Instructor, ensure course tracking numbers match the backend correctly.
- Log in as a TA, verify the list of assigned courses accurately mimics backend access control.
