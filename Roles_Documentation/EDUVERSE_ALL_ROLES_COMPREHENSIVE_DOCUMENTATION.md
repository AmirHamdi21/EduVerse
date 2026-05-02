# EduVerse — Whole Project Comprehensive Documentation (All Roles)

> **Location:** `Roles_Documentation/EDUVERSE_ALL_ROLES_COMPREHENSIVE_DOCUMENTATION.md`  
> **Generated:** 2026-05-02 18:35:01  
> **Repository:** `AmirHamdi21/EduVerse`  
> **Branch:** `Instructor_TA_courses_redesign`

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Project Purpose and Product Vision](#project-purpose-and-product-vision)
3. [System Architecture Deep Dive](#system-architecture-deep-dive)
4. [Authentication, Authorization, and Role Model](#authentication-authorization-and-role-model)
5. [Cross-Role Shared Capabilities](#cross-role-shared-capabilities)
6. [Role-by-Role Comprehensive Documentation](#role-by-role-comprehensive-documentation)
7. [Complete Route Catalog by Role](#complete-route-catalog-by-role)
8. [State Management Inventory](#state-management-inventory)
9. [API Service Layer Inventory](#api-service-layer-inventory)
10. [Data, Workflow, and UX State Patterns](#data-workflow-and-ux-state-patterns)
11. [Implementation Maturity and Known Gaps](#implementation-maturity-and-known-gaps)
12. [Per-Feature Documentation Index (Generated Files)](#per-feature-documentation-index-generated-files)
13. [Engineering Recommendations and Next Milestones](#engineering-recommendations-and-next-milestones)
14. [Appendices](#appendices)

---

## Executive Summary

EduVerse is a **multi-role, AI-augmented Learning Management System** implemented in Flutter/Dart with a feature-driven structure. The platform unifies academic delivery, communication, assessment, analytics, and operational governance for the following roles:

- `student`
- `instructor`
- `teaching_assistant`
- `admin`
- `it_admin`

The product uses role-specific screens and routes with shared infrastructure for messaging, discussion, profile, settings, localization, and theming. It supports a wide functional spectrum:

- Student learning workflows (courses, assignments, labs, quizzes, grades, attendance, AI study tools).
- Instructor teaching operations (course management, grading, roster, attendance, reports, announcements, quiz management).
- TA support workflows (assigned-course execution, grading support, lab oversight, analytics).
- Admin governance workflows (users, roles, courses, departments, security, integrations, backups, institutional settings).
- IT Admin technical operations (health monitoring, incidents, infrastructure, API/database/cloud configuration, logs, alerts).

### Snapshot Metrics (Codebase-Derived)
| Area | Count |
|---|---|
| Total Distinct Routes (router paths) | 206 |
| Student Screen Files | 64 |
| Instructor Screen Files | 36 |
| TA Screen Files | 32 |
| Admin Screen Files | 49 |
| IT Admin Screen Files | 19 |
| Auth Screen Files | 5 |
| Shared Screen Files | 9 |
| BLoC/Cubit Files | 99 |
| API Service Files | 26 |
| Student Per-Feature Docs | 54 |
| Instructor Per-Feature Docs | 34 |
| TA Per-Feature Docs | 30 |

---

## Project Purpose and Product Vision

EduVerse is designed as a **single digital campus platform** where every educational stakeholder operates within one coherent environment, while each role still receives context-specific tools and permissions.  

The vision is to avoid fragmented systems (one for teaching, one for communication, one for attendance, one for administration) by consolidating:

1. **Academic execution:** course delivery, assessment, grading, attendance.
2. **Learning augmentation:** AI chat, summarization, quiz generation, flashcards, voice transcription.
3. **Institutional governance:** user/role administration, auditing, policy controls, enrollment windows.
4. **Technical reliability:** system health, backups, logs, integration and API management.

### Product Principles
- **Role-first UX:** each user sees the right dashboard and action surface.
- **Shared foundation:** common infrastructure for auth, navigation, messaging, localization, theming.
- **State clarity:** explicit loading/success/error transitions.
- **Scalable organization:** feature modules with screen/bloc/service separation.
- **Operational maturity:** admin and IT admin roles for governance + runtime reliability.

---

## System Architecture Deep Dive

### Repository and Runtime Architecture

EduVerse follows a **feature-oriented Flutter architecture**:

- `lib/screens/**` for role-oriented UI and feature pages.
- `lib/bloc/**` for feature state orchestration.
- `lib/services/api/**` for domain-specific API interaction.
- `lib/config/app_router.dart` for navigation topology.
- `lib/services/auth_role_resolver.dart` for role normalization and route decisions.

### Layer Responsibilities

#### 1) Presentation Layer (Screens + Widgets)
- Role-segregated screen trees (`student`, `instructor`, `ta`, `admin`, `it_admin`).
- Shared screens for cross-role interactions (messaging/discussion/profile).
- Role-specific widget libraries for dashboard cards, list rows, tiles, and forms.

#### 2) State Layer (BLoC/Cubit)
- Event/state-driven flows for asynchronous domains (attendance, assignments, quizzes, discussions).
- Cubit-driven flows for simpler state containers (settings/preferences).
- Route-aware data loading and refresh behavior.

#### 3) Service Layer
- Central API client and interceptors.
- Domain services (courses, assignments, grades, attendance, notifications, discussion, enrollment, materials).
- Encapsulated request/retry/response parsing behavior.

#### 4) Domain/Data Layer
- DTO-style models and enums under `lib/models/**`.
- Feature-specific state models under bloc modules.
- Derived view models produced per screen.

### Why this architecture fits EduVerse
- Multi-role LMS products naturally require modular separation.
- Role-specific navigation and state can evolve without breaking unrelated surfaces.
- Shared infrastructure avoids duplicated logic in messaging/auth/settings.
- It supports incremental hardening from mock/placeholder data to full API parity.

---

## Authentication, Authorization, and Role Model

### Role Definitions (from `auth_role_resolver.dart`)
The resolver establishes canonical role strings:

- `student`
- `instructor`
- `teaching_assistant`
- `admin`
- `it_admin`

### Dashboard Routing Policy
Authenticated users are redirected by role precedence:
1. IT Admin -> `/it-admin/dashboard`
2. Admin -> `/admin/dashboard`
3. Instructor -> `/instructor/dashboard`
4. TA -> `/ta/dashboard`
5. Student -> `/dashboard`

### Route Access Policy (simplified)
- `/it-admin/**` -> IT Admin only
- `/admin/**` -> Admin only
- `/instructor/**` -> Instructor only
- `/ta/**` -> TA only
- `/messages/**` -> all authenticated roles
- default non-prefixed protected routes -> student role

### Role Normalization
The resolver maps aliases:
- `ta` -> `teaching_assistant`
- `it`, `it-admin` -> `it_admin`

This normalization prevents role-name drift and makes external identity inputs more resilient.

---

## Cross-Role Shared Capabilities

### 1) Messaging and Communication Fabric
- Shared chat screen architecture with profile/group views.
- New conversation flows and message thread navigation.
- Swipe-action customization available through settings.

### 2) Discussion Ecosystem
- Course/threaded discussions exist across academic roles.
- Role-specific moderation and participation responsibilities vary by route scope.

### 3) Identity and Account Surfaces
- Profile and edit-profile patterns appear for all primary authenticated roles.
- Settings categories are role-specific but follow shared interaction paradigms.

### 4) Internationalization and Theme
- English/Arabic localization support.
- Runtime theme mode controls with role-oriented visual identity.

### 5) Common Non-Functional UX Patterns
- Pull-to-refresh and explicit loading states.
- Empty-state affordances for low-content contexts.
- Error pathways with retriable behavior where possible.

---

## Role-by-Role Comprehensive Documentation

## Student Role

### Mission
The student role focuses on **learning execution and progress visibility**: consume content, submit work, monitor performance, communicate with teaching staff, and use AI acceleration tools.

### Core Student Feature Domains
1. **Academic Core:** courses, details, registration, assignments, labs, quizzes.
2. **Performance Core:** grades, analysis, attendance.
3. **Productivity Core:** dashboard, tasks, calendar, search.
4. **AI Core:** AI chat, summarizer, quiz generator, flashcards, voice transcription.
5. **Engagement Core:** gamification, discussion, announcements, messaging.
6. **Account Core:** profile, privacy/security/preferences, notification controls.

### Student UX Operating Model
- Dashboard acts as orchestration center.
- Course-centric navigation anchors all learning artifacts.
- Assignments/labs/quizzes form the assessment execution pipeline.
- Grades/attendance provide outcome visibility.
- AI tools reduce cognitive load and improve revision speed.
- Settings allow user-level control over communication and privacy.

### Student Data and State Characteristics
- Frequently changing state in tasks, assignments, quizzes, and messaging.
- Hybrid of backend-backed and partially mocked flows in selected domains.
- Requires strict handling of submission finalization and result display timing.

---

## Instructor Role

### Mission
The instructor role focuses on **teaching delivery, assessment governance, and class orchestration**.

### Core Instructor Feature Domains
1. **Teaching Dashboard:** KPI snapshots and action shortcuts.
2. **Content Management:** courses, materials, video assets, course management.
3. **Assessment Operations:** create assignments, evaluate submissions, grading center.
4. **Class Operations:** labs, attendance manager, roster management.
5. **Instructional Intelligence:** reports, analytics, AI teaching assistant.
6. **Communication:** announcements, discussions, notifications, messaging.
7. **Quiz Governance:** quiz lifecycle from creation through statistics.
8. **Account Controls:** profile and role-specific settings.

### Instructor UX Operating Model
- High-frequency workflows are exposed as dashboard quick actions.
- Grading center and submissions flows are optimized for throughput and auditability.
- Roster/attendance/reporting screens provide oversight and intervention context.
- AI teaching tools serve as planning augmentation, not grading authority.

### Instructor Data and State Characteristics
- Multi-entity dependencies (courses, assignments, students, submissions).
- Strong need for deterministic grading flows and save-state integrity.
- Frequent list/detail navigation with route parameters.

---

## Teaching Assistant (TA) Role

### Mission
The TA role focuses on **instructional support execution**: assist grading, oversee labs, track student performance, and maintain communication flow with students and instructors.

### Core TA Feature Domains
1. **TA Dashboard and Work Queue**
2. **Assigned Courses and Materials**
3. **Assignment Review and Grading Center**
4. **Lab Operations and Attendance**
5. **Analytics and AI Support**
6. **Discussions, Messaging, Notifications**
7. **Quiz Support Workflows**
8. **Profile/Settings/Calendar**

### TA UX Operating Model
- Task-first orientation (what needs action now).
- Course assignment scope controls access and visibility.
- AI assistant supports response drafting and insight generation.
- Strong coupling to instructor-designed course structure and assessment policy.

### TA Data and State Characteristics
- Role-scoped data subsets (assigned sections/courses).
- Action-heavy queues for submissions and lab sessions.
- Discussion and communication surfaces for rapid response loops.

---

## Admin Role

### Mission
The admin role provides **institutional governance and platform control** over users, courses, policy, analytics, and compliance-related operations.

### Core Admin Feature Domains
1. **User and Role Lifecycle Management**
2. **Course, Department, and Staff Assignment Governance**
3. **Enrollment Periods, Campus Events, Templates, Office Hours**
4. **Security, Audit, and Compliance Monitoring**
5. **Platform Configuration (branding, comms channels, APIs, storage, gateways)**
6. **Backup and Recovery**
7. **Institutional Notifications, Announcements, Messaging**
8. **Admin Profile and preference controls**

### Admin UX Operating Model
- Dashboard + quick actions for high-level operational awareness.
- Broad settings hierarchy for policy-level controls.
- Reporting and audit paths for governance transparency.

### Admin Data and State Characteristics
- Broadest business-domain surface among non-technical roles.
- High sensitivity on role assignment and policy changes.
- Requires clear confirmation workflows for destructive/system-wide actions.

---

## IT Admin Role

### Mission
The IT admin role delivers **runtime reliability and technical operations**: infrastructure health, incidents, logs, backups, API/database/cloud settings, and integration runtime stability.

### Core IT Admin Feature Domains
1. **System Health and Service Status Monitoring**
2. **Servers, API, Database, Cloud Services**
3. **Error/Security Logs and Alerts**
4. **Backup/Restore Operations**
5. **AI Model and Integration Configuration**
6. **Performance Reporting**
7. **IT Profile and settings**

### IT Admin UX Operating Model
- Monitoring-first dashboard with operational metrics.
- Incident triage and service-level drill-down.
- Rapid access to infrastructure configuration tools.

### IT Admin Data and State Characteristics
- Operational telemetry and incident/event data.
- High need for timestamped status and trend visibility.
- Read-heavy monitoring + controlled write actions for configuration changes.

---

## Guest/Public Role

### Mission
Provide secure and clear entry to the platform before authentication.

### Guest/Public Capability Set
- Splash screen
- Onboarding
- Login
- Register
- Email verification
- Forgot password
- Reset password

---

## Complete Route Catalog by Role

### Public Routes
- `/`
- `/onboarding`
- `/login`
- `/register`
- `/verify-email`
- `/forgot-password`
- `/reset-password`

### Shared Authenticated Routes
- `/messages`
- `/messages/new`
- `/messages/profile/:userId`
- `/messages/group/:conversationId`
- `/messages/swipe-settings`

### Student and Non-Prefixed Academic Routes
- `/dashboard`
- `/courses`
- `/registration`
- `/flashcards`
- `/labs`
- `/assignments`
- `/tasks`
- `/ai-quiz-generator`
- `/quiz-questions`
- `/quiz-result`
- `/course-details`
- `/course-instructor-info`
- `/notifications`
- `/student/announcements`
- `/grades`
- `/grade-analysis`
- `/voice-to-text`
- `/attendance`
- `/student/quizzes`
- `/student/quiz-take`
- `/student/quiz-result`
- `/summarizer`
- `/gamification`
- `/ai-chat`
- `/calendar`
- `/search`
- `/course/:courseId/discussions`
- `/discussions`
- `/course/:courseId/discussions/:threadId`
- `/profile`
- `/edit-profile`
- `/settings`
- `/settings/appearance`
- `/settings/language`
- `/settings/notifications`
- `/settings/email-notifications`
- `/settings/two-factor-auth`
- `/settings/connected-devices`
- `/settings/privacy`
- `/settings/login-history`
- `/settings/ai`
- `/settings/storage`
- `/settings/help`
- `/settings/about`
- `/settings/email`
- `/settings/dnd`
- `/settings/terms`
- `/settings/privacy-policy`
- `/settings/blocked-users`
- `/settings/swipe-actions`
- `/settings/swipe-actions/notifications`
- `/settings/swipe-actions/chats`
- `/settings/swipe-actions/files`
- `/settings/swipe-actions/notes`
- `/settings/share-app`
- `/settings/share-app/qr`
- `/settings/share-app/apk`

### Instructor Routes
- `/instructor/dashboard`
- `/instructor/courses`
- `/instructor/courses/:courseId`
- `/instructor/courses/:courseId/video/:videoId`
- `/instructor/grading`
- `/instructor/assignments`
- `/instructor/labs`
- `/instructor/labs/:labId`
- `/instructor/assignments/create`
- `/instructor/assignments/:assignmentId/submissions`
- `/instructor/assignments/:assignmentId/submissions/:submissionId/grading`
- `/instructor/assignments/:assignmentId`
- `/instructor/course-management`
- `/instructor/announcements`
- `/instructor/attendance`
- `/instructor/create-assignment`
- `/instructor/reports`
- `/instructor/ai-teaching`
- `/instructor/upload-materials`
- `/instructor/calendar`
- `/instructor/search`
- `/instructor/notifications`
- `/instructor/roster`
- `/instructor/profile`
- `/instructor/edit-profile`
- `/instructor/settings`
- `/instructor/messages`
- `/instructor/discussions`
- `/instructor/course/:courseId/discussions`
- `/instructor/course/:courseId/discussions/:threadId`
- `/instructor/quiz-management`
- `/instructor/quiz-create`
- `/instructor/quiz-edit`
- `/instructor/quiz-attempts`
- `/instructor/quiz-grading`
- `/instructor/quiz-statistics`

### TA Routes
- `/ta/announcements`
- `/ta/dashboard`
- `/ta/courses`
- `/ta/assignments`
- `/ta/assignments/:assignmentId`
- `/ta/course/:id`
- `/ta/labs`
- `/ta/lab/:id`
- `/ta/quiz-management`
- `/ta/quiz-create`
- `/ta/quiz-edit`
- `/ta/quiz-attempts`
- `/ta/quiz-grading`
- `/ta/quiz-statistics`
- `/ta/notifications`
- `/ta/roster`
- `/ta/discussions`
- `/ta/course/:courseId/discussions`
- `/ta/course/:courseId/discussions/:threadId`
- `/ta/section-materials`
- `/ta/grading`
- `/ta/analytics`
- `/ta/settings`
- `/ta/profile`
- `/ta/edit-profile`
- `/ta/calendar`
- `/ta/search`
- `/ta/attendance`
- `/ta/ai-assistant`
- `/ta/messages`

### Admin Routes
- `/admin/announcements`
- `/admin/dashboard`
- `/admin/users`
- `/admin/users/add`
- `/admin/users/edit/:id`
- `/admin/roles`
- `/admin/courses`
- `/admin/enrollment-periods`
- `/admin/campus-events`
- `/admin/schedule-templates`
- `/admin/office-hours`
- `/admin/courses/add`
- `/admin/staff`
- `/admin/departments`
- `/admin/analytics`
- `/admin/security`
- `/admin/backup-center`
- `/admin/payments`
- `/admin/audit`
- `/admin/integrations`
- `/admin/profile`
- `/admin/edit-profile`
- `/admin/attendance`
- `/admin/search`
- `/admin/messages`
- `/admin/discussions`
- `/admin/ai-insights`
- `/admin/notifications`
- `/admin/notifications/swipe-settings`
- `/admin/settings`
- `/admin/settings/semester`
- `/admin/settings/registration`
- `/admin/settings/blocked-users`
- `/admin/settings/appearance`
- `/admin/settings/language`
- `/admin/settings/branding`
- `/admin/settings/logo-assets`
- `/admin/settings/password-policy`
- `/admin/settings/two-factor`
- `/admin/settings/email`
- `/admin/settings/sms`
- `/admin/settings/push-notifications`
- `/admin/settings/webhooks`
- `/admin/settings/api`
- `/admin/settings/cloud-storage`
- `/admin/settings/payment-gateways`
- `/admin/settings/video-conferencing`
- `/admin/settings/backup-restore`
- `/admin/settings/system-updates`
- `/admin/settings/developer-options`
- `/admin/settings/system-logs`

### IT Admin Routes
- `/it-admin/dashboard`
- `/it-admin/settings`
- `/it-admin/account-settings`
- `/it-admin/integrations`
- `/it-admin/backup`
- `/it-admin/security-logs`
- `/it-admin/ai-settings`
- `/it-admin/performance`
- `/it-admin/alerts`
- `/it-admin/profile`
- `/it-admin/edit-profile`
- `/it-admin/system-health`
- `/it-admin/servers`
- `/it-admin/api`
- `/it-admin/logs`
- `/it-admin/database`
- `/it-admin/cloud`
- `/it-admin/messages`
- `/it-admin/discussions`
- `/it-admin/search`

---

## State Management Inventory

The platform relies on BLoC/Cubit modules distributed by feature domain.

| BLoC Module | Files |
|---|---|
| `admin_course_management` | 3 |
| `admin_notifications` | 2 |
| `ai_chat` | 2 |
| `assignments` | 3 |
| `attendance` | 8 |
| `auth` | 3 |
| `calendar` | 2 |
| `chat` | 4 |
| `course_structure` | 3 |
| `courses` | 3 |
| `discussions` | 4 |
| `gamification` | 2 |
| `grades` | 2 |
| `instructor` | 15 |
| `lab_detail` | 2 |
| `labs` | 2 |
| `language` | 1 |
| `materials` | 3 |
| `notifications` | 3 |
| `profile` | 3 |
| `quiz` | 4 |
| `roster` | 2 |
| `schedule` | 1 |
| `search` | 2 |
| `student_registration` | 2 |
| `summarizer` | 2 |
| `ta` | 7 |
| `tasks` | 2 |
| `theme` | 4 |
| `voice_to_text` | 3 |

### State Management Strategy Notes
- Event-heavy modules handle asynchronous APIs and complex transitions.
- Cubits are used for preference-like or compact state domains.
- Shared conversation/discussion state should remain role-safe and route-scoped.

---

## API Service Layer Inventory

| Service File | Responsibility (inferred) |
|---|---|
| `admin_course_management_service.dart` | Admin Course Management Service domain operations |
| `admin_periods_service.dart` | Admin Periods Service domain operations |
| `admin_student_management_service.dart` | Admin Student Management Service domain operations |
| `assignment_service.dart` | Assignment Service domain operations |
| `attendance_service.dart` | Attendance Service domain operations |
| `chat_service.dart` | Chat Service domain operations |
| `communication_service.dart` | Communication Service domain operations |
| `core_api_client.dart` | Core Api Client domain operations |
| `course_service.dart` | Course Service domain operations |
| `discussion_service.dart` | Discussion Service domain operations |
| `enrollment_service.dart` | Enrollment Service domain operations |
| `grades_normalizer.dart` | Grades Normalizer domain operations |
| `grades_service.dart` | Grades Service domain operations |
| `lab_service.dart` | Lab Service domain operations |
| `material_service.dart` | Material Service domain operations |
| `notification_api_service.dart` | Notification Api Service domain operations |
| `office_hours_service.dart` | Office Hours Service domain operations |
| `public_profile_service.dart` | Public Profile Service domain operations |
| `quiz_ai_service.dart` | Quiz Ai Service domain operations |
| `quiz_api_service.dart` | Quiz Api Service domain operations |
| `schedule_api_service.dart` | Schedule Api Service domain operations |
| `schedule_service.dart` | Schedule Service domain operations |
| `section_service.dart` | Section Service domain operations |
| `semester_service.dart` | Semester Service domain operations |
| `student_stats_service.dart` | Student Stats Service domain operations |
| `user_profile_service.dart` | User Profile Service domain operations |

### Service Layer Design Notes
- Service classes encapsulate endpoint concerns per domain.
- Router/state layers should avoid direct HTTP coupling.
- Cross-cutting concerns (auth headers, retries, parsing wrappers) belong in shared client/interceptor utilities.

---

## Data, Workflow, and UX State Patterns

### Common Workflow Pattern
1. Route entry initializes screen state.
2. Screen triggers service-layer reads.
3. BLoC/Cubit emits transitional state updates.
4. UI renders domain-specific affordances.
5. User actions trigger write operations.
6. Success/error outcomes update local and visual state.

### UX State Expectations
- Loading indicators must be explicit for slow operations.
- Empty states should communicate “why empty” and “what next”.
- Error states should be actionable and avoid silent failures.
- Critical operations should be idempotent and retry-safe.

### Domain-Specific Integrity Expectations
- **Assessments:** deterministic grading and immutable submission history.
- **Attendance:** explicit status taxonomy and session lifecycle control.
- **Messaging:** read-state consistency and access boundary enforcement.
- **Settings:** atomic persistence for user preferences.
- **Admin/IT Changes:** high-signal confirmations and audit visibility.

---

## Implementation Maturity and Known Gaps

Based on repository docs and current branch artifacts:

1. Some dashboard surfaces still use mock or placeholder data.
2. Attendance parity is in-progress in parts of the system.
3. Certain auth-related flows (for example full parity of 2FA/token refresh patterns) are documented as partial/in-progress in audit/planning documents.
4. Some documented capabilities are platform-roadmap or partial-feature states rather than fully integrated end-to-end flows.

### Recommended Maturity Milestones
1. Finish end-to-end parity for attendance across all roles.
2. Harden auth/session refresh and route protection consistency.
3. Instrument key workflows (grading, attendance, quiz submissions) for observability.
4. Unify mock-to-real data migration strategy for remaining role dashboards.
5. Add regression-focused role-route contract tests.

---

## Per-Feature Documentation Index (Generated Files)

This repository now includes detailed per-feature documentation files for Student, Instructor, and TA.

## Student Feature Documentation Index
| # | Feature | Documentation File |
|---|---|---|
| 1 | About | `Roles_Documentation/Student/student_about.md` |
| 2 | Ai Chat | `Roles_Documentation/Student/student_ai_chat.md` |
| 3 | Ai Quiz Generator | `Roles_Documentation/Student/student_ai_quiz_generator.md` |
| 4 | Ai Settings | `Roles_Documentation/Student/student_ai_settings.md` |
| 5 | Appearance Settings | `Roles_Documentation/Student/student_appearance_settings.md` |
| 6 | Assignment Details Submission | `Roles_Documentation/Student/student_assignment_details_submission.md` |
| 7 | Assignments | `Roles_Documentation/Student/student_assignments.md` |
| 8 | Attendance | `Roles_Documentation/Student/student_attendance.md` |
| 9 | Blocked Users | `Roles_Documentation/Student/student_blocked_users.md` |
| 10 | Calendar | `Roles_Documentation/Student/student_calendar.md` |
| 11 | Connected Devices | `Roles_Documentation/Student/student_connected_devices.md` |
| 12 | Course Attendance Detail | `Roles_Documentation/Student/student_course_attendance_detail.md` |
| 13 | Course Details | `Roles_Documentation/Student/student_course_details.md` |
| 14 | Course Instructor Info | `Roles_Documentation/Student/student_course_instructor_info.md` |
| 15 | Course Registration Enrollment | `Roles_Documentation/Student/student_course_registration_enrollment.md` |
| 16 | Courses List | `Roles_Documentation/Student/student_courses_list.md` |
| 17 | Dashboard | `Roles_Documentation/Student/student_dashboard.md` |
| 18 | Discussions | `Roles_Documentation/Student/student_discussions.md` |
| 19 | Do Not Disturb | `Roles_Documentation/Student/student_do_not_disturb.md` |
| 20 | Edit Profile | `Roles_Documentation/Student/student_edit_profile.md` |
| 21 | Email Notifications | `Roles_Documentation/Student/student_email_notifications.md` |
| 22 | Email Preferences | `Roles_Documentation/Student/student_email_preferences.md` |
| 23 | Flashcards | `Roles_Documentation/Student/student_flashcards.md` |
| 24 | Gamification | `Roles_Documentation/Student/student_gamification.md` |
| 25 | Grade Analysis | `Roles_Documentation/Student/student_grade_analysis.md` |
| 26 | Grades | `Roles_Documentation/Student/student_grades.md` |
| 27 | Help Center | `Roles_Documentation/Student/student_help_center.md` |
| 28 | Lab Details | `Roles_Documentation/Student/student_lab_details.md` |
| 29 | Labs | `Roles_Documentation/Student/student_labs.md` |
| 30 | Language Settings | `Roles_Documentation/Student/student_language_settings.md` |
| 31 | Login History | `Roles_Documentation/Student/student_login_history.md` |
| 32 | Messages | `Roles_Documentation/Student/student_messages.md` |
| 33 | Notifications | `Roles_Documentation/Student/student_notifications.md` |
| 34 | Privacy Policy | `Roles_Documentation/Student/student_privacy_policy.md` |
| 35 | Privacy Settings | `Roles_Documentation/Student/student_privacy_settings.md` |
| 36 | Profile | `Roles_Documentation/Student/student_profile.md` |
| 37 | Quiz List | `Roles_Documentation/Student/student_quiz_list.md` |
| 38 | Quiz Questions | `Roles_Documentation/Student/student_quiz_questions.md` |
| 39 | Quiz Result | `Roles_Documentation/Student/student_quiz_result.md` |
| 40 | Quiz Taking | `Roles_Documentation/Student/student_quiz_taking.md` |
| 41 | Search | `Roles_Documentation/Student/student_search.md` |
| 42 | Share App Apk | `Roles_Documentation/Student/student_share_app_apk.md` |
| 43 | Share App Qr | `Roles_Documentation/Student/student_share_app_qr.md` |
| 44 | Storage Settings | `Roles_Documentation/Student/student_storage_settings.md` |
| 45 | Student Announcements | `Roles_Documentation/Student/student_student_announcements.md` |
| 46 | Summarizer | `Roles_Documentation/Student/student_summarizer.md` |
| 47 | Swipe Actions Chats | `Roles_Documentation/Student/student_swipe_actions_chats.md` |
| 48 | Swipe Actions Files | `Roles_Documentation/Student/student_swipe_actions_files.md` |
| 49 | Swipe Actions Notes | `Roles_Documentation/Student/student_swipe_actions_notes.md` |
| 50 | Swipe Actions Notifications | `Roles_Documentation/Student/student_swipe_actions_notifications.md` |
| 51 | Tasks And To Do | `Roles_Documentation/Student/student_tasks_and_to_do.md` |
| 52 | Terms | `Roles_Documentation/Student/student_terms.md` |
| 53 | Two Factor Authentication Settings | `Roles_Documentation/Student/student_two_factor_authentication_settings.md` |
| 54 | Voice To Text | `Roles_Documentation/Student/student_voice_to_text.md` |

## Instructor Feature Documentation Index
| # | Feature | Documentation File |
|---|---|---|
| 1 | Ai Teaching Assistant | `Roles_Documentation/Instructor/instructor_ai_teaching_assistant.md` |
| 2 | Announcements | `Roles_Documentation/Instructor/instructor_announcements.md` |
| 3 | Assignment Details | `Roles_Documentation/Instructor/instructor_assignment_details.md` |
| 4 | Assignment Submissions | `Roles_Documentation/Instructor/instructor_assignment_submissions.md` |
| 5 | Assignments List | `Roles_Documentation/Instructor/instructor_assignments_list.md` |
| 6 | Attendance Manager | `Roles_Documentation/Instructor/instructor_attendance_manager.md` |
| 7 | Calendar | `Roles_Documentation/Instructor/instructor_calendar.md` |
| 8 | Course Details | `Roles_Documentation/Instructor/instructor_course_details.md` |
| 9 | Course Discussion Threads | `Roles_Documentation/Instructor/instructor_course_discussion_threads.md` |
| 10 | Course Management | `Roles_Documentation/Instructor/instructor_course_management.md` |
| 11 | Create Assignment | `Roles_Documentation/Instructor/instructor_create_assignment.md` |
| 12 | Dashboard | `Roles_Documentation/Instructor/instructor_dashboard.md` |
| 13 | Discussions | `Roles_Documentation/Instructor/instructor_discussions.md` |
| 14 | Edit Profile | `Roles_Documentation/Instructor/instructor_edit_profile.md` |
| 15 | Grading Center | `Roles_Documentation/Instructor/instructor_grading_center.md` |
| 16 | Lab Detail | `Roles_Documentation/Instructor/instructor_lab_detail.md` |
| 17 | Labs List | `Roles_Documentation/Instructor/instructor_labs_list.md` |
| 18 | Messages | `Roles_Documentation/Instructor/instructor_messages.md` |
| 19 | My Courses | `Roles_Documentation/Instructor/instructor_my_courses.md` |
| 20 | Notifications | `Roles_Documentation/Instructor/instructor_notifications.md` |
| 21 | Profile | `Roles_Documentation/Instructor/instructor_profile.md` |
| 22 | Quiz Attempts | `Roles_Documentation/Instructor/instructor_quiz_attempts.md` |
| 23 | Quiz Create | `Roles_Documentation/Instructor/instructor_quiz_create.md` |
| 24 | Quiz Edit | `Roles_Documentation/Instructor/instructor_quiz_edit.md` |
| 25 | Quiz Grading | `Roles_Documentation/Instructor/instructor_quiz_grading.md` |
| 26 | Quiz Management | `Roles_Documentation/Instructor/instructor_quiz_management.md` |
| 27 | Quiz Statistics | `Roles_Documentation/Instructor/instructor_quiz_statistics.md` |
| 28 | Reports And Analytics | `Roles_Documentation/Instructor/instructor_reports_and_analytics.md` |
| 29 | Roster | `Roles_Documentation/Instructor/instructor_roster.md` |
| 30 | Search | `Roles_Documentation/Instructor/instructor_search.md` |
| 31 | Settings | `Roles_Documentation/Instructor/instructor_settings.md` |
| 32 | Submission Grading | `Roles_Documentation/Instructor/instructor_submission_grading.md` |
| 33 | Upload Materials | `Roles_Documentation/Instructor/instructor_upload_materials.md` |
| 34 | Video Player | `Roles_Documentation/Instructor/instructor_video_player.md` |

## TA Feature Documentation Index
| # | Feature | Documentation File |
|---|---|---|
| 1 | Announcements | `Roles_Documentation/TA/ta_announcements.md` |
| 2 | Assigned Courses | `Roles_Documentation/TA/ta_assigned_courses.md` |
| 3 | Assignment Detail | `Roles_Documentation/TA/ta_assignment_detail.md` |
| 4 | Assignment Submissions | `Roles_Documentation/TA/ta_assignment_submissions.md` |
| 5 | Assignments List | `Roles_Documentation/TA/ta_assignments_list.md` |
| 6 | Attendance | `Roles_Documentation/TA/ta_attendance.md` |
| 7 | Calendar | `Roles_Documentation/TA/ta_calendar.md` |
| 8 | Course Detail | `Roles_Documentation/TA/ta_course_detail.md` |
| 9 | Course Discussion Threads | `Roles_Documentation/TA/ta_course_discussion_threads.md` |
| 10 | Dashboard | `Roles_Documentation/TA/ta_dashboard.md` |
| 11 | Discussions | `Roles_Documentation/TA/ta_discussions.md` |
| 12 | Edit Profile | `Roles_Documentation/TA/ta_edit_profile.md` |
| 13 | Grading Center | `Roles_Documentation/TA/ta_grading_center.md` |
| 14 | Lab Detail | `Roles_Documentation/TA/ta_lab_detail.md` |
| 15 | Labs List | `Roles_Documentation/TA/ta_labs_list.md` |
| 16 | Messages | `Roles_Documentation/TA/ta_messages.md` |
| 17 | Notifications | `Roles_Documentation/TA/ta_notifications.md` |
| 18 | Profile | `Roles_Documentation/TA/ta_profile.md` |
| 19 | Quiz Attempts | `Roles_Documentation/TA/ta_quiz_attempts.md` |
| 20 | Quiz Create | `Roles_Documentation/TA/ta_quiz_create.md` |
| 21 | Quiz Edit | `Roles_Documentation/TA/ta_quiz_edit.md` |
| 22 | Quiz Grading | `Roles_Documentation/TA/ta_quiz_grading.md` |
| 23 | Quiz Management | `Roles_Documentation/TA/ta_quiz_management.md` |
| 24 | Quiz Statistics | `Roles_Documentation/TA/ta_quiz_statistics.md` |
| 25 | Roster | `Roles_Documentation/TA/ta_roster.md` |
| 26 | Search | `Roles_Documentation/TA/ta_search.md` |
| 27 | Section Materials | `Roles_Documentation/TA/ta_section_materials.md` |
| 28 | Settings | `Roles_Documentation/TA/ta_settings.md` |
| 29 | Ta Ai Assistant | `Roles_Documentation/TA/ta_ta_ai_assistant.md` |
| 30 | Ta Analytics | `Roles_Documentation/TA/ta_ta_analytics.md` |

---

## Engineering Recommendations and Next Milestones

### Documentation Governance
- Keep this master document as the **cross-role architecture and capability source of truth**.
- Keep role-specific feature docs as **implementation detail references**.
- Update route tables whenever `app_router.dart` changes materially.

### Suggested Update Process
1. Update feature screen/service references during implementation.
2. Refresh role feature docs for changed modules.
3. Regenerate or manually update this master file after major feature milestones.
4. Include doc update checks in PR review templates.

### Quality Controls for Future Expansions
- Enforce naming conventions for new routes/screens/services.
- Standardize error/loading/empty UX behavior templates.
- Keep role boundary checks centralized and testable.

---

## Appendices

### Appendix A — Role Screen Tree Snapshot
| Role Area | Screen File Count |
|---|---|
| Student | 64 |
| Instructor | 36 |
| TA | 32 |
| Admin | 49 |
| IT Admin | 19 |
| Auth | 5 |
| Shared | 9 |

### Appendix B — Key Files Used for This Documentation
- `lib/config/app_router.dart`
- `lib/services/auth_role_resolver.dart`
- `README.md`
- `features documentation/student/STUDENT_FEATURES_DOCUMENTATION.md`
- `features documentation/instructor/INSTRUCTOR_FEATURES_DOCUMENTATION.md`
- `features documentation/TA/TA_FEATURES_DOCUMENTATION.md`
- `features documentation/admin/ADMIN_FEATURES_DOCUMENTATION.md`
- `features documentation/it admin/IT_ADMIN_FEATURES_DOCUMENTATION.md`

### Appendix C — Notes on Scope
- This document is intentionally comprehensive and role-spanning.
- Detailed per-feature implementation docs for Student/Instructor/TA are linked above.
- Admin and IT Admin deep details are captured in their role-level documentation files and route catalogs.
