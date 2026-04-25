# Flutter User Profile Fix Implementation Plan

## Purpose
This document is the **implementation plan only** for fixing and completing the **Flutter project** user profile and profile-related identity features based on the investigation report:

- [user_profile_backend_website_flutter_gap_report.md](/D:/Graduation/EduVerse/edu_verse/difference_documentation/user_profile_backend_website_flutter_gap_report.md)

This plan is written so another Codex can execute it directly inside the Flutter repository without needing to re-investigate the backend or website codebases.

---

## Hard Constraints

### Repository scope
Only the Flutter project may be changed:

- `D:\Graduation\EduVerse\edu_verse`

Do **not** modify:

- Backend: `D:\Graduation\backend\last_backend\EduVerse_Backend`
- Website frontend: `D:\Graduation\frontend_tarek\Eduverse-Frontend`

### Source-of-truth rule
Implementation must follow this priority order:

1. **Backend contract is the data truth**
2. **Website is the UX/flow reference**
3. **Flutter mock behavior must be replaced when it conflicts with either**

### Important interpretation rule
If the website shows a field that is **not supported by the backend profile contract**, Flutter should **not implement it as a persisted editable profile field**.

That means fields such as:

- `studentId`
- `university`
- `major`
- `minor`
- `level`
- `year`
- `expectedGraduation`
- `dateOfBirth`
- `location`
- `gpa`
- `rank`
- `department`
- `office`
- `officeHours`
- `employeeId`
- `supervisor`
- `timezone`
- `language`

must **not** be treated as backend-backed self-profile fields unless a separate existing Flutter API already supports them.

### Goal of this plan
Bring Flutter to parity with the **backend-supported user profile contract** and the **working website logic/flow**, while removing or correcting the current Flutter mock/misaligned implementation.

---

## Final Target State

At the end of implementation, the Flutter app should have:

- Real self-profile loading from `/users/profile`
- Real self-profile update to `/users/profile`
- Real public profile parsing from `/users/:id/public`
- Dynamic display of authenticated user name/avatar in drawer/app bar/dashboard shell for student, instructor, TA, and admin
- A consistent Flutter profile flow for all target roles based on the backend-supported generic profile fields
- Public profile parity with the website for role display, bio, social links, and office-hours context
- Removal of local-only mock identity/profile behavior where it conflicts with real data
- Correct routing for dashboard/profile navigation

The implementation should **not** attempt to force unsupported website placeholder fields into the Flutter persisted profile flow.

---

## Backend Contract to Implement in Flutter

The Flutter implementation must align to this backend self-profile contract:

### Supported self-profile read/write fields

- `firstName`
- `lastName`
- `phone`
- `profilePictureUrl`
- `bio`
- `socialLinks`
- `academicInterests`
- `skills`

### Supported self-profile read-only values returned by backend

- `userId`
- `email`
- `roles`
- `status`
- `emailVerified`
- `createdAt`
- `profileCompleteness`

### Supported public profile fields

- `userId`
- `email`
- `firstName`
- `lastName`
- `fullName`
- `profilePictureUrl`
- `bio`
- `socialLinks`
- `academicInterests`
- `skills`
- `roles`

### Supported related endpoints

- `GET /users/profile`
- `PUT /users/profile`
- `GET /users/:id/public`
- `PATCH /users/password`

### Lower-priority backend-only endpoint

- `GET /users/preferences`
- `PUT /users/preferences`

These preferences endpoints are backend-supported, but website parity for them was not established in the report. They should be treated as **optional Phase 6 work**, not part of the minimum parity path.

---

## What Must Be Fixed in Flutter

### Replace mock self-profile data
Current student, instructor, TA, and admin self-profile screens rely on local/mock/sample profile data. These flows must be refactored to use real backend data.

### Replace hardcoded identity in shell UI
Current drawers and app bars hardcode names such as:

- `Student User`
- `Amir`
- `Dr. Ahmed Mohamed`
- `Dr. Ahmed`
- `Sarah Anderson`
- localized `admin`

All of these must be replaced with authenticated user data from `AuthBloc`.

### Fix incorrect route usage
Current Flutter shell components use nonexistent routes such as:

- `/student-dashboard`
- `/instructor-dashboard`

They must be aligned to the actual router:

- `/dashboard`
- `/instructor/dashboard`
- `/ta/dashboard`
- `/admin/dashboard`

