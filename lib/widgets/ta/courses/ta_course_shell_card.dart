import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/ta_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/extended_course_model.dart';
import '../../../models/instructor/teaching_course_model.dart';

class TACourseShellCard extends StatelessWidget {
  final TeachingCourseModel course;
  final int studentCount;
  final CourseViewType viewType;
  final VoidCallback onTap;
  final VoidCallback onLabsTap;
  final VoidCallback onGradingTap;
  final VoidCallback onDiscussionsTap;

  const TACourseShellCard({
    super.key,
    required this.course,
    required this.studentCount,
    required this.viewType,
    required this.onTap,
    required this.onLabsTap,
    required this.onGradingTap,
    required this.onDiscussionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return viewType == CourseViewType.compact
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
        borderRadius: TACoursesTheme.cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: TACoursesTheme.cardBackground(isDark),
            borderRadius: TACoursesTheme.cardRadius,
            border: Border.all(color: TACoursesTheme.borderColor(isDark)),
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
                      course.course.courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TACoursesTheme.primaryText(isDark),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TACoursesTheme.secondaryText(isDark),
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
                          icon: Icons.groups_rounded,
                          label: '$studentCount/${course.capacity}',
                        ),
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.calendar_today_rounded,
                          label: course.semester.name,
                        ),
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.stairs_rounded,
                          label: _categoryLabel(),
                        ),
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.location_on_outlined,
                          label: _locationLabel(),
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
                              foregroundColor: TACoursesTheme.brandPrimary,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(0xFFF0E8FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: TACoursesTheme.controlRadius,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.openCourse,
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
                        const SizedBox(width: 10),
                        _buildActionsMenu(isDark, l10n),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildActionPill(
                          isDark: isDark,
                          icon: Icons.science_rounded,
                          label: l10n.labs,
                          color: TACoursesTheme.brandPrimary,
                          onTap: onLabsTap,
                        ),
                        _buildActionPill(
                          isDark: isDark,
                          icon: Icons.grading_rounded,
                          label: l10n.taGrading,
                          color: TACoursesTheme.warningAmber,
                          onTap: onGradingTap,
                        ),
                        _buildActionPill(
                          isDark: isDark,
                          icon: Icons.forum_rounded,
                          label: l10n.discussions,
                          color: TACoursesTheme.accentTeal,
                          onTap: onDiscussionsTap,
                        ),
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
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: TACoursesTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: TACoursesTheme.borderColor(isDark)),
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
                        course.course.courseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TACoursesTheme.primaryText(isDark),
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
                          color: TACoursesTheme.secondaryText(isDark),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_fillPercent()}% ${l10n.complete.toLowerCase()}',
                        style: TextStyle(
                          color: TACoursesTheme.brandPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionsMenu(isDark, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(bool isDark, AppLocalizations l10n) {
    final statusColor = TACoursesTheme.statusColor(_normalizedStatus());

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
                    const Color(0xFF130F1F),
                  ]
                : [
                    _bannerColors().first,
                    _bannerColors().last,
                    TACoursesTheme.heroInk,
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
                label: course.course.courseCode,
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
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.course.courseName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBannerChip(
                            label: _sectionLabel(),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ],
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

  Widget _buildBannerChip({
    required String label,
    required Color backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: TACoursesTheme.pillRadius,
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
        color: TACoursesTheme.chipBackground(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: TACoursesTheme.secondaryText(isDark)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: TACoursesTheme.primaryText(isDark),
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
              l10n.taCoursesSectionFill,
              style: TextStyle(
                color: TACoursesTheme.secondaryText(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_fillPercent()}%',
              style: TextStyle(
                color: TACoursesTheme.primaryText(isDark),
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
            value: _fillRatio(),
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
                l10n.taCoursesEnrolledCount(studentCount, course.capacity),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TACoursesTheme.primaryText(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                _locationLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: TACoursesTheme.secondaryText(isDark),
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
            : const Color(0xFFF7F1FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: PopupMenuButton<String>(
        tooltip: l10n.taCoursesCourseActions,
        padding: EdgeInsets.zero,
        color: TACoursesTheme.elevatedCardBackground(isDark),
        surfaceTintColor: Colors.transparent,
        elevation: 14,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: TACoursesTheme.borderColor(isDark)),
        ),
        onSelected: (value) {
          switch (value) {
            case 'open':
              onTap();
              break;
            case 'labs':
              onLabsTap();
              break;
            case 'grading':
              onGradingTap();
              break;
            case 'discussions':
              onDiscussionsTap();
              break;
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'open',
            child: _buildActionRow(Icons.arrow_forward_rounded, l10n.openCourse),
          ),
          PopupMenuItem<String>(
            value: 'labs',
            child: _buildActionRow(Icons.science_rounded, l10n.labs),
          ),
          PopupMenuItem<String>(
            value: 'grading',
            child: _buildActionRow(Icons.grading_rounded, l10n.taGrading),
          ),
          PopupMenuItem<String>(
            value: 'discussions',
            child: _buildActionRow(Icons.forum_rounded, l10n.discussions),
          ),
        ],
        icon: Icon(
          Icons.more_horiz_rounded,
          color: TACoursesTheme.primaryText(isDark),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n) {
    switch (_normalizedStatus()) {
      case 'draft':
        return l10n.draft;
      case 'archived':
        return l10n.archived;
      case 'active':
      default:
        return l10n.activeLabel;
    }
  }

  String _normalizedStatus() {
    switch ((course.course.status ?? '').trim().toLowerCase()) {
      case 'draft':
        return 'draft';
      case 'archived':
      case 'inactive':
        return 'archived';
      case 'published':
      case 'active':
      default:
        return 'active';
    }
  }

  String _subtitle() {
    final details = <String>[
      course.semester.name,
      _sectionLabel(),
      if ((course.course.departmentName ?? '').trim().isNotEmpty)
        course.course.departmentName!.trim(),
    ];
    return details.join(' • ');
  }

  String _sectionLabel() {
    final section = course.section.sectionNumber.trim();
    if (section.isEmpty) {
      return 'Section';
    }
    return 'Section $section';
  }

  String _locationLabel() {
    final location = (course.section.location ?? '').trim();
    return location.isEmpty ? 'TBA' : location;
  }

  String _categoryLabel() {
    final normalized = (course.course.level ?? '').trim();
    if (normalized.isEmpty || normalized.toUpperCase() == 'UNKNOWN') {
      return 'General';
    }
    return normalized;
  }

  String _initials() {
    final code = course.course.courseCode.trim();
    if (code.length >= 2) {
      return code.substring(0, 2).toUpperCase();
    }
    final title = course.course.courseName.trim();
    if (title.isEmpty) {
      return 'TA';
    }
    final parts = title.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  double _fillRatio() {
    if (course.capacity <= 0) {
      return 0;
    }
    return (studentCount / course.capacity).clamp(0.0, 1.0);
  }

  int _fillPercent() {
    return (_fillRatio() * 100).round();
  }

  List<Color> _bannerColors() {
    const palette = <Color>[
      TACoursesTheme.brandPrimary,
      TACoursesTheme.accentBlue,
      TACoursesTheme.accentTeal,
      Color(0xFFEC4899),
    ];
    final base = palette[course.courseId % palette.length];
    return <Color>[
      base,
      Color.lerp(base, TACoursesTheme.brandPrimaryLight, 0.45) ??
          base.withValues(alpha: 0.9),
    ];
  }
}
