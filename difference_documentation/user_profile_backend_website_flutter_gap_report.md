# User Profile Gap Analysis Report

## Scope
This report compares the **User Profile** implementation and profile-related identity display across:

- Backend: `D:\Graduation\backend\last_backend\EduVerse_Backend`
- Website frontend: `D:\Graduation\frontend_tarek\Eduverse-Frontend`
- Flutter frontend: `D:\Graduation\EduVerse\edu_verse`

The focus is on:

- Self profile screen
- Edit profile fields
- Name/avatar/identity shown in drawers, headers, dashboards, and related UI
- Public profile usage where relevant
- Roles: **student, instructor, teaching assistant (TA), admin**

This is an **investigation report only**. It is intentionally written to support a later planning and implementation phase.

---

## Executive Summary
The backend exposes a **single generic profile contract for all roles**. It supports only core user/profile fields such as name, phone, profile picture URL, bio, social links, academic interests, skills, preferences, password change, and public profile retrieval. It does **not** provide role-specific academic/staff/admin profile fields like `studentId`, `major`, `department`, `officeHours`, `employeeId`, `supervisor`, `timezone`, or `language`.

The website is **partially integrated** with this backend contract:

- It already reads and updates the generic profile via `/users/profile`.
- It already reads public profiles via `/users/:id/public`.
- It uses authenticated user data for names in several dashboards and chats.
- But it still contains many placeholder role-specific profile fields that are not backend-backed.

The Flutter app is **far behind the website and backend contract** in profile-related features:

- Student self-profile UI exists, but it is driven by local mock/sample data rather than backend APIs.
- Instructor, TA, and admin profile screens are almost entirely mock/local-only.
- Drawer/app bar names are hardcoded for several roles instead of using authenticated user data that Flutter already has.
- Public profile retrieval exists in Flutter, but the model is incomplete/inaccurate relative to the backend and is behind the website UI.
- Some Flutter behavior is not just missing, but **incorrect**, such as wrong dashboard routes and edit fields that do not match the backend contract.

High-level verdict by role:

- **Student**: Flutter is visually ahead of website in local UI richness, but functionally behind because it is not integrated with the backend.
- **Instructor**: Flutter is mostly mock, while website has at least partial integration through shared profile and auth-based naming.
- **TA**: Flutter is mostly mock and internally inconsistent; website is partial but clearly ahead.
- **Admin**: Flutter is mostly mock and uses role labels instead of actual user identity; website is also partial, but still ahead on some live auth usage.

---

## Reference Baseline: What the Backend Actually Supports

### Backend profile endpoints
The backend exposes the following profile-related endpoints in `src/modules/auth/user-profile.controller.ts`:

- `GET /api/users/profile` at `src/modules/auth/user-profile.controller.ts:34`
- `PUT /api/users/profile` at `src/modules/auth/user-profile.controller.ts:44`
- `GET /api/users/preferences` at `src/modules/auth/user-profile.controller.ts:51`
- `GET /api/users/:id/public` at `src/modules/auth/user-profile.controller.ts:58`
- `PUT /api/users/preferences` at `src/modules/auth/user-profile.controller.ts:71`
- `PATCH /api/users/password` at `src/modules/auth/user-profile.controller.ts:81`

### Backend user entity fields relevant to profile
The persisted user profile fields visible in `src/modules/auth/entities/user.entity.ts` include:

- `firstName` at `:42`
- `lastName` at `:45`
- `phone` at `:48`
- `profilePictureUrl` at `:51`
- `bio` at `:54`
- `socialLinks` at `:57`
- `academicInterests` at `:60`
- `skills` at `:62-63`
- `campusId` at `:66`

### Backend update contract
`UpdateProfileDto` in `src/modules/auth/dto/user-management.dto.ts` supports:

- `firstName` at `:157`
- `lastName` at `:162`
- `phone` at `:167`
- `profilePictureUrl` at `:171`
- `bio` at `:176`
- `socialLinks` at `:179`
- `academicInterests` at `:184`
- `skills` at `:189`

### Backend self profile response
`getProfile()` in `src/modules/auth/user-management.service.ts` returns a generic role-agnostic profile including:

- `socialLinks` at `:904`
- `academicInterests` at `:905`
- `skills` at `:906`
- `profileCompleteness` at `:911`
- roles mapping around `:896-911`

### Backend public profile response
`getPublicProfile()` in `src/modules/auth/user-management.service.ts` returns:

