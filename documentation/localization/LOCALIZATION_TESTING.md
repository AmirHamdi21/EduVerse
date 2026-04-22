# Testing the Localization Implementation

## Pre-Test Verification

Make sure all files are in place:

```bash
# In your project root, verify these files exist:
✓ l10n.yaml
✓ lib/l10n/app_en.arb (43 keys)
✓ lib/l10n/app_ar.arb (43 keys)
✓ lib/generated_l10n/app_localizations.dart
✓ lib/generated_l10n/app_localizations_en.dart
✓ lib/generated_l10n/app_localizations_ar.dart
✓ lib/bloc/language/language_cubit.dart
✓ lib/screens/settings/example_settings_screen.dart
✓ pubspec.yaml (updated with intl and flutter_localizations)
```

## Test 1: Verify Dependencies

```bash
cd your_project
flutter pub get
```

Expected output: `Got dependencies!` with no errors.

## Test 2: Regenerate Localization Files

```bash
flutter gen-l10n
```

Expected output: Command completes silently (success indicated by exit code 0).

Check that these files were generated/updated:
- `lib/generated_l10n/app_localizations.dart`
- `lib/generated_l10n/app_localizations_en.dart`
- `lib/generated_l10n/app_localizations_ar.dart`

## Test 3: Analyze Code

```bash
flutter analyze
```

Expected: No errors related to `generated_l10n`, `language_cubit`, or localization imports.

(Pre-existing warnings about deprecated methods are OK - not related to localization)

## Test 4: Test in Code - Manual Widget Test

Create a temporary test widget:

```dart
import 'package:flutter/material.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class LocalizationTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l!.appTitle),        // Should show "EduVerse"
            Text(l.hello),             // Should show "Hello"
            Text(l.welcome),           // Should show "Welcome to EduVerse"
            Text(l.loginTitle),        // Should show "Welcome Back"
          ],
        ),
      ),
    );
  }
}
```

Expected: All translations render without errors.

## Test 5: Test Language Switching (Using Example Screen)

1. **Add the example screen to your router** (temporary for testing):

```dart
// In your app_router.dart or navigation
import 'package:edu_verse/screens/settings/example_settings_screen.dart';

// Add route
GoRoute(
  path: '/settings-test',
  builder: (context, state) => const ExampleSettingsScreen(),
),
```

2. **Navigate to the example screen**:
```dart
context.go('/settings-test');
```

3. **Test language switching**:
   - Tap "English" → Should see checkmark next to English
   - Tap "العربية" → Should see checkmark next to Arabic
   - Text should immediately update to Arabic
   - Tap "English" → Should see checkmark next to English
   - Text should update back to English

4. **Close and reopen app**:
   - The app should remember your language choice!

## Test 6: Integration Test Script

Create `test/localization_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/main.dart';

void main() {
  testWidgets('Language switching updates UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Verify initial locale is English
    expect(find.text('Login'), findsWidgets);
    
    // Change to Arabic
    context.read<LanguageCubit>().changeLanguage('ar');
    await tester.pumpAndSettle();
    
    // Verify Arabic text is shown
    expect(find.text('تسجيل الدخول'), findsWidgets);
    
    // Change back to English
    context.read<LanguageCubit>().changeLanguage('en');
    await tester.pumpAndSettle();
    
    // Verify English text is shown
    expect(find.text('Login'), findsWidgets);
  });
}
```

Run with:
```bash
flutter test
```

## Test 7: Manual Runtime Test

1. **Run the app**:
```bash
flutter run
```

2. **Test in your actual screens**:
   - Look for any widget using `AppLocalizations.of(context)!`
   - Verify translations appear correctly
   - Change language using the example settings screen
   - Verify all text updates immediately

3. **Test persistence**:
   - Change language to Arabic
   - Stop the app (close)
   - Reopen the app
   - Verify it starts in Arabic (language preference was saved)

## Troubleshooting

### Issue: "AppLocalizations.of(context) returned null"
**Solution**: Make sure `AppLocalizations.delegate` is in `localizationsDelegates`

### Issue: "Generated files don't have my new translation key"
**Solution**: 
1. Make sure you added the key to BOTH `app_en.arb` and `app_ar.arb`
2. Run `flutter gen-l10n`
3. Rebuild your app

### Issue: "Language doesn't change in the app"
**Solution**: 
1. Verify `LanguageCubit` is added to `BlocProvider`
2. Verify you're calling `changeLanguage()` correctly
3. Check that `AppLocalizations.of(context)` is called in a widget that rebuilds
4. Make sure you're using `context.read<LanguageCubit>()` not a static reference

### Issue: "Error: Unknown locale: 'ar'"
**Solution**: Add the locale to `supportedLocales` in `MaterialApp`:
```dart
supportedLocales: const [
  Locale('en'),
  Locale('ar'),  // Make sure this is here
],
```

### Issue: "Cannot import app_localizations"
**Solution**:
1. Run `flutter pub get`
2. Run `flutter gen-l10n`
3. If error persists, run `flutter clean` then `flutter pub get`

## Verification Checklist

- [ ] `flutter pub get` succeeds
- [ ] `flutter gen-l10n` produces no errors
- [ ] `flutter analyze` shows no localization errors
- [ ] Example screen navigates without crashes
- [ ] Tapping language options changes the UI text
- [ ] Closing and reopening app preserves language choice
- [ ] All hardcoded text uses `AppLocalizations.of(context)!.translationKey`
- [ ] Both English and Arabic text render correctly
- [ ] RTL text (Arabic) displays right-to-left

## Performance Checklist

- [ ] App starts in <2 seconds
- [ ] Language switching is immediate (no noticeable delay)
- [ ] No memory leaks after multiple language switches
- [ ] Locale changes don't trigger full app rebuild
- [ ] SharedPreferences save/load is async and non-blocking

## Next Steps After Testing

1. ✅ Integrate the example settings screen into your app's actual settings
2. ✅ Replace all hardcoded UI strings with `AppLocalizations` calls
3. ✅ Add more languages by creating `app_xx.arb` files
4. ✅ Test in different device locales and screen sizes
5. ✅ Add localization tests to your CI/CD pipeline
6. ✅ Submit to app stores (Google Play, App Store) with localization

## Quick Commands Reference

```bash
# Check dependencies are installed
flutter pub get

# Generate localization files
flutter gen-l10n

# Analyze code
flutter analyze

# Run tests
flutter test

# Run app
flutter run

# Clean build
flutter clean
flutter pub get
flutter gen-l10n

# Build for production
flutter build apk
flutter build ios
flutter build web
```

## Support Resources

If you encounter issues:

1. Check `LOCALIZATION_QUICK_REFERENCE.md` for common patterns
2. Review `LOCALIZATION_GUIDE.md` for architecture details
3. Look at `lib/screens/settings/example_settings_screen.dart` for working example
4. Check Flutter docs: https://flutter.dev/docs/development/accessibility-and-localization/internationalization

## Additional Testing Ideas

### Test Theme + Language Together
```dart
// In example_settings_screen.dart
// Both language and theme switching should work simultaneously
```

### Test with More Languages
Add `lib/l10n/app_fr.arb` for French and verify it works.

### Test RTL (Right-to-Left) Direction
Arabic should automatically display RTL. Verify in:
- Text alignment
- Button placement
- List items
- Navigation

### Test with Long Strings
Add a long translation string and verify:
- Text doesn't overflow
- Text wraps properly
- UI layout adapts
