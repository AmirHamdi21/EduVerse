import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';

class CourseManagementScreen extends StatefulWidget {
  final InstructorCourseModel? course;

  const CourseManagementScreen({super.key, this.course});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late InstructorCourseModel _course;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _course = widget.course ??
        InstructorCourseModel(
          id: 'demo',
          name: 'Operating Systems',
          code: 'CS101',
          description: 'Introduction to Operating Systems concepts',
          totalStudents: 45,
          newItems: 3,
          activeQuizzes: 2,
          colorValue: 0xFF155CFB,
          isActive: true,
          semester: 'Fall 2025',
          assignments: [
            AssignmentModel(
              id: '1',
              title: 'Process Scheduling',
              dueDate: DateTime.now().add(const Duration(days: 3)),
              submissionsCount: 28,
              gradedCount: 15,
            ),
            AssignmentModel(
              id: '2',
              title: 'Memory Management',
              dueDate: DateTime.now().add(const Duration(days: 7)),
              submissionsCount: 15,
              gradedCount: 0,
            ),
          ],
          materials: [
            MaterialModel(id: '1', title: 'Week 1 - Introduction', type: 'pdf'),
            MaterialModel(id: '2', title: 'Week 2 - Processes', type: 'pdf'),
            MaterialModel(id: '3', title: 'Lab Session Recording', type: 'video'),
          ],
          announcements: [
            AnnouncementModel(
              id: '1',
              title: 'Midterm Schedule',
              content: 'Midterm exam will be held on Week 8',
              postedAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _course.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _course.code,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                onPressed: () => _showCourseSettings(context, isDark),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF155CFB),
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              indicatorColor: const Color(0xFF155CFB),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(text: l10n.overview),
                Tab(text: l10n.courseAssignments),
                Tab(text: l10n.courseMaterials),
                Tab(text: l10n.courseStudents),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isDark, l10n),
              _buildAssignmentsTab(isDark, l10n),
              _buildMaterialsTab(isDark, l10n),
              _buildStudentsTab(isDark, l10n),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddOptions(context, isDark, l10n),
            backgroundColor: const Color(0xFF155CFB),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l10n.add, style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course info card
          _buildCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(_course.colorValue),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _course.code.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _course.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_course.code} • ${_course.semester}',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _course.isActive
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _course.isActive ? l10n.activeLabel : l10n.archived,
                        style: TextStyle(
                          color: _course.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _course.description,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  isDark: isDark,
                  icon: Icons.people_rounded,
                  color: const Color(0xFF155CFB),
                  value: _course.totalStudents.toString(),
                  label: l10n.students,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  isDark: isDark,
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFFF59E0B),
                  value: _course.assignments.length.toString(),
                  label: l10n.courseAssignments,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  isDark: isDark,
                  icon: Icons.folder_rounded,
                  color: const Color(0xFF10B981),
                  value: _course.materials.length.toString(),
                  label: l10n.courseMaterials,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent activity
          Text(
            l10n.recentActivity,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                _buildActivityItem(
                  isDark: isDark,
                  icon: Icons.assignment_turned_in_rounded,
                  color: const Color(0xFF10B981),
                  title: '28 students submitted Process Scheduling',
                  time: '2 hours ago',
                ),
                const Divider(height: 24),
                _buildActivityItem(
                  isDark: isDark,
                  icon: Icons.announcement_rounded,
                  color: const Color(0xFF155CFB),
                  title: 'New announcement posted',
                  time: '2 days ago',
                ),
                const Divider(height: 24),
                _buildActivityItem(
                  isDark: isDark,
                  icon: Icons.upload_file_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'Lab Session Recording uploaded',
                  time: '3 days ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab(bool isDark, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _course.assignments.length,
      itemBuilder: (context, index) {
        final assignment = _course.assignments[index];
        final progress = assignment.gradingProgress;
        final isOverdue = assignment.dueDate.isBefore(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16213E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOverdue ? l10n.late : l10n.activeLabel,
                      style: TextStyle(
                        color: isOverdue
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.dueDate}: ${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF155CFB)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${assignment.gradedCount}/${assignment.submissionsCount}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/instructor/grading'),
                      icon: const Icon(Icons.grading, size: 16),
                      label: Text(l10n.grade),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF155CFB),
                        side: const BorderSide(color: Color(0xFF155CFB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility, size: 16),
                      label: Text(l10n.viewDetails),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF155CFB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialsTab(bool isDark, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _course.materials.length,
      itemBuilder: (context, index) {
        final material = _course.materials[index];
        final icon = material.type == 'pdf'
            ? Icons.picture_as_pdf_rounded
            : material.type == 'video'
                ? Icons.play_circle_rounded
                : Icons.insert_drive_file_rounded;
        final color = material.type == 'pdf'
            ? const Color(0xFFEF4444)
            : material.type == 'video'
                ? const Color(0xFF155CFB)
                : const Color(0xFF10B981);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16213E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              material.title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              material.type.toUpperCase(),
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsTab(bool isDark, AppLocalizations l10n) {
    final students = List.generate(
      _course.totalStudents,
      (i) => {
        'name': 'Student ${i + 1}',
        'email': 'student${i + 1}@university.edu',
        'avatar': '',
      },
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16213E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF155CFB).withValues(alpha: 0.1),
              child: Text(
                student['name']![0],
                style: const TextStyle(
                  color: Color(0xFF155CFB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              student['name']!,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              student['email']!,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            trailing: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.sendMessage),
                    ],
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.grade_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.viewGrades),
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

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatBox({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCourseSettings(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
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
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFF155CFB)),
              title: Text(l10n.editCourse),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Color(0xFFF59E0B)),
              title: Text(l10n.archiveCourse),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              title: Text(l10n.delete, style: const TextStyle(color: Color(0xFFEF4444))),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context, bool isDark, AppLocalizations l10n) {
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
          children: [
            ListTile(
              leading: const Icon(Icons.assignment_add, color: Color(0xFF155CFB)),
              title: Text(l10n.createAssignment),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.assignmentCreated)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Color(0xFF10B981)),
              title: Text(l10n.uploadMaterial),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.materialUploaded)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: Color(0xFFF59E0B)),
              title: Text(l10n.postAnnouncement),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