- `fullName` at `:927`
- `socialLinks` at `:930`
- `academicInterests` at `:931`
- `skills` at `:932`
- roles mapping in the same return block `:922-932`

### Important backend implication
The backend is **not role-specific** for profile data. There is no backend support here for:

- Student-only fields such as `studentId`, `university`, `major`, `minor`, `level`, `year`, `expectedGraduation`, `dateOfBirth`, `location`, `gpa`, `rank`
- Instructor-only fields such as `title`, `department`, `office`, `officeHours`, `specialization`, `education`, `employeeId`
- TA-only fields such as `employeeId`, `supervisor`, `joinDate`, `labsManaged`
- Admin-only fields such as `employeeId`, `department`, `timezone`, `language`, `lastLogin`

Therefore, any such fields shown in website or Flutter profile screens are currently:

- placeholders,
- local-only UI data,
- or derived from unrelated sources,

unless there is another backend module supporting them separately.

---

## Website Current State

## Shared website profile/API layer

### `UserService` is already wired to the backend profile API
In `src/services/api/userService.ts`:

- `UserProfile` includes `academicInterests`, `skills`, and `profileCompleteness` at `:15-28`
- `UpdateProfileDto` exists at `:31-36`
- `getPublicProfile()` exists at `:41`
- `getProfile()` exists at `:45`
- `updateProfile()` exists at `:49`

This means the website already has a real API layer for the generic backend profile contract.

### Shared dashboard profile tab is partially backend-backed
`src/components/shared/DashboardProfileTab.tsx` is the main shared profile component across multiple dashboard roles.

Evidence:

- It merges auth user data into local profile state at `:147-152`
- It calls `UserService.getProfile()` at `:165`
- It maps backend `academicInterests` into UI `interests` at `:173`
- It maps backend `skills` at `:174`
- It calls `UserService.updateProfile()` at `:195`
- It only persists `firstName`, `lastName`, `bio`, `academicInterests`, and `skills` at `:195-200`

What is good:

- Real profile read/update exists
- Shared role dashboard profile UI exists
- Name and email can be derived from auth/backend
- Bio, interests, and skills are genuinely integrated

What is still limited/wrong:

- UI includes `phone` and `address` fields at `:420-427`, but update payload does not persist them
- `department` and `officeHours` can be displayed at `:24`, `:485-486`, but are not backend-supported here
- `socialLinks` are backend-supported, but this shared component does not expose them for editing
- `profilePictureUrl` is backend-supported, but this shared component does not appear to handle true profile image persistence

---

## Website role-by-role observations

## Student website

### Dashboard identity and profile
In `src/pages/student-dashboard/StudentDashboard.tsx`:

- Header uses `user?.fullName || 'No Name'` at `:356`
- Chat uses `currentUserName={user?.fullName || 'Student'}` at `:469`
- Shared profile tab is used at `:478`
- Shared profile data passes `fullName: user?.fullName || 'No Name'` at `:483`

This is better than Flutter because the displayed student name is tied to auth state in the dashboard.

### Standalone profile page is only partially real
In `src/pages/profile/ProfilePage.tsx`:

- Calls `UserService.getProfile()` at `:132`
- Maps `studentId` from `userId` at `:135`
- Fills `phone`, `address`, `dateOfBirth`, `enrollmentDate`, `major`, `minor`, `gpa`, `expectedGraduation` with local defaults at `:137-146`
- Uses backend `academicInterests` and `skills` at `:146-147`
- Saves via `UserService.updateProfile()` at `:167`
- Save payload only includes `academicInterests` and `skills` plus core names/bio at `:167-172`
- UI still exposes phone editing at `:399-400` and address editing at `:416-417`

Conclusion:

- Core profile fields are partially integrated
- Student-only profile details are mostly placeholders
- Phone is editable in UI but not really persisted
- Several displayed student profile items have no backend support

## Instructor website

In `src/pages/instructor-dashboard/InstructorDashboard.tsx`:

- Header uses `user?.fullName || 'Instructor'` at `:1237`
- It also uses `user?.role || 'Instructor'` at `:1238`
- Discussion page hardcodes `userName="Prof. Sarah Martinez"` at `:1574`
- Chat uses `currentUserName={user?.fullName || 'Prof. Sarah Martinez'}` at `:1581`
- Shared profile tab is used at `:1592`
- Shared profile data passes `fullName: user?.fullName || 'Instructor'` at `:1597`
- Shared profile data again uses `user?.role || 'Instructor'` at `:1598`

