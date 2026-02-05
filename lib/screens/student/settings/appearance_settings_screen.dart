import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../bloc/profile/profile_models.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  AccentColor _selectedAccent = AccentColor.blue;
  bool _reduceMotion = false;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;
    final currentThemeMode = themeState.themeMode;
    final currentFontSize = themeState.fontSize;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.appearance,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Theme Section
          _buildSectionTitle(l10n.theme, isDark),
          const SizedBox(height: 12),
          _buildThemeSelector(isDark, l10n, currentThemeMode),
          const SizedBox(height: 24),

          // Accent Color
          _buildSectionTitle(l10n.primaryColorAccent, isDark),
          const SizedBox(height: 12),
          _buildAccentColorSelector(isDark),
          const SizedBox(height: 24),

          // Font Size
          _buildSectionTitle(l10n.fontSize, isDark),
          const SizedBox(height: 12),
          _buildFontSizeSelector(isDark, l10n, currentFontSize),
          const SizedBox(height: 24),

          // Accessibility
          _buildSectionTitle(l10n.accessibility, isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.motion_photos_off_rounded,
              title: l10n.reduceMotion,
              subtitle: l10n.reduceMotionDesc,
              value: _reduceMotion,
              onChanged: (v) => setState(() => _reduceMotion = v),
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.contrast_rounded,
              title: l10n.highContrast,
              subtitle: l10n.highContrastDesc,
              value: _highContrast,
              onChanged: (v) => setState(() => _highContrast = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Preview Card
          _buildPreviewCard(isDark),
          const SizedBox(height: 32),
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(bool isDark, AppLocalizations l10n, AppThemeMode currentMode) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              context.read<ThemeBloc>().add(const SetThemeModeEvent(AppThemeMode.light));
            },
          ),
          const SizedBox(width: 8),
          _buildThemeOption(
            currentIsDark: isDark,
            isSelected: currentMode == AppThemeMode.dark,
            icon: Icons.dark_mode_rounded,
            label: l10n.dark,
            selectedColor: const Color(0xFF6366F1),
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<ThemeBloc>().add(const SetThemeModeEvent(AppThemeMode.dark));
            },
          ),
          const SizedBox(width: 8),
          _buildThemeOption(
            currentIsDark: isDark,
            isSelected: currentMode == AppThemeMode.system,
            icon: Icons.settings_suggest_rounded,
            label: l10n.system,
            selectedColor: const Color(0xFF3B82F6),
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<ThemeBloc>().add(const SetThemeModeEvent(AppThemeMode.system));
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
            color: isSelected
                ? selectedColor
                : (currentIsDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: selectedColor.withValues(alpha: 0.3), width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? Colors.white
                    : (currentIsDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (currentIsDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccentColorSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AccentColor.values.map((color) {
              final isSelected = _selectedAccent == color;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedAccent = color);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.color.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedAccent.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSelector(bool isDark, AppLocalizations l10n, FontSizeOption currentFontSize) {
    final sizes = [l10n.small, l10n.medium, l10n.large];
    final fontSizes = [12.0, 14.0, 16.0];
    final fontSizeIndex = currentFontSize.index;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Preview text
          Text(
            'Preview Text',
            style: TextStyle(
              fontSize: fontSizes[fontSizeIndex] + 4,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your text will appear throughout the app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSizes[fontSizeIndex],
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          // Slider
          Row(
            children: [
              Icon(
                Icons.text_decrease_rounded,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
              Expanded(
                child: Slider(
                  value: fontSizeIndex.toDouble(),
                  min: 0,
                  max: 2,
                  divisions: 2,
                  activeColor: const Color(0xFF3B82F6),
                  inactiveColor: isDark
                      ? Colors.white12
                      : Colors.black12,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    final newIndex = v.round();
                    context.read<ThemeBloc>().add(
                      SetFontSizeEvent(FontSizeOption.values[newIndex]),
                    );
                  },
                ),
              ),
              Icon(
                Icons.text_increase_rounded,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ],
          ),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sizes.asMap().entries.map((e) {
              final isSelected = e.key == fontSizeIndex;
              return Text(
                e.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value
                  ? const Color(0xFF3B82F6)
                  : (isDark ? Colors.white38 : Colors.black26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? Colors.white12 : Colors.black12,
      height: 1,
      indent: 60,
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _selectedAccent.color,
            _selectedAccent.color.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _selectedAccent.color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'See how your app will look',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your changes are saved automatically',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
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
