# Flutter Announcement Fix Plan

Date: 2026-04-24  
Scope: `Flutter project only`  
Project: `D:\Graduation\EduVerse\edu_verse`

## 1. Purpose

This document is the implementation plan for fixing the announcement feature **only inside the Flutter project**.

This plan intentionally ignores any issue that would require editing:

- backend code
- website frontend code

The job of the implementer is to make the Flutter app:

- match the current usable behavior of the website where appropriate
- stop exposing fake or misleading functionality
- fit the existing modern Flutter student UI style
- rely only on real backend endpoints that already exist

This is a phased execution plan so another Codex can implement it step by step without needing to redesign the work from scratch.

## 2. Hard Constraints

These constraints are mandatory.

### 2.1 Repository boundaries

- Do not edit anything under:
  - `D:\Graduation\backend\last_backend\EduVerse_Backend`
  - `D:\Graduation\frontend_tarek\Eduverse-Frontend`
- All changes must stay inside:
  - `D:\Graduation\EduVerse\edu_verse`

### 2.2 Backend truth must be respected

The Flutter app must adapt to the backend as it exists today.

This means:

- do not fake backend features that are not truly working end-to-end
- do not keep UI actions that appear functional but are actually misleading
- do not introduce temporary local-only behavior for features that are supposed to be server-backed

### 2.3 Student new announcement screen requirements

The new student announcements screen must follow:

- `flow and logic`: from the website student announcements page
- `visual style`: from the modern/colorful Flutter student screens

This means:

- data flow, search/filter behavior, and overall screen purpose should follow the website
- colors, layout rhythm, headers, stat blocks, card styling, empty/loading states, and motion should follow the modern Flutter student UI language

### 2.4 Real data only

All displayed stats and counts on the new student announcements screen must be based on real backend data from existing endpoints.

Allowed approach:

- derive stats from `GET /announcements` response data already returned by the backend

Not allowed:

- hardcoded counts
- fake analytics
- mock read rate
- fake channel delivery counts

## 3. Source References Inside Flutter

These are the main Flutter files that the implementation will likely touch.

### Existing student entry points

- [student_dashboard_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/student_dashboard_screen.dart:16)
- [student_drawer.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/dashboard/student_drawer.dart:284)
- [app_router.dart](/D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:229)

### Existing student announcement surfaces

- [course_tabs.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/course_tabs.dart:34)
- [announcements_tab_content.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:24)
- [course_detail_bloc.dart](/D:/Graduation/EduVerse/edu_verse/lib/features/courses/bloc/course_detail/course_detail_bloc.dart:691)
- [course_detail_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/features/courses/screens/course_detail_screen.dart:334)

### Existing shared announcement API/model layer

- [communication_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:17)
- [announcement_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/materials/announcement_model.dart:70)
- [instructor announcement model](/D:/Graduation/EduVerse/edu_verse/lib/models/instructor/announcement_model.dart:48)

### Existing management screens

- [AnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:301)
- [TAAnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/ta/announcements/ta_announcement_manager_screen.dart:318)
- [AdminAnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/admin/announcements/admin_announcement_manager_screen.dart:301)
- [announcement_form_dialog.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:401)
- [announcement_card.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_card.dart:114)

### Existing wrong admin duplicate system

- [admin_notification_cubit.dart](/D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:32)
- [admin_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/admin/notifications/admin_notifications_screen.dart:588)

## 4. Target End State

When all phases are complete, Flutter should behave like this.

### Student

- Student drawer contains a new `Announcements` destination.
- Student can open a dedicated announcement inbox screen.
- The screen follows website flow:
  - fetch all accessible announcements
  - client-side search
  - client-side course filtering from loaded announcements
  - read-only consumption
  - no item detail route required
- The screen follows modern Flutter styling:
  - colorful header
  - live stat cards
  - modern filter/search row
  - polished announcement cards
  - strong empty/loading/error states
- Student course-level announcements become closer to website behavior.

### Instructor

- Instructor announcement manager uses only real, backend-supported behavior.
- Fake analytics are removed and replaced with real minimal analytics.
- Misleading unsupported UI is hidden or downgraded.

### TA

- TA manager stops exposing actions that are misleading in Flutter.
- TA screen aligns better with current backend truth.