Important notes:

- The website is ahead of Flutter because it at least tries to use live auth user names
- However, `user?.role` looks inconsistent with the auth model that uses `roles[]`, so role display is already fragile/wrong on the website side
- There is still a hardcoded discussion username in one place

There is also a separate local-only instructor profile component:

- `src/pages/instructor-dashboard/components/ProfilePage.tsx`

This appears to be mock/local and not the shared integrated implementation.

## TA website

In `src/pages/ta-dashboard/TADashboard.tsx`:

- Shared profile tab is imported at `:51`
- Mock profile uses `fullName: 'Ahmed Hassan'` at `:234`
- Live profile is loaded via authenticated account at `:411`
- Shared profile state uses `source?.fullName || 'Teaching Assistant'` at `:1147`
- Role is hardcoded as `'Teaching Assistant'` at `:1148`
- Bio text says edit actions are not connected at `:1156`
- Current user name is mock `'Ahmed Hassan'` or live `liveProfile?.fullName || user?.fullName` at `:1162-1164`
- Header uses `userName={currentUserName}` at `:1204`
- Chat uses `currentUserName={currentUserName}` at `:1350`
- Shared profile tab is rendered at `:1360`

Conclusion:

- TA website is not fully complete
- But it is clearly ahead of Flutter because it uses live auth/profile identity in several places
- TA profile details beyond name/email/phone remain mostly placeholders

## Admin website

In `src/pages/admin-dashboard/AdminDashboard.tsx`:

- Header hardcodes `userName="Department Head"` at `:855`
- Chat uses `currentUserName={user?.fullName || 'Administrator'}` at `:964`
- Shared profile tab is used at `:976`
- Shared profile tab is passed `fullName: 'Admin Name'` at `:981`
- Role is passed as `'Administrator'` at `:982`

Conclusion:

- Admin website is still partial and contains hardcoded identity in some places
- But shared profile tab can still overlay some auth/backend data, so it is ahead of Flutter admin in practical integration

## Website public profile

`src/pages/student-dashboard/pages/PublicProfileView.tsx` is a meaningful reference implementation:

- Uses backend public profile roles at `:92-95`
- Reads `socialLinks` at `:97-102`
- Calls `UserService.getPublicProfile(staffId)` at `:154`
- Displays role(s) at `:293`
- Displays bio at `:323-332`
- Displays social links at `:360-366`
- Supports office-hours appointment booking flow at `:392-510`

This is an important benchmark because the website already has:

- public profile loading,
- social links display,
- roles display,
- bio display,
- and office-hours booking integration.

---

## Flutter Current State

## Cross-cutting Flutter observations

### Flutter already has authenticated user identity available
Flutter auth state is capable of providing live user identity:

- `AuthAuthenticated` exists in `lib/bloc/auth/auth_state.dart:22-25`
- `UserDto` exists in `lib/models/auth_models.dart:299`
- It includes `fullName` at `:304`
- It includes `profilePictureUrl` at `:306`
- It includes `roles` at `:312`
- It exposes `displayName` at `:385`

This is important because many hardcoded Flutter names are not caused by lack of auth data. The data model already exists, but the UI is not using it.

### No Flutter self-profile API integration found
No working Flutter service usage was found for:

- `GET /users/profile`
- `PUT /users/profile`
- `GET /users/preferences`
- `PUT /users/preferences`
- `PATCH /users/password`

The only clear profile-related API integration found in Flutter is the **public profile** service at `lib/services/api/public_profile_service.dart:10`.

That means Flutter self-profile behavior is currently not parity with either backend or website.

---

## Student Flutter

### Student profile state is sample/local-only
In `lib/bloc/profile/profile_cubit.dart`:

- `loadProfile()` starts at `:10`
- It generates sample profile data via `_generateSampleProfile()` at `:16`
- `updateProfile()` is local-only at `:46`
- `changePassword()` is local-only at `:196`
- `exportData()` is local-only at `:218`
- `_generateSampleProfile()` starts at `:244`
- Sample user email is `alex.doe@university.edu` at `:249`
- Sample student fields include:
  - `studentId` at `:254`
  - `university` at `:255`
  - `major` at `:256`
  - `minor` at `:257`
  - `expectedGraduation` at `:260`
  - `dateOfBirth` at `:261`
  - `location` at `:262`
  - `gpa` at `:265`
  - `rank` at `:266`
  - `coursesEnrolled` at `:267`
  - `assignmentsCompleted` at `:268`

