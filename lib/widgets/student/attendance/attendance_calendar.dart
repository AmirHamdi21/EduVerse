import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/attendance/attendance_cubit.dart';
import '../../../bloc/attendance/attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class AttendanceCalendar extends StatefulWidget {
  const AttendanceCalendar({super.key});

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<AttendanceCubit, AttendanceState>(
          buildWhen: (previous, current) =>
              previous.allRecords != current.allRecords ||
              previous.selectedDate != current.selectedDate,
          builder: (context, state) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCalendarHeader(isDark, l10n),
                  _buildWeekdayHeaders(isDark, l10n),
                  _buildCalendarGrid(isDark, state),
                  _buildSelectedDateRecords(isDark, state, l10n),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarHeader(bool isDark, AppLocalizations l10n) {
    final monthNames = [
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(bool isDark, AppLocalizations l10n) {
    final weekdays = [
      l10n.sun,
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark, AttendanceState state) {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday = _isToday(date);
      final isSelected = _isSameDay(date, _selectedDate);
      final dayStatus = _getDayStatus(date, state.allRecords);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            context.read<AttendanceCubit>().setSelectedDate(date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : isToday
                  ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
                if (dayStatus != null)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dayStatus,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildSelectedDateRecords(
    bool isDark,
    AttendanceState state,
    AppLocalizations l10n,
  ) {
    final dayRecords = state.allRecords.where((r) {
      return _isSameDay(r.date, _selectedDate);
    }).toList();

    if (dayRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          l10n.noClassesOnThisDay,
          style: TextStyle(
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dayRecords.length} ${l10n.classesOnThisDay}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          ...dayRecords.map((record) => _buildRecordItem(record, isDark, l10n)),
        ],
      ),
    );
  }

  Widget _buildRecordItem(
    AttendanceRecord record,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final statusColor = _getStatusColor(record.status);
    final statusText = _getStatusText(record.status, l10n);
    final statusIcon = _getStatusIcon(record.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.courseName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      record.courseCode,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    if (record.lectureTitle != null &&
                        record.lectureTitle!.isNotEmpty) ...[
                      Text(
                        ' · ',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          record.lectureTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.startTime.format(context)} - ${record.endTime.format(context)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.late:
        return Icons.schedule_rounded;
      case AttendanceStatus.excused:
        return Icons.info_outline_rounded;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color? _getDayStatus(DateTime date, List<AttendanceRecord> records) {
    final dayRecords = records.where((r) => _isSameDay(r.date, date)).toList();

    if (dayRecords.isEmpty) return null;

    final hasAbsent = dayRecords.any(
      (r) => r.status == AttendanceStatus.absent,
    );
    final hasLate = dayRecords.any((r) => r.status == AttendanceStatus.late);
    final allPresent = dayRecords.every(
      (r) => r.status == AttendanceStatus.present,
    );

    if (hasAbsent) return const Color(0xFFEF4444);
    if (hasLate) return const Color(0xFFF59E0B);
    if (allPresent) return const Color(0xFF10B981);
    return const Color(0xFF6366F1);
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF10B981);
      case AttendanceStatus.absent:
        return const Color(0xFFEF4444);
      case AttendanceStatus.late:
        return const Color(0xFFF59E0B);
      case AttendanceStatus.excused:
        return const Color(0xFF6366F1);
    }
  }

  String _getStatusText(AttendanceStatus status, AppLocalizations l10n) {
    switch (status) {
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
}