### Admin

- Only one admin announcement system remains active in Flutter.
- Admin uses the API-backed manager only.
- Local-only announcement creation inside admin notifications is removed or replaced.
- Admin target-audience values become backend-compatible.

## 5. Out Of Scope

The implementer must explicitly avoid these items.

### 5.1 Backend fixes

Do not try to solve in Flutter:

- real pin persistence
- real `scheduledAt` backend support
- `findOne()` authorization problems
- inflated backend view count logic
- backend target-audience enforcement
- backend attachment upload support
- backend notification channel delivery logic

### 5.2 Website code parity by editing website

Do not edit website code to “match Flutter”.

Instead:

- treat the website as the logic reference for the student global page
- treat Flutter as the only codebase being changed

### 5.3 Fake fallback systems

Do not add:

- local-only announcement persistence
- local simulated pinning
- local simulated scheduling
- fake analytics charts
- fake delivery or read-rate metrics

## 6. Implementation Strategy

The work should be done in this order:

1. Stabilize the shared Flutter announcement data layer.
2. Add the new student global announcements screen and drawer entry.
3. Upgrade student course-level announcement UX for closer website parity.
4. Clean instructor and TA managers so they stop lying about unsupported features.
5. Consolidate admin onto the API-backed announcement path only.
6. Finish polish, localization, testing, and regression checks.

This order matters because:

- the student screen depends on clean list parsing and filtering behavior
- role managers should be corrected after the shared announcement rules are clarified
- admin cleanup should happen only after the shared announcement UI rules are finalized

## 7. Phase 0: Preparation And Guardrails

### Goal

Create a safe implementation baseline before changing behavior.

### Files likely touched

- [ANNOUNCEMENT_FEATURE_AUDIT_REPORT.md](/D:/Graduation/EduVerse/edu_verse/ANNOUNCEMENT_FEATURE_AUDIT_REPORT.md)
- new phase execution notes file if needed

### Tasks

1. Re-read the audit report and mark every finding as one of:
   - implement in Flutter now
   - hide/remove in Flutter because backend cannot support it
   - keep visible but read-only
2. Record one implementation rule for each risky backend limitation:
   - pin mutation: no interactive UI
   - schedule mutation: do not present as fully supported scheduling
   - attachments: do not present as upload-ready
   - channels: do not present as sent to email/SMS/push per-channel
   - analytics: only show backend-returned fields
3. Decide exact naming for new student announcement files before coding.
4. Decide whether student announcement screen state will use:
   - a dedicated Cubit
   - or a screen-local state object

### Recommended decision

Use a dedicated Cubit for the new student global announcement screen because it needs:

- initial fetch
- refresh
- client-side filters
- derived stats
- search query
- selected course chip
- loading/error/empty states

### Deliverables

- clear implementation notes
- confirmed file naming
- confirmed state management approach

### Acceptance criteria

- No implementation work starts before unsupported features are explicitly classified.
- The implementer knows exactly which UI must be removed versus improved.

## 8. Phase 1: Stabilize Shared Announcement Data Layer

### Goal

Make announcement parsing and derived display logic reliable across Flutter before building the new student screen.

### Why this phase comes first

The new student screen, student course tab, and management screens all depend on:

- consistent list parsing
- correct sorting strategy decisions
- safe field interpretation
- elimination of fake state assumptions

### Files to update

- [communication_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:17)
- [announcement_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/materials/announcement_model.dart:70)
- [instructor announcement model](/D:/Graduation/EduVerse/edu_verse/lib/models/instructor/announcement_model.dart:48)

### Tasks

#### 8.1 Normalize list-response handling

Make sure all shared list consumers can safely read:

- direct list payload
- paginated `{ data, meta }` payload

Even though `communication_service.dart` already handles both in `getAnnouncements()` and `getAnnouncementsByCourseId()`, this phase should confirm:

- no other announcement path bypasses this normalization
- new student screen uses the same normalized source

#### 8.2 Clarify field semantics in Flutter models

Document and enforce how Flutter should treat these fields:

- `isPinned`
- `priority`
- `publishedAt`
- `createdAt`
- `expiresAt`
- `targetAudience`
- `viewCount`

Important rule:

