# EduVerse Notifications Audit Report

## Backend + Website vs Flutter

Prepared on: 2026-04-25

Compared codebases:

- Flutter app: `D:\Graduation\EduVerse\edu_verse`
- Backend: `D:\Graduation\backend\last_backend\EduVerse_Backend`
- Website frontend: `D:\Graduation\frontend_tarek\Eduverse-Frontend`

---

## 1. Purpose of This Report

This report investigates the notification system and all closely related behavior across the backend, website, and Flutter app for the following roles:

- Student
- Instructor
- TA

The goal is not to propose an implementation plan yet. The goal is to produce a detailed comparison report that answers:

- What the backend already supports
- What the website actually implements on top of the backend
- What the Flutter app currently implements
- What is partially implemented in Flutter compared to the website/backend
- What is totally missing in Flutter
- What is wrong, misleading, or architecturally inconsistent in Flutter
- Which surrounding features trigger notifications and therefore must be considered part of the notification scope
- What the website uses for notification alerting on the notifications/dashboard side, especially sound vs visual alerts

---

## 2. Executive Summary

The backend already contains a real notification platform, not just a simple notifications list. It includes:

- persisted notifications
- notification types and priorities
- unread count
- mark one read / mark all read
- delete one / clear read / clear all
- realtime delivery via Socket.IO namespace `/notifications`
- notification preferences
- scheduled notification generation via cron jobs
- many notification producers across assignments, labs, quizzes, grades, materials, announcements, discussions, enrollments, schedule, office hours, attendance, and campus events

The website is significantly closer to the backend than the Flutter app. The website has:

- realtime socket integration
- dashboard unread badge refresh
- toast popup on new incoming notifications
- role-specific notification pages
- working read-state mutations

However, the website is not perfect either. It has several important issues:

- `clearAll` and `clearRead` are wired to wrong REST routes in the shared notification service
- the student page mixes notifications API data with announcements API data
- the student page exposes a `soundEnabled` setting but no actual sound playback was found
- several role pages collapse many backend notification types into oversimplified UI categories
- TA notifications exist in both mock/static and live/API-backed forms

The Flutter app is behind the backend and the website in the notification area. It has some live API integration, but it is incomplete and inconsistent:

- Student Flutter is only partially connected to the backend
- Instructor Flutter is live for basic list/read/delete actions, but not realtime and not type-complete
- TA Flutter loads live notifications initially, but many actions are local-only and not synced correctly
- Flutter has no notification realtime socket integration
- Flutter has no notification alert sound implementation
- Flutter does not integrate backend notification preferences
- Flutter loses many backend notification types during mapping
- Flutter exposes several notification features that look real but are only local UI state

In short:

- Backend = strong source of truth
- Website = mostly functional notification client, but with some defects and inconsistencies
- Flutter = partial implementation with major gaps in realtime, preferences, type fidelity, action fidelity, and role parity

---

## 3. Scope and Investigation Method

This audit covered:

- backend notification module architecture
- backend notification producers in surrounding academic features
- website notification services, realtime socket flow, role dashboards, and notification pages
- Flutter notification services, models, cubits/state, screens, settings, and related dependencies

The investigation focused on evidence from code, not assumptions. When something was not found, this report states that it was not found in the inspected code rather than claiming it does not exist conceptually.

---

## 4. Backend Notification System: Source of Truth

## 4.1 Core backend notification module

The backend has a dedicated notifications module that acts as the source of truth for notification storage, delivery, preferences, and scheduled reminders.

Key files:

- `src/modules/notifications/controllers/notifications.controller.ts`
- `src/modules/notifications/services/notifications.service.ts`
- `src/modules/notifications/notifications.gateway.ts`
- `src/modules/notifications/services/notification-cron.service.ts`
- `src/modules/notifications/entities/notification.entity.ts`
- `src/modules/notifications/entities/notification-preference.entity.ts`
- `src/modules/notifications/entities/scheduled-notification.entity.ts`
- `src/modules/notifications/enums/index.ts`

## 4.2 Backend REST endpoints

Controller evidence:

- `GET /api/notifications` at `notifications.controller.ts:45`
- `GET /api/notifications/unread-count` at `notifications.controller.ts:56`
- `PATCH /api/notifications/read-all` at `notifications.controller.ts:67`
- `DELETE /api/notifications/clear-all` at `notifications.controller.ts:78`
- `DELETE /api/notifications/clear-read` at `notifications.controller.ts:89`
- `GET /api/notifications/preferences` at `notifications.controller.ts:100`
- `PUT /api/notifications/preferences` at `notifications.controller.ts:111`
- `PATCH /api/notifications/:id/read` at `notifications.controller.ts:123`
- `DELETE /api/notifications/:id` at `notifications.controller.ts:136`
- `POST /api/notifications/send` at `notifications.controller.ts:151`

This matters because the website and Flutter implementations should align to this contract. Some of them currently do not.

## 4.3 Backend notification query model

The backend list service supports filtering and pagination:

