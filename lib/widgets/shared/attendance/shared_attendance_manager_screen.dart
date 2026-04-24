import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/attendance/instructor_attendance_cubit.dart';
import '../../../bloc/attendance/instructor_attendance_state.dart';
import '../../../models/attendance/attendance_session_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import 'status_toggle_widget.dart';

class SharedAttendanceTheme {
  final String title;
  final Color primary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final List<List<Color>> sectionGradients;
  final Color Function(bool isDark) background;
  final Color Function(bool isDark) cardColor;
  final Color Function(bool isDark) borderColor;
  final Color Function(bool isDark) textPrimary;
  final Color Function(bool isDark) textSecondary;

  const SharedAttendanceTheme({
    required this.title,
    required this.primary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.sectionGradients,
    required this.background,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });
}

class SharedAttendanceManagerScreen extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;

  const SharedAttendanceManagerScreen({
    super.key,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background(isDark),
      body: SafeArea(
        child:
            BlocConsumer<InstructorAttendanceCubit, InstructorAttendanceState>(
              listener: (context, state) {
                if (state.error != null && state.error!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: theme.error,
                    ),
                  );
                } else if (state.aiError != null && state.aiError!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.aiError!),
                      backgroundColor: theme.warning,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading && state.teachingSections.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.view == InstructorAttendanceView.roster) {
                  return _RosterView(
                    isDark: isDark,
                    theme: theme,
                    state: state,
                  );
                }

                return Column(
                  children: <Widget>[
                    _PageHeader(
                      isDark: isDark,
                      theme: theme,
                      title: theme.title,
                    ),
                    _ModeToggle(isDark: isDark, theme: theme, state: state),
                    Expanded(
                      child: state.uiMode == AttendanceUiMode.lecture
                          ? (state.view == InstructorAttendanceView.section
                                ? _LectureSectionView(
                                    isDark: isDark,
                                    theme: theme,
                                    state: state,
                                  )
                                : _ClassesView(
                                    isDark: isDark,
                                    theme: theme,
                                    state: state,
                                  ))
                          : _SessionsModeView(
                              isDark: isDark,
                              theme: theme,
                              state: state,
                            ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final String title;

  const _PageHeader({
    required this.isDark,
    required this.theme,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        border: Border(bottom: BorderSide(color: theme.borderColor(isDark))),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.textPrimary(isDark),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.textPrimary(isDark),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _ModeToggle({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.borderColor(isDark)),
        ),
        child: Row(
          children: AttendanceUiMode.values.map((mode) {
            final selected = state.uiMode == mode;
            final label = mode == AttendanceUiMode.lecture
                ? 'Lecture Attendance'
                : 'Session Table';
            return Expanded(
              child: InkWell(
                onTap: () =>
                    context.read<InstructorAttendanceCubit>().setUiMode(mode),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? theme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : theme.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ClassesView extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _ClassesView({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    if (state.teachingSections.isEmpty) {
      return Center(
        child: Text(
          'No sections assigned.',
          style: TextStyle(color: theme.textSecondary(isDark)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.teachingSections.length,
      itemBuilder: (context, index) {
        final section = state.teachingSections[index];
        final colors =
            theme.sectionGradients[index % theme.sectionGradients.length];
        return GestureDetector(
          onTap: () => cubit.openSection(section, section.sectionId),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.borderColor(isDark)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              section.course.courseCode,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.first,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              section.course.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Section ${section.section.sectionNumber} • ${section.semester.name}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.textSecondary(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LectureSectionView extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _LectureSectionView({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final section = state.selectedSection;
    if (section == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _SectionIntro(
          isDark: isDark,
          theme: theme,
          title: '${section.course.courseCode} • ${section.course.name}',
          subtitle:
              'Section ${section.section.sectionNumber} • Take or resume attendance',
          backLabel: 'All sections',
          onBack: cubit.backToClasses,
        ),
        const SizedBox(height: 16),
        _OpenSessionsCard(isDark: isDark, theme: theme, state: state),
        const SizedBox(height: 16),
        _CreateSessionCard(isDark: isDark, theme: theme, state: state),
      ],
    );
  }
}

class _SessionsModeView extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _SessionsModeView({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final selectedSection = state.selectedSection;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (state.teachingSections.isNotEmpty)
          _SessionsSectionSelector(isDark: isDark, theme: theme, state: state),
        if (selectedSection != null) ...<Widget>[
          const SizedBox(height: 12),
          _SectionSummaryCard(
            isDark: isDark,
            theme: theme,
            section: selectedSection,
          ),
          const SizedBox(height: 12),
          _CreateSessionCard(isDark: isDark, theme: theme, state: state),
          const SizedBox(height: 12),
          _SessionTableCard(
            isDark: isDark,
            theme: theme,
            state: state,
            onEditSession: (session) =>
                _showEditSessionSheet(context, cubit, session),
            onDeleteSession: (session) =>
                _confirmDeleteSession(context, cubit, session),
          ),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Select a section to view attendance sessions.',
                style: TextStyle(color: theme.textSecondary(isDark)),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showEditSessionSheet(
    BuildContext context,
    InstructorAttendanceCubit cubit,
    AttendanceSessionModel session,
  ) async {
    final typeNotifier = ValueNotifier<String>(
      session.sessionType ?? 'lecture',
    );
    var selectedDate = session.sessionDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Edit Session',
                    style: TextStyle(
                      color: theme.textPrimary(isDark),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
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
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(selectedDate),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: typeNotifier,
                    builder: (context, value, _) {
                      return DropdownButtonFormField<String>(
                        initialValue: value,
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                            value: 'lecture',
                            child: Text('Lecture'),
                          ),
                          DropdownMenuItem(value: 'lab', child: Text('Lab')),
                          DropdownMenuItem(
                            value: 'tutorial',
                            child: Text('Tutorial'),
                          ),
                          DropdownMenuItem(value: 'exam', child: Text('Exam')),
                        ],
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
                          child: const Text('Cancel'),
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
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
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
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: Text(
            'Delete session ${session.id} on ${session.sessionDate}? This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await cubit.deleteSession(session.id);
    }
  }
}

class _SessionsSectionSelector extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _SessionsSectionSelector({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: DropdownButtonFormField<int>(
        initialValue:
            state.selectedSectionId ?? state.teachingSections.first.sectionId,
        decoration: const InputDecoration(
          labelText: 'Select Section',
          border: OutlineInputBorder(),
        ),
        items: state.teachingSections.map((section) {
          return DropdownMenuItem<int>(
            value: section.sectionId,
            child: Text(
              '${section.course.courseCode} • ${section.course.name} • Sec ${section.section.sectionNumber}',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            context.read<InstructorAttendanceCubit>().selectSectionForSessions(
              value,
            );
          }
        },
      ),
    );
  }
}

class _SectionSummaryCard extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final TeachingCourseModel section;

  const _SectionSummaryCard({
    required this.isDark,
    required this.theme,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.course.name,
            style: TextStyle(
              color: theme.textPrimary(isDark),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaPill(color: theme.primary, label: section.course.courseCode),
              _MetaPill(
                color: theme.accent,
                label: 'Section ${section.section.sectionNumber}',
              ),
              _MetaPill(color: theme.info, label: section.semester.name),
              _MetaPill(
                color: theme.success,
                label: '${section.enrolledCount} students',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final Color color;
  final String label;

  const _MetaPill({required this.color, required this.label});

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
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _OpenSessionsCard({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.pending_actions_rounded,
                color: theme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Open Sessions',
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sessions not closed yet. Resume to keep editing.',
            style: TextStyle(color: theme.textSecondary(isDark), fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.openSessions.isEmpty)
            Text(
              'No open sessions. Start a new session below.',
              style: TextStyle(color: theme.textSecondary(isDark)),
            )
          else
            ...state.openSessions.map(
              (session) => _SessionTile(
                isDark: isDark,
                theme: theme,
                session: session,
                onOpen: () => context
                    .read<InstructorAttendanceCubit>()
                    .openRosterFromSession(session),
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateSessionCard extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _CreateSessionCard({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.add_circle_outline_rounded,
                color: theme.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Start New Attendance Session',
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () async {
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
            icon: const Icon(Icons.calendar_today_rounded, size: 16),
            label: Text(state.newSessionDate),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: state.newSessionType,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'lecture', child: Text('Lecture')),
              DropdownMenuItem(value: 'lab', child: Text('Lab')),
              DropdownMenuItem(value: 'tutorial', child: Text('Tutorial')),
              DropdownMenuItem(value: 'exam', child: Text('Exam')),
            ],
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
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Create Session & Open Roster'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTableCard extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;
  final ValueChanged<AttendanceSessionModel> onEditSession;
  final ValueChanged<AttendanceSessionModel> onDeleteSession;

  const _SessionTableCard({
    required this.isDark,
    required this.theme,
    required this.state,
    required this.onEditSession,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Attendance Records',
              style: TextStyle(
                color: theme.textPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (state.sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'No attendance sessions yet.',
                style: TextStyle(color: theme.textSecondary(isDark)),
              ),
            )
          else
            ...state.sessions.map(
              (session) => _SessionTableRow(
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
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final AttendanceSessionModel session;
  final VoidCallback onOpen;

  const _SessionTile({
    required this.isDark,
    required this.theme,
    required this.session,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = session.status == 'in_progress'
        ? theme.warning
        : theme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              session.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${session.sessionType ?? 'lecture'} • Session ${session.id}',
                  style: TextStyle(
                    color: theme.textSecondary(isDark),
                    fontSize: 11,
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
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _SessionTableRow extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final AttendanceSessionModel session;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SessionTableRow({
    required this.isDark,
    required this.theme,
    required this.session,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        session.presentCount +
        session.absentCount +
        session.lateCount +
        session.excusedCount;
    final attendancePercent = total == 0
        ? 0
        : ((session.presentCount + session.lateCount) / total) * 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.borderColor(isDark).withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
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
                const SizedBox(height: 2),
                Text(
                  '${session.sessionType ?? 'lecture'} • Present ${session.presentCount} • Absent ${session.absentCount} • ${attendancePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: theme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Open roster',
            onPressed: onOpen,
            icon: Icon(Icons.open_in_new_rounded, color: theme.primary),
          ),
          IconButton(
            tooltip: 'Edit session',
            onPressed: session.isClosed ? null : onEdit,
            icon: Icon(Icons.edit_outlined, color: theme.accent),
          ),
          IconButton(
            tooltip: 'Delete session',
            onPressed: session.isClosed ? null : onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: theme.error),
          ),
        ],
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final String title;
  final String subtitle;
  final String backLabel;
  final VoidCallback onBack;

  const _SectionIntro({
    required this.isDark,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.backLabel,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: theme.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(onPressed: onBack, child: Text(backLabel)),
      ],
    );
  }
}

class _RosterView extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _RosterView({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final section = state.selectedSection;
    final title = section != null
        ? '${section.course.courseCode} • roster'
        : 'Roster';
    final subtitle = [
      if (state.activeSession != null) 'Session ${state.activeSession!.id}',
      state.activeSession?.sessionDate ?? '',
      state.activeSession?.sessionType ?? '',
      state.activeSession?.status ?? '',
    ].where((part) => part.isNotEmpty).join(' • ');

    return Column(
      children: <Widget>[
        _PageHeader(isDark: isDark, theme: theme, title: title),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _SectionIntro(
                isDark: isDark,
                theme: theme,
                title: title,
                subtitle: subtitle,
                backLabel: state.uiMode == AttendanceUiMode.sessions
                    ? 'Back to sessions'
                    : 'Back',
                onBack: cubit.backToSection,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _ActionButton(
                    label: 'Everyone Present',
                    color: theme.primary,
                    onTap: state.isRosterReadOnly
                        ? null
                        : () => _confirmBulkStatus(
                            context,
                            cubit: cubit,
                            status: 'present',
                          ),
                  ),
                  _ActionButton(
                    label: 'Everyone Absent',
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFF94A3B8),
                    onTap: state.isRosterReadOnly
                        ? null
                        : () => _confirmBulkStatus(
                            context,
                            cubit: cubit,
                            status: 'absent',
                          ),
                  ),
                  _ActionButton(
                    label: state.isRosterDirty
                        ? 'Save Attendance*'
                        : 'Save Attendance',
                    color: theme.success,
                    onTap: state.isRosterReadOnly ? null : cubit.saveBatch,
                  ),
                  _ActionButton(
                    label: 'Close & Lock',
                    color: theme.error,
                    onTap: state.isRosterReadOnly
                        ? null
                        : () => _confirmCloseSession(context, cubit),
                  ),
                ],
              ),
              if (state.isRosterDirty) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You have unsaved attendance changes. Save before leaving or closing the session.',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (state.isRosterReadOnly) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.warning.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'This session is closed (view only). Open another session to edit.',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _AiReviewPanel(isDark: isDark, theme: theme, state: state),
              const SizedBox(height: 12),
              if (state.displayedRosterRows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No enrolled students.',
                      style: TextStyle(color: theme.textSecondary(isDark)),
                    ),
                  ),
                )
              else
                ...state.displayedRosterRows.map(
                  (row) => _RosterRowCard(
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
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmBulkStatus(
    BuildContext context, {
    required InstructorAttendanceCubit cubit,
    required String status,
  }) async {
    final label = status == 'present' ? 'present' : 'absent';
    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mark everyone $label'),
          content: Text(
            'Apply "$label" to all roster rows? You can still change individual students before saving.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Apply'),
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
  ) async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Close Session'),
          content: const Text(
            'Close and lock this session? Attendance will become read-only.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close & Lock'),
            ),
          ],
        );
      },
    );

    if (shouldClose == true) {
      await cubit.closeSession();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        disabledBackgroundColor: color.withValues(alpha: 0.3),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _AiReviewPanel extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final InstructorAttendanceState state;

  const _AiReviewPanel({
    required this.isDark,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.camera_alt_rounded, color: theme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI from class photo',
                  style: TextStyle(
                    color: theme.textPrimary(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Uses saved face references',
                style: TextStyle(
                  color: theme.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: (state.isRosterReadOnly || state.isAiLoading)
                ? null
                : () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    final path = result?.files.single.path;
                    if (path != null && path.isNotEmpty) {
                      cubit.setAiFile(File(path));
                    }
                  },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.borderColor(isDark)),
              ),
              child: state.aiPhoto == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_a_photo_rounded,
                            color: theme.textSecondary(isDark),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pick attendance photo',
                            style: TextStyle(
                              color: theme.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(state.aiPhoto!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 12),
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
                icon: state.isAiLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology_rounded),
                label: Text(state.isAiLoading ? 'Running...' : 'Run AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    (state.isRosterReadOnly || state.aiReviewRows.isEmpty)
                    ? null
                    : cubit.applyAiResultsToRoster,
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: const Text('Apply AI Suggestions'),
              ),
            ],
          ),
          if (state.aiResult != null) ...<Widget>[
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                _MetricCard(
                  label: 'On roster',
                  value: '${state.aiReviewRows.length}',
                  color: theme.primary,
                ),
                const SizedBox(width: 8),
                _MetricCard(
                  label: 'Flagged',
                  value: '${state.aiNeedsReviewRows.length}',
                  color: theme.warning,
                ),
                const SizedBox(width: 8),
                _MetricCard(
                  label: 'Unknown',
                  value: '${state.aiUnknownCount}',
                  color: theme.info,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
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
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RosterRowCard extends StatelessWidget {
  final bool isDark;
  final SharedAttendanceTheme theme;
  final RosterRow row;
  final AiReviewRow? aiRow;
  final bool isHighlighted;

  const _RosterRowCard({
    required this.isDark,
    required this.theme,
    required this.row,
    required this.aiRow,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.warning.withValues(alpha: isDark ? 0.12 : 0.08)
            : theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? theme.warning.withValues(alpha: 0.4)
              : theme.borderColor(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            row.name,
                            style: TextStyle(
                              color: theme.textPrimary(isDark),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isHighlighted) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Review',
                              style: TextStyle(
                                color: theme.warning,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (row.email.isNotEmpty)
                      Text(
                        row.email,
                        style: TextStyle(
                          color: theme.textSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (row.isAiMarked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    aiRow?.confidencePercent != null
                        ? 'AI ${aiRow!.confidencePercent!.toStringAsFixed(0)}%'
                        : 'AI',
                    style: TextStyle(
                      color: theme.info,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          StatusToggleWidget(
            currentStatus: row.status,
            isDark: isDark,
            isDisabled: context
                .read<InstructorAttendanceCubit>()
                .state
                .isRosterReadOnly,
            onChanged: (status) => cubit.applyStatus(row.userId, status),
          ),
          const SizedBox(height: 10),
          Text(
            aiRow == null
                ? 'Not run yet. Choose a photo and click Run AI.'
                : aiRow!.confidencePercent != null
                ? 'AI suggested ${aiRow!.suggestedStatus} • ${aiRow!.confidencePercent!.toStringAsFixed(0)}% confidence'
                : 'AI suggested ${aiRow!.suggestedStatus} • No confidence score',
            style: TextStyle(color: theme.textSecondary(isDark), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