### Correct public profile model mismatch
Current Flutter public profile logic expects:

- `role`
- `userType`
- `profileImageUrl`
- `avatarUrl`

It must instead correctly handle:

- `roles[]`
- `profilePictureUrl`

and add support for:

- `socialLinks`
- `academicInterests`
- `skills`

### Remove or demote unsupported editable fields
Flutter edit profile screens currently allow editing many unsupported fields. These must be:

- removed from persisted forms,
- hidden,
- or clearly converted into non-editable/local-only sections if they already belong to another real feature area.

For this implementation, the safer default is:

- **remove unsupported fields from edit profile**
- keep only backend-supported fields in the save payload

---

## Recommended Implementation Strategy

### Architecture direction
Do **not** continue maintaining separate mock profile systems for each role.

Instead:

1. Build one **shared Flutter self-profile data layer** around the backend contract
2. Build one **shared Flutter profile state layer**
3. Use **role-specific wrapper screens** only for layout/navigation differences
4. Render the same real profile data for student, instructor, TA, and admin

This mirrors the backend reality and is closer to the website’s `DashboardProfileTab` approach.

### Reuse existing Flutter infrastructure
The implementation should build on:

- `CoreApiClient`
- `AuthBloc`
- `UserDto`
- existing `GoRouter`
- existing `PublicProfileService`
- existing `ProfileCubit` only if it can be safely refactored; otherwise replace it cleanly

### Do not preserve broken behavior for parity
The website currently has some partial/broken placeholder behavior. Flutter should **match website flow**, but should **not copy broken placeholder data persistence**.

Example:

- Website shows phone in some profile UIs but does not always persist it
- Backend supports phone
- Flutter should implement phone **correctly**

Example:

- Website shows `address` or `department` in some role profile contexts
- Backend profile contract does not support those fields
- Flutter should **not** implement them as real self-profile edit fields

---

## Phase Summary

| Phase | Goal | Outcome |
| --- | --- | --- |
| Phase 0 | Lock scope and data contract | Prevent wrong implementation direction |
| Phase 1 | Build shared profile API/data layer | Real profile service/models exist |
| Phase 2 | Replace shell identity + fix routing | Drawers/app bars show real user, routes work |
| Phase 3 | Migrate student self-profile | Student profile becomes backend-backed |
| Phase 4 | Fix public profile parity | Instructor/TA public profile matches backend/website |
| Phase 5 | Migrate instructor, TA, admin self-profile | Non-student roles stop using mocks |
| Phase 6 | Integrate password flow and optional preferences | Profile-related security/settings become real where appropriate |
| Phase 7 | Cleanup, regression hardening, and QA | Mocks removed, behavior stable |

---

## Phase 0: Scope Lock and Contract Freeze

### Objective
Before editing Flutter code, define the exact implementation boundaries so the work does not drift into unsupported fields or backend assumptions.

### Tasks

- Re-read the report and extract the final “allowed persisted fields” list.
- Confirm that the implementation will target only:
  - self-profile
  - edit profile
  - shell identity display
  - public profile
  - password change
- Mark backend-only preferences as optional, not required for first parity pass.
- Decide whether to refactor the existing `ProfileCubit` or replace it with a cleaner shared profile cubit/bloc.

### Recommended decision
Refactor only if it is low-risk. Otherwise:

- keep the existing `ProfileCubit` filename if many screens depend on it,
- but replace its internals and model contract,
- or introduce a new profile state layer and migrate screens incrementally.

### Deliverables

- Implementation note in the PR or local doc comments describing:
  - supported fields
  - unsupported fields
  - routes to fix
  - screens to migrate

### Acceptance criteria

- The execution Codex can clearly answer:
  - which fields are persisted,
  - which are display-only,
  - which must be removed,
  - which screens are in scope.

---

## Phase 1: Build Shared Flutter Profile Data Layer

### Objective
Create the real Flutter API/service/model foundation for self-profile and public-profile parity.

### Files to inspect or modify

- `lib/services/api/core_api_client.dart`
- `lib/services/api/public_profile_service.dart`
- `lib/bloc/profile/profile_cubit.dart`
- `lib/bloc/profile/profile_models.dart`
- `lib/bloc/profile/profile_state.dart`
- `lib/models/auth_models.dart`
- `lib/main.dart`