`lib/bloc/profile/profile_models.dart` also formalizes many fields not supported by the backend contract:

- `studentId` at `:13`
- `university` at `:14`
- `major` at `:15`
- `minor` at `:16`
- `expectedGraduation` at `:19`
- `dateOfBirth` at `:20`
- `location` at `:21`
- `gpa` at `:23`
- `rank` at `:24`
- `coursesEnrolled` at `:25`
- `assignmentsCompleted` at `:26`

### Student profile UI exists, but it is not backend-backed
In `lib/screens/student/profile/profile_screen.dart`:

- Profile displays email at `:228-230`
- Profile displays phone at `:234-236`
- Save action exists at `:440`
- Password change UI hooks into `ProfileCubit.changePassword()` at `:419-426`

In `lib/screens/student/profile/edit_profile_screen.dart`:

- Email controller exists at `:27`
- Phone controller exists at `:28`
- Location controller exists at `:29`
- Bio controller exists at `:30`
- University, student ID, major, minor, level, year, expected graduation controllers exist at `:34-40`
- Existing profile values are loaded into those controllers at `:73-84`
- Cover/profile image UI exists around `:180-210`
- Email field is editable at `:293-297`
- Phone field is editable at `:302-306`
- Location field is editable at `:313-315`
- Bio field is editable at `:321-322`
- University and student ID are editable at `:344-353`
- Major/minor/level/year are editable at `:363-398`
- Expected graduation is editable at `:408-409`
- Date of birth field exists at `:740-777`
- Save constructs an updated local profile at `:984-1024`
- Save only calls `context.read<ProfileCubit>().updateProfile(updatedProfile)` at `:1042`

### Student drawer/app bar identity is hardcoded and inconsistent with auth capability
In `lib/widgets/student/dashboard/student_drawer.dart`:

- Profile navigation goes to `/profile` at `:97`
- Drawer header name is hardcoded as `'Student User'` at `:154`
- Dashboard route item uses `/student-dashboard` at `:290`
- Profile route item uses `/profile` at `:410`
- Route handling compares against `/student-dashboard` at `:481`

In `lib/widgets/student/dashboard/student_app_bar.dart`:

- App bar hardcodes `'Amir'` at `:203`
- Profile tap goes to `/profile` at `:364`

In `lib/config/app_router.dart`:

- Actual student dashboard route is `/dashboard` at `:256`
- Actual student profile route is `/profile` at `:534`

### Student comparison verdict
Compared with the website:

- Flutter student has a richer standalone profile UI
- But it is still **functionally behind** because website already uses real `/users/profile` integration
- Flutter student edit screen exposes several fields that the backend does not support
- Flutter student name display in dashboard shell is not tied to auth state

Classification for student Flutter:

- **Partially implemented**: profile UI, edit UI, password UI, settings/security sections
- **Totally missing**: real self-profile API integration, preferences integration, real password-change API integration, dynamic name/avatar binding
- **Totally wrong**: editable email against unsupported update contract, wrong dashboard route `/student-dashboard`, mock identity values in drawer/app bar

---

## Instructor Flutter

### Instructor profile is almost entirely mock
In `lib/screens/instructor/profile/instructor_profile_screen.dart`:

- Mock name is `'Dr. Sarah Mitchell'` at `:21`
- Department is `'Computer Science'` at `:24`
- Office hours are `'Mon & Wed, 2-4 PM'` at `:27`
- Specialization is set at `:28`
- Biography text is hardcoded at `:30`
- Edit navigation goes to `/instructor/edit-profile` at `:114`
- Office hours are displayed again at `:478-479`
- Specialization is displayed at `:484`
- Profile photo change UI exists around `:937`
- Save/profile-updated UI exists at `:1009-1026`

In `lib/screens/instructor/profile/instructor_edit_profile_screen.dart`:

- Department controller defaults to `'Computer Science'` at `:38`
- Employee ID controller defaults to `'EMP-2010-001'` at `:40`
- Specialization controller exists at `:41`
- Office hours controller exists at `:45`
- Save action exists at `:151` and `:414-427`
- `_saveProfile()` contains only placeholder logic at `:522-526`

