import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import 'course_management_colors.dart';

/// Redesigned students tab with modern list and search
class StudentsTab extends StatefulWidget {
  final List<SectionStudentModel> students;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback? onRefreshRequested;
  final String? emptyStateTitleOverride;
  final String? emptyStateSubtitleOverride;

  const StudentsTab({
    super.key,
    required this.students,
    required this.isDark,
    required this.l10n,
    this.onRefreshRequested,
    this.emptyStateTitleOverride,
    this.emptyStateSubtitleOverride,
  });

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  String _search = '';

  List<SectionStudentModel> get _students => widget.students;

  List<SectionStudentModel> get _filtered => _search.isEmpty
      ? _students
      : _students.where((student) {
          final query = _search.toLowerCase();
          return student.displayName.toLowerCase().contains(query) ||
              student.resolvedEmail.toLowerCase().contains(query) ||
              student.studentIdLabel.toLowerCase().contains(query) ||
              student.status.toLowerCase().contains(query);
        }).toList();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefreshRequested?.call(),
      color: CMColors.primary,
      child: Column(
        children: [
          _buildSearchBar(),
          _buildStudentCount(),
          Expanded(
            child: _filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                    children: [_buildEmptyState()],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      return _StudentCard(
                        student: _filtered[index],
                        isDark: widget.isDark,
                        l10n: widget.l10n,
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CMColors.cardColor(widget.isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CMColors.borderColor(widget.isDark),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: widget.isDark ? 0.15 : 0.03,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                style: TextStyle(
                  color: CMColors.text(widget.isDark),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '${widget.l10n.searchStudents}...',
                  hintStyle: TextStyle(
                    color: CMColors.textMutedColor(widget.isDark),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: CMColors.primary,
                    size: 20,
                  ),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: CMColors.textMutedColor(widget.isDark),
                            size: 18,
                          ),
                          onPressed: () => setState(() => _search = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          if (widget.onRefreshRequested != null) ...[
            const SizedBox(width: 10),
            InkWell(
              onTap: widget.onRefreshRequested,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CMColors.primary.withValues(alpha: 0.14),
                      CMColors.accent.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: CMColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: CMColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CMColors.primary.withValues(alpha: 0.1),
                  CMColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_filtered.length} ${widget.l10n.students}',
              style: const TextStyle(
                color: CMColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // const SizedBox(width: 8),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //   decoration: BoxDecoration(
          //     color: CMColors.surfaceColor(widget.isDark),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Text(
          //     'Live from roster endpoint',
          //     style: TextStyle(
          //       color: CMColors.textSub(widget.isDark),
          //       fontSize: 11,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final title = widget.students.isEmpty
        ? (widget.emptyStateTitleOverride ?? 'No students enrolled yet')
        : 'No students found';

    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 48,
              color: CMColors.textMutedColor(widget.isDark),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: CMColors.text(widget.isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.students.isEmpty &&
                widget.emptyStateSubtitleOverride != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.emptyStateSubtitleOverride!,
                style: TextStyle(
                  color: CMColors.textSub(widget.isDark),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ] else if (widget.students.isEmpty &&
                widget.emptyStateTitleOverride == null) ...[
              const SizedBox(height: 8),
              Text(
                'Students will appear here when enrollments are available.',
                style: TextStyle(
                  color: CMColors.textSub(widget.isDark),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final SectionStudentModel student;
  final bool isDark;
  final AppLocalizations l10n;
  final int index;

  const _StudentCard({
    required this.student,
    required this.isDark,
    required this.l10n,
    required this.index,
  });

  static const List<Color> _avatarColors = [
    CMColors.primary,
    CMColors.accent,
    CMColors.orange,
    CMColors.teal,
    CMColors.pink,
    CMColors.success,
  ];

  Color get _avatarColor => _avatarColors[index % _avatarColors.length];

  String get _initials {
    final first = (student.firstName?.isNotEmpty ?? false)
        ? student.firstName![0]
        : '';
    final last = (student.lastName?.isNotEmpty ?? false)
        ? student.lastName![0]
        : '';
    final value = (first + last).trim();
    return value.isEmpty ? 'S' : value.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(student.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CMColors.borderColor(isDark), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _avatarColor,
                            _avatarColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _avatarColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.displayName,
                            style: TextStyle(
                              color: CMColors.text(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.email ?? 'No email',
                            style: TextStyle(
                              color: CMColors.textSub(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<void>(
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: CMColors.surfaceColor(isDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: CMColors.textMutedColor(isDark),
                          size: 18,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: CMColors.cardColor(isDark),
                      itemBuilder: (context) => [
                        _buildMenuItem(
                          Icons.email_outlined,
                          l10n.sendMessage,
                          CMColors.primary,
                        ),
                        _buildMenuItem(
                          Icons.grade_outlined,
                          l10n.viewGrades,
                          CMColors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.badge_outlined,
                      label: student.studentIdLabel,
                    ),
                    _buildStatusChip(statusColor),
                    if (student.grade != null)
                      _buildInfoChip(
                        icon: Icons.analytics_outlined,
                        label: 'Grade: ${student.grade!.toStringAsFixed(1)}',
                        tint: CMColors.orange,
                      ),
                    if (student.finalScore != null)
                      _buildInfoChip(
                        icon: Icons.emoji_events_outlined,
                        label:
                            'Score: ${student.finalScore!.toStringAsFixed(1)}',
                        tint: CMColors.teal,
                      ),
                  ],
                ),
                if (student.courseCode != null ||
                    student.enrollmentDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CMColors.surfaceColor(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        if (student.courseCode != null)
                          Expanded(
                            child: _buildMetaColumn(
                              label: 'Course',
                              value: student.courseCode!,
                              isDark: isDark,
                            ),
                          ),
                        if (student.courseCode != null &&
                            student.enrollmentDate != null)
                          const SizedBox(width: 12),
                        if (student.enrollmentDate != null)
                          Expanded(
                            child: _buildMetaColumn(
                              label: 'Enrolled',
                              value: _formatDate(student.enrollmentDate!),
                              isDark: isDark,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.contains('wait')) {
      return CMColors.orange;
    }
    if (normalized.contains('drop') || normalized.contains('inactive')) {
      return CMColors.pink;
    }
    return CMColors.success;
  }

  Widget _buildStatusChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            student.status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? tint,
  }) {
    final color = tint ?? CMColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: CMColors.textSub(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<void> _buildMenuItem(IconData icon, String label, Color color) {
    return PopupMenuItem<void>(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : CMColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

Widget _buildMetaColumn({
  required String label,
  required String value,
  required bool isDark,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: CMColors.textMutedColor(isDark),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          color: CMColors.text(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