### New files likely needed

- `lib/services/api/user_profile_service.dart`
- `lib/models/profile/user_self_profile_model.dart`
- `lib/models/profile/update_user_profile_request.dart`
- `lib/models/profile/change_password_request.dart`
- optionally `lib/models/profile/user_profile_preferences_model.dart`

### Implementation tasks

- Add a new `UserProfileService` using `CoreApiClient`.
- Implement:
  - `Future<UserSelfProfileModel> getProfile()`
  - `Future<UserSelfProfileModel> updateProfile(UpdateUserProfileRequest request)`
  - `Future<void> changePassword(ChangePasswordRequest request)`
  - optional `getPreferences()` / `updatePreferences()` only if Phase 6 is reached
- Define a backend-accurate `UserSelfProfileModel` for:
  - `userId`
  - `email`
  - `firstName`
  - `lastName`
  - `fullName`
  - `phone`
  - `profilePictureUrl`
  - `bio`
  - `socialLinks`
  - `academicInterests`
  - `skills`
  - `roles`
  - `status`
  - `emailVerified`
  - `createdAt`
  - `profileCompleteness`
- Define `UpdateUserProfileRequest` with only backend-supported mutable fields.
- Add request sanitization logic that trims strings and filters empty values.
- Reuse the payload-cleaning style already present in:
  - `lib/services/api/admin_student_management_service.dart`
- Ensure `phone` validation matches the app’s existing style where possible.

### Required design decisions

#### Self-profile model should be generic, not student-specific
Do not keep the current student-only fields in the main profile model.

#### Roles should use the same role shape as auth
For consistency, profile responses should map roles into the same `RoleModel` shape already used in `UserDto`.

#### Social links should be modeled as real data
Represent `socialLinks` as a typed map or typed value object, but keep the JSON mapping tolerant of missing keys.

### `ProfileCubit` migration plan

- Stop generating sample profile data
- Replace `_generateSampleProfile()`
- Replace local-only `updateProfile()`
- Replace local-only `changePassword()`
- Add real loading, saving, success, and error states
- Keep any settings/device/export features separate from real self-profile state if they are not backend-backed

### `main.dart` integration tasks

- Instantiate `UserProfileService` beside the other services
- Inject it into the profile state layer
- Ensure the profile state layer can refresh after login and after successful profile update

### Deliverables

- A real self-profile service
- A real self-profile model
- A migrated profile cubit/bloc that no longer depends on sample data

### Acceptance criteria

- No self-profile screen depends on `_generateSampleProfile()`
- Save/update logic only sends backend-supported fields
- Profile state can load from the API and handle failure cleanly

---

## Phase 2: Fix Shared Identity Display and Routing

### Objective
Make drawer/app bar/dashboard shell identity consistent and dynamic for all target roles.

### Files to inspect or modify

- `lib/widgets/student/dashboard/student_drawer.dart`
- `lib/widgets/student/dashboard/student_app_bar.dart`
- `lib/widgets/instructor/dashboard/instructor_drawer.dart`
- `lib/widgets/instructor/dashboard/instructor_app_bar.dart`
- `lib/widgets/ta/dashboard/ta_drawer.dart`
- `lib/widgets/ta/dashboard/ta_app_bar.dart`
- `lib/widgets/admin/dashboard/admin_drawer.dart`
- `lib/widgets/admin/dashboard/admin_app_bar.dart`
- `lib/config/app_router.dart`
- `lib/models/auth_models.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/bloc/auth/auth_state.dart`

### Implementation tasks

- Replace all hardcoded names with values from `AuthBloc`.
- Use `UserDto.displayName` as the primary shell display name.
- Use `UserDto.initials` for avatar fallback initials.
- Use `UserDto.profilePictureUrl` for avatar image if present.
- Add a shared helper or shared widget for:
  - current user display name
  - initials
  - avatar image fallback

### Route fixes required

- Student shell must use `/dashboard`, not `/student-dashboard`
- Instructor shell must use `/instructor/dashboard`, not `/instructor-dashboard`
- Ensure profile menu items navigate to:
  - `/profile`
  - `/instructor/profile`
  - `/ta/profile`
  - `/admin/profile`
- Ensure drawer active-item logic compares against real router paths

### Admin-specific requirement
Admin shell must stop displaying only `l10n.admin` as the identity. It should show:

