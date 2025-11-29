# Router Configuration for Email Verification

## Required Router Changes

To complete the email verification implementation, add the `/verify-email` route to your GoRouter configuration.

### Current Router File Location
Find your router configuration file (typically in `lib/config/app_router.dart` or similar) and add the following route.

### Route to Add

```dart
// Email Verification Screen Route
GoRoute(
  path: '/verify-email',
  builder: (context, state) {
    final email = state.extra as String?;
    return EmailVerificationScreen(email: email);
  },
),
```

### Full Example Router Configuration

If you're using GoRouter with nested routes, here's a complete example:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/dashboard_screen.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        // Handle redirects based on auth state
        final authState = context.read<AuthBloc>().state;
        
        if (authState is AuthInitial || authState is AuthUnauthenticated) {
          if (state.matchedLocation == '/splash') {
            return null; // Stay on splash
          }
          return '/login';
        }
        
        if (authState is AuthAuthenticated) {
          if (state.matchedLocation == '/login' ||
              state.matchedLocation == '/register' ||
              state.matchedLocation == '/verify-email') {
            return '/dashboard';
          }
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) {
            final email = state.extra as String?;
            return EmailVerificationScreen(email: email);
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Error: ${state.error}'),
        ),
      ),
    );
  }
}
```

### Usage in Main App

```dart
import 'config/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            apiService: ApiService(),
            storageService: StorageService(),
          )..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'EduVerse',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerConfig: AppRouter.createRouter(context),
      ),
    );
  }
}
```

### Import Statement Required

Make sure to import the new screen in your router file:

```dart
import '../screens/email_verification_screen.dart';
```

### Navigation in Register Screen

The register screen will navigate to the email verification screen after successful registration:

```dart
// This is automatically handled by the register screen
// The navigation call is already in place:
context.go('/verify-email', extra: state.user.email);
```

### Navigation in Login Screen (Resend Button)

When user clicks "Resend Email" from login error, they stay on login screen but the resend request is sent:

```dart
// This triggers ResendVerificationEmailRequested event
context.read<AuthBloc>().add(
  ResendVerificationEmailRequested(_emailController.text.trim()),
);
```

### Navigation in Verification Screen

After successful verification:

```dart
// Automatically handled by BlocListener
context.go('/dashboard');
```

Back to login:

```dart
// User clicks "Back to Login"
context.go('/login');
```

---

## State-Based Redirects

The router configuration above handles automatic redirects based on auth state:

### Auth States → Navigation

- **AuthInitial** → Stay on current screen (app initializing)
- **AuthUnauthenticated** → Redirect to /login (except /splash)
- **AuthAuthenticated** → Redirect to /dashboard (from auth screens)
- **AuthEmailVerificationNeeded** → User can stay on /verify-email
- **AuthError** → Show error, user can retry

### Protected Routes

The following routes are protected by redirect logic:

- ✅ `/dashboard` - Requires AuthAuthenticated
- ✅ `/verify-email` - Can be accessed without auth (intermediate state)
- ✅ `/login` - Redirects to /dashboard if already authenticated
- ✅ `/register` - Redirects to /dashboard if already authenticated

---

## Testing the Router

### Test 1: Navigation After Registration
```
1. Go to /register
2. Fill form and submit
3. Should navigate to /verify-email (with email parameter)
4. Email should display on screen
```

### Test 2: Back Navigation
```
1. On /verify-email screen
2. Click "Back to Login"
3. Should navigate to /login
4. Router redirect should NOT send to /dashboard
```

### Test 3: Protected Dashboard
```
1. Direct URL to /dashboard without logging in
2. Router should redirect to /login
3. Then to /dashboard after successful login/verification
```

### Test 4: Already Authenticated
```
1. Login and verify
2. Direct URL to /register or /login
3. Should redirect to /dashboard automatically
```

---

## Troubleshooting

### Issue: "/verify-email" route not found
**Solution**: Make sure the GoRoute is added to your routes list in router configuration

### Issue: Email not passing to verification screen
**Solution**: Check that register screen is using `context.go('/verify-email', extra: state.user.email);`

### Issue: Back button on verification screen doesn't work
**Solution**: Make sure you're using `context.go('/login')` or `context.pop()`

### Issue: Redirect loop between login and dashboard
**Solution**: Check redirect logic - should NOT redirect from /verify-email to /dashboard unless AuthAuthenticated

### Issue: User can access /dashboard without verification
**Solution**: Make sure redirect checks `authState is AuthAuthenticated` before allowing /dashboard access

---

## Advanced Configuration

### Custom Error Page

Add a custom error page:

```dart
errorBuilder: (context, state) {
  return Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Oops! Something went wrong.'),
          Text('Error: ${state.error}'),
          ElevatedButton(
            onPressed: () => context.go('/splash'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  );
}
```

### Deep Linking Support

Enable deep linking for email verification links from emails:

```dart
GoRoute(
  path: '/verify-email',
  builder: (context, state) {
    // Support deep linking: /verify-email?token=xxx&email=yyy
    final token = state.uri.queryParameters['token'];
    final email = state.extra as String? ?? 
                 state.uri.queryParameters['email'];
    
    if (token != null) {
      // Auto-submit token if provided via deep link
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthBloc>().add(VerifyEmailRequested(token));
      });
    }
    
    return EmailVerificationScreen(email: email);
  },
),
```

Then in email, use: `https://app.eduverse.edu/verify-email?token=xxx&email=user@example.com`

---

## Summary

✅ Add `/verify-email` route to your GoRouter configuration
✅ Import EmailVerificationScreen in your router file
✅ Test all navigation flows
✅ Test redirect logic
✅ Optional: Implement deep linking for email links

**Status**: Ready to implement
