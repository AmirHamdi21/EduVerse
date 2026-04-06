# Comprehensive Authentication & Login Flow Documentation

This document serves as the absolute, single source of truth for the entire Authentication, Login, and Session Persistence pipeline in the EduVerse project. It is designed to be highly detailed so that any developer can understand, reconstruct, or debug the entire auth pipeline from UI animations down to interceptor-level token refreshing across all user roles.

---

## 1. Architecture Overview & Data Flow

The authentication system is built on a robust, multi-layered architecture:
1. **UI Layer (`LoginScreen`, `SplashScreen`)**: Handles user input, captures credentials, orchestrates staggered animations, and listens to BLoC state changes to execute navigation via `go_router`.
2. **State Management (`AuthBloc`)**: The central brain. Interprets events (e.g., `LoginRequested`, `AuthCheckRequested`) and emits states (`AuthAuthenticated`, `AuthLoading`, `AuthError`). 
3. **API & Networking (`ApiService`, `AuthInterceptor`)**: Converts BLoC requests into HTTP calls using `Dio`. Handles token injection, catching `401 Unauthorized` errors, automatically refreshing tokens, and retrying failed requests.
4. **Local Persistence (`StorageService`)**: Utilizes `flutter_secure_storage` to safely persist JWTs (Access and Refresh tokens) and `shared_preferences` for non-sensitive user data.

### High-Level Data Flow:
```text
User Input -> LoginScreen -> AuthBloc.add(LoginRequested) 
   -> ApiService.login() -> Dio POST /auth/login
   -> Returns Access/Refresh Tokens + UserDto
   -> StorageService (saves tokens & user data securely)
   -> AuthBloc.emit(AuthAuthenticated)
   -> LoginScreen/SplashScreen (BlocListener catches state)
   -> DemoCredentials.getDashboardRouteForUser (role resolution)
   -> go_router routes to role-specific dashboard
```

---

## 2. App Initialization & Global State (`main.dart`)

**File**: `lib/main.dart`

To ensure authentication state is maintained globally without re-initialization, `AuthBloc` is created at the root of the app.

### Process:
1. Inside `_MyAppState.initState()`, instances of core services are created:
   ```dart
   _storageService = StorageService();
   _authBloc = AuthBloc(
     apiService: ApiService(),
     storageService: _storageService,
   );
   ```
2. The `AuthBloc` is then injected into the app's widget tree using `MultiBlocProvider`.
3. This guarantees that **any widget or screen** can access the user's authentications status via `context.read<AuthBloc>()` or listen to changes via `BlocBuilder`/`BlocListener`.

---

## 3. Session Kickoff: The Splash Screen (`splash_screen.dart`)

**File**: `lib/screens/splash/splash_screen.dart`

The splash screen is the gatekeeper of the app. It decides whether the user needs to log in or can be fast-tracked to their dashboard.

### Initialization & Auth Check:
1. `initState()` fires and instantly calls `context.read<AuthBloc>().add(const AuthCheckRequested());`.
2. `AuthBloc` queries `StorageService.isLoggedIn()` (which checks if an access token exists).
3. If an access token exists, it loads the `UserDto` from storage and emits `AuthAuthenticated(user)`.
4. If no token is found, or an error occurs, it emits `AuthUnauthenticated()`.

### The Routing Logic (and Current Development Quirk):
The `SplashScreen` includes a `BlocListener` that waits for a minimum duration (e.g., 4 seconds) so the UI animations can complete before redirecting.

> ⚠️ **CRITICAL DEVELOPMENT NOTE:** 
> In the current codebase, the redirect for *both* authenticated and unauthenticated states is temporarily hardcoded to `/login` for development purposes. 
> ```dart
> if (state is AuthAuthenticated) {
>     context.go('/login'); // Should be returning to role-specific dashboard!
> } else if (state is AuthUnauthenticated) {
>     context.go('/login'); 
> }
> ```
> **To Fix This in Production:** Replace the authenticated branch with role-based routing (e.g., `DemoCredentials.getDashboardRouteForUser(user)`).

