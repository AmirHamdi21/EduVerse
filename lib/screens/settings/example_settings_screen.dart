import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

/// Example Settings Screen demonstrating language switching with BLoC
///
/// This is a reference implementation showing:
/// - How to read translations using AppLocalizations
/// - How to change language using LanguageCubit
/// - How to combine with ThemeBloc for dark mode
///
/// To use this in your app, either:
/// 1. Copy this as a starting point for your settings screen
/// 2. Use the patterns shown here in your existing settings screen
///
class ExampleSettingsScreen extends StatelessWidget {
  const ExampleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: ListView(
        children: [
          _buildLanguageSection(context, localizations),
          Divider(),
          _buildThemeSection(context, localizations),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            localizations.language,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _buildLanguageOption(
          context,
          localizations,
          'en',
          localizations.english,
        ),
        _buildLanguageOption(
          context,
          localizations,
          'ar',
          localizations.arabic,
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    AppLocalizations localizations,
    String languageCode,
    String languageName,
  ) {
    final currentLanguage = context.read<LanguageCubit>().getCurrentLanguage();
    final isSelected = currentLanguage == languageCode;

    return ListTile(
      title: Text(languageName),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        context.read<LanguageCubit>().changeLanguage(languageCode);
        // Optional: Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $languageName'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            localizations.theme,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        BlocBuilder<ThemeBloc, dynamic>(
          builder: (context, themeState) {
            final isDark = themeState.isDark;

            return SwitchListTile(
              title: Text(
                isDark ? localizations.darkMode : localizations.lightMode,
              ),
              value: isDark,
              onChanged: (value) {
                context.read<ThemeBloc>().add(SetThemeEvent(value));
              },
            );
          },
        ),
      ],
    );
  }
}

/// Usage example in your app:
///
/// ```dart
/// // In your router or main navigation
/// GoRoute(
///   path: '/settings',
///   builder: (context, state) => const ExampleSettingsScreen(),
/// ),
///
/// // Or use in Navigator
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ExampleSettingsScreen(),
///   ),
/// );
/// ```
///
/// Key patterns demonstrated:
///
/// 1. **Reading translations**:
///    ```dart
///    final localizations = AppLocalizations.of(context)!;
///    Text(localizations.language);
///    ```
///
/// 2. **Changing language**:
///    ```dart
///    context.read<LanguageCubit>().changeLanguage('ar');
///    ```
///
/// 3. **Getting current language**:
///    ```dart
///    String currentLang = context.read<LanguageCubit>().getCurrentLanguage();
///    ```
///
/// 4. **Combining with other BLoCs**:
///    ```dart
///    BlocBuilder<ThemeBloc, dynamic>(
///      builder: (context, state) {
///        // Access both language and theme
///      },
///    )
///    ```
