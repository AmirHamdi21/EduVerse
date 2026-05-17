import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';

class AiChatAppBar extends StatelessWidget {
  final VoidCallback onClearChat;

  const AiChatAppBar({super.key, required this.onClearChat});

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
              _buildLanguageToggle(context, isDark),
              const SizedBox(width: 12),
              _buildThemeToggle(context, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => safeBack(context, '/dashboard'),
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
              iosBackIcon(context),
              size: 16,
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.back,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF4A5565),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2939).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                locale.languageCode.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2939).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 20,
          color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