- `type`
- `priority`
- `isRead`
- `page`
- `limit`

Evidence:

- `notifications.service.ts:74-87`
- DTO query fields in `src/modules/notifications/dto/index.ts:73-102`

Important contract note:

- The backend expects `page` and `limit`
- Flutter service currently exposes `offset` and `limit`
- This is a pagination contract mismatch, even if current screens are mostly using only `limit`

## 4.4 Backend realtime delivery

Realtime notifications are already implemented on the backend through Socket.IO.

Evidence from `notifications.gateway.ts`:

- namespace `/notifications` at line 14
- connection handling at line 25
- user ID extraction from socket handshake at line 47
- emit `newNotification` at lines 77-78
- emit `unreadCountUpdate` at lines 85-86

Important backend behavior:

- users join room `user_<id>`
- realtime delivery is per-user
- gateway currently extracts `userId` from the socket handshake query
- the website already connects to this gateway
- Flutter does not

## 4.5 Backend preferences model

The backend supports stored notification preferences. This is a real backend feature, not a future placeholder.

Evidence from `notification-preference.entity.ts`:

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

This is important because Flutter currently exposes notification settings UI but does not wire it to these backend preferences.

## 4.6 Backend notification types

Notification types defined in backend enum `src/modules/notifications/enums/index.ts:1-15`:

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

The stored notification entity also includes:

- `relatedEntityType`
- `relatedEntityId`
- `announcementId`
- `actionUrl`
- `priority`
- `readAt`

Evidence: `notification.entity.ts:20-47`

This means the backend model is richer than the Flutter presentation model.

## 4.7 Backend scheduled reminders

The backend notification module also generates scheduled notifications, not just event-driven ones.

Evidence from `notification-cron.service.ts`:

- `handleDailyScheduleReminders` at line 92
- `handleDeadlineReminders` at line 137
- `handleGradingReminders` at line 149
- `sendAssignmentDeadlineReminders` at line 157
- `sendLabDeadlineReminders` at line 198
- `sendQuizClosingReminders` at line 239
- `sendAssignmentGradingReminders` at line 281
- `sendLabGradingReminders` at line 320
- `sendExamTomorrowReminders` at line 359
- `sendCampusEventReminders` at line 392

This means any parity effort must account for both:

- immediate notifications caused by user actions
- scheduled notifications caused by time-based rules

---

## 5. Backend Trigger Inventory by Feature and Role

This section answers the important question from the note: notification work on the website involved edits in many other features. That is true in the backend as well. Notifications are not isolated; they are emitted from many academic modules.

## 5.1 Student-facing notification triggers already present in backend

### Assignments

Evidence: `src/modules/assignments/services/assignments.service.ts`

- published assignment notifications are produced through `notifyStudentsAboutPublishedAssignment` at line 34
- assignment creation/update publish flow calls this method at lines 117, 231, and 278
- assignment graded notification uses title `Assignment Graded` at line 467

### Labs

Evidence: `src/modules/labs/services/labs.service.ts`

- published lab notifications are produced through `notifyStudentsAboutPublishedLab` at line 34
- publish/update flows call this method at lines 176, 196, and 223
- lab graded notification uses title `Lab Graded` at line 390

### Quizzes

Evidence: `src/modules/quizzes/services/quizzes.service.ts`

- published quiz notifications are produced through `notifyStudentsAboutPublishedQuiz` at line 48
- publish/update flows call this method at lines 130, 214, and 236
- quiz graded notification uses title `Quiz Graded` at line 578

### Grades

Evidence: `src/modules/grades/services/grades.service.ts`

- grade publish notification uses title `Grade Published` at line 172
- bulk/other grade publish path also uses title `Grade Published` at line 213

### Course materials

Evidence: `src/modules/course-materials/services/materials.service.ts`

- new material notification helper `notifyStudentsOfNewMaterial` at line 50
- invoked in upload/update flows at lines 241, 286, 369, 653, and 890

### Announcements

Evidence: `src/modules/announcements/services/announcements.service.ts`

- target audience notification helper `notifyTargetAudience` at line 45
- invoked during announcement save/publish flows at lines 308, 337, and 377

### Discussions

Evidence: `src/modules/discussions/services/discussions.service.ts`

- `New Reply in Discussion` at line 196
- `New Reply to Your Message` at line 212
- `Reply Endorsed` at line 302
- `Reply Upvoted` at line 338

### Enrollment

Evidence: `src/modules/enrollments/services/enrollments.service.ts`

- `Course Enrollment Successful` at line 309
- `Course Dropped` at line 540

### Attendance

Evidence: `src/modules/attendance/services/attendance.service.ts`

- absent notification body at line 62

### Office hours

Evidence: `src/modules/office-hours/services/office-hours.service.ts`

- `Appointment Confirmed` at line 358
- `Appointment Cancelled` at lines 372 and 404

### Schedule and campus events

Evidence:

- `Exam Scheduled` / `Exam Schedule Updated` at `exam-schedule.service.ts:36`
- `Campus Event Registration Confirmed` at `campus-events.service.ts:30`

