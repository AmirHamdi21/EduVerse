# Localization Quick Reference

## For Developers: Using Translations

### In Any Widget

```dart
import 'package:edu_verse/generated_l10n/app_localizations.dart';

// Get the localization instance
final localizations = AppLocalizations.of(context)!;

// Use any translated string
Text(localizations.hello);
Text(localizations.welcome);
Text(localizations.loginTitle);
```

### Available Translations

Common UI elements:
- `localizations.appTitle` → "EduVerse"
- `localizations.hello` → "Hello"
- `localizations.welcome` → "Welcome to EduVerse"

Authentication:
- `localizations.loginTitle` → "Welcome Back"
- `localizations.signupTitle` → "Create Account"
- `localizations.email`, `password`, `fullName`
- `localizations.loginButton`, `signupButton`, `logout`
- `localizations.invalidEmail`, `passwordTooShort`, `passwordMismatch`

Navigation & UI:
- `localizations.homeTitle`, `coursesTitle`, `profileTitle`
- `localizations.back`, `next`, `skip`, `done`
- `localizations.save`, `delete`, `edit`, `cancel`

Settings:
- `localizations.settings` → "Settings"
- `localizations.language` → "Language"
- `localizations.english` → "English"
- `localizations.arabic` → "العربية"
- `localizations.darkMode`, `lightMode`

## For Admins: Adding New Translations

### Step 1: Edit ARB Files

Edit both files in `lib/l10n/`:

**app_en.arb:**
```json
{
  "@@locale": "en",
  "newKey": "New English Text"
}
```

**app_ar.arb:**
```json
{
  "@@locale": "ar",
  "newKey": "النص العربي الجديد"
}
```

### Step 2: Regenerate

```bash
flutter gen-l10n
```

### Step 3: Use in Code

```dart
Text(localizations.newKey);
```

## For Users: Changing Language

In your settings screen or language menu:

```dart
// Change to Arabic
context.read<LanguageCubit>().changeLanguage('ar');

// Change to English
context.read<LanguageCubit>().changeLanguage('en');

// Check current language
String lang = context.read<LanguageCubit>().getCurrentLanguage();
```

## Project Structure

```
✓ pubspec.yaml                 - Updated with intl, flutter_localizations
✓ l10n.yaml                    - Config for code generation
✓ lib/l10n/
  ✓ app_en.arb                 - All English translations (43 keys)
  ✓ app_ar.arb                 - All Arabic translations (43 keys)
✓ lib/generated_l10n/          - Auto-generated (never edit!)
  ✓ app_localizations.dart
  ✓ app_localizations_en.dart
  ✓ app_localizations_ar.dart
✓ lib/bloc/language/
  ✓ language_cubit.dart        - Manages language switching
✓ lib/main.dart                - Updated with locale support
✓ lib/screens/settings/
  ✓ example_settings_screen.dart - Example implementation
```

## Common Patterns

### Pattern 1: Simple Translation
```dart
Text(AppLocalizations.of(context)!.hello);
```

### Pattern 2: Dynamic Language Switch
```dart
ElevatedButton(
  onPressed: () {
    context.read<LanguageCubit>().changeLanguage('ar');
  },
  child: Text(AppLocalizations.of(context)!.arabic),
);
```

### Pattern 3: Store Current Language
```dart
String currentLang = context.read<LanguageCubit>().getCurrentLanguage();
// Automatically persisted to SharedPreferences!
```

### Pattern 4: Build UI Based on Language
```dart
BlocBuilder<LanguageCubit, Locale>(
  builder: (context, locale) {
    return Text('Current: ${locale.languageCode}');
  },
);
```

## Important Notes

⚠️ **DO NOT**:
- Edit files in `lib/generated_l10n/` - they're auto-generated
- Change `@@locale` values in ARB files
- Remove ARB files without updating code that uses them

✅ **ALWAYS**:
- Add translations to BOTH `app_en.arb` AND `app_ar.arb`
- Run `flutter gen-l10n` after editing ARB files
- Import from `package:edu_verse/generated_l10n/app_localizations.dart`
- Use `AppLocalizations.of(context)!` to access translations

## Troubleshooting

### Translations not showing up?
1. Make sure you ran `flutter gen-l10n`
2. Check that your key exists in both ARB files
3. Rebuild your app with `flutter clean && flutter pub get`

### Language not changing?
1. Make sure `LanguageCubit` is provided in `BlocProvider`
2. Check that you're calling `changeLanguage()` correctly
3. Verify it's available via `context.read<LanguageCubit>()`

### Missing translation key error?
1. Check the key exists in `app_localizations.dart`
2. Run `flutter gen-l10n` if you recently added it
3. Make sure the key spelling matches exactly

## Next Steps

1. ✅ Review `LOCALIZATION_GUIDE.md` for full documentation
2. ✅ Check `lib/screens/settings/example_settings_screen.dart` for implementation example
3. ✅ Start using `AppLocalizations.of(context)!` in your screens
4. ✅ Test language switching in the example settings screen
