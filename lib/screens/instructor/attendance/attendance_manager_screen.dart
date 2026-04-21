import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/attendance/instructor_attendance_cubit.dart';
import '../../../bloc/attendance/instructor_attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/attendance/attendance_session_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/attendance_service.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/shared/attendance/ai_attendance_panel.dart';
import '../../../widgets/shared/attendance/status_toggle_widget.dart';

class AttendanceManagerScreen extends StatelessWidget {
  const AttendanceManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstructorAttendanceCubit>(
      create: (context) => InstructorAttendanceCubit(
        attendanceService: context.read<AttendanceService>(),
        enrollmentService: context.read<EnrollmentService>(),
      )..loadTeachingSections(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;

          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            body: SafeArea(
              child:
                  BlocConsumer<
                    InstructorAttendanceCubit,
                    InstructorAttendanceState
                  >(
                    listener: (context, state) {
                      if (state.error != null && state.error!.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error!),
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      }
                      if (state.aiError != null && state.aiError!.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.aiError!),
                            backgroundColor: const Color(0xFFF59E0B),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state.isLoading &&
                          state.view == InstructorAttendanceView.classes &&
                          state.teachingSections.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      switch (state.view) {
                        case InstructorAttendanceView.classes:
                          return _ClassesView(isDark: isDark, state: state);
                        case InstructorAttendanceView.section:
                          return _SectionView(isDark: isDark, state: state);
                        case InstructorAttendanceView.roster:
                          return _RosterView(isDark: isDark, state: state);
                      }
                    },
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _ClassesView extends StatelessWidget {
  final bool isDark;
  final InstructorAttendanceState state;

  const _ClassesView({required this.isDark, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _Header(
          title: l10n.attendanceManager,
          subtitle: 'Select a section to manage attendance',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.teachingSections.length,
            itemBuilder: (context, index) {
              final section = state.teachingSections[index];
              return _SectionCard(section: section, isDark: isDark);
            },
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final TeachingCourseModel section;
  final bool isDark;

  const _SectionCard({required this.section, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        title: Text(
          '${section.course.courseCode} - ${section.course.name}',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          'Section ${section.section.sectionNumber} • ${section.semester.name}',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          context.read<InstructorAttendanceCubit>().openSection(
            section,
            section.sectionId,
          );
        },
      ),
    );
  }
}

class _SectionView extends StatefulWidget {
  final bool isDark;
  final InstructorAttendanceState state;

  const _SectionView({required this.isDark, required this.state});

  @override
  State<_SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<_SectionView> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<InstructorAttendanceCubit>();

    return Column(
      children: [
        _Header(
          title:
              '${state.selectedSection?.course.courseCode ?? ''} ${state.selectedSection?.section.sectionNumber ?? ''}',
          subtitle: state.selectedSection?.course.name ?? 'Attendance Sessions',
          showBack: true,
          onBack: cubit.backToClasses,
        ),
        _CreateSessionCard(isDark: widget.isDark, state: state),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: state.sessions
                .where(
                  (s) => s.status == 'scheduled' || s.status == 'in_progress',
                )
                .map(
                  (session) =>
                      _SessionTile(session: session, isDark: widget.isDark),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CreateSessionCard extends StatelessWidget {
  final bool isDark;
  final InstructorAttendanceState state;

  const _CreateSessionCard({required this.isDark, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Session',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
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
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(state.newSessionDate),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state.newSessionType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'lecture', child: Text('Lecture')),
                    DropdownMenuItem(value: 'lab', child: Text('Lab')),
                    DropdownMenuItem(
                      value: 'tutorial',
                      child: Text('Tutorial'),
                    ),
                    DropdownMenuItem(value: 'exam', child: Text('Exam')),
                  ],
                  onChanged: (value) {
                    if (value != null) cubit.updateNewSessionType(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cubit.createSession,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Session'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final AttendanceSessionModel session;
  final bool isDark;

  const _SessionTile({required this.session, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (session.status) {
      'in_progress' => const Color(0xFFF59E0B),
      'completed' => const Color(0xFF10B981),
      'cancelled' => const Color(0xFFEF4444),
      _ => const Color(0xFF3B82F6),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.sessionDate} • ${session.sessionType ?? 'lecture'}',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.status,
                    style: TextStyle(color: statusColor, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<InstructorAttendanceCubit>().openRosterFromSession(
                session,
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _RosterView extends StatelessWidget {
  final bool isDark;
  final InstructorAttendanceState state;

  const _RosterView({required this.isDark, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();

    return Column(
      children: [
        _Header(
          title: 'Session ${state.activeSession?.sessionDate ?? ''}',
          subtitle: state.activeSession?.sessionType ?? 'Roster',
          showBack: true,
          onBack: cubit.backToSection,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isRosterReadOnly
                      ? null
                      : () => cubit.setAllStatus('present'),
                  child: const Text('Mark All Present'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isRosterReadOnly
                      ? null
                      : () => cubit.setAllStatus('absent'),
                  child: const Text('Mark All Absent'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...state.rosterRows.map(
                (row) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              row.name,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (row.aiConfidence != null)
                            Text(
                              'AI ${(row.aiConfidence! * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Color(0xFF0EA5E9),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StatusToggleWidget(
                        currentStatus: row.status,
                        isDisabled: state.isRosterReadOnly,
                        isDark: isDark,
                        onChanged: (status) =>
                            cubit.applyStatus(row.userId, status),
                      ),
                    ],
                  ),
                ),
              ),
              AiAttendancePanel(
                sessionId: state.activeSession?.id,
                isReadOnly: state.isRosterReadOnly,
                isLoading: state.isAiLoading,
                error: state.aiError,
                result: state.aiResult,
                selectedPhoto: state.aiPhoto,
                onPickPhoto: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: false,
                  );
                  final path = result?.files.single.path;
                  if (path != null && path.isNotEmpty) {
                    cubit.setAiFile(File(path));
                  }
                },
                onRunAi: cubit.runAiAttendance,
                onApplyResults: cubit.applyAiResultsToRoster,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isRosterReadOnly
                          ? null
                          : cubit.saveBatch,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isRosterReadOnly
                          ? null
                          : cubit.closeSession,
                      icon: const Icon(Icons.lock_outline_rounded),
                      label: const Text('Close Session'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;

  const _Header({
    required this.title,
    required this.subtitle,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
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
