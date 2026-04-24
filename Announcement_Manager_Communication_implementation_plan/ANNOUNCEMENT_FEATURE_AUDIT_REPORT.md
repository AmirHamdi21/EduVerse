# Announcement Feature Audit Report

Date: 2026-04-24  
Scope: backend, website frontend, and Flutter frontend announcement feature comparison

## 1. Scope And Repositories

- Backend: `D:\Graduation\backend\last_backend\EduVerse_Backend`
- Website frontend: `D:\Graduation\frontend_tarek\Eduverse-Frontend`
- Flutter frontend: `D:\Graduation\EduVerse\edu_verse`

This report compares the announcement feature for `student`, `instructor`, `TA`, and `admin` across the three projects and classifies gaps into:

- `Partially implemented`
- `Totally missing`
- `Totally wrong / misleading`
- `Backend mismatch / contract issue`

The goal of this document is to serve as a planning input for later implementation and cleanup work.

## 2. Executive Summary

The announcement feature is not aligned across the backend, website, and Flutter projects.

- The backend provides a single announcement module with CRUD, publish, schedule, pin, and analytics endpoints, but several capabilities are incomplete or misleading in actual implementation.
- The website is currently the richest reference for student announcement consumption because it has:
  - a student dashboard-level announcements page
  - a student course-level announcements tab
  - instructor, TA, and admin announcement management surfaces
- The Flutter project has partial announcement support for all roles, but student support is much weaker than the website and admin support is fragmented into two different systems.
- The biggest student gap is that Flutter has no equivalent to the website’s new student sidebar `Announcements` tab/page.
- The biggest backend gap is that pinning is effectively not implemented, scheduling is stored incorrectly, target audience is not enforced in listing, and `findOne()` is reused in ways that inflate view counts and bypass proper authorization.
- The biggest admin Flutter issue is that there are two separate admin announcement implementations:
  - an API-backed `/admin/announcements` manager
  - a separate local-only admin notifications announcement system that incorrectly assumes no backend endpoint exists

## 3. Source Inventory

### Backend

- [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:44)
- [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:106)
- [announcement.entity.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/entities/announcement.entity.ts:14)
- [create-announcement.dto.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/dto/create-announcement.dto.ts:5)
- [target-audience.enum.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/enums/target-audience.enum.ts:1)

### Website frontend

- [announcementService.ts](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/services/api/announcementService.ts:17)
- [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:193)
- [student Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:18)
- [student CourseView.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/pages/CourseView.tsx:222)
- [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:287)
- [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:149)
- [TADashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/TADashboard.tsx:816)
- [LiveModeViews.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/components/LiveModeViews.tsx:517)

### Flutter frontend

- [communication_service.dart](D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:17)
- [app_router.dart](D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:854)
- [materials announcement_model.dart](D:/Graduation/EduVerse/edu_verse/lib/models/materials/announcement_model.dart:70)
- [instructor announcement_model.dart](D:/Graduation/EduVerse/edu_verse/lib/models/instructor/announcement_model.dart:48)
- [course_tabs.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/course_tabs.dart:34)
- [announcements_tab_content.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:24)
- [course_detail_bloc.dart](D:/Graduation/EduVerse/edu_verse/lib/features/courses/bloc/course_detail/course_detail_bloc.dart:691)
- [course_detail_screen.dart](D:/Graduation/EduVerse/edu_verse/lib/features/courses/screens/course_detail_screen.dart:334)
- [AnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:301)
- [TAAnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/ta/announcements/ta_announcement_manager_screen.dart:318)
- [AdminAnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/admin/announcements/admin_announcement_manager_screen.dart:301)
- [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:401)
- [announcement_card.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_card.dart:114)
- [admin_notification_cubit.dart](D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:32)
- [admin_notifications_screen.dart](D:/Graduation/EduVerse/edu_verse/lib/screens/admin/notifications/admin_notifications_screen.dart:588)

