import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

enum TAAttendanceStatus { present, absent, late, unmarked }

class TALabAttendanceTab extends StatefulWidget {
  final bool isDark;
  final List<TALabSession> sessions;
  final Function(TALabSession, TALabStudent, TAAttendanceStatus)?
  onMarkAttendance;
  final Function(TALabSession)? onMarkAllPresent;
  final Function(TALabSession)? onExport;

  const TALabAttendanceTab({
    super.key,
    required this.isDark,
    required this.sessions,
    this.onMarkAttendance,
    this.onMarkAllPresent,
    this.onExport,
  });

  @override
  State<TALabAttendanceTab> createState() => _TALabAttendanceTabState();
}

class _TALabAttendanceTabState extends State<TALabAttendanceTab> {
  late TALabSession _selectedSession;

  @override
  void initState() {
    super.initState();
    _selectedSession = widget.sessions.isNotEmpty
        ? widget.sessions.first
        : TALabSession(
            id: '0',
            title: 'No sessions',
            date: '',
            timeRange: '',
            students: [],
          );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSessionCard(l10n),
          const SizedBox(height: 20),
          _buildStudentsList(l10n),
          const SizedBox(height: 16),
          _buildActionButtons(l10n),
          const SizedBox(height: 16),
          _buildAINotice(l10n),
        ],
      ),
    );
  }

  Widget _buildSessionCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                      _selectedSession.title,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(widget.isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedSession.date} • ${_selectedSession.timeRange}',
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(widget.isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSessionDropdown(l10n),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TAColors.borderColor(widget.isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSession.id,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: TAColors.textSecondaryColor(widget.isDark),
          ),
          isDense: true,
          dropdownColor: TAColors.cardColor(widget.isDark),
          items: widget.sessions.map((session) {
            return DropdownMenuItem<String>(
              value: session.id,
              child: Text(
                l10n.taLabSession + ' ' + session.id,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(widget.isDark),
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSession = widget.sessions.firstWhere(
                  (s) => s.id == value,
                );
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildStudentsList(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _selectedSession.students.asMap().entries.map((entry) {
          final index = entry.key;
          final student = entry.value;
          final isLast = index == _selectedSession.students.length - 1;

          return Column(
            children: [
              _buildStudentRow(student, l10n),
              if (!isLast)
                Divider(
                  height: 1,
                  color: TAColors.borderColor(
                    widget.isDark,
                  ).withValues(alpha: 0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentRow(TALabStudent student, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(
                alpha: widget.isDark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              student.name,
              style: TextStyle(
                color: TAColors.textPrimaryColor(widget.isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildAttendanceButtons(student),
        ],
      ),
    );
  }

  Widget _buildAttendanceButtons(TALabStudent student) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAttendanceIcon(
          status: TAAttendanceStatus.present,
          currentStatus: student.status,
          student: student,
        ),
        const SizedBox(width: 8),
        _buildAttendanceIcon(
          status: TAAttendanceStatus.absent,
          currentStatus: student.status,
          student: student,
        ),
        const SizedBox(width: 8),
        _buildAttendanceIcon(
          status: TAAttendanceStatus.late,
          currentStatus: student.status,
          student: student,
        ),
      ],
    );
  }

  Widget _buildAttendanceIcon({
    required TAAttendanceStatus status,
    required TAAttendanceStatus currentStatus,
    required TALabStudent student,
  }) {
    final isSelected = status == currentStatus;
    Color color;
    IconData icon;

    switch (status) {
      case TAAttendanceStatus.present:
        color = TAColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case TAAttendanceStatus.absent:
        color = TAColors.error;
        icon = Icons.cancel_rounded;
        break;
      case TAAttendanceStatus.late:
        color = TAColors.warning;
        icon = Icons.access_time_filled_rounded;
        break;
      case TAAttendanceStatus.unmarked:
        color = TAColors.textTertiary;
        icon = Icons.radio_button_unchecked_rounded;
        break;
    }

    return GestureDetector(
      onTap: () {
        widget.onMarkAttendance?.call(_selectedSession, student, status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? color : color.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.check_circle_outline_rounded,
            label: l10n.taLabMarkAllPresent,
            onTap: () => widget.onMarkAllPresent?.call(_selectedSession),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.download_rounded,
            label: l10n.taLabExport,
            onTap: () => widget.onExport?.call(_selectedSession),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: TAColors.cardColor(widget.isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TAColors.borderColor(widget.isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: TAColors.textSecondaryColor(widget.isDark),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(widget.isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAINotice(AppLocalizations l10n) {
    final absentStudents = _selectedSession.students
        .where((s) => s.consecutiveAbsences >= 3)
        .length;

    if (absentStudents == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.warning.withValues(alpha: widget.isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: TAColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${l10n.taLabAINotice}: $absentStudents ${l10n.taLabStudentsAbsent}',
              style: TextStyle(
                color: TAColors.textPrimaryColor(widget.isDark),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TALabSession {
  final String id;
  final String title;
  final String date;
  final String timeRange;
  final List<TALabStudent> students;

  TALabSession({
    required this.id,
    required this.title,
    required this.date,
    required this.timeRange,
    required this.students,
  });
}

class TALabStudent {
  final String id;
  final String name;
  final TAAttendanceStatus status;
  final int consecutiveAbsences;

  TALabStudent({
    required this.id,
    required this.name,
    this.status = TAAttendanceStatus.unmarked,
    this.consecutiveAbsences = 0,
  });
}