- `expiresAt` must **not** be treated as trustworthy scheduling data
- student UI must not present `expiresAt` as an “expires” field if that would be misleading with current backend behavior

#### 8.3 Fix instructor/TA/admin model status mapping

Current issue:

- [instructor announcement model](/D:/Graduation/EduVerse/edu_verse/lib/models/instructor/announcement_model.dart:53) maps anything not published to `draft`

Planned adjustment:

- do not invent a scheduled state unless the app can truly identify it from reliable backend data
- choose one of these approaches:
  - preferred: remove scheduled classification from API-derived announcement mapping
  - fallback: keep scheduled only for local unsaved draft state inside the form, never for server-returned items

#### 8.4 Establish Flutter-only display rules for unsupported backend fields

Create a small shared rule set for UI behavior:

- `isPinned`:
  - allowed for passive display only if data exists
  - not allowed as an editable action
- `attachmentFileId`:
  - do not expose file upload UI unless a real upload flow exists
- `targetAudience`:
  - admin can submit only valid backend enum values
- analytics:
  - only show raw backend metrics that truly exist

### Recommended implementation artifacts

Consider adding:

- a small shared helper for announcement sorting
- a small shared helper for safe display mapping
- a small shared helper for deriving list stats

Suggested new files:

- `lib/features/announcements/utils/announcement_sorting.dart`
- `lib/features/announcements/utils/announcement_display_mapper.dart`
- `lib/features/announcements/utils/announcement_stats_mapper.dart`

If the repository already has a better conventions folder, adapt the paths but keep the responsibilities.

### Acceptance criteria

- All announcement list consumers use one normalized data source path.
- No UI depends on fake `scheduled` server state.
- There is a single, explicit Flutter rule for unsupported fields.

## 9. Phase 2: Build The New Student Drawer Announcements Screen

### Goal

Add the missing student global announcements experience in Flutter.

### Core requirement

This phase must follow:

- website page logic
- Flutter student UI design language

### Files to update

- [student_drawer.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/dashboard/student_drawer.dart:284)
- [app_router.dart](/D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:229)

### Files to add

Recommended new files:

- `lib/screens/student/announcements/student_announcements_screen.dart`
- `lib/bloc/student_announcements/student_announcements_cubit.dart`
- `lib/bloc/student_announcements/student_announcements_state.dart`
- `lib/widgets/student/announcements/student_announcements_header.dart`
- `lib/widgets/student/announcements/student_announcements_stats_row.dart`
- `lib/widgets/student/announcements/student_announcements_search_bar.dart`
- `lib/widgets/student/announcements/student_announcements_filter_chips.dart`
- `lib/widgets/student/announcements/student_announcement_card.dart`
- `lib/widgets/student/announcements/student_announcements_empty_state.dart`
- `lib/widgets/student/announcements/student_announcements_loading_view.dart`

These file names are recommended, not mandatory, but the separation of concerns should stay close to this structure.

### Functional logic to match from website

The Flutter screen should replicate these website behaviors:

1. Load all visible student announcements from `GET /announcements`.
2. Keep the fetched list in memory.
3. Build course filter chips from the loaded announcement list, not from a separate course endpoint.
4. Provide a search field that filters client-side.
5. Provide an `All Courses` chip plus dynamic course chips.
6. Keep the screen read-only for students.
7. Show full content directly in each card.
8. Do not require a details page to view announcement content.

### UX and visual direction

The screen must not look like a plain copy of the website.

It should use Flutter student UI patterns similar in quality to:

- [student dashboard](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/student_dashboard_screen.dart:25)
- [notifications screen](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/notifications/notifications_screen.dart:62)
- [grades screen](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/grades_screen.dart:179)

### Detailed implementation tasks

#### 9.1 Add the route

Add a new route in [app_router.dart](/D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:229).

Recommended route:

- `/student/announcements`

Do not overload existing notification or course routes.

#### 9.2 Add the drawer destination

Update [student_drawer.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/dashboard/student_drawer.dart:284) to include:

- a new `Announcements` menu item
- category `communication`
- placement near other communication tools

Recommended placement:

- after `Messages`
- before account items

Recommended icon:

- `Icons.campaign_outlined` or a closely related campaign/megaphone icon consistent with current student icon style

