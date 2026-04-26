# Flutter Auth Phased Implementation Plan

Date: `2026-04-26`

Related source report: [AUTH_AUDIT_REPORT.md](/C:/Users/Friends/Desktop/Graduation/EduVerse/AUTH_AUDIT_REPORT.md)

## Purpose

This document is a Flutter-only implementation plan for fixing and completing auth in the Flutter project at:

- `C:\Users\Friends\Desktop\Graduation\EduVerse`

This plan must be executed **without editing**:

- Backend project
- Website frontend project

The implementation must make the Flutter app:

- logically correct
- aligned with the **actual backend auth contract**
- aligned with the **intended website auth flow**
- free from the known auth mistakes documented in the audit

This is a plan only. It does **not** execute the work.

---

## Hard Constraints

## Constraint 1: Flutter-only changes

Another Codex implementing this plan must **not modify**:

- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`
- `C:\Users\Friends\Desktop\Graduation\Frontend\Eduverse-Frontend`

Only the Flutter project may be changed.

## Constraint 2: Do not copy website bugs

The Flutter implementation should use the website as a product reference, but it must **not reproduce** website auth bugs such as:

- fake logout by navigation only
- unprotected role routes
- trusting local cached auth without backend validation
- first-role-only routing if it creates fragile multi-role behavior
- mock login/dev bypasses as production behavior

## Constraint 3: Prefer actual backend runtime contract over outdated Flutter assumptions

The Flutter app currently contains old assumptions that conflict with the audit, especially around:

- registration response shape
- email verification flow
- refresh token response shape
- forgot-password behavior

The implementation must follow the audited backend behavior, not the outdated assumptions currently embedded in Flutter.

---

## Source of Truth

When there is ambiguity, use this priority order:

1. Actual audited backend runtime behavior from `AUTH_AUDIT_REPORT.md`
2. Valid website behavior that is not itself wrong
3. Flutter’s existing reusable architecture, when compatible with 1 and 2

If website behavior and backend behavior disagree, and the website behavior is a known bug or partial implementation, the Flutter app should follow the **logically correct** behavior described in the audit.

---

## What This Plan Covers

This plan covers auth-related work for all five roles:

- Student
- Instructor
- TA
- Admin
- IT Admin

It includes:

- login
- logout
- remember-me handling
- session restore on app reopen
- `/auth/me` bootstrap validation
- refresh-token flow
- auth/role route guarding
- role-aware dashboard landing
- forgot password
- reset password
- public registration policy in Flutter
- admin-created user flows in Flutter
- profile
- password change
- preferences parity with backend
- admin/IT account-management and role-management auth surfaces in Flutter

It also explicitly defines what should be removed, hidden, or de-scoped because it is unsupported or incorrect.

---

## Current Flutter Auth Snapshot

The Flutter app already has useful auth infrastructure, but it is inconsistent and partially based on outdated assumptions.

## Existing strengths

- `AuthBloc` exists and is implemented
  - `lib/bloc/auth/auth_bloc.dart`
- secure token storage exists
  - `lib/services/storage_service.dart`
- `ApiService` exists with auth endpoints
  - `lib/services/api_service.dart`
- `AuthInterceptor` exists with refresh-token retry behavior
  - `lib/services/auth_interceptor.dart`
- `CoreApiClient` exists with a second refresh-capable auth layer
  - `lib/services/api/core_api_client.dart`
- role-specific dashboards already exist
  - student, instructor, TA, admin, IT admin
- many dashboard drawers already dispatch `LogoutRequested`

## Current high-risk Flutter issues

- splash startup always routes to `/login` even when auth exists
  - `lib/screens/splash/splash_screen.dart`
- router has no global auth or role redirect
  - `lib/config/app_router.dart`
- login screen still contains demo credential bypasses
  - `lib/screens/auth/login_screen.dart`
- login pre-check uses `isEmailVerifiedAndExists()` before real login
  - `lib/screens/auth/login_screen.dart`
- register screen exposes public multi-role registration and assumes email verification flow
  - `lib/screens/auth/register_screen.dart`
- forgot-password screen does not call the real forgot-password flow correctly
  - `lib/screens/auth/forgot_password_screen.dart`
- email verification flow is implemented in Flutter even though audited backend/website parity does not support it as a real end-to-end feature
  - `lib/screens/auth/email_verification_screen.dart`
- `AuthCheckRequested` restores cached user without server validation
  - `lib/bloc/auth/auth_bloc.dart`
- some logout entry points still just navigate to `/login`
  - student/instructor/TA/IT settings screens
- profile settings are partly local-only and not connected to backend preferences
  - `lib/bloc/profile/*`
  - settings screens under student/instructor/TA/IT admin
- admin role/permission management is static/mock instead of live backend-driven
  - `lib/screens/admin/roles/admin_roles_screen.dart`

---

## Target End State

After implementation, Flutter auth should behave like this:

1. App opens.
2. If there is no stored session, user lands on onboarding/login.
3. If there is a stored session:
   - the app validates the session using `/auth/me`
   - if needed, the refresh flow runs automatically
   - if validation succeeds, the app lands on the correct dashboard for the user’s role set
   - if validation fails permanently, the app clears auth and returns to login
4. Every protected route is guarded by auth.
5. Every role-specific route is guarded by role.
6. Every logout entry point dispatches real logout and clears session data.
7. Forgot-password and reset-password use the real backend endpoints.
8. Public registration, if still exposed, is **student-only** and does not expose privileged role selection.
9. Profile, change-password, and backend preferences are wired consistently.
10. Admin/IT auth-adjacent management screens in Flutter use real backend endpoints where those endpoints actually exist.
11. Unsupported backend features such as real 2FA or real email verification are not presented as working live features in Flutter.

---

## Implementation Principles

## Principle 1: Single auth source of truth

`AuthBloc` should be the single source of truth for:

- current authenticated user
- startup auth validation
- logout
- session death
- refresh-driven auth recovery

UI screens should not implement their own auth logic beyond dispatching bloc events and reacting to bloc state.

## Principle 2: One session contract

The app should standardize on:

- secure storage for tokens
- cached user snapshot for quick boot
- server validation through `/auth/me`
- automatic refresh through 401 handling

Avoid duplicate inconsistent auth logic between:

- `ApiService`
- `AuthInterceptor`
- `CoreApiClient`
- individual screens

## Principle 3: Client-side guards are UX guards, not security

Since backend authorization issues cannot be fixed in this task, the Flutter app must still implement:

- auth guards
- role guards
- admin/IT feature gating

But implementation comments and planning should acknowledge that Flutter route restrictions are not a true security boundary.

## Principle 4: De-scope unsupported auth illusions

If a feature is not actually supported end-to-end by backend + audited product behavior, Flutter should not pretend it is real.

Examples:

- email verification
- live 2FA
- live connected devices
- live login history

These should be hidden, labeled, or deferred rather than shipped as fake working auth.

---

## Feature Decision Matrix

| Feature | Flutter Action |
| --- | --- |
| Login | Keep and fix |
| Remember me | Implement properly |
| Logout | Standardize and fix all entry points |
| Startup persistence | Rebuild around `/auth/me` validation |
| Refresh-token flow | Keep and harden |
| Route protection | Add globally |
| Role protection | Add globally |
| Forgot password | Fix and complete |
| Reset password | Add/complete |
| Public registration | Restrict to student-only or hide from public entry path |
| Email verification screen/flow | Remove from primary auth flow |
| Profile | Keep and align |
| Change password | Keep and harden |
| Preferences (`/users/preferences`) | Add real service + state wiring |
| 2FA | Do not implement as live backend feature |
| Connected devices | Do not present as live backend-backed auth feature |
| Login history | Do not present as live backend-backed auth feature |
| Admin user management | Keep live, expand carefully |
| Admin role/permission management | Convert from mock/static to live |
| IT admin auth management surfaces | Add or reuse real live admin-role/user management with IT role gating |
| Demo credential bypass | Remove from production auth flow |

---

## Phased Plan

## Phase 0: Preparation and Contract Realignment

### Goal

Before editing behavior, align the Flutter auth layer with the audited backend contract and explicitly remove outdated assumptions.

### Why this phase is first

Several Flutter files currently encode the wrong backend contract. If implementation starts at UI or router level first, the later service-layer corrections will force rework.

### Primary files to inspect and update during implementation

- `lib/models/auth_models.dart`
- `lib/services/api_service.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/bloc/auth/auth_event.dart`
- `lib/bloc/auth/auth_state.dart`
- `Flutter_Auth_API_Docs.md`

### Tasks

1. Normalize the real backend auth response assumptions.
   - Login returns:
     - `accessToken`
     - `refreshToken`
     - `user`
   - Refresh returns:
     - `accessToken`
     - `refreshToken`
     - and may or may not include `user`, so the implementation must not depend on it
   - Register should be treated according to the audited backend contract, not the old Flutter assumption that registration is an automatic auth success path.

2. Remove the outdated assumption that registration requires email verification.
   - `AuthBloc._onRegisterRequested()` currently emits `AuthEmailVerificationNeeded`.
   - That flow should be redesigned.
   - Another Codex should choose one of two final behaviors:
     - student self-registration ends with success message and returns to login
     - or student self-registration logs in only if runtime API proves tokens are truly returned by the deployed backend
   - Preferred path for stability:
     - success message
     - no auto-login
     - go back to login

3. Remove the outdated assumption that email verification is required for login.
   - `LoginScreen` currently calls `ApiService.isEmailVerifiedAndExists()` before normal login.
   - This pre-check must be removed.
   - Login should go directly through `AuthBloc -> ApiService.login`.

4. Mark unsupported auth endpoints as de-scoped.
   - `verifyEmail`
   - `resendVerificationEmail`
   - any auth flow depending on them

5. Decide the public registration policy.
   - Because the audit found the backend register endpoint unsafe if role is exposed publicly, Flutter must not expose privileged role selection publicly.
   - Final Flutter public registration policy should be:
     - student-only if public registration is kept
     - or hidden entirely from the public login entry path if product wants website parity

### Deliverables of this phase

- Clean auth model contract
- Clear registration policy
- Clear list of supported vs unsupported auth flows

### Acceptance criteria

- No Flutter code path assumes email verification is part of the real auth lifecycle.
- No Flutter code path assumes registration returns a verified signed-in session unless runtime contract is explicitly confirmed and safely handled.
- Public auth screens no longer expose privileged role selection.

---

## Phase 1: Rebuild Startup Session Validation

### Goal

Make app reopen / cold-start auth behave correctly.

### Current problem

`AuthCheckRequested` only checks local storage, and splash currently routes to login regardless of auth state.

### Primary files

- `lib/bloc/auth/auth_bloc.dart`
- `lib/services/storage_service.dart`
- `lib/services/api_service.dart`
- `lib/screens/splash/splash_screen.dart`
- `lib/main.dart`

### Tasks

1. Redesign `AuthCheckRequested`.
   - Current behavior:
     - if access token exists and user exists in storage => emit `AuthAuthenticated(user)`
   - Required behavior:
     - if no tokens => `AuthUnauthenticated`
     - if tokens exist:
       - try `/auth/me`
       - let interceptor/core client refresh automatically if access token is expired
       - if `/auth/me` succeeds:
         - persist fresh user snapshot
         - emit `AuthAuthenticated(serverUser)`
       - if it fails permanently:
         - clear auth storage
         - emit `AuthUnauthenticated`

2. Add explicit storage helpers if needed.
   - Suggested additions to `StorageService`:
     - `hasSession()`
     - `clearAuthOnly()`
     - `clearAllAuthAndRelatedCaches()`
     - optional `saveLastResolvedRole()` only if needed for analytics, not routing

3. Fix splash routing.
   - `SplashScreen` currently sends both authenticated and unauthenticated users to `/login`.
   - Replace that with:
     - authenticated => role-resolved dashboard
     - unauthenticated => onboarding or login, based on existing app product decision

4. Ensure startup does not navigate before auth check settles.
   - Splash should wait for the first terminal auth state.
   - Avoid racing splash animation against auth initialization.

5. Align session expiry handling.
   - `SessionExpiryNotifier` already exists.
   - Ensure the logout path triggered from session expiry:
     - clears tokens
     - clears cached user
     - clears chat cache
     - navigates to login exactly once

### Acceptance criteria

- Closing and reopening the app with a valid session lands on the correct dashboard.
- Closing and reopening with an expired access token but valid refresh token still restores the session.
- Closing and reopening with a dead refresh token returns the user to login and clears local auth.
- Splash no longer hardcodes `/login` for authenticated users.

---

## Phase 2: Add Global Auth Guards and Role Guards

### Goal

Make routing behavior correct for all roles.

### Current problem

`GoRouter` has many role-specific routes but no redirect logic or guard system.

### Primary files

- `lib/config/app_router.dart`
- possibly new guard/helper files under:
  - `lib/config/`
  - `lib/common/auth/`
  - `lib/common/navigation/`
- `lib/services/demo_credentials.dart` if dashboard resolution helpers are reused

### Tasks

1. Introduce a centralized route guard strategy.
   - Prefer GoRouter redirect-based protection.
   - Required route categories:
     - public
     - authenticated-only
     - role-restricted

2. Define public routes.
   - likely:
     - `/`
     - `/onboarding`
     - `/login`
     - `/forgot-password`
     - possibly `/register` if public registration remains visible
     - reset-password route once added

3. Define authenticated routes.
   - all student, instructor, TA, admin, IT admin dashboards
   - profile
   - settings
   - feature routes requiring active auth session

4. Define role-restricted route groups.
   - Student routes
   - Instructor routes
   - TA routes
   - Admin routes
   - IT admin routes

5. Define dashboard resolution strategy.
   - Do **not** depend on backend role order.
   - Use deterministic priority:
     - `it_admin`
     - `admin`
     - `instructor`
     - `teaching_assistant`
     - `student`
   - This matches the current useful helper style in `DemoCredentials.getDashboardRouteForUser()` and avoids website-style first-role fragility.

6. Add redirect rules for invalid role access.
   - Example:
     - student enters `/admin/users` => redirect to student dashboard
     - instructor enters `/it-admin/dashboard` => redirect to instructor dashboard

7. Add explicit handling for unauthenticated deep links.
   - Preserve intended target only if the route is public or if a secure post-login redirect mechanism is intentionally added.
   - Do not silently allow access to protected pages.

### Acceptance criteria

- Unauthenticated users cannot enter protected routes.
- Logged-in users cannot enter role-incompatible routes.
- Logged-in users cannot remain on login/register pages unless logout just occurred.
- Multi-role users always land on a deterministic primary dashboard.

---

## Phase 3: Correct Login and Logout End-to-End

### Goal

Make login/logout behavior fully correct from every Flutter entry point.

### Primary files

- `lib/screens/auth/login_screen.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/services/api_service.dart`
- `lib/widgets/student/dashboard/student_drawer.dart`
- `lib/widgets/instructor/dashboard/instructor_drawer.dart`
- `lib/widgets/ta/dashboard/ta_drawer.dart`
- `lib/widgets/admin/dashboard/admin_drawer.dart`
- `lib/widgets/it_admin/shared/it_drawer.dart`
- settings screens that still navigate-only logout:
  - `lib/screens/student/settings/settings_screen.dart`
  - `lib/screens/instructor/settings/instructor_settings_screen.dart`
  - `lib/screens/ta/settings/ta_settings_screen.dart`
  - `lib/screens/it_admin/settings/it_settings_screen.dart`

### Tasks

1. Remove demo credential bypass from production login flow.
   - Current login screen allows role-based demo auth without real backend login.
   - Replace with one of:
     - fully remove
     - guard behind a compile-time dev flag not enabled in production
   - Preferred implementation:
     - remove from normal builds

2. Remove `isEmailVerifiedAndExists()` pre-check.
   - Login should dispatch `LoginRequested` directly.
   - Backend login result must be the single authority.

3. Add real remember-me UI.
   - Backend supports `rememberMe`.
   - Flutter `LoginRequest` already has `rememberMe`.
   - Add a checkbox/switch to `LoginScreen`.
   - Persist the field only as part of the login request, not as a local auth truth source.

4. Standardize successful login handling.
   - Save tokens
   - save user snapshot
   - emit `AuthAuthenticated`
   - route using the centralized role dashboard resolver

5. Standardize logout across all entry points.
   - Every logout UI must dispatch `LogoutRequested`.
   - No screen may navigate directly to `/login` without dispatching auth logout first.
   - Introduce a shared helper if needed:
     - `performLogout(BuildContext context)`
   - Ensure settings screens stop doing navigation-only logout.

6. Prevent post-logout stale-state leakage.
   - Clear:
     - access token
     - refresh token
     - cached user
     - chat cache
     - any auth-dependent local screen caches if present

7. Make logout idempotent.
   - If refresh token is missing or backend logout fails, local logout must still complete cleanly.

### Acceptance criteria

- Login uses the real backend call only.
- Remember-me value reaches backend.
- Every logout button in the app performs real bloc-driven logout.
- After logout, reopening the app does not restore the old session.

---

## Phase 4: Fix Public Registration Policy and Screen Flow

### Goal

Make Flutter registration safe and aligned with actual intended product behavior.

### Current problem

The current Flutter register screen:

- exposes role selection publicly
- includes privileged roles
- assumes email verification flow
- does not use the selected role correctly in the request
- is based on an unsafe backend capability and incorrect audited assumptions

### Primary files

- `lib/screens/auth/register_screen.dart`
- `lib/models/auth_models.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/services/api_service.dart`
- `lib/config/app_router.dart`

### Required product decision for implementation

Use this default implementation policy unless the project owner says otherwise:

- keep public registration route if desired by product
- make it **student-only**
- remove public role selector entirely
- do **not** expose admin/instructor/TA creation publicly

### Tasks

1. Remove the public role dropdown from the register screen.
   - Delete the UI for:
     - `student`
     - `instructor`
     - `ta`
     - `admin`
   - Hardcode student role if the request needs a role field.
   - If backend defaults to student cleanly, omit role entirely for public sign-up.

2. Rebuild register completion flow.
   - Preferred behavior:
     - submit student registration
     - show success message
     - navigate back to login
   - Do not navigate to email verification.

3. Remove `AuthEmailVerificationNeeded` as a required public registration state.
   - Keep the state only if another non-auth feature still uses it intentionally.
   - Otherwise remove it cleanly from bloc/state/screen logic.

4. Ensure public registration is not a privileged account creation tool.
   - No public UI may create:
     - instructor
     - teaching assistant
     - admin
     - IT admin

5. Keep admin-created user creation separate.
   - Admin-only user creation can use a separate protected flow later in Phase 7.

### Acceptance criteria

- Public registration no longer exposes privileged roles.
- Register success no longer routes into fake email verification.
- Public registration and login together form a coherent student-only flow.

---

## Phase 5: Fix Forgot Password and Add Reset Password Flow

### Goal

Make password recovery actually work end-to-end.

### Current problem

Flutter currently uses the wrong flow:

- `ForgotPasswordScreen` calls `emailExistsForPasswordReset()`
- that method hits `/auth/resend-verification-email`
- it does not call the real forgot-password contract correctly

### Primary files

- `lib/screens/auth/forgot_password_screen.dart`
- `lib/services/api_service.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/config/app_router.dart`
- add new screen if needed:
  - `lib/screens/auth/reset_password_screen.dart`

### Tasks

1. Remove the resend-verification-based email existence check.
   - `ForgotPasswordScreen` should call the real forgot-password path:
     - `AuthBloc -> ForgotPasswordRequested`
     - `ApiService.forgotPassword(email)`

2. Align forgot-password UX with backend behavior.
   - Backend intentionally avoids disclosing whether the email exists.
   - Flutter should show a generic success state such as:
     - “If this email exists, a reset link/code has been sent.”
   - Do not build existence-check UX around a separate endpoint.

3. Add or complete a reset-password screen.
   - Inputs:
     - token
     - new password
     - confirm password
   - If the app receives deep links later, this screen should be reusable.
   - If deep linking is not implemented now, the route should still exist for manual token entry.

4. Wire reset-password through `ResetPasswordRequested`.
   - on success:
     - show success
     - force unauthenticated state
     - route to login

5. Validate password requirements on Flutter side.
   - Match backend constraints as closely as possible.

### Acceptance criteria

- Forgot-password uses `/auth/forgot-password`.
- Reset-password uses `/auth/reset-password`.
- Recovery flow no longer depends on email-verification endpoints.

---

## Phase 6: Remove Unsupported Email Verification as a Real Auth Dependency

### Goal

Stop treating email verification as a live required auth feature in Flutter.

### Why this is necessary

The audit concluded that email verification is not an implemented end-to-end auth feature across backend + website. Flutter must not block or shape auth around a feature that is not actually supported.

### Primary files

- `lib/screens/auth/email_verification_screen.dart`
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/register_screen.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/bloc/auth/auth_event.dart`
- `lib/bloc/auth/auth_state.dart`
- `lib/services/api_service.dart`
- `lib/config/app_router.dart`

### Tasks

1. Remove email-verification routing from the normal auth funnel.
2. Remove all forced navigation to `/verify-email`.
3. Remove login-screen copy and retry flows that assume unverified email is a real blocking state.
4. Remove resend-verification behavior from normal auth UX.
5. Decide final treatment of `EmailVerificationScreen`.
   - Preferred:
     - remove the screen from router and auth flow
   - Acceptable fallback:
     - leave route inaccessible and clearly deprecated until fully removed

### Acceptance criteria

- A normal student/instructor/TA/admin/IT admin auth flow no longer depends on email verification.
- No public Flutter auth action calls `/auth/verify-email` or `/auth/resend-verification-email` as part of standard auth.

---

## Phase 7: Profile, Password, and Preferences Parity

### Goal

Bring Flutter account management up to parity with real backend-supported auth-adjacent features.

### What backend actually supports according to audit

- `/auth/me`
- `/users/profile` get/put
- `/users/password` patch
- `/users/preferences` get/put

### Current Flutter status

- Profile get/update exists
- Change password exists in shared profile flow
- Preferences are mostly local state only
- Connected devices and other security panels are sample/local-only

### Primary files

- `lib/services/api/user_profile_service.dart`
- `lib/bloc/profile/profile_models.dart`
- `lib/bloc/profile/profile_cubit.dart`
- `lib/bloc/profile/profile_state.dart`
- `lib/screens/shared/profile/shared_profile_screen.dart`
- `lib/screens/shared/profile/shared_edit_profile_screen.dart`
- student settings screens under:
  - `lib/screens/student/settings/`
- instructor settings:
  - `lib/screens/instructor/settings/instructor_settings_screen.dart`
- TA settings:
  - `lib/screens/ta/settings/ta_settings_screen.dart`
- IT settings:
  - `lib/screens/it_admin/settings/it_settings_screen.dart`

### Tasks

1. Add a real preferences model and service.
   - Create backend preference DTO model matching `/users/preferences`.
   - Add:
     - `getPreferences()`
     - `updatePreferences()`
   - Keep this separate from visual-only theme/device preferences where necessary.

2. Expand `ProfileCubit` or create a dedicated preferences cubit.
   - Recommended approach:
     - keep profile data and preferences related but separate in state if complexity grows
   - Avoid overloading `AppSettings` with values the backend does not actually own.

3. Map backend-owned settings vs device-only settings.
   - Backend-owned:
     - user preferences returned by `/users/preferences`
   - Device-only:
     - local display preferences if backend does not own them
   - Unsupported-as-live:
     - real 2FA
     - real connected devices
     - real login history

4. Keep change-password in the shared profile flow, but harden it.
   - Ensure success state is clear.
   - Decide whether password change should trigger:
     - just success toast
     - or optional auth refresh/user reload
   - Do not log the user out automatically unless product explicitly wants that behavior.

5. Rework screens that currently imply fake backend support.
   - Student settings
   - Instructor settings
   - TA settings
   - IT settings

6. Unsupported security panels should be handled intentionally.
   - For `2FA`, `Connected Devices`, `Login History`:
     - either hide
     - or mark “Coming soon / Not yet connected”
     - or keep only if clearly labeled local-only and not misleading
   - Do not leave them looking production-live while they are fake.

### Acceptance criteria

- `/users/profile` and `/users/password` are fully wired and stable.
- `/users/preferences` exists as a real Flutter-backed feature.
- Settings screens no longer misrepresent unsupported auth features as live.

---

## Phase 8: Admin and IT Auth-Adjacent Management Parity

### Goal

Make Flutter’s admin and IT auth/account-management surfaces align with the real backend capabilities that already exist.

### Scope note

This phase is about auth-adjacent administration:

- user creation and account status
- user listing/search
- role assignment/removal
- role and permission management

It is not a full admin-platform rewrite.

### Current status

- Admin student management has real live service coverage
  - `lib/services/api/admin_student_management_service.dart`
  - `lib/screens/admin/users/admin_user_management_screen.dart`
- Admin roles screen is still static/mock
  - `lib/screens/admin/roles/admin_roles_screen.dart`
- IT admin does not have equivalent live role/user management flows wired into auth administration

### Primary files

- `lib/services/api/admin_student_management_service.dart`
- add new services such as:
  - `lib/services/api/admin_user_management_service.dart`
  - `lib/services/api/admin_roles_service.dart`
  - `lib/services/api/admin_permissions_service.dart`
- `lib/screens/admin/users/admin_user_management_screen.dart`
- `lib/screens/admin/users/admin_add_new_user_screen.dart`
- `lib/screens/admin/roles/admin_roles_screen.dart`
- `lib/config/app_router.dart`
- IT admin screens/routes under:
  - `lib/screens/it_admin/`

### Tasks

1. Split student-only management from generic user-management if needed.
   - The current admin student service is useful but too narrow for full role-aware account management.
   - Add a general admin user service that can:
     - list users
     - search users
     - get user details
     - update user
     - update user status
     - delete user
     - assign role
     - remove role
     - read permissions if needed by UI

2. Build a live roles/permissions service layer.
   - Wrap backend endpoints for:
     - list roles
     - create role
     - update role
     - delete role
     - list permissions
     - assign/remove permissions to role
   - Parse backend responses with defensive normalization.

3. Convert `AdminRolesScreen` from static permissions to live backend data.
   - Replace `_getDefaultPermissions()` mock matrix with service-driven data.
   - Support:
     - loading existing roles
     - selecting a role
     - viewing permissions
     - saving permission changes

4. Add IT-admin access path to the same capability.
   - Options:
     - reuse the same management screen behind IT-admin routes
     - or create thin IT-admin wrappers that route to the same shared feature
   - Preferred:
     - shared implementation + role-specific route shells

5. Make admin-created user creation safe in Flutter.
   - Since backend create-user coverage is imperfect, the Flutter plan should:
     - keep privileged creation only inside protected admin/IT flows
     - never expose privileged creation publicly
   - If the implementation uses `/auth/register` for admin-created users because that is the available backend path, the UI must still be protected by Flutter role guards.

6. Add client-side role gating for admin/IT screens.
   - Admin-only or IT-admin-only entry points should not be accessible to students/instructors/TAs.

### Acceptance criteria

- Admin user management stays live and expands cleanly.
- Admin role management stops being static mock UI.
- IT admin gets real access to the same auth-adjacent management surfaces through Flutter role guards.

---

## Phase 9: Remove or Quarantine Remaining Mock Auth Behavior

### Goal

Ensure Flutter auth is production-correct rather than partly demo-correct.

### Primary files

- `lib/services/demo_credentials.dart`
- `lib/screens/auth/login_screen.dart`
- any auth-related screen using local-only security illusions
- any routes or screens hardcoded for fake auth assumptions

### Tasks

1. Remove demo credentials from normal login UX.
2. If demo support must remain, move it behind:
   - debug-only compilation
   - hidden dev menu
   - explicit developer flag
3. Remove commented legacy auth code that can confuse future work.
4. Audit string labels and user messages for outdated flows:
   - verification messaging
   - registration messaging
   - forgot-password messaging

### Acceptance criteria

- No production auth path depends on demo behavior.
- Auth code no longer advertises flows that the real backend does not support.

---

## Phase 10: Testing, Verification, and Regression Coverage

### Goal

Leave another Codex with a clear verification target so auth changes are safe.

### Existing relevant test coverage

- `test/models/auth_models_test.dart`

There is currently very limited dedicated auth-flow coverage.

### New tests to add

#### Unit tests

- `AuthResponse`, `RegistrationResponse`, `TokenRefreshResponse` parsing
- role normalization and role-priority route resolution
- preferences model parsing

#### Service tests

- `ApiService.login`
- `ApiService.logout`
- `ApiService.forgotPassword`
- `ApiService.resetPassword`
- `ApiService.getCurrentUser`
- `ApiService.refreshToken`
- new preferences service methods
- new admin role/user management service methods

#### Bloc tests

- `AuthCheckRequested`:
  - no tokens
  - valid session
  - expired access token but valid refresh
  - dead refresh token
- `LoginRequested`
- `LogoutRequested`
- `ForgotPasswordRequested`
- `ResetPasswordRequested`
- registration success behavior

#### Router tests

- unauthenticated access to protected routes redirects
- role mismatch redirects
- authenticated startup goes to correct dashboard

#### Widget tests

- login screen submits remember-me correctly
- register screen no longer exposes privileged roles
- forgot-password screen uses real flow
- logout from settings screen dispatches auth logout instead of navigation-only logout

### Manual QA checklist

1. Login as student and reopen app.
2. Login as instructor and reopen app.
3. Login as TA and reopen app.
4. Login as admin and reopen app.
5. Login as IT admin and reopen app.
6. Trigger access-token expiry and confirm refresh recovery.
7. Trigger refresh-token expiry and confirm forced logout.
8. Use every logout entry point.
9. Change password and verify result.
10. Open settings screens and confirm unsupported auth features are not falsely live.
11. Verify admin/IT role-restricted screens reject non-authorized roles in Flutter routing.

### Acceptance criteria

- All auth-critical flows have automated coverage.
- Manual QA confirms consistent behavior across all five roles.

---

## Recommended Execution Order for Another Codex

Another Codex should implement in this order:

1. Phase 0
2. Phase 1
3. Phase 2
4. Phase 3
5. Phase 4
6. Phase 5
7. Phase 6
8. Phase 7
9. Phase 8
10. Phase 9
11. Phase 10

Do not start with admin role screens first. The session lifecycle, routing, and public auth corrections must be stabilized before expanding role-management surfaces.

---

## Explicit Non-Goals

The implementing Codex should **not** do the following as part of this auth plan:

- modify backend endpoint behavior
- fix backend authorization defects
- fix website auth code
- implement real backend 2FA
- implement real backend email verification
- implement real backend connected-device management unless backend endpoints are later added
- implement unrelated non-auth admin features

---

## Final Implementation Summary

This plan intentionally pushes Flutter toward:

- real session validation
- real refresh-token lifecycle
- real route/role protection
- correct logout everywhere
- corrected registration policy
- correct forgot/reset-password flow
- real profile/password/preferences parity
- real admin/IT auth-adjacent management where backend endpoints already exist

It also intentionally removes or deactivates auth flows that are currently misleading in Flutter:

- demo login as a normal path
- public privileged-role registration
- email verification as a real dependency
- fake live 2FA/security/session-management panels

If another Codex follows the phases in order, the Flutter project should end up with an auth system that is materially more correct than the current website implementation while still staying aligned with the real backend contract and the product’s role structure.