## 4. Backend Baseline: What Actually Exists

### 4.1 Endpoints and intended role coverage

| Endpoint | Controller role guard | Actual service behavior |
| --- | --- | --- |
| `GET /api/announcements` | authenticated users | role-filtered listing |
| `POST /api/announcements` | instructor, TA, admin, it_admin | create announcement |
| `GET /api/announcements/:id` | authenticated users | returns announcement and increments view count |
| `PUT /api/announcements/:id` | instructor, TA, admin, it_admin | owner or admin only |
| `DELETE /api/announcements/:id` | instructor, TA, admin, it_admin | owner or admin only |
| `PATCH /api/announcements/:id/publish` | instructor, TA, admin, it_admin | owner or admin only |
| `PATCH /api/announcements/:id/schedule` | instructor, TA, admin, it_admin | owner or admin only |
| `PATCH /api/announcements/:id/pin` | instructor, admin, it_admin | instructor or admin only, but no persistence |
| `GET /api/announcements/:id/analytics` | instructor, TA, admin, it_admin | admin, instructor, or owner |

Evidence:

- [controller endpoint definitions](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:44)
- [service implementations](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:106)

### 4.2 Backend announcement data model

The backend entity currently stores:

- `courseId`
- `createdBy`
- `title`
- `content`
- `announcementType`
- `priority`
- `targetAudience`
- `isPublished`
- `publishedAt`
- `expiresAt`
- `attachmentFileId`
- `viewCount`
- timestamps
- relations to `author` and `course`

Evidence: [announcement.entity.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/entities/announcement.entity.ts:14)

### 4.3 Backend capabilities that are real

- Role-based listing exists in `findAll()` with different behavior for admin, student, and instructor/TA.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:106)
- `targetAudience`, `expiresAt`, and `attachmentFileId` exist in the DTO and entity.  
  Evidence: [create-announcement.dto.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/dto/create-announcement.dto.ts:30), [announcement.entity.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/entities/announcement.entity.ts:46)
- Analytics endpoint exists, but only returns very basic fields.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:328)

## 5. Backend Mismatches And Defects That Affect Planning

These are important because any frontend parity work will fail or become misleading if they are ignored.

### B-01: Pinning is exposed by the API but not implemented in the schema

Classification: `Backend mismatch / contract issue`

- The controller exposes a pin endpoint and the docs say pinned announcements should appear first.  
  Evidence: [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:53), [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:203)
- The service explicitly says pinning is a no-op because the `is_pinned` column does not exist.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:306)
- The entity has no `isPinned` field at all.  
  Evidence: [announcement.entity.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/entities/announcement.entity.ts:14)

Impact:

- Website and Flutter both show pin/unpin UI that appears functional.
- Users can trigger pin actions that do not persist.
- Any frontend sorting by pinned status is unreliable.

### B-02: Scheduling is stored in the wrong field

Classification: `Backend mismatch / contract issue`

- The service stores `scheduledAt` into `expiresAt` as a workaround.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:283)
- The entity has `expiresAt` but no `scheduledAt`.  
  Evidence: [announcement.entity.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/entities/announcement.entity.ts:57)

Impact:

- Frontends cannot reliably distinguish expiration from scheduled publication.
- Student UIs that display `expiresAt` may accidentally show scheduled publication as an expiration date.

### B-03: `findOne()` has no role-based access check

Classification: `Backend mismatch / contract issue`

- `findOne()` only fetches by `id` and increments the view count. It does not verify whether the current user is allowed to access that announcement.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:183)

Impact:

- Any authenticated user may be able to read announcement details if they know or guess an ID.

### B-04: View counts are inflated by non-read actions

Classification: `Backend mismatch / contract issue`

- `findOne()` increments `viewCount`.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:193)
- `update()`, `remove()`, `publish()`, `schedule()`, `togglePin()`, and `getAnalytics()` all call `findOne()` first.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:224), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:249), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:265), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:287), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:310), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:328)

