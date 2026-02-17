import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/courses/courses_barrel.dart';
import '../../../generated_l10n/app_localizations.dart';

/// Admin Course Management Screen
class AdminCourseManagementScreen extends StatefulWidget {
  const AdminCourseManagementScreen({super.key});

  @override
  State<AdminCourseManagementScreen> createState() =>
      _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState
    extends State<AdminCourseManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;
  String? _selectedDepartment;
  bool _isLoading = true;
  String? _errorMessage;
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      _courses = [
        CourseModel(
          id: '1',
          code: 'CS221',
          name: 'Advanced Data Structures',
          department: 'Computer Science',
          instructorName: 'Dr. Sarah Johnson',
          instructorInitials: 'SJ',
          taName: 'Mike Chen',
          taInitials: 'MC',
          studentCount: 126,
          labCount: 8,
          avgGrade: 82,
          status: 'healthy',
          aiInsight: 'High engagement, positive feedback',
          isActive: true,
          hasLabs: true,
        ),
        CourseModel(
          id: '2',
          code: 'CS102',
          name: 'Introduction to Programming',
          department: 'Computer Science',
          instructorName: 'Dr. Ahmed Hassan',
          instructorInitials: 'AH',
          taName: 'Sara Ali',
          taInitials: 'SA',
          studentCount: 245,
          labCount: 12,
          avgGrade: 78,
          status: 'healthy',
          isActive: true,
          hasLabs: true,
        ),
        CourseModel(
          id: '3',
          code: 'MATH201',
          name: 'Linear Algebra',
          department: 'Mathematics',
          instructorName: 'Dr. James Wilson',
          instructorInitials: 'JW',
          studentCount: 89,
          labCount: 0,
          avgGrade: 71,
          status: 'warning',
          aiInsight: 'Engagement dropping, consider intervention',
          isActive: true,
          hasLabs: false,
        ),
        CourseModel(
          id: '4',
          code: 'PHY101',
          name: 'Physics Fundamentals',
          department: 'Physics',
          instructorName: null,
          taName: 'John Smith',
          taInitials: 'JS',
          studentCount: 156,
          labCount: 6,
          avgGrade: 65,
          status: 'critical',
          aiInsight: 'No instructor assigned - urgent',
          isActive: true,
          hasLabs: true,
        ),
        CourseModel(
          id: '5',
          code: 'CS301',
          name: 'Machine Learning',
          department: 'Computer Science',
          instructorName: 'Dr. Emily Chen',
          instructorInitials: 'EC',
          studentCount: 67,
          labCount: 4,
          avgGrade: 88,
          status: 'healthy',
          isActive: true,
          hasLabs: true,
        ),
        CourseModel(
          id: '6',
          code: 'ENG201',
          name: 'Technical Writing',
          department: 'English',
          instructorName: 'Prof. Maria Garcia',
          instructorInitials: 'MG',
          taName: 'Alex Brown',
          taInitials: 'AB',
          studentCount: 45,
          labCount: 0,
          avgGrade: 85,
          status: 'healthy',
          isActive: false,
          hasLabs: false,
        ),
      ];

      _applyFilters();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        // Filter by selected filter
        switch (_selectedFilter) {
          case 'active':
            if (!course.isActive) return false;
            break;
          case 'inactive':
            if (course.isActive) return false;
            break;
          case 'needs_instructor':
            if (course.instructorName != null) return false;
            break;
          case 'needs_ta':
            if (course.taName != null) return false;
            break;
          case 'ai_flagged':
            if (course.status == 'healthy') return false;
            break;
          case 'lab_based':
            if (!course.hasLabs) return false;
            break;
        }