#### 9.3 Create student announcement state layer

The Cubit/state should contain:

- `allAnnouncements`
- `filteredAnnouncements`
- `status`:
  - initial
  - loading
  - success
  - error
- `searchQuery`
- `selectedCourseFilter`
- `courseFilterOptions`
- derived stats model
- optional `errorMessage`

#### 9.4 Fetch strategy

Use [communication_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:17) and call:

- `getAnnouncements()`

Rules:

- fetch on screen open
- allow pull-to-refresh
- do not call `getAnnouncementById()` for list rendering
- do not call analytics per item for stats

Reason:

- `GET /announcements/:id` increments view count
- `GET /announcements/:id/analytics` is too limited and should not be spammed per card

#### 9.5 Derived live stats for the header

The student screen needs a modern colorful header with live stats derived from real backend response data.

Recommended stat cards:

- `Total`
  - count of all loaded visible announcements
- `Urgent`
  - count where `priority == urgent`
- `Courses`
  - count of unique non-null course IDs represented in the loaded list
- `This Week`
  - count where `publishedAt ?? createdAt` falls within the last 7 days

Alternative stat options if the above fit poorly with the UI:

- `High Priority`
- `General`
- `Recently Published`

Rules:

- no mocked numbers
- no fake read rate
- no fake audience reach
- no hardcoded percentages

#### 9.6 Header layout

The screen header should include:

- back navigation or contextual close behavior if needed
- colorful gradient hero/header area
- page title
- subtitle aligned with website intent
- live stat cards

Recommended content:

- title: `Announcements`
- subtitle concept: “Latest updates and important notices from your instructors”

Do not copy the website visual style literally. Translate the purpose into Flutter’s modern style.

#### 9.7 Search and filter section

Implement:

- search bar with icon and clear action
- horizontally scrollable chip row
- first chip = `All Courses`
- remaining chips from loaded announcements only

Filtering rules:

- search should match at least:
  - title
  - content
  - course code if present
  - course name if present
  - author name if present
- course filter should compare against:
  - `courseId`
  - fallback course object id if needed

#### 9.8 Sorting strategy

Because the website global page does not apply extra explicit client sorting after fetch, the Flutter global screen should not invent a different ranking model unless necessary.

Recommended rule:

- preserve backend order by default
- if a defensive client sort is needed for consistency, use:
  - `publishedAt ?? createdAt` descending

Do not add local fake pinned-first behavior on this screen because pin persistence is not reliable from the backend.

#### 9.9 Card design

Each card should include:

- optional passive pin badge if API provides it
- course badge
- priority badge
- title
- author name
- published date
- published time
- view count
- full content body

Modern Flutter styling recommendations:

- elevated cards with soft gradients or tinted surfaces
- distinct priority accents
- strong spacing and hierarchy
- readable metadata chips
- good dark-mode and light-mode support

#### 9.10 Empty states

Implement two separate empty states:

- no data after fetch
- no results after filters/search

Website logic to preserve:

- filtered empty state message should indicate current filters/search returned no matches
- no-data empty state should indicate there are no announcements for the student at the moment

#### 9.11 Error state

Implement a dedicated error panel with:

- retry action
- calm message
- no crash or raw exception dump

#### 9.12 Localization pass

All new strings must be added to localization resources if the surrounding student UI expects localized text.

Do not leave the feature half localized if neighboring screens are localized.

### Acceptance criteria

- Student drawer shows a working `Announcements` destination.
- Student can open a dedicated global announcements screen.
- The screen uses real backend list data only.
- Search and course chips work client-side.
- Stats are live and derived from the announcement payload.
- Cards show website-equivalent data in a more modern Flutter design.
- No mock analytics or fake counts appear on the screen.

## 10. Phase 3: Upgrade Student Course-Level Announcements

### Goal

Bring the existing student course announcements experience closer to the website while staying compatible with current backend truth.

### Files to update

- [announcements_tab_content.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:24)
- [course_detail_bloc.dart](/D:/Graduation/EduVerse/edu_verse/lib/features/courses/bloc/course_detail/course_detail_bloc.dart:691)
- [course_detail_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/features/courses/screens/course_detail_screen.dart:334)

### Tasks

#### 10.1 Improve course-tab sorting