Impact:

- View counts do not represent student reads only.
- Admin/instructor/TA maintenance operations increase view counts.
- Opening analytics also increases view counts.

### B-05: `targetAudience` exists but is not enforced in listing

Classification: `Backend mismatch / contract issue`

- The entity and DTO support `targetAudience`.  
  Evidence: [announcement.entity.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/entities/announcement.entity.ts:46), [create-announcement.dto.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/dto/create-announcement.dto.ts:48)
- `findAll()` filters by role, course, type, priority, and published state, but not by target audience.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:144)

Impact:

- A frontend may believe an announcement is audience-scoped while the backend still returns it broadly.

### B-06: API docs and actual behavior disagree for TA permissions

Classification: `Backend mismatch / contract issue`

- Delete docs say TAs cannot delete, but the service allows any owner or admin.  
  Evidence: [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:139), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:249)
- Publish and schedule docs mention owner instructor or admin, but the controller and service allow TA owners.  
  Evidence: [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:154), [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:176), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:265), [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:287)

Impact:

- The website and Flutter may implement the wrong permission model depending on whether they follow controller docs or observed behavior.

### B-07: Listing docs promise pinned-first sorting, but service does not do that

Classification: `Backend mismatch / contract issue`

- Controller docs say pinned announcements appear first.  
  Evidence: [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:53)
- Service orders only by `createdAt DESC`.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:158)

### B-08: Analytics endpoint is minimal

Classification: `Partially implemented`

- The backend analytics response contains only `announcementId`, `title`, `viewCount`, `isPublished`, `publishedAt`, `createdAt`.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:338)

Impact:

- No delivery stats, no read rate, no per-role breakdown, no audience reach, no attachment interactions.

## 6. Website vs Flutter Gap Analysis By Role

## 6.1 Student

### Website student implementation

The website has two student announcement surfaces.

#### Student Surface A: global dashboard-level announcements page

- The student sidebar includes a dedicated `Announcements` tab under the communication group.  
  Evidence: [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:193)
- Clicking a tab navigates to `/studentdashboard/${tabId}`.  
  Evidence: [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:257)
- The `announcements` tab renders the `Announcements` page component.  
  Evidence: [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:430)

#### Student Surface B: course-level announcements tab

- Course view includes an `announcements` tab.  
  Evidence: [CourseView.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/pages/CourseView.tsx:992)
- It loads announcements for the selected course and performs a defensive client-side course filter because the backend may ignore `courseId`.  
  Evidence: [CourseView.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/pages/CourseView.tsx:222)
- It sorts pinned first, then by newest published/created date.  
  Evidence: [CourseView.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/pages/CourseView.tsx:242)

### Flutter student implementation

- Student course details include an `Announcements` tab.  
  Evidence: [course_tabs.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/course_tabs.dart:34)
- Flutter fetches course announcements through the BLoC and sorts only by date.  
  Evidence: [course_detail_bloc.dart](D:/Graduation/EduVerse/edu_verse/lib/features/courses/bloc/course_detail/course_detail_bloc.dart:691)
- Flutter renders a basic announcement list card inside `AnnouncementsTabContent`.  
  Evidence: [announcements_tab_content.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:60)
- Flutter also shows a smaller `Latest Announcements` preview in course details, limited to the first 3 announcements.  
  Evidence: [course_detail_screen.dart](D:/Graduation/EduVerse/edu_verse/lib/features/courses/screens/course_detail_screen.dart:334)
- There is no student global announcement route in the router. Only instructor, TA, and admin announcement routes were found.  
  Evidence: [app_router.dart](D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:854)

### Student findings