### Instructor dashboard identity is hardcoded
In `lib/widgets/instructor/dashboard/instructor_drawer.dart`:

- Profile navigation goes to `/instructor/profile` at `:99`
- Drawer header name is `'Dr. Ahmed Mohamed'` at `:156`
- Dashboard route item uses `/instructor-dashboard` at `:292`
- Profile item uses `/instructor/profile` at `:424-425`
- Route handling compares against `/instructor-dashboard` at `:508`

In `lib/widgets/instructor/dashboard/instructor_app_bar.dart`:

- App bar hardcodes `'Dr. Ahmed'` at `:170`
- Profile tap goes to `/instructor/profile` at `:331`

In `lib/config/app_router.dart`:

- Actual instructor dashboard route is `/instructor/dashboard` at `:649`
- Actual instructor profile route is `/instructor/profile` at `:931`

### Instructor comparison verdict
Compared with the website:

- Website instructor at least uses auth/live name in header/chat/shared profile
- Flutter instructor is still almost entirely local/mock
- Flutter exposes many staff profile fields that do not exist in the backend contract

Classification for instructor Flutter:

- **Partially implemented**: route structure, profile screen UI, edit screen UI
- **Totally missing**: real profile load/update, shared backend-backed profile behavior, dynamic header/drawer identity
- **Totally wrong**: wrong dashboard route `/instructor-dashboard`, hardcoded drawer/app bar names, editing unsupported staff fields as if persisted

---

## TA Flutter

### TA profile is mock and internally inconsistent
In `lib/screens/ta/profile/ta_profile_screen.dart`:

- File explicitly marks mock data at `:18`
- Mock name is `'Ahmed Hassan'` at `:20`
- Employee ID is `'TA-2024-001'` at `:24`
- Supervisor is `'Dr. Sarah Johnson'` at `:25`
- Join date is `'January 2024'` at `:26`
- Edit navigation goes to `/ta/edit-profile` at `:85`
- Displayed role is `'Teaching Assistant'` at `:215`
- Employee ID, department, supervisor, phone, join date are displayed at `:360-384`
- Bio is displayed at `:491`

In `lib/screens/ta/profile/ta_edit_profile_screen.dart`:

- Name controller defaults to `'Ahmed Hassan'` at `:55`
- Save action exists at `:181-183`
- Save button also exists at `:580-599`
- `_saveProfile()` starts at `:748` and is local/simulated

### TA drawer/app bar use a different hardcoded person
In `lib/widgets/ta/dashboard/ta_drawer.dart`:

- Profile navigation goes to `/ta/profile` at `:93`
- Drawer header name is `'Sarah Anderson'` at `:145`
- Profile route item exists at `:461-462`

In `lib/widgets/ta/dashboard/ta_app_bar.dart`:

- App bar hardcodes `'Sarah Anderson'` at `:171`
- Profile tap goes to `/ta/profile` at `:332`

### TA comparison verdict
Compared with the website:

- Website TA already uses live auth/profile identity in multiple places
- Flutter TA is significantly behind because it is still mock/local-only
- Flutter TA is also internally inconsistent because different screens use different hardcoded identities

Classification for TA Flutter:

- **Partially implemented**: profile and edit screen UI shells, route wiring
- **Totally missing**: backend profile load/update, dynamic identity usage, public/shared profile parity with website TA dashboard
- **Totally wrong**: TA profile uses `'Ahmed Hassan'` while TA drawer/app bar use `'Sarah Anderson'`; unsupported TA-only fields are treated as if real profile data

---

## Admin Flutter

### Admin profile is mock/local-only
In `lib/screens/admin/profile/admin_profile_screen.dart`:

- Mock profile map starts at `:25`
- Role is `'Super Administrator'` at `:30`
- Employee ID is `'ADM-001'` at `:32`
- Join date is set at `:33`
- Last login is set at `:34`
- Language is set at `:35`
- Timezone is set at `:36`
- Edit navigation goes to `/admin/edit-profile` at `:392` and `:420`
- Profile values are rendered from `_adminProfile` at `:413-417`, `:449-454`, `:459-485`, `:489-534`

In `lib/screens/admin/profile/admin_edit_profile_screen.dart`:

- Employee ID controller exists at `:31`
- Timezone controller exists at `:33`
- Mock/default values are set at `:62-65`
- `_saveProfile()` exists at `:89`
- Save button exists at `:212-223` and `:357-381`

