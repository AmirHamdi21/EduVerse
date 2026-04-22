# 🎯 Localization - Quick Start Guide

## ⚡ 30-Second Overview

Your Flutter app now has professional localization support:
- **43 translations** already included (English + Arabic)
- **Language switching** managed by BLoC (LanguageCubit)
- **Automatic persistence** via SharedPreferences
- **RTL support** for Arabic (automatic)

## 📝 Use Translations in Your Widgets

```dart
import 'package:edu_verse/generated_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.hello);        // "Hello" or "مرحبا"
Text(AppLocalizations.of(context)!.loginTitle);   // "Welcome Back" or "مرحبًا بعودتك"
```

**That's it!** No more hardcoded strings.

## 🔄 Switch Language

```dart
// Change to Arabic
context.read<LanguageCubit>().changeLanguage('ar');

// Change to English  
context.read<LanguageCubit>().changeLanguage('en');

// Get current language
String lang = context.read<LanguageCubit>().getCurrentLanguage();
```

## 📋 Available Translations

See all 43 available keys in `LOCALIZATION_QUICK_REFERENCE.md`

Common ones:
```dart
l.appTitle              // "EduVerse"
l.hello                 // "Hello"
l.welcome              // "Welcome to EduVerse"
l.loginTitle           // "Welcome Back"
l.email                // "Email"
l.password             // "Password"
l.save                 // "Save"
l.cancel               // "Cancel"
l.settings             // "Settings"
l.language             // "Language"
l.darkMode             // "Dark Mode"
// ... and 33 more
```

## ➕ Add New Translation

1. **Edit both ARB files**:
```json
// lib/l10n/app_en.arb
{ "myKey": "My text" }

// lib/l10n/app_ar.arb  
{ "myKey": "نصي" }
```

2. **Run**:
```bash
flutter gen-l10n
```

3. **Use**:
```dart
Text(AppLocalizations.of(context)!.myKey);
```

## ✅ Example Screen

See working example: `lib/screens/settings/example_settings_screen.dart`
- Language selector
- Theme switcher  
- Shows how to combine BLoCs
- Fully commented

## 📚 Documentation

- **LOCALIZATION_QUICK_REFERENCE.md** - Quick lookup (START HERE)
- **LOCALIZATION_GUIDE.md** - Full architecture
- **LOCALIZATION_TESTING.md** - How to test
- **LOCALIZATION_IMPLEMENTATION_SUMMARY.md** - What was built

## 🗂️ Files Structure

```
lib/
├── l10n/
│   ├── app_en.arb          ← Edit here for new translations
│   └── app_ar.arb
├── generated_l10n/         ← Auto-generated, don't edit
├── bloc/language/
│   └── language_cubit.dart ← Language switching logic
├── screens/settings/
│   └── example_settings_screen.dart  ← Reference example
└── main.dart               ← Already configured ✓
```

## ✨ Key Features

✅ Official Flutter localization system  
✅ Language persists across app restarts  
✅ RTL support for Arabic  
✅ No manual translation coding  
✅ Type-safe translations  
✅ Easy to add new languages  

## 🚀 To Get Started

### Option 1: Use Example Settings Screen
```dart
// Navigate to the example (or copy/modify it for your app)
context.go('/settings');  // Add this route to your router
```

### Option 2: Add Localization to Your Existing Screens
```dart
// Before (hardcoded):
Text('Login')

// After (localized):
import 'package:edu_verse/generated_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.loginButton)
```

### Option 3: Use in Forms/Validation
```dart
import 'package:edu_verse/generated_l10n/app_localizations.dart';

if (email.isEmpty) {
  showError(AppLocalizations.of(context)!.fieldRequired);
}
```

## ❓ Quick Troubleshooting

**Translations not showing?**
```bash
flutter gen-l10n
flutter clean
flutter pub get
```

**Language not changing?**
- Make sure LanguageCubit is in BlocProvider ✓ (already done)
- Call `context.read<LanguageCubit>().changeLanguage('ar')`

**Missing translation?**
- Add key to BOTH `app_en.arb` and `app_ar.arb`
- Run `flutter gen-l10n`

## 🎨 Architecture

User taps "Arabic" → LanguageCubit.changeLanguage('ar') 
→ Emits Locale('ar') 
→ BlocBuilder rebuilds MaterialApp 
→ Flutter applies localization 
→ All text updates to Arabic 
→ Preference saved to SharedPreferences 
→ Next launch starts in Arabic ✓

## 📱 Already Included Translations

**Authentication**: login, signup, password, email  
**Navigation**: home, courses, profile, settings  
**Actions**: save, delete, back, next, skip, done  
**Errors**: networkError, invalidEmail, passwordTooShort  
**Settings**: language, theme, darkMode, lightMode  
**Status**: loading, success, error, warning  

See full list in `LOCALIZATION_QUICK_REFERENCE.md`

## 🎯 Next Steps

1. ✅ Review `LOCALIZATION_QUICK_REFERENCE.md`
2. ✅ Check example: `lib/screens/settings/example_settings_screen.dart`
3. ✅ Test language switching (run example screen)
4. ✅ Replace hardcoded strings in your screens
5. ✅ Add more translations to ARB files as needed

## 📞 Need Help?

- **Quick answers**: See `LOCALIZATION_QUICK_REFERENCE.md`
- **How it works**: See `LOCALIZATION_GUIDE.md`  
- **Testing**: See `LOCALIZATION_TESTING.md`
- **Full details**: See `LOCALIZATION_IMPLEMENTATION_SUMMARY.md`

---

**You're all set! 🎉**

Start using `AppLocalizations.of(context)!` in your widgets today.