### Scheduled reminders affecting students

Evidence from `notification-cron.service.ts`:

- assignment due soon
- lab due soon
- quiz closing soon
- exam tomorrow
- campus event reminder

## 5.2 Instructor-facing and TA-facing triggers already present in backend

### Assignment submissions to course staff

Evidence: `src/modules/assignments/services/assignments.service.ts`

- helper `notifyCourseStaffAboutSubmission` at line 54
- submission flow calls it at lines 380 and 651

### Lab submissions to course staff

Evidence: `src/modules/labs/services/labs.service.ts`

- helper `notifyCourseStaffAboutSubmission` at line 54
- submission flow calls it at lines 313 and 653

### Discussion threads created by students

Evidence: `src/modules/discussions/services/discussions.service.ts`

- `New Discussion Thread` at lines 136-137

### Staff schedule reminders

Evidence: `notification-cron.service.ts:92`

- daily schedule reminders are generated for teaching activities

### Staff grading reminders

Evidence:

- pending assignment grading reminders at `notification-cron.service.ts:281`
- pending lab grading reminders at `notification-cron.service.ts:320`

### Announcement targeting

Evidence: `announcements.service.ts:45`

- announcements can be targeted to audience groups including staff-related audiences

### Office hours

Evidence: `office-hours.service.ts:358`, `372`, `404`

- appointment confirm/cancel notifications affect staff as well

### Instructor assignment to section

Evidence: `enrollments.service.ts`

- assignment log at line 1066
- instructor assignment notification body at line 1074

### TA assignment to section

Evidence: `enrollments.service.ts`

- TA assignment log at line 1219
- TA assignment notification body at line 1226

## 5.3 Important backend conclusion

The backend notification domain is broad. A notification parity project is not just a single screen project. It touches:

- assignments
- labs
- quizzes
- grades
- announcements
- discussions
- materials
- enrollment
- attendance
- office hours
- schedule
- campus events
- cron reminders

Any Flutter parity work that only focuses on a notification list UI will still be incomplete.

---

## 6. Website Notification Implementation

## 6.1 Shared website notification API client

Key file:

- `src/services/api/notificationService.ts`

What it does correctly:

- fetches notifications
- fetches unread count
- marks one as read
- marks all as read
- deletes one
- exposes preferences get/update methods

Important defects:

- `clearAll()` uses `DELETE /notifications` at lines 119-120
- `clearRead()` uses `DELETE /notifications/read` at lines 123-124

These do not match backend routes:

- backend expects `/notifications/clear-all`
- backend expects `/notifications/clear-read`

This means the shared website service contains a contract bug in these two operations.

## 6.2 Website realtime notification infrastructure

Key files:

- `src/services/notifications/notificationSocket.ts`
- `src/hooks/useNotificationRealtime.ts`

What is implemented:

- connects to Socket.IO namespace `/notifications`
- resolves `userId` from stored user object
- sends `userId` in socket handshake query
- listens to `newNotification`
- listens to `unreadCountUpdate`
- normalizes socket payload into frontend notification shape

Evidence:

- socket connection namespace logic in `notificationSocket.ts:104-113`
- `newNotification` and `unreadCountUpdate` listener registration in `useNotificationRealtime.ts:57-58`
- toast popup in `useNotificationRealtime.ts:45-48`

## 6.3 What the website uses for notification alerting

This was a specific investigation target.

### Actual alerting behavior found

The website shows a toast popup when a new realtime notification arrives:

- `toast.success(notification.title, { description: ... })`
- evidence at `useNotificationRealtime.ts:45-48`

### Sound behavior found

I found a `soundEnabled` setting in the student notification UI:

- `NotificationCenter.tsx:131`
- settings option at `NotificationCenter.tsx:664`
- Save Settings button at `NotificationCenter.tsx:694`

However, I did **not** find actual notification audio playback in the website notification flow.

Specifically, I found:

- toast popup behavior
- no confirmed audio playback call in the inspected notification code
- no evidence that the student page `soundEnabled` toggle triggers a real sound engine

Therefore:

- the website appears to have **visual realtime alerting**
- the website does **not appear to have real notification sound playback implemented**, even though the student UI exposes a sound toggle

This distinction matters because Flutter currently also lacks sound playback. If parity target is "website as-is", then visual alert parity matters first. If target is "intended product behavior", then both website and Flutter still need real sound behavior.

## 6.4 Student website implementation

Key file:

- `src/pages/student-dashboard/components/NotificationCenter.tsx`

What the student website does:

- loads notifications from the notification API
- loads unread count from the notification API
- also loads announcements from `announcementService.getAnnouncements()` at line 140
- merges these into the displayed list
- supports mark as read
- supports mark all as read
- supports clear read
- exposes notification settings UI

Evidence:

- announcements import at line 25
- announcement fetch at line 140
- type mapping call at line 144
- mark as read at line 305
- mark all as read at line 317
- clear read at line 336

