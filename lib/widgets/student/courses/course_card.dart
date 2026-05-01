import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/course_ui_utils.dart';
import '../../../common/utils/student_course_filters.dart';
import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/enrollment_model.dart';

/// Displays a single course enrollment card with live data from the API.
class CourseCard extends StatelessWidget {
  final CourseEnrollmentModel enrollment;
  final Animation<double>? animation;

  const CourseCard({super.key, required this.enrollment, this.animation});

  String get _title =>
      CourseUiUtils.safeCourseTitle(enrollment.course?.courseName);

  String get _courseCode =>
      CourseUiUtils.safeCourseCode(enrollment.course?.courseCode);

  String get _initials =>
      CourseUiUtils.initialsFromCourseName(enrollment.course?.courseName ?? '');

  String get _normalizedStatus =>
      StudentCourseFilters.normalizeEnrollmentStatus(enrollment.status);

  List<Color> get _gradientColors => CourseUiUtils.gradientForCourseId(
    enrollment.course?.courseId ?? enrollment.courseId,
  );

  String _statusLabel(AppLocalizations l10n) {
    switch (_normalizedStatus) {
      case 'completed':
        return l10n.completed;
      case 'dropped':
        return l10n.studentCourseDropped;
      case 'active':
      default:
        return l10n.active;
    }
  }

  String _instructorLabel(AppLocalizations l10n) {
    final String instructor = StudentCourseFilters.instructorFullName(
      enrollment,
    ).trim();
    if (instructor.isNotEmpty) {
      return instructor;
    }

    final String department = (enrollment.course?.departmentName ?? '').trim();
    if (department.isNotEmpty) {
      return department;
    }

    return l10n.studentCourseUnknownInstructor;
  }

  String _sectionLabel(AppLocalizations l10n) {
    final String section = (enrollment.section?.sectionNumber ?? '').trim();
    if (section.isEmpty) {
      return l10n.studentCourseSectionFallback;
    }
    return l10n.sectionLabel(section);
  }

  String _semesterLabel(AppLocalizations l10n) {
    final String semester = (enrollment.semester?.name ?? '').trim();
    if (semester.isNotEmpty) {
      return semester;
    }
    return l10n.studentCourseNoSemester;
  }

  double? get _progressFraction {
    final double? backendProgress = enrollment.progressPercentage;
    if (backendProgress != null) {
      return (backendProgress / 100).clamp(0.0, 1.0);
    }

    final int viewed = enrollment.materialsViewed ?? 0;
    final int total = enrollment.totalMaterials ?? 0;
    if (total > 0) {
      return (viewed / total).clamp(0.0, 1.0);
    }

    if (_normalizedStatus == 'completed') {
      return 1.0;
    }
    if (_normalizedStatus == 'dropped') {
      return 0.0;
    }
    return null;
  }

  String _primaryActionLabel(AppLocalizations l10n) {
    if (_normalizedStatus == 'completed') {
      return l10n.review;
    }

    final double? progress = _progressFraction;
    if (progress != null && progress > 0) {
      return l10n.continueButton;
    }
    return l10n.openCourse;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        final slideAnimation =
            animation?.drive(
              Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ) ??
            const AlwaysStoppedAnimation(Offset.zero);

        final fadeAnimation =
            animation?.drive(
              Tween<double>(
                begin: 0,
                end: 1,
              ).chain(CurveTween(curve: Curves.easeOut)),
            ) ??
            const AlwaysStoppedAnimation(1);

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openCourse(context),
                borderRadius: StudentCoursesTheme.cardRadius,
                child: Ink(
                  decoration: BoxDecoration(
                    color: StudentCoursesTheme.cardBackground(isDark),
                    borderRadius: StudentCoursesTheme.cardRadius,
                    border: Border.all(
                      color: StudentCoursesTheme.borderColor(isDark),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.18 : 0.08,
                        ),
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
                              _title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: StudentCoursesTheme.primaryText(isDark),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _instructorLabel(l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: StudentCoursesTheme.secondaryText(
                                  isDark,
                                ),
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
                                  label: _courseCode,
                                ),
                                _buildMetaChip(
                                  isDark: isDark,
                                  icon: Icons.groups_rounded,
                                  label: _sectionLabel(l10n),
                                ),
                                _buildMetaChip(
                                  isDark: isDark,
                                  icon: Icons.calendar_today_rounded,
                                  label: _semesterLabel(l10n),
                                ),
                                _buildMetaChip(
                                  isDark: isDark,
                                  icon: Icons.workspace_premium_outlined,
                                  label:
                                      '${enrollment.course?.credits ?? 0} ${l10n.credits}',
                                ),
                              ],
                            ),
                            if (_progressFraction != null) ...[
                              const SizedBox(height: 18),
                              _buildProgressRow(isDark, l10n),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => _openCourse(context),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      StudentCoursesTheme.brandBlue,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : StudentCoursesTheme.brandBluePale,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        StudentCoursesTheme.controlRadius,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _primaryActionLabel(l10n),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(bool isDark, AppLocalizations l10n) {
    final Color statusColor = StudentCoursesTheme.statusColor(
      _normalizedStatus,
    );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    _gradientColors.first.withValues(alpha: 0.82),
                    _gradientColors.last.withValues(alpha: 0.96),
                    const Color(0xFF0F172A),
                  ]
                : [
                    _gradientColors.first,
                    _gradientColors.last,
                    StudentCoursesTheme.heroInk,
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
                label: _courseCode.isNotEmpty
                    ? _courseCode
                    : l10n.myCoursesHeader,
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
                      child: Text(
                        _title,
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
                          _initials,
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
        borderRadius: StudentCoursesTheme.pillRadius,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
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
        color: StudentCoursesTheme.chipBackground(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: StudentCoursesTheme.secondaryText(isDark),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: StudentCoursesTheme.primaryText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(bool isDark, AppLocalizations l10n) {
    final double progress = _progressFraction!.clamp(0.0, 1.0);
    final int progressPercent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.progress,
                style: TextStyle(
                  color: StudentCoursesTheme.secondaryText(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$progressPercent%',
              style: TextStyle(
                color: StudentCoursesTheme.primaryText(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE4E7EC),
            valueColor: AlwaysStoppedAnimation<Color>(
              StudentCoursesTheme.statusColor(_normalizedStatus),
            ),
          ),
        ),
      ],
    );
  }

  void _openCourse(BuildContext context) {
    context.push('/course-details', extra: enrollment);
  }
}