Website course tab behavior:

- pinned first
- newest next

Flutter currently sorts by date only.

Planned Flutter approach:

- sort by `isPinned` first if data exists
- then `publishedAt ?? createdAt` descending

Important note:

- this is passive sorting only
- do not add any student pin action

#### 10.2 Add richer metadata to course-tab cards

Enhance student course cards to include:

- optional pin indicator
- author name
- view count
- publish date and time
- course label only if useful in shared card reuse

#### 10.3 Add content expansion behavior

Website course tab supports:

- `Read more`
- `Show less`

Flutter should add equivalent behavior for long content in the course tab only.

Recommended rule:

- default to a max visible line count
- expand inline without navigating away

#### 10.4 Improve priority treatment

Current issue:

- `urgent` is not treated distinctly

Planned fix:

- add explicit urgent color and label handling
- keep `high`, `medium`, `low` visually distinct

#### 10.5 Remove misleading expiry wording

Current issue:

- [announcements_tab_content.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:175) shows `Expires ...`
- backend currently reuses `expiresAt` for scheduling workaround in some flows

Recommended Flutter-only fix:

- remove the `Expires` display from the student course announcement card
- or hide it unless the team has a reliable way to know the field truly means expiration

Preferred option:

- remove the student-facing expiry label completely for now

#### 10.6 Revisit the `Latest Announcements` preview block

Current preview:

- shows only first 3 announcements inside course details

Plan:

- keep the preview if it still adds value
- make the card snippet consistent with the improved course-tab display
- ensure preview uses the same sorted announcement source as the tab

### Acceptance criteria

- Student course announcements feel like a polished, modern, expanded version of the current Flutter implementation.
- Sorting is improved.
- Cards are more informative.
- `Read more / Show less` exists.
- `Expires` no longer misleads students.

## 11. Phase 4: Clean Instructor Announcement Manager

### Goal

Remove fake or misleading behavior from the instructor announcement experience while keeping useful real backend-backed functionality.

### Files to update

- [AnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:301)
- [announcement_form_dialog.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:401)
- [announcement_card.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_card.dart:114)

### Tasks

#### 11.1 Replace fake analytics with real minimal analytics

Current issue:

- analytics are mocked/generated

Planned fix:

- call `getAnnouncementAnalytics(id)`
- display only fields the backend actually returns:
  - title
  - viewCount
  - isPublished
  - publishedAt
  - createdAt

Recommended UI:

- simple bottom sheet or dialog
- summary metrics only
- no fabricated charts
- no fabricated insight text

#### 11.2 Remove interactive pin mutation

Current issue:

- backend pin endpoint is a no-op
- current UI makes pinning look functional

Planned fix:

- remove instructor pin/unpin action buttons
- if `isPinned` is already present in returned data, allow a passive badge only

Preferred approach:

- no pin action
- optional passive pin badge

#### 11.3 Remove or defer scheduling UI

Current issue:

- current scheduling flow depends on backend workaround behavior that is not reliable

Planned Flutter-only fix:

- remove the schedule option from the form and manager filters
- keep only:
  - draft
  - published

If the team insists on keeping schedule visible, it must be marked as unsupported or beta, but the preferred plan is to remove it for now.

#### 11.4 Remove fake attachment workflow

Current issue:

- UI lets users add fake filenames
- no real upload path exists

Planned fix:

- remove attachments section from the shared announcement form for now

#### 11.5 Keep creation/editing aligned to actual backend-supported fields

Instructor create/update should be limited to practical supported fields:

- title
- content
- courseId
- priority
- publish now

Do not keep UI fields that imply end-to-end support if they are not real.

### Acceptance criteria

- Instructor screen no longer presents fake analytics, fake scheduling, fake attachments, or fake pinning.
- Instructor create/edit flow remains stable and backend-backed.

## 12. Phase 5: Clean TA Announcement Manager

### Goal

Make TA announcement behavior honest and aligned with current Flutter-only constraints.

### Files to update

- [TAAnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/ta/announcements/ta_announcement_manager_screen.dart:318)
- shared announcement form/card files if reused

### Tasks

#### 12.1 Remove pin action

Reasons:

- TA pin is misleading in Flutter
- backend pin is no-op
- TA permission behavior is inconsistent across docs and implementation