| ID | Classification | Finding |
| --- | --- | --- |
| STU-01 | `Totally missing` | Flutter has no equivalent to the website student sidebar announcement tab/page. |
| STU-02 | `Partially implemented` | Flutter supports only course-level announcements, while the website supports both global and course-level announcement consumption. |
| STU-03 | `Partially implemented` | Flutter course list sorts by date only; website course list sorts pinned first, then date. |
| STU-04 | `Totally missing` | Flutter student course cards do not show pin badge, author, course badge, views, or time-of-day metadata shown on the website global page. |
| STU-05 | `Partially implemented` | Flutter course cards show full content only; website course tab has `Read more` / `Show less`. |
| STU-06 | `Totally missing` | Flutter has no search field and no cross-course filter chips for announcements. |
| STU-07 | `Totally wrong / misleading` | Flutter treats `expiresAt` as an expiry label, but backend scheduling currently reuses `expiresAt` for scheduled publication. |
| STU-08 | `Totally wrong / incomplete` | Flutter priority styling does not special-case `urgent`, while website global page does. |

#### STU-01 details

- Website global student announcement page exists in [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:207) and [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:18).
- Flutter router exposes only:
  - [instructor route](D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:855)
  - [TA route](D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:859)
  - [admin route](D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:863)
- No student route or student dashboard-level announcement page was found in Flutter.

#### STU-03 details

- Website course view sorts pinned first and then newest first.  
  Evidence: [CourseView.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/pages/CourseView.tsx:242)
- Flutter sorts only by `publishedAt ?? createdAt`.  
  Evidence: [announcements_tab_content.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:24), [course_detail_bloc.dart](D:/Graduation/EduVerse/edu_verse/lib/features/courses/bloc/course_detail/course_detail_bloc.dart:703)

#### STU-04 details

Website global page card includes:

- pinned badge  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:149)
- course badge (`course.code` or `General`)  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:154)
- priority badge with urgent/high handling  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:157)
- author information  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:170)
- publication date  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:181)
- publication time  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:189)
- view count  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:196)

Flutter student card includes only:

- title
- content
- priority chip
- published date
- optional `Expires`

Evidence: [announcements_tab_content.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:60)

#### STU-07 details

- Flutter displays `Expires ${date}` if `expiresAt` exists.  
  Evidence: [announcements_tab_content.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/student/course_details/announcements_tab_content.dart:175)
- Backend currently stores `scheduledAt` into `expiresAt`.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:296)

This means a scheduled announcement may appear to students as if it has an expiration date instead of a scheduled publication date.

## 6.2 Instructor

### Website instructor implementation

- Instructor has a dedicated announcement manager page.  
  Evidence: [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:360)
- It supports create, edit, delete, publish, pin, search, and status filtering.  
  Evidence: [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:287), [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:419), [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:443), [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:545)
- The create/edit modal contains:
  - title
  - content
  - course
  - priority
  - publish immediately
  Evidence: [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:582)

### Flutter instructor implementation

- Flutter instructor has a dedicated API-backed announcement manager.  
  Evidence: [AnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:301)
- Flutter service already wraps schedule and analytics endpoints.  
  Evidence: [communication_service.dart](D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:88), [communication_service.dart](D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:104)
- Flutter manager includes a `scheduled` filter and scheduling flow.  
  Evidence: [AnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:315)
- Flutter shared form includes advanced UI that the website does not have:
  - AI writing assistant
  - schedule section
  - attachments area
  Evidence: [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:527), [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:730), [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:890)

### Instructor findings

| ID | Classification | Finding |
| --- | --- | --- |
| INS-01 | `Partially implemented` | Flutter instructor UI is richer than the website for scheduling, but the backend scheduling model is broken, so the feature cannot round-trip correctly. |
| INS-02 | `Totally wrong / misleading` | Flutter shows pin actions even though backend pinning is a no-op. |
| INS-03 | `Totally wrong / misleading` | Flutter analytics dialog is mock/generated instead of using the real analytics endpoint. |
| INS-04 | `Partially implemented` | Flutter form shows attachments UI, but there is no actual attachment upload/integration flow. |
| INS-05 | `Partially implemented` | Backend supports `targetAudience`, `announcementType`, `expiresAt`, and `attachmentFileId`, but neither website instructor flow nor Flutter instructor save flow sends all of them. |
| INS-06 | `Totally wrong / misleading` | Scheduled announcements are mapped back into Flutter as `draft`, not `scheduled`. |
| INS-07 | `Website missing feature` | Website instructor manager does not expose schedule or analytics at all, even though Flutter service and backend endpoints exist. |

