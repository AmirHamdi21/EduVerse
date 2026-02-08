import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../widgets/instructor/course_management/course_management_barrel.dart';

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
    _course = widget.course ?? _demoCourse();
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
          backgroundColor: CMColors.bg(isDark),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              CourseManagementAppBar(
                courseName: _course.name,
                courseCode: _course.code,
                isDark: isDark,
                onSettings: () => _showCourseSettings(context, isDark),
              ),
              SliverToBoxAdapter(
                child: CourseManagementHeader(
                  course: _course,
                  isDark: isDark,
                  l10n: l10n,
                  tabController: _tabController,
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(course: _course, isDark: isDark, l10n: l10n),
                AssignmentsTab(
                  assignments: _course.assignments,
                  isDark: isDark,
                  l10n: l10n,
                ),
                MaterialsTab(
                  materials: _course.materials,
                  isDark: isDark,
                  l10n: l10n,
                ),
                StudentsTab(
                  totalStudents: _course.totalStudents,
                  isDark: isDark,
                  l10n: l10n,
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(isDark, l10n),
        );
      },
    );
  }

  Widget _buildFAB(bool isDark, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddOptions(context, isDark, l10n),
      backgroundColor: CMColors.primary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        l10n.add,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
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
          color: CMColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: CMColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildSheetItem(
              ctx,
              Icons.edit_outlined,
              l10n.editCourse,
              CMColors.primary,
              isDark,
            ),
            _buildSheetItem(
              ctx,
              Icons.archive_outlined,
              l10n.archiveCourse,
              CMColors.warning,
              isDark,
            ),
            _buildSheetItem(
              ctx,
              Icons.delete_outline,
              l10n.delete,
              CMColors.error,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: CMColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildSheetItem(
              ctx,
              Icons.assignment_add,
              l10n.createAssignment,
              CMColors.primary,
              isDark,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.assignmentCreated),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: CMColors.primary,
                  ),
                );
              },
            ),
            _buildSheetItem(
              ctx,
              Icons.upload_file_rounded,
              l10n.uploadMaterial,
              CMColors.success,
              isDark,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.materialUploaded),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: CMColors.success,
                  ),
                );
              },
            ),
            _buildSheetItem(
              ctx,
              Icons.campaign_rounded,
              l10n.postAnnouncement,
              CMColors.warning,
              isDark,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: CMColors.text(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap ?? () => Navigator.pop(ctx),
    );
  }

  InstructorCourseModel _demoCourse() {
    return InstructorCourseModel(
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
}
