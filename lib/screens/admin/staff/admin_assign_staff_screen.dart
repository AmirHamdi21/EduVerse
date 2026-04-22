import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/staff/staff_assignment_header.dart';
import '../../../widgets/admin/staff/staff_filters.dart';
import '../../../widgets/admin/staff/coverage_map.dart';
import '../../../widgets/admin/staff/staff_list_view.dart';
import '../../../widgets/admin/staff/staff_view_toggle.dart';
import '../../../widgets/admin/staff/staff_availability.dart';
import '../../../widgets/admin/staff/ai_suggestions_card.dart';

/// Admin Assign Staff Screen
class AdminAssignStaffScreen extends StatefulWidget {
  const AdminAssignStaffScreen({super.key});

  @override
  State<AdminAssignStaffScreen> createState() => _AdminAssignStaffScreenState();
}

class _AdminAssignStaffScreenState extends State<AdminAssignStaffScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  String? _selectedDepartment;
  bool _isLoading = false;
  bool _isListView = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample data
  late List<CourseAssignment> _courses;
  late List<StaffMember> _instructors;
  late List<StaffMember> _teachingAssistants;
  late List<AiSuggestion> _suggestions;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadData() {
    _courses = [
      CourseAssignment(
        id: '1',
        code: 'CS321',
        name: 'Advanced Data Structures',
        instructorName: 'Dr. Sarah Ahmed',
        instructorInitials: 'SA',
        taCount: 2,
        studentCount: 120,
      ),
      CourseAssignment(
        id: '2',
        code: 'LAB102',
        name: 'Physics Laboratory',
        instructorName: null,
        taCount: 0,
        studentCount: 80,
        hasIssue: true,
        issueType: 'needsInstructor',
      ),
      CourseAssignment(
        id: '3',
        code: 'MATH301',
        name: 'Linear Algebra II',
        instructorName: 'Prof. David Lee',
        instructorInitials: 'DL',
        taCount: 0,
        studentCount: 95,
        hasIssue: true,
        issueType: 'needsTA',
      ),
      CourseAssignment(
        id: '4',
        code: 'CS450',
        name: 'Machine Learning',
        instructorName: 'Dr. Emma Wilson',
        instructorInitials: 'EW',
        taCount: 1,
        studentCount: 150,
      ),
    ];

    _instructors = [
      StaffMember(
        id: '1',
        name: 'Dr. Sarah Ahmed',
        initials: 'SA',
        department: 'Data Structures',
        workloadPercent: 119,
        status: StaffStatus.overloaded,
        assignedCourses: 4,
      ),
      StaffMember(
        id: '2',
        name: 'Prof. David Lee',
        initials: 'DL',
        department: 'Machine Learning',
        workloadPercent: 115,
        status: StaffStatus.overloaded,
        assignedCourses: 3,
      ),
      StaffMember(
        id: '3',
        name: 'Dr. Emma Wilson',
        initials: 'EW',
        department: 'Machine Learning',
        workloadPercent: 95,
        status: StaffStatus.atCapacity,
        assignedCourses: 3,
      ),
      StaffMember(
        id: '4',
        name: 'Dr. Robert Kim',
        initials: 'RK',
        department: 'Algorithms',
        workloadPercent: 85,
        status: StaffStatus.available,
        assignedCourses: 2,
      ),
    ];

    _teachingAssistants = [
      StaffMember(
        id: '5',
        name: 'Mike Chen',
        initials: 'MC',
        department: 'Lab TA',
        workloadPercent: 75,
        status: StaffStatus.available,
        assignedCourses: 2,
        isInstructor: false,
      ),
      StaffMember(
        id: '6',
        name: 'Sarah Park',
        initials: 'SP',
        department: 'Discussion TA',
        workloadPercent: 100,
        status: StaffStatus.atCapacity,
        assignedCourses: 3,
        isInstructor: false,
      ),
      StaffMember(
        id: '7',
        name: 'Alex Rodriguez',
        initials: 'AR',
        department: 'Lab TA',
        workloadPercent: 127,
        status: StaffStatus.overloaded,
        assignedCourses: 4,
        isInstructor: false,
      ),
      StaffMember(
        id: '8',
        name: 'Yasmine Hassan',
        initials: 'YH',
        department: 'Research TA',
        workloadPercent: 92,
        status: StaffStatus.available,
        assignedCourses: 2,
        isInstructor: false,
      ),
    ];

    _suggestions = [
      AiSuggestion(
        id: '1',
        title: 'Course LAB102 lacks assigned instructor',
        description:
            'We suggest Dr. Robert Kim as an ideal candidate for MATH301 lab section.',
        type: SuggestionType.assignInstructor,
        confidencePercent: 94,
        courseId: '2',
        staffId: '4',
      ),
      AiSuggestion(
        id: '2',
        title: 'TA Yasmine Hassan is an ideal candidate',
        description: 'For MATH301 lab section.',
        type: SuggestionType.assignTA,
        confidencePercent: 89,
        courseId: '3',
        staffId: '8',
      ),
      AiSuggestion(
        id: '3',
        title: 'Prof. David Lee is overloaded (115.0 hours)',
        description: 'Consider coverage reassignment.',
        type: SuggestionType.rebalance,
        confidencePercent: 87,
        staffId: '2',
      ),
    ];
  }

  List<CourseAssignment> get _filteredCourses {
    var filtered = _courses;

    // Apply filter
    switch (_selectedFilter) {
      case 'needsInstructor':
        filtered = filtered.where((c) => c.instructorName == null).toList();
        break;
      case 'needsTA':
        filtered = filtered.where((c) => c.taCount == 0).toList();
        break;
      case 'instructorOverloaded':
        // Show courses with overloaded instructors
        final overloadedInstructors = _instructors
            .where((i) => i.isOverloaded)
            .map((i) => i.name)
            .toSet();
        filtered = filtered
            .where((c) => overloadedInstructors.contains(c.instructorName))
            .toList();
        break;
      case 'taOverloaded':
        // Just show courses - in real app would filter by TA status
        break;
      case 'aiSuggestions':
        final coursesWithSuggestions = _suggestions
            .where((s) => s.courseId != null)
            .map((s) => s.courseId)
            .toSet();
        filtered = filtered
            .where((c) => coursesWithSuggestions.contains(c.id))
            .toList();
        break;
    }

    // Apply department filter
    if (_selectedDepartment != null) {
      // In a real app, would filter by actual department
    }

    return filtered;
  }

  Map<String, int> get _filterCounts {
    return {
      'all': _courses.length,
      'needsInstructor': _courses.where((c) => c.instructorName == null).length,
      'needsTA': _courses.where((c) => c.taCount == 0).length,
      'instructorOverloaded': _instructors.where((i) => i.isOverloaded).length,
      'taOverloaded': _teachingAssistants.where((t) => t.isOverloaded).length,
      'aiSuggestions': _suggestions.length,
    };
  }

  void _onAssignInstructor(CourseAssignment course, String type) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.read<ThemeBloc>().state.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildAssignmentSheet(ctx, isDark, l10n, course, true),
    );
  }

  void _onAssignTA(CourseAssignment course) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.read<ThemeBloc>().state.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildAssignmentSheet(ctx, isDark, l10n, course, false),
    );
  }

  Widget _buildAssignmentSheet(
    BuildContext ctx,
    bool isDark,
    AppLocalizations l10n,
    CourseAssignment course,
    bool isInstructor,
  ) {
    final staff = isInstructor ? _instructors : _teachingAssistants;
    final title = isInstructor ? l10n.assignInstructor : l10n.assignTA;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(ctx).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isInstructor
                        ? AdminColors.secondaryGradient
                        : AdminColors.cyanGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isInstructor
                        ? Icons.person_add_rounded
                        : Icons.group_add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${course.code} - ${course.name}',
                        style: TextStyle(
                          color: AdminColors.getTextSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: staff.length,
              itemBuilder: (context, index) {
                final member = staff[index];
                return _buildStaffOption(
                  ctx,
                  isDark,
                  l10n,
                  member,
                  course,
                  isInstructor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffOption(
    BuildContext ctx,
    bool isDark,
    AppLocalizations l10n,
    StaffMember member,
    CourseAssignment course,
    bool isInstructor,
  ) {
    final accentColor = isInstructor
        ? AdminColors.secondary
        : AdminColors.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(ctx);
          _applyAssignment(course, member, isInstructor);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AdminColors.darkSurface : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: member.status == StaffStatus.available
                  ? AdminColors.success.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accentColor.withValues(alpha: 0.2),
                child: Text(
                  member.initials,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          member.department,
                          style: TextStyle(
                            color: AdminColors.getTextSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              member.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${member.workloadPercent}%',
                            style: TextStyle(
                              color: _getStatusColor(member.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle_outline_rounded,
                color: accentColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(StaffStatus status) {
    switch (status) {
      case StaffStatus.available:
        return AdminColors.success;
      case StaffStatus.atCapacity:
        return AdminColors.warning;
      case StaffStatus.overloaded:
        return AdminColors.error;
      case StaffStatus.onLeave:
        return Colors.grey;
    }
  }

  void _applyAssignment(
    CourseAssignment course,
    StaffMember member,
    bool isInstructor,
  ) {
    final l10n = AppLocalizations.of(context);

    setState(() {
      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        if (isInstructor) {
          _courses[index] = CourseAssignment(
            id: course.id,
            code: course.code,
            name: course.name,
            instructorName: member.name,
            instructorInitials: member.initials,
            taCount: course.taCount,
            studentCount: course.studentCount,
          );
        } else {
          _courses[index] = CourseAssignment(
            id: course.id,
            code: course.code,
            name: course.name,
            instructorName: course.instructorName,
            instructorInitials: course.instructorInitials,
            taCount: course.taCount + 1,
            studentCount: course.studentCount,
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isInstructor ? l10n.instructorAssigned : l10n.taAssigned,
              ),
            ),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onStaffTapped(StaffMember member) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.read<ThemeBloc>().state.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor:
                  (member.isInstructor
                          ? AdminColors.secondary
                          : AdminColors.accent)
                      .withValues(alpha: 0.2),
              child: Text(
                member.initials,
                style: TextStyle(
                  color: member.isInstructor
                      ? AdminColors.secondary
                      : AdminColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              member.name,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              member.department,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  l10n.courses,
                  '${member.assignedCourses}',
                  AdminColors.primary,
                  isDark,
                ),
                _buildStatColumn(
                  l10n.workload,
                  '${member.workloadPercent}%',
                  _getStatusColor(member.status),
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.primary,
                  side: BorderSide(color: AdminColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _onApplySuggestion(AiSuggestion suggestion) {
    setState(() {
      _suggestions.removeWhere((s) => s.id == suggestion.id);
    });

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.suggestionApplied),
          ],
        ),
        backgroundColor: AdminColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onDismissSuggestion() {
    if (_suggestions.isNotEmpty) {
      setState(() {
        _suggestions.removeAt(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                StaffAssignmentHeader(
                  isDark: isDark,
                  onBack: () => context.go('/admin/dashboard'),
                ),
                StaffFilters(
                  isDark: isDark,
                  selectedFilter: _selectedFilter,
                  selectedDepartment: _selectedDepartment,
                  onFilterChanged: (f) => setState(() => _selectedFilter = f),
                  onDepartmentChanged: (d) =>
                      setState(() => _selectedDepartment = d),
                  filterCounts: _filterCounts,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBody(isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          StaffViewToggle(
            isDark: isDark,
            isListView: _isListView,
            onViewChanged: (isListView) =>
                setState(() => _isListView = isListView),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isListView
                ? StaffListView(
                    key: const ValueKey('list'),
                    isDark: isDark,
                    courses: _filteredCourses,
                    onAssignInstructor: _onAssignInstructor,
                    onAssignTA: _onAssignTA,
                  )
                : CoverageMap(
                    key: const ValueKey('card'),
                    isDark: isDark,
                    courses: _filteredCourses,
                    onAssignInstructor: _onAssignInstructor,
                    onAssignTA: _onAssignTA,
                  ),
          ),
          const SizedBox(height: 16),
          StaffAvailability(
            isDark: isDark,
            instructors: _instructors,
            teachingAssistants: _teachingAssistants,
            onStaffTapped: _onStaffTapped,
          ),
          const SizedBox(height: 16),
          AiSuggestionsCard(
            isDark: isDark,
            suggestions: _suggestions,
            onApplySuggestion: _onApplySuggestion,
            onDismissSuggestion: _onDismissSuggestion,
          ),
        ],
      ),
    );
  }
}
