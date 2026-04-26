# EduVerse Auth Audit Report

Date: `2026-04-26`

## Scope

This report compares the current authentication and authorization implementation across:

- Backend: `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`
- Website frontend: `C:\Users\Friends\Desktop\Graduation\Frontend\Eduverse-Frontend`

The goal is to document how auth currently works for these roles:

- Student
- Instructor
- TA (`teaching_assistant`)
- Admin
- IT Admin (`it_admin`)

This report focuses on:

- Login
- Logout
- Session persistence after refresh / browser close / reopen
- Current-user restoration
- Token refresh / expiry handling
- Route protection
- Role protection / authorization
- Registration / account creation
- Password reset
- Profile / preferences / password-change features related to auth
- 2FA / email-verification-related auth work

This is an investigation report only. It is intentionally written to be used later as the input for a fix/implementation plan.

---

## Status Legend

- `Working`: implemented end-to-end and behavior generally matches intent
- `Partially implemented`: some parts exist, but the flow is incomplete, inconsistent, or not enforced end-to-end
- `Missing`: expected feature is not implemented in the relevant layer
- `Wrong`: implemented behavior is incorrect, unsafe, or contradicts the expected auth model
- `Mock/UI-only`: frontend UI exists, but it does not actually use real backend auth logic

---

## Executive Summary

The backend already contains a real auth core: JWT login, refresh tokens, session records, `/auth/me`, logout, password reset, user profile endpoints, user preferences endpoints, and password-change endpoints. However, the backend has serious authorization weaknesses:

- The public registration endpoint accepts an optional role and is not restricted to `student`, which appears to allow creation of privileged accounts if the caller supplies another valid role.
- A large set of admin/user-management endpoints are protected only by JWT authentication and are missing effective role enforcement, even though their API docs say they require `ADMIN` or `IT_ADMIN`.

The frontend, by contrast, has only a partial real auth integration:

- Real login exists.
- Local session persistence exists through `localStorage`.
- Real logout exists in `AuthService`, but the main dashboard pages usually do not call it.
- Route protection is effectively missing.
- Role-based access control in routing is missing.
- Token refresh exists in code but is not actually used automatically.
- Several role dashboards rely partly or heavily on mock-mode behavior.
- Several auth-adjacent settings screens are UI-only and do not connect to real backend auth features.

In short:

- Backend auth core: `Partially implemented`, with major authorization/security defects.
- Frontend auth integration: `Partially implemented`, but several critical pieces are either missing or wrong.
- End-to-end auth parity between backend and website: `Not achieved`.

---

## Overall Comparison

| Area | Backend | Frontend Website | Assessment |
| --- | --- | --- | --- |
| Login | Real JWT login implemented | Real login form implemented | `Partially implemented end-to-end` |
| Logout | Real endpoint exists and deletes refresh-token session | Service exists, but dashboards usually only navigate to `/login` | `Wrong end-to-end` |
| Persist session after refresh/reopen | Session records + refresh tokens exist | `localStorage` restores user/token without server validation | `Partially implemented` |
| Access-token expiry handling | Backend supports refresh-token exchange | Frontend does not auto-refresh on 401/expiry | `Missing end-to-end` |
| `/auth/me` current-user retrieval | Implemented | Used only in some places, not central bootstrapping | `Partially implemented` |
| Role-based route protection | Backend has role concepts and guards | Frontend routes are not protected by auth or role | `Missing / Wrong` |
| Admin/IT authorization | Intended in docs, only partially enforced in code | UI access is also not protected | `Wrong` |
| Password reset | Implemented | No connected forgot/reset flow found | `Missing on frontend` |
| Change password | Implemented | No proper end-to-end usage found | `Missing / Mock/UI-only` |
| Preferences | Implemented | Only partial usage found; some settings screens are local-only | `Partially implemented` |
| 2FA | Entity exists only | Student/instructor UI exists, but not wired | `Missing end-to-end` |
| Email verification | Entity/migration exists | No real end-to-end usage found | `Missing end-to-end` |

---

## Auth Architecture: Current State

## Backend Auth Model

The backend auth design is centered around:

- Access token JWTs
- Refresh token JWTs
- A `sessions` table storing refresh-token sessions
- A `users` table with roles, status, last login, and soft-delete fields
- Role-based authorization using `RolesGuard` and `@Roles(...)`

Relevant backend files:

- `src/modules/auth/auth.service.ts`
- `src/modules/auth/auth.controller.ts`
- `src/modules/auth/strategies/jwt.strategy.ts`
- `src/modules/auth/guards/jwt-auth.guard.ts`
- `src/modules/auth/guards/roles.guard.ts`
- `src/modules/auth/user-management.controller.ts`
- `src/modules/auth/user-management.service.ts`
- `src/modules/auth/user-profile.controller.ts`
- `src/modules/auth/entities/user.entity.ts`
- `src/modules/auth/entities/role.entity.ts`
- `src/modules/auth/entities/session.entity.ts`

Important backend data model details:

- Roles enum includes:
  - `student`
  - `instructor`
  - `teaching_assistant`
  - `admin`
  - `it_admin`
  - `department_head`
  - Reference: `src/modules/auth/entities/role.entity.ts:12-18`
- Session entity stores:
  - `sessionToken`
  - `ipAddress`
  - `userAgent`
  - `deviceType`
  - `expiresAt`
  - `rememberMe`
  - Reference: `src/modules/auth/entities/session.entity.ts:21-36`
- User entity stores:
  - `status`
  - `emailVerified`
  - `lastLoginAt`
  - `deletedAt`
  - `roles`
  - Reference: `src/modules/auth/entities/user.entity.ts:70-97`

## Frontend Auth Model

The website auth model is centered around:

- `AuthService` storing tokens and user in `localStorage`
- `AuthContext` exposing `user`, `isAuthenticated`, `login`, `logout`
- API client logic that injects `Authorization` headers
- Dashboard route navigation based on role

Relevant frontend files:

- `src/services/api/authService.ts`
- `src/services/api/client.ts`
- `src/context/AuthContext.tsx`
- `src/pages/auth/LoginPage.tsx`
- `src/App.jsx`
- `src/hooks/useLiveApiSession.ts`

Important frontend auth details:

- Local bootstrapping reads the stored user directly from `localStorage`
  - Reference: `src/context/AuthContext.tsx:21`
- `isAuthenticated` is derived from `!!user`
  - Reference: `src/context/AuthContext.tsx:64`
- Role-based dashboard routing uses only the first role in `user.roles`
  - Reference: `src/services/api/authService.ts:118-138`
- `refreshAccessToken()` exists in code
  - Reference: `src/services/api/authService.ts:63-69`
- No automatic refresh flow was found in request/response handling
  - Reference: `src/services/api/client.ts:180-192`

---

## End-to-End Flow Analysis

## 1. Login Flow

### Backend behavior

`/auth/login` is implemented and real.

Backend login flow:

1. Find user by email
2. Validate password
3. Reject login if `user.status !== active`
4. Update `lastLoginAt`
5. Generate:
   - access token
   - refresh token
   - session row in `sessions`
6. Return `{ accessToken, refreshToken, user }`

Evidence:

- Login method: `src/modules/auth/auth.service.ts:87-113`
- Token generation/session creation: `src/modules/auth/auth.service.ts:272-328`

Remember-me handling is implemented on the backend:

- Access token expiry:
  - `1h` normally
  - `24h` when `rememberMe = true`
- Refresh token expiry:
  - `7d` normally
  - `30d` when `rememberMe = true`
- Session row stores `rememberMe`

Evidence:

- `src/modules/auth/auth.service.ts:283-307`

### Frontend behavior

The login page uses the real login service:

- `AuthService.login(...)` posts to `/auth/login`
- Tokens and user are saved to `localStorage`

Evidence:

- `src/services/api/authService.ts:33-46`
- Login form submission: `src/pages/auth/LoginPage.tsx:49-73`

### Gaps / issues

#### 1.1 Remember-me support exists in backend, but the website login page does not appear to expose it

- Backend supports `rememberMe`.
- `AuthService.login()` accepts `rememberMe`.
- No real remember-me UI/control was found in `LoginPage.tsx`.

Assessment: `Partially implemented`

#### 1.2 Login page still contains strong mock/dev login paths

The login page includes:

- `QuickLoginModal`
- role-specific direct mock buttons
- mock login for:
  - student
  - instructor
  - admin
  - `it_admin`
  - `teaching_assistant`

Evidence:

- `src/pages/auth/LoginPage.tsx:11`
- `src/pages/auth/LoginPage.tsx:88`
- `src/pages/auth/LoginPage.tsx:279-316`

Assessment: `Partially implemented`

#### 1.3 Login API documentation does not match backend return shape fully

The controller examples show `expiresIn` in login/refresh responses, but `generateAuthResponse()` actually returns:

- `accessToken`
- `refreshToken`
- `user`

It does not return `expiresIn`.

Evidence:

- Controller examples mention `expiresIn`: `src/modules/auth/auth.controller.ts:135-137`, `231-233`
- Actual return shape: `src/modules/auth/auth.service.ts:323-327`