### Admin shell identity does not use actual user name
In `lib/widgets/admin/dashboard/admin_drawer.dart`:

- Profile navigation goes to `/admin/profile` at `:88`
- Header uses `l10n.admin` at `:137`
- Role badge uses `l10n.adminRole` at `:155`
- Dashboard route is correctly `/admin/dashboard` at `:295`
- Profile route exists at `:453`

In `lib/widgets/admin/dashboard/admin_app_bar.dart`:

- App bar uses `l10n.admin` at `:164`
- Profile tap goes to `/admin/profile` at `:297`

### Admin comparison verdict
Compared with the website:

- Website admin is also only partial, but chat already uses `user?.fullName || 'Administrator'`
- Flutter admin remains mostly mock and does not even display the actual logged-in user identity in shell UI
- Admin edit fields such as employee ID, timezone, language, last login are outside the backend self-profile contract

Classification for admin Flutter:

- **Partially implemented**: route structure, profile UI, edit UI
- **Totally missing**: real self-profile API integration, dynamic admin name/avatar in shell UI
- **Totally wrong**: using role label instead of user identity in drawer/app bar, treating unsupported admin metadata as persisted self-profile fields

---

## Flutter Public Profile and Office-Hours Flow

### What is implemented
Flutter does have a real public-profile flow:

- `PublicProfileService.getPublicProfile()` exists at `lib/services/api/public_profile_service.dart:10`
- `CourseDetailBloc` loads public profile at `lib/features/courses/bloc/course_detail/course_detail_bloc.dart:322`
- `CourseInstructorInfoScreen` uses `profile?.role` at `lib/screens/student/course_instructor_info_screen.dart:188`
- It displays office location if present at `:225-229`

This is a real partial implementation and is one of the few areas where Flutter already talks to the backend profile system.

### Why it is still behind the website
`lib/models/student/public_profile_model.dart` is incomplete/inaccurate relative to the backend:

- It expects a single `role` field at `:8`
- It expects `profileImageUrl` at `:10`
- It expects `officeLocation` at `:11`
- Parsing uses `data['role'] ?? data['userType']` at `:42`
- Parsing uses `data['profileImageUrl'] ?? data['avatarUrl']` at `:44-45`
- Parsing uses `officeLocation` from `officeLocation/office/location` at `:47-48`

Problems relative to the backend contract:

- Backend returns `roles[]`, not a single `role`
- Backend returns `profilePictureUrl`, not `profileImageUrl` or `avatarUrl`
- Backend public profile includes `socialLinks`, `academicInterests`, and `skills`, but this Flutter model does not represent them

Impact:

- Role display may be blank or inaccurate
- Public profile image may not map correctly
- Flutter public profile is missing social links that website already shows
- Flutter public profile is missing interests/skills that backend already returns

Classification for Flutter public profile:

- **Partially implemented**: endpoint call, display screen, office-hours context usage
- **Totally missing**: social links rendering, interests/skills rendering, accurate roles array handling, correct profile picture mapping
- **Totally wrong**: JSON mapping assumptions do not match backend field names

---

## Comparative Gap Matrix

| Capability | Backend Support | Website Status | Flutter Status | Flutter Classification |
| --- | --- | --- | --- | --- |
| Load own profile (`/users/profile`) | Yes | Implemented | Not found in working self-profile flow | Totally missing |
| Update own profile (`/users/profile`) | Yes | Implemented for core fields | Local-only profile updates | Totally missing |
| Load public profile (`/users/:id/public`) | Yes | Implemented | Implemented | Partially implemented |
| Change password (`/users/password`) | Yes | Endpoint exists; website profile layer is closer to backend | Student UI is local-only | Partially implemented but backend integration missing |
| Preferences (`/users/preferences`) | Yes | Backend exists; website comparison not central here | No parity found in profile flow | Totally missing |
| Use authenticated full name in student shell | Available | Mostly yes | No, hardcoded | Totally wrong |
| Use authenticated full name in instructor shell | Available | Mostly yes | No, hardcoded | Totally wrong |
| Use authenticated full name in TA shell | Available | Mostly yes | No, hardcoded and inconsistent | Totally wrong |
| Use authenticated full name in admin shell | Available | Partial | No, role label only | Totally wrong |
| Bio editing | Yes | Implemented | Student local-only; other roles mock-only | Partially implemented |
| Phone editing | Yes | UI exists but website persistence is incomplete | Student local-only; others mock/local | Partially implemented |
| Social links | Yes | Public profile displays them | Missing in Flutter self/public profile parity | Totally missing |
| Skills/interests | Yes | Implemented in shared profile and public profile | Student self-profile has local-only data; public profile missing | Partially implemented |
| Profile picture URL | Yes | Partial | Public profile mapping wrong; self-profile not integrated | Partially implemented / wrong |
| Shared reusable dashboard profile component | N/A | Yes | No equivalent found | Totally missing |
| Student-only academic profile fields | No | Mostly placeholders | Local-only editor/data model | Wrong against backend contract |
| Staff/admin-only metadata fields | No | Mostly placeholders | Local-only editor/data model | Wrong against backend contract |
| Dashboard route consistency | N/A | Acceptable overall | Student and instructor route mismatches | Totally wrong |

