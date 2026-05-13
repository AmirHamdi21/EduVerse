import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/attendance/attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

enum _CourseAttendanceViewMode { sessions, calendar }

class CourseAttendanceDetailScreen extends StatefulWidget {
  final CourseAttendance course;
  final List<AttendanceRecord> records;

  const CourseAttendanceDetailScreen({
    super.key,
    required this.course,
    required this.records,
  });

  @override
  State<CourseAttendanceDetailScreen> createState() =>
      _CourseAttendanceDetailScreenState();
}

class _CourseAttendanceDetailScreenState
    extends State<CourseAttendanceDetailScreen> {
  static const List<Color> _studentHeroColors = [
    Color(0xFF2563EB),
    Color(0xFF06B6D4),
  ];
  AttendanceStatus? _selectedStatus;
  _CourseAttendanceViewMode _viewMode = _CourseAttendanceViewMode.sessions;
  late DateTime _calendarMonth;

  @override
  void initState() {
    super.initState();
    final seedDate = widget.records.isNotEmpty
        ? widget.records.first.date
        : DateTime.now();
    _calendarMonth = DateTime(seedDate.year, seedDate.month);
  }

  List<AttendanceRecord> get _filteredRecords {
    final source = List<AttendanceRecord>.from(
      _selectedStatus == null
          ? widget.records
          : widget.records.where((r) => r.status == _selectedStatus),
    );
    source.sort((a, b) => b.date.compareTo(a.date));
    return source;
  }

  List<AttendanceRecord> get _monthRecords {
    return _filteredRecords.where((record) {
      return record.date.year == _calendarMonth.year &&
          record.date.month == _calendarMonth.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(context, isDark),
                        const SizedBox(height: 14),
                        _buildHero(context, isDark),
                        const SizedBox(height: 14),
                        _buildStatsSection(context, isDark),
                        const SizedBox(height: 14),
                        _buildFilterRow(context, isDark),
                        const SizedBox(height: 14),
                        _buildContentHeader(context, isDark),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: _viewMode == _CourseAttendanceViewMode.sessions
                        ? _buildSessionsView(context, isDark)
                        : _buildCalendarView(context, isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        _buildIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          isDark: isDark,
          onTap: () => _leaveCourseAttendanceDetail(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.attendance,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Text(
                widget.course.courseCode,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _leaveCourseAttendanceDetail(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/attendance');
  }

  Widget _buildHero(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final colors = _studentHeroColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.attendanceCourseSnapshot,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.course.attendancePercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.attendanceRate,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.8),
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
            children: [
              _buildHeroChip(
                icon: Icons.school_rounded,
                text: '${widget.course.totalClasses} ${l10n.totalClasses}',
              ),
              _buildHeroChip(
                icon: Icons.check_circle_rounded,
                text: '${widget.course.presentCount} ${l10n.present}',
              ),
              _buildHeroChip(
                icon: Icons.calendar_month_rounded,
                text:
                    '${_filteredRecords.length} ${l10n.attendanceSessionView}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        final cards = [
          _buildStatCard(
            isDark: isDark,
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
            value: widget.course.presentCount.toString(),
            label: l10n.present,
          ),
          _buildStatCard(
            isDark: isDark,
            color: const Color(0xFFF59E0B),
            icon: Icons.schedule_rounded,
            value: widget.course.lateCount.toString(),
            label: l10n.late,
          ),
          _buildStatCard(
            isDark: isDark,
            color: const Color(0xFFEF4444),
            icon: Icons.cancel_rounded,
            value: widget.course.absentCount.toString(),
            label: l10n.absent,
          ),
          _buildStatCard(
            isDark: isDark,
            color: const Color(0xFF8B5CF6),
            icon: Icons.verified_rounded,
            value: widget.course.excusedCount.toString(),
            label: l10n.excused,
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required Color color,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.12 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final statusMenu = _buildMenuCard<AttendanceStatus?>(
      isDark: isDark,
      title: l10n.attendanceStatusFilter,
      value: _statusLabel(context, _selectedStatus),
      icon: Icons.tune_rounded,
      items: [
        PopupMenuItem<AttendanceStatus?>(value: null, child: Text(l10n.all)),
        PopupMenuItem<AttendanceStatus?>(
          value: AttendanceStatus.present,
          child: Text(l10n.present),
        ),
        PopupMenuItem<AttendanceStatus?>(
          value: AttendanceStatus.late,
          child: Text(l10n.late),
        ),
        PopupMenuItem<AttendanceStatus?>(
          value: AttendanceStatus.absent,
          child: Text(l10n.absent),
        ),
        PopupMenuItem<AttendanceStatus?>(
          value: AttendanceStatus.excused,
          child: Text(l10n.excused),
        ),
      ],
      onSelected: (value) {
        setState(() => _selectedStatus = value);
      },
    );
    final viewMenu = _buildMenuCard<_CourseAttendanceViewMode>(
      isDark: isDark,
      title: l10n.view,
      value: _viewMode == _CourseAttendanceViewMode.sessions
          ? l10n.attendanceSessionView
          : l10n.calendar,
      icon: Icons.grid_view_rounded,
      items: [
        PopupMenuItem<_CourseAttendanceViewMode>(
          value: _CourseAttendanceViewMode.sessions,
          child: Text(l10n.attendanceSessionView),
        ),
        PopupMenuItem<_CourseAttendanceViewMode>(
          value: _CourseAttendanceViewMode.calendar,
          child: Text(l10n.calendar),
        ),
      ],
      onSelected: (value) {
        setState(() => _viewMode = value);
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [statusMenu, const SizedBox(height: 12), viewMenu],
          );
        }

        return Row(
          children: [
            Expanded(child: statusMenu),
            const SizedBox(width: 12),
            Expanded(child: viewMenu),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard<T>({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required List<PopupMenuEntry<T>> items,
    required ValueChanged<T> onSelected,
  }) {
    final accent = Color(widget.course.gradientColors[0]);

    return PopupMenuButton<T>(
      onSelected: onSelected,
      offset: const Offset(0, 10),
      elevation: 12,
      color: isDark ? const Color(0xFF162033) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (_) => items,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162033) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final count = _viewMode == _CourseAttendanceViewMode.sessions
        ? _filteredRecords.length
        : _monthRecords.length;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _viewMode == _CourseAttendanceViewMode.sessions
                    ? l10n.history
                    : l10n.calendar,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _viewMode == _CourseAttendanceViewMode.sessions
                    ? l10n.attendanceSessionsSubtitle
                    : l10n.attendanceCalendarSubtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(
              widget.course.gradientColors[0],
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(widget.course.gradientColors[0]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsView(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final records = _filteredRecords;
    if (records.isEmpty) {
      return _buildEmptyState(
        context: context,
        isDark: isDark,
        icon: Icons.event_busy_rounded,
        title: _selectedStatus == null
            ? l10n.attendanceNoSessionsYet
            : l10n.attendanceNoSessionsMatchFilters,
        description: l10n.attendanceSessionsSubtitle,
      );
    }

    final groupedRecords = <String, List<AttendanceRecord>>{};
    for (final record in records) {
      final key = _monthLabel(record.date, l10n);
      groupedRecords.putIfAbsent(key, () => []).add(record);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedRecords.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
              ...entry.value.map(
                (record) => _buildRecordCard(
                  context: context,
                  isDark: isDark,
                  record: record,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordCard({
    required BuildContext context,
    required bool isDark,
    required AttendanceRecord record,
  }) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(record.status);
    final noteText = (record.note ?? '').trim();
    final normalizedStatus = _statusLabel(context, record.status).toLowerCase();
    final normalizedNote = noteText.toLowerCase();
    final shouldShowNote =
        noteText.isNotEmpty && normalizedNote != normalizedStatus;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _statusIcon(record.status),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.lectureTitle ?? l10n.attendanceSessionView,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(context, record.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildMetaLine(
                      icon: Icons.calendar_today_rounded,
                      text: _dayLabel(record.date),
                      isDark: isDark,
                    ),
                    _buildMetaLine(
                      icon: Icons.schedule_rounded,
                      text:
                          '${record.startTime.format(context)} - ${record.endTime.format(context)}',
                      isDark: isDark,
                    ),
                    _buildMetaLine(
                      icon: Icons.code_rounded,
                      text: record.courseCode,
                      isDark: isDark,
                    ),
                  ],
                ),
                if (shouldShowNote) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      noteText,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isDark
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaLine({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final monthRecords = _monthRecords;
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateTime(
      _calendarMonth.year,
      _calendarMonth.month + 1,
      0,
    ).day;
    final leadingEmpty = firstDay.weekday % 7;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162033) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildIconButton(
                    icon: Icons.chevron_left_rounded,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _calendarMonth = DateTime(
                          _calendarMonth.year,
                          _calendarMonth.month - 1,
                        );
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      _monthLabel(_calendarMonth, l10n),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _buildIconButton(
                    icon: Icons.chevron_right_rounded,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _calendarMonth = DateTime(
                          _calendarMonth.year,
                          _calendarMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final day in [
                    l10n.sun,
                    l10n.mon,
                    l10n.tue,
                    l10n.wed,
                    l10n.thu,
                    l10n.fri,
                    l10n.sat,
                  ])
                    Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.92,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final dayNumber = index - leadingEmpty + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  final dayDate = DateTime(
                    _calendarMonth.year,
                    _calendarMonth.month,
                    dayNumber,
                  );
                  AttendanceRecord? dayRecord;
                  for (final record in monthRecords) {
                    if (record.date.year == dayDate.year &&
                        record.date.month == dayDate.month &&
                        record.date.day == dayDate.day) {
                      dayRecord = record;
                      break;
                    }
                  }

                  return _buildCalendarCell(
                    isDark: isDark,
                    day: dayNumber,
                    record: dayRecord,
                    isToday: _isSameDay(dayDate, DateTime.now()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (monthRecords.isEmpty)
          _buildEmptyState(
            context: context,
            isDark: isDark,
            icon: Icons.calendar_month_rounded,
            title: l10n.attendanceNoSessionsMatchFilters,
            description: l10n.attendanceCalendarSubtitle,
          )
        else
          Column(
            children: monthRecords
                .take(6)
                .map(
                  (record) => _buildRecordCard(
                    context: context,
                    isDark: isDark,
                    record: record,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCalendarCell({
    required bool isDark,
    required int day,
    required AttendanceRecord? record,
    required bool isToday,
  }) {
    final accent = Color(widget.course.gradientColors[0]);
    final statusColor = record == null ? null : _statusColor(record.status);

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isToday
            ? accent.withValues(alpha: 0.12)
            : statusColor?.withValues(alpha: 0.12) ??
                  (isDark
                      ? const Color(0xFF101827).withValues(alpha: 0.45)
                      : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? accent
              : statusColor?.withValues(alpha: 0.22) ??
                    (isDark
                        ? const Color(0xFF233044)
                        : const Color(0xFFE2E8F0)),
          width: isToday ? 1.6 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isToday
                  ? accent
                  : isDark
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
          ),
          if (statusColor != null) ...[
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Color(
                widget.course.gradientColors[0],
              ).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              size: 28,
              color: Color(widget.course.gradientColors[0]),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162033) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF233044) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Color _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF10B981);
      case AttendanceStatus.absent:
        return const Color(0xFFEF4444);
      case AttendanceStatus.late:
        return const Color(0xFFF59E0B);
      case AttendanceStatus.excused:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _statusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.late:
        return Icons.schedule_rounded;
      case AttendanceStatus.excused:
        return Icons.verified_rounded;
    }
  }

  String _statusLabel(BuildContext context, AttendanceStatus? status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case null:
        return l10n.all;
      case AttendanceStatus.present:
        return l10n.present;
      case AttendanceStatus.absent:
        return l10n.absent;
      case AttendanceStatus.late:
        return l10n.late;
      case AttendanceStatus.excused:
        return l10n.excused;
    }
  }

  String _monthLabel(DateTime date, AppLocalizations l10n) {
    return '${_monthName(date.month, l10n)} ${date.year}';
  }

  String _monthName(int month, AppLocalizations l10n) {
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    return months[month - 1];
  }

  String _dayLabel(DateTime date) {
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
