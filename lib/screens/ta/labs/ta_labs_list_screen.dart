import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

class TALabsListScreen extends StatefulWidget {
  const TALabsListScreen({super.key});

  @override
  State<TALabsListScreen> createState() => _TALabsListScreenState();
}

class _TALabsListScreenState extends State<TALabsListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<TACourseWithLabs> _coursesWithLabs = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadLabs();
  }

  Future<void> _loadLabs() async {
    setState(() => _isLoading = true);

    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock data organized by courses
    _coursesWithLabs = [
      TACourseWithLabs(
        courseId: '1',
        courseCode: 'CS101',
        courseName: 'Operating Systems',
        instructor: 'Dr. Ahmed Mohamed',
        color: TAColors.primary,
        labs: [
          TALabListItem(
            id: '1',
            title: 'Lab 1: Process Management',
            status: 'closed',
            submissionsCount: 118,
            totalStudents: 120,
            dueDate: 'Oct 14, 2025',
          ),
          TALabListItem(
            id: '2',
            title: 'Lab 2: Thread Synchronization',
            status: 'closed',
            submissionsCount: 115,
            totalStudents: 120,
            dueDate: 'Oct 21, 2025',
          ),
          TALabListItem(
            id: '3',
            title: 'Lab 3: Process Synchronization',
            status: 'active',
            submissionsCount: 45,
            totalStudents: 120,
            dueDate: 'Oct 28, 2025',
            pendingReview: 12,
          ),
        ],
      ),
      TACourseWithLabs(
        courseId: '2',
        courseCode: 'CS201',
        courseName: 'Data Structures',
        instructor: 'Dr. Sara Ali',
        color: TAColors.teal,
        labs: [
          TALabListItem(
            id: '4',
            title: 'Lab 1: Linked Lists',
            status: 'closed',
            submissionsCount: 92,
            totalStudents: 95,
            dueDate: 'Oct 10, 2025',
          ),
          TALabListItem(
            id: '5',
            title: 'Lab 2: Binary Trees',
            status: 'active',
            submissionsCount: 67,
            totalStudents: 95,
            dueDate: 'Oct 24, 2025',
            pendingReview: 8,
          ),
        ],
      ),
      TACourseWithLabs(
        courseId: '3',
        courseCode: 'CS301',
        courseName: 'Database Systems',
        instructor: 'Dr. Mohamed Hassan',
        color: TAColors.warning,
        labs: [
          TALabListItem(
            id: '6',
            title: 'Lab 1: SQL Basics',
            status: 'active',
            submissionsCount: 55,
            totalStudents: 80,
            dueDate: 'Oct 30, 2025',
            pendingReview: 5,
          ),
        ],
      ),
    ];

    setState(() => _isLoading = false);
  }

  List<TACourseWithLabs> get _filteredCourses {
    if (_selectedFilter == 'all') return _coursesWithLabs;

    return _coursesWithLabs.map((course) {
      final filteredLabs = course.labs.where((lab) {
        if (_selectedFilter == 'active') return lab.status == 'active';
        if (_selectedFilter == 'pending') return (lab.pendingReview ?? 0) > 0;
        return true;
      }).toList();
      return TACourseWithLabs(
        courseId: course.courseId,
        courseCode: course.courseCode,
        courseName: course.courseName,
        instructor: course.instructor,
        color: course.color,
        labs: filteredLabs,
      );
    }).where((course) => course.labs.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: TADrawer(
            currentRoute: '/ta/labs',
            isDark: isDark,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadLabs,
              color: TAColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark, l10n),
                  _buildFilterChips(isDark, l10n),
                  _buildContent(isDark, l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        l10n.taLabsTitle,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _buildFilterChip(
              label: l10n.taLabFilterAll,
              value: 'all',
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: l10n.taLabFilterActive,
              value: 'active',
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: l10n.taLabFilterPendingReview,
              value: 'pending',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? TAColors.primary : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? TAColors.primary : TAColors.borderColor(isDark),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: TAColors.primary),
        ),
      );
    }

    if (_filteredCourses.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(isDark, l10n),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = _filteredCourses[index];
            return _buildCourseLabsCard(course, isDark, l10n);
          },
          childCount: _filteredCourses.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.science_rounded,
              size: 48,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.taLabNoLabs,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taLabNoLabsDesc,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseLabsCard(TACourseWithLabs course, bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  course.color.withValues(alpha: isDark ? 0.25 : 0.15),
                  course.color.withValues(alpha: isDark ? 0.1 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      course.courseCode.replaceAll(RegExp(r'[^A-Z]'), ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.courseCode,
                        style: TextStyle(
                          color: course.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        course.courseName,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        course.instructor,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: course.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${course.labs.length} ${l10n.taLabsCount}',
                    style: TextStyle(
                      color: course.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Labs List
          ...course.labs.asMap().entries.map((entry) {
            final index = entry.key;
            final lab = entry.value;
            final isLast = index == course.labs.length - 1;

            return Column(
              children: [
                _buildLabItem(lab, isDark, l10n),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLabItem(TALabListItem lab, bool isDark, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/ta/lab/${lab.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getStatusColor(lab.status).withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.science_rounded,
                  color: _getStatusColor(lab.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab.title,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 14,
                          color: TAColors.textTertiaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lab.submissionsCount}/${lab.totalStudents}',
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: TAColors.textTertiaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lab.dueDate,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(lab.status, l10n),
                  if (lab.pendingReview != null && lab.pendingReview! > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: TAColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${lab.pendingReview} ${l10n.taLabPendingReview}',
                        style: TextStyle(
                          color: TAColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: TAColors.textTertiaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return TAColors.success;
      case 'upcoming':
        return TAColors.info;
      case 'closed':
        return TAColors.textSecondary;
      default:
        return TAColors.primary;
    }
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    final color = _getStatusColor(status);
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        label = l10n.taLabActive;
        break;
      case 'closed':
        label = l10n.taLabClosed;
        break;
      default:
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class TACourseWithLabs {
  final String courseId;
  final String courseCode;
  final String courseName;
  final String instructor;
  final Color color;
  final List<TALabListItem> labs;

  TACourseWithLabs({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.instructor,
    required this.color,
    required this.labs,
  });
}

class TALabListItem {
  final String id;
  final String title;
  final String status;
  final int submissionsCount;
  final int totalStudents;
  final String dueDate;
  final int? pendingReview;

  TALabListItem({
    required this.id,
    required this.title,
    required this.status,
    required this.submissionsCount,
    required this.totalStudents,
    required this.dueDate,
    this.pendingReview,
  });
}
