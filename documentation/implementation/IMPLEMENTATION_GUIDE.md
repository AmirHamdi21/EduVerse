# Email Verification Implementation Guide

## Overview
The Flutter frontend has been updated to match the backend's email verification workflow. Users must now verify their email before accessing the dashboard.

---

## Key Changes Made

### 1. Models
**File**: `lib/models/auth_models.dart`
- **Added**: `RegistrationResponse` class for backend registration response
  - Contains: `message`, `user`
  - User will have `emailVerified: false` and `status: PENDING`
- **Kept**: `AuthResponse` for login response (with tokens)

### 2. API Service
**File**: `lib/services/api_service.dart`
- Updated `register()` to return `RegistrationResponse`
- Added `resendVerificationEmail(String email)` method
  - Calls: `POST /api/auth/resend-verification-email`
  - Used when user needs to resend verification token

### 3. Authentication Events
**File**: `lib/bloc/auth/auth_event.dart`
- Added `ResendVerificationEmailRequested` event
- Used for requesting new verification email

### 4. Authentication BLoC
**File**: `lib/bloc/auth/auth_bloc.dart`
- Fixed registration handler:
  - No longer saves tokens after registration
  - Emits `AuthEmailVerificationNeeded` state
- Updated email verification handler:
  - Refreshes user data from server
  - Emits `AuthAuthenticated` only after successful verification
- Added resend verification handler:
  - Sends request to backend
  - Shows success/error message

### 5. UI Screens

#### Register Screen
**File**: `lib/screens/register_screen.dart`
- Sends `role` parameter to backend
- Navigates to `/verify-email` after successful registration
- Shows user-friendly success message

#### Login Screen  
**File**: `lib/screens/login_screen.dart`
- Detects "verify email" errors from backend
- Shows orange warning snackbar (not red error)
- Provides "Resend Email" button for unverified users
- Users cannot login until email is verified

#### Email Verification Screen (NEW)
**File**: `lib/screens/email_verification_screen.dart`
- Accepts verification token from user
- Shows resend button
- Navigates to dashboard after successful verification
- Beautiful UI with gradient design
- Displays email address user registered with

---

## Registration Flow

### Step 1: User Registers
```
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890",
  "role": "student"
}

Response (201):
{
  "message": "User registered successfully. Please verify your email.",
  "user": {
    "userId": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "status": "pending",
    "emailVerified": false,
    ...
  }
}
```

**Frontend Action**: 
- ✅ Emit `AuthEmailVerificationNeeded` state
- ✅ Navigate to `/verify-email` screen
- ✅ Display email for reference

---

### Step 2: User Verifies Email
```
POST /api/auth/verify-email
{
  "token": "TOKEN_FROM_EMAIL"
}

Response (200):
{
  "message": "Email verified successfully!",
  ...
}
```

**Frontend Action**:
- ✅ Fetch latest user data from GET /api/auth/me
- ✅ Emit `AuthAuthenticated` state
- ✅ Save user data locally
- ✅ Navigate to `/dashboard`

---

### Step 3: User Can Now Login
```
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}

Response (200):
{
  "accessToken": "jwt_token...",
  "refreshToken": "refresh_token...",
  "user": {
    "userId": 1,
    "email": "user@example.com",
    "emailVerified": true,
    "status": "active",
    ...
  }
}
```

**Frontend Action**:
- ✅ Save tokens locally
- ✅ Save user data
- ✅ Emit `AuthAuthenticated` state
- ✅ Navigate to `/dashboard`

---

## Error Scenarios

### Unverified User Tries to Login
**Backend Response**:
```
{
  "statusCode": 401,
  "message": "Please verify your email first",
  "error": "Unauthorized"
}
```

**Frontend Behavior**:
- ✅ Detects "verify" or "email" keywords in error
- ✅ Shows orange warning snackbar
- ✅ Provides "Resend Email" button
- ✅ User stays on login screen

### Invalid Verification Token
**Backend Response**:
```
{
  "statusCode": 400,
  "message": "Invalid or already used verification token",
  "error": "Bad Request"
}
```

**Frontend Behavior**:
- ✅ Shows red error snackbar
- ✅ User can try again or resend
- ✅ Stays on verification screen

### User Requests Resend
**Request**:
```
POST /api/auth/resend-verification-email
{
  "email": "user@example.com"
}

Response (200):
{
  "message": "Verification email sent to user@example.com",
  ...
}
```

**Frontend Behavior**:
- ✅ Shows success message
- ✅ User can submit new token

---

## Router Configuration (TODO)

Add to your router configuration:
```dart
GoRoute(
  path: '/verify-email',
  builder: (context, state) {
    final email = state.extra as String?;
    return EmailVerificationScreen(email: email);
  },
),
```

---

## Testing the Flow

### Test 1: Complete Registration
1. Open app, go to Register screen
2. Enter: John Doe, john@example.com, Secure123!, Student, accept terms
3. Should see: Success message, redirected to email verification screen
4. Check email inbox for verification token
5. Enter token on verification screen
6. Should see: Redirected to dashboard

### Test 2: Unverified User Tries Login
1. Register user (stop after registration, don't verify)
2. Go to Login screen
3. Enter same email and password
4. Should see: Orange warning "Please verify your email first"
5. Click "Resend Email"
6. Check inbox for new token
7. Verify and try login again
8. Should succeed this time

### Test 3: Expired Token
1. Register user
2. Get verification token from email
3. Wait 24 hours (or change backend date)
4. Try to verify with old token
5. Should see: Red error "Verification token has expired"
6. Click "Resend" to get new token

### Test 4: Already Verified User
1. Register and verify user once
2. Try to resend verification to same email
3. Should see: Error "Email is already verified"

---

## Troubleshooting

### Issue: "Network error: Connection refused"
**Solution**: Check backend URL in `lib/services/api_service.dart` (baseUrl)

### Issue: Token not being saved after verification
**Solution**: Ensure `GET /api/auth/me` returns fresh user data with `emailVerified: true`

### Issue: Can't navigate to email verification screen
**Solution**: Ensure `/verify-email` route is configured in your router

### Issue: Resend button not working
**Solution**: Check that `resendVerificationEmail()` is implemented in ApiService

### Issue: User data not updating after verification
**Solution**: Make sure `_onVerifyEmailRequested` calls `_apiService.getCurrentUser()`

---

## Security Notes

✅ **Email Verification Required**
- Users cannot access dashboard without verified email
- Tokens are not stored until verification succeeds
- Backend checks emailVerified flag on every protected endpoint

✅ **Token Security**
- Backend uses SHA256 hashing for verification tokens
- Tokens expire after 24 hours
- Used tokens are marked as "used" to prevent reuse
- Resending invalidates previous tokens

✅ **Rate Limiting** (Backend only)
- Resend endpoint can be rate-limited
- Multiple failed attempts can lock account temporarily
- Frontend should respect these limits with user-friendly messages

---

## Next Steps

1. ✅ Models match backend
2. ✅ API service has all endpoints
3. ✅ BLoC handlers implemented
4. ✅ Screens created and updated
5. 📋 Add router configuration
6. 🧪 Run complete flow test
7. 🚀 Deploy to production

---

## Support

For issues or questions about the implementation:
1. Check BACKEND_FRONTEND_ALIGNMENT.md for detailed changes
2. Review backend documentation in `1.1 Auth.pdf`
3. Check error messages from backend API responses

**Backend Status**: ✅ Ready for integration
**Frontend Status**: ✅ Ready for testing