Important observations:

### Student website is not a pure notification-API screen

It mixes:

- backend notifications
- announcements from a separate API

This means the website student experience is broader than the raw notifications endpoint alone.

### Delete behavior is local-only in the student page

`deleteNotification` in `NotificationCenter.tsx:325-331` only removes the item from local UI state and adjusts local unread count. It does not call `NotificationService.deleteNotification()`.

This is an important behavioral gap even inside the website itself.

### Type mapping is incomplete

The student page has a local `mapNotificationType` function at line 70, but the overall student notification page does not clearly preserve the full backend type richness for:

- lab
- quiz
- material
- discussion
- schedule
- office hours
- community
- deadline

### Settings are not actually persisted to backend preferences

The page exposes settings UI, including sound, but no evidence was found that it calls:

- `NotificationService.getPreferences()`
- `NotificationService.updatePreferences()`

### Realtime exists at dashboard level

Student dashboard uses `useNotificationRealtime`:

- import at `StudentDashboard.tsx:55`
- notification fetch refresh around lines `159-160`
- realtime hook usage at line `185`
- notification page receives refresh signal at line `460`

So the website student role has realtime infrastructure that Flutter does not currently have.

## 6.5 Instructor website implementation

Key files:

- `src/pages/instructor-dashboard/components/NotificationsPage.tsx`
- `src/pages/instructor-dashboard/InstructorDashboard.tsx`

What is good:

- loads backend notifications from API
- has mark all read
- has clear read
- has mark single read
- has delete single
- dashboard integrates realtime hook and refresh signal

Evidence:

- notification fetch at `NotificationsPage.tsx:271-273`
- fallback to mock data on error at `276-277`
- mark all read at `347`
- clear read at `359`
- mark one read at `376`
- delete one at `386`
- dashboard realtime hook at `InstructorDashboard.tsx:268`
- refresh signal passed into page at `InstructorDashboard.tsx:1568`

Important issues:

### Type mapping is lossy

`mapApiNotificationToNotification` maps:

- `assignment -> submission`
- `grade -> grading`
- `announcement -> message`
- `system -> system`
- `enrollment -> deadline`

Evidence: `NotificationsPage.tsx:47-54`

This means many backend types are not preserved semantically:

- lab
- quiz
- material
- discussion
- office_hours
- schedule
- deadline
- message

### There is a mock fallback path

The page falls back to `initialNotifications` on load error:

- `NotificationsPage.tsx:82`
- `NotificationsPage.tsx:276-277`

That is acceptable as a resilience strategy, but it means the page can silently display non-backend data when the API fails.

## 6.6 TA website implementation

There are two different TA notification implementations on the website side, and that is important.

### TA static/mock page

Key file:

- `src/pages/ta-dashboard/components/NotificationsPage.tsx`

Observed behavior:

- contains static notification content
- uses backend only for some bulk actions such as mark all read / clear read
- does not appear to be the main live source-of-truth list

Evidence:

- static content entries exist in this file
- mark all read uses API at line `198`
- clear read uses API at line `209`

### TA live/dashboard-backed implementation

Key files:

- `src/pages/ta-dashboard/TADashboard.tsx`
- `src/pages/ta-dashboard/components/LiveModeViews.tsx`

What is implemented:

- dashboard fetches notifications
- dashboard fetches unread count
- dashboard uses realtime hook
- live mode can mark single read
- live mode can mark all read
- live mode can clear all

Evidence:

- fetch list and unread count at `TADashboard.tsx:342-343`
- realtime hook at `TADashboard.tsx:363`
- larger notifications fetch at `TADashboard.tsx:738`
- mark one read at `945`
- mark all read at `952`
- clear all at `959`

Important issue:

- `NotificationService.clearAll()` is used by TA live mode
- shared website service points `clearAll()` to wrong route `/notifications`
- backend expects `/notifications/clear-all`

So TA website live clear-all path is conceptually implemented but contract-broken through the shared service.

## 6.7 Website conclusion

Relative to the Flutter app, the website already has:

- realtime socket notifications
- dashboard unread refresh
- toast popup on incoming notifications
- stronger role coverage
- more backend-backed notification actions

But the website is not a perfect source of UI truth. It contains its own defects and inconsistencies that should not necessarily be copied into Flutter unchanged.

---

## 7. Flutter Notification Implementation

## 7.1 Shared Flutter API layer

Key file:

- `lib/services/api/notification_api_service.dart`

Implemented methods:

- `getAll()`
- `getUnreadCount()`
- `markAsRead()`
- `markAllAsRead()`
- `clearRead()`
- `deleteNotification()`

Evidence:

- list at `notification_api_service.dart:44`
- unread count at `67`
- mark one read at `81`
- mark all read at `88`
- clear read at `97`
- delete one at `106`

Missing methods:

- no `clearAll()`
- no `getPreferences()`
- no `updatePreferences()`
- no socket/realtime client

Important contract note:

- service supports query param `offset` at `46` and `52`
- backend expects `page`

