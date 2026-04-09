import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminQuickActionsGrid extends StatelessWidget {
  const AdminQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AdminColors.darkCard.withOpacity(0.8),
                      AdminColors.darkCard.withOpacity(0.6),
                    ]
                  : [
                      const Color(0xFFEFF6FF).withOpacity(0.8),
                      const Color(0xFFECFEFF).withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightCardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flash_on_rounded,
                    color: AdminColors.getTextColor(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.quickAdminActions,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildQuickActionItem(
                    context,
                    isDark: isDark,
                    title: l10n.addUser,
                    icon: Icons.person_add_rounded,
                    gradient: AdminColors.primaryGradient,
                    onTap: () => context.push('/admin/users/add'),
                  ),
                  _buildQuickActionItem(
                    context,
                    isDark: isDark,
                    title: l10n.addCourse,
                    icon: Icons.add_box_rounded,
                    gradient: AdminColors.purpleGradient,
                    onTap: () => context.push('/admin/courses/add'),
                  ),
                  _buildQuickActionItem(
                    context,
                    isDark: isDark,
                    title: l10n.announcement,
                    icon: Icons.campaign_rounded,
                    gradient: AdminColors.cyanGradient,
                    onTap: () => context.push('/admin/notifications'),
                  ),
                  _buildQuickActionItem(
                    context,
                    isDark: isDark,
                    title: l10n.assignInstructor,
                    icon: Icons.assignment_ind_rounded,
                    gradient: AdminColors.greenGradient,
                    onTap: () => context.push('/admin/staff'),
                  ),
                  _buildQuickActionItem(
                    context,
                    isDark: isDark,
                    title: l10n.viewReports,
                    icon: Icons.analytics_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    onTap: () => context.push('/admin/analytics'),
                  ),
                  _buildQuickActionItem(
                    context,
                    isDark: isDark,
                    title: l10n.systemSettings,
                    icon: Icons.settings_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF64748B), Color(0xFF475569)],
                    ),
                    onTap: () => context.push('/admin/settings'),
                  ),
                  _buildQuickActionItem(
                    context,
                    isDark: isDark,
                    title: 'Discussions',
                    icon: Icons.forum_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                    ),
                    onTap: () => context.push('/admin/discussions'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required bool isDark,
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AdminColors.darkCard.withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AdminColors.darkCardBorder
                : AdminColors.lightCardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Student';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.addUser,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    labelStyle: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AdminColors.getDividerColor(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(color: AdminColors.getTextColor(isDark)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    labelStyle: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AdminColors.getDividerColor(isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(color: AdminColors.getTextColor(isDark)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: l10n.selectRole,
                    labelStyle: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AdminColors.getDividerColor(isDark),
                      ),
                    ),
                  ),
                  dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
                  style: TextStyle(color: AdminColors.getTextColor(isDark)),
                  items: ['Student', 'Instructor', 'TA', 'Admin'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.addUser} ${l10n.success}'),
                    backgroundColor: AdminColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCourseDialog(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AdminColors.purpleGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_box_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.addCourse,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.courseName,
                  labelStyle: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AdminColors.getDividerColor(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(color: AdminColors.getTextColor(isDark)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: l10n.courseCode,
                  labelStyle: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AdminColors.getDividerColor(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(color: AdminColors.getTextColor(isDark)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.addCourse} ${l10n.success}'),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementDialog(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AdminColors.cyanGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.announcement,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  labelStyle: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AdminColors.getDividerColor(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.accent,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(color: AdminColors.getTextColor(isDark)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.message,
                  labelStyle: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AdminColors.getDividerColor(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AdminColors.accent,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(color: AdminColors.getTextColor(isDark)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.announcement} ${l10n.success}'),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }

  void _showAssignInstructorDialog(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    String? selectedCourse;
    String? selectedInstructor;

    final courses = [
      'CS101 - Intro to Programming',
      'CS201 - Data Structures',
      'CS301 - Algorithms',
    ];
    final instructors = [
      'Dr. Sarah Johnson',
      'Prof. Michael Chen',
      'Dr. Emily Williams',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AdminColors.greenGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_ind_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.assignInstructor,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCourse,
                  decoration: InputDecoration(
                    labelText: l10n.selectCourse,
                    labelStyle: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AdminColors.getDividerColor(isDark),
                      ),
                    ),
                  ),
                  dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
                  style: TextStyle(color: AdminColors.getTextColor(isDark)),
                  items: courses.map((course) {
                    return DropdownMenuItem(
                      value: course,
                      child: Text(course, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCourse = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedInstructor,
                  decoration: InputDecoration(
                    labelText: l10n.selectInstructor,
                    labelStyle: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AdminColors.getDividerColor(isDark),
                      ),
                    ),
                  ),
                  dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
                  style: TextStyle(color: AdminColors.getTextColor(isDark)),
                  items: instructors.map((instructor) {
                    return DropdownMenuItem(
                      value: instructor,
                      child: Text(
                        instructor,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedInstructor = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.assignInstructor} ${l10n.success}'),
                    backgroundColor: AdminColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