---

## Role-by-Role Delta Between Website and Flutter

## Student
Website student profile is already connected to the real profile API for names, bio, interests, and skills, while Flutter student profile is still powered by sample data in `ProfileCubit`. Flutter student is ahead only in UI richness, not in correctness or integration.

Main delta:

- Website has real `/users/profile` read/update
- Flutter does not
- Website dashboard name uses auth user
- Flutter dashboard shell uses hardcoded names
- Flutter exposes unsupported editable fields like email, university, student ID, GPA-related data as if they are part of the real self-profile

## Instructor
Website instructor profile is still partial, but it already reuses shared profile infrastructure and live auth names. Flutter instructor remains mostly a standalone mock screen and mock edit form.

Main delta:

- Website uses shared profile tab with some real backend fields
- Flutter instructor profile/edit are mock/local
- Website header/chat mostly use live user full name
- Flutter header/drawer are hardcoded

## TA
Website TA already blends live profile/auth identity into dashboard and shared profile tab. Flutter TA is fully mock-driven and even disagrees with itself about who the TA is.

Main delta:

- Website TA current user name can come from live profile/auth
- Flutter TA uses inconsistent hardcoded names across screen vs shell
- Flutter TA has no real profile persistence at all

## Admin
Website admin is not clean, but it still integrates auth name in chat and uses the shared profile tab. Flutter admin is mostly a mock profile system and does not display the logged-in admin identity in shell UI.

Main delta:

- Website admin has at least partial auth-backed identity usage
- Flutter admin uses localized role label instead of actual user full name
- Flutter admin profile/edit contain unsupported admin metadata fields as if they are real self-profile fields

---

## Items That Are Partially Implemented in Flutter

- Student profile screen UI
- Student edit profile screen UI
- Student password/security/settings UI
- Role-specific profile routes for student, instructor, TA, admin
- Public profile retrieval for course/instructor info
- Office-hours context usage around public profile
- Auth user model already containing full name, roles, and profile picture URL

These items exist, but they are not yet aligned with the backend and website behavior.

---

## Items That Are Totally Missing in Flutter

- Real self-profile fetch using `/users/profile`
- Real self-profile update using `/users/profile`
- Real preferences fetch/update using `/users/preferences`
- Real password change integration using `/users/password`
- A shared reusable profile component or shared profile data flow comparable to website `DashboardProfileTab`
- Dynamic user name/avatar binding in drawers and app bars for student, instructor, TA, and admin
- Public profile support for `socialLinks`
- Public profile support for backend `academicInterests`
- Public profile support for backend `skills`
- Correct handling of backend `roles[]` in public profile model
- Correct handling of backend `profilePictureUrl` in public profile model

---

## Items That Are Totally Wrong or Misaligned in Flutter

- Student dashboard drawer uses `/student-dashboard` while router defines `/dashboard`
- Instructor dashboard drawer uses `/instructor-dashboard` while router defines `/instructor/dashboard`
- Student drawer name is hardcoded as `'Student User'`
- Student app bar name is hardcoded as `'Amir'`
- Instructor drawer name is hardcoded as `'Dr. Ahmed Mohamed'`
- Instructor app bar name is hardcoded as `'Dr. Ahmed'`
- TA profile screen uses `'Ahmed Hassan'` while TA drawer/app bar use `'Sarah Anderson'`
- Admin shell shows role label (`l10n.admin`) instead of actual authenticated user identity
- Student edit profile allows editing `email`, but backend `UpdateProfileDto` does not support email update
- Flutter public profile model expects `role`, `userType`, `profileImageUrl`, `avatarUrl` instead of matching backend `roles[]` and `profilePictureUrl`
- Many student/instructor/TA/admin fields are represented as if they are part of the persisted profile contract even though the backend profile contract does not support them