Planned fix:

- remove TA pin action completely from Flutter

#### 12.2 Replace fake analytics with real minimal analytics

Same plan as instructor:

- use real endpoint
- show raw backend metrics only

#### 12.3 Remove schedule UI

Same reason as instructor:

- current backend behavior is not reliable enough for truthful scheduling UX

#### 12.4 Keep TA scope limited

TA manager should focus on:

- create draft
- edit own/visible announcements per current backend behavior
- publish where backend allows it
- delete where backend allows it

Flutter should not try to “fix” TA permission ambiguity by guessing extra client restrictions that may contradict real server behavior unless the server is clearly rejecting the action.

Recommended rule:

- if backend accepts the action, the UI can offer it
- if backend behavior is misleading or non-functional, remove it

Applied to TA:

- keep create
- keep edit
- keep publish
- keep delete
- remove pin
- remove fake schedule
- remove fake attachment flow
- remove fake analytics visuals

### Acceptance criteria

- TA announcement manager exposes only backend-realistic actions.
- No pin action remains.
- No fake analytics or fake scheduling remain.

## 13. Phase 6: Consolidate Admin Announcement Implementation

### Goal

Unify admin announcements around the API-backed system and remove the wrong local-only branch.

### Files to update

- [AdminAnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/admin/announcements/admin_announcement_manager_screen.dart:301)
- [admin_notification_cubit.dart](/D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:32)
- [admin_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/admin/notifications/admin_notifications_screen.dart:588)
- [announcement_form_dialog.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:1046)

### Tasks

#### 13.1 Remove the local-only admin announcement path

Current issue:

- admin notifications area creates local-only announcements

Planned fix:

Choose one of these implementation approaches:

##### Preferred

- remove announcement creation/management from the local admin notifications screen entirely
- keep that screen focused on notifications only
- route admin announcement management to the existing API-backed `/admin/announcements` flow

##### Acceptable fallback

- keep a shortcut button in admin notifications screen
- but make it navigate to the API-backed admin announcement manager instead of creating local-only data

Do not keep any local-only admin announcement creation.

#### 13.2 Align admin target-audience values with the backend enum

Current invalid value:

- `admins`

Backend-compatible values:

- `all`
- `students`
- `instructors`
- `tas`
- `custom`

Planned fix:

- replace `admins` with valid backend enum options
- do not send invalid values anymore

#### 13.3 Decide how to handle `custom`

Because backend supports the enum but no custom target-building flow is visible, use this approach:

##### Preferred

- expose:
  - `all`
  - `students`
  - `instructors`
  - `tas`
- do not expose `custom` yet
- add a developer comment or note explaining why it is intentionally omitted

Reason:

- avoid exposing a choice the UI cannot configure meaningfully

#### 13.4 Remove fake channels and attachments from admin form

Current issue:

- channels UI implies send-medium behavior the backend does not support
- attachments UI implies upload support that does not exist

Planned fix:

- remove notification channel picker from admin announcement form
- remove attachments UI from shared form

#### 13.5 Remove pin and fake scheduling from admin manager

Same treatment as instructor/TA:

- no interactive pin action
- no misleading schedule UI

#### 13.6 Replace fake analytics with real minimal analytics

Same treatment as instructor/TA:

- use real analytics endpoint
- show summary values only

### Acceptance criteria

- Admin has only one real announcement system in Flutter.
- No local-only admin announcements remain.
- Admin can submit only valid backend-compatible target audience values.
- Admin no longer sees fake channel, fake pin, fake attachment, or fake schedule flows.

## 14. Phase 7: Shared Form And Shared Card Refactor

### Goal

Clean the shared announcement UI components so they reflect current backend truth and support role differences without lying.

### Files to update

- [announcement_form_dialog.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:401)
- [announcement_card.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_card.dart:114)

### Tasks

#### 14.1 Split supported vs unsupported form sections

The current dialog mixes:

- real fields
- fake fields
- role-specific fields

Refactor it so the form is built from clearly separated sections:

- always-supported section
  - title
  - content
  - course
  - priority
  - publish now
- admin-only supported section
  - valid target audience values only
- removed sections
  - attachments
  - channels
  - unreliable scheduling