Assessment: `Wrong documentation / implementation mismatch`

---

## 2. Session Persistence After Refresh / Browser Close / Reopen

### Backend behavior

The backend stores refresh-token sessions in the `sessions` table and supports refresh-token rotation.

Evidence:

- Session record creation: `src/modules/auth/auth.service.ts:300-317`
- Refresh-token rotation: `src/modules/auth/auth.service.ts:133-151`

### Frontend behavior

The website restores auth state from `localStorage` by loading the stored user during `AuthContext` initialization.

Evidence:

- `src/context/AuthContext.tsx:21`
- `src/context/AuthContext.tsx:64`

This means:

- If the browser is closed and reopened, the app can still treat the user as logged in.
- If the user navigates directly to a dashboard route, the dashboard can still render because routes are not protected.

### Gaps / issues

#### 2.1 Persistence is client-trust-based, not server-validated

The frontend does not validate stored auth state on app startup via:

- `/auth/me`
- refresh-token exchange
- token introspection

Instead, it trusts locally stored `user` data.

Impact:

- A stale or expired token can still leave the app believing the user is authenticated until a later API call fails.
- Dashboard routing can appear logged-in before the backend confirms the session.

Assessment: `Partially implemented`

#### 2.2 App boot does not centrally re-hydrate from backend identity

Although `/auth/me` exists on the backend, the frontend does not use it as the core bootstrap source of truth for auth restoration.

Evidence:

- Backend `/auth/me`: `src/modules/auth/auth.controller.ts:335-384`
- Frontend local boot: `src/context/AuthContext.tsx:21`

Assessment: `Missing central identity validation`

---

## 3. Authenticated API Calls

### Current behavior

The frontend API layer injects the bearer token for non-auth endpoints.

Evidence:

- Axios branch: `src/services/api/client.ts:37-44`
- Fetch `ApiClient` branch: `src/services/api/client.ts:152-156`

### Gap / architectural note

There are two client styles in the same file:

- Axios client
- Custom `fetch`-based `ApiClient`

This is not itself an auth bug, but it increases the risk of inconsistent auth handling because:

- token injection exists in two paths
- 401 handling exists in two paths
- refresh logic would need to be implemented consistently in both

Assessment: `Architectural risk`

---

## 4. Token Expiry and Refresh Flow

### Backend behavior

Refresh-token flow is implemented:

1. Verify refresh token signature
2. Load user
3. Verify matching refresh-token session in database
4. Reject expired session
5. Delete old session row
6. Issue new access token + refresh token + new session row

Evidence:

- `src/modules/auth/auth.service.ts:115-155`

### Frontend behavior

The frontend has `refreshAccessToken()` implemented:

- `src/services/api/authService.ts:63-69`

However, no automatic refresh usage was found in:

- request interceptor
- response interceptor
- `ApiClient` retry flow
- app bootstrap flow

Instead, 401 handling clears local auth and redirects to `/login`.

Evidence:

- `src/services/api/client.ts:55-64`
- `src/services/api/client.ts:180-192`

### Gaps / issues

#### 4.1 Refresh-token support exists but is not operational in normal frontend runtime

This is one of the clearest backend/frontend parity gaps.

Backend: refresh flow exists.

Frontend: refresh flow is coded but not actually integrated into the app lifecycle.

Assessment: `Partially implemented in code, missing in behavior`

#### 4.2 Expired access token leads directly to logout behavior instead of refresh attempt

Impact:

- Worse user experience
- Session persistence is weaker than the backend supports
- Browser reopen behavior is more fragile than intended

Assessment: `Missing`

---

## 5. Logout Flow

### Backend behavior

`/auth/logout` requires:

- valid access token
- `refreshToken` in the request body

The backend then deletes the matching session row.

Evidence:

- Controller: `src/modules/auth/auth.controller.ts:188-192`
- Service: `src/modules/auth/auth.service.ts:157-162`

Important detail:

- Logout deletes the refresh-token session record.
- The access token itself is not blacklisted or revoked server-side.
- That means an already-issued access token can still be used until expiry unless other protections exist elsewhere.

Assessment: `Partially implemented`

### Frontend behavior

`AuthService.serverLogout()` does the correct intended thing:

1. Read stored refresh token
2. POST to `/auth/logout`
3. Clear local auth in a `finally`

Evidence:

- `src/services/api/authService.ts:50-61`

`AuthContext.logout()` calls `AuthService.serverLogout()`.

Evidence:

- `src/context/AuthContext.tsx:52-53`