#### INS-03 details

- Flutter service has a real analytics method.  
  Evidence: [communication_service.dart](D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:105)
- The instructor manager uses a fabricated analytics insight string rather than the backend analytics endpoint.  
  Evidence: [AnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:220)

#### INS-04 details

- The form stores local attachment names in `_attachments`.  
  Evidence: [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:42)
- The UI says `Add Files`.  
  Evidence: [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:907)
- The save logic in the instructor screen sends only `title`, `content`, `priority`, and optional `courseId`.  
  Evidence: [AnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/announcements/announcement_manager_screen.dart:301)

#### INS-06 details

- Flutter maps API data to `published` if `isPublished == 1`, otherwise `draft`.  
  Evidence: [instructor announcement_model.dart](D:/Graduation/EduVerse/edu_verse/lib/models/instructor/announcement_model.dart:48)
- The model ignores the backend scheduling workaround entirely.

## 6.3 TA

### Website TA implementation

- TA dashboard loads live announcements from the API in non-mock mode.  
  Evidence: [TADashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/TADashboard.tsx:665)
- TA can create, publish, update, pin, and delete announcements from the live page.  
  Evidence: [TADashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/TADashboard.tsx:816)
- Live TA announcement page shows a `pinDisabledReason` banner.  
  Evidence: [LiveModeViews.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/components/LiveModeViews.tsx:517)
- But the same page still shows a working `Pin/Unpin` action in the item menu.  
  Evidence: [LiveModeViews.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/components/LiveModeViews.tsx:635)
- TA create/edit modal is minimal: title, course, message only.  
  Evidence: [LiveModeViews.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/components/LiveModeViews.tsx:700)

### Flutter TA implementation

- Flutter TA manager is very close to the instructor manager and includes scheduling, pinning, analytics, and delete actions.  
  Evidence: [TAAnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/ta/announcements/ta_announcement_manager_screen.dart:318), [TAAnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/ta/announcements/ta_announcement_manager_screen.dart:392)

### TA findings

| ID | Classification | Finding |
| --- | --- | --- |
| TA-01 | `Totally wrong / misleading` | Website live TA page warns that pinning is disabled, but still exposes the pin action. |
| TA-02 | `Totally wrong / misleading` | Flutter TA page exposes pin actions even though backend pinning is restricted for TA and is a backend no-op anyway. |
| TA-03 | `Backend mismatch / contract issue` | Backend docs say TAs cannot delete announcements, but service allows TA owners to delete. |
| TA-04 | `Partially implemented` | Website TA create form is smaller than Flutter TA form, but both are still missing true attachment flow, true analytics integration, and reliable schedule persistence. |
| TA-05 | `Totally wrong / misleading` | Flutter TA analytics is mock/generated rather than backed by the announcement analytics endpoint. |

#### TA-01 details

- Warning banner: [LiveModeViews.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/components/LiveModeViews.tsx:517)
- Pin action still available: [LiveModeViews.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/components/LiveModeViews.tsx:635)

#### TA-03 details

- Controller docs say TAs cannot delete.  
  Evidence: [announcements.controller.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/controllers/announcements.controller.ts:141)
- Service actually allows any owner or admin to delete.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:249)

## 6.4 Admin

### Website admin implementation

- Website admin announcement UI is inside a broader communication page, not a dedicated announcement manager.  
  Evidence: [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:149)
- The UI exposes:
  - publish immediately
  - target audience selection
  - notification channels
  - broadcast preview
  - recent broadcasts list with edit, publish, pin, delete
  Evidence: [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:368), [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:467)

