# Flutter Notifications Parity Fix Plan

Date: 2026-04-25  
Scope: `Flutter project only`  
Project: `D:\Graduation\EduVerse\edu_verse`

## 1. Purpose

This document is the **Flutter-only phased implementation plan** for fixing the notifications feature so the Flutter project matches the usable behavior, logic, data contract, and role coverage already present in the backend and website.

This plan is intentionally limited to:

- Student notifications
- Instructor notifications
- TA notifications
- shared notification infrastructure inside Flutter

This plan does **not** execute any code changes. It is a detailed handoff document so another Codex can implement the work phase by phase without redesigning the solution from scratch.

Primary source report:

- [NOTIFICATIONS_WEBSITE_BACKEND_VS_FLUTTER_GAP_REPORT.md](/D:/Graduation/EduVerse/edu_verse/difference_documentation/NOTIFICATIONS_WEBSITE_BACKEND_VS_FLUTTER_GAP_REPORT.md)

---

## 2. Hard Constraints

### 2.1 Repository boundaries

Do **not** edit anything under:

- `D:\Graduation\backend\last_backend\EduVerse_Backend`
- `D:\Graduation\frontend_tarek\Eduverse-Frontend`

All implementation work must stay inside:

- `D:\Graduation\EduVerse\edu_verse`

### 2.2 Backend contract is the truth for data and endpoints

Flutter must adapt to the backend as it exists today.

This means:

- do not plan backend API changes
- do not invent missing backend endpoints
- do not rely on fake local-only behavior for operations that are supposed to be server-backed

### 2.3 Website is the reference for user-facing flow, but not for bugs

Flutter should match the website’s visible notification flow where possible, but should **not** copy known website defects.

Examples that must **not** be copied:

- website shared service using wrong `clearAll` route
- website shared service using wrong `clearRead` route
- student sound toggle without real audio implementation
- lossy type mapping that hides backend notification meaning

### 2.4 Flutter fixes must remove misleading behavior

If a Flutter notification control looks real but is not backed by:

- backend data
- backend mutation
- clearly labeled local personal preference storage

then the implementer must either:

- replace it with real behavior, or
- remove it from the primary UX, or
- clearly convert it into an explicit local-only personal preference feature

### 2.5 No fake mobile push delivery

The backend stores `pushEnabled`, but this audit did not confirm a complete mobile push transport pipeline for Flutter.

Therefore:

- do not add fake device push behavior
- do not present a toggle as proof that Firebase/APNs delivery works unless it is actually implemented end to end
- treat backend `pushEnabled` as a real stored preference field, not proof of a finished mobile push delivery channel

---

## 3. Source References Inside Flutter

These are the primary Flutter files another Codex will likely touch during implementation.

### Shared notification infrastructure

- [notification_api_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/notification_api_service.dart:14)
- [notification_cubit.dart](/D:/Graduation/EduVerse/edu_verse/lib/bloc/notifications/notification_cubit.dart:1)
- [notification_state.dart](/D:/Graduation/EduVerse/edu_verse/lib/bloc/notifications/notification_state.dart:1)
- [api_notification_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/notifications/api_notification_model.dart:1)
- [notification_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/notifications/notification_model.dart:1)
- [main.dart](/D:/Graduation/EduVerse/edu_verse/lib/main.dart:163)

### Student notification surfaces

- [notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/notifications/notifications_screen.dart:56)
- [notification_tile.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/notifications/notification_tile.dart:1)
- [notifications_settings_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/settings/notifications_settings_screen.dart:18)
- [student_announcements_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/announcements/student_announcements_screen.dart:12)
- [communication_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:9)

### Instructor notification surfaces

- [instructor_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/notifications/instructor_notifications_screen.dart:48)

### TA notification surfaces

- [ta_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/ta/notifications/ta_notifications_screen.dart:50)

### Router and navigation

- [app_router.dart](/D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:412)

### Existing reusable infrastructure worth borrowing

- [chat_socket_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/chat/chat_socket_service.dart:148)
- [storage_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/storage_service.dart:6)
- [notification_swipe_settings_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/notification_swipe_settings_service.dart:5)

---

## 4. Reference Backend and Website Behaviors That Flutter Must Match

The implementer should treat the following behaviors as required parity targets inside Flutter.

### Backend capabilities that Flutter must consume correctly