### Major frontend bug

Most dashboard pages do not call `logout()` from `AuthContext`.

Instead, they pass logout handlers that only navigate to `/login`.

Evidence:

- Student dashboard: `src/pages/student-dashboard/StudentDashboard.tsx:334`
- Instructor dashboard: `src/pages/instructor-dashboard/InstructorDashboard.tsx:1226`
- Admin dashboard: `src/pages/admin-dashboard/AdminDashboard.tsx:821`, `840`
- IT Admin dashboard: `src/pages/it-admin-dashboard/ITAdminDashboard.tsx:366`
- TA dashboard: `src/pages/ta-dashboard/TADashboard.tsx:1180`

### Consequences

When a user clicks logout from these dashboards:

- The app often only navigates to `/login`.
- Tokens and stored user remain in `localStorage`.
- The backend logout endpoint is usually not called.
- The refresh-token session remains active on the backend.
- Because routes are unprotected, the user can often revisit dashboard routes directly.
- Browser close/reopen can still restore the logged-in state from stored user/token.

Assessment: `Wrong`

#### 5.1 Logout UI in shared header is incomplete

`DashboardHeader.tsx` contains translation labels for logout, but no real logout action was found in the rendered menu flow shown by the investigated code.

Evidence:

- Logout translation exists: `src/components/shared/DashboardHeader.tsx:199`
- Investigated menu actions emphasize profile/language/theme, not actual logout wiring

Assessment: `Partially implemented / incomplete UI behavior`

---

## 6. Route Protection and Role-Based Access Protection

## Frontend routing protection

### Current behavior

`App.jsx` declares dashboard routes directly and does not wrap them with an auth-protected or role-protected route component.

Evidence:

- Student dashboard routes: `src/App.jsx:159-178`
- Instructor dashboard marked as no auth protection: `src/App.jsx:183-204`
- Admin dashboard marked as no auth protection: `src/App.jsx:209-230`
- IT Admin dashboard marked as no auth protection: `src/App.jsx:235-256`
- TA dashboard marked as no auth protection: `src/App.jsx:281-302`

### Impact

Users can browse directly to:

- `/studentdashboard`
- `/instructordashboard`
- `/admindashboard`
- `/itadmindashboard`
- `/tadashboard`

without a route-level auth gate.

Assessment: `Missing / Wrong`

## Backend role protection

### Intended design

The backend has:

- `JwtAuthGuard`
- `RolesGuard`
- `@Roles(...)`

This is the correct direction architecturally.

### Actual problem

`UserManagementController` is guarded at controller level only with `JwtAuthGuard`.

Evidence:

- `src/modules/auth/user-management.controller.ts:61`

Many endpoints inside this controller do not add role restrictions even though their documentation says they require admin or IT admin permissions.

Examples of endpoints that appear to be authenticated-only instead of role-restricted:

- `GET /api/admin/users`
  - method starts at `src/modules/auth/user-management.controller.ts:105`
- `GET /api/admin/users/:id`
  - method starts at `src/modules/auth/user-management.controller.ts:261`
- `PUT /api/admin/users/:id`
  - method starts at `src/modules/auth/user-management.controller.ts:296`
- `DELETE /api/admin/users/:id`
  - method starts at `src/modules/auth/user-management.controller.ts:331`
- `PUT /api/admin/users/:id/status`
  - method starts at `src/modules/auth/user-management.controller.ts:363`
- `POST /api/admin/users/:id/roles`
  - method starts at `src/modules/auth/user-management.controller.ts:405`
- `DELETE /api/admin/users/:id/roles/:roleId`
  - method starts at `src/modules/auth/user-management.controller.ts:438`
- `GET /api/admin/roles`
  - method starts at `src/modules/auth/user-management.controller.ts:497`
- `POST /api/admin/roles`
  - method starts at `src/modules/auth/user-management.controller.ts:569`
- `PUT /api/admin/roles/:id`
  - method starts at `src/modules/auth/user-management.controller.ts:597`
- `DELETE /api/admin/roles/:id`
  - method starts at `src/modules/auth/user-management.controller.ts:629`
- `GET /api/admin/permissions`
  - method starts at `src/modules/auth/user-management.controller.ts:749`
- `POST /api/admin/permissions`
  - method starts at `src/modules/auth/user-management.controller.ts:827`

By contrast, some endpoints do explicitly apply role guards, for example:

- bulk import
- bulk status
- statistics
- dashboard summary
- export
- permission matrix

This inconsistency strongly suggests the controller is only partially protected.

### Impact

