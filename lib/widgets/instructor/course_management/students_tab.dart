import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import 'course_management_colors.dart';

/// Redesigned students tab with modern list and search
class StudentsTab extends StatefulWidget {
  final int totalStudents;
  final bool isDark;
  final AppLocalizations l10n;

  const StudentsTab({
    super.key,
    required this.totalStudents,
    required this.isDark,
    required this.l10n,
  });

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  String _search = '';

  List<_StudentData> get _students => List.generate(
        widget.totalStudents,
        (i) => _StudentData(
          name: 'Student ${i + 1}',
          email: 'student${i + 1}@university.edu',
          initials: 'S${i + 1}',
          color: _avatarColors[i % _avatarColors.length],
        ),
      );

  List<_StudentData> get _filtered => _search.isEmpty
      ? _students
      : _students
          .where(
              (s) => s.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  static const List<Color> _avatarColors = [
    CMColors.primary,
    CMColors.accent,
    CMColors.orange,
    CMColors.teal,
    CMColors.pink,
    CMColors.success,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildStudentCount(),
        Expanded(
          child: _filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    return _StudentCard(
                      student: _filtered[index],
                      isDark: widget.isDark,
                      l10n: widget.l10n,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
              color: Colors.black
                  .withValues(alpha: widget.isDark ? 0.15 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: TextStyle(
            color: CMColors.text(widget.isDark),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: '${widget.l10n.searchStudents}...',
            hintStyle: TextStyle(color: CMColors.textMutedColor(widget.isDark)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: CMColors.primary,
              size: 20,
            ),
            suffixIcon: _search.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: CMColors.textMutedColor(widget.isDark),
                        size: 18),
                    onPressed: () => setState(() => _search = ''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              style: TextStyle(
                color: CMColors.primary,
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
    return Center(
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
            'No students found',
            style: TextStyle(
              color: CMColors.text(widget.isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final _StudentData student;
  final bool isDark;
  final AppLocalizations l10n;

  const _StudentCard({
    required this.student,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CMColors.borderColor(isDark),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        student.color,
                        student.color.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: student.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      student.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          color: CMColors.text(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        student.email,
                        style: TextStyle(
                          color: CMColors.textSub(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action menu
                PopupMenuButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CMColors.surfaceColor(isDark),
                      borderRadius: BorderRadius.circular(8),
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
          ),
        ),
      ),
    );
  }

  PopupMenuItem _buildMenuItem(
      IconData icon, String label, Color color) {
    return PopupMenuItem(
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
}

class _StudentData {
  final String name;
  final String email;
  final String initials;
  final Color color;

  _StudentData({
    required this.name,
    required this.email,
    required this.initials,
    required this.color,
  });
}
