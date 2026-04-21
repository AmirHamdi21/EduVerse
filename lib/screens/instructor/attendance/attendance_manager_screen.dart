import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/attendance/instructor_attendance_cubit.dart';
import '../../../bloc/attendance/instructor_attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/attendance/attendance_session_model.dart';
import '../../../services/api/attendance_service.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/shared/attendance/ai_attendance_panel.dart';
import '../../../widgets/shared/attendance/status_toggle_widget.dart';

// ── Color constants ────────────────────────────────────────────────────
const _kPrimary = Color(0xFF3B82F6);
const _kCyan = Color(0xFF06B6D4);
const _kGreen = Color(0xFF10B981);
const _kAmber = Color(0xFFF59E0B);
const _kRed = Color(0xFFEF4444);

const _kSectionGradients = [
  [Color(0xFF3B82F6), Color(0xFF06B6D4)],
  [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  [Color(0xFF10B981), Color(0xFF34D399)],
  [Color(0xFFEF4444), Color(0xFFF87171)],
  [Color(0xFFEC4899), Color(0xFFF472B6)],
];

Color _textPrimary(bool d) => d ? Colors.white : const Color(0xFF1E293B);
Color _textSecondary(bool d) =>
    d ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
Color _cardBg(bool d) => d ? const Color(0xFF1E293B) : Colors.white;
Color _border(bool d) =>
    d ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
Color _scaffoldBg(bool d) =>
    d ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

class AttendanceManagerScreen extends StatelessWidget {
  const AttendanceManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstructorAttendanceCubit>(
      create: (ctx) => InstructorAttendanceCubit(
        attendanceService: ctx.read<AttendanceService>(),
        enrollmentService: ctx.read<EnrollmentService>(),
      )..loadTeachingSections(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        return Scaffold(
          backgroundColor: _scaffoldBg(isDark),
          body: SafeArea(
            child: BlocConsumer<InstructorAttendanceCubit,
                InstructorAttendanceState>(
              listener: (ctx, s) {
                if (s.error != null && s.error!.isNotEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(s.error!),
                    backgroundColor: _kRed,
                  ));
                }
              },
              builder: (ctx, state) {
                if (state.isLoading && state.teachingSections.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return switch (state.view) {
                  InstructorAttendanceView.classes =>
                    _ClassesView(isDark: isDark, state: state),
                  InstructorAttendanceView.section =>
                    _SectionView(isDark: isDark, state: state),
                  InstructorAttendanceView.roster =>
                    _RosterView(isDark: isDark, state: state),
                };
              },
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  VIEW 1 — Classes Grid
// ════════════════════════════════════════════════════════════════════════

class _ClassesView extends StatelessWidget {
  final bool isDark;
  final InstructorAttendanceState state;
  const _ClassesView({required this.isDark, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    return Column(
      children: [
        _header(context, 'Your Sections', 'Choose a class to take attendance',
            isDark),
        Expanded(
          child: state.teachingSections.isEmpty
              ? Center(
                  child: Text('No sections assigned.',
                      style: TextStyle(color: _textSecondary(isDark))))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.teachingSections.length,
                  itemBuilder: (ctx, i) {
                    final s = state.teachingSections[i];
                    final colors =
                        _kSectionGradients[i % _kSectionGradients.length];
                    return _SectionCard(
                      section: s,
                      colors: colors,
                      isDark: isDark,
                      onTap: () => cubit.openSection(s, s.sectionId),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final dynamic section;
  final List<Color> colors;
  final bool isDark;
  final VoidCallback onTap;
  const _SectionCard(
      {required this.section,
      required this.colors,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardBg(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.course.courseCode,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors[0],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          section.course.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Section ${section.section.sectionNumber}',
                          style: TextStyle(
                              fontSize: 12, color: _textSecondary(isDark)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: _textSecondary(isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  VIEW 2 — Section Detail (Open Sessions + Create)
// ════════════════════════════════════════════════════════════════════════

class _SectionView extends StatelessWidget {
  final bool isDark;
  final InstructorAttendanceState state;
  const _SectionView({required this.isDark, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final sec = state.selectedSection;
    final title = sec != null
        ? '${sec.course.courseCode} — ${sec.course.name}'
        : 'Section';
    final subtitle = sec != null
        ? 'Section ${sec.section.sectionNumber} · Take or resume attendance'
        : '';

    final openSessions = state.sessions
        .where(
            (s) => s.status == 'scheduled' || s.status == 'in_progress')
        .toList();

    return Column(
      children: [
        _headerWithBack(context, title, subtitle, isDark, '← All sections',
            cubit.backToClasses),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Open Sessions Card
              _card(
                isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pending_actions_rounded,
                            color: _kPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text('Open Sessions',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _textPrimary(isDark))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sessions not closed yet. Resume to keep editing.',
                      style:
                          TextStyle(fontSize: 12, color: _textSecondary(isDark)),
                    ),
                    const SizedBox(height: 12),
                    if (state.isLoading)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child:
                                  CircularProgressIndicator(strokeWidth: 2)))
                    else if (openSessions.isEmpty)
                      Text('No open sessions. Start a new lecture below.',
                          style: TextStyle(
                              fontSize: 13, color: _textSecondary(isDark)))
                    else
                      ...openSessions.map((s) => _SessionTile(
                          session: s,
                          isDark: isDark,
                          onTap: () => cubit.openRosterFromSession(s))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Create Session Card
              _card(
                isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_circle_outline_rounded,
                            color: _kGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('Start New Lecture Attendance',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _textPrimary(isDark))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Date',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _textSecondary(isDark),
                            letterSpacing: 1)),
                    const SizedBox(height: 6),
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
                          final m = picked.month.toString().padLeft(2, '0');
                          final d = picked.day.toString().padLeft(2, '0');
                          cubit.updateNewSessionDate('${picked.year}-$m-$d');
                        }
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(state.newSessionDate),
                    ),
                    const SizedBox(height: 10),
                    Text('Type',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _textSecondary(isDark),
                            letterSpacing: 1)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: state.newSessionType,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: _cardBg(isDark),
                      ),
                      dropdownColor: _cardBg(isDark),
                      items: const [
                        DropdownMenuItem(
                            value: 'lecture', child: Text('Lecture')),
                        DropdownMenuItem(value: 'lab', child: Text('Lab')),
                        DropdownMenuItem(
                            value: 'tutorial', child: Text('Tutorial')),
                        DropdownMenuItem(value: 'exam', child: Text('Exam')),
                      ],
                      onChanged: (v) {
                        if (v != null) cubit.updateNewSessionType(v);
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            state.isLoading ? null : () => cubit.createSession(),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Create Session & Open Roster'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final AttendanceSessionModel session;
  final bool isDark;
  final VoidCallback onTap;
  const _SessionTile(
      {required this.session, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = session.status == 'in_progress' ? _kAmber : _kPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(session.status,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.sessionDate,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _textPrimary(isDark))),
                Text('${session.sessionType ?? 'lecture'} · id ${session.id}',
                    style:
                        TextStyle(fontSize: 11, color: _textSecondary(isDark))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Open Roster', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  VIEW 3 — Roster
// ════════════════════════════════════════════════════════════════════════

class _RosterView extends StatelessWidget {
  final bool isDark;
  final InstructorAttendanceState state;
  const _RosterView({required this.isDark, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstructorAttendanceCubit>();
    final sec = state.selectedSection;
    final title = sec != null ? '${sec.course.courseCode} — roster' : 'Roster';
    final parts = [
      if (state.activeSession != null) 'Session ${state.activeSession!.id}',
      state.activeSession?.sessionDate ?? '',
      state.activeSession?.sessionType ?? '',
      state.activeSession?.status ?? '',
    ].where((s) => s.isNotEmpty).join(' · ');

    return Column(
      children: [
        _headerWithBack(
            context, title, parts, isDark, '← Back', cubit.backToSection),
        Expanded(
          child: state.isLoading && state.rosterRows.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Action buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _actionBtn('Everyone Present', _kPrimary,
                            state.isRosterReadOnly
                                ? null
                                : () => cubit.setAllStatus('present')),
                        _actionBtn(
                            'Everyone Absent',
                            isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            state.isRosterReadOnly
                                ? null
                                : () => cubit.setAllStatus('absent')),
                        _actionBtn('Save', _kGreen,
                            state.isRosterReadOnly ? null : cubit.saveBatch),
                        _actionBtn('Close & Lock', _kRed,
                            state.isRosterReadOnly ? null : cubit.closeSession),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Read-only banner
                    if (state.isRosterReadOnly)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _kAmber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _kAmber.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'This session is closed (view only).',
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFF92400E)),
                        ),
                      ),

                    // AI Panel
                    if (!state.isRosterReadOnly)
                      AiAttendancePanel(
                        sessionId: state.activeSession?.id,
                        isReadOnly: state.isRosterReadOnly,
                        isLoading: state.isAiLoading,
                        error: state.aiError,
                        result: state.aiResult,
                        selectedPhoto: state.aiPhoto,
                        onPickPhoto: () async {
                          final r = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          final p = r?.files.single.path;
                          if (p != null) cubit.setAiFile(File(p));
                        },
                        onRunAi: cubit.runAiAttendance,
                        onApplyResults: cubit.applyAiResultsToRoster,
                      ),

                    const SizedBox(height: 8),

                    // Roster rows
                    if (state.rosterRows.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('No enrolled students.',
                              style: TextStyle(color: _textSecondary(isDark))),
                        ),
                      )
                    else
                      ...state.rosterRows.map((row) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _cardBg(isDark),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _border(isDark)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(row.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      _textPrimary(isDark))),
                                          if (row.email.isNotEmpty)
                                            Text(row.email,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: _textSecondary(
                                                        isDark))),
                                        ],
                                      ),
                                    ),
                                    if (row.isAiMarked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              _kCyan.withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'AI ${row.aiConfidence != null ? '${(row.aiConfidence! * 100).toStringAsFixed(0)}%' : ''}',
                                          style: const TextStyle(
                                              fontSize: 10, color: _kCyan),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                StatusToggleWidget(
                                  currentStatus: row.status,
                                  isDark: isDark,
                                  isDisabled: state.isRosterReadOnly,
                                  onChanged: (s) =>
                                      cubit.applyStatus(row.userId, s),
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback? onTap) {
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

// ════════════════════════════════════════════════════════════════════════
//  Shared helpers
// ════════════════════════════════════════════════════════════════════════

Widget _header(BuildContext ctx, String title, String subtitle, bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: _cardBg(isDark),
      border: Border(bottom: BorderSide(color: _border(isDark))),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(ctx).pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPrimary(isDark)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary(isDark))),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 13, color: _textSecondary(isDark))),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _headerWithBack(BuildContext ctx, String title, String subtitle,
    bool isDark, String backLabel, VoidCallback onBack) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: _cardBg(isDark),
      border: Border(bottom: BorderSide(color: _border(isDark))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary(isDark)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 12, color: _textSecondary(isDark)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onBack,
          child: Text(backLabel, style: const TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );
}

Widget _card(bool isDark, {required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _cardBg(isDark),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border(isDark)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