        // Search filter
        final query = _searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          return course.name.toLowerCase().contains(query) ||
              course.code.toLowerCase().contains(query) ||
              course.department.toLowerCase().contains(query);
        }

        return true;
      }).toList();

      // Apply department filter
      if (_selectedDepartment != null) {
        _filteredCourses = _filteredCourses
            .where((c) => c.department == _selectedDepartment)
            .toList();
      }

      // Apply sorting
      _filteredCourses.sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'name':
            comparison = a.name.compareTo(b.name);
            break;
          case 'code':
            comparison = a.code.compareTo(b.code);
            break;
          case 'students':
            comparison = a.studentCount.compareTo(b.studentCount);
            break;
          case 'grade':
            comparison = a.avgGrade.compareTo(b.avgGrade);
            break;
          default:
            comparison = a.name.compareTo(b.name);
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  List<String> _getDepartments() {
    return _courses.map((c) => c.department).toSet().toList()..sort();
  }

  Map<String, int> _getFilterCounts() {
    return {
      'all': _courses.length,
      'active': _courses.where((c) => c.isActive).length,
      'inactive': _courses.where((c) => !c.isActive).length,
      'needs_instructor': _courses
          .where((c) => c.instructorName == null)
          .length,
      'needs_ta': _courses.where((c) => c.taName == null).length,
      'ai_flagged': _courses.where((c) => c.status != 'healthy').length,
      'lab_based': _courses.where((c) => c.hasLabs).length,
    };
  }

  void _showAddCourseDialog(bool isDark, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        title: Text(
          l10n.addCourse,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: l10n.courseCode,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.courseName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.courseCreated),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(
    CourseModel course,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AdminColors.darkDivider
                    : AdminColors.lightDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.assignStaff,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${course.code} - ${course.name}',
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAssignOption(
                    icon: Icons.person_rounded,
                    label: l10n.assignInstructor,
                    value: course.instructorName ?? l10n.notAssigned,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.instructorAssigned),
                          backgroundColor: AdminColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildAssignOption(
                    icon: Icons.support_agent_rounded,
                    label: l10n.assignTA,
                    value: course.taName ?? l10n.notAssigned,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.taAssigned),
                          backgroundColor: AdminColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignOption({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkCard.withValues(alpha: 0.5)
                : AdminColors.lightBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightDivider,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AdminColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCourseDialog(
    CourseModel course,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController(text: course.name);
    final codeController = TextEditingController(text: course.code);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        title: Text(
          l10n.editCourse,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: l10n.courseCode,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.courseName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.courseUpdated),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: _isLoading
                  ? _buildLoadingState(isDark)
                  : _errorMessage != null
                  ? _buildErrorState(isDark, l10n)
                  : _buildContent(isDark, l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    final aiInsight = _courses.where((c) => c.taName == null).length;

    return RefreshIndicator(
      onRefresh: _loadCourses,
      color: AdminColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CourseManagementAppBar(
              isDark: isDark,
              totalCourses: _courses.length,
              searchController: _searchController,
              onSearchChanged: (_) => _applyFilters(),
              onAddCourse: () => context.push('/admin/courses/add'),
              sortBy: _sortBy,
              sortAscending: _sortAscending,
              onSortChanged: (sort) {
                setState(() {
                  if (_sortBy == sort) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortBy = sort;
                    _sortAscending = true;
                  }
                });
                _applyFilters();
              },
              departments: _getDepartments(),
              selectedDepartment: _selectedDepartment,
              onDepartmentChanged: (dept) {
                setState(() {
                  _selectedDepartment = dept;
                });
                _applyFilters();
              },
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: CourseFilters(
              isDark: isDark,
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
                _applyFilters();
              },
              filterCounts: _getFilterCounts(),
            ),
          ),
          if (aiInsight > 0) ...[
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: CourseAIInsight(
                isDark: isDark,
                insight: '$aiInsight ${l10n.coursesNoTA}',
                onAction: () {
                  setState(() {
                    _selectedFilter = 'needs_ta';
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: CourseStatistics(
              isDark: isDark,
              totalCourses: _courses.length,
              activeCourses: _courses.where((c) => c.isActive).length,
              totalStudents: _courses.fold(0, (sum, c) => sum + c.studentCount),
              unassignedCourses: _courses
                  .where((c) => c.instructorName == null || c.taName == null)
                  .length,
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          if (_filteredCourses.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState(isDark, l10n))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final course = _filteredCourses[index];
                return CourseCard(
                  isDark: isDark,
                  course: course,
                  onEdit: () => _showEditCourseDialog(course, isDark, l10n),
                  onAssign: () => _showAssignDialog(course, isDark, l10n),
                  onViewLabs: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.viewingLabs} ${course.name}'),
                        backgroundColor: AdminColors.accent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onViewDetails: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.viewingDetails} ${course.name}'),
                        backgroundColor: AdminColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }, childCount: _filteredCourses.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AdminColors.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading courses...',
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AdminColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.somethingWentWrong,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCourses,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                color: AdminColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noCoursesFound,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noCoursesFoundDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCourseDialog(isDark, l10n),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addCourse),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
