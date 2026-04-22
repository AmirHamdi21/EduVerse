import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/departments/departments_barrel.dart';
import '../../../widgets/admin/dashboard/admin_drawer.dart';

class AdminDepartmentsScreen extends StatefulWidget {
  const AdminDepartmentsScreen({super.key});

  @override
  State<AdminDepartmentsScreen> createState() => _AdminDepartmentsScreenState();
}

class _AdminDepartmentsScreenState extends State<AdminDepartmentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _searchQuery = '';
  String _selectedFaculty = 'All';
  DepartmentViewType _viewType = DepartmentViewType.list;
  DepartmentFilterType _filterType = DepartmentFilterType.all;
  bool _isLoading = false;
  Set<String> _expandedDepartments = {};

  final List<String> _faculties = [
    'All',
    'Engineering',
    'Science',
    'Business',
    'Arts',
  ];

  late List<Department> _departments;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  void _loadDepartments() {
    setState(() => _isLoading = true);

    // Sample data
    _departments = [
      Department(
        id: '1',
        name: 'Computer Engineering',
        faculty: 'Engineering',
        iconColor: AdminColors.primary,
        icon: Icons.computer_rounded,
        studentCount: 450,
        programs: ['BSc', 'MSc', 'PhD'],
        courseCount: 22,
        instructorCount: 9,
        taCount: 12,
        headName: 'Dr. Ahmed Hassan',
        healthPercent: 95,
      ),
      Department(
        id: '2',
        name: 'Mathematics',
        faculty: 'Science',
        iconColor: AdminColors.secondary,
        icon: Icons.functions_rounded,
        studentCount: 380,
        programs: ['BSc', 'MSc'],
        courseCount: 18,
        instructorCount: 7,
        taCount: 4,
        headName: 'Dr. Sarah Ahmed',
        hasWarning: true,
        warningMessage:
            'Mathematics program has low TA count (4 TAs for 280 students)',
        healthPercent: 65,
      ),
      Department(
        id: '3',
        name: 'Physics',
        faculty: 'Science',
        iconColor: AdminColors.chartCyan,
        icon: Icons.science_rounded,
        studentCount: 185,
        programs: ['BSc', 'MSc', 'PhD'],
        courseCount: 15,
        instructorCount: 4,
        taCount: 5,
        hasWarning: true,
        warningMessage: 'Physics department missing department head assignment',
        healthPercent: 35,
      ),
      Department(
        id: '4',
        name: 'Electrical Engineering',
        faculty: 'Engineering',
        iconColor: AdminColors.chartOrange,
        icon: Icons.electrical_services_rounded,
        studentCount: 380,
        programs: ['BSc', 'MSc'],
        courseCount: 20,
        instructorCount: 7,
        taCount: 8,
        headName: 'Dr. Omar Khalid',
        hasWarning: true,
        warningMessage:
            'Electrical Engineering missing AI-based evaluation tools',
        healthPercent: 70,
      ),
      Department(
        id: '5',
        name: 'Business Administration',
        faculty: 'Business',
        iconColor: AdminColors.chartGreen,
        icon: Icons.business_center_rounded,
        studentCount: 520,
        programs: ['BBA', 'MBA'],
        courseCount: 25,
        instructorCount: 10,
        taCount: 15,
        headName: 'Dr. Fatima Nasser',
        healthPercent: 92,
      ),
    ];

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  List<Department> get _filteredDepartments {
    var filtered = _departments;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Faculty filter
    if (_selectedFaculty != 'All') {
      filtered = filtered.where((d) => d.faculty == _selectedFaculty).toList();
    }

    // Type filter
    switch (_filterType) {
      case DepartmentFilterType.understaffed:
        filtered = filtered.where((d) => d.taCount < 6).toList();
        break;
      case DepartmentFilterType.missingCourses:
        filtered = filtered.where((d) => d.courseCount < 10).toList();
        break;
      case DepartmentFilterType.noHead:
        filtered = filtered.where((d) => d.headName == null).toList();
        break;
      case DepartmentFilterType.aiWarnings:
        filtered = filtered.where((d) => d.hasWarning).toList();
        break;
      case DepartmentFilterType.all:
        break;
    }

    return filtered;
  }

  int get _understaffedCount => _departments.where((d) => d.taCount < 6).length;
  int get _missingCoursesCount =>
      _departments.where((d) => d.courseCount < 10).length;
  int get _noHeadCount => _departments.where((d) => d.headName == null).length;
  int get _aiWarningsCount => _departments.where((d) => d.hasWarning).length;

  void _showAddDepartmentDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AddDepartmentDialog(
        isDark: isDark,
        onSubmit: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.departmentCreatedSuccessfully ??
                    'Department created successfully',
              ),
              backgroundColor: AdminColors.success,
            ),
          );
          _loadDepartments();
        },
      ),
    );
  }

  void _handleAlertAction(CriticalAlert alert) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n?.actionTriggered ?? "Action triggered"}: ${alert.actionLabel}',
        ),
        backgroundColor: AdminColors.primary,
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
          key: _scaffoldKey,
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          // drawer: const AdminDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: AdminColors.getBackgroundGradient(isDark),
            ),
            child: SafeArea(
              child: _isLoading
                  ? _buildLoadingState(isDark)
                  : _buildContent(isDark, l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(child: CircularProgressIndicator(color: AdminColors.primary));
  }

  Widget _buildContent(bool isDark, AppLocalizations? l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        return Row(
          children: [
            // Main Content
            Expanded(
              flex: isWide ? 3 : 1,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(20),
                  //     child: Row(
                  //       children: [
                  //         IconButton(
                  //           onPressed: () =>
                  //               _scaffoldKey.currentState?.openDrawer(),
                  //           icon: Icon(
                  //             Icons.menu_rounded,
                  //             color: AdminColors.getTextColor(isDark),
                  //           ),
                  //         ),
                  //         const Spacer(),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DepartmentHeader(
                        isDark: isDark,
                        onAddDepartment: () => _showAddDepartmentDialog(isDark),
                        onSettings: () {},
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  // Filters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DepartmentFilters(
                        isDark: isDark,
                        searchQuery: _searchQuery,
                        selectedFaculty: _selectedFaculty,
                        viewType: _viewType,
                        filterType: _filterType,
                        faculties: _faculties,
                        allCount: _departments.length,
                        understaffedCount: _understaffedCount,
                        missingCoursesCount: _missingCoursesCount,
                        noHeadCount: _noHeadCount,
                        aiWarningsCount: _aiWarningsCount,
                        onSearchChanged: (value) =>
                            setState(() => _searchQuery = value),
                        onFacultyChanged: (value) =>
                            setState(() => _selectedFaculty = value),
                        onViewTypeChanged: (value) =>
                            setState(() => _viewType = value),
                        onFilterChanged: (value) =>
                            setState(() => _filterType = value),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  // Content based on view type
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildViewContent(isDark, l10n),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            // Side Panel (only on wide screens)
            if (isWide) ...[
              Container(width: 1, color: AdminColors.getDividerColor(isDark)),
              SizedBox(width: 350, child: _buildSidePanel(isDark, l10n)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildViewContent(bool isDark, AppLocalizations? l10n) {
    switch (_viewType) {
      case DepartmentViewType.list:
        return DepartmentTable(
          key: const ValueKey('table'),
          isDark: isDark,
          departments: _filteredDepartments,
          onViewDetails: (dept) => _showDepartmentDetails(dept, isDark),
          onEdit: (dept) => _editDepartment(dept),
          onAssignHead: (dept) => _assignHead(dept),
        );
      case DepartmentViewType.card:
        return Column(
          key: const ValueKey('cards'),
          children: _filteredDepartments.map((dept) {
            return DepartmentCard(
              isDark: isDark,
              department: dept,
              isExpanded: _expandedDepartments.contains(dept.id),
              onToggleExpand: () {
                setState(() {
                  if (_expandedDepartments.contains(dept.id)) {
                    _expandedDepartments.remove(dept.id);
                  } else {
                    _expandedDepartments.add(dept.id);
                  }
                });
              },
              onViewDetails: () => _showDepartmentDetails(dept, isDark),
              onEdit: () => _editDepartment(dept),
              onAssignHead: () => _assignHead(dept),
              onAssignTAs: () => _assignTAs(dept),
            );
          }).toList(),
        );
      case DepartmentViewType.health:
        return DepartmentHealthMap(
          key: const ValueKey('health'),
          isDark: isDark,
          departments: _filteredDepartments,
          onViewDetails: (dept) => _showDepartmentDetails(dept, isDark),
        );
    }
  }

  Widget _buildSidePanel(bool isDark, AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // AI Insights
          DepartmentAiInsights(
            isDark: isDark,
            mostActiveDepartment: 'Business Administration',
            mostActiveProgress: 0.92,
            underperformingDepartment: 'Physics',
            underperformingProgress: 0.35,
            staffShortageCount: 2,
            onViewDetails: () {},
          ),
          const SizedBox(height: 20),
          // Statistics
          DepartmentStatistics(
            isDark: isDark,
            totalDepartments: _departments.length,
            totalPrograms: 12,
            totalStudents: 1810,
            totalCourses: 100,
          ),
          const SizedBox(height: 20),
          // Critical Alerts
          CriticalAlertsCard(
            isDark: isDark,
            alerts: [
              CriticalAlert(
                id: '1',
                message:
                    l10n?.mathLowTACount ??
                    'Mathematics program has low TA count (4 TAs for 280 students)',
                actionLabel: l10n?.assignTAs ?? 'Assign TAs',
                type: AlertType.staffing,
              ),
              CriticalAlert(
                id: '2',
                message:
                    l10n?.physicsMissingHead ??
                    'Physics department missing department head assignment',
                actionLabel: l10n?.assignHead ?? 'Assign Head',
                type: AlertType.head,
              ),
              CriticalAlert(
                id: '3',
                message:
                    l10n?.electricalMissingAI ??
                    'Electrical Engineering missing AI-based evaluation tools',
                actionLabel: l10n?.enableAITools ?? 'Enable AI Tools',
                type: AlertType.aiTools,
              ),
            ],
            onAlertAction: _handleAlertAction,
          ),
        ],
      ),
    );
  }

  void _showDepartmentDetails(Department dept, bool isDark) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dept.iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(dept.icon, color: dept.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dept.name,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n?.faculty ?? 'Faculty', dept.faculty, isDark),
            _buildDetailRow(
              l10n?.students ?? 'Students',
              dept.studentCount.toString(),
              isDark,
            ),
            _buildDetailRow(
              l10n?.courses ?? 'Courses',
              dept.courseCount.toString(),
              isDark,
            ),
            _buildDetailRow(
              l10n?.instructors ?? 'Instructors',
              dept.instructorCount.toString(),
              isDark,
            ),
            _buildDetailRow(
              l10n?.teachingAssistants ?? 'TAs',
              dept.taCount.toString(),
              isDark,
            ),
            _buildDetailRow(
              l10n?.departmentHead ?? 'Head',
              dept.headName ?? '-',
              isDark,
            ),
            _buildDetailRow(
              l10n?.programs ?? 'Programs',
              dept.programs.join(', '),
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _editDepartment(Department dept) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n?.editing ?? "Editing"}: ${dept.name}'),
        backgroundColor: AdminColors.primary,
      ),
    );
  }

  void _assignHead(Department dept) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n?.assigningHeadTo ?? "Assigning head to"}: ${dept.name}',
        ),
        backgroundColor: AdminColors.chartPurple,
      ),
    );
  }

  void _assignTAs(Department dept) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n?.assigningTAsTo ?? "Assigning TAs to"}: ${dept.name}',
        ),
        backgroundColor: AdminColors.warning,
      ),
    );
  }
}