- persisted notifications
- unread count
- mark one read
- mark all read
- delete one
- clear read
- clear all
- preferences
- realtime `newNotification`
- realtime `unreadCountUpdate`
- backend notification types:
  - `announcement`
  - `grade`
  - `assignment`
  - `message`
  - `deadline`
  - `system`
  - `lab`
  - `quiz`
  - `material`
  - `community`
  - `discussion`
  - `enrollment`
  - `schedule`
  - `office_hours`
- backend metadata:
  - `priority`
  - `actionUrl`
  - `relatedEntityType`
  - `relatedEntityId`
  - `announcementId`
  - `readAt`

### Website behaviors that Flutter should mirror

- realtime notification refresh while dashboard/screens are open
- incoming visual alert when a new notification arrives
- role-specific notification pages
- student notifications page behavior that includes announcements in the feed
- instructor and TA pages with real notification CRUD-like interactions
- unread badge freshness on dashboard-level entry points

### Website behaviors that Flutter should intentionally improve

- do not use the website’s wrong clear-all / clear-read routes
- do not copy the website’s silent sound toggle
- do not repeat the website’s overly lossy type collapses if Flutter can preserve richer backend meaning

---

## 5. Target End State

When all phases are complete, the Flutter project should behave like this.

### Student

- student notifications screen is fully backend-aligned
- student notifications screen supports real:
  - list fetch
  - unread count
  - mark one read
  - mark all read
  - clear read
  - clear all
  - delete one
- student screen no longer mixes fake AI/system placeholder content into the real notifications experience
- student screen includes announcement content in the notification feed in a controlled and deduplicated way that mirrors the website intent
- student screen can react to realtime socket events
- student screen can trigger navigation based on `actionUrl` or related entity metadata
- student settings screen is split between:
  - real backend notification preferences
  - real device-local in-app alert preferences

### Instructor

- instructor notification screen is fully backend-backed
- instructor screen supports real:
  - list fetch
  - unread sync
  - mark one read
  - mark all read
  - clear read
  - delete one
- instructor screen reacts to realtime updates
- instructor screen preserves backend notification type meaning instead of collapsing most types into generic buckets

### TA

- TA notification screen is fully backend-backed
- TA screen supports real:
  - list fetch
  - unread sync
  - mark one read
  - mark all read
  - clear read and/or clear all according to chosen final UX
  - delete one
- TA bulk actions mutate backend state correctly
- TA fake/misleading local-only notification behaviors are removed or clearly separated from real notification operations
- TA screen reacts to realtime updates

### Shared system

- Flutter has a proper notification socket layer using existing app auth data
- all roles use consistent notification semantics
- models preserve backend type richness
- mutations are optimistic only when safe and always have rollback/refetch strategy
- notification settings are no longer fake
- sound/vibration behavior exists only if it is truly implemented

---

## 6. Planning Principles for the Implementer

These rules should guide implementation decisions during all phases.

### 6.1 Prefer one shared notification domain model

Do not keep three unrelated notification interpretations if they can be derived from one backend-aligned base model.

Recommended approach:

- define one base notification entity aligned with backend fields
- define role-specific presentation adapters on top of that base entity
- keep shared mutations in one service/repository layer

### 6.2 Separate server state from device-local preferences

Server-backed preference examples:

- `emailEnabled`
- `pushEnabled`
- `smsEnabled`
- `announcementEmail`
- `gradeEmail`
- `assignmentEmail`
- `messageEmail`
- `deadlineReminderDays`
- `quietHoursStart`
- `quietHoursEnd`

Device-local preference examples:

- in-app sound enabled
- in-app vibration enabled
- show in-app alert banner/toast while app is foregrounded

These must not be mixed into one fake settings model.

### 6.3 Do not keep unsupported mutations in the primary UX

Examples of problematic controls today:

- mark as unread
- archive
- bookmark
- TA local bulk delete without backend sync
- TA local bulk mark-read without backend sync

If these are kept, they must be redefined as clearly local personal organization features with explicit persistence and explicit UX labeling. If that is not in scope, remove them from the primary notification action set.

### 6.4 Realtime should update both list and unread badge

A correct implementation should react to incoming socket events by updating:

- visible list data
- unread count state
- dashboard badge state
- in-app alert UI when enabled

### 6.5 Preserve backend meaning before improving visuals

The first responsibility is correctness:

- right data
- right mutation
- right route
- right type
- right source
- right navigation target

Only after that should the implementer spend time on micro-polish.

---

## 7. Recommended New Flutter Structure

Another Codex can implement the plan more safely if it introduces a clearer separation of responsibilities.

Recommended additions:

- `lib/models/notifications/notification_preference_model.dart`
- `lib/models/notifications/device_notification_preferences.dart`
- `lib/models/notifications/realtime_notification_event.dart`
- `lib/services/notifications/notification_socket_service.dart`
- `lib/services/notifications/device_notification_preferences_service.dart`
- `lib/repositories/notifications/notification_repository.dart`
- `lib/bloc/notifications/notification_preferences_cubit.dart`
- `lib/bloc/notifications/instructor_notifications_cubit.dart`
- `lib/bloc/notifications/ta_notifications_cubit.dart`
- `lib/utils/notifications/notification_action_resolver.dart`
- `lib/utils/notifications/notification_type_mapper.dart`

If the implementer wants a lighter approach, they may extend the current structure instead of creating all these files. But the final code should still achieve the same separation:

- transport
- repository/service
- mapping
- role-specific presentation state
- settings state

---

## 8. Phase Overview

### Phase 0

Preparation and shared design decisions inside Flutter

### Phase 1

Shared backend contract alignment and notification domain remodeling

### Phase 2

Realtime socket infrastructure and in-app alert plumbing

### Phase 3

Student notifications parity

### Phase 4

Student notification settings, alerts, and announcements parity

### Phase 5

Instructor notifications parity

### Phase 6

TA notifications parity

### Phase 7

Cross-role action routing, cleanup of misleading local-only controls, and UX consistency

### Phase 8

Stabilization, regression testing, and implementation handoff

---

## 9. Phase 0: Preparation and Shared Design Decisions

## 9.1 Objective

Create a clear internal Flutter implementation strategy before touching behavior. This phase prevents another Codex from fixing symptoms in three separate screens without unifying the underlying notification model.

## 9.2 Main outputs

- agreed shared notification model direction
- agreed socket service direction
- agreed separation between backend preferences and local device preferences
- agreed list of unsupported local-only actions to remove or downgrade

## 9.3 Tasks

- Re-read the audit report and extract all confirmed backend fields and supported mutations.
- Write a small internal implementation note listing the final Flutter-side meaning of each backend notification type.
- Decide whether the existing global student `NotificationCubit` will be:
  - upgraded into a shared repository-backed foundation, or
  - renamed/split so student/instructor/TA each have dedicated state objects on top of one shared repository.
- Decide how dashboard unread badges are owned:
  - one global notification count source, or
  - role-local count sources backed by one shared socket/repository layer.
- Decide whether announcement items in student notifications should be:
  - merged into one feed model with source tagging, or
  - rendered as a secondary section inside the same screen.

## 9.4 Required decisions

The implementer must explicitly decide and document these before starting code:

- whether to keep or remove `mark as unread`
- whether to keep or remove `archive`
- whether to keep or remove `bookmark`
- whether TA selection mode remains in the real notification screen
- whether announcement items without notification IDs are read-only informational entries

## 9.5 Exit criteria

- implementation direction is clear enough that later phases do not duplicate model and socket logic
- unsupported controls are explicitly classified as:
  - remove
  - rework
  - keep as explicit local-only

---

## 10. Phase 1: Shared Backend Contract Alignment and Domain Remodeling

## 10.1 Objective

Bring the shared Flutter notification layer into full alignment with the backend contract before role-specific screen work begins.

## 10.2 Main files to touch

- [notification_api_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/notification_api_service.dart:14)
- [api_notification_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/notifications/api_notification_model.dart:1)
- [notification_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/notifications/notification_model.dart:1)
- [notification_cubit.dart](/D:/Graduation/EduVerse/edu_verse/lib/bloc/notifications/notification_cubit.dart:1)

## 10.3 Detailed tasks

### Add missing API methods

- Add `clearAll()` that calls the real backend route `DELETE /notifications/clear-all`.
- Add `getPreferences()` that calls `GET /notifications/preferences`.
- Add `updatePreferences()` that calls `PUT /notifications/preferences`.
- Extend list fetching to support backend filters:
  - `type`
  - `priority`
  - `isRead`
  - `page`
  - `limit`

### Fix list query contract

- Replace or supplement the current `offset` query model with backend-compatible `page`.
- Preserve backward compatibility internally only if necessary during refactor.
- Do not leave the public API service shaped around `offset` if the backend expects `page`.

### Create a backend-aligned notification type system

