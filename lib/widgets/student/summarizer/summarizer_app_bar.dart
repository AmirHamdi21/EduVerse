import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/language/language_cubit.dart';
import '../../../generated_l10n/app_localizations.dart';

class SummarizerAppBar extends StatelessWidget {
  final bool isDark;

  const SummarizerAppBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with back button and action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              _buildBackButton(context),
              // Action buttons
              _buildActionButtons(context),
            ],
          ),
          const SizedBox(height: 16),
          // Title and description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.summarizerTitle,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.summarizerSubtitle,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF99A1AF)
                        : const Color(0xFF4A5565),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pop(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 18,
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF4A5565),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.back,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF99A1AF)
                      : const Color(0xFF4A5565),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Language toggle
        _buildLanguageButton(context),
        const SizedBox(width: 8),
        // Theme toggle
        _buildThemeButton(context),
      ],
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        final isArabic = locale.languageCode == 'ar';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<LanguageCubit>().changeLanguage(
                isArabic ? 'en' : 'ar',
              );
            },
            borderRadius: BorderRadius.circular(22),
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
                      ? const Color(0xFF364153)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isArabic ? 'EN' : 'AR',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2939).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF364153) : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
          ),
        ),
      ),
    );
  }
}