---

## 4. The Login Screen (`login_screen.dart`)

**File**: `lib/screens/auth/login_screen.dart`

This is the primary interface for unauthenticated users. It handles form validation, API coordination, and advanced UI animations.

### A. UI Animations
The login screen features complex, staggered "waterfall" animations. Controllers are set up in `initState()` (`_logoController`, `_titleController`, `_emailFieldController`, etc.) and fired sequentially using `Future.delayed` to create a smooth entrance.

### B. Pre-Flight Verification & Login Submission
When the user taps "Login", `_handleLogin()` executes an intricate sequence:

1. **Form Validation**: Checks if inputs are empty.
2. **Demo Credential Bypass**: Checks if the credentials match standard offline demo accounts (e.g., `student@eduverse.dev`, `admin@eduverse.dev`). If so, it *entirely bypasses the API*, constructs a mock `UserDto`, and instantly routes the user via `go_router`. (See Section 5).
3. **Security Pre-Check (`isEmailVerifiedAndExists`)**: 
   Before dispatching the actual login event to the BLoC, the UI directly calls `ApiService().isEmailVerifiedAndExists()`. 
   - If the API returns a 'verify' error, it intercepts it and shows a specific warning dialog: "Email not verified", offering a quick "Resend Verification Email" button.
4. **BLoC Dispatch**: If the pre-check passes, it wraps the credentials in a `LoginRequest` and fires `context.read<AuthBloc>().add(LoginRequested(request));`.

### C. BLoC Listener Navigation
The `BlocListener` at the root of `LoginScreen` waits for the outcome:
- **On `AuthAuthenticated`**: Uses `DemoCredentials.getDashboardRouteForUser(state.user)` to figure out where to go, displays a green success SnackBar, and routes the user.
- **On `AuthError`**: Displays a red/orange SnackBar with the error message.

---

## 5. Demo Accounts & Role-Based Routing (`demo_credentials.dart`)

**File**: `lib/services/demo_credentials.dart`

To facilitate rapid development, testing, and presentations without relying on a live backend, the app includes a robust demo credential system.

### Recognized Offline Accounts:
- **Student**: `student@eduverse.dev` / `Student@123`
- **Instructor**: `instructor@eduverse.dev` / `Instructor@123`
- **Teaching Assistant (TA)**: `ta@eduverse.dev` / `TA@123456`
- **Admin**: `admin@eduverse.dev` / `Admin@123`
- **IT Admin**: `itadmin@eduverse.dev` / `ITAdmin@123`

### Role-Based Routing Execution:
When a user (demo or real) successfully logs in, their profile (`UserDto`) contains an array of `RoleModel`s. The `DemoCredentials.getDashboardRouteForUser(user)` function parses this array natively prioritising higher access levels:
1. IT_ADMIN -> `/it-admin/dashboard`
2. ADMIN -> `/admin/dashboard`
3. INSTRUCTOR -> `/instructor/dashboard`
4. TA -> `/ta/dashboard`
5. STUDENT -> `/dashboard`

---

## 6. API, Networking, & Token Refresh Interceptor

**Files**: `lib/services/api_service.dart`, `lib/services/auth_interceptor.dart`

### A. The API Service
The `ApiService` acts as the bridge to the backend. 
- **`login(LoginRequest)`**: Issues a `POST /auth/login`. On success, it receives a payload with `accessToken`, `refreshToken`, and user object.
- **`isEmailVerifiedAndExists()`**: The pre-flight check method that interprets specific string errors from the backend (like "verify") to instruct the UI to prompt for email verification rather than generic failures.

### B. The Auth Interceptor (The Masterpiece of Persistence)
If a user is browsing the app and their `accessToken` naturally expires, the server will return a `401 Unauthorized` error. 
The `AuthInterceptor` intercepts *every* outgoing and incoming HTTP request using `Dio`.