- the actual authenticated user name
- optionally the role label as secondary text

### TA-specific requirement
TA shell and TA profile screens must stop using different hardcoded names.

### Deliverables

- Shared current-user identity helper/widget
- Correct dashboard/profile route usage
- Dynamic identity across all target roles

### Acceptance criteria

- Logging in as each role shows the real authenticated user name in drawer and app bar
- Avatar initials come from the real user name
- No hardcoded profile name strings remain in targeted shell files
- All profile and dashboard navigation works without route errors

---

## Phase 3: Migrate Student Self-Profile to Real Backend Data

### Objective
Turn the existing student self-profile flow into a backend-backed implementation that matches the backend contract and website logic.

### Files to inspect or modify

- `lib/screens/student/profile/profile_screen.dart`
- `lib/screens/student/profile/edit_profile_screen.dart`
- `lib/bloc/profile/profile_cubit.dart`
- `lib/bloc/profile/profile_models.dart`
- `lib/bloc/profile/profile_state.dart`

### Current student issues to eliminate

- local sample profile data
- editable email field
- editable unsupported academic fields
- local-only password change
- local-only update/save behavior
- local-only avatar/cover assumptions that do not map to backend

### Student profile target behavior

#### Display on profile screen
Show only real or safely derived values:

- full name
- email
- phone
- bio
- roles
- profile completeness
- academic interests
- skills
- social links if added to the self-profile screen
- avatar/profile image if `profilePictureUrl` exists

#### Edit on profile screen
Allow editing only:

- first name
- last name
- phone
- bio
- academic interests
- skills
- optionally social links
- optionally profile picture URL if there is an existing image-entry pattern

#### Do not allow editing

- email
- studentId
- university
- major
- minor
- level
- year
- expectedGraduation
- dateOfBirth
- location
- GPA
- rank
- enrolled-course counters
- assignment counters

### Student UI restructuring tasks

- Audit the current student profile sections and remove unsupported fields from edit mode.
- Decide whether unsupported academic/stat cards should:
  - be removed entirely,
  - be hidden until a real data source exists,
  - or remain only if another real service in Flutter already supplies them.

### Recommended decision
For this profile implementation pass:

- remove unsupported academic profile edit fields from the save form,
- remove unsupported summary values if they are mock-only,
- keep the screen focused on real self-profile data.

### Save flow tasks

- On save, build an `UpdateUserProfileRequest`
- Send it to `/users/profile`
- Update local profile state with the server response
- If the response changes first/last name or profile picture, refresh any dependent shell UI if necessary

### Auth synchronization requirement
Because shell identity and profile screens both depend on user identity:

- after successful profile update, trigger either:
  - a local sync from profile state into UI consumers, or
  - `AuthBloc` refresh if the app architecture relies on `UserDto`

Recommended safer option:

- add a lightweight `RefreshUserDataRequested` or equivalent if it already exists and works,
- otherwise update shell identity from profile state only where needed.

### Deliverables

- Real student profile screen
- Real student edit profile screen
- No sample student profile dependency

### Acceptance criteria

- Student profile loads from backend
- Editing name/phone/bio/interests/skills persists successfully
- Unsupported fields are not editable as if they were real
- Student shell name updates correctly after profile changes

---

## Phase 4: Bring Public Profile to Website Parity

### Objective
Fix the Flutter public profile flow so it matches the backend contract and the website public profile behavior.

### Files to inspect or modify

- `lib/services/api/public_profile_service.dart`
- `lib/models/student/public_profile_model.dart`
- `lib/features/courses/bloc/course_detail/course_detail_bloc.dart`
- `lib/features/courses/bloc/course_detail/course_detail_state.dart`
- `lib/screens/student/course_instructor_info_screen.dart`

### Current public profile issues to fix

- expects `role` instead of `roles[]`
- expects `profileImageUrl` or `avatarUrl` instead of `profilePictureUrl`
- does not represent `socialLinks`
- does not represent `academicInterests`
- does not represent `skills`

### Target public profile behavior

#### Data model
Refactor public profile parsing to support:

- `userId`
- `email`
- `firstName`
- `lastName`
- `fullName`
- `profilePictureUrl`
- `bio`
- `socialLinks`
- `academicInterests`
- `skills`
- `roles`

#### UI behavior
On the instructor/TA info screen:

- display name correctly
- derive a readable role label from `roles`
- display bio
- display social links if present
- display avatar/profile image from `profilePictureUrl`
- keep office-hours booking integration intact

### Recommended model strategy
Either:

- replace `PublicProfileModel` with a backend-accurate version,

or:

- keep the filename but fully refactor the internals and JSON mapping.

### UI parity notes
The website public profile screen displays:

- roles
- bio
- social links
- office-hours actions

Flutter should at minimum match these.

### Deliverables

- Correct public profile model
- Correct public profile rendering
- No field-name mismatch with backend contract

### Acceptance criteria

- Public profile loads correctly from backend JSON
- Role label does not depend on nonexistent `role` field
- Social links render when returned by backend
- Public profile picture renders from `profilePictureUrl`
- Office-hours flow still works

---

## Phase 5: Migrate Instructor, TA, and Admin Self-Profile Flows

### Objective
Replace the role-specific mock profile systems for instructor, TA, and admin with a shared backend-backed profile implementation, while preserving each role’s route and general navigation structure.

### Files to inspect or modify

- `lib/screens/instructor/profile/instructor_profile_screen.dart`
- `lib/screens/instructor/profile/instructor_edit_profile_screen.dart`
- `lib/screens/ta/profile/ta_profile_screen.dart`
- `lib/screens/ta/profile/ta_edit_profile_screen.dart`
- `lib/screens/admin/profile/admin_profile_screen.dart`
- `lib/screens/admin/profile/admin_edit_profile_screen.dart`
- any role-specific profile widgets these screens depend on
- shared profile state layer from Phase 1

### Core rule for non-student roles
Even though the screens are role-specific, the persisted self-profile data remains the same backend generic profile contract.

That means instructor, TA, and admin should all persist only:

- first name
- last name
- phone
- profile picture URL
- bio
- social links
- academic interests
- skills

### Instructor migration tasks

- Remove hardcoded profile map values such as:
  - name
  - department
  - office hours
  - specialization
  - education
- Convert screen to load shared self-profile data
- Convert edit screen to save only supported fields
- Remove or hide unsupported editable staff metadata such as:
  - department
  - employeeId
  - specialization
  - office hours
  - office
- If desired, keep a role label such as “Instructor” derived from authenticated role, not from local mock data

### TA migration tasks

- Remove hardcoded TA profile map
- Remove mismatch between TA screen identity and TA shell identity
- Convert TA profile and edit screens to the shared self-profile source
- Remove unsupported editable fields such as:
  - employeeId
  - supervisor
  - joinDate
  - labs managed
  - department

### Admin migration tasks

- Remove hardcoded admin profile map
- Replace local admin edit form with backend-supported fields only
- Remove unsupported admin self-profile edit fields such as:
  - employeeId
  - timezone
  - language
  - joinDate
  - lastLogin
  - admin role text as persisted field
- If desired, retain some admin account metadata only if it comes from a real existing service elsewhere in Flutter; otherwise omit it

### UI structure recommendation
To avoid duplication, create shared profile sections that can be reused by all roles:

- profile header section
- identity/contact section
- bio section
- interests section
- skills section
- social links section
- save/error/loading footer section

Then keep each role’s screen as a thin wrapper that:

- sets title,
- sets route,
- optionally changes visual styling,
- but uses the same data and same edit rules.

### Deliverables

- Instructor self-profile is no longer mock
- TA self-profile is no longer mock
- Admin self-profile is no longer mock
- Shared profile UI sections exist or shared logic exists

### Acceptance criteria

- Instructor, TA, and admin profiles load real backend profile data
- Their edit flows persist only backend-supported fields
- No conflicting hardcoded role-person identities remain
- The screens do not present unsupported fields as editable persisted profile data

---

## Phase 6: Password Change Integration and Optional Preferences

### Objective
Complete profile-related account actions that already exist in Flutter UI but are still local-only or incomplete.

### Files to inspect or modify

- `lib/screens/student/profile/profile_screen.dart`
- role-specific profile screens if they also expose password actions
- `lib/bloc/profile/profile_cubit.dart`
- `lib/services/api/user_profile_service.dart`
- optionally settings screens if any should delegate to the same password flow

### Password-change tasks

- Replace local-only `changePassword()` implementation with a real call to `PATCH /users/password`
- Ensure request validation occurs before sending:
  - current password required
  - new password required
  - confirmation matches