### Flutter admin implementation

Flutter currently has two admin announcement systems:

#### Admin System A: API-backed admin announcement manager

- Route exists at `/admin/announcements`.  
  Evidence: [app_router.dart](D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:863)
- Screen loads announcements from backend and saves through the API.  
  Evidence: [AdminAnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/admin/announcements/admin_announcement_manager_screen.dart:72), [AdminAnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/admin/announcements/admin_announcement_manager_screen.dart:301)

#### Admin System B: local-only admin notifications announcement tab

- The cubit explicitly says announcements remain local-only and generates mock announcements.  
  Evidence: [admin_notification_cubit.dart](D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:32), [admin_notification_cubit.dart](D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:186)
- The admin notifications screen shows a `New Announcement` FAB that writes into that local-only system.  
  Evidence: [admin_notifications_screen.dart](D:/Graduation/EduVerse/edu_verse/lib/screens/admin/notifications/admin_notifications_screen.dart:588)

### Admin findings

| ID | Classification | Finding |
| --- | --- | --- |
| ADM-01 | `Totally wrong / misleading` | Flutter has two different admin announcement systems, and one of them is local-only even though a backend announcement API exists. |
| ADM-02 | `Totally wrong / misleading` | Flutter shared admin target-audience options do not match the backend enum. |
| ADM-03 | `Totally wrong / misleading` | Flutter admin can send `targetAudience: 'admins'`, but backend enum does not define `admins`. |
| ADM-04 | `Partially implemented` | Website admin UI exposes audience, channels, and scheduling ideas, but the save flow ignores most of them when calling the announcement API. |
| ADM-05 | `Totally wrong / misleading` | Website admin announcement loading assumes array response and can drop paginated backend results. |
| ADM-06 | `Totally wrong / misleading` | Flutter admin form exposes notification channels and attachments UI, but they are not persisted through the backend announcement flow. |
| ADM-07 | `Totally wrong / misleading` | Flutter and website both show pin actions for admin, but backend pinning still does not persist. |

#### ADM-01 details

- API-backed path exists: [app_router.dart](D:/Graduation/EduVerse/edu_verse/lib/config/app_router.dart:863)
- Local-only path assumption exists in:
  - [admin_notification_cubit.dart](D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:32)
  - [admin_notification_cubit.dart](D:/Graduation/EduVerse/edu_verse/lib/bloc/admin_notifications/admin_notification_cubit.dart:186)

This is not just duplication. It is conceptually wrong because one part of the app assumes no backend admin announcement support exists while another part already uses it.

#### ADM-02 and ADM-03 details

- Flutter shared form audience options are:
  - `all`
  - `students`
  - `instructors`
  - `admins`
  Evidence: [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:1046)
- Backend enum is:
  - `all`
  - `students`
  - `instructors`
  - `tas`
  - `custom`
  Evidence: [target-audience.enum.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/enums/target-audience.enum.ts:1)
- Flutter admin API-backed save flow forwards `targetAudience` if present.  
  Evidence: [AdminAnnouncementManagerScreen](D:/Graduation/EduVerse/edu_verse/lib/screens/admin/announcements/admin_announcement_manager_screen.dart:305)

Impact:

- Flutter admin can send an invalid backend value.
- Flutter admin cannot choose valid backend values `tas` and `custom`.

#### ADM-04 details

- Website admin save flow sends only `title`, `content`, optional `courseId`, and `priority`, then optionally publishes.  
  Evidence: [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:149)
- The same page exposes audience and channels UI, but these values are not passed to the announcement API.  
  Evidence: [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:376), [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:412)

#### ADM-05 details

- Website admin announcement loading uses `setAnnouncements(Array.isArray(response) ? response : [])`.  
  Evidence: [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:105)
- Backend listing is paginated object `{ data, meta }`.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:165)

Impact:

- The admin website can display zero announcements even when the backend returns valid paginated data.

## 7. Website Student Sidebar Announcement Page: Detailed Functional Specification

