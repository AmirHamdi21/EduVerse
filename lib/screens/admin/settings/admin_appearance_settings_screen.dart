import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminAppearanceSettingsScreen extends StatefulWidget {
  const AdminAppearanceSettingsScreen({super.key});

  @override
  State<AdminAppearanceSettingsScreen> createState() =>
      _AdminAppearanceSettingsScreenState();
}

class _AdminAppearanceSettingsScreenState
    extends State<AdminAppearanceSettingsScreen> {
  AccentColor _selectedAccent = AccentColor.blue;
  bool _reduceMotion = false;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final currentThemeMode = themeState.themeMode;
        final currentFontSize = themeState.fontSize;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionTitle(l10n.theme, isDark),
                  SizedBox(height: responsive.p12),
                  _buildThemeSelector(isDark, l10n, currentThemeMode),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.primaryColorAccent, isDark),
                  SizedBox(height: responsive.p12),
                  _buildAccentColorSelector(isDark),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.fontSize, isDark),
                  SizedBox(height: responsive.p12),
                  _buildFontSizeSelector(isDark, l10n, currentFontSize),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.accessibility, isDark),
                  SizedBox(height: responsive.p12),
                  _buildAccessibilitySettings(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildPreviewCard(isDark, l10n),
                  SizedBox(height: responsive.p32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
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
        l10n.appearance,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AdminColors.getTextSecondaryColor(isDark),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
      bool isDark, AppLocalizations l10n, AppThemeMode currentMode) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Row(
        children: [
          _buildThemeOption(
            currentIsDark: isDark,
            isSelected: currentMode == AppThemeMode.light,
            icon: Icons.light_mode_rounded,
            label: l10n.light,
            selectedColor: const Color(0xFFF59E0B),
            onTap: () {
              HapticFeedback.selectionClick();
              context
                  .read<ThemeBloc>()
                  .add(const SetThemeModeEvent(AppThemeMode.light));
            },
          ),
          _buildThemeOption(
            currentIsDark: isDark,
            isSelected: currentMode == AppThemeMode.dark,
            icon: Icons.dark_mode_rounded,
            label: l10n.dark,
            selectedColor: const Color(0xFF6366F1),
            onTap: () {
              HapticFeedback.selectionClick();
              context
                  .read<ThemeBloc>()
                  .add(const SetThemeModeEvent(AppThemeMode.dark));
            },
          ),
          _buildThemeOption(
            currentIsDark: isDark,
            isSelected: currentMode == AppThemeMode.system,
            icon: Icons.settings_suggest_rounded,
            label: l10n.systemDefault,
            selectedColor: AdminColors.primary,
            onTap: () {
              HapticFeedback.selectionClick();
              context
                  .read<ThemeBloc>()
                  .add(const SetThemeModeEvent(AppThemeMode.system));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required bool currentIsDark,
    required bool isSelected,
    required IconData icon,
    required String label,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AdminColors.getTextSecondaryColor(currentIsDark),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AdminColors.getTextSecondaryColor(currentIsDark),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccentColorSelector(bool isDark) {
    final colors = [
      (AdminColors.primary, 'Blue'),
      (const Color(0xFF8B5CF6), 'Purple'),
      (const Color(0xFFEC4899), 'Pink'),
      (const Color(0xFF10B981), 'Green'),
      (const Color(0xFFF59E0B), 'Orange'),
      (const Color(0xFFEF4444), 'Red'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors.map((colorData) {
          final color = colorData.$1;
          final name = colorData.$2;
          final isSelected = _selectedAccent == AccentColor.blue &&
              color == AdminColors.primary;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedAccent = AccentColor.blue);
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 24)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFontSizeSelector(
      bool isDark, AppLocalizations l10n, FontSizeOption currentSize) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Row(
        children: [
          _buildFontSizeOption(
            isDark: isDark,
            label: l10n.small,
            fontSize: 12,
            isSelected: currentSize == FontSizeOption.small,
            onTap: () {
              context
                  .read<ThemeBloc>()
                  .add(const SetFontSizeEvent(FontSizeOption.small));
            },
          ),
          _buildFontSizeOption(
            isDark: isDark,
            label: l10n.medium,
            fontSize: 14,
            isSelected: currentSize == FontSizeOption.medium,
            onTap: () {
              context
                  .read<ThemeBloc>()
                  .add(const SetFontSizeEvent(FontSizeOption.medium));
            },
          ),
          _buildFontSizeOption(
            isDark: isDark,
            label: l10n.large,
            fontSize: 16,
            isSelected: currentSize == FontSizeOption.large,
            onTap: () {
              context
                  .read<ThemeBloc>()
                  .add(const SetFontSizeEvent(FontSizeOption.large));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeOption({
    required bool isDark,
    required String label,
    required double fontSize,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? AdminColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: isSelected
                    ? Colors.white
                    : AdminColors.getTextSecondaryColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibilitySettings(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          _buildToggleTile(
            isDark: isDark,
            icon: Icons.motion_photos_off_rounded,
            title: l10n.reduceMotion,
            subtitle: l10n.reduceMotionDesc,
            value: _reduceMotion,
            onChanged: (v) => setState(() => _reduceMotion = v),
          ),
          Divider(
            color: AdminColors.getDividerColor(isDark),
            height: 1,
            indent: 56,
          ),
          _buildToggleTile(
            isDark: isDark,
            icon: Icons.contrast_rounded,
            title: l10n.highContrast,
            subtitle: l10n.highContrastDesc,
            value: _highContrast,
            onChanged: (v) => setState(() => _highContrast = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AdminColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AdminColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AdminColors.getTextColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AdminColors.getTextSecondaryColor(isDark),
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AdminColors.primary,
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.preview,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sampleHeading,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.sampleText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