- Update or replace the current limited notification enums so Flutter can represent every backend type explicitly.
- Ensure the base model can represent:
  - `announcement`
  - `grade`
  - `assignment`
  - `message`
  - `deadline`
  - `system`
  - `lab`
  - `quiz`
  - `material`
  - `community`
  - `discussion`
  - `enrollment`
  - `schedule`
  - `office_hours`

### Preserve backend metadata instead of collapsing it

- Ensure the base model retains:
  - `actionUrl`
  - `relatedEntityType`
  - `relatedEntityId`
  - `announcementId`
  - `priority`
  - `readAt`
  - `createdAt`

### Split base mapping from role presentation mapping

- Keep one normalized backend model.
- Move role-specific visual type mapping out of the API model if needed.
- Avoid a situation where one parse step already destroys backend meaning.

### Remove incorrect assumptions in shared code

- Delete or update the current incorrect comment claiming the backend has no clear-all endpoint.
- Audit all shared notification comments for factual accuracy after refactor.

## 10.4 Recommended implementation shape

- `ApiNotificationModel` should be a transport-normalized model only.
- `NotificationModel` should become a backend-aligned domain model.
- role screens should consume:
  - the domain model directly, or
  - role adapters derived from the domain model.

## 10.5 Risks to avoid

- do not keep grade notifications mapped to generic course types
- do not keep unknown types silently mapped to system unless there is a logged explicit fallback
- do not tie parsing logic to one role’s UI assumptions

## 10.6 Exit criteria

- Flutter service layer can call every existing backend notification endpoint needed by this feature
- one shared base notification model can represent every backend notification type and metadata field
- no shared notification code still assumes missing backend endpoints that actually exist

---

## 11. Phase 2: Realtime Socket Infrastructure and In-App Alert Plumbing

## 11.1 Objective

Implement a reusable Flutter notification realtime layer that matches the backend socket contract already used by the website.

## 11.2 Main files to touch

- [main.dart](/D:/Graduation/EduVerse/edu_verse/lib/main.dart:163)
- [storage_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/storage_service.dart:6)
- [chat_socket_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/chat/chat_socket_service.dart:148)

Likely new files:

- `lib/services/notifications/notification_socket_service.dart`
- `lib/models/notifications/realtime_notification_event.dart`

## 11.3 Detailed tasks

### Build a dedicated notification socket service

- Use `socket_io_client`, which is already present in `pubspec.yaml`.
- Follow the chat socket service pattern where useful, but keep notification logic isolated.
- Connect to the backend namespace `/notifications`.
- Include the same handshake information the website relies on:
  - auth token
  - `userId` in query

### Source auth and user identity from existing storage

- Use [storage_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/storage_service.dart:24) to load the access token.
- Use [storage_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/storage_service.dart:39) to load current user data so `userId` can be passed in the socket query.

### Support the two backend events

- listen for `newNotification`
- listen for `unreadCountUpdate`

### Normalize socket payloads into the same domain model as REST results

- do not create a second incompatible notification object shape for realtime
- REST and realtime items must pass through a common normalizer

### Handle connection lifecycle

- implement connect
- implement disconnect
- implement reconnect/backoff
- prevent duplicate socket instances
- unsubscribe listeners cleanly

### Integrate into app lifecycle

- decide whether socket connects:
  - globally after auth, or
  - lazily when notification-aware screens are mounted
- recommended direction for parity: maintain one app-level notification socket after login so dashboard badges stay fresh

### Add in-app foreground alert plumbing

- define a shared mechanism that UI layers can subscribe to when a new notification arrives
- this event should support:
  - list insertion/update
  - unread badge refresh
  - in-app banner/toast/snackbar
  - optional sound/vibration in later phases

## 11.4 Implementation notes

- Do not implement OS push notifications in this phase.
- This phase is strictly about realtime in-app socket delivery while the app is active.
- The website uses toast popups. Flutter can use:
  - overlay banner
  - snack bar
  - top-aligned in-app toast component

The exact widget can be chosen later, but the event pipeline should be created here.

## 11.5 Risks to avoid

- opening multiple duplicate socket connections from different role screens
- having screen-local unread counts that drift apart
- parsing realtime notifications with different type mappings than REST notifications

## 11.6 Exit criteria

- Flutter can receive and normalize `newNotification`
- Flutter can receive and apply `unreadCountUpdate`
- there is one reusable socket service usable by student, instructor, and TA flows

---

## 12. Phase 3: Student Notifications Parity

## 12.1 Objective

Upgrade the student notifications experience from partially backend-backed to a full real notifications inbox aligned with backend logic and website behavior.

## 12.2 Main files to touch