**How it handles a 401 Error:**
1. **Guard Clauses**: It ignores `401`s on `/auth/login`, `/auth/register`, and `/auth/refresh-token` to prevent infinite loops.
2. **Queueing**: If a refresh is already in progress (`_isRefreshing == true`), it holds parallel requests.
3. **The Refresh Call**: It fetches the `refreshToken` from `StorageService` and uses a *clean* instance of Dio (`refreshDio`) to execute a `POST /auth/refresh-token`.
4. **Success**: If successful, it receives new tokens, updates `StorageService`, modifies the original failed request's header with the `Bearer $newAccessToken`, and instantly retries the original request. The user never knows it happened.
5. **Failure**: If the refresh token is also dead/expired, it calls `_storage.clearAll()` effectively killing the session, requiring the user to log in manually again.

---

## 7. State Management Lifecycle (`auth_bloc.dart`)

**File**: `lib/bloc/auth/auth_bloc.dart`

The `AuthBloc` orchestrates the system states.

### Core Events & Transitions:
- **`AuthCheckRequested`**: 
  - **Action**: Look for local token.
  - **Yields**: `AuthAuthenticated` or `AuthUnauthenticated`.
- **`LoginRequested`**: 
  - **Action**: Calls `_apiService.login`. Save tokens to `StorageService` if successful.
  - **Yields**: `AuthLoading` -> `AuthAuthenticated` (success) OR `AuthError` -> `AuthUnauthenticated` (failure).
- **`LogoutRequested`**: 
  - **Action**: Calls `_apiService.logout(refreshToken)` to invalidate the token on the server, then `_storageService.clearAll()` locally.
  - **Yields**: `AuthUnauthenticated`.
- **`RegisterRequested`**: 
  - **Action**: Pushes data. Does *not* automatically authenticate because email verification is required.
  - **Yields**: `AuthEmailVerificationNeeded`.

---

## 8. Troubleshooting & Fixes Blueprint

If you are a developer assigned to fix a broken authentication pipeline, use the following isolation steps:

### Scenario 1: User logs in, gets a green "Success" check, but nothing happens or they are sent back to Login.
- **Check 1**: Look at `splash_screen.dart` lines ~158+. If `context.go('/login')` is hardcoded under the `AuthAuthenticated` condition, remove it and restore the redirect to `context.go(DemoCredentials.getDashboardRouteForUser(state.user))`.
- **Check 2**: Look at `login_screen.dart` BLoC listener. Ensure `context.go()` is appropriately catching the `AuthAuthenticated` state.
- **Check 3**: Look at `app_router.dart` to ensure the target path (e.g., `/dashboard`) is properly registered in GoRouter.

### Scenario 2: Requests fail immediately with a 401 and the app crashes/hangs instead of refreshing.
- **Check 1**: Open `auth_interceptor.dart`. Ensure `_isRefreshing` flag is correctly resetting to `false` in both the `catch` and `success` blocks. If it stays `true`, all future requests are deadlocked.
- **Check 2**: Verify the endpoint for the refresh token in `auth_interceptor.dart` (`/auth/refresh-token`). Ensure this exactly matches the backend specification.

### Scenario 3: Demo credentials do not work.
- **Check 1**: Open `demo_credentials.dart`. Verify the emails match exactly what the user is typing (the logic uses `.toLowerCase().trim()`).
- **Check 2**: Verify `demo_credentials.dart`'s `validateDemoCredentials` method is accurately being executed early inside `_handleLogin()` in `login_screen.dart`.

### Scenario 4: User is getting "Email not verified" but they verified it.
- **Check 1**: The backend may not be updating the `emailVerified=true` status, or the `isEmailVerifiedAndExists` method in `api_service.dart` is falsely triggering based on a loosely matched error string (e.g., `message.toLowerCase().contains('verify')`). Review backend logs.

### Scenario 5: Access Tokens are "missing" from requests.
- **Check 1**: In `auth_interceptor.dart`'s `onRequest`, ensure `_storage.getAccessToken()` successfully awaits the Read.
- **Check 2**: Verify `flutter_secure_storage` plugin isn't crashing silently natively. On iOS, check the Keychain entitlements. On Android, check the keystore initialization. Ensure `clearAll()` is appropriately called on Logout.