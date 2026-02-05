import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class CalendarAppBar extends StatelessWidget {
  final VoidCallback onAddEvent;

  const CalendarAppBar({
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

  Widget _buildBackButton(BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
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
                color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEventButton(BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: onAddEvent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
            final newLang = locale.languageCode == 'en' ? 'ar' : 'en';
            context.read<LanguageCubit>().changeLanguage(newLang);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF1E2939).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Center(
              child: Text(
                locale.languageCode.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF1E2939).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 18,
          color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