This section is intentionally detailed because this page does not currently exist in the student Flutter project and will be important for later planning.

### 7.1 Location and navigation

- The page is exposed through the student dashboard sidebar.
- Sidebar item:
  - `id: 'announcements'`
  - `label: 'Announcements'`
  - `icon: Megaphone`
  - `group: 'groupCommunication'`
  Evidence: [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:207)
- Student tab changes navigate to `/studentdashboard/${tabId}`.  
  Evidence: [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:257)
- When the active tab becomes `announcements`, the page renders `<Announcements />`.  
  Evidence: [StudentDashboard.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/StudentDashboard.tsx:430)

### 7.2 Data source behavior

- The page calls `announcementService.getAnnouncements()` on mount.  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:27)
- It accepts either:
  - direct array
  - paginated object with `data`
- It stores the normalized result into local state.  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:30)

Important implementation notes:

- There is no explicit pagination UI.
- There is no explicit refetch on search/filter; filtering is client-side after the initial fetch.
- There is no item detail page.
- There is no mark-as-read action.
- There is no explicit sorting in the component after fetch, so display order currently depends on backend response order.

### 7.3 Header

- Title: `Announcements`
- Subtitle: `Latest updates and important notices from your instructors`

Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:73)

### 7.4 Filter area

The page has a combined filter section with:

- search input
- course chips

Search details:

- placeholder: `Search announcements...`
- bound to `searchTerm`
- client-side text filtering

Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:83)

Course filter chip details:

- first chip is always `All Courses`
- remaining chips are generated from courses present in the loaded announcements
- the list is derived from announcement payload, not from a dedicated course endpoint

Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:96)

Important planning detail:

- If a student is enrolled in a course that currently has no loaded announcements, that course will not appear as a chip on this page because the chip source is derived from the announcement list itself.

### 7.5 Loading state

- Centered spinner
- text: `Loading announcements...`

Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:124)

### 7.6 Empty states

The component has two empty-state messages:

- when filters are active:
  - `We couldn't find any announcements matching your current filters.`
- when filters are not active:
  - `There are no announcements for your courses at the moment.`

Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:129)

### 7.7 Announcement card layout

Each card includes the following elements.

#### Top badges

- optional `Pinned` badge if `announcement.isPinned === 1`  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:149)
- course badge:
  - uses `announcement.course?.code`
  - falls back to `General`
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:154)
- priority badge:
  - `urgent` => red
  - `high` => orange
  - otherwise neutral styling
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:157)

#### Main content

- title
- full content body
- content is not truncated
- no `Read more` / `Show less` in this global page

Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:166), [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:202)

#### Metadata row

- author:
  - full name from `firstName lastName`
  - fallback `Instructor`
- date:
  - based on `publishedAt || createdAt`
- time:
  - based on `publishedAt || createdAt`
- views:
  - `announcement.viewCount ?? 0`

Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:170)

### 7.8 Scope difference from student course tab

The dashboard-level student announcement page is not the same as the course-level announcement tab.

Dashboard-level page characteristics:

- aggregates all announcements visible to the student
- supports cross-course filtering
- shows course badge and author
- behaves like a central announcement inbox

Course-level tab characteristics:

- is scoped to one course
- uses pinned-first sorting
- truncates long content to 3 lines by default
- offers `Read more` / `Show less`
- has a simpler layout

Evidence: [CourseView.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/pages/CourseView.tsx:1159)

### 7.9 Flutter parity status for this page

Flutter currently has none of the following as a student dashboard feature:

- global student announcement route
- sidebar entry for student announcements
- global announcement list screen
- search input for announcements
- cross-course filter chips
- global aggregated student announcements view
- card layout with author, course badge, time, view count, pinned badge

This page is therefore `totally missing` in Flutter.

## 8. Cross-Cutting Frontend/Backend Mismatches

### X-01: Website and Flutter UIs assume `isPinned` exists as real persisted data