- [notification_cubit.dart](/D:/Graduation/EduVerse/edu_verse/lib/bloc/notifications/notification_cubit.dart:1)
- [notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/notifications/notifications_screen.dart:56)
- [notification_tile.dart](/D:/Graduation/EduVerse/edu_verse/lib/widgets/student/notifications/notification_tile.dart:1)
- [notification_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/notifications/notification_model.dart:1)
- [api_notification_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/notifications/api_notification_model.dart:1)

## 12.3 Detailed tasks

### Replace local-only clear-all with real backend clear-all

- update student overflow/menu actions to call the real backend endpoint through the shared service
- remove the current local-only clear-all implementation
- ensure unread count resets correctly after success
- add rollback or full refetch behavior on failure

### Remove fake notification sections from the real notifications product surface

Current fake or misleading areas include:

- local AI insights
- local system alerts that are not backend notifications

Required action:

- remove them from the primary notifications feed, or
- move them into a clearly separate feature area that is not labeled as real notifications

The parity target is real notification behavior, not decorative local content.

### Preserve actual backend type meaning in student cards

- student UI must handle real backend types distinctly
- update icons, labels, and categories so these types are meaningfully represented:
  - assignment
  - grade
  - announcement
  - lab
  - quiz
  - material
  - discussion
  - enrollment
  - schedule
  - office hours
  - deadline
  - message
  - system
  - community

### Replace unsupported core actions

Current problematic student actions include:

- mark as unread
- bookmark
- archive-like local behavior if present in the tile surface

Required action:

- remove unsupported server-looking actions from the primary notification UX
- if the team insists on keeping personal organization features, move them behind explicit local-only labeling and explicit persistence later

For parity, the safe path is to remove them from the main notification action flow.

### Implement proper realtime handling in student state

- insert or refresh newly received notifications
- update unread count immediately on socket event
- avoid duplicate insertion when a realtime item also appears in a near-term refetch
- sort by `createdAt` descending

### Implement true mutation semantics

- mark-as-read should never behave like a toggle
- delete should remove only the targeted notification
- clear-read should only remove read notifications
- clear-all should clear the entire notification list and unread count

### Improve optimistic update rules

- optimistic update is acceptable for read/delete actions if rollback or refetch is present
- clear-all and bulk operations should prefer refetch after success to avoid drift

## 12.4 Student feed composition requirements

The website student notifications page includes announcements in the feed. Flutter should mirror that behavior carefully.

This requires a design decision:

- notification records from the notifications API remain the primary source of unread state and mutation
- announcement records from the announcements API are informational feed items unless they have a matching notification identity

Recommended implementation:

- extend the student screen state to support feed items with `source`:
  - `notification`
  - `announcement`
- fetch notifications and announcements in parallel
- merge them into one sorted feed
- deduplicate where possible using:
  - `announcementId`
  - `relatedEntityType == 'announcement'`
  - `relatedEntityId`
  - title/body/time heuristics as fallback only

Recommended UX rules:

- announcement-only items should not be counted in unread notifications unless the backend notification list includes them as unread notification records
- announcement-only items should not expose delete/read mutations unless a corresponding notification ID exists

## 12.5 Required student UX outcomes

- no fake content mixed into the real notification domain
- no local-only bulk clear-all
- clear distinction between informational announcement entries and real notification records
- stable unread badge behavior
- correct type-specific visuals

## 12.6 Exit criteria

- student screen is fully backend-backed for real notification actions
- student list can receive realtime updates
- student announcement-in-feed behavior is present without corrupting unread semantics

---

## 13. Phase 4: Student Notification Settings, Alerts, and Announcements Parity

## 13.1 Objective

Turn the current student notification settings screen from a local mockup into a real preferences surface, and implement real in-app alert behavior for foreground notifications.

## 13.2 Main files to touch

- [notifications_settings_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/settings/notifications_settings_screen.dart:18)
- [notification_api_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/notification_api_service.dart:14)
- [main.dart](/D:/Graduation/EduVerse/edu_verse/lib/main.dart:163)

Likely new files:

- `lib/models/notifications/notification_preference_model.dart`
- `lib/models/notifications/device_notification_preferences.dart`
- `lib/services/notifications/device_notification_preferences_service.dart`
- `lib/bloc/notifications/notification_preferences_cubit.dart`

## 13.3 Detailed tasks

### Split the settings screen into two sections

#### Backend-backed account preferences