---

## Important Caveat: The Website Is Also Not a Perfect Reference
The website should be treated as the **current functional benchmark**, not as a perfect final design.

Known website limitations discovered during this investigation:

- Student profile page exposes phone/address and many academic fields without true backend persistence
- Shared profile tab does not fully expose backend-supported `socialLinks`
- Shared profile tab does not appear to fully integrate `profilePictureUrl`
- Instructor dashboard still has some hardcoded identity usage such as `Prof. Sarah Martinez`
- Instructor dashboard uses `user?.role` even though auth shape appears to use `roles[]`
- Admin dashboard header hardcodes `Department Head`

So, future planning should distinguish between:

- **parity with backend-supported truth**
- **parity with current website behavior**
- **website placeholders that should not be copied into Flutter as-is**

---

## Bottom-Line Assessment

### Student
Flutter student profile is **visually substantial but operationally incomplete**. It is mostly a local demo implementation and is behind the website in real backend integration.

### Instructor
Flutter instructor profile is **mostly mock** and is well behind the website in real identity/profile integration.

### TA
Flutter TA profile is **mostly mock and inconsistent**, and is behind the website both functionally and structurally.

### Admin
Flutter admin profile is **mostly mock** and uses generic admin labeling instead of actual user identity, leaving it behind the website baseline.

### Overall
The main strategic gap is not lack of screens. The screens already exist. The main gap is:

1. missing integration with the backend profile contract,
2. missing consistent usage of authenticated identity across dashboard shells,
3. incorrect modeling of fields that are not actually supported by the backend,
4. incomplete public-profile parity with the website.

---

## Key File References

### Backend
- `src/modules/auth/user-profile.controller.ts`
- `src/modules/auth/user-management.service.ts`
- `src/modules/auth/entities/user.entity.ts`
- `src/modules/auth/dto/user-management.dto.ts`

### Website
- `src/services/api/userService.ts`
- `src/components/shared/DashboardProfileTab.tsx`
- `src/pages/profile/ProfilePage.tsx`
- `src/pages/student-dashboard/StudentDashboard.tsx`
- `src/pages/instructor-dashboard/InstructorDashboard.tsx`
- `src/pages/ta-dashboard/TADashboard.tsx`
- `src/pages/admin-dashboard/AdminDashboard.tsx`
- `src/pages/student-dashboard/pages/PublicProfileView.tsx`
- `src/context/AuthContext.tsx`
- `src/services/api/authService.ts`

### Flutter
- `lib/bloc/profile/profile_cubit.dart`
- `lib/bloc/profile/profile_models.dart`
- `lib/screens/student/profile/profile_screen.dart`
- `lib/screens/student/profile/edit_profile_screen.dart`
- `lib/widgets/student/dashboard/student_drawer.dart`
- `lib/widgets/student/dashboard/student_app_bar.dart`
- `lib/screens/instructor/profile/instructor_profile_screen.dart`
- `lib/screens/instructor/profile/instructor_edit_profile_screen.dart`
- `lib/widgets/instructor/dashboard/instructor_drawer.dart`
- `lib/widgets/instructor/dashboard/instructor_app_bar.dart`
- `lib/screens/ta/profile/ta_profile_screen.dart`
- `lib/screens/ta/profile/ta_edit_profile_screen.dart`
- `lib/widgets/ta/dashboard/ta_drawer.dart`
- `lib/widgets/ta/dashboard/ta_app_bar.dart`
- `lib/screens/admin/profile/admin_profile_screen.dart`
- `lib/screens/admin/profile/admin_edit_profile_screen.dart`
- `lib/widgets/admin/dashboard/admin_drawer.dart`
- `lib/widgets/admin/dashboard/admin_app_bar.dart`
- `lib/models/auth_models.dart`
- `lib/bloc/auth/auth_state.dart`
- `lib/services/api/public_profile_service.dart`
- `lib/models/student/public_profile_model.dart`
- `lib/screens/student/course_instructor_info_screen.dart`
- `lib/features/courses/bloc/course_detail/course_detail_bloc.dart`
- `lib/config/app_router.dart`

