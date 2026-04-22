import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/roster/roster_cubit.dart';
import '../../../bloc/roster/roster_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';

class InstructorRosterScreen extends StatelessWidget {
  const InstructorRosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RosterCubit(enrollmentService: context.read<EnrollmentService>())
            ..loadCourses(),
      child: const _InstructorRosterView(),
    );
  }
}

class _InstructorRosterView extends StatelessWidget {
  const _InstructorRosterView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: SafeArea(
            child: BlocBuilder<RosterCubit, RosterState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () => context.read<RosterCubit>().refresh(),
                  color: InstructorColors.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ── App Bar ──
                      _buildAppBar(context, isDark),

                      // ── Gradient Header Card ──
                      SliverToBoxAdapter(
                        child: _buildHeaderCard(context, isDark, state),
                      ),

                      // ── Course Filter Chips ──
                      if (state.coursesStatus == RosterStatus.loaded &&
                          state.courses.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildCourseFilterChips(
                            context,
                            isDark,
                            state,
                          ),
                        ),

                      // ── Search Bar ──
                      if (state.selectedSectionId != null)
                        SliverToBoxAdapter(
                          child: _buildSearchBar(context, isDark, state),
                        ),

                      // ── Students List ──
                      _buildStudentsList(context, isDark, state),

                      // Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: InstructorColors.textPrimaryColor(isDark),
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Roster',
        style: TextStyle(
          color: InstructorColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    bool isDark,
    RosterState state,
  ) {
    final gradient = isDark
        ? InstructorColors.darkHeaderGradient
        : InstructorColors.headerGradient;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: InstructorColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Roster',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage & view enrolled students',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            children: [
              _buildStatPill(
                icon: Icons.school_rounded,
                label: 'Courses',
                value: '${state.courses.length}',
              ),
              const SizedBox(width: 10),
              _buildStatPill(
                icon: Icons.groups_rounded,
                label: 'Students',
                value: '${state.totalStudents}',
              ),
              const SizedBox(width: 10),
              _buildStatPill(
                icon: Icons.class_rounded,
                label: 'Sections',
                value: '${state.courses.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseFilterChips(
    BuildContext context,
    bool isDark,
    RosterState state,
  ) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];
          final isSelected = course.sectionId == state.selectedSectionId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                '${course.course.code} - ${course.section.sectionNumber}',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : InstructorColors.textPrimaryColor(isDark),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              avatar: isSelected
                  ? null
                  : Icon(
                      Icons.book_rounded,
                      size: 16,
                      color: InstructorColors.primary,
                    ),
              selectedColor: InstructorColors.primary,
              backgroundColor: InstructorColors.cardColor(isDark),
              side: BorderSide(
                color: isSelected
                    ? InstructorColors.primary
                    : InstructorColors.borderColor(isDark),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              showCheckmark: false,
              onSelected: (_) {
                context.read<RosterCubit>().selectCourse(course.sectionId);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark, RosterState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => context.read<RosterCubit>().setSearchQuery(v),
          decoration: InputDecoration(
            hintText: 'Search students by name or email...',
            hintStyle: TextStyle(
              color: InstructorColors.textTertiaryColor(isDark),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: InstructorColors.textTertiaryColor(isDark),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsList(
    BuildContext context,
    bool isDark,
    RosterState state,
  ) {
    // Loading courses
    if (state.coursesStatus == RosterStatus.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Error loading courses
    if (state.coursesStatus == RosterStatus.error) {
      return SliverFillRemaining(
        child: _buildErrorState(context, isDark, state.errorMessage),
      );
    }

    // No courses
    if (state.courses.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyCoursesState(isDark));
    }

    // No section selected
    if (state.selectedSectionId == null) {
      return SliverFillRemaining(child: _buildSelectCourseState(isDark));
    }

    // Loading students
    if (state.studentsStatus == RosterStatus.loading) {
      return SliverToBoxAdapter(child: _buildLoadingSkeletons(isDark));
    }

    // Error loading students
    if (state.studentsStatus == RosterStatus.error) {
      return SliverFillRemaining(
        child: _buildErrorState(context, isDark, state.errorMessage),
      );
    }

    final students = state.filteredStudents;

    if (students.isEmpty) {
      return SliverFillRemaining(
        child: _buildNoStudentsState(isDark, state.searchQuery.isNotEmpty),
      );
    }

    // Student count header
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: InstructorColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${students.length} student${students.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: InstructorColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (state.selectedCourse != null)
                  Text(
                    state.selectedCourse!.course.name,
                    style: TextStyle(
                      color: InstructorColors.textSecondaryColor(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          );
        }

        final student = students[index - 1];
        return _buildStudentCard(isDark, student, index - 1);
      }, childCount: students.length + 1),
    );
  }

  Widget _buildStudentCard(
    bool isDark,
    SectionStudentModel student,
    int index,
  ) {
    // Color-coded avatar colors
    final avatarColors = [
      InstructorColors.primary,
      InstructorColors.accent,
      InstructorColors.teal,
      InstructorColors.orange,
      InstructorColors.pink,
      InstructorColors.cyan,
      InstructorColors.success,
    ];
    final avatarColor = avatarColors[index % avatarColors.length];

    final initials = _getInitials(student.displayName);
    final statusColor = _getStatusColor(student.status);
    final statusLabel = _formatStatus(student.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [avatarColor, avatarColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: avatarColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        student.displayName,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (student.email != null)
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: InstructorColors.textTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.email!,
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                // Grade row
                Row(
                  children: [
                    if (student.grade != null) ...[
                      _buildInfoChip(
                        isDark,
                        Icons.grade_rounded,
                        'Grade: ${student.grade!.toStringAsFixed(1)}',
                        InstructorColors.accent,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (student.finalScore != null)
                      _buildInfoChip(
                        isDark,
                        Icons.bar_chart_rounded,
                        'Score: ${student.finalScore!.toStringAsFixed(1)}',
                        InstructorColors.teal,
                      ),
                    if (student.enrollmentDate != null) ...[
                      const Spacer(),
                      Text(
                        _formatDate(student.enrollmentDate!),
                        style: TextStyle(
                          color: InstructorColors.textTertiaryColor(isDark),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(bool isDark, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeletons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 90,
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: InstructorColors.borderColor(
                  isDark,
                ).withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: InstructorColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyCoursesState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 48,
              color: InstructorColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Courses Found',
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You are not assigned to any courses yet.',
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCourseState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 48,
            color: InstructorColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a Course',
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a course chip above to view its students.',
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStudentsState(bool isDark, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.person_off_rounded,
            size: 48,
            color: InstructorColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No Results Found' : 'No Students Enrolled',
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term.'
                : 'No students are enrolled in this section.',
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    String? errorMessage,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: InstructorColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? 'An unexpected error occurred.',
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.read<RosterCubit>().refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'enrolled':
      case 'active':
        return InstructorColors.success;
      case 'dropped':
      case 'withdrawn':
        return InstructorColors.error;
      case 'waitlisted':
        return InstructorColors.warning;
      case 'completed':
        return InstructorColors.info;
      default:
        return InstructorColors.textSecondary;
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
