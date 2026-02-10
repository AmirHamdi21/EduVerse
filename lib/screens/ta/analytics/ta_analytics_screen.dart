import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/analytics/ta_analytics_barrel.dart';

class TAAnalyticsScreen extends StatefulWidget {
  const TAAnalyticsScreen({super.key});

  @override
  State<TAAnalyticsScreen> createState() => _TAAnalyticsScreenState();
}

class _TAAnalyticsScreenState extends State<TAAnalyticsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  int _attendanceFilterIndex = 0;
  int _submissionFilterIndex = 0;
  String? _selectedDeadlineCourse;

  // Analytics Data
  late Map<String, dynamic> _statsData;
  late List<ChartData> _attendanceData;
  late List<ChartData> _submissionData;
  late List<ChartData> _scoreDistributionData;
  late List<UpcomingDeadline> _deadlines;
  late List<ComparisonMetric> _comparisonMetrics;
  late List<QuickInsight> _quickInsights;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _statsData = {
        'attendance': 88,
        'attendanceTrend': '+3%',
        'submissionRate': 76,
        'submissionTrend': '-2%',
        'atRiskStudents': 5,
        'atRiskTrend': '+1',
        'engagementScore': 82,
        'engagementTrend': '+5%',
      };

      _attendanceData = [
        ChartData(label: 'Week 1', value: 85, color: TAColors.primary),
        ChartData(label: 'Week 2', value: 90, color: TAColors.primary),
        ChartData(label: 'Week 3', value: 78, color: TAColors.primary),
        ChartData(label: 'Week 4', value: 88, color: TAColors.primary),
        ChartData(label: 'Week 5', value: 92, color: TAColors.primary),
        ChartData(label: 'Week 6', value: 86, color: TAColors.primary),
        ChartData(label: 'Week 7', value: 88, color: TAColors.primary),
      ];

      _submissionData = [
        ChartData(label: 'Lab 1', value: 95, color: TAColors.success),
        ChartData(label: 'Lab 2', value: 88, color: TAColors.success),
        ChartData(label: 'Lab 3', value: 72, color: TAColors.warning),
        ChartData(label: 'Lab 4', value: 80, color: TAColors.success),
        ChartData(label: 'Lab 5', value: 65, color: TAColors.warning),
      ];

      _scoreDistributionData = [
        ChartData(label: '90-100', value: 25, color: TAColors.success),
        ChartData(label: '80-89', value: 35, color: TAColors.info),
        ChartData(label: '70-79', value: 22, color: TAColors.primary),
        ChartData(label: '60-69', value: 12, color: TAColors.warning),
        ChartData(label: '<60', value: 6, color: TAColors.error),
      ];

      _deadlines = [
        UpcomingDeadline(
          title: 'Lab 5 Submission',
          course: 'Data Structures',
          daysRemaining: 2,
          icon: Icons.assignment,
        ),
        UpcomingDeadline(
          title: 'Midterm Review',
          course: 'Algorithms',
          daysRemaining: 5,
          icon: Icons.quiz,
        ),
        UpcomingDeadline(
          title: 'Project Milestone',
          course: 'Software Engineering',
          daysRemaining: 7,
          icon: Icons.folder,
        ),
      ];

      _comparisonMetrics = [
        ComparisonMetric(
          name: 'Attendance',
          currentValue: 88,
          previousValue: 85,
          change: 3,
        ),
        ComparisonMetric(
          name: 'Submissions',
          currentValue: 76,
          previousValue: 80,
          change: -4,
        ),
        ComparisonMetric(
          name: 'Avg. Score',
          currentValue: 78,
          previousValue: 75,
          change: 3,
        ),
      ];

      _quickInsights = [
        QuickInsight(
          text: '3 students showing attendance decline over last 2 weeks',
          color: TAColors.warning,
        ),
        QuickInsight(
          text: 'Lab 5 has lowest submission rate (65%)',
          color: TAColors.error,
        ),
        QuickInsight(
          text: 'Overall engagement increased by 5% this month',
          color: TAColors.success,
        ),
        QuickInsight(
          text: 'Score distribution improved compared to last semester',
          color: TAColors.info,
        ),
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(),
          appBar: _buildAppBar(l10n, isDark),
          body: _isLoading
              ? _buildLoadingState(isDark)
              : RefreshIndicator(
                  onRefresh: _loadAnalyticsData,
                  color: TAColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(l10n, isDark),
                        const SizedBox(height: 20),
                        _buildChartsSection(l10n, isDark),
                        const SizedBox(height: 20),
                        _buildAIInsightsSection(l10n, isDark),
                        const SizedBox(height: 20),
                        _buildBottomSection(l10n, isDark),
                        const SizedBox(height: 20),
                        _buildViewAllButton(l10n, isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, bool isDark) {
    return AppBar(
      backgroundColor: TAColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        l10n.taAnalyticsTitle,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.calendar_today_rounded,
            color: TAColors.textSecondaryColor(isDark),
            size: 20,
          ),
          onPressed: _showDateRangePicker,
        ),
        IconButton(
          icon: Icon(
            Icons.download_rounded,
            color: TAColors.textSecondaryColor(isDark),
            size: 22,
          ),
          onPressed: _exportReport,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TAColors.primary, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AppLocalizations l10n, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        TAStatsCard(
          title: l10n.taAnalyticsAttendance,
          value: '${_statsData['attendance']}%',
          icon: Icons.people_alt_rounded,
          color: TAColors.primary,
          isDark: isDark,
          trend: _statsData['attendanceTrend'],
          isPositiveTrend: true,
          onTap: () => _showAttendanceDetails(isDark),
        ),
        TAStatsCard(
          title: l10n.taAnalyticsSubmissionRate,
          value: '${_statsData['submissionRate']}%',
          icon: Icons.assignment_turned_in_rounded,
          color: TAColors.success,
          isDark: isDark,
          trend: _statsData['submissionTrend'],
          isPositiveTrend: false,
          onTap: () => _showSubmissionDetails(isDark),
        ),
        TAStatsCard(
          title: l10n.taAnalyticsAtRisk,
          value: '${_statsData['atRiskStudents']}',
          subtitle: 'Students need attention',
          icon: Icons.warning_amber_rounded,
          color: TAColors.warning,
          isDark: isDark,
          trend: _statsData['atRiskTrend'],
          isPositiveTrend: false,
          onTap: () => context.push('/ta/student-performance'),
        ),
        TAStatsCard(
          title: l10n.taAnalyticsEngagement,
          value: '${_statsData['engagementScore']}',
          icon: Icons.trending_up_rounded,
          color: TAColors.info,
          isDark: isDark,
          trend: _statsData['engagementTrend'],
          isPositiveTrend: true,
          onTap: () => _showEngagementDetails(isDark),
        ),
      ],
    );
  }

  Widget _buildChartsSection(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        TAChartCard(
          title: l10n.taAnalyticsAttendanceTrends,
          filters: const ['All', 'Week 1-4', 'Week 5-8'],
          selectedFilterIndex: _attendanceFilterIndex,
          onFilterChanged: (index) {
            setState(() => _attendanceFilterIndex = index);
          },
          data: _attendanceData,
          isDark: isDark,
          chartType: ChartType.bar,
        ),
        const SizedBox(height: 12),
        TAChartCard(
          title: l10n.taAnalyticsSubmissionPerformance,
          filters: const ['All Labs', 'Recent'],
          selectedFilterIndex: _submissionFilterIndex,
          onFilterChanged: (index) {
            setState(() => _submissionFilterIndex = index);
          },
          data: _submissionData,
          isDark: isDark,
          chartType: ChartType.bar,
        ),
        const SizedBox(height: 12),
        TAChartCard(
          title: l10n.taAnalyticsScoreDistribution,
          data: _scoreDistributionData,
          isDark: isDark,
          chartType: ChartType.horizontalBar,
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection(AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: TAColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taAnalyticsAIInsights,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TAAIInsightCard(
          title: l10n.taAnalyticsPerformanceDecline,
          description:
              '3 students showing significant grade drop in recent labs. Early intervention recommended.',
          icon: Icons.trending_down_rounded,
          iconColor: TAColors.error,
          actionLabel: l10n.taAnalyticsSendSupport,
          isDark: isDark,
          severity: InsightSeverity.critical,
          onAction: () => _sendSupportMessage(),
        ),
        const SizedBox(height: 10),
        TAAIInsightCard(
          title: l10n.taAnalyticsLabConfusion,
          description:
              'Multiple students asking similar questions about Lab 4. Consider creating FAQ.',
          icon: Icons.help_outline_rounded,
          iconColor: TAColors.warning,
          actionLabel: l10n.taAnalyticsCreateFAQ,
          isDark: isDark,
          severity: InsightSeverity.warning,
          onAction: () => _createFAQ(),
        ),
        const SizedBox(height: 10),
        TAAIInsightCard(
          title: l10n.taAnalyticsAttendanceReminder,
          description:
              '5 students have missed 2+ consecutive sessions. Send attendance reminder.',
          icon: Icons.notifications_active_rounded,
          iconColor: TAColors.info,
          actionLabel: l10n.taAnalyticsSendReminder,
          isDark: isDark,
          severity: InsightSeverity.info,
          onAction: () => _sendReminder(),
        ),
        const SizedBox(height: 10),
        TAAIInsightCard(
          title: l10n.taAnalyticsPerformancePrediction,
          description:
              'Based on current trends, 2 students are at risk of failing. Review their progress.',
          icon: Icons.analytics_rounded,
          iconColor: TAColors.primary,
          actionLabel: l10n.taAnalyticsViewDetails,
          isDark: isDark,
          severity: InsightSeverity.warning,
          onAction: () => _viewAtRiskDetails(),
        ),
      ],
    );
  }

  Widget _buildBottomSection(AppLocalizations l10n, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              TADeadlineDetectionCard(
                deadlines: _deadlines,
                isDark: isDark,
                selectedCourse: _selectedDeadlineCourse,
                courseOptions: const [
                  'All Courses',
                  'Data Structures',
                  'Algorithms',
                  'Software Engineering',
                ],
                onCourseChanged: (course) {
                  setState(() => _selectedDeadlineCourse = course);
                },
                onDeadlineTap: (deadline) => _handleDeadlineTap(deadline, isDark),
              ),
              const SizedBox(height: 12),
              TASessionComparisonCard(
                currentSession: 'Spring 2024',
                previousSession: 'Fall 2023',
                metrics: _comparisonMetrics,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleDeadlineTap(UpcomingDeadline deadline, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.scaffoldColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TAColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(deadline.icon, color: TAColors.warning, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deadline.title,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${deadline.course} • ${deadline.daysRemaining} days remaining',
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              'View Assignment',
              Icons.assignment,
              () {
                Navigator.pop(context);
                context.push('/ta/labs');
              },
              isDark,
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              'Send Reminder to Students',
              Icons.notifications,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reminder sent for ${deadline.title}'),
                    backgroundColor: TAColors.success,
                  ),
                );
              },
              isDark,
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              'View Submissions',
              Icons.folder_open,
              () {
                Navigator.pop(context);
                context.push('/ta/ai-grading');
              },
              isDark,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        TAQuickInsightsCard(
          insights: _quickInsights,
          isDark: isDark,
          onViewAll: _viewAllInsights,
        ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: TAColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Date range: ${dateRange.start.toString().split(' ')[0]} - ${dateRange.end.toString().split(' ')[0]}',
          ),
          backgroundColor: TAColors.primary,
        ),
      );
      // Reload data with new date range
      _loadAnalyticsData();
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting analytics report...'),
        backgroundColor: TAColors.success,
      ),
    );
  }

  void _sendSupportMessage() {
    _showActionDialog(
      title: 'Send Support Message',
      content: 'Send personalized support messages to 3 struggling students?',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support messages sent successfully!'),
            backgroundColor: TAColors.success,
          ),
        );
      },
    );
  }

  void _createFAQ() {
    _showActionDialog(
      title: 'Create FAQ',
      content: 'Create an FAQ document based on common Lab 4 questions?',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FAQ created and shared with students!'),
            backgroundColor: TAColors.success,
          ),
        );
      },
    );
  }

  void _sendReminder() {
    _showActionDialog(
      title: 'Send Attendance Reminder',
      content: 'Send attendance reminder to 5 students with low attendance?',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminders sent successfully!'),
            backgroundColor: TAColors.success,
          ),
        );
      },
    );
  }

  void _viewAtRiskDetails() {
    // Navigate to student performance screen with at-risk filter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to at-risk students...'),
        backgroundColor: TAColors.info,
      ),
    );
  }

  void _viewAllInsights() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.themeMode == AppThemeMode.dark;
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: TAColors.scaffoldColor(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'All AI Insights',
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: TAColors.textSecondaryColor(isDark),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      TAAIInsightCard(
                        title: 'Performance Decline Detected',
                        description:
                            '3 students showing significant grade drop in recent labs.',
                        icon: Icons.trending_down_rounded,
                        iconColor: TAColors.error,
                        actionLabel: 'Send Support',
                        isDark: isDark,
                        severity: InsightSeverity.critical,
                        onAction: () {
                          Navigator.pop(context);
                          _sendSupportMessage();
                        },
                      ),
                      const SizedBox(height: 10),
                      TAAIInsightCard(
                        title: 'Lab Confusion Detected',
                        description:
                            'Multiple students asking similar questions about Lab 4.',
                        icon: Icons.help_outline_rounded,
                        iconColor: TAColors.warning,
                        actionLabel: 'Create FAQ',
                        isDark: isDark,
                        severity: InsightSeverity.warning,
                        onAction: () {
                          Navigator.pop(context);
                          _createFAQ();
                        },
                      ),
                      const SizedBox(height: 10),
                      TAAIInsightCard(
                        title: 'Attendance Reminder',
                        description:
                            '5 students have missed 2+ consecutive sessions.',
                        icon: Icons.notifications_active_rounded,
                        iconColor: TAColors.info,
                        actionLabel: 'Send Reminder',
                        isDark: isDark,
                        severity: InsightSeverity.info,
                        onAction: () {
                          Navigator.pop(context);
                          _sendReminder();
                        },
                      ),
                      const SizedBox(height: 10),
                      TAAIInsightCard(
                        title: 'Performance Prediction',
                        description:
                            'Based on current trends, 2 students are at risk of failing.',
                        icon: Icons.analytics_rounded,
                        iconColor: TAColors.primary,
                        actionLabel: 'View Details',
                        isDark: isDark,
                        severity: InsightSeverity.warning,
                        onAction: () {
                          Navigator.pop(context);
                          _viewAtRiskDetails();
                        },
                      ),
                      const SizedBox(height: 10),
                      TAAIInsightCard(
                        title: 'Engagement Improvement',
                        description:
                            'Overall class engagement improved by 5% this month.',
                        icon: Icons.celebration_rounded,
                        iconColor: TAColors.success,
                        actionLabel: 'View Report',
                        isDark: isDark,
                        severity: InsightSeverity.success,
                        onAction: () {},
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showActionDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.themeMode == AppThemeMode.dark;
          return AlertDialog(
            backgroundColor: TAColors.cardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              content,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TAColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.confirm,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAttendanceDetails(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(
        isDark: isDark,
        title: 'Attendance Details',
        icon: Icons.people_alt_rounded,
        iconColor: TAColors.primary,
        children: [
          _buildDetailItem('Average Attendance', '88%', TAColors.primary, isDark),
          _buildDetailItem('Perfect Attendance', '15 students', TAColors.success, isDark),
          _buildDetailItem('Low Attendance (<70%)', '5 students', TAColors.error, isDark),
          _buildDetailItem('This Week', '92%', TAColors.info, isDark),
          _buildDetailItem('Last Week', '85%', TAColors.warning, isDark),
          const SizedBox(height: 16),
          _buildActionButton(
            'View Full Attendance Report',
            Icons.assessment,
            () {
              Navigator.pop(context);
              context.push('/ta/courses');
            },
            isDark,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Send Attendance Reminder',
            Icons.notifications,
            () {
              Navigator.pop(context);
              _showActionDialog(
                title: 'Send Reminder',
                content: 'Send attendance reminder to students with low attendance?',
                onConfirm: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminders sent to 5 students'),
                      backgroundColor: TAColors.success,
                    ),
                  );
                },
              );
            },
            isDark,
          ),
        ],
      ),
    );
  }

  void _showSubmissionDetails(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(
        isDark: isDark,
        title: 'Submission Details',
        icon: Icons.assignment_turned_in_rounded,
        iconColor: TAColors.success,
        children: [
          _buildDetailItem('Total Submissions', '156', TAColors.primary, isDark),
          _buildDetailItem('On-Time Submissions', '120 (77%)', TAColors.success, isDark),
          _buildDetailItem('Late Submissions', '28 (18%)', TAColors.warning, isDark),
          _buildDetailItem('Missing Submissions', '8 (5%)', TAColors.error, isDark),
          _buildDetailItem('Pending Review', '23', TAColors.info, isDark),
          const SizedBox(height: 16),
          _buildActionButton(
            'View All Submissions',
            Icons.folder_open,
            () {
              Navigator.pop(context);
              context.push('/ta/labs');
            },
            isDark,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Start AI Grading',
            Icons.auto_fix_high,
            () {
              Navigator.pop(context);
              context.push('/ta/ai-grading');
            },
            isDark,
          ),
        ],
      ),
    );
  }

  void _showEngagementDetails(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(
        isDark: isDark,
        title: 'Engagement Details',
        icon: Icons.trending_up_rounded,
        iconColor: TAColors.info,
        children: [
          _buildDetailItem('Discussion Posts', '45 this week', TAColors.primary, isDark),
          _buildDetailItem('Forum Replies', '78 this week', TAColors.success, isDark),
          _buildDetailItem('Resource Downloads', '234', TAColors.info, isDark),
          _buildDetailItem('Average Session Time', '42 min', TAColors.warning, isDark),
          _buildDetailItem('Active Students', '48/52', TAColors.success, isDark),
          const SizedBox(height: 16),
          _buildActionButton(
            'View Discussions',
            Icons.forum,
            () {
              Navigator.pop(context);
              context.push('/ta/discussions');
            },
            isDark,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'View Student Inbox',
            Icons.inbox,
            () {
              Navigator.pop(context);
              context.push('/ta/student-inbox');
            },
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSheet({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: TAColors.scaffoldColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TAColors.borderColor(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: TAColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TAColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: TAColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: TAColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: TAColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