- Website uses `isPinned` in multiple places.  
  Evidence: [Announcements.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/components/Announcements.tsx:149), [CourseView.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/student-dashboard/pages/CourseView.tsx:243), [AnnouncementsManager.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/instructor-dashboard/components/AnnouncementsManager.tsx:443), [LiveModeViews.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/ta-dashboard/components/LiveModeViews.tsx:552), [CommunicationPage.tsx](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/pages/admin-dashboard/components/CommunicationPage.tsx:522)
- Flutter also assumes `isPinned` is real persisted state.  
  Evidence: [materials announcement_model.dart](D:/Graduation/EduVerse/edu_verse/lib/models/materials/announcement_model.dart:117), [announcement_card.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_card.dart:114)
- Backend pin is currently a no-op.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:319)

### X-02: Website service and backend response shape are not fully aligned

- Website service types `getAnnouncements()` as `Announcement[]`.  
  Evidence: [announcementService.ts](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/services/api/announcementService.ts:59)
- Backend returns paginated `{ data, meta }`.  
  Evidence: [announcements.service.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/services/announcements.service.ts:165)

Result:

- Some website pages normalize manually.
- Some website pages do not.
- Behavior is inconsistent across roles.

### X-03: Flutter service is ahead of the website service, but the UI does not consistently use that advantage

- Flutter service already wraps:
  - schedule
  - pin
  - analytics
  Evidence: [communication_service.dart](D:/Graduation/EduVerse/edu_verse/lib/services/api/communication_service.dart:88)
- Website service does not wrap schedule or analytics.  
  Evidence: [announcementService.ts](D:/Graduation/frontend_tarek/Eduverse-Frontend/src/services/api/announcementService.ts:57)

Result:

- Flutter has some advanced UI ideas.
- But because backend contract issues remain unresolved, those UI ideas are only partially real.

### X-04: Attachment support is not end-to-end in either frontend

- Backend supports only `attachmentFileId` metadata.  
  Evidence: [create-announcement.dto.ts](D:/Graduation/backend/last_backend/EduVerse_Backend/src/modules/announcements/dto/create-announcement.dto.ts:65)
- Flutter form exposes attachment UI but does not upload real files.  
  Evidence: [announcement_form_dialog.dart](D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/announcements/announcement_form_dialog.dart:890)
- Website announcement UIs do not expose a real attachment workflow.

## 9. Planning-Ready Issue Inventory

These are the most important implementation topics to keep in mind when creating the actual fix plan later.

### Highest priority structural items

1. Fix backend contract truth first:
   - real `isPinned`
   - real `scheduledAt`
   - correct authorization in `findOne()`
   - stop inflating `viewCount`
   - decide final TA permission model
   - enforce `targetAudience`
2. Add the missing Flutter student global announcements feature:
   - route
   - entry point
   - page
   - list aggregation
   - search and course filters
   - card metadata parity
3. Remove or replace the local-only Flutter admin announcement system.
4. Align admin target-audience values across backend, website, and Flutter.
5. Decide which advanced features are truly supported end-to-end:
   - scheduling
   - pinning
   - analytics
   - attachments
   - notification channels

### Roles most affected right now

- `Student`: most visible missing functionality in Flutter.
- `Admin`: most inconsistent implementation in Flutter.
- `TA`: most confusing permission model across docs, backend behavior, website, and Flutter.

## 10. Final Conclusion

If the website is used as the main UX reference, the Flutter project is currently:

- `student`: clearly behind, because the student dashboard-level announcements page is entirely missing
- `instructor`: partially implemented, but with several misleading advanced features
- `TA`: partially implemented but permission handling is inconsistent and misleading
- `admin`: partially implemented in one place and totally wrong in another because of the duplicate local-only system

If the backend is used as the source of truth, then both website and Flutter currently contain UI that over-promises features that the backend does not yet fully support, especially pinning, scheduling, audience targeting, and trustworthy analytics.