If this interpretation holds in runtime, then any authenticated user, including student/instructor/TA accounts, may be able to call endpoints intended only for admin/IT workflows.

Assessment: `Wrong` and `Critical`

---

## 7. Registration / Account Creation

### Backend behavior

Public registration exists at `/auth/register`.

Evidence:

- Controller register endpoint: `src/modules/auth/auth.controller.ts:88-89`
- Service implementation: `src/modules/auth/auth.service.ts:46-85`

Behavior:

- Checks duplicate email
- Accepts optional `role`
- Defaults to `student`
- Creates user as `active`
- Sets `emailVerified: true`
- Returns message + user
- Does not automatically issue tokens

Evidence:

- `src/modules/auth/auth.service.ts:59-76`
- `src/modules/auth/auth.service.ts:81-84`

### Critical backend issue

The registration DTO accepts any `RoleName`, not just `student`.

Evidence:

- `src/modules/auth/dto/register-request.dto.ts:71-78`

Because the endpoint itself is public and no additional restriction was found in `AuthService.register()`, the current implementation appears to allow self-registration into any valid role if the caller supplies it, including:

- `admin`
- `it_admin`
- `instructor`
- `teaching_assistant`
- `department_head`

This is one of the highest-risk findings in the entire audit.

Assessment: `Wrong` and `Critical`

### Frontend behavior

Frontend observations:

- The login page shows “Create one for free”, but no real registration flow was found.
- The button text exists, but no real public registration flow was found in the investigated login page behavior.

Evidence:

- `src/pages/auth/LoginPage.tsx:330`

At the same time, admin-side student creation uses `/auth/register` with `role: 'student'`.

Evidence:

- `src/services/adminService.ts:365-368`

### Comparison result

- Backend registration capability exists.
- Website public registration flow appears missing.
- Admin-side student creation partially reuses the public register endpoint.
- The endpoint itself appears too permissive for a public route.

Assessment: `Backend partially implemented but unsafe`, `Frontend missing public flow`

---

## 8. Password Reset

### Backend behavior

Password reset is implemented:

- `POST /auth/forgot-password`
- `POST /auth/reset-password`

Behavior:

- Generates reset token
- Hashes token in DB
- Sends email
- Resets password
- Marks token as used
- Invalidates all user sessions after successful password reset

Evidence:

- Forgot-password flow: `src/modules/auth/auth.service.ts:164-205`
- Reset-password flow: `src/modules/auth/auth.service.ts:208-235`

This is one of the stronger backend auth areas.

Assessment: `Working on backend`

### Frontend behavior

The login page visually contains a “Forgot password?” button, but no real handler flow was found.

Evidence:

- `src/pages/auth/LoginPage.tsx:189-190`

No connected frontend forgot/reset-password flow was identified in the investigated website files.

Assessment: `Missing on frontend`

---

## 9. Current User, Profile, Preferences, and Password Change

## Backend capabilities

Backend supports:

- current user identity (`/auth/me`)
- profile read/update
- preferences read/update
- password change

Evidence:

- `/auth/me`: `src/modules/auth/auth.controller.ts:335-384`
- profile methods: `src/modules/auth/user-management.service.ts:876-952`
- preferences methods: `src/modules/auth/user-management.service.ts:955-992`
- password change: `src/modules/auth/user-management.service.ts:995+`

## Frontend usage

### Real usage found

The website has a real `UserService` only for profile:

- `GET /users/profile`
- `PUT /users/profile`

Evidence:

- `src/services/api/userService.ts:45-50`

TA dashboard also uses `AuthService.getMe()` in live mode.

Evidence:

- `src/pages/ta-dashboard/TADashboard.tsx:413-414`

### Missing or partial usage

No comparable dedicated frontend service wrappers were found for:

- `/users/preferences`
- `/users/password`

The profile integration is therefore only partial relative to what the backend already supports.

Assessment: `Partially implemented`

### Student settings screen

`SettingsPreferences.tsx` appears to store settings in `localStorage` and present 2FA/security controls without real backend integration.

Evidence:

- local settings persistence: `src/pages/student-dashboard/components/SettingsPreferences.tsx:259-271`
- load from local settings storage: `src/pages/student-dashboard/components/SettingsPreferences.tsx:286`
- 2FA/security UI present: `src/pages/student-dashboard/components/SettingsPreferences.tsx:620-682`, `1077-1136`

Assessment: `Mock/UI-only` for security/preferences behavior

### Instructor settings screen

`SettingsPage.tsx` contains UI for:

- password/security
- notifications
- deactivate account

But no real backend auth wiring was found in the investigated file.

Evidence:

- password/security area: `src/pages/instructor-dashboard/components/SettingsPage.tsx:217-230`
- notification preferences: `src/pages/instructor-dashboard/components/SettingsPage.tsx:272-311`
- deactivate account area: `src/pages/instructor-dashboard/components/SettingsPage.tsx:549-558`

Assessment: `Mock/UI-only` or `Missing integration`

---

## 10. 2FA and Email Verification

### Backend

2FA:

- `TwoFactorAuth` entity exists
- module imports the entity
- no end-to-end controller/service flow was identified in the auth feature for setup, challenge, verify, or enforce-on-login

Evidence:

- entity references found in:
  - `src/modules/auth/entities/user.entity.ts:105-106`
  - `src/modules/auth/entities/two-factor-auth.entity.ts`
  - `src/modules/auth/auth.module.ts:19`, `35`

Email verification:

- `EmailVerification` entity exists
- migration exists
- no real end-to-end email-verification auth flow was identified in the investigated backend auth flow

Evidence:

- `src/modules/auth/entities/email-verification.entity.ts`
- `src/database/migrations/001_create_email_verifications_table.sql`

Assessment: `Backend partial model only`, not full auth feature delivery

### Frontend

The website contains 2FA/security-style UI, especially in student settings and instructor settings, but no real backend 2FA integration was found.

Assessment: `Mock/UI-only`

### Comparison result

2FA and email verification are currently best described as:

- modeled in some places
- presented in some UI places
- not implemented end-to-end

Assessment: `Missing end-to-end`

---

## 11. Role-by-Role Findings

## Student

### What exists

- Real backend role exists: `student`
- Real login can return a student user
- Student dashboard can render with stored/local auth state
- Some real profile data integration exists elsewhere in the app

### Main issues

- Student dashboard route is not protected
- Student logout from dashboard only navigates to login, does not perform real logout
- Student settings/security/preferences are largely local-only
- Student can potentially access backend admin endpoints if authenticated, because backend admin controller protection is inconsistent

Evidence:

- Student dashboard logout wiring: `src/pages/student-dashboard/StudentDashboard.tsx:334`
- Route exposure: `src/App.jsx:159-178`

Assessment: `Partially implemented`, with serious routing/logout/authz risks

## Instructor

### What exists

- Real backend role exists: `instructor`
- Real login can return instructor role
- Instructor dashboard has some live-data branches

### Main issues

- Instructor dashboard route is not protected
- Instructor dashboard uses mock-mode fallback logic
- Instructor logout from dashboard only navigates to login
- Instructor settings page appears mostly UI-only for auth-adjacent actions

Evidence:

- mock-mode detection: `src/pages/instructor-dashboard/InstructorDashboard.tsx:222-225`
- logout wiring: `src/pages/instructor-dashboard/InstructorDashboard.tsx:1226`
- route exposure: `src/App.jsx:183-204`

Assessment: `Partially implemented`

## TA

### What exists

- Real backend role exists as `teaching_assistant`
- Real login can return that role
- TA dashboard uses real `/auth/me` in live mode
- Some live data behavior exists

### Main issues

- TA dashboard route is not protected
- TA dashboard still uses mock-mode fallback
- TA logout from dashboard only navigates to login

Evidence:

- live `/auth/me`: `src/pages/ta-dashboard/TADashboard.tsx:413-414`
- mock-mode: `src/pages/ta-dashboard/TADashboard.tsx:329`
- logout wiring: `src/pages/ta-dashboard/TADashboard.tsx:1180`
- route exposure: `src/App.jsx:281-302`

Assessment: `Partially implemented`, stronger than admin/IT frontend integration in some areas, but still not secure end-to-end

## Admin

### What exists

- Real backend role exists: `admin`
- Backend has many admin/user-management endpoints
- Frontend admin dashboard has some real live API integrations
- Admin-side student creation uses real backend registration endpoint

### Main issues

- Admin dashboard route is not protected
- Admin dashboard logout only navigates to login
- Header/profile data are partly hardcoded/mock
- Live admin UI coverage does not match backend capabilities
- Backend admin endpoints are incompletely role-protected

Evidence:

- route exposure: `src/App.jsx:209-230`
- logout wiring: `src/pages/admin-dashboard/AdminDashboard.tsx:821`, `840`
- hardcoded header role/name: `src/pages/admin-dashboard/AdminDashboard.tsx:855-856`
- hardcoded profile data: `src/pages/admin-dashboard/AdminDashboard.tsx:981-985`

Assessment: `Partially implemented on frontend`, `Wrong/unsafe on backend authz`

