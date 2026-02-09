import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/reports_model.dart';
import '../../../widgets/instructor/reports/reports_barrel.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isLoading = true;
  String? _error;
  ReportTabType _selectedTab = ReportTabType.performance;
  String _selectedCourse = 'CS101 - Operating Systems';
  String _searchQuery = '';
  final Set<String> _selectedStudents = {};

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  // Data
  List<StudentReportData> _students = [];
  List<String> _courses = [];
  CourseStatistics? _courseStats;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock courses
      _courses = [
        'CS101 - Operating Systems',
        'CS102 - Data Structures',
        'CS201 - Algorithms',
        'CS301 - Database Systems',
      ];

      // Mock course statistics
      _courseStats = CourseStatistics(
        courseId: '1',
        courseName: 'Operating Systems',
        courseCode: 'CS101',
        totalStudents: 5,
        averageGrade: 82.2,
        attendanceRate: 83.0,
        studentsAtRisk: 2,
        gradeDistribution: const GradeDistribution(
          gradeA: 2,
          gradeB: 2,
          gradeC: 1,
          gradeD: 0,
          gradeF: 0,
        ),
        engagementMetrics: const EngagementMetrics(
          assignmentSubmissionRate: 92,
          labCompletionRate: 88,
          discussionParticipation: 75,
        ),
        attendanceBreakdown: const AttendanceBreakdown(
          presentRate: 85,
          absentRate: 10,
          lateRate: 5,
          insight:
              'AI Insight: Attendance drops on Monday mornings — consider lighter sessions or recorded content.',
        ),
        aiInsight: 'AI identified 2 students with declining performance',
      );

      // Mock students
      _students = [
        StudentReportData(
          id: '1',
          studentId: 'CS2025-001',
          name: 'Sarah Johnson',
          averageGrade: 92,
          attendanceRate: 95,
          assignmentScore: 90,
          labScore: 95,
          quizScore: 91,
          midtermScore: 88,
          trend: StudentPerformanceTrend.improving,
        ),
        StudentReportData(
          id: '2',
          studentId: 'CS2025-002',
          name: 'Michael Chen',
          averageGrade: 85,
          attendanceRate: 88,
          assignmentScore: 82,
          labScore: 88,
          quizScore: 86,
          midtermScore: 84,
          trend: StudentPerformanceTrend.declining,
        ),
        StudentReportData(
          id: '3',
          studentId: 'CS2025-003',
          name: 'Emily Rodriguez',
          averageGrade: 68,
          attendanceRate: 62,
          assignmentScore: 65,
          labScore: 70,
          quizScore: 72,
          midtermScore: 64,
          trend: StudentPerformanceTrend.declining,
          isAtRisk: true,
        ),
        StudentReportData(
          id: '4',
          studentId: 'CS2025-004',
          name: 'James Williams',
          averageGrade: 78,
          attendanceRate: 78,
          assignmentScore: 75,
          labScore: 80,
          quizScore: 79,
          midtermScore: 77,
          trend: StudentPerformanceTrend.declining,
          isAtRisk: true,
        ),
        StudentReportData(
          id: '5',
          studentId: 'CS2025-005',
          name: 'Olivia Martinez',
          averageGrade: 88,
          attendanceRate: 92,
          assignmentScore: 87,
          labScore: 90,
          quizScore: 89,
          midtermScore: 86,
          trend: StudentPerformanceTrend.improving,
        ),
      ];

      setState(() => _isLoading = false);
      _animController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<StudentReportData> get _filteredStudents {
    var filtered = _students;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.studentId.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  void _toggleStudentSelection(String studentId) {
    setState(() {
      if (_selectedStudents.contains(studentId)) {
        _selectedStudents.remove(studentId);
      } else {
        _selectedStudents.add(studentId);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _showExportSheet() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ReportsExportSheet(
        isDark: isDark,
        onExportPDF: () => _exportReport(ExportFormat.pdf),
        onExportCSV: () => _exportReport(ExportFormat.csv),
        onExportAll: () => _exportReport(ExportFormat.excel),
      ),
    );
  }

  void _exportReport(ExportFormat format) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.exportingReport),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: ReportsColors.primary,
      ),
    );
  }

  void _showStudentDetail(StudentReportData student) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildStudentDetailSheet(student, isDark),
    );
  }

  Widget _buildStudentDetailSheet(StudentReportData student, bool isDark) {
    final gradeColor = ReportsColors.getGradeColor(student.averageGrade);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? ReportsColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ReportsColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Student header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradeColor.withValues(alpha: 0.8), gradeColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        student.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
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
                          student.name,
                          style: TextStyle(
                            color: ReportsColors.textPrimaryColor(isDark),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          student.studentId,
                          style: TextStyle(
                            color: ReportsColors.textSecondaryColor(isDark),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (student.isAtRisk)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ReportsColors.atRiskLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 14,
                            color: ReportsColors.atRisk,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'At Risk',
                            style: TextStyle(
                              color: ReportsColors.atRisk,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              // Stats grid
              Row(
                children: [
                  _buildStatBox(
                    'Average Grade',
                    '${student.averageGrade.toStringAsFixed(0)}%',
                    gradeColor,
                    isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBox(
                    'Attendance',
                    '${student.attendanceRate.toStringAsFixed(0)}%',
                    ReportsColors.getAttendanceColor(student.attendanceRate),
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Performance breakdown
              Text(
                'Performance Breakdown',
                style: TextStyle(
                  color: ReportsColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildPerformanceRow(
                'Assignments',
                student.assignmentScore,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildPerformanceRow('Labs', student.labScore, isDark),
              const SizedBox(height: 12),
              _buildPerformanceRow('Quizzes', student.quizScore, isDark),
              const SizedBox(height: 12),
              _buildPerformanceRow('Midterm', student.midtermScore, isDark),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: const Text('Contact'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ReportsColors.primary,
                        side: BorderSide(color: ReportsColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ReportsColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ReportsColors.darkSurface : ReportsColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: ReportsColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, double value, bool isDark) {
    final color = ReportsColors.getGradeColor(value);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: ReportsColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: ReportsColors.borderColor(isDark),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 45,
          child: Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark
              ? ReportsColors.darkBackground
              : ReportsColors.lightBackground,
          body: SafeArea(
            child: _isLoading
                ? ReportsLoadingState(isDark: isDark, message: l10n.loading)
                : _error != null
                ? ReportsErrorState(
                    isDark: isDark,
                    title: l10n.error,
                    message: _error,
                    onRetry: _loadData,
                  )
                : _buildContent(isDark, l10n),
          ),
          bottomNavigationBar: _isLoading || _error != null
              ? null
              : _buildBottomBar(isDark, l10n),
        );
      },
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        // App Bar
        _buildSliverAppBar(isDark, l10n),

        // Tab Selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ReportsTabSelector(
              selectedTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
              isDark: isDark,
            ),
          ),
        ),

        // Course Selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildCourseSelector(isDark),
          ),
        ),

        // Course Summary Card
        if (_courseStats != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CourseSummaryCard(
                courseCode: _courseStats!.courseCode,
                courseName: _courseStats!.courseName,
                totalStudents: _courseStats!.totalStudents,
                averageGrade: _courseStats!.averageGrade,
                attendanceRate: _courseStats!.attendanceRate,
                studentsAtRisk: _courseStats!.studentsAtRisk,
                aiInsight: _courseStats!.aiInsight,
                isDark: isDark,
              ),
            ),
          ),

        // Tab Content
        ..._buildTabContent(isDark, l10n),

        // Bottom spacing
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildCourseSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? ReportsColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ReportsColors.borderColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCourse,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ReportsColors.textSecondaryColor(isDark),
          ),
          dropdownColor: isDark ? ReportsColors.darkCard : Colors.white,
          items: _courses.map((course) {
            return DropdownMenuItem(
              value: course,
              child: Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 18,
                    color: ReportsColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      course,
                      style: TextStyle(
                        color: ReportsColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCourse = val!),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 45,
      floating: true,
      pinned: true,
      backgroundColor: isDark
          ? ReportsColors.darkBackground
          : ReportsColors.lightBackground,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: ReportsColors.textPrimaryColor(isDark),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _loadData,
          icon: Icon(
            Icons.refresh_rounded,
            color: ReportsColors.textSecondaryColor(isDark),
          ),
          tooltip: l10n.refresh,
        ),
      ],
      // flexibleSpace: FlexibleSpaceBar(
      //   titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportsAndAnalytics,
            style: TextStyle(
              color: ReportsColors.textPrimaryColor(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.exportPerformanceData,
            style: TextStyle(
              color: ReportsColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      // ),
    );
  }

  List<Widget> _buildTabContent(bool isDark, AppLocalizations l10n) {
    switch (_selectedTab) {
      case ReportTabType.performance:
        return _buildPerformanceTab(isDark, l10n);
      case ReportTabType.attendance:
        return _buildAttendanceTab(isDark, l10n);
      case ReportTabType.analytics:
        return _buildAnalyticsTab(isDark, l10n);
    }
  }

  List<Widget> _buildPerformanceTab(bool isDark, AppLocalizations l10n) {
    return [
      // Search Bar
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ReportsSearchBar(
            controller: _searchController,
            isDark: isDark,
            hintText: l10n.searchStudents,
            onChanged: (val) => setState(() => _searchQuery = val),
            onClear: () => setState(() => _searchQuery = ''),
          ),
        ),
      ),

      // Selection Header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ReportsSelectionHeader(
            selectedCount: _selectedStudents.length,
            onExport: _showExportSheet,
            isDark: isDark,
          ),
        ),
      ),

      // Student List
      _filteredStudents.isEmpty
          ? SliverFillRemaining(
              child: ReportsEmptyState(
                isDark: isDark,
                title: l10n.noStudentsFound,
                subtitle: l10n.tryDifferentSearch,
                icon: Icons.search_off_rounded,
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final student = _filteredStudents[index];
                  return StudentPerformanceCard(
                    student: student,
                    isDark: isDark,
                    isSelected: _selectedStudents.contains(student.id),
                    onTap: () => _showStudentDetail(student),
                    onSelectionChanged: (_) =>
                        _toggleStudentSelection(student.id),
                  );
                }, childCount: _filteredStudents.length),
              ),
            ),
    ];
  }

  List<Widget> _buildAttendanceTab(bool isDark, AppLocalizations l10n) {
    return [
      // Attendance Overview
      if (_courseStats != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AttendanceOverviewCard(
              breakdown: _courseStats!.attendanceBreakdown,
              isDark: isDark,
            ),
          ),
        ),

      // Student Attendance List
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final student = _students[index];
            return StudentAttendanceReportCard(
              student: student,
              isDark: isDark,
              onTap: () => _showStudentDetail(student),
            );
          }, childCount: _students.length),
        ),
      ),
    ];
  }

  List<Widget> _buildAnalyticsTab(bool isDark, AppLocalizations l10n) {
    return [
      // Grade Distribution
      if (_courseStats != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GradeDistributionCard(
              distribution: _courseStats!.gradeDistribution,
              isDark: isDark,
            ),
          ),
        ),

      // Engagement Metrics
      if (_courseStats != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EngagementMetricsCard(
              metrics: _courseStats!.engagementMetrics,
              isDark: isDark,
            ),
          ),
        ),
    ];
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ReportsColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(color: ReportsColors.borderColor(isDark)),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Export buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportReport(ExportFormat.pdf),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(l10n.exportPDF),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ReportsColors.textPrimaryColor(isDark),
                      side: BorderSide(
                        color: ReportsColors.borderColor(isDark),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportReport(ExportFormat.csv),
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: Text(l10n.exportCSV),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ReportsColors.textPrimaryColor(isDark),
                      side: BorderSide(
                        color: ReportsColors.borderColor(isDark),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Export all button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showExportSheet,
                icon: const Icon(Icons.download_rounded, size: 20),
                label: Text(l10n.exportAllReports),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReportsColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
