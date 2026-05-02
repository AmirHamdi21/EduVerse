import 'package:flutter/material.dart';

import '../../../common/utils/ta_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';

class TAStudentsTab extends StatefulWidget {
  const TAStudentsTab({
    super.key,
    required this.students,
    required this.isDark,
    required this.l10n,
    this.onRefreshRequested,
    this.emptyStateTitleOverride,
    this.emptyStateSubtitleOverride,
  });

  final List<SectionStudentModel> students;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback? onRefreshRequested;
  final String? emptyStateTitleOverride;
  final String? emptyStateSubtitleOverride;

  @override
  State<TAStudentsTab> createState() => _TAStudentsTabState();
}

class _TAStudentsTabState extends State<TAStudentsTab> {
  String _search = '';

  List<SectionStudentModel> get _filtered => _search.isEmpty
      ? widget.students
      : widget.students.where((student) {
          final query = _search.toLowerCase();
          return student.displayName.toLowerCase().contains(query) ||
              student.resolvedEmail.toLowerCase().contains(query) ||
              student.studentIdLabel.toLowerCase().contains(query) ||
              student.status.toLowerCase().contains(query);
        }).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefreshRequested?.call(),
      color: TACoursesTheme.brandPrimary,
      child: Column(
        children: <Widget>[
          _buildSearchBar(),
          _buildStudentCount(),
          Expanded(
            child: _filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                    children: <Widget>[_buildEmptyState()],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      return _TAStudentCard(
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
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: TACoursesTheme.cardBackground(widget.isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TACoursesTheme.borderColor(widget.isDark),
                ),
                boxShadow: <BoxShadow>[
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
                  color: TACoursesTheme.primaryText(widget.isDark),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '${widget.l10n.searchStudents}...',
                  hintStyle: TextStyle(
                    color: TACoursesTheme.mutedText(widget.isDark),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: TACoursesTheme.brandPrimary,
                    size: 20,
                  ),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: TACoursesTheme.mutedText(widget.isDark),
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
          if (widget.onRefreshRequested != null) ...<Widget>[
            const SizedBox(width: 10),
            InkWell(
              onTap: widget.onRefreshRequested,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      TACoursesTheme.brandPrimary.withValues(alpha: 0.14),
                      TACoursesTheme.accentBlue.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: TACoursesTheme.brandPrimary.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: TACoursesTheme.brandPrimary,
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
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  TACoursesTheme.brandPrimary.withValues(alpha: 0.1),
                  TACoursesTheme.brandPrimary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_filtered.length} ${widget.l10n.students}',
              style: const TextStyle(
                color: TACoursesTheme.brandPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
          children: <Widget>[
            Icon(
              Icons.person_search_rounded,
              size: 48,
              color: TACoursesTheme.mutedText(widget.isDark),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: TACoursesTheme.primaryText(widget.isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.students.isEmpty &&
                widget.emptyStateSubtitleOverride != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                widget.emptyStateSubtitleOverride!,
                style: TextStyle(
                  color: TACoursesTheme.secondaryText(widget.isDark),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ] else if (widget.students.isEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Students will appear here when enrollments are available.',
                style: TextStyle(
                  color: TACoursesTheme.secondaryText(widget.isDark),
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

class _TAStudentCard extends StatelessWidget {
  const _TAStudentCard({
    required this.student,
    required this.isDark,
    required this.l10n,
    required this.index,
  });

  final SectionStudentModel student;
  final bool isDark;
  final AppLocalizations l10n;
  final int index;

  static const List<Color> _avatarColors = <Color>[
    TACoursesTheme.brandPrimary,
    TACoursesTheme.accentBlue,
    TACoursesTheme.warningAmber,
    TACoursesTheme.accentTeal,
    TACoursesTheme.errorRed,
    TACoursesTheme.successGreen,
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
        color: TACoursesTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TACoursesTheme.borderColor(isDark)),
        boxShadow: <BoxShadow>[
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
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            _avatarColor,
                            _avatarColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: <BoxShadow>[
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
                        children: <Widget>[
                          Text(
                            student.displayName,
                            style: TextStyle(
                              color: TACoursesTheme.primaryText(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.resolvedEmail.isNotEmpty
                                ? student.resolvedEmail
                                : 'No email',
                            style: TextStyle(
                              color: TACoursesTheme.secondaryText(isDark),
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
                          color: TACoursesTheme.chipBackground(isDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: TACoursesTheme.mutedText(isDark),
                          size: 18,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: TACoursesTheme.cardBackground(isDark),
                      itemBuilder: (context) => <PopupMenuEntry<void>>[
                        _buildMenuItem(
                          Icons.email_outlined,
                          l10n.sendMessage,
                          TACoursesTheme.brandPrimary,
                        ),
                        _buildMenuItem(
                          Icons.grade_outlined,
                          l10n.viewGrades,
                          TACoursesTheme.warningAmber,
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
                    _buildInfoChip(
                      icon: Icons.badge_outlined,
                      label: student.studentIdLabel,
                    ),
                    _buildStatusChip(statusColor),
                    if (student.grade != null)
                      _buildInfoChip(
                        icon: Icons.analytics_outlined,
                        label: 'Grade: ${student.grade!.toStringAsFixed(1)}',
                        tint: TACoursesTheme.warningAmber,
                      ),
                    if (student.finalScore != null)
                      _buildInfoChip(
                        icon: Icons.emoji_events_outlined,
                        label:
                            'Score: ${student.finalScore!.toStringAsFixed(1)}',
                        tint: TACoursesTheme.accentTeal,
                      ),
                  ],
                ),
                if (student.courseCode != null ||
                    student.enrollmentDate != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TACoursesTheme.chipBackground(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: <Widget>[
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
      return TACoursesTheme.warningAmber;
    }
    if (normalized.contains('drop') || normalized.contains('inactive')) {
      return TACoursesTheme.errorRed;
    }
    return TACoursesTheme.successGreen;
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
        children: <Widget>[
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
    final color = tint ?? TACoursesTheme.brandPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: TACoursesTheme.secondaryText(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<void> _buildMenuItem(
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<void>(
      child: Row(
        children: <Widget>[
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
              color: isDark ? Colors.white : TACoursesTheme.lightText,
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
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
          color: TACoursesTheme.mutedText(isDark),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          color: TACoursesTheme.primaryText(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
