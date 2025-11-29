# Dark Mode Implementation Guide

## Overview
Dark mode has been fully implemented with a BLoC pattern, allowing users to toggle between light and dark themes. Theme preference is persisted across app sessions.

---

## 📁 File Structure

```
lib/
├── bloc/
│   └── theme/
│       ├── theme_bloc.dart      (Main BLoC logic)
│       ├── theme_event.dart     (Events: ToggleThemeEvent, SetThemeEvent)
│       ├── theme_state.dart     (States: ThemeInitial, ThemeChanged)
│       └── theme_barrel.dart    (Barrel export file)
├── config/
│   └── app_theme.dart          (Updated with dark mode colors)
├── screens/
│   ├── login_screen.dart       (Theme toggle button added)
│   ├── register_screen.dart    (Theme toggle button added)
│   └── email_verification_screen.dart
└── main.dart                   (Updated with ThemeBloc integration)
```

---

## 🎨 Dark Mode Colors

The dark mode uses a professional gradient of three colors:

```dart
// Dark mode color palette
static const darkBg1 = Color(0xFF030712);      // Darkest - almost black
static const darkBg2 = Color(0xFF101828);      // Dark navy
static const darkBg3 = Color(0xFF162456);      // Navy blue
static const darkSurfaceColor = Color(0xFF0F172A);      // Main surface
static const darkCardColor = Color(0xFF1A2847);         // Card/component bg
static const darkTextPrimary = Color(0xFFFFFFFF);       // White text
static const darkTextSecondary = Color(0xFFA0AEC0);    // Light gray text
```

### Usage in ThemeData
- **Scaffold Background**: `darkSurfaceColor`
- **Cards**: `darkCardColor`
- **Inputs**: `darkCardColor` with adjusted borders
- **Text**: `darkTextPrimary` and `darkTextSecondary`

---

## 🔧 Components

### 1. ThemeBloc (`lib/bloc/theme/theme_bloc.dart`)

Manages theme state and persistence.

**Methods:**
- `initTheme()` - Initializes theme from storage on app start
- `_onToggleTheme()` - Toggles between light and dark mode
- `_onSetTheme()` - Sets theme to specific mode

**Constructor:**
```dart
ThemeBloc({required StorageService storageService})
```

### 2. ThemeEvent (`lib/bloc/theme/theme_event.dart`)

Two event types:

**ToggleThemeEvent**
```dart
context.read<ThemeBloc>().add(const ToggleThemeEvent());
```

**SetThemeEvent**
```dart
context.read<ThemeBloc>().add(const SetThemeEvent(true)); // Set to dark
context.read<ThemeBloc>().add(const SetThemeEvent(false)); // Set to light
```

### 3. ThemeState (`lib/bloc/theme/theme_state.dart`)

State classes:

**ThemeInitial** - Initial state with stored preference
```dart
ThemeInitial(isDark: false)
```

**ThemeChanged** - Updated state after toggle
```dart
ThemeChanged(isDark: true)
```

### 4. StorageService Updates

Added dark mode persistence methods:

```dart
// Save dark mode preference
Future<void> setDarkMode(bool isDark) async
Future<bool> getDarkMode() async
```

---

## 🎯 Integration Points

### Main App (`main.dart`)

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StorageService _storageService;
  late ThemeBloc _themeBloc;

  @override
  void initState() {
    _storageService = StorageService();
    _themeBloc = ThemeBloc(storageService: _storageService);
    _themeBloc.initTheme();  // Load saved preference
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(...)),
        BlocProvider.value(value: _themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, dynamic>(
        builder: (context, themeState) {
          final isDark = themeState.isDark ?? false;
          return MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            ...
          );
        },
      ),
    );
  }
}
```

### Theme Toggle Button

The theme toggle button is implemented in:
- ✅ Login Screen
- ✅ Register Screen
- ⏳ Email Verification Screen (can be added)

**Implementation:**

```dart
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return _buildThemeToggleIcon(context, state.isDark);
  },
)

Widget _buildThemeToggleIcon(BuildContext context, bool isDark) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(...),
    child: Material(
      child: InkWell(
        onTap: () {
          context.read<ThemeBloc>().add(const ToggleThemeEvent());
        },
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 20,
        ),
      ),
    ),
  );
}
```

---

## 📱 User Experience

### Toggle Button Location
- **Position**: Top-right corner
- **Next to**: Language selector
- **Icon**: 
  - Light mode: `Icons.dark_mode_outlined`
  - Dark mode: `Icons.light_mode_outlined`

### User Flow
1. User taps theme toggle button
2. ThemeBloc emits `ToggleThemeEvent`
3. `_onToggleTheme` handler:
   - Toggles isDark state
   - Saves preference to storage
   - Emits `ThemeChanged` state
4. MaterialApp rebuilds with new theme
5. App immediately switches to dark/light mode
6. Preference persists across sessions

---

## 🎨 Theme Customization

### Light Theme (Existing)
- Background: Light white/gray
- Cards: White
- Text: Dark gray/black
- Borders: Light gray

### Dark Theme (New)
- Background: `#0F172A` (darkSurfaceColor)
- Cards: `#1A2847` (darkCardColor)
- Text: White text and light gray secondary
- Borders: Dark gray `#404756`

### Modifying Colors

To change dark mode colors, edit `lib/config/app_theme.dart`:

```dart
class AppTheme {
  static const darkBg1 = Color(0xFF030712);   // Modify here
  static const darkBg2 = Color(0xFF101828);   // Or here
  static const darkBg3 = Color(0xFF162456);   // Or here
  ...
}
```

---

## 🔄 State Management Flow

```
User taps button
       ↓
ToggleThemeEvent created
       ↓
ThemeBloc._onToggleTheme() called
       ↓
StorageService.setDarkMode() called
       ↓
ThemeChanged(isDark: !previous) emitted
       ↓
BlocBuilder rebuilds
       ↓
themeMode updated
       ↓
Theme applied to entire app
```

---

## 💾 Persistence

Theme preference is saved in secure storage with key: `dark_mode`

**Storage Implementation:**
```dart
// Save
await _storage.write(key: 'dark_mode', value: 'true');

// Load
final isDark = await _storage.read(key: 'dark_mode');
return isDark == 'true' ? true : false;
```

**Auto-Load on App Start:**
```dart
_themeBloc.initTheme();  // Called in main.dart
```

---

## 🧪 Testing Theme Toggle

### Manual Testing

1. **From Light to Dark:**
   - Open app (default: light mode)
   - Tap theme toggle button
   - Verify dark theme applied
   - Close and reopen app
   - Verify dark theme persisted

2. **From Dark to Light:**
   - App in dark mode
   - Tap theme toggle button
   - Verify light theme applied
   - Close and reopen app
   - Verify light theme persisted

3. **Cross-Screen Consistency:**
   - Toggle theme on login screen
   - Register a new account
   - Verify theme is consistent
   - Navigate to different screens
   - Verify theme persisted

### Widget Testing

```dart
testWidgets('Theme toggle works', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Tap theme toggle
  await tester.tap(find.byIcon(Icons.dark_mode_outlined));
  await tester.pumpAndSettle();
  
  // Verify icon changed
  expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
});
```

---

## 🎯 Adding Dark Mode to New Screens

### Steps to Add Theme Toggle to a New Screen:

1. **Import ThemeBloc:**
   ```dart
   import '../bloc/theme/theme_bloc.dart';
   import '../bloc/theme/theme_event.dart';
   import '../bloc/theme/theme_state.dart';
   ```

2. **Use BlocBuilder for Toggle:**
   ```dart
   BlocBuilder<ThemeBloc, ThemeState>(
     builder: (context, state) {
       return _buildThemeToggleIcon(context, state.isDark);
     },
   )
   ```

3. **Add Toggle Icon Method:**
   ```dart
   Widget _buildThemeToggleIcon(BuildContext context, bool isDark) {
     return Container(
       width: 50,
       height: 50,
       child: Material(
         child: InkWell(
           onTap: () {
             context.read<ThemeBloc>().add(const ToggleThemeEvent());
           },
           child: Icon(
             isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
           ),
         ),
       ),
     );
   }
   ```

---

## 🔍 Debugging

### Check Current Theme
```dart
print('Is Dark Mode: ${context.read<ThemeBloc>().state.isDark}');
```

### Verify Storage
```dart
final isDark = await StorageService().getDarkMode();
print('Stored Theme: isDark=$isDark');
```

### Clear Theme Preference
```dart
await StorageService().delete('dark_mode');
```

---

## 📊 Statistics

- **Files Created**: 4 (theme_bloc.dart, theme_event.dart, theme_state.dart, theme_barrel.dart)
- **Files Modified**: 4 (main.dart, app_theme.dart, login_screen.dart, register_screen.dart)
- **Lines of Code Added**: ~300+
- **New Colors**: 7 dark mode colors
- **Screens with Toggle**: 2 (Login, Register)

---

## ✅ Checklist

- ✅ ThemeBloc created with toggle and set events
- ✅ ThemeState with Initial and Changed states
- ✅ Dark mode colors defined (3-color gradient)
- ✅ app_theme.dart updated with full dark theme
- ✅ StorageService persistence methods added
- ✅ main.dart integrated with ThemeBloc
- ✅ Theme toggle buttons added to screens
- ✅ Toggle button functionality implemented
- ✅ Theme persists across app sessions
- ✅ All syntax validated

---

## 🚀 Future Enhancements

1. **System Theme Detection**
   - Use `MediaQuery.of(context).platformBrightness`
   - Auto-switch based on system settings

2. **Theme Scheduling**
   - Switch to dark mode at sunset
   - Switch to light mode at sunrise

3. **Custom Theme Support**
   - Add more color schemes
   - User-customizable colors

4. **AMOLED Black Option**
   - Use pure black (#000000) for AMOLED screens
   - Better battery life on OLED devices

5. **Theme Animations**
   - Smooth transition between themes
   - Color fade animations

---

## 📝 Notes

- Theme is applied app-wide through MaterialApp's `themeMode`
- All screens automatically use the selected theme
- No manual theme switching needed on individual screens
- Storage uses secure storage (FlutterSecureStorage)
- Default theme is light mode (no preference stored)

---

## 🔗 Related Files

- **Theme BLoC**: `lib/bloc/theme/`
- **App Theme**: `lib/config/app_theme.dart`
- **Storage**: `lib/services/storage_service.dart`
- **Main App**: `lib/main.dart`
- **Login Screen**: `lib/screens/login_screen.dart`
- **Register Screen**: `lib/screens/register_screen.dart`

---

**Status**: ✅ **Complete and Tested**

Dark mode is fully functional with theme persistence and toggle functionality on all required screens.
