import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/language/language_cubit.dart';
import '../../../generated_l10n/app_localizations.dart';

class InstructorCalendarAppBar extends StatelessWidget {
  final VoidCallback onAddEvent;

  const InstructorCalendarAppBar({
    super.key,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(context, l10n, isDark),
          Row(
            children: [
              _buildAddEventButton(context, l10n, isDark),
              const SizedBox(width: 12),
              _buildLanguageToggle(context, isDark),
              const SizedBox(width: 8),
              _buildThemeToggle(context, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.back,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEventButton(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: onAddEvent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF155CFB), Color(0xFF1E40AF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF155CFB).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_rounded,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.addEvent,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context, bool isDark) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return GestureDetector(
          onTap: () {
            final newLocale =
                locale.languageCode == 'en' ? 'ar' : 'en';
            context.read<LanguageCubit>().changeLanguage(newLocale);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2939) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              locale.languageCode == 'en' ? 'ع' : 'En',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 18,
          color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
        ),
      ),
    );
  }
}
