import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminBrandingSettingsScreen extends StatefulWidget {
  const AdminBrandingSettingsScreen({super.key});

  @override
  State<AdminBrandingSettingsScreen> createState() =>
      _AdminBrandingSettingsScreenState();
}

class _AdminBrandingSettingsScreenState
    extends State<AdminBrandingSettingsScreen> {
  Color _primaryColor = AdminColors.primary;
  Color _secondaryColor = AdminColors.secondary;
  Color _accentColor = AdminColors.accent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPreviewCard(isDark, l10n, responsive),
                  SizedBox(height: responsive.p24),
                  _buildColorSection(
                    isDark: isDark,
                    l10n: l10n,
                    title: l10n.primaryColor,
                    description: l10n.primaryColorDesc,
                    color: _primaryColor,
                    onColorChanged: (c) => setState(() => _primaryColor = c),
                  ),
                  SizedBox(height: responsive.p16),
                  _buildColorSection(
                    isDark: isDark,
                    l10n: l10n,
                    title: l10n.secondaryColor,
                    description: l10n.secondaryColorDesc,
                    color: _secondaryColor,
                    onColorChanged: (c) => setState(() => _secondaryColor = c),
                  ),
                  SizedBox(height: responsive.p16),
                  _buildColorSection(
                    isDark: isDark,
                    l10n: l10n,
                    title: l10n.accentColor,
                    description: l10n.accentColorDesc,
                    color: _accentColor,
                    onColorChanged: (c) => setState(() => _accentColor = c),
                  ),
                  SizedBox(height: responsive.p24),
                  _buildPresetColors(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildSaveButton(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildResetButton(isDark, l10n),
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
        l10n.brandingColors,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.brandPreview,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'EduVerse',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      l10n.primaryButton,
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      l10n.accentButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection({
    required bool isDark,
    required AppLocalizations l10n,
    required String title,
    required String description,
    required Color color,
    required ValueChanged<Color> onColorChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _showColorPicker(context, color, onColorChanged, isDark),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AdminColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetColors(bool isDark, AppLocalizations l10n) {
    final presets = [
      (
        _Colors(
          const Color(0xFF155DFC),
          const Color(0xFF8B5CF6),
          const Color(0xFF00B8DB),
        ),
        'Default',
      ),
      (
        _Colors(
          const Color(0xFF10B981),
          const Color(0xFF059669),
          const Color(0xFF34D399),
        ),
        'Nature',
      ),
      (
        _Colors(
          const Color(0xFFEC4899),
          const Color(0xFFF472B6),
          const Color(0xFFFBBF24),
        ),
        'Vibrant',
      ),
      (
        _Colors(
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
          const Color(0xFFA855F7),
        ),
        'Purple',
      ),
      (
        _Colors(
          const Color(0xFFEF4444),
          const Color(0xFFF97316),
          const Color(0xFFFBBF24),
        ),
        'Warm',
      ),
      (
        _Colors(
          const Color(0xFF0EA5E9),
          const Color(0xFF06B6D4),
          const Color(0xFF14B8A6),
        ),
        'Ocean',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.presetThemes,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((preset) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _primaryColor = preset.$1.primary;
                    _secondaryColor = preset.$1.secondary;
                    _accentColor = preset.$1.accent;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [preset.$1.primary, preset.$1.secondary],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: preset.$1.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preset.$2,
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
        ],
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
    bool isDark,
  ) {
    final colors = [
      const Color(0xFF155DFC),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFF6366F1),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
      const Color(0xFFA855F7),
      const Color(0xFF0EA5E9),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AdminColors.getDividerColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Color',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colors.map((color) {
                final isSelected = color == currentColor;
                return GestureDetector(
                  onTap: () {
                    onColorChanged(color);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
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
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 28,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.brandingSaved),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AdminColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        l10n.saveBranding,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildResetButton(bool isDark, AppLocalizations l10n) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _primaryColor = AdminColors.primary;
          _secondaryColor = AdminColors.secondary;
          _accentColor = AdminColors.accent;
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminColors.getTextSecondaryColor(isDark),
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AdminColors.getDividerColor(isDark)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        l10n.resetToDefault,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Colors {
  final Color primary;
  final Color secondary;
  final Color accent;

  const _Colors(this.primary, this.secondary, this.accent);
}
