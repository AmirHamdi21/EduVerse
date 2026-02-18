import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/language/language_cubit.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminLanguageSettingsScreen extends StatelessWidget {
  const AdminLanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final currentLocale = Localizations.localeOf(context);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: AppBar(
            backgroundColor: AdminColors.getBackgroundColor(isDark),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            title: Text(
              l10n.language,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCurrentLanguageCard(isDark, l10n, currentLocale, responsive),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.availableLanguages, isDark),
                  SizedBox(height: responsive.p12),
                  _buildLanguageOption(
                    context: context,
                    isDark: isDark,
                    languageCode: 'en',
                    languageName: 'English',
                    nativeName: 'English',
                    flag: '🇺🇸',
                    isSelected: currentLocale.languageCode == 'en',
                  ),
                  SizedBox(height: responsive.p12),
                  _buildLanguageOption(
                    context: context,
                    isDark: isDark,
                    languageCode: 'ar',
                    languageName: 'Arabic',
                    nativeName: 'العربية',
                    flag: '🇸🇦',
                    isSelected: currentLocale.languageCode == 'ar',
                  ),
                  SizedBox(height: responsive.p24),
                  _buildInfoCard(isDark, l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentLanguageCard(
      bool isDark, AppLocalizations l10n, Locale locale, ResponsiveUtil responsive) {
    final isEnglish = locale.languageCode == 'en';
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEnglish ? '🇺🇸' : '🇸🇦',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentLanguage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnglish ? 'English' : 'العربية',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.active,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required bool isDark,
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<LanguageCubit>().changeLanguage(languageCode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AdminColors.primary
                : AdminColors.getCardBorderColor(isDark),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AdminColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AdminColors.primary.withValues(alpha: 0.1)
                    : AdminColors.getBackgroundColor(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 14,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? AdminColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AdminColors.primary
                      : AdminColors.getTextTertiaryColor(isDark),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AdminColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.languageChangeNote,
              style: TextStyle(
                fontSize: 13,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