## 7.2 Flutter app-level initialization

Key file:

- `lib/main.dart`

Observed behavior:

- app creates `NotificationApiService`
- app creates global student `NotificationCubit`
- app loads notifications at startup

Evidence:

- service creation at `main.dart:163`
- cubit creation at `167`
- initial load at `169`

What is not present:

- no notification socket initialization
- no notification sound setup
- no notification polling coordinator
- no notification preferences bootstrap

## 7.3 Student Flutter implementation

Key files:

- `lib/bloc/notifications/notification_cubit.dart`
- `lib/bloc/notifications/notification_state.dart`
- `lib/screens/student/notifications/notifications_screen.dart`
- `lib/models/notifications/api_notification_model.dart`
- `lib/models/notifications/notification_model.dart`
- `lib/screens/student/settings/notifications_settings_screen.dart`

### What is implemented for student Flutter

- live notification list fetch from backend
- live unread count fetch from backend
- mark as read
- mark all as read
- clear read
- delete single
- local filtering/search/bookmark/archive style UI

### What is only partially implemented

The student cubit is only partially backend-backed.

Evidence from `notification_cubit.dart`:

- `markAsRead` fires backend call after optimistic UI update at lines `75-93`
- `markAllAsRead` fires backend call after optimistic UI update at lines `116-124`
- `deleteNotification` fires backend call after optimistic UI update at lines `140-154`
- `clearReadNotifications` uses backend API starting at line `163`

### What is local-only or fake

Evidence from `notification_cubit.dart`:

- `AI Insights and System Alerts remain local-only (no backend endpoints)` at lines `51-53`
- `markAsUnread` is local-only starting at line `97`
- `toggleBookmark` is local-only at line `127`
- `clearAllNotifications` is local-only at `157-160`

Important issue:

- the comment says clear-all is local-only because backend has no clear-all endpoint
- this is false
- backend **does** provide `DELETE /api/notifications/clear-all`

So the current Flutter student implementation is not just incomplete. It is also based on an incorrect assumption.

### Student screen behavior gap

Evidence from `notifications_screen.dart`:

- clear read action calls backend-backed cubit method at line `446`
- clear all action calls local-only cubit method at line `459`
- tapping a notification marks it as read at `699`
- comment says `Handle navigation based on notification type` at line `700`

This means:

- student Flutter can mark notifications read
- but it does not implement actual type-based navigation or action URL handling

### Student settings are UI-only

Evidence from `notifications_settings_screen.dart`:

- `_pushEnabled` at line `18`
- `_soundEnabled` at line `25`
- `_vibrationEnabled` at line `26`
- sound UI at lines `142-145`
- vibration UI at lines `150-155`

No evidence was found that this screen:

- loads backend notification preferences
- saves backend notification preferences
- triggers OS push configuration
- triggers local notification sound logic

So the screen currently behaves like a local settings mockup, not a real notification preferences client.

## 7.4 Student Flutter type-mapping losses

Key file:

- `lib/models/notifications/api_notification_model.dart`

Student mapping behavior:

- `assignment -> NotificationType.assignment` at `146-147`
- `grade -> NotificationType.course` at `148-149`
- `announcement -> NotificationType.announcement` at `150-151`
- `enrollment -> NotificationType.course` at `152-153`
- `system and everything else -> NotificationType.system` at `154-156`

Category mapping behavior:

- `announcement -> NotificationCategory.system` at `166-167`
- `enrollment -> NotificationCategory.courses` at `168-169`
- unknown types -> system at `170-172`

This is a major fidelity problem. Backend types such as:

- `lab`
- `quiz`
- `material`
- `discussion`
- `deadline`
- `schedule`
- `office_hours`
- `community`
- `message`

are not preserved distinctly in the student Flutter model. Most of them collapse into generic `system`.

Result:

- the backend may generate correct domain-specific notifications
- the Flutter student experience will still present them generically or incorrectly

## 7.5 Instructor Flutter implementation

Key file:

- `lib/screens/instructor/notifications/instructor_notifications_screen.dart`

What is implemented:

- live API fetch
- mark one read
- mark all read
- delete one

Evidence:

- load notifications at `48-54`
- map API model to instructor model at `54`
- mark one read at `137-147`
- delete one at `151-158`
- mark all read at `171-180`

What is missing:

- no realtime socket updates
- no clear read action
- no clear all action
- no backend preferences integration
- no incoming toast/sound behavior
- no explicit navigation via `actionUrl` / related entity

### Instructor type mapping is also lossy

Evidence from `api_notification_model.dart`:

- `assignment -> InstructorNotificationType.submission` at `192-193`
- `grade -> InstructorNotificationType.grading` at `194-195`
- `announcement -> InstructorNotificationType.announcement` at `196-197`
- `enrollment -> InstructorNotificationType.attendance` at `198-199`
- default -> `system` at `200-202`

Again, many backend types collapse incorrectly.

## 7.6 TA Flutter implementation

Key file:

- `lib/screens/ta/notifications/ta_notifications_screen.dart`

### What is implemented

- initial live load from backend notifications API
- delete single attempts backend call
- some mark-read behavior attempts backend call in one code path
- local filters/search/selection/bulk actions

Evidence:

- load notifications at `50-71`
- API fetch at `54-55`
- mapping at `58-60`

### TA mapping is simplified and incomplete

Evidence from `_mapApiToTANotification`:

- `assignment -> submission` at `77-79`
- `grade -> grade` at `80-81`
- `announcement -> announcement` at `82-83`
- `enrollment -> deadline` at `84-85`
- `system/default -> system` at `86-88`

That means TA Flutter also loses backend distinctions for:

- lab
- quiz
- material
- discussion
- office_hours
- schedule
- deadline
- message
- community

### TA mark-read behavior is inconsistent

There are multiple code paths:

- one async path attempts backend mark-as-read around `227-229`
- `_markAsRead(String id)` at `258-280` only mutates local UI state and shows snackbar

Important detail:

- `_markAsRead` toggles `isUnread` locally using `!n.isUnread` at line `271`
- it is not a strict "mark as read"
- if reused on an already-read item, it flips it back to unread locally

This is incorrect relative to backend semantics, because backend supports `mark as read`, not `toggle read state`.

### TA bulk actions are local-only

Evidence:

- bulk actions sheet starts at `475`
- mark all read only mutates local state at `520-540`
- delete all confirmation clears local list only at `614-617`

There is no backend call in these bulk TA Flutter actions.

### TA delete single is partially backed

`_deleteNotification`:

- removes item locally at `282-285`
- then fire-and-forget backend delete at `287-290`

This is better than the bulk actions, but still optimistic without reconciliation.

### TA screen includes non-backend notification concepts

The TA notification page also contains local UI concepts such as:

- AI replies
- archive/bookmark actions
- selection mode
- student/instructor/AI filters

These are not backed by the backend notification model inspected in this audit.

That does not automatically make them bad UI features, but they should not be confused with actual backend notification parity.

## 7.7 Flutter dependencies show unused notification capability

Evidence from `pubspec.yaml`:

- `socket_io_client: ^3.0.2` at line `50`
- `audioplayers: ^6.1.0` at line `71`

Investigation result:

- `socket_io_client` is currently used for chat, not notifications
- `audioplayers` is currently used in voice-to-text code, not notifications

So Flutter already includes packages that could support notification parity, but the notification feature does not currently use them.

---

## 8. Direct Backend vs Website vs Flutter Comparison

## 8.1 Cross-cutting capability matrix

| Capability | Backend | Website | Flutter |
| --- | --- | --- | --- |
| Persisted notifications | Yes | Yes | Yes, partially consumed |
| Unread count endpoint | Yes | Yes | Yes |
| Mark single read | Yes | Yes | Yes |
| Mark all read | Yes | Yes | Yes |
| Delete single | Yes | Yes | Yes |
| Clear read | Yes | Intended yes, but shared route is wrong | Student yes |
| Clear all | Yes | Intended yes, but shared route is wrong | No shared API method |
| Realtime socket delivery | Yes | Yes | No |
| Incoming toast popup | N/A | Yes | No |
| Incoming sound playback | N/A | Not found | No |
| Stored notification preferences | Yes | API exists but UI usage not found | No |
| Role-aware live dashboards | N/A | Yes | Partial |
| Action URL / related entity metadata | Yes | Present in normalized models | Stored but not meaningfully used |
| Scheduled reminders | Yes | Can receive them through normal notifications flow | Can fetch them only if already persisted; no realtime-specific handling |

## 8.2 Notification-type fidelity matrix

This matrix focuses on whether the frontend preserves the backend domain type clearly enough to present or route correctly.

| Backend type | Website | Flutter |
| --- | --- | --- |
| `assignment` | Present | Present |
| `grade` | Present but often remapped into simplified UI categories | Present but student maps to generic course |
| `announcement` | Present, but student page also mixes separate announcements API | Present, but category treatment is weak |
| `lab` | Backend-supported but often collapsed by website role pages | Missing distinct handling |
| `quiz` | Backend-supported but often collapsed by website role pages | Missing distinct handling |
| `material` | Backend-supported but not clearly preserved in role UIs | Missing distinct handling |
| `discussion` | Backend-supported but not clearly preserved in role UIs | Missing distinct handling |
| `enrollment` | Present | Present but often remapped incorrectly |
| `schedule` | Backend-supported | Not clearly preserved | Missing distinct handling |
| `office_hours` | Backend-supported | Not clearly preserved | Missing distinct handling |
| `deadline` | Backend-supported | Partially represented through simplified role mapping | Missing distinct handling |
| `message` | In backend model | Not a strong first-class notification page type in inspected code | Missing distinct handling |
| `community` | In backend model | No clear first-class handling found | Missing distinct handling |

Important conclusion:

- even the website does not preserve all backend types perfectly
- Flutter is substantially worse because its models and role screens collapse many backend types into generic buckets