- `emailEnabled`
- `pushEnabled`
- `smsEnabled`
- `announcementEmail`
- `gradeEmail`
- `assignmentEmail`
- `messageEmail`
- `deadlineReminderDays`
- `quietHoursStart`
- `quietHoursEnd`

#### Device-local in-app alert preferences

- sound enabled
- vibration enabled
- show foreground in-app alert enabled

This split is important because backend and website do not provide the same settings model.

### Load and save backend preferences for real

- call `GET /notifications/preferences` on screen load
- populate form fields from real backend values
- call `PUT /notifications/preferences` on save
- show save success/failure feedback

### Reconcile the existing push toggle

Do not present the current toggle as proof of fully working mobile push delivery.

Recommended behavior:

- keep the backend `pushEnabled` field because it is real backend data
- label it as a notification preference channel rather than a proven device push pipeline
- do not claim "device push notifications are active" unless the project really has end-to-end push

### Implement real foreground alert behavior

When a new notification arrives through the realtime socket while the app is open:

- show an in-app alert UI if enabled
- optionally play a sound if enabled
- optionally vibrate if enabled and supported

### Implement sound behavior only if it is real

Use `audioplayers`, which is already present in the project.

Implementation requirements:

- define one short bundled alert sound asset
- preload or manage playback safely
- respect the local sound preference
- prevent overlapping chaotic playback bursts

### Implement vibration only if supported correctly

The current project has a vibration toggle UI, but this audit did not find an actual vibration package integration.

Required approach:

- either add a real vibration implementation with proper package and platform handling
- or temporarily hide/disable the vibration toggle until it is truly supported

Do not leave a fake vibration toggle visible.

### Handle announcements parity on the settings side

Because the website includes announcements in the student notifications experience, student settings should include a clear distinction between:

- announcement-related backend delivery preferences
- device-local in-app alert preferences

## 13.4 Risks to avoid

- mixing server-backed and local-only preferences into one flat unsaved state
- keeping sound/vibration toggles visible without implementation
- creating a save button that only updates local widget state

## 13.5 Exit criteria

- student notification settings screen loads and saves real backend preferences
- student foreground alert behavior exists and respects local device preferences
- no fake sound/vibration toggle remains in the UI

---

## 14. Phase 5: Instructor Notifications Parity

## 14.1 Objective

Bring instructor notifications to parity with the backend and the website’s live behavior while preserving backend meaning more accurately than the current Flutter mapping.

## 14.2 Main files to touch

- [instructor_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/notifications/instructor_notifications_screen.dart:48)
- [notification_api_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/notification_api_service.dart:14)
- [api_notification_model.dart](/D:/Graduation/EduVerse/edu_verse/lib/models/notifications/api_notification_model.dart:117)

Likely new files:

- `lib/bloc/notifications/instructor_notifications_cubit.dart`

## 14.3 Detailed tasks

### Replace direct screen-owned mutation logic with shared repository-backed state

- move API interaction and reconciliation out of widget code where practical
- ensure the instructor screen uses the same mutation semantics as student and TA

### Add missing instructor actions

The website instructor notifications page supports:

- list fetch
- mark single read
- mark all read
- clear read
- delete single

Flutter instructor screen must support the same set at minimum.

Required work:

- add `clearRead` UI
- wire `clearRead` to real backend endpoint
- keep delete single and mark-read backed by real API calls

### Add realtime updates

- subscribe instructor notification state to the shared socket layer
- refresh or insert incoming items live
- update unread badge/state live

### Replace lossy type mapping

Current Flutter instructor mapping is too coarse.

Required action:

- preserve raw backend type
- define instructor-specific display groups only at presentation level
- never lose the original type

Suggested instructor visual groupings if needed:

- submissions
- grading
- discussions
- schedule
- office hours
- announcements
- system

But these groups must be derived from the original backend type, not replace it.

### Implement actionable navigation

On tap, instructor notifications should route to the most relevant screen based on:

- `actionUrl`
- `relatedEntityType`
- `relatedEntityId`

If no direct route exists yet:

- navigate to the closest relevant top-level screen
- do not leave the notification tap as a no-op

## 14.4 UX cleanup rules

- do not show fallback mock notification lists in normal production behavior
- if load fails, show explicit error state with retry instead of fabricated content

## 14.5 Exit criteria

- instructor screen fully supports backend-backed list and core actions
- instructor screen reacts to realtime updates
- instructor screen no longer collapses most backend types into generic labels

---

## 15. Phase 6: TA Notifications Parity

## 15.1 Objective