#### 14.2 Fix role-specific copy

Current shared subtitle says:

- `Share important updates with your students`

This is acceptable for instructor and TA but weak for admin.

Planned fix:

- allow role-specific subtitle copy
- or replace with neutral wording suitable for all announcement creators

Suggested neutral wording:

- `Create and share important academic updates`

#### 14.3 Simplify announcement cards

Card action rows should only include truthful actions.

Examples:

- if pin action removed, remove it from card overflow menus
- if schedule removed, do not show scheduled badge for server-returned items
- if attachments removed, do not show fake attachment count chips

#### 14.4 Keep passive display fields where safe

Allowed passive display:

- view count
- author name
- course name
- priority
- publication state
- passive pin badge if returned by the server

### Acceptance criteria

- Shared form no longer includes misleading sections.
- Shared cards no longer advertise unsupported features.
- Role copy is cleaner and less misleading.

## 15. Phase 8: Localization, Accessibility, And UI Polish

### Goal

Bring the new and updated announcement UX to production-ready quality.

### Files likely touched

- localization resource files
- new student announcement widgets
- updated shared announcement widgets

### Tasks

#### 15.1 Localization

Add localized strings for:

- student announcements title
- subtitles
- stats labels
- search placeholder
- filter labels
- empty/error states
- analytics labels
- role-adjusted form copy

#### 15.2 Accessibility

Ensure:

- tap targets are comfortable
- search clear and filter chips are keyboard/screen-reader friendly where applicable
- color contrast remains readable in dark and light themes
- status and priority are not conveyed by color alone

#### 15.3 Visual polish for student screen

Review:

- header spacing
- stat card hierarchy
- chip wrapping/scrolling
- long content readability
- card padding
- dark mode colors
- refresh behavior
- shimmer or skeleton loading states if used

#### 15.4 Motion polish

Use subtle motion only:

- screen entrance fade/slide if consistent with surrounding student UI
- chip state transitions
- card hover/press feedback where applicable

Do not over-animate.

### Acceptance criteria

- New student announcement screen feels native to the existing Flutter app.
- Updated announcement flows are localized and accessible.

## 16. Phase 9: Testing And Verification

### Goal

Validate correctness and prevent regressions.

### Test types

#### 16.1 Unit tests

Recommended targets:

- announcement response normalization
- student announcement filtering logic
- student announcement stats derivation
- sorting helper behavior
- target audience value mapping

#### 16.2 Widget tests

Recommended targets:

- student announcements screen loading state
- student announcements screen empty state
- student announcements screen filtered-empty state
- student announcement card rendering
- course filter chip interaction
- search interaction

#### 16.3 Manual verification

Must manually verify:

- new drawer item opens the correct screen
- pull-to-refresh works
- search filters title/content correctly
- course chips filter correctly
- stats update correctly after refresh
- student course tab now shows richer announcement cards
- instructor analytics shows real backend values
- TA no longer has pin action
- admin local-only announcements are gone or rerouted
- admin target audience submits only valid values

### Important manual checks related to backend limitations

The implementer must explicitly verify these Flutter behaviors:

- no screen fabricates analytics values
- no screen offers attachments upload if upload is not real
- no screen offers pin action if it does not truly persist
- no student screen shows misleading `Expires` text
- no admin screen can create local-only announcements anymore

## 17. Phase-by-Phase Deliverables

### Phase 1 deliverables

- stable shared announcement data interpretation
- shared helpers for sorting/stat derivation if added

### Phase 2 deliverables

- new student announcements route
- new drawer menu item
- new student announcements screen
- live stat header
- search and course filter behavior

### Phase 3 deliverables

- upgraded student course announcement cards
- improved sorting
- read more / show less

### Phase 4 deliverables

- truthful instructor announcement manager

### Phase 5 deliverables

- truthful TA announcement manager

### Phase 6 deliverables

- single admin announcement system
- valid target audience submission

### Phase 7 deliverables

- cleaned shared form and shared cards

### Phase 8 deliverables

- localization and polish pass

### Phase 9 deliverables

- unit/widget/manual verification complete

## 18. Suggested File-Level Task Map

This section is meant to make handoff easier.

### Student navigation and routing