- Surface backend error messages cleanly
- Reuse existing success messaging patterns in Flutter

### Preferences tasks
Only do this if time remains after parity work and only if a clear Flutter UI target exists.

If implemented:

- create a preferences model matching backend response
- decide which existing settings screens should read/write backend account preferences
- do not force unrelated device-only settings into backend profile preferences

### Recommendation
Treat password change as **required** and preferences as **optional**.

### Deliverables

- Real password-change flow
- Optional backend account preferences wiring

### Acceptance criteria

- Password change succeeds against backend for supported roles
- UI no longer reports success from local-only fake logic
- Preferences work only if mapped to a real Flutter settings surface

---

## Phase 7: Cleanup, Regression Hardening, and QA

### Objective
Remove obsolete mock profile behavior and verify that the migrated implementation is stable across roles.

### Cleanup tasks

- Remove or quarantine dead code paths that generate sample profile data
- Remove hardcoded mock names in targeted profile/shell files
- Remove obsolete fields from profile models that no longer belong to persisted self-profile
- Remove unused controllers tied only to deleted unsupported fields
- Ensure no lingering route references remain to:
  - `/student-dashboard`
  - `/instructor-dashboard`

### Validation tasks

- Verify no role-specific profile screen still depends on local maps containing fake person data
- Verify shell components always render safely when auth state is loading or unavailable
- Verify profile update does not break avatar/name rendering in shell UI
- Verify public profile still works when optional fields are absent

### Recommended test coverage

#### Unit tests

- `UserSelfProfileModel.fromJson`
- `UpdateUserProfileRequest.toJson`
- `PublicProfileModel.fromJson`
- phone/sanitization helpers
- role label resolution from `roles[]`

#### Bloc/Cubit tests

- profile load success
- profile load error
- profile update success
- profile update error
- password change success/error

#### Widget tests

- shell widgets render authenticated user name
- profile screen shows loading/success/error states
- edit screen removes unsupported fields from save payload behavior
- public profile screen renders social links and bio when present

#### Manual QA matrix

- Student login
- Instructor login
- TA login
- Admin login
- Edit own profile for each role
- Return to dashboard and confirm updated display name/avatar
- Open public profile from course/instructor context
- Book office hours after public profile load
- Trigger password change from profile UI

### Deliverables

- Cleaned codebase
- Regression checklist
- Tested migrated profile system

### Acceptance criteria

- No targeted role relies on mock self-profile data
- No targeted shell uses hardcoded user identity
- Public profile parsing matches backend payload
- All targeted routes and profile actions work end-to-end

---

## Detailed File-by-File Execution Guide

## Group A: Core profile data layer

### Likely create

- `lib/services/api/user_profile_service.dart`
- `lib/models/profile/user_self_profile_model.dart`
- `lib/models/profile/update_user_profile_request.dart`
- `lib/models/profile/change_password_request.dart`

### Likely modify

- `lib/services/api/public_profile_service.dart`
- `lib/models/student/public_profile_model.dart`
- `lib/bloc/profile/profile_cubit.dart`
- `lib/bloc/profile/profile_state.dart`
- `lib/main.dart`

### Expected outcomes

- no mock data source
- one backend-accurate shared profile contract in Flutter

## Group B: Shell identity

### Modify

- `lib/widgets/student/dashboard/student_drawer.dart`
- `lib/widgets/student/dashboard/student_app_bar.dart`
- `lib/widgets/instructor/dashboard/instructor_drawer.dart`
- `lib/widgets/instructor/dashboard/instructor_app_bar.dart`
- `lib/widgets/ta/dashboard/ta_drawer.dart`
- `lib/widgets/ta/dashboard/ta_app_bar.dart`
- `lib/widgets/admin/dashboard/admin_drawer.dart`
- `lib/widgets/admin/dashboard/admin_app_bar.dart`

### Expected outcomes

- all targeted roles show live identity from auth state

## Group C: Student profile flow

### Modify

- `lib/screens/student/profile/profile_screen.dart`
- `lib/screens/student/profile/edit_profile_screen.dart`

### Expected outcomes

- student profile/edit are real and backend-backed

## Group D: Public profile flow

### Modify

