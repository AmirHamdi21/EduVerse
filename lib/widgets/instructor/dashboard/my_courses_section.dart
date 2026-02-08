import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';

class MyCoursesSection extends StatelessWidget {
  final List<InstructorCourseModel> courses;

  const MyCoursesSection({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.myCourses,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/instructor/courses'),
                  child: Text(
                    l10n.viewAll,
                    style: const TextStyle(
                      color: Color(0xFF155CFB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...courses.take(4).map((course) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CourseCard(course: course, isDark: isDark, l10n: l10n),
                )),
          ],
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final InstructorCourseModel course;
  final bool isDark;
  final AppLocalizations l10n;

  const _CourseCard({
    required this.course,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: code badge + pending count
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(course.colorValue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.code,
                  style: TextStyle(
                    color: Color(course.colorValue),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (course.assignments.any((a) => !a.isGraded))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending_actions, color: Color(0xFFF59E0B), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${course.assignments.where((a) => !a.isGraded).length} ${l10n.pending}',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Course name
          Text(
            course.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          // Student count
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${course.totalStudents} ${l10n.students}',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: course.progress / 100,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(course.colorValue)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${course.progress}%',
                style: TextStyle(
                  color: Color(course.colorValue),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Badges row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (course.newItems > 0)
                _buildBadge(
                  Icons.fiber_new_rounded,
                  '${course.newItems} ${l10n.newItems}',
                  const Color(0xFF10B981),
                ),
              if (course.activeQuizzes > 0)
                _buildBadge(
                  Icons.quiz_outlined,
                  '${course.activeQuizzes} ${l10n.activeQuizzes}',
                  const Color(0xFF155CFB),
                ),
              if (course.unreadMessages > 0)
                _buildBadge(
                  Icons.message_outlined,
                  '${course.unreadMessages} ${l10n.messages}',
                  const Color(0xFFEF4444),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: l10n.manage,
                  color: const Color(0xFF155CFB),
                  isDark: isDark,
                  onTap: () => context.push(
                    '/instructor/course-management',
                    extra: course,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: l10n.materials,
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  isDark: isDark,
                  isOutlined: true,
                  onTap: () => _showMaterialsSheet(context, course),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                  color: isDark ? const Color(0xFF16213E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) => _handleMenuAction(context, value, course, l10n),
                  itemBuilder: (ctx) => [
                    _menuItem(Icons.announcement_outlined, l10n.announcements),
                    _menuItem(Icons.analytics_outlined, l10n.analytics),
                    _menuItem(Icons.settings_outlined, l10n.settings),
                    _menuItem(Icons.archive_outlined, l10n.archive),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(IconData icon, String text) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white70 : Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, String action, InstructorCourseModel course, AppLocalizations l10n) {
    if (action == l10n.archive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${course.name} ${l10n.archived}'),
          backgroundColor: const Color(0xFF155CFB),
        ),
      );
    } else if (action == l10n.analytics) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.analyticsComingSoon)),
      );
    } else if (action == l10n.announcements) {
      _showAnnouncementsSheet(context, course, l10n);
    }
  }

  void _showMaterialsSheet(BuildContext context, InstructorCourseModel course) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${course.name} - ${l10n.materials}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (course.materials.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open,
                          size: 48, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noMaterialsYet,
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...course.materials.map((m) => ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF155CFB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getMaterialIcon(m.type),
                        color: const Color(0xFF155CFB),
                      ),
                    ),
                    title: Text(
                      m.title,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    subtitle: Text(
                      '${m.type} • ${m.fileSize}',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.download,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementsSheet(
      BuildContext context, InstructorCourseModel course, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.announcements,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.announcementPosted)),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.newAnnouncement),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF155CFB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (course.announcements.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.noAnnouncementsYet,
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              )
            else
              ...course.announcements.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.content,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.video_library;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isDark,
    this.isOutlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(8),
            border: isOutlined ? Border.all(color: color) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isOutlined
                    ? (isDark ? Colors.white70 : Colors.grey[700])
                    : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