Convert the TA notifications screen from a mixed live/local prototype into a reliable backend-backed notifications client.

## 15.2 Main files to touch

- [ta_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/ta/notifications/ta_notifications_screen.dart:50)
- [notification_api_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/api/notification_api_service.dart:14)
- [notification_swipe_settings_service.dart](/D:/Graduation/EduVerse/edu_verse/lib/services/notification_swipe_settings_service.dart:5)

Likely new files:

- `lib/bloc/notifications/ta_notifications_cubit.dart`

## 15.3 Detailed tasks

### Replace local toggle semantics with real mark-read semantics

Current issue:

- `_markAsRead` behaves like a toggle, not a real mark-read operation

Required fix:

- `markAsRead` should only ever move unread to read
- there should be no local "flip" back to unread unless a real local-only personal state feature is intentionally introduced

### Replace local-only bulk actions

Current problematic TA bulk operations:

- mark all read only mutates local list
- delete all clears local list only

Required fix:

- bulk mark all read must call backend `PATCH /notifications/read-all`
- bulk clear operations must call backend `DELETE /notifications/clear-read` or `DELETE /notifications/clear-all` based on selected action
- refetch after success

### Redesign bulk action menu around real backend capabilities

Recommended final TA bulk menu:

- mark all as read
- clear read
- clear all

Recommended removals from the primary backend-backed flow:

- archive if not truly persisted
- bookmark if not truly persisted
- AI reply shortcuts if not part of real notification backend flow

### Replace fake filters with real backend-backed filters

Current TA filters such as:

- students
- instructors
- AI

are not backed by a confirmed backend notification field in this audit.

Required fix:

- replace them with filters based on real data:
  - all
  - unread
  - read
  - type-based filters from backend
  - priority-based filters if useful

### Add realtime updates

- subscribe TA screen state to shared socket events
- live-insert new notifications
- update unread count

### Preserve backend meaning for TA workflows

TA should be able to distinguish at least:

- assignment submissions
- lab submissions or lab-related notifications
- grading reminders
- announcements
- discussion notifications
- office hours notifications
- schedule notifications
- system notifications

Do not map everything non-assignment to generic system.

## 15.4 Handling swipe actions

The TA screen uses notification swipe settings.

Recommended rule:

- keep swipe customization only for real supported actions
- remove unsupported actions from selectable swipe options for notifications if they remain unimplemented

Examples:

- keep delete if backend-backed
- keep mark read if backend-backed
- remove archive/bookmark from notification swipe options unless explicitly converted into local personal organization features

## 15.5 Exit criteria

- TA bulk actions are real backend mutations
- TA mark-read semantics are correct
- TA filters are derived from real backend data
- TA screen reacts to realtime updates

---

## 16. Phase 7: Cross-Role Action Routing, Cleanup, and UX Consistency

## 16.1 Objective

Make notification taps and actions meaningful across all roles, and remove or isolate the remaining misleading controls that do not belong in a backend-backed notification system.

## 16.2 Main files to touch

- [app_router.dart](/D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:412)
- [notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/student/notifications/notifications_screen.dart:698)
- [instructor_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/notifications/instructor_notifications_screen.dart:137)
- [ta_notifications_screen.dart](/D:/Graduation/EduVerse/edu_verse/lib/screens/ta/notifications/ta_notifications_screen.dart:258)

Likely new files:

- `lib/utils/notifications/notification_action_resolver.dart`

## 16.3 Detailed tasks

### Implement a shared notification action resolver

The resolver should:

- inspect `actionUrl`
- inspect `relatedEntityType`
- inspect `relatedEntityId`
- inspect raw notification type
- return the correct app navigation target

### Define route mapping rules

The resolver should support at least:

- assignment-related notifications
- lab-related notifications
- quiz-related notifications
- grade-related notifications
- material-related notifications
- discussion-related notifications
- enrollment-related notifications
- schedule-related notifications
- office-hours-related notifications
- announcement-related notifications

If a direct deep-link route does not exist, the fallback should still be useful.

Examples of acceptable fallback behavior:

- open the relevant course area
- open the relevant module list screen
- open the role’s dashboard section related to that domain

### Normalize list sorting and display rules

Across all roles, standardize:

- newest first sorting
- unread visual treatment
- priority visual treatment
- empty state behavior
- loading state behavior
- error state behavior

### Remove remaining misleading local-only controls

By the end of this phase, no notification screen should still expose unsupported controls as if they are server-backed.

Likely removals or redesigns:

- student mark unread
- student bookmark
- student archive
- TA archive
- TA bookmark
- AI-reply-like notification actions if they are not backed

### Keep local-only personal features only if clearly intentional

If the team decides to keep local-only bookmark or archive behavior:

- store it explicitly using local persistence
- label it as personal organization, not server state
- never let it interfere with server unread/read semantics

That should be treated as optional polish, not core parity.

## 16.4 Exit criteria

- all roles have meaningful tap behavior
- action routing is centralized and predictable
- unsupported controls are removed or clearly downgraded to personal local-only features

---

## 17. Phase 8: Stabilization, Regression Testing, and Handoff

## 17.1 Objective

Finish the implementation with confidence so the next engineer does not inherit a fragile partially refactored notifications system.

## 17.2 Required testing coverage

### Unit tests

- API response parsing for all backend notification types
- preference model parsing
- socket payload normalization
- action resolver logic
- dedupe logic for merged student notifications and announcements

### Widget tests

- student notifications screen loading state
- student clear-all / clear-read / delete / mark-read state transitions
- instructor clear-read and mark-all-read UX
- TA bulk actions using backend-backed semantics
- settings screen rendering backend and local preference sections correctly

### Manual QA

Student:

- open notifications screen
- verify list fetch
- verify unread count
- verify clear read
- verify clear all
- verify delete single
- verify announcement items appear correctly
- verify tap navigation
- verify realtime insert and badge update
- verify sound toggle only affects real implemented audio behavior

Instructor:

- open instructor notifications
- verify list fetch
- verify mark one read
- verify mark all read
- verify clear read
- verify delete one
- verify realtime update
- verify tap navigation

TA:

- open TA notifications
- verify list fetch
- verify mark one read
- verify mark all read
- verify clear read and/or clear all
- verify delete one
- verify bulk actions use backend
- verify realtime update
- verify unsupported local-only controls are gone or clearly labeled

### Failure and recovery testing

- socket disconnect and reconnect
- API failure during optimistic delete
- API failure during mark-read
- API failure during clear-all
- duplicate notification arrival through socket + refresh

## 17.3 Documentation updates

After implementation, update or add:

- a short developer note describing the notification architecture
- a short note describing which settings are backend-backed vs device-local
- a short note describing how notification tap routing works

## 17.4 Exit criteria

- feature behavior matches the final target end state
- no known fake notification behavior remains in student/instructor/TA flows
- another engineer can understand the notification architecture without re-investigating backend and website behavior

---

## 18. Priority Order Within Phases

If time becomes constrained, implement in this exact order.

### Must do first

1. Phase 1 shared contract alignment
2. Phase 2 realtime infrastructure
3. Phase 3 student core parity

### Must do next

4. Phase 5 instructor parity
5. Phase 6 TA parity

### Must do after core parity

6. Phase 4 settings and alert correctness
7. Phase 7 routing and misleading-control cleanup

### Must do before closing the task

8. Phase 8 stabilization and QA

Note:

Phase 4 appears numerically before phases 5 and 6 because it belongs to student scope, but if implementation sequencing is easier, the engineer may complete instructor and TA list parity before finishing the student settings screen. The hard dependency is that shared contract and realtime infrastructure must land first.

---

## 19. Features That Should Not Be Reintroduced Incorrectly

Another Codex implementing this plan should be careful not to accidentally recreate the current bad states.

Do not reintroduce:

- fake AI insights inside real notifications
- fake system alerts inside real notifications
- local-only clear-all for server-backed lists
- mark-read implemented as a toggle
- backend type collapse into generic `system` for most cases
- dashboard unread counts that only refresh on manual pull
- silent sound/vibration toggles with no implementation
- fake fallback mock notifications in instructor or TA views

---

## 20. Final Handoff Summary for the Implementer

The implementation should be understood as three layers of work.

### Layer 1: shared infrastructure

- backend contract alignment
- type-safe domain modeling
- realtime socket
- shared repository/state strategy

### Layer 2: role parity

- student parity including merged announcement feed behavior
- instructor parity
- TA parity

### Layer 3: cleanup and trustworthiness

- real settings
- real alerts
- real routing
- removal of misleading local-only controls
- regression coverage

If another Codex follows this plan in order, the result should be a Flutter notifications system that is:

- aligned with backend truth
- behaviorally close to the website
- safer than the website in places where the website has known bugs
- much more maintainable than the current mixed implementation

This document is the execution plan baseline and should be used together with the audit report during implementation.
