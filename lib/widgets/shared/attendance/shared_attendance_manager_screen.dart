import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/attendance/instructor_attendance_cubit.dart';
import '../../../bloc/attendance/instructor_attendance_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/attendance/attendance_session_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import 'status_toggle_widget.dart';

class SharedAttendanceTheme {
  final String title;
  final String subtitle;
  final IconData heroIcon;
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final LinearGradient headerGradient;
  final LinearGradient darkHeaderGradient;
  final List<List<Color>> sectionGradients;
  final Color Function(bool isDark) background;
  final Color Function(bool isDark) cardColor;
  final Color Function(bool isDark) surfaceColor;
  final Color Function(bool isDark) borderColor;
  final Color Function(bool isDark) textPrimary;
  final Color Function(bool isDark) textSecondary;
  final Color Function(bool isDark) textTertiary;

  const SharedAttendanceTheme({
    required this.title,
    required this.subtitle,
    required this.heroIcon,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.headerGradient,
    required this.darkHeaderGradient,
    required this.sectionGradients,
    required this.background,
    required this.cardColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });
}

class SharedAttendanceManagerScreen extends StatelessWidget {
  const SharedAttendanceManagerScreen({
    super.key,
    required this.isDark,
    required this.theme,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background(isDark),
      body: Stack(
        children: <Widget>[
          _AttendanceBackground(theme: theme, isDark: isDark),
          SafeArea(
            child:
                BlocConsumer<
                  InstructorAttendanceCubit,
                  InstructorAttendanceState
                >(
                  listener: (context, state) {
                    final message = (state.error ?? state.aiError ?? '').trim();
                    if (message.isEmpty) {
                      return;
                    }

                    final backgroundColor =
                        (state.aiError ?? '').trim().isNotEmpty
                        ? theme.warning
                        : theme.error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: backgroundColor,
                      ),
                    );
                  },
                  builder: (context, state) {
                    if (state.isLoading && state.teachingSections.isEmpty) {
                      return _AttendanceLoadingState(
                        isDark: isDark,
                        theme: theme,
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 860;
                        final l10n = AppLocalizations.of(context);

                        return Column(
                          children: <Widget>[
                            _TopBar(
                              isDark: isDark,
                              theme: theme,
                              title: theme.title,
                              onBack: () => context.pop(),
                            ),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  32,
                                ),
                                children: <Widget>[
                                  _HeroCard(
                                    isDark: isDark,
                                    theme: theme,
                                    title: _heroTitle(l10n, state),
                                    subtitle: _heroSubtitle(l10n, state),
                                    badge: _heroBadge(l10n, state),
                                    icon: theme.heroIcon,
                                    stats: _heroStats(l10n, state),
                                    actionLabel: _heroActionLabel(l10n, state),
                                    onActionTap: _heroAction(
                                      context,
                                      context.read<InstructorAttendanceCubit>(),
                                      state,
                                    ),
                                  ),
                                  if (state.view !=
                                      InstructorAttendanceView
                                          .roster) ...<Widget>[
                                    const SizedBox(height: 12),
                                    _ModeToggle(
                                      isDark: isDark,
                                      theme: theme,
                                      state: state,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  if (state.view ==
                                      InstructorAttendanceView.roster)
                                    _RosterView(
                                      isDark: isDark,
                                      theme: theme,
                                      state: state,
                                      wide: wide,
                                    )
                                  else if (state.uiMode ==
                                          AttendanceUiMode.lecture &&
                                      state.view ==
                                          InstructorAttendanceView.section)
                                    _LectureSectionView(
                                      isDark: isDark,
                                      theme: theme,
                                      state: state,
                                      wide: wide,
                                    )
                                  else if (state.uiMode ==
                                      AttendanceUiMode.sessions)
                                    _SessionsModeView(
                                      isDark: isDark,
                                      theme: theme,
                                      state: state,
                                      wide: wide,
                                    )
                                  else
                                    _ClassesView(
                                      isDark: isDark,
                                      theme: theme,
                                      state: state,
                                      wide: wide,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  String _heroTitle(AppLocalizations l10n, InstructorAttendanceState state) {
    if (state.view == InstructorAttendanceView.roster &&
        state.selectedSection != null) {
      final section = state.selectedSection!;
      return '${section.course.courseCode} • ${section.course.name}';
    }

    if (state.selectedSection != null &&
        state.view == InstructorAttendanceView.section) {
      final section = state.selectedSection!;
      return '${section.course.courseCode} • ${section.course.name}';
    }

    return theme.title;
  }

  String _heroSubtitle(AppLocalizations l10n, InstructorAttendanceState state) {
    if (state.view == InstructorAttendanceView.roster &&
        state.activeSession != null) {
      final session = state.activeSession!;
      return [
        l10n.attendanceSessionLabel(session.id),
        session.sessionDate,
        _localizedSessionType(l10n, session.sessionType),
        _localizedSessionStatus(l10n, session.status),
      ].join(' • ');
    }

    if (state.selectedSection != null &&
        state.view == InstructorAttendanceView.section) {
      final section = state.selectedSection!;
      return l10n.attendanceSectionTakeResume(section.section.sectionNumber);
    }

    return theme.subtitle;
  }

  String _heroBadge(AppLocalizations l10n, InstructorAttendanceState state) {
    if (state.view == InstructorAttendanceView.roster &&
        state.activeSession != null) {
      return _localizedSessionStatus(l10n, state.activeSession!.status);
    }

    return state.uiMode == AttendanceUiMode.lecture
        ? l10n.attendanceLectureMode
        : l10n.attendanceSessionsMode;
  }

  List<_HeroStat> _heroStats(
    AppLocalizations l10n,
    InstructorAttendanceState state,
  ) {
    if (state.view == InstructorAttendanceView.roster) {
      return <_HeroStat>[
        _HeroStat(
          value: '${state.rosterRows.length}',
          label: l10n.attendanceRosterLabel,
          color: theme.primary,
          icon: Icons.groups_rounded,
        ),
        _HeroStat(
          value: '${state.rosterRows.where((row) => row.isDirty).length}',
          label: l10n.attendanceChangesLabel,
          color: theme.warning,
          icon: Icons.edit_note_rounded,
        ),
        _HeroStat(
          value: '${state.aiNeedsReviewRows.length}',
          label: l10n.attendanceFlagged,
          color: theme.accent,
          icon: Icons.auto_awesome_rounded,
        ),
      ];
    }

    final totalStudents =
        state.selectedSection?.enrolledCount ??
        state.teachingSections.fold<int>(
          0,
          (sum, section) => sum + section.enrolledCount,
        );

    return <_HeroStat>[
      _HeroStat(
        value: '${state.teachingSections.length}',
        label: l10n.attendanceSectionsLabel,
        color: theme.primary,
        icon: Icons.auto_stories_rounded,
      ),
      _HeroStat(
        value: '${state.openSessions.length}',
        label: l10n.attendanceOpenSessionsLabel,
        color: theme.warning,
        icon: Icons.pending_actions_rounded,
      ),
      _HeroStat(
        value: '$totalStudents',
        label: l10n.students,
        color: theme.success,
        icon: Icons.people_alt_rounded,
      ),
    ];
  }

  String? _heroActionLabel(
    AppLocalizations l10n,
    InstructorAttendanceState state,
  ) {
    if (state.view == InstructorAttendanceView.roster) {
      return state.uiMode == AttendanceUiMode.sessions
          ? l10n.attendanceBackToSessions
          : l10n.attendanceAllSections;
    }

    if (state.view == InstructorAttendanceView.section &&
        state.uiMode == AttendanceUiMode.lecture) {
      return l10n.attendanceAllSections;
    }

    return null;
  }

  VoidCallback? _heroAction(
    BuildContext context,
    InstructorAttendanceCubit cubit,
    InstructorAttendanceState state,
  ) {
    if (state.view == InstructorAttendanceView.roster) {
      return cubit.backToSection;
    }

    if (state.view == InstructorAttendanceView.section &&
        state.uiMode == AttendanceUiMode.lecture) {
      return cubit.backToClasses;
    }

    return null;
  }
}

class _AttendanceBackground extends StatelessWidget {
  const _AttendanceBackground({required this.theme, required this.isDark});

  final SharedAttendanceTheme theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -110,
          right: -45,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  theme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 260,
          left: -70,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  theme.accent.withValues(alpha: isDark ? 0.16 : 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceLoadingState extends StatelessWidget {
  const _AttendanceLoadingState({required this.isDark, required this.theme});

  final bool isDark;
  final SharedAttendanceTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor(isDark),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.borderColor(isDark)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.primary.withValues(alpha: isDark ? 0.22 : 0.08),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(color: theme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context).attendanceManager,
              style: TextStyle(
                color: theme.textPrimary(isDark),
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).trackStudentAttendance,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textSecondary(isDark),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isDark,
    required this.theme,
    required this.title,
    required this.onBack,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: <Widget>[
          _UtilityButton(
            isDark: isDark,
            theme: theme,
            onTap: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: theme.textPrimary(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  MaterialLocalizations.of(context).backButtonTooltip,
                  style: TextStyle(
                    color: theme.textPrimary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: theme.textPrimary(isDark),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({
    required this.isDark,
    required this.theme,
    required this.onTap,
    required this.child,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme
                .cardColor(isDark)
                .withValues(alpha: isDark ? 0.94 : 0.98),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.borderColor(isDark)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.isDark,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.stats,
    required this.actionLabel,
    required this.onActionTap,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final List<_HeroStat> stats;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? theme.darkHeaderGradient : theme.headerGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.primary.withValues(alpha: isDark ? 0.24 : 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _HeaderPill(label: badge),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatsGrid(stats: stats),
          if (actionLabel != null && onActionTap != null) ...<Widget>[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onActionTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.30)),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
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
}

class _HeroStat {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_HeroStat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 420
            ? 3
            : 1;
        final tileWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - ((columns - 1) * 10)) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: tileWidth,
                  child: _HeroStatTile(stat: stat),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  const _HeroStatTile({required this.stat});

  final _HeroStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stat.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  stat.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: AttendanceUiMode.values.map((mode) {
          final selected = state.uiMode == mode;
          final label = mode == AttendanceUiMode.lecture
              ? l10n.attendanceLectureMode
              : l10n.attendanceSessionsMode;
          final subtitle = mode == AttendanceUiMode.lecture
              ? l10n.attendanceModeLectureSubtitle
              : l10n.attendanceModeSessionsSubtitle;
          final icon = mode == AttendanceUiMode.lecture
              ? Icons.how_to_reg_rounded
              : Icons.table_rows_rounded;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () =>
                    context.read<InstructorAttendanceCubit>().setUiMode(mode),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.primary.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? theme.primary.withValues(alpha: 0.36)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        icon,
                        color: selected
                            ? theme.primary
                            : theme.textSecondary(isDark),
                        size: 20,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? theme.primary
                              : theme.textPrimary(isDark),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textSecondary(isDark),
                          fontSize: 10.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ClassesView extends StatelessWidget {
  const _ClassesView({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.wide,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final l10n = AppLocalizations.of(context);

    if (state.teachingSections.isEmpty) {
      return _EmptyPanel(
        isDark: isDark,
        theme: theme,
        icon: Icons.school_outlined,
        title: l10n.attendanceNoSectionsAssigned,
        subtitle: theme.subtitle,
      );
    }

    final crossAxisCount = wide ? 2 : 1;
    final spacing = 12.0;
    final aspectRatio = wide ? 1.9 : 1.42;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.teachingSections.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        final section = state.teachingSections[index];
        final colors =
            theme.sectionGradients[index % theme.sectionGradients.length];
        return _TeachingSectionCard(
          isDark: isDark,
          theme: theme,
          section: section,
          colors: colors,
          onTap: () => cubit.openSection(section, section.sectionId),
        );
      },
    );
  }
}

class _TeachingSectionCard extends StatelessWidget {
  const _TeachingSectionCard({
    required this.isDark,
    required this.theme,
    required this.section,
    required this.colors,
    required this.onTap,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final TeachingCourseModel section;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.borderColor(isDark)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colors.first.withValues(alpha: isDark ? 0.18 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: colors),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.textTertiary(isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        section.course.courseCode,
                        style: TextStyle(
                          color: colors.first,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.course.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _MetaPill(
                            color: theme.accent,
                            label: l10n.sectionLabel(
                              section.section.sectionNumber,
                            ),
                          ),
                          _MetaPill(
                            color: theme.info,
                            label: section.semester.name,
                          ),
                          _MetaPill(
                            color: theme.success,
                            label:
                                '${section.enrolledCount} ${l10n.students.toLowerCase()}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LectureSectionView extends StatelessWidget {
  const _LectureSectionView({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.wide,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final section = state.selectedSection;
    if (section == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        _SectionSummaryCard(isDark: isDark, theme: theme, section: section),
        const SizedBox(height: 12),
        _AdaptivePanelRow(
          wide: wide,
          left: _OpenSessionsCard(isDark: isDark, theme: theme, state: state),
          right: _CreateSessionCard(isDark: isDark, theme: theme, state: state),
        ),
      ],
    );
  }
}

class _SessionsModeView extends StatelessWidget {
  const _SessionsModeView({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.wide,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final selectedSection = state.selectedSection;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<InstructorAttendanceCubit>();

    return Column(
      children: <Widget>[
        _SessionsSectionSelector(isDark: isDark, theme: theme, state: state),
        if (selectedSection == null) ...<Widget>[
          const SizedBox(height: 12),
          _EmptyPanel(
            isDark: isDark,
            theme: theme,
            icon: Icons.table_rows_rounded,
            title: l10n.selectSection,
            subtitle: l10n.attendanceSelectSectionToViewSessions,
          ),
        ] else ...<Widget>[
          const SizedBox(height: 12),
          _SectionSummaryCard(
            isDark: isDark,
            theme: theme,
            section: selectedSection,
          ),
          const SizedBox(height: 12),
          _AdaptivePanelRow(
            wide: wide,
            left: _CreateSessionCard(
              isDark: isDark,
              theme: theme,
              state: state,
            ),
            right: _SessionTableCard(
              isDark: isDark,
              theme: theme,
              state: state,
              onEditSession: (session) =>
                  _showEditSessionSheet(context, cubit, session, isDark, theme),
              onDeleteSession: (session) =>
                  _confirmDeleteSession(context, cubit, session, isDark, theme),
            ),
          ),
        ],
      ],
    );
  }
}

class _AdaptivePanelRow extends StatelessWidget {
  const _AdaptivePanelRow({
    required this.wide,
    required this.left,
    required this.right,
  });

  final bool wide;
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        children: <Widget>[left, const SizedBox(height: 12), right],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _SessionsSectionSelector extends StatelessWidget {
  const _SessionsSectionSelector({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.teachingSections.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.tune_rounded,
            title: l10n.selectSection,
            subtitle: l10n.attendanceModeSessionsSubtitle,
            color: theme.accent,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue:
                state.selectedSectionId ??
                state.teachingSections.first.sectionId,
            decoration: _inputDecoration(
              isDark: isDark,
              theme: theme,
              label: l10n.selectSection,
            ),
            dropdownColor: theme.cardColor(isDark),
            items: state.teachingSections.map((section) {
              return DropdownMenuItem<int>(
                value: section.sectionId,
                child: Text(
                  '${section.course.courseCode} • ${section.course.name} • ${l10n.sectionLabel(section.section.sectionNumber)}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context
                    .read<InstructorAttendanceCubit>()
                    .selectSectionForSessions(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionSummaryCard extends StatelessWidget {
  const _SectionSummaryCard({
    required this.isDark,
    required this.theme,
    required this.section,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final TeachingCourseModel section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[theme.primary, theme.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.class_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      section.course.courseCode,
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      section.course.name,
                      style: TextStyle(
                        color: theme.textPrimary(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaPill(
                color: theme.accent,
                label: l10n.sectionLabel(section.section.sectionNumber),
              ),
              _MetaPill(color: theme.info, label: section.semester.name),
              _MetaPill(
                color: theme.success,
                label:
                    '${section.enrolledCount} ${l10n.students.toLowerCase()}',
              ),
              if (section.capacity > 0)
                _MetaPill(
                  color: theme.warning,
                  label: '${section.capacity} cap',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OpenSessionsCard extends StatelessWidget {
  const _OpenSessionsCard({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.pending_actions_rounded,
            title: l10n.attendanceOpenSessionsTitle,
            subtitle: l10n.attendanceOpenSessionsSubtitle,
            color: theme.warning,
          ),
          const SizedBox(height: 12),
          if (state.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: CircularProgressIndicator(color: theme.primary),
              ),
            )
          else if (state.openSessions.isEmpty)
            Text(
              l10n.attendanceNoOpenSessions,
              style: TextStyle(color: theme.textSecondary(isDark)),
            )
          else
            ...state.openSessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SessionTile(
                  isDark: isDark,
                  theme: theme,
                  session: session,
                  onOpen: () => context
                      .read<InstructorAttendanceCubit>()
                      .openRosterFromSession(session),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateSessionCard extends StatelessWidget {
  const _CreateSessionCard({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.add_circle_outline_rounded,
            title: l10n.attendanceStartSessionTitle,
            subtitle: l10n.attendanceStartSessionSubtitle,
            color: theme.success,
          ),
          const SizedBox(height: 12),
          _DateTile(
            isDark: isDark,
            theme: theme,
            title: l10n.date,
            value: state.newSessionDate,
            icon: Icons.calendar_today_rounded,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 1),
              );
              if (picked != null) {
                final month = picked.month.toString().padLeft(2, '0');
                final day = picked.day.toString().padLeft(2, '0');
                cubit.updateNewSessionDate('${picked.year}-$month-$day');
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: state.newSessionType,
            decoration: _inputDecoration(
              isDark: isDark,
              theme: theme,
              label: l10n.type,
            ),
            dropdownColor: theme.cardColor(isDark),
            items: _sessionTypeItems(l10n),
            onChanged: (value) {
              if (value != null) {
                cubit.updateNewSessionType(value);
              }
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isLoading ? null : cubit.createSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.attendanceCreateSessionAndOpenRoster),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.isDark,
    required this.theme,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.borderColor(isDark)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.textSecondary(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: theme.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_calendar_rounded,
                color: theme.textTertiary(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTableCard extends StatelessWidget {
  const _SessionTableCard({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.onEditSession,
    required this.onDeleteSession,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final ValueChanged<AttendanceSessionModel> onEditSession;
  final ValueChanged<AttendanceSessionModel> onDeleteSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.history_rounded,
            title: l10n.attendanceRecordsTitle,
            subtitle: l10n.attendanceRecordsSubtitle,
            color: theme.info,
          ),
          const SizedBox(height: 12),
          if (state.sessions.isEmpty)
            Text(
              l10n.attendanceNoSessionsYet,
              style: TextStyle(color: theme.textSecondary(isDark)),
            )
          else
            ...state.sessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SessionSummaryCard(
                  isDark: isDark,
                  theme: theme,
                  session: session,
                  onOpen: () => context
                      .read<InstructorAttendanceCubit>()
                      .openRosterFromSession(session),
                  onEdit: () => onEditSession(session),
                  onDelete: () => onDeleteSession(session),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.isDark,
    required this.theme,
    required this.session,
    required this.onOpen,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final AttendanceSessionModel session;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(theme, session.status);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.borderColor(isDark)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _localizedSessionStatus(l10n, session.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.sessionDate,
                      style: TextStyle(
                        color: theme.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_localizedSessionType(l10n, session.sessionType)} • ${l10n.attendanceSessionLabel(session.id)}',
                      style: TextStyle(
                        color: theme.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onOpen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                child: Text(l10n.attendanceOpen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({
    required this.isDark,
    required this.theme,
    required this.session,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final AttendanceSessionModel session;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trackedTotal =
        session.presentCount +
        session.absentCount +
        session.lateCount +
        session.excusedCount;
    final attendancePercent = trackedTotal == 0
        ? 0.0
        : ((session.presentCount + session.lateCount) / trackedTotal) * 100;
    final statusColor = _statusColor(theme, session.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.sessionDate,
                      style: TextStyle(
                        color: theme.textPrimary(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _MetaPill(
                          color: statusColor,
                          label: _localizedSessionStatus(l10n, session.status),
                        ),
                        _MetaPill(
                          color: theme.accent,
                          label: _localizedSessionType(
                            l10n,
                            session.sessionType,
                          ),
                        ),
                        _MetaPill(
                          color: theme.info,
                          label: l10n.attendanceSessionLabel(session.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _IconAction(
                    icon: Icons.open_in_new_rounded,
                    color: theme.primary,
                    tooltip: l10n.attendanceOpenRosterAction,
                    onTap: onOpen,
                  ),
                  _IconAction(
                    icon: Icons.edit_outlined,
                    color: theme.accent,
                    tooltip: l10n.attendanceEditSessionTitle,
                    onTap: session.isClosed ? null : onEdit,
                  ),
                  _IconAction(
                    icon: Icons.delete_outline_rounded,
                    color: theme.error,
                    tooltip: l10n.delete,
                    onTap: session.isClosed ? null : onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InfoChip(
                color: theme.success,
                label: '${l10n.present}: ${session.presentCount}',
              ),
              _InfoChip(
                color: theme.error,
                label: '${l10n.absent}: ${session.absentCount}',
              ),
              _InfoChip(
                color: theme.warning,
                label: '${l10n.late}: ${session.lateCount}',
              ),
              _InfoChip(
                color: theme.info,
                label: '${l10n.excused}: ${session.excusedCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: attendancePercent / 100,
                    minHeight: 8,
                    color: theme.primary,
                    backgroundColor: theme.borderColor(isDark),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${attendancePercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, color: color),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _RosterView extends StatelessWidget {
  const _RosterView({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.wide,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final l10n = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        _ActionStrip(
          isDark: isDark,
          theme: theme,
          buttons: <Widget>[
            _ActionButton(
              label: l10n.attendanceEveryonePresent,
              color: theme.primary,
              onTap: state.isRosterReadOnly
                  ? null
                  : () => _confirmBulkStatus(
                      context,
                      cubit: cubit,
                      status: 'present',
                      isDark: isDark,
                      theme: theme,
                    ),
            ),
            _ActionButton(
              label: l10n.attendanceEveryoneAbsent,
              color: theme.textTertiary(isDark),
              onTap: state.isRosterReadOnly
                  ? null
                  : () => _confirmBulkStatus(
                      context,
                      cubit: cubit,
                      status: 'absent',
                      isDark: isDark,
                      theme: theme,
                    ),
            ),
            _ActionButton(
              label: state.isRosterDirty
                  ? '${l10n.saveAttendance}*'
                  : l10n.saveAttendance,
              color: theme.success,
              onTap: state.isRosterReadOnly ? null : cubit.saveBatch,
            ),
            _ActionButton(
              label: l10n.attendanceCloseAndLock,
              color: theme.error,
              onTap: state.isRosterReadOnly
                  ? null
                  : () => _confirmCloseSession(context, cubit, isDark, theme),
            ),
          ],
        ),
        if (state.isRosterDirty) ...<Widget>[
          const SizedBox(height: 12),
          _BannerCard(
            color: theme.warning,
            background: theme.warning.withValues(alpha: 0.12),
            message: l10n.attendanceUnsavedChangesBanner,
          ),
        ],
        if (state.isRosterReadOnly) ...<Widget>[
          const SizedBox(height: 12),
          _BannerCard(
            color: theme.warning,
            background: theme.warning.withValues(alpha: 0.12),
            message: l10n.attendanceReadOnlyBanner,
          ),
        ],
        const SizedBox(height: 12),
        _AiReviewPanel(isDark: isDark, theme: theme, state: state, wide: wide),
        const SizedBox(height: 12),
        if (state.displayedRosterRows.isEmpty)
          _EmptyPanel(
            isDark: isDark,
            theme: theme,
            icon: Icons.group_off_rounded,
            title: l10n.attendanceNoEnrolledStudents,
            subtitle: l10n.trackStudentAttendance,
          )
        else
          ...state.displayedRosterRows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RosterRowCard(
                isDark: isDark,
                theme: theme,
                row: row,
                aiRow: state.aiReviewRows
                    .where((item) => item.userId == row.userId)
                    .firstOrNull,
                isHighlighted: state.aiNeedsReviewRows.any(
                  (item) => item.userId == row.userId,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.isDark,
    required this.theme,
    required this.buttons,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Wrap(spacing: 8, runSpacing: 8, children: buttons),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        disabledBackgroundColor: color.withValues(alpha: 0.35),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12.5)),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.color,
    required this.background,
    required this.message,
  });

  final Color color;
  final Color background;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AiReviewPanel extends StatelessWidget {
  const _AiReviewPanel({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.wide,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            isDark: isDark,
            theme: theme,
            icon: Icons.auto_awesome_rounded,
            title: l10n.attendanceAiPhotoTitle,
            subtitle: l10n.attendanceAiPhotoSubtitle,
            color: theme.accent,
            trailing: Text(
              l10n.attendanceUsesSavedFaceReferences,
              style: TextStyle(
                color: theme.textSecondary(isDark),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _AiPhotoPicker(
                    isDark: isDark,
                    theme: theme,
                    state: state,
                    onPick: () => _pickAiPhoto(cubit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AiActionSummary(
                    isDark: isDark,
                    theme: theme,
                    state: state,
                  ),
                ),
              ],
            )
          else ...<Widget>[
            _AiPhotoPicker(
              isDark: isDark,
              theme: theme,
              state: state,
              onPick: () => _pickAiPhoto(cubit),
            ),
            const SizedBox(height: 12),
            _AiActionSummary(isDark: isDark, theme: theme, state: state),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAiPhoto(InstructorAttendanceCubit cubit) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null && path.isNotEmpty) {
      cubit.setAiFile(File(path));
    }
  }
}

class _AiPhotoPicker extends StatelessWidget {
  const _AiPhotoPicker({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.onPick,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (state.isRosterReadOnly || state.isAiLoading) ? null : onPick,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 190,
          decoration: BoxDecoration(
            color: theme.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.borderColor(isDark)),
          ),
          child: state.aiPhoto == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.attendancePickPhoto,
                        style: TextStyle(
                          color: theme.textPrimary(isDark),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(state.aiPhoto!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

class _AiActionSummary extends StatelessWidget {
  const _AiActionSummary({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed:
                  (state.isRosterReadOnly ||
                      state.isAiLoading ||
                      state.aiPhoto == null)
                  ? null
                  : cubit.runAiAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: state.isAiLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.psychology_rounded),
              label: Text(
                state.isAiLoading
                    ? l10n.attendanceRunning
                    : l10n.attendanceRunAi,
              ),
            ),
            OutlinedButton.icon(
              onPressed: (state.isRosterReadOnly || state.aiReviewRows.isEmpty)
                  ? null
                  : cubit.applyAiResultsToRoster,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.accent,
                side: BorderSide(color: theme.accent.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.playlist_add_check_rounded),
              label: Text(l10n.attendanceApplyAiSuggestions),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.aiResult == null)
          Text(
            l10n.attendanceAiNotRunYet,
            style: TextStyle(
              color: theme.textSecondary(isDark),
              fontSize: 12.5,
              height: 1.35,
            ),
          )
        else
          Row(
            children: <Widget>[
              _MetricCard(
                label: l10n.attendanceOnRoster,
                value: '${state.aiReviewRows.length}',
                color: theme.primary,
              ),
              const SizedBox(width: 8),
              _MetricCard(
                label: l10n.attendanceFlagged,
                value: '${state.aiNeedsReviewRows.length}',
                color: theme.warning,
              ),
              const SizedBox(width: 8),
              _MetricCard(
                label: l10n.attendanceUnknown,
                value: '${state.aiUnknownCount}',
                color: theme.info,
              ),
            ],
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RosterRowCard extends StatelessWidget {
  const _RosterRowCard({
    required this.isDark,
    required this.theme,
    required this.row,
    required this.aiRow,
    required this.isHighlighted,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final RosterRow row;
  final AiReviewRow? aiRow;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.warning.withValues(alpha: isDark ? 0.12 : 0.08)
            : theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted
              ? theme.warning.withValues(alpha: 0.35)
              : theme.borderColor(isDark),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[theme.primary, theme.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _initials(row.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          row.name,
                          style: TextStyle(
                            color: theme.textPrimary(isDark),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        if (isHighlighted)
                          _InfoChip(
                            color: theme.warning,
                            label: l10n.attendanceReview,
                          ),
                        if (row.isAiMarked)
                          _InfoChip(
                            color: theme.info,
                            label: aiRow?.confidencePercent != null
                                ? l10n.attendanceAiBadge(
                                    aiRow!.confidencePercent!.toStringAsFixed(
                                      0,
                                    ),
                                  )
                                : 'AI',
                          ),
                      ],
                    ),
                    if (row.email.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        row.email,
                        style: TextStyle(
                          color: theme.textSecondary(isDark),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatusToggleWidget(
            currentStatus: row.status,
            isDark: isDark,
            isDisabled: context
                .read<InstructorAttendanceCubit>()
                .state
                .isRosterReadOnly,
            onChanged: (status) => cubit.applyStatus(row.userId, status),
            activeColor: theme.primary,
            surfaceColor: theme.surfaceColor(isDark),
            borderColor: theme.borderColor(isDark),
            mutedColor: theme.textSecondary(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            aiRow == null
                ? l10n.attendanceAiNotRunYet
                : aiRow!.confidencePercent != null
                ? l10n.attendanceAiSuggestedWithConfidence(
                    _localizedStatusLabel(l10n, aiRow!.suggestedStatus),
                    aiRow!.confidencePercent!.toStringAsFixed(0),
                  )
                : l10n.attendanceAiSuggestedWithoutConfidence(
                    _localizedStatusLabel(l10n, aiRow!.suggestedStatus),
                  ),
            style: TextStyle(
              color: theme.textSecondary(isDark),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.isDark,
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.trailing,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontWeight: FontWeight.w800,
                  fontSize: 16.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: theme.textSecondary(isDark),
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.isDark,
    required this.theme,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor(isDark)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.isDark,
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool isDark;
  final SharedAttendanceTheme theme;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      isDark: isDark,
      theme: theme,
      child: Column(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: theme.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textPrimary(isDark),
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textSecondary(isDark),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showEditSessionSheet(
  BuildContext context,
  InstructorAttendanceCubit cubit,
  AttendanceSessionModel session,
  bool isDark,
  SharedAttendanceTheme theme,
) async {
  final l10n = AppLocalizations.of(context);
  final typeNotifier = ValueNotifier<String>(session.sessionType ?? 'lecture');
  var selectedDate = session.sessionDate;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor(isDark),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.borderColor(isDark)),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.attendanceEditSessionTitle,
                    style: TextStyle(
                      color: theme.textPrimary(isDark),
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.attendanceEditSessionSubtitle,
                    style: TextStyle(
                      color: theme.textSecondary(isDark),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DateTile(
                    isDark: isDark,
                    theme: theme,
                    title: l10n.date,
                    value: selectedDate,
                    icon: Icons.event_rounded,
                    onTap: () async {
                      final now = DateTime.now();
                      final parsedDate =
                          DateTime.tryParse(session.sessionDate) ?? now;
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: parsedDate,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 1),
                      );
                      if (picked != null) {
                        final month = picked.month.toString().padLeft(2, '0');
                        final day = picked.day.toString().padLeft(2, '0');
                        setModalState(() {
                          selectedDate = '${picked.year}-$month-$day';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: typeNotifier,
                    builder: (context, value, _) {
                      return DropdownButtonFormField<String>(
                        initialValue: value,
                        decoration: _inputDecoration(
                          isDark: isDark,
                          theme: theme,
                          label: l10n.type,
                        ),
                        dropdownColor: theme.cardColor(isDark),
                        items: _sessionTypeItems(l10n),
                        onChanged: (next) {
                          if (next != null) {
                            typeNotifier.value = next;
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await cubit.updateSession(
                              sessionId: session.id,
                              sessionDate: selectedDate,
                              sessionType: typeNotifier.value,
                            );
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );

  typeNotifier.dispose();
}

Future<void> _confirmDeleteSession(
  BuildContext context,
  InstructorAttendanceCubit cubit,
  AttendanceSessionModel session,
  bool isDark,
  SharedAttendanceTheme theme,
) async {
  final l10n = AppLocalizations.of(context);
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.attendanceDeleteSessionTitle),
        content: Text(
          l10n.attendanceDeleteSessionMessage(
            session.id.toString(),
            session.sessionDate,
          ),
        ),
        backgroundColor: theme.cardColor(isDark),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    await cubit.deleteSession(session.id);
  }
}

Future<void> _confirmBulkStatus(
  BuildContext context, {
  required InstructorAttendanceCubit cubit,
  required String status,
  required bool isDark,
  required SharedAttendanceTheme theme,
}) async {
  final l10n = AppLocalizations.of(context);
  final localizedStatus = _localizedStatusLabel(l10n, status).toLowerCase();
  final shouldApply = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.attendanceMarkEveryoneTitle(localizedStatus)),
        content: Text(l10n.attendanceMarkEveryoneMessage(localizedStatus)),
        backgroundColor: theme.cardColor(isDark),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.attendanceApply),
          ),
        ],
      );
    },
  );

  if (shouldApply == true) {
    cubit.setAllStatus(status);
  }
}

Future<void> _confirmCloseSession(
  BuildContext context,
  InstructorAttendanceCubit cubit,
  bool isDark,
  SharedAttendanceTheme theme,
) async {
  final l10n = AppLocalizations.of(context);
  final shouldClose = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.attendanceCloseSessionTitle),
        content: Text(l10n.attendanceCloseSessionMessage),
        backgroundColor: theme.cardColor(isDark),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.attendanceCloseAndLock),
          ),
        ],
      );
    },
  );

  if (shouldClose == true) {
    await cubit.closeSession();
  }
}

InputDecoration _inputDecoration({
  required bool isDark,
  required SharedAttendanceTheme theme,
  required String label,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: theme.textSecondary(isDark)),
    filled: true,
    fillColor: theme.surfaceColor(isDark),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: theme.borderColor(isDark)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: theme.borderColor(isDark)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: theme.primary, width: 1.4),
    ),
  );
}

List<DropdownMenuItem<String>> _sessionTypeItems(AppLocalizations l10n) {
  return <DropdownMenuItem<String>>[
    DropdownMenuItem(value: 'lecture', child: Text(l10n.lectureType)),
    DropdownMenuItem(value: 'lab', child: Text(l10n.labType)),
    DropdownMenuItem(
      value: 'tutorial',
      child: Text(l10n.attendanceTutorialType),
    ),
    DropdownMenuItem(value: 'exam', child: Text(l10n.examType)),
  ];
}

String _localizedSessionType(AppLocalizations l10n, String? rawType) {
  switch ((rawType ?? 'lecture').toLowerCase()) {
    case 'lab':
      return l10n.labType;
    case 'tutorial':
      return l10n.attendanceTutorialType;
    case 'exam':
      return l10n.examType;
    case 'lecture':
    default:
      return l10n.lectureType;
  }
}

String _localizedSessionStatus(AppLocalizations l10n, String rawStatus) {
  switch (rawStatus.toLowerCase()) {
    case 'in_progress':
      return l10n.attendanceStatusInProgress;
    case 'completed':
      return l10n.attendanceStatusCompleted;
    case 'cancelled':
      return l10n.attendanceStatusCancelled;
    case 'scheduled':
    default:
      return l10n.attendanceStatusScheduled;
  }
}

String _localizedStatusLabel(AppLocalizations l10n, String rawStatus) {
  switch (rawStatus.toLowerCase()) {
    case 'absent':
      return l10n.absent;
    case 'late':
      return l10n.late;
    case 'excused':
      return l10n.excused;
    case 'present':
    default:
      return l10n.present;
  }
}

Color _statusColor(SharedAttendanceTheme theme, String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
      return theme.warning;
    case 'completed':
      return theme.success;
    case 'cancelled':
      return theme.error;
    case 'scheduled':
    default:
      return theme.primary;
  }
}

String _initials(String value) {
  final parts = value
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'S';
  }
  final first = parts.first.substring(0, 1);
  final second = parts.length > 1 ? parts.last.substring(0, 1) : '';
  return '$first$second'.toUpperCase();
}
