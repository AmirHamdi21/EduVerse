# Flutter Localization System Implementation

This document describes the official Flutter localization system (ARB + AppLocalizations + intl) that has been implemented in EduVerse.

## Overview

The localization system uses:
- **ARB files** (lib/l10n/app_*.arb) - Translation definitions for each language
- **AppLocalizations** - Auto-generated class for accessing translations
- **LanguageCubit** - BLoC for managing language switching logic
- **intl package** - Internationalization and localization library

## Architecture

### 1. Directory Structure

```
lib/
  ├── l10n/                          # Translation files
  │   ├── app_en.arb                 # English translations
  │   └── app_ar.arb                 # Arabic translations
  │
  ├── generated_l10n/                # Auto-generated (DO NOT EDIT)
  │   ├── app_localizations.dart
  │   ├── app_localizations_en.dart
  │   └── app_localizations_ar.dart
  │
  ├── bloc/
  │   └── language/
  │       └── language_cubit.dart    # Manages language switching
  │
  └── main.dart                      # Wrapped with LanguageCubit

l10n.yaml                            # Localization configuration
pubspec.yaml                         # Updated with dependencies
```

### 2. How It Works

**⭐ Key Principle**: Flutter's localization system is completely separate from BLoC.
- **Flutter handles**: Switching between language strings based on locale
- **BLoC handles**: Storing the current language preference and triggering locale changes

## Usage Guide

### Adding Translations to ARB Files

Edit `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`:

```json
{
  "@@locale": "en",
  "hello": "Hello",
  "welcome": "Welcome to EduVerse",
  "email": "Email"
}
```

### Using Translations in Widgets

```dart
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access translations
    Text(AppLocalizations.of(context)!.hello);
    Text(AppLocalizations.of(context)!.welcome);
  }
}
```

### Changing Language

From any screen or widget:

```dart
// Change to Arabic
context.read<LanguageCubit>().changeLanguage('ar');

// Change to English
context.read<LanguageCubit>().changeLanguage('en');

// Get current language
String currentLang = context.read<LanguageCubit>().getCurrentLanguage();
```

### Example: Settings Screen with Language Selector

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(localizations.language),
            subtitle: Text(localizations.english),
            onTap: () {
              context.read<LanguageCubit>().changeLanguage('en');
            },
          ),
          ListTile(
            title: Text(localizations.language),
            subtitle: Text(localizations.arabic),
            onTap: () {
              context.read<LanguageCubit>().changeLanguage('ar');
            },
          ),
        ],
      ),
    );
  }
}
```

## Workflow

### When You Add New Translations

1. **Edit ARB files** in `lib/l10n/`:
   - Add the new key-value pair to both `app_en.arb` and `app_ar.arb`
   
2. **Regenerate** localization files:
   ```bash
   flutter gen-l10n
   ```

3. **Use** in your widgets:
   ```dart
   Text(AppLocalizations.of(context)!.newTranslationKey);
   ```

### When User Changes Language

1. User taps language option in settings
2. **LanguageCubit** emits a new `Locale`
3. **BlocBuilder** in main.dart rebuilds MaterialApp with new locale
4. Flutter automatically switches all `AppLocalizations.of(context)` calls to new language
5. All widgets are rebuilt with new translations

## Advanced: Organizing Large Translation Files

For apps with many screens, split ARB files by feature:

```
lib/l10n/
  ├── app_en.arb              # Common/shared translations
  ├── app_ar.arb
  ├── auth_en.arb             # Auth module
  ├── auth_ar.arb
  ├── profile_en.arb          # Profile module
  ├── profile_ar.arb
  ├── courses_en.arb          # Courses module
  └── courses_ar.arb
```

Update `l10n.yaml` to include all files:

```yaml
arb-dir: lib/l10n
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/generated_l10n
nullable-getter: false
```

Flutter will automatically merge all ARB files at build time.

## Files Modified

1. **pubspec.yaml**
   - Added `flutter_localizations` SDK dependency
   - Added `intl: ^0.20.1` package
   - Added `generate: true` configuration

2. **l10n.yaml** (new)
   - Configures localization code generation

3. **lib/l10n/** (new)
   - `app_en.arb` - English translations
   - `app_ar.arb` - Arabic translations

4. **lib/bloc/language/** (new)
   - `language_cubit.dart` - Manages language switching

5. **lib/main.dart**
   - Added LanguageCubit initialization
   - Added BlocBuilder for locale switching
   - Added localizationsDelegates and supportedLocales

6. **lib/generated_l10n/** (auto-generated)
   - `app_localizations.dart`
   - `app_localizations_en.dart`
   - `app_localizations_ar.dart`

## Key Features

✅ **Professional Architecture** - Uses official Flutter localization  
✅ **Language Persistence** - Saves user's language choice via SharedPreferences  
✅ **BLoC Integration** - Language logic managed via LanguageCubit  
✅ **Automatic Generation** - No manual translation class coding needed  
✅ **RTL Support** - Automatically handles Right-to-Left languages (Arabic)  
✅ **Scalable** - Easy to add new languages and organize translations  

## Common Tasks

### Add a New Language

1. Create `lib/l10n/app_xx.arb` (where xx is language code)
2. Copy all keys from `app_en.arb` and translate values
3. Update `supportedLocales` in main.dart
4. Run `flutter gen-l10n`
5. Done!

### Add a Missing Translation

1. Edit the appropriate ARB file(s)
2. Run `flutter gen-l10n`
3. Flutter rebuilds and shows the new translation

### Debug Translations

```dart
// Print current locale
print(AppLocalizations.of(context)!.toString());

// Check all available translations
print(Locale('ar').toString());
```

## Notes

- Never manually edit files in `lib/generated_l10n/` - they're auto-generated
- Always run `flutter gen-l10n` after modifying ARB files
- The `@@locale` field in ARB files tells Flutter which language each file represents
- `LanguageCubit` stores the preference in SharedPreferences under key `'selected_locale'`
- RTL is handled automatically by Flutter when using Arabic locale

## References

- [Flutter Internationalization Guide](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle)
- [intl Package Documentation](https://pub.dev/packages/intl)