## IT Admin

### What exists

- Real backend role exists: `it_admin`
- Backend contains role/permission/user-management endpoints intended for IT admin usage

### Main issues

- IT Admin dashboard route is not protected
- IT Admin logout only navigates to login
- User-management UI is local/mock instead of real backend integration
- Role-management UI is local/mock instead of real backend integration
- Profile/header content is partly hardcoded
- Backend role/permission endpoints are not consistently protected as IT-admin-only

Evidence:

- route exposure: `src/App.jsx:235-256`
- logout wiring: `src/pages/it-admin-dashboard/ITAdminDashboard.tsx:366`
- hardcoded IT admin header/profile: `src/pages/it-admin-dashboard/ITAdminDashboard.tsx:390`, `523`, `539-546`
- local/mock user management: `src/pages/it-admin-dashboard/components/UserManagementPage.tsx:103-107`
- local/mock role management: `src/pages/it-admin-dashboard/components/RoleManagementPage.tsx:117-129`

Assessment: `Largely missing as a real end-to-end auth-admin experience`

---

## 12. Backend Documentation vs Actual Behavior Mismatches

These mismatches matter because they can mislead implementation planning and testing.

### 12.1 Login/refresh docs show `expiresIn`, service does not return it

Evidence:

- docs/examples: `src/modules/auth/auth.controller.ts:135-137`, `231-233`
- actual service return: `src/modules/auth/auth.service.ts:323-327`

### 12.2 User-status docs say suspended sessions are terminated, service only updates status

Evidence:

- docs: `src/modules/auth/user-management.controller.ts:352-354`
- service behavior: `src/modules/auth/user-management.service.ts:154-170`

### 12.3 Remove-role docs say removing the last role should fail, service does not enforce that

Evidence:

- docs: `src/modules/auth/user-management.controller.ts:425-427`, `434`
- service behavior: `src/modules/auth/user-management.service.ts:226-243`

### 12.4 Role docs say built-in roles should not be renamed/deleted, service does not clearly enforce built-in-role protection in `deleteRole`

Evidence:

- docs: `src/modules/auth/user-management.controller.ts:586`, `618-619`
- service delete behavior only checks assigned users: `src/modules/auth/user-management.service.ts:363-379`

### 12.5 Register docs/examples imply auth-style response shape, but service returns only message + user

Evidence:

- controller register response example includes token-looking fields near `src/modules/auth/auth.controller.ts:81-82`
- service actual return: `src/modules/auth/auth.service.ts:81-84`

---

## 13. Critical Findings

These are the most urgent auth findings from this audit.

### Critical 1: Public registration appears to allow privileged roles

Why it matters:

- A public endpoint should not allow self-selection of privileged roles unless there is a higher-level invitation/approval mechanism.

Evidence:

- public register endpoint: `src/modules/auth/auth.controller.ts:88-89`
- DTO accepts any `RoleName`: `src/modules/auth/dto/register-request.dto.ts:71-78`
- service trusts incoming role and loads it directly: `src/modules/auth/auth.service.ts:59-66`

Assessment: `Critical`, `Wrong`

### Critical 2: Many admin/user-management endpoints appear to be missing role enforcement

Why it matters:

- Any authenticated user may be able to call endpoints intended only for admin or IT admin workflows.

Evidence:

- controller-level JWT only: `src/modules/auth/user-management.controller.ts:61`
- many admin methods lack local `@Roles(...)/RolesGuard` while docs claim restricted access

Assessment: `Critical`, `Wrong`

### Critical 3: Frontend dashboard logout is usually fake logout

Why it matters:

- User thinks they logged out, but tokens remain stored and server session often remains valid.

Evidence:

- real logout service exists: `src/services/api/authService.ts:50-61`
- dashboards often only navigate to `/login`:
  - student: `src/pages/student-dashboard/StudentDashboard.tsx:334`
  - instructor: `src/pages/instructor-dashboard/InstructorDashboard.tsx:1226`
  - admin: `src/pages/admin-dashboard/AdminDashboard.tsx:821`
  - IT admin: `src/pages/it-admin-dashboard/ITAdminDashboard.tsx:366`
  - TA: `src/pages/ta-dashboard/TADashboard.tsx:1180`

Assessment: `Critical`, `Wrong`

### Critical 4: Frontend routes are not auth-protected or role-protected

Why it matters:

- Users can navigate directly into dashboards.
- This is a major mismatch with the expected auth model for role-specific dashboards.

Evidence:

- `src/App.jsx:159-302`

Assessment: `Critical`, `Missing / Wrong`

---

## 14. High-Priority Findings

