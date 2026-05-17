import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/attendance/admin_attendance_cubit.dart';
import '../../../bloc/attendance/admin_attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../services/api/attendance_service.dart';
import '../../../widgets/admin/dashboard/admin_drawer.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminAttendanceCubit>(
      create: (context) => AdminAttendanceCubit(
        attendanceService: context.read<AttendanceService>(),
      )..initialize(),
      child: const _AdminAttendanceBody(),
    );
  }
}

class _AdminAttendanceBody extends StatefulWidget {
  const _AdminAttendanceBody();

  @override
  State<_AdminAttendanceBody> createState() => _AdminAttendanceBodyState();
}

class _AdminAttendanceBodyState extends State<_AdminAttendanceBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          drawer: const AdminDrawer(),
          body: SafeArea(
            child: BlocConsumer<AdminAttendanceCubit, AdminAttendanceState>(
              listener: (context, state) {
                if (state.error != null && state.error!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: AdminColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final cubit = context.read<AdminAttendanceCubit>();

                return Column(
                  children: [
                    _buildHeader(isDark, cubit),
                    _buildSummary(isDark, state),
                    _buildTabs(isDark, state, cubit),
                    Expanded(
                      child:
                          state.isLoading &&
                              state.courses.isEmpty &&
                              state.students.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : _buildTabContent(isDark, state, cubit),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, AdminAttendanceCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AdminColors.darkCardBorder
                : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          Expanded(
            child: Text(
              'Attendance Manager',
              style: TextStyle(
                color: isDark ? AdminColors.darkText : AdminColors.lightText,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: cubit.initialize,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isDark, AdminAttendanceState state) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _statTile('Total', state.totalStudents.toString()),
              const SizedBox(width: 8),
              _statTile('Present', state.presentToday.toString()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statTile('Absent', state.absentToday.toString()),
              const SizedBox(width: 8),
              _statTile('Late', state.lateToday.toString()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Overall Attendance: ${state.overallRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(
    bool isDark,
    AdminAttendanceState state,
    AdminAttendanceCubit cubit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _tabButton(
            isDark: isDark,
            active: state.activeTab == AdminAttendanceTab.overview,
            label: 'Overview',
            onTap: () => cubit.setActiveTab(AdminAttendanceTab.overview),
          ),
          const SizedBox(width: 8),
          _tabButton(
            isDark: isDark,
            active: state.activeTab == AdminAttendanceTab.courses,
            label: 'Courses',
            onTap: () => cubit.setActiveTab(AdminAttendanceTab.courses),
          ),
          const SizedBox(width: 8),
          _tabButton(
            isDark: isDark,
            active: state.activeTab == AdminAttendanceTab.students,
            label: 'Students',
            onTap: () => cubit.setActiveTab(AdminAttendanceTab.students),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required bool isDark,
    required bool active,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AdminColors.primary
                : (isDark ? AdminColors.darkCard : AdminColors.lightCard),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightCardBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? AdminColors.darkText : AdminColors.lightText),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    bool isDark,
    AdminAttendanceState state,
    AdminAttendanceCubit cubit,
  ) {
    switch (state.activeTab) {
      case AdminAttendanceTab.overview:
        return _buildOverviewTab(isDark, state);
      case AdminAttendanceTab.courses:
        return _buildCoursesTab(isDark, state, cubit);
      case AdminAttendanceTab.students:
        return _buildStudentsTab(isDark, state, cubit);
    }
  }

  Widget _buildOverviewTab(bool isDark, AdminAttendanceState state) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionCard(
          isDark,
          title: 'Department Performance',
          child: Column(
            children: state.departmentStats.map((dep) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dep.department,
                          style: TextStyle(
                            color: isDark
                                ? AdminColors.darkText
                                : AdminColors.lightText,
                          ),
                        ),
                        Text(
                          '${dep.rate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (dep.rate / 100).clamp(0, 1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          isDark,
          title: 'Weekly Trends',
          child: state.weeklyTrends.isEmpty
              ? const Text('No trend data yet')
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: state.weeklyTrends
                      .map(
                        (trend) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Text(
                                  '${trend.rate.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: (trend.rate.clamp(0, 100) * 0.8) + 10,
                                  decoration: BoxDecoration(
                                    color: AdminColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  trend.label,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildCoursesTab(
    bool isDark,
    AdminAttendanceState state,
    AdminAttendanceCubit cubit,
  ) {
    final departments = <String>{'all'};
    for (final c in state.courses) {
      departments.add(c.department.toLowerCase());
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search course name or code',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: cubit.setCourseSearch,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: state.departmentFilter,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Department',
          ),
          items: departments
              .map(
                (d) => DropdownMenuItem<String>(
                  value: d,
                  child: Text(d == 'all' ? 'All Departments' : d),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) cubit.setDepartmentFilter(value);
          },
        ),
        const SizedBox(height: 12),
        ...state.filteredCourses.map(
          (course) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AdminColors.darkCardBorder
                    : AdminColors.lightCardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course.courseCode} - ${course.courseName}',
                  style: TextStyle(
                    color: isDark
                        ? AdminColors.darkText
                        : AdminColors.lightText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dept: ${course.department} • Section ${course.sectionId}',
                  style: TextStyle(
                    color: isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniChip(
                      'Present ${course.present}',
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 6),
                    _miniChip(
                      'Absent ${course.absent}',
                      const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    _miniChip('Late ${course.late}', const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rate: ${course.attendanceRate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsTab(
    bool isDark,
    AdminAttendanceState state,
    AdminAttendanceCubit cubit,
  ) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search student name, email, or id',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: cubit.setStudentSearch,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: state.statusFilter,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Risk Level',
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'low', child: Text('Low Risk')),
            DropdownMenuItem(value: 'medium', child: Text('Medium Risk')),
            DropdownMenuItem(value: 'high', child: Text('High Risk')),
          ],
          onChanged: (value) {
            if (value != null) cubit.setStatusFilter(value);
          },
        ),
        const SizedBox(height: 12),
        ...state.filteredStudents.map(
          (student) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AdminColors.darkCardBorder
                    : AdminColors.lightCardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    color: isDark
                        ? AdminColors.darkText
                        : AdminColors.lightText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.email.isEmpty
                      ? 'Student #${student.userId}'
                      : student.email,
                  style: TextStyle(
                    color: isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Attendance ${student.attendedClasses}/${student.totalClasses}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _riskColor(
                          student.riskLevel,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _riskLabel(student.riskLevel),
                        style: TextStyle(
                          fontSize: 11,
                          color: _riskColor(student.riskLevel),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionCard(
    bool isDark, {
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Color _riskColor(StudentRiskLevel level) {
    switch (level) {
      case StudentRiskLevel.low:
        return const Color(0xFF10B981);
      case StudentRiskLevel.medium:
        return const Color(0xFFF59E0B);
      case StudentRiskLevel.high:
        return const Color(0xFFEF4444);
    }
  }

  String _riskLabel(StudentRiskLevel level) {
    switch (level) {
      case StudentRiskLevel.low:
        return 'Low Risk';
      case StudentRiskLevel.medium:
        return 'Medium Risk';
      case StudentRiskLevel.high:
        return 'High Risk';
    }
  }
}