- [app_router.dart](/D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:229)
  - add `/student/announcements`
- [student_drawer.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/dashboard/student_drawer.dart:284)
  - add communication menu item

### Student global announcements feature

- new `student_announcements_screen.dart`
  - page shell
  - refresh
  - sliver/body structure
- new student announcement Cubit/state
  - fetch
  - filter
  - search
  - stats derivation
- new student announcement widgets
  - header
  - stats row
  - chip row
  - card
  - empty/loading/error

### Student course-level parity

- [announcements_tab_content.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:24)
  - richer card
  - expansion
  - better priority handling
  - remove misleading `Expires`
- [course_detail_bloc.dart](/D:/Graduation/EduVerse/edu_verse/lib/features/courses/bloc/course_detail/course_detail_bloc.dart:691)
  - improved sorting

### Shared announcement layer

- [communication_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:17)
  - confirm normalized list handling is reused
- [announcement_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/materials/announcement_model.dart:70)
  - review field semantics
- [instructor announcement model](/D:/Graduation/EduVerse/edu_verse/lib/models/instructor/announcement_model.dart:48)
  - remove misleading scheduled-from-API mapping

### Instructor/TA/Admin managers

- [AnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:301)
  - real analytics
  - remove fake actions
- [TAAnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/ta/announcements/ta_announcement_manager_screen.dart:318)
  - remove fake actions
- [AdminAnnouncementManagerScreen](/D:/Graduation/EduVerse/edu_verse/lib/screens/admin/announcements/admin_announcement_manager_screen.dart:301)
  - valid audience values
  - real analytics
  - no fake actions

### Admin duplicate cleanup

- [admin_notification_cubit.dart](/D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:32)
  - remove local-only announcement assumptions
- [admin_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/admin/notifications/admin_notifications_screen.dart:588)
  - remove/reroute FAB announcement flow

### Shared dialog/card cleanup

- [announcement_form_dialog.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:401)
  - remove attachments/channels/schedule if unsupported
  - clean role copy
- [announcement_card.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_card.dart:114)
  - remove fake badges/actions

## 19. Decision Table For Unsupported Features

This table is important for implementation consistency.

| Feature | Backend reality today | Flutter action plan |
| --- | --- | --- |
| Pin mutation | endpoint exists but effectively no-op | remove action buttons, keep passive badge only if data exists |
| Scheduling | not trustworthy enough for polished UX | remove scheduling UI from role managers for now |
| Attachments upload | no real upload flow | remove attachment UI |
| Notification channels | no real per-channel send behavior | remove channels UI |
| Analytics | minimal real endpoint exists | show simple real analytics, no fake charts |
| Target audience | field exists, enum limited | submit only valid backend enum values |
| Student stats | no dedicated endpoint | derive from real list response only |

## 20. Recommended Implementation Order For Another Codex

If another Codex implements this plan, the recommended order is:

1. Phase 1 shared data stabilization
2. Phase 2 student global page
3. Phase 3 student course parity
4. Phase 7 shared form/card cleanup
5. Phase 4 instructor cleanup
6. Phase 5 TA cleanup
7. Phase 6 admin consolidation
8. Phase 8 polish
9. Phase 9 testing

Reason:

- the student feature is the highest-value addition
- shared cleanup should happen before role managers are finalized
- admin consolidation should happen after shared cleanup decisions are set

## 21. Final Notes For The Implementer

### 21.1 Student screen philosophy

Do not build a plain list page.

The new student announcements screen should feel like a first-class modern student dashboard surface:

- strong header
- live stats
- polished search/filter flow
- attractive but readable announcement cards
- clear states for loading, empty, filtered-empty, and error

### 21.2 Do not over-copy the website visually

Use the website as the logic reference, not as the design reference.

The Flutter screen should visually belong to the Flutter app.

### 21.3 Prefer honest UX over feature count

If a feature is not truly supported by the current backend, the Flutter fix should:

- remove it
- simplify it
- or downgrade it to passive display

but never pretend it works fully.

### 21.4 Definition of done

The work is done when:

- Flutter student announcements have a complete new drawer-driven global screen
- student course announcements are improved
- role managers no longer expose fake functionality
- admin no longer has a duplicate local-only announcement system
- all of this happens without touching backend or website code