- `lib/models/student/public_profile_model.dart`
- `lib/services/api/public_profile_service.dart`
- `lib/screens/student/course_instructor_info_screen.dart`
- `lib/features/courses/bloc/course_detail/course_detail_bloc.dart`

### Expected outcomes

- website-level public profile parity for backend-supported data

## Group E: Instructor, TA, admin self-profile screens

### Modify

- `lib/screens/instructor/profile/instructor_profile_screen.dart`
- `lib/screens/instructor/profile/instructor_edit_profile_screen.dart`
- `lib/screens/ta/profile/ta_profile_screen.dart`
- `lib/screens/ta/profile/ta_edit_profile_screen.dart`
- `lib/screens/admin/profile/admin_profile_screen.dart`
- `lib/screens/admin/profile/admin_edit_profile_screen.dart`

### Expected outcomes

- no mock profile maps
- all three roles consume shared profile logic

## Group F: Routing

### Modify

- `lib/config/app_router.dart`
- any drawer/app bar/menu files using wrong hardcoded route constants

### Expected outcomes

- all dashboard/profile routes are valid and consistent

---

## Execution Order Recommendation

The implementation should be done in this exact order:

1. Phase 1 data layer
2. Phase 2 shell identity and route fixes
3. Phase 3 student self-profile
4. Phase 4 public profile
5. Phase 5 instructor/TA/admin self-profile
6. Phase 6 password integration
7. Phase 7 cleanup and QA

This order matters because:

- shell UI depends on real auth/profile identity usage
- student profile is the easiest place to validate the new data layer
- public profile is already partially integrated and can be fixed next
- instructor/TA/admin should reuse the now-stable shared profile implementation instead of inventing new per-role logic

---

## Parallelization Guidance for Another Codex

If implementation is split across multiple agents, use these independent workstreams:

### Workstream 1
Core profile service, models, cubit/bloc, and `main.dart` wiring

### Workstream 2
Shell identity and route corrections

### Workstream 3
Public profile model/service/screen corrections

### Workstream 4
Student self-profile migration

### Workstream 5
Instructor/TA/admin screen migration after Workstream 1 stabilizes

Do **not** let multiple workers edit the same profile state/model files at the same time.

---

## Risks and Mitigations

## Risk 1: Breaking screens that depend on the current student-heavy `ProfileCubit`
Mitigation:

- migrate incrementally,
- keep compatibility adapters temporarily if needed,
- remove old fields only after screens are updated.

## Risk 2: Name updates do not reflect in drawer/app bar after save
Mitigation:

- define one explicit refresh strategy before coding:
  - either refresh auth user,
  - or make shell components depend on the shared profile state,
  - but do not leave them disconnected.

## Risk 3: Public profile UI breaks when backend omits optional fields
Mitigation:

- parse all optional arrays/maps defensively,
- show sections only when data exists.

## Risk 4: Team accidentally reintroduces unsupported fields into save payload
Mitigation:

- centralize payload construction in `UpdateUserProfileRequest`
- do not build raw profile update maps in individual widgets

## Risk 5: Role screens diverge again after migration
Mitigation:

- move shared sections/widgets into shared profile components
- keep role wrappers thin

---

## Explicit Non-Goals for This Plan

- No backend controller/service/entity/DTO changes
- No website frontend changes
- No persistence for unsupported placeholder fields without an existing real Flutter API source
- No attempt to redesign the entire profile UX beyond what is needed for parity and correctness
- No mandatory IT Admin implementation in this plan unless the execution team chooses to extend the shared approach later

---

## Definition of Done

This plan is considered fully implemented when all of the following are true inside the Flutter project:

- Student, instructor, TA, and admin drawers/app bars show the real authenticated user name and avatar/initials
- Student, instructor, TA, and admin self-profile screens load real backend profile data
- Edit profile screens persist only backend-supported fields
- Flutter no longer pretends unsupported fields are part of the persisted self-profile
- Student public profile / instructor info flow correctly parses and displays backend public profile data, including social links and roles
- Password change is no longer local-only
- Wrong dashboard routes are removed
- Major mock profile maps and hardcoded identity strings are removed from targeted role files

---

## Recommended Output Artifact for the Implementing Codex

When another Codex executes this plan, the final implementation report should summarize:

- phases completed
- files created
- files modified
- unsupported fields removed or demoted
- routes fixed
- tests run
- remaining follow-up items, if any