---

## 9. Role-by-Role Gap Analysis for Flutter

## 9.1 Student Flutter gaps

### Fully or mostly implemented

- fetch notification list
- fetch unread count
- mark single read
- mark all read
- clear read
- delete single

### Partially implemented

- list UI is real, but mixed with local-only AI/system sections
- backend fields exist in models, but action routing is not implemented
- notification categories exist, but domain type fidelity is incomplete
- settings exist visually, but are not connected to backend or device behavior

### Totally missing

- realtime socket connection to `/notifications`
- realtime `newNotification` handling
- realtime unread count updates
- visual incoming alert parity with website toast
- sound playback on incoming notifications
- backend preferences load/save
- backend clear-all action
- proper handling for backend types such as lab, quiz, material, discussion, schedule, office hours, deadline, community, message
- action URL and related entity navigation

### Totally wrong or misleading

- `clearAllNotifications()` assumes backend has no clear-all endpoint, which is incorrect
- AI Insights and System Alerts are presented inside the notifications experience, but they are not backend notifications
- settings screen suggests real push/sound/vibration preference control, but it is only local UI state
- many backend notification types degrade to generic `system`

## 9.2 Instructor Flutter gaps

### Fully or mostly implemented

- load live backend notifications
- mark one read
- mark all read
- delete one

### Partially implemented

- instructor list is backend-backed, but semantic mapping is narrowed
- optimistic actions exist, but there is no realtime or richer navigation handling

### Totally missing

- realtime socket integration
- clear read
- clear all
- preferences load/save
- toast/sound incoming alert parity
- full support for backend types beyond the simplified mapping
- action URL / related entity navigation

### Totally wrong or misleading

- `enrollment` becomes `attendance` in instructor mapping
- many unrelated backend types become generic `system`
- role screen appears more complete than it really is because basic CRUD works, but parity with website/backend is still incomplete

## 9.3 TA Flutter gaps

### Fully or mostly implemented

- initial load from live backend notifications API
- delete single attempts backend sync

### Partially implemented

- TA screen consumes real backend data initially
- some single-item actions touch the backend
- UI is rich, but backend fidelity is weak

### Totally missing

- realtime socket integration
- correct backend-backed mark all read
- correct backend-backed clear all
- preferences load/save
- toast/sound incoming alert parity
- full type support for backend notification categories
- action URL / related entity navigation

### Totally wrong or misleading

- `_markAsRead` is actually a local toggle, not a true mark-read operation
- bulk mark-all-read is local only
- bulk delete-all is local only
- AI/selection/archive/bookmark style affordances are richer than the actual backend sync underneath them

---

## 10. Cross-Cutting Issues That Must Be Treated as High-Risk

## 10.1 Realtime is missing entirely in Flutter

This is one of the biggest gaps.

Backend already emits:

- `newNotification`
- `unreadCountUpdate`

Website already consumes both.

Flutter currently does not consume either. This affects:

- freshness of the notifications list
- unread badge accuracy
- user trust in the feature
- perceived parity with the website

## 10.2 Flutter settings are not real notification settings yet

Student Flutter exposes:

- push
- sound
- vibration
- several notification content toggles

But the actual backend supports a different real preference model:

- email / push / SMS enablement
- email category toggles
- quiet hours
- deadline reminder days

Current Flutter settings therefore have a product-contract gap in addition to an implementation gap.

## 10.3 Flutter models are not aligned with backend notification types

This is a data-model issue, not just a UI issue.

As long as the Flutter mapping layer collapses many backend types into generic categories, the app cannot achieve true parity even if the screens are polished.

## 10.4 Flutter actions are inconsistent by role

Student uses a global cubit.

Instructor uses a separate screen-level live fetch approach.

TA uses another separate screen-level mapping approach with local-only bulk actions.

This fragmentation increases the risk of:

- different semantics by role
- different bugs by role
- duplicated fixes
- future drift

## 10.5 Website defects should not be copied blindly

Important examples:

- wrong `clearAll` / `clearRead` routes in website shared service
- student sound setting without real sound engine
- student notification page mixing notification API and announcement API
- role pages collapsing backend types too aggressively

The website is the closer reference, but not a perfect reference.

---

## 11. Precise Classification of Flutter Issues

## 11.1 Totally missing in Flutter

- notification Socket.IO client for `/notifications`
- subscription to `newNotification`
- subscription to `unreadCountUpdate`
- incoming visual alert behavior comparable to website toast
- incoming sound alert behavior
- backend `clearAll` API support
- backend notification preferences API support
- backend preference load/save flows in UI
- action URL / related entity navigation
- full handling for backend notification types beyond the current narrow mapping
- role-consistent notification semantics across student/instructor/TA

## 11.2 Partially implemented in Flutter

- student notifications list and unread count
- student mark read / mark all read / clear read / delete single
- instructor live notifications list with basic actions
- TA live initial fetch and some single-item sync
- storage of backend fields like `actionUrl` in models without actually using them

