import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/instructor_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/extended_course_model.dart';

class InstructorCourseShellCard extends StatelessWidget {
  final ExtendedCourse course;
  final bool isSelected;
  final bool isSelectionMode;
  final bool canDelete;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(String action) onQuickAction;

  const InstructorCourseShellCard({
    super.key,
    required this.course,
    required this.isSelected,
    required this.isSelectionMode,
    required this.canDelete,
    required this.onTap,
    required this.onLongPress,
    required this.onQuickAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return compact
            ? _buildCompactCard(context, isDark)
            : _buildFullCard(context, isDark);
      },
    );
  }

  Widget _buildFullCard(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: InstructorCoursesTheme.cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: InstructorCoursesTheme.cardBackground(isDark),
            borderRadius: InstructorCoursesTheme.cardRadius,
            border: Border.all(
              color: isSelected
                  ? InstructorCoursesTheme.brandBlue
                  : InstructorCoursesTheme.borderColor(isDark),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(isDark, l10n),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.course.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorCoursesTheme.primaryText(isDark),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorCoursesTheme.secondaryText(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.confirmation_number_outlined,
                          label: course.course.code,
                        ),
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.groups_rounded,
                          label: '${course.course.totalStudents}/${course.course.capacity}',
                        ),
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.calendar_today_rounded,
                          label: course.course.semester,
                        ),
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.stairs_rounded,
                          label: _categoryLabel(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildProgressRow(isDark, l10n),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: onTap,
                            style: TextButton.styleFrom(
                              foregroundColor: InstructorCoursesTheme.brandBlue,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(0xFFE9F2FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    InstructorCoursesTheme.controlRadius,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Open workspace',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isSelectionMode) ...[
                          const SizedBox(width: 10),
                          _buildActionsMenu(isDark, l10n),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: InstructorCoursesTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? InstructorCoursesTheme.brandBlue
                  : InstructorCoursesTheme.borderColor(isDark),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isSelectionMode) ...[
                  _buildSelectionIndicator(),
                  const SizedBox(width: 12),
                ],
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _bannerColors(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _initials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.course.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorCoursesTheme.primaryText(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorCoursesTheme.secondaryText(isDark),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_fillPercent()}% ${l10n.complete.toLowerCase()}',
                        style: TextStyle(
                          color: InstructorCoursesTheme.brandBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSelectionMode) _buildActionsMenu(isDark, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(bool isDark, AppLocalizations l10n) {
    final statusColor = InstructorCoursesTheme.statusColor(course.status);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    _bannerColors().first.withValues(alpha: 0.82),
                    _bannerColors().last.withValues(alpha: 0.96),
                    const Color(0xFF0F172A),
                  ]
                : [
                    _bannerColors().first,
                    _bannerColors().last,
                    InstructorCoursesTheme.heroInk,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -24,
              right: -18,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -36,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _buildBannerChip(
                label: course.course.code,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _buildBannerChip(
                label: _statusLabel(l10n),
                backgroundColor: statusColor.withValues(alpha: 0.18),
                borderColor: statusColor.withValues(alpha: 0.36),
              ),
            ),
            if (isSelectionMode)
              Positioned(top: 16, left: 16, child: _buildSelectionIndicator()),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        course.course.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _initials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isSelected
            ? InstructorCoursesTheme.brandBlue
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isSelected ? InstructorCoursesTheme.brandBlue : Colors.white,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
    );
  }

  Widget _buildBannerChip({
    required String label,
    required Color backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: InstructorCoursesTheme.pillRadius,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required bool isDark,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: InstructorCoursesTheme.chipBackground(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: InstructorCoursesTheme.secondaryText(isDark),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: InstructorCoursesTheme.primaryText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Enrollment fill',
              style: TextStyle(
                color: InstructorCoursesTheme.secondaryText(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_fillPercent()}%',
              style: TextStyle(
                color: InstructorCoursesTheme.primaryText(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: course.completionRate.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(_bannerColors().first),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                '${course.course.totalStudents}/${course.course.capacity} enrolled',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: InstructorCoursesTheme.primaryText(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '${course.engagementScore}% engagement',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: InstructorCoursesTheme.secondaryText(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsMenu(bool isDark, AppLocalizations l10n) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Course actions',
        padding: EdgeInsets.zero,
        color: InstructorCoursesTheme.elevatedCardBackground(isDark),
        surfaceTintColor: Colors.transparent,
        elevation: 14,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: InstructorCoursesTheme.borderColor(isDark)),
        ),
        onSelected: onQuickAction,
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: _buildActionRow(Icons.edit_rounded, l10n.edit),
            ),
            PopupMenuItem<String>(
              value: 'analytics',
              child: _buildActionRow(Icons.analytics_rounded, l10n.analytics),
            ),
            const PopupMenuItem<String>(
              value: 'duplicate',
              child: _ActionLabel(icon: Icons.copy_rounded, label: 'Duplicate'),
            ),
            PopupMenuItem<String>(
              value: 'share',
              child: _buildActionRow(Icons.share_rounded, l10n.share),
            ),
          ];

          if (canDelete) {
            items.add(
              PopupMenuItem<String>(
                value: 'delete',
                child: _buildActionRow(Icons.delete_outline_rounded, l10n.delete),
              ),
            );
          }

          return items;
        },
        icon: Icon(
          Icons.more_horiz_rounded,
          color: InstructorCoursesTheme.primaryText(isDark),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label) {
    return _ActionLabel(icon: icon, label: label);
  }

  String _statusLabel(AppLocalizations l10n) {
    switch (course.status) {
      case 'draft':
        return l10n.draft;
      case 'archived':
        return l10n.archived;
      case 'published':
      default:
        return l10n.publishedAnnouncements;
    }
  }

  String _subtitle() {
    final details = <String>[
      course.course.semester,
      if (course.course.description.trim().isNotEmpty) course.course.description,
    ];
    return details.join(' • ');
  }

  String _categoryLabel() {
    final normalized = course.category.trim();
    if (normalized.isEmpty || normalized == 'UNKNOWN') {
      return 'General';
    }
    return normalized;
  }

  String _initials() {
    final code = course.course.code.trim();
    if (code.length >= 2) {
      return code.substring(0, 2).toUpperCase();
    }
    final title = course.course.name.trim();
    if (title.isEmpty) {
      return 'CO';
    }
    final parts = title.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  int _fillPercent() {
    return (course.completionRate.clamp(0.0, 1.0) * 100).round();
  }

  List<Color> _bannerColors() {
    final base = Color(course.course.colorValue);
    return <Color>[
      base,
      Color.lerp(base, InstructorCoursesTheme.accentPurple, 0.45) ??
          base.withValues(alpha: 0.9),
    ];
  }
}

class _ActionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}