### High 1: Frontend does not operationalize backend refresh-token support

Evidence:

- refresh service exists: `src/services/api/authService.ts:63-69`
- 401 clears auth instead of refreshing: `src/services/api/client.ts:180-192`

### High 2: Stored auth is trusted locally without backend validation

Evidence:

- local restore from stored user: `src/context/AuthContext.tsx:21`
- `isAuthenticated` based on `!!user`: `src/context/AuthContext.tsx:64`

### High 3: Dashboard routing uses only the first role

If a user has multiple roles, the chosen dashboard depends on `user.roles?.[0]`.

Evidence:

- `src/services/api/authService.ts:119`

This is fragile because backend role order is not guaranteed to be a safe routing authority.

### High 4: Password reset is real in backend but absent from website flow

Evidence:

- backend real flow: `src/modules/auth/auth.service.ts:164-235`
- frontend forgot-password button only: `src/pages/auth/LoginPage.tsx:189-190`

---

## 15. Medium-Priority Findings

### Medium 1: Admin and IT dashboard identity/profile display is partly mock/hardcoded

Evidence:

- admin header/profile: `src/pages/admin-dashboard/AdminDashboard.tsx:855-856`, `981-985`
- IT admin header/profile: `src/pages/it-admin-dashboard/ITAdminDashboard.tsx:390`, `539-546`

### Medium 2: Student/instructor security/preferences screens create false completeness

The UI suggests real auth-account settings are available, but much of it is only local or visual.

Evidence:

- student settings local storage + 2FA UI: `src/pages/student-dashboard/components/SettingsPreferences.tsx:259-271`, `620-682`, `1077-1136`
- instructor settings auth-adjacent UI: `src/pages/instructor-dashboard/components/SettingsPage.tsx:217-230`, `272-311`, `549-558`

### Medium 3: Backend docs and runtime behavior are inconsistent in several auth areas

This increases planning and QA risk.

---

## 16. What Is Implemented, Partially Implemented, Missing, and Wrong

## Implemented reasonably on backend

- Basic JWT login
- Refresh token issuance
- Session-table storage for refresh sessions
- `/auth/me`
- Forgot password
- Reset password
- Profile read/update
- Preferences read/update
- Password change

## Partially implemented

- Frontend login
- Session persistence across close/reopen
- Frontend live-profile usage
- Frontend admin live integrations
- Backend logout semantics
- Multi-role handling
- 2FA/email-verification groundwork

## Missing

- Frontend protected-route system
- Frontend role-protected routing
- Frontend automatic token refresh
- Frontend forgot/reset-password flow
- Frontend real password-change flow
- Frontend real preferences integration for all settings pages
- End-to-end 2FA
- End-to-end email verification

## Wrong

- Dashboard logout behavior on most role dashboards
- Backend public registration role acceptance
- Backend missing role enforcement on many admin endpoints
- Frontend trusting `user` presence as authenticated truth
- Backend docs vs behavior in several places

---

## 17. Planning Implications

This section is not a fix plan, but it highlights the areas that will matter when making one.

### Workstream A: Security correction before feature completion

The following should be treated as security/auth correctness issues, not polish:

- restrict public registration role behavior
- enforce role guards consistently on admin/user-management endpoints
- fix real logout wiring in all dashboards
- add auth-protected and role-protected route wrappers

### Workstream B: Make session persistence real instead of local-only

The intended session story should be clarified around:

- app startup identity validation
- automatic refresh-token flow
- expired-token behavior
- logout semantics across tabs/reloads/reopen

### Workstream C: Replace mock/UI-only auth-adjacent screens with real integrations

Most visible gaps are not in raw login itself, but in adjacent auth/account features:

- forgot/reset password
- change password
- preferences
- 2FA
- account security settings
- IT admin user/role management parity

### Workstream D: Role-specific frontend hardening

Each role dashboard currently exists visually, but auth enforcement and auth lifecycle are not role-safe yet.

---

## Final Conclusion

The backend and website are not aligned yet on auth.

The backend already contains the foundation for a real auth system, but it has critical authorization gaps and at least one severe registration-risk issue. The website has a working login entry point and local persistence, but it does not yet behave like a secure, complete authenticated product because:

- logout is mostly incorrect in real dashboard usage
- routing is not protected
- token refresh is not actually operational
- several auth-related features are mock-only or incomplete
- role handling is not enforced cleanly on either side

If the goal is a stable production-ready auth system for student, instructor, TA, admin, and IT admin, the current state should be considered `partially implemented with critical security/correctness gaps`, not merely unfinished UI work.