## 11.3 Totally wrong or misleading in Flutter

- student clear-all assumption is factually wrong relative to backend
- student settings screen presents fake persistence
- student AI Insights and System Alerts are mixed into notification UX despite not being backend notifications
- student type mapping collapses too many backend types to `system`
- instructor mapping re-labels `enrollment` as `attendance`
- TA `_markAsRead` behaves like a toggle instead of true mark-read
- TA bulk actions are presented as strong notification management but are only local UI actions

---

## 12. Important Differences by Role

## 12.1 Student

Reference experience on website/backend:

- backend generates many student-relevant notifications from academic flows
- website student dashboard has realtime updates and toast alerts
- website student page merges notifications with announcements

Flutter status:

- can fetch stored notifications
- cannot behave like a realtime student notification center
- does not match website dashboard freshness
- does not match website announcement mixing behavior
- does not match backend preference system

## 12.2 Instructor

Reference experience on website/backend:

- backend produces staff-relevant notifications for submissions, reminders, discussions, announcements, office hours, schedule, and role assignment
- website instructor dashboard is realtime-aware
- website instructor page is API-backed with read/delete controls

Flutter status:

- basic list/read/delete exists
- realtime parity does not exist
- semantic type parity does not exist
- advanced controls and routing parity do not exist

## 12.3 TA

Reference experience on website/backend:

- backend produces TA-relevant notifications for submissions, grading reminders, schedule, discussions, announcements, office hours, and role assignment
- website TA dashboard uses realtime hook
- website TA live mode is backend-backed

Flutter status:

- initial live data exists
- many actions are not truly synced
- some semantics are incorrect
- bulk actions are especially behind

---

## 13. Evidence Summary by File

## Backend

- `src/modules/notifications/controllers/notifications.controller.ts`
- `src/modules/notifications/services/notifications.service.ts`
- `src/modules/notifications/notifications.gateway.ts`
- `src/modules/notifications/services/notification-cron.service.ts`
- `src/modules/notifications/entities/notification.entity.ts`
- `src/modules/notifications/entities/notification-preference.entity.ts`
- `src/modules/notifications/enums/index.ts`
- `src/modules/assignments/services/assignments.service.ts`
- `src/modules/labs/services/labs.service.ts`
- `src/modules/quizzes/services/quizzes.service.ts`
- `src/modules/grades/services/grades.service.ts`
- `src/modules/course-materials/services/materials.service.ts`
- `src/modules/announcements/services/announcements.service.ts`
- `src/modules/discussions/services/discussions.service.ts`
- `src/modules/enrollments/services/enrollments.service.ts`
- `src/modules/attendance/services/attendance.service.ts`
- `src/modules/office-hours/services/office-hours.service.ts`
- `src/modules/schedule/services/exam-schedule.service.ts`
- `src/modules/schedule/services/campus-events.service.ts`

## Website

- `src/services/api/notificationService.ts`
- `src/services/notifications/notificationSocket.ts`
- `src/hooks/useNotificationRealtime.ts`
- `src/pages/student-dashboard/components/NotificationCenter.tsx`
- `src/pages/student-dashboard/StudentDashboard.tsx`
- `src/pages/instructor-dashboard/components/NotificationsPage.tsx`
- `src/pages/instructor-dashboard/InstructorDashboard.tsx`
- `src/pages/ta-dashboard/components/NotificationsPage.tsx`
- `src/pages/ta-dashboard/components/LiveModeViews.tsx`
- `src/pages/ta-dashboard/TADashboard.tsx`

## Flutter

- `lib/services/api/notification_api_service.dart`
- `lib/bloc/notifications/notification_cubit.dart`
- `lib/bloc/notifications/notification_state.dart`
- `lib/models/notifications/api_notification_model.dart`
- `lib/models/notifications/notification_model.dart`
- `lib/screens/student/notifications/notifications_screen.dart`
- `lib/screens/student/settings/notifications_settings_screen.dart`
- `lib/screens/instructor/notifications/instructor_notifications_screen.dart`
- `lib/screens/ta/notifications/ta_notifications_screen.dart`
- `lib/widgets/student/notifications/notification_tile.dart`
- `lib/main.dart`
- `pubspec.yaml`

---

## 14. Final Conclusion

The backend already supports a comprehensive notification ecosystem, and the website has implemented a meaningful portion of it, especially around realtime updates and dashboard integration. The Flutter app, however, currently implements only a subset of the notification product.

The biggest Flutter gaps are:

- no realtime notifications
- no backend preference integration
- no clear-all support
- incorrect and lossy type mapping
- role inconsistency
- local-only features presented as if they are real notification behavior

The biggest architectural lesson from this audit is that "notifications" in EduVerse are not a single screen. They are a cross-feature product surface connected to many academic modules. Any later planning should treat this as:

- notification transport and sync
- notification data-model alignment
- role-specific UI parity
- backend preference parity
- event-source coverage across academic features

This report should be used as the audit baseline before creating the actual implementation or fix plan.
