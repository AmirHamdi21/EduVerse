import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/grades/grades_cubit.dart';
import '../../bloc/grades/grades_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/responsive.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/grades/grade_model.dart';
import '../../services/api/core_api_client.dart';
import '../../services/api/grades_service.dart';
import '../../services/api/student_stats_service.dart';
import '../../services/storage_service.dart';
import '../../utils/navigation/safe_back.dart';

class GradeAnalysisScreen extends StatefulWidget {
  const GradeAnalysisScreen({super.key});

  @override
  State<GradeAnalysisScreen> createState() => _GradeAnalysisScreenState();
}

class _GradeAnalysisScreenState extends State<GradeAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocProvider(
          create: (context) {
            final coreApiClient = CoreApiClient();
            return GradesCubit(
              gradesService: GradesService(coreApiClient: coreApiClient),
              studentStatsService: StudentStatsService(
                coreApiClient: coreApiClient,
              ),
              storageService: StorageService(),
            );
          },
          child: BlocBuilder<GradesCubit, GradesState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                body: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, isDark, l10n),
                      _buildTabBar(context, isDark, l10n),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(context, state, isDark, l10n),
                            _buildTrendsTab(context, state, isDark, l10n),
                            _buildComparisonTab(context, state, isDark, l10n),
                            _buildInsightsTab(context, state, isDark, l10n),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF8FAFC)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => safeBack(context, '/dashboard'),
              borderRadius: BorderRadius.circular(responsive.radius12),
              child: Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: Icon(
                  iosBackIcon(context),
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  size: 22,
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                    SizedBox(width: responsive.p8),
                    Text(
                      l10n.gradeAnalysis,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: responsive.fontSize20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  l10n.detailedPerformanceInsights,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: responsive.fontSize13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p12,
              vertical: responsive.p8,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(responsive.radius10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: responsive.p4),
                Text(
                  '+5%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.fontSize13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(responsive.radius12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B),
        labelStyle: TextStyle(
          fontSize: responsive.fontSize12,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        padding: EdgeInsets.all(responsive.p4),
        tabs: [
          Tab(text: l10n.overview),
          Tab(text: l10n.trends),
          Tab(text: l10n.comparison),
          Tab(text: l10n.insights),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;
    final stats = state.statistics;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPA Overview Card
          _buildGPAOverviewCard(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p16),

          // Grade Distribution
          _buildGradeDistribution(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p16),

          // Performance Stats
          _buildPerformanceStats(responsive, stats, isDark, l10n),
          SizedBox(height: responsive.p16),

          // Credit Progress
          _buildCreditProgress(responsive, stats, isDark, l10n),
          SizedBox(height: responsive.p20),
        ],
      ),
    );
  }

  Widget _buildGPAOverviewCard(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.academicStanding,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: responsive.fontSize14,
                    ),
                  ),
                  SizedBox(height: responsive.p8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.p16,
                          vertical: responsive.p8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            responsive.radius10,
                          ),
                        ),
                        child: Text(
                          _getAcademicStanding(
                            state.statistics?.cumulativeGPA ?? 0,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.fontSize18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Circular progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: (state.statistics?.cumulativeGPA ?? 0) / 4.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 8,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        state.statistics?.cumulativeGPA.toStringAsFixed(2) ??
                            '0.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.fontSize20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'GPA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: responsive.fontSize11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: responsive.p16),
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                responsive,
                label: l10n.passRate,
                value: '${state.statistics?.passRate.toStringAsFixed(0) ?? 0}%',
                icon: Icons.check_circle_rounded,
              ),
              _buildQuickStat(
                responsive,
                label: l10n.highestGrade,
                value: state.statistics?.highestGrade.label ?? '-',
                icon: Icons.emoji_events_rounded,
              ),
              _buildQuickStat(
                responsive,
                label: l10n.avgPercentage,
                value:
                    '${state.statistics?.averagePercentage.toStringAsFixed(0) ?? 0}%',
                icon: Icons.percent_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    ResponsiveUtil responsive, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 22),
        SizedBox(height: responsive.p4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: responsive.fontSize11,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDistribution(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final distribution = state.statistics?.gradeDistribution ?? {};

    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 22,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.gradeDistribution,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p20),
          // Distribution bars
          _buildDistributionBars(responsive, distribution, isDark),
        ],
      ),
    );
  }

  Widget _buildDistributionBars(
    ResponsiveUtil responsive,
    Map<GradeLetter, int> distribution,
    bool isDark,
  ) {
    final maxCount = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    final grades = [
      GradeLetter.aPlus,
      GradeLetter.a,
      GradeLetter.aMinus,
      GradeLetter.bPlus,
      GradeLetter.b,
      GradeLetter.bMinus,
      GradeLetter.cPlus,
      GradeLetter.c,
      GradeLetter.cMinus,
      GradeLetter.d,
      GradeLetter.f,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: grades.map((grade) {
        final count = distribution[grade] ?? 0;
        final height = maxCount > 0 ? (count / maxCount) * 100 : 0.0;

        return Tooltip(
          message: '${grade.label}: $count courses',
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: responsive.fontSize10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: responsive.p4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: 24,
                height: height.clamp(8.0, 100.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [grade.color.withValues(alpha: 0.7), grade.color],
                  ),
                  borderRadius: BorderRadius.circular(responsive.radius6),
                ),
              ),
              SizedBox(height: responsive.p4),
              Text(
                grade.label,
                style: TextStyle(
                  color: grade.color,
                  fontSize: responsive.fontSize10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceStats(
    ResponsiveUtil responsive,
    GradeStatistics? stats,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.performanceMetrics,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p20),
          // Metrics grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  responsive,
                  isDark,
                  icon: Icons.school_rounded,
                  label: l10n.totalCourses,
                  value: '${stats?.totalCourses ?? 0}',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: _buildMetricCard(
                  responsive,
                  isDark,
                  icon: Icons.check_circle_rounded,
                  label: l10n.passed,
                  value: '${stats?.passedCourses ?? 0}',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  responsive,
                  isDark,
                  icon: Icons.trending_up_rounded,
                  label: l10n.highest,
                  value: stats?.highestGrade.label ?? '-',
                  color: const Color(0xFF6366F1),
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: _buildMetricCard(
                  responsive,
                  isDark,
                  icon: Icons.trending_down_rounded,
                  label: l10n.lowest,
                  value: stats?.lowestGrade.label ?? '-',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    ResponsiveUtil responsive,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(responsive.radius14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: responsive.p12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: responsive.fontSize24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: responsive.fontSize12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditProgress(
    ResponsiveUtil responsive,
    GradeStatistics? stats,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final progress =
        (stats?.completedCredits ?? 0) /
        (stats?.totalCredits ?? 1).clamp(1, double.infinity);

    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(responsive.p10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(responsive.radius12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFF59E0B),
                      size: 22,
                    ),
                  ),
                  SizedBox(width: responsive.p12),
                  Text(
                    l10n.creditProgress,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: responsive.fontSize18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${stats?.completedCredits ?? 0}/${stats?.totalCredits ?? 0}',
                style: TextStyle(
                  color: const Color(0xFFF59E0B),
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p16),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: 12,
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% ${l10n.completed}',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: responsive.fontSize13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPA Trend Chart
          _buildGPATrendCard(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p16),

          // Semester Comparison
          _buildSemesterComparison(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p20),
        ],
      ),
    );
  }

  Widget _buildGPATrendCard(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Color(0xFF6366F1),
                  size: 22,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.gpaTrend,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p24),
          // Simple line chart representation
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: state.gradeTrend.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                final normalizedHeight = (point.gpa / 4.0) * 160;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.p4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // GPA value
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.p8,
                            vertical: responsive.p4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(
                              responsive.radius8,
                            ),
                          ),
                          child: Text(
                            point.gpa.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.fontSize11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.p8),
                        // Bar
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          height: normalizedHeight.clamp(20.0, 160.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF6366F1).withValues(alpha: 0.5),
                                const Color(0xFF6366F1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              responsive.radius8,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.p8),
                        // Semester label
                        Text(
                          point.semesterName,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: responsive.fontSize10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterComparison(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.semesterComparison,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p20),
          // Comparison items
          ...state.gradeTrend.reversed
              .take(3)
              .map(
                (point) => Padding(
                  padding: EdgeInsets.only(bottom: responsive.p12),
                  child: _buildSemesterRow(responsive, point, isDark),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSemesterRow(
    ResponsiveUtil responsive,
    GradeTrendPoint point,
    bool isDark,
  ) {
    final progress = point.gpa / 4.0;
    final color = point.gpa >= 3.5
        ? const Color(0xFF10B981)
        : point.gpa >= 3.0
        ? const Color(0xFF3B82F6)
        : point.gpa >= 2.5
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Container(
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.semesterName,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.p4),
                Text(
                  '${point.creditHours} credits',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: responsive.fontSize12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  point.gpa.toStringAsFixed(2),
                  style: TextStyle(
                    color: color,
                    fontSize: responsive.fontSize20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: responsive.p4),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(
                      height: 6,
                      width: 80 * progress,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTab(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Performance Ranking
          _buildCourseRanking(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p16),

          // Best/Worst Courses
          _buildBestWorstCourses(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p20),
        ],
      ),
    );
  }

  Widget _buildCourseRanking(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final sortedCourses = [...state.courses]
      ..sort((a, b) => b.currentPercentage.compareTo(a.currentPercentage));

    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: const Icon(
                  Icons.leaderboard_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.courseRanking,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p20),
          ...sortedCourses.asMap().entries.take(5).map((entry) {
            final index = entry.key;
            final course = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.p12),
              child: _buildRankingRow(responsive, index + 1, course, isDark),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRankingRow(
    ResponsiveUtil responsive,
    int rank,
    CourseGrade course,
    bool isDark,
  ) {
    final rankColors = [
      const Color(0xFFFBBF24), // Gold
      const Color(0xFF94A3B8), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    final rankColor = rank <= 3
        ? rankColors[rank - 1]
        : const Color(0xFF64748B);

    return Container(
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : course.courseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(color: course.courseColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: rank <= 3 ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.p12),
          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  course.courseCode,
                  style: TextStyle(
                    color: course.courseColor,
                    fontSize: responsive.fontSize12,
                  ),
                ),
              ],
            ),
          ),
          // Grade
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.p10,
                  vertical: responsive.p4,
                ),
                decoration: BoxDecoration(
                  color: course.currentGrade.color,
                  borderRadius: BorderRadius.circular(responsive.radius6),
                ),
                child: Text(
                  course.currentGrade.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.fontSize12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: responsive.p2),
              Text(
                '${course.currentPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: responsive.fontSize11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestWorstCourses(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final sortedCourses = [...state.courses]
      ..sort((a, b) => b.currentPercentage.compareTo(a.currentPercentage));

    final bestCourses = sortedCourses.take(2).toList();
    final worstCourses = sortedCourses.reversed.take(2).toList();

    return Row(
      children: [
        Expanded(
          child: _buildBestWorstCard(
            responsive,
            isDark,
            title: l10n.topPerformers,
            courses: bestCourses,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF10B981),
          ),
        ),
        SizedBox(width: responsive.p12),
        Expanded(
          child: _buildBestWorstCard(
            responsive,
            isDark,
            title: l10n.needsFocus,
            courses: worstCourses,
            icon: Icons.trending_down_rounded,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildBestWorstCard(
    ResponsiveUtil responsive,
    bool isDark, {
    required String title,
    required List<CourseGrade> courses,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: responsive.p8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          ...courses.map(
            (course) => Padding(
              padding: EdgeInsets.only(bottom: responsive.p8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: responsive.fontSize12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${course.currentGrade.label} • ${course.currentPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: responsive.fontSize11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Insights
          _buildAIInsights(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p16),

          // Study Recommendations
          _buildStudyRecommendations(responsive, state, isDark, l10n),
          SizedBox(height: responsive.p16),

          // Goals
          _buildGoalsSection(responsive, isDark, l10n),
          SizedBox(height: responsive.p20),
        ],
      ),
    );
  }

  Widget _buildAIInsights(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final insights = _generateInsights(state);

    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
        ),
        borderRadius: BorderRadius.circular(responsive.radius20),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiInsights,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: responsive.fontSize18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.personalizedRecommendations,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: responsive.fontSize12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p20),
          ...insights.map(
            (insight) => Padding(
              padding: EdgeInsets.only(bottom: responsive.p12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: insight.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(responsive.radius6),
                    ),
                    child: Icon(insight.icon, size: 14, color: insight.color),
                  ),
                  SizedBox(width: responsive.p12),
                  Expanded(
                    child: Text(
                      insight.text,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: responsive.fontSize14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyRecommendations(
    ResponsiveUtil responsive,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Get courses that need attention
    final needsAttention = state.courses
        .where((c) => c.currentPercentage < 80)
        .take(3)
        .toList();

    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.studyRecommendations,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p20),
          if (needsAttention.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    color: const Color(0xFF10B981),
                    size: 48,
                  ),
                  SizedBox(height: responsive.p12),
                  Text(
                    l10n.greatJob,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: responsive.fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.keepUpTheGoodWork,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: responsive.fontSize14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...needsAttention.map(
              (course) => Padding(
                padding: EdgeInsets.only(bottom: responsive.p12),
                child: Container(
                  padding: EdgeInsets.all(responsive.p14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(responsive.radius12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: course.courseColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            responsive.radius10,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            course.courseCode.substring(0, 2),
                            style: TextStyle(
                              color: course.courseColor,
                              fontSize: responsive.fontSize14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.courseName,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: responsive.fontSize14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getRecommendation(course),
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: responsive.fontSize12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(
    ResponsiveUtil responsive,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 24),
              SizedBox(width: responsive.p12),
              Text(
                l10n.academicGoals,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p20),
          _buildGoalItem(
            responsive,
            title: l10n.targetGPA,
            current: '3.55',
            target: '3.70',
            progress: 0.96,
          ),
          SizedBox(height: responsive.p12),
          _buildGoalItem(
            responsive,
            title: l10n.creditGoal,
            current: '47',
            target: '60',
            progress: 0.78,
          ),
          SizedBox(height: responsive.p16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: responsive.p12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(responsive.radius12),
            ),
            child: Center(
              child: Text(
                l10n.setNewGoals,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(
    ResponsiveUtil responsive, {
    required String title,
    required String current,
    required String target,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: responsive.fontSize13,
              ),
            ),
            Text(
              '$current / $target',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.fontSize13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getAcademicStanding(double gpa) {
    if (gpa >= 3.7) return "Dean's List";
    if (gpa >= 3.5) return 'Honors';
    if (gpa >= 3.0) return 'Good Standing';
    if (gpa >= 2.0) return 'Satisfactory';
    return 'Probation';
  }

  List<_Insight> _generateInsights(GradesState state) {
    final insights = <_Insight>[];

    final stats = state.statistics;
    if (stats != null) {
      if (stats.cumulativeGPA >= 3.5) {
        insights.add(
          _Insight(
            text:
                "Your GPA is in the top tier! You're on track for Dean's List recognition.",
            icon: Icons.star_rounded,
            color: const Color(0xFFFBBF24),
          ),
        );
      }

      if (stats.passRate < 100 && stats.totalCourses > 0) {
        insights.add(
          _Insight(
            text:
                'Focus on courses where you scored below 70% to improve your overall performance.',
            icon: Icons.warning_rounded,
            color: const Color(0xFFF59E0B),
          ),
        );
      }

      if (state.gradeTrend.length >= 2) {
        final recent = state.gradeTrend.last;
        final previous = state.gradeTrend[state.gradeTrend.length - 2];
        if (recent.gpa > previous.gpa) {
          insights.add(
            _Insight(
              text:
                  'Great progress! Your GPA increased by ${(recent.gpa - previous.gpa).toStringAsFixed(2)} since last semester.',
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF10B981),
            ),
          );
        }
      }
    }

    if (insights.isEmpty) {
      insights.add(
        _Insight(
          text:
              'Keep up the consistent effort. Regular study habits lead to academic success!',
          icon: Icons.lightbulb_rounded,
          color: const Color(0xFF6366F1),
        ),
      );
    }

    return insights;
  }

  String _getRecommendation(CourseGrade course) {
    if (course.currentPercentage < 60) {
      return 'Prioritize this course. Consider tutoring or study groups.';
    } else if (course.currentPercentage < 70) {
      return 'Schedule extra study sessions for upcoming assessments.';
    } else {
      return 'Review weak areas to maintain your grade.';
    }
  }
}

class _Insight {
  final String text;
  final IconData icon;
  final Color color;

  _Insight({required this.text, required this.icon, required this.color});
}
