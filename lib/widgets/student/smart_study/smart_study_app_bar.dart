import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/smart_study/smart_study_cubit.dart';
import '../../../bloc/smart_study/smart_study_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/language/language_cubit.dart';
import '../../../generated_l10n/app_localizations.dart';

class SmartStudyAppBar extends StatelessWidget {
  final bool isDark;

  const SmartStudyAppBar({
    super.key,
    required this.isDark,
  });

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
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBackButton(context, l10n),
              _buildActionButtons(context),
            ],
          ),
          const SizedBox(height: 16),
          // Title section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2B7FFF).withValues(alpha: 0.2),
                        const Color(0xFF155DFC).withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF2B7FFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.smartStudyTitle,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.smartStudySubtitle,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, AppLocalizations l10n) {
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
                color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.back,
                style: TextStyle(
                  color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
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
    return BlocBuilder<SmartStudyCubit, SmartStudyState>(
      builder: (context, state) {
        return Row(
          children: [
            // Regenerate button
            _buildRegenerateButton(context, state),
            const SizedBox(width: 8),
            // Language toggle
            _buildLanguageButton(context),
            const SizedBox(width: 8),
            // Theme toggle
            _buildThemeButton(context),
          ],
        );
      },
    );
  }

  Widget _buildRegenerateButton(BuildContext context, SmartStudyState state) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state.isRegenerating
            ? null
            : () => context.read<SmartStudyCubit>().regeneratePlan(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2939).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF364153) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.isRegenerating)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
                ),
              const SizedBox(width: 6),
              Text(
                l10n.smartStudyRegenerate,
                style: TextStyle(
                  color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
              context.read<LanguageCubit>().changeLanguage(isArabic ? 'en' : 'ar');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2939).withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF364153) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Center(
                child: Text(
                  isArabic ? 'EN' : 'AR',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
                    fontSize: 11,
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2939).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF364153) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 18,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
          ),
        ),
      ),
    );
  }
}
