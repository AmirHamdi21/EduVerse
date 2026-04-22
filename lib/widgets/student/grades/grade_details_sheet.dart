import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/utils/responsive.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/grades/grade_model.dart';

class GradeDetailsSheet extends StatefulWidget {
  final CourseGrade course;
  final bool isDark;

  const GradeDetailsSheet({
    super.key,
    required this.course,
    required this.isDark,
  });

  @override
  State<GradeDetailsSheet> createState() => _GradeDetailsSheetState();
}

class _GradeDetailsSheetState extends State<GradeDetailsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(responsive, l10n),
          _buildCourseInfo(responsive),
          _buildTabBar(responsive, l10n),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssessmentsTab(responsive, l10n),
                _buildGradeBreakdownTab(responsive, l10n),
                _buildAnalysisTab(responsive, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: responsive.p16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.course.courseColor,
                      widget.course.courseColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(responsive.radius16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.course.courseColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.course.courseCode.substring(0, 2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                      widget.course.courseName,
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                        fontSize: responsive.fontSize18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: responsive.p4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.p8,
                            vertical: responsive.p2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.course.courseColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              responsive.radius6,
                            ),
                          ),
                          child: Text(
                            widget.course.courseCode,
                            style: TextStyle(
                              color: widget.course.courseColor,
                              fontSize: responsive.fontSize12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: responsive.p8),
                        Text(
                          '${widget.course.creditHours} ${l10n.credits}',
                          style: TextStyle(
                            color: widget.isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: responsive.fontSize12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: EdgeInsets.all(responsive.p8),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(responsive.radius10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(ResponsiveUtil responsive) {
    final grade = widget.course.currentGrade;

    return Container(
      margin: EdgeInsets.all(responsive.p16),
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            responsive,
            label: 'Grade',
            value: grade.label,
            color: grade.color,
            isLarge: true,
          ),
          _buildInfoDivider(responsive),
          _buildInfoItem(
            responsive,
            label: 'Percentage',
            value: '${widget.course.currentPercentage.toStringAsFixed(1)}%',
            color: const Color(0xFF3B82F6),
          ),
          _buildInfoDivider(responsive),
          _buildInfoItem(
            responsive,
            label: 'GPA',
            value: grade.gpa.toStringAsFixed(2),
            color: const Color(0xFF10B981),
          ),
          _buildInfoDivider(responsive),
          _buildInfoItem(
            responsive,
            label: 'Rank',
            value: '#5',
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ResponsiveUtil responsive, {
    required String label,
    required String value,
    required Color color,
    bool isLarge = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: widget.isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
            fontSize: responsive.fontSize11,
          ),
        ),
        SizedBox(height: responsive.p4),
        Container(
          padding: isLarge
              ? EdgeInsets.symmetric(
                  horizontal: responsive.p12,
                  vertical: responsive.p8,
                )
              : null,
          decoration: isLarge
              ? BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius10),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              color: isLarge
                  ? color
                  : (widget.isDark ? Colors.white : const Color(0xFF1E293B)),
              fontSize: isLarge ? responsive.fontSize20 : responsive.fontSize16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoDivider(ResponsiveUtil responsive) {
    return Container(
      width: 1,
      height: 40,
      color: widget.isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildTabBar(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.p16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: widget.course.courseColor,
          borderRadius: BorderRadius.circular(responsive.radius10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: widget.isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B),
        labelStyle: TextStyle(
          fontSize: responsive.fontSize13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: responsive.fontSize13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        padding: EdgeInsets.all(responsive.p4),
        tabs: [
          Tab(text: l10n.assessments),
          Tab(text: l10n.breakdown),
          Tab(text: l10n.analysis),
        ],
      ),
    );
  }

  Widget _buildAssessmentsTab(
    ResponsiveUtil responsive,
    AppLocalizations l10n,
  ) {
    final assessments = widget.course.assessments;

    return ListView.builder(
      padding: EdgeInsets.all(responsive.p16),
      itemCount: assessments.length,
      itemBuilder: (context, index) {
        final assessment = assessments[index];
        return _buildAssessmentCard(responsive, assessment);
      },
    );
  }

  Widget _buildAssessmentCard(
    ResponsiveUtil responsive,
    AssessmentGrade assessment,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius14),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: widget.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAssessmentDetails(assessment),
          borderRadius: BorderRadius.circular(responsive.radius14),
          child: Padding(
            padding: EdgeInsets.all(responsive.p14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: assessment.type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(responsive.radius12),
                  ),
                  child: Icon(
                    assessment.type.icon,
                    color: assessment.type.color,
                    size: 22,
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.name,
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: responsive.p4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.p6,
                              vertical: responsive.p2,
                            ),
                            decoration: BoxDecoration(
                              color: assessment.type.color.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                responsive.radius4,
                              ),
                            ),
                            child: Text(
                              assessment.type.label,
                              style: TextStyle(
                                color: assessment.type.color,
                                fontSize: responsive.fontSize10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: responsive.p8),
                          Text(
                            'Weight: ${assessment.weight.toInt()}%',
                            style: TextStyle(
                              color: widget.isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontSize: responsive.fontSize11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (assessment.isGraded)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.p10,
                          vertical: responsive.p6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              assessment.gradeLetter.color,
                              assessment.gradeLetter.color.withValues(
                                alpha: 0.8,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            responsive.radius8,
                          ),
                        ),
                        child: Text(
                          assessment.gradeLetter.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.fontSize13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.p4),
                      Text(
                        '${assessment.score.toInt()}/${assessment.maxScore.toInt()}',
                        style: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: responsive.fontSize12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p12,
                      vertical: responsive.p8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(responsive.radius8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: responsive.p4),
                        Text(
                          'Pending',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: responsive.fontSize12,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildGradeBreakdownTab(
    ResponsiveUtil responsive,
    AppLocalizations l10n,
  ) {
    final assessments = widget.course.assessments;
    final typeGroups = <AssessmentType, List<AssessmentGrade>>{};

    for (final assessment in assessments) {
      typeGroups[assessment.type] = [
        ...(typeGroups[assessment.type] ?? []),
        assessment,
      ];
    }

    return ListView(
      padding: EdgeInsets.all(responsive.p16),
      children: [
        // Weight distribution
        _buildWeightDistribution(responsive, l10n),
        SizedBox(height: responsive.p20),

        // By category
        Text(
          l10n.byCategory,
          style: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: responsive.p12),
        ...typeGroups.entries.map(
          (entry) => _buildCategoryBreakdown(
            responsive,
            type: entry.key,
            assessments: entry.value,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightDistribution(
    ResponsiveUtil responsive,
    AppLocalizations l10n,
  ) {
    final assessments = widget.course.assessments;
    final typeWeights = <AssessmentType, double>{};

    for (final assessment in assessments) {
      typeWeights[assessment.type] =
          (typeWeights[assessment.type] ?? 0) + assessment.weight;
    }

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius10),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.weightDistribution,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p16),
          // Progress bars for each type
          ...typeWeights.entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: responsive.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            entry.key.icon,
                            size: 16,
                            color: entry.key.color,
                          ),
                          SizedBox(width: responsive.p8),
                          Text(
                            entry.key.label,
                            style: TextStyle(
                              color: widget.isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontSize: responsive.fontSize13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value.toInt()}%',
                        style: TextStyle(
                          color: entry.key.color,
                          fontSize: responsive.fontSize13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (entry.value / 100).clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                entry.key.color,
                                entry.key.color.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
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
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    ResponsiveUtil responsive, {
    required AssessmentType type,
    required List<AssessmentGrade> assessments,
  }) {
    final gradedAssessments = assessments.where((a) => a.isGraded).toList();
    final averageScore = gradedAssessments.isNotEmpty
        ? gradedAssessments.map((a) => a.percentage).reduce((a, b) => a + b) /
              gradedAssessments.length
        : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : type.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(responsive.radius14),
        border: Border.all(color: type.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(responsive.radius12),
            ),
            child: Icon(type.icon, color: type.color, size: 22),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${gradedAssessments.length}/${assessments.length} graded',
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: responsive.fontSize12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${averageScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: type.color,
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Average',
                style: TextStyle(
                  color: widget.isDark
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

  Widget _buildAnalysisTab(ResponsiveUtil responsive, AppLocalizations l10n) {
    return ListView(
      padding: EdgeInsets.all(responsive.p16),
      children: [
        _buildPerformanceTrend(responsive, l10n),
        SizedBox(height: responsive.p16),
        _buildStrengthsWeaknesses(responsive, l10n),
        SizedBox(height: responsive.p16),
        _buildProjections(responsive, l10n),
      ],
    );
  }

  Widget _buildPerformanceTrend(
    ResponsiveUtil responsive,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.performanceTrend,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p16),
          // Simple bar chart representation
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.course.assessments
                  .where((a) => a.isGraded)
                  .take(5)
                  .map((assessment) {
                    final height = (assessment.percentage / 100) * 80;
                    return Tooltip(
                      message:
                          '${assessment.name}: ${assessment.percentage.toStringAsFixed(0)}%',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: height.clamp(10.0, 80.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  assessment.type.color.withValues(alpha: 0.8),
                                  assessment.type.color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                responsive.radius6,
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.p4),
                          Icon(
                            assessment.type.icon,
                            size: 14,
                            color: assessment.type.color,
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsWeaknesses(
    ResponsiveUtil responsive,
    AppLocalizations l10n,
  ) {
    final gradedAssessments = widget.course.assessments
        .where((a) => a.isGraded)
        .toList();
    if (gradedAssessments.isEmpty) return const SizedBox.shrink();

    gradedAssessments.sort((a, b) => b.percentage.compareTo(a.percentage));
    final strengths = gradedAssessments.take(2).toList();
    final weaknesses = gradedAssessments.reversed.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strengths
        _buildStrengthWeaknessCard(
          responsive,
          title: l10n.strengths,
          items: strengths,
          icon: Icons.thumb_up_rounded,
          color: const Color(0xFF10B981),
        ),
        SizedBox(height: responsive.p12),
        // Weaknesses
        _buildStrengthWeaknessCard(
          responsive,
          title: l10n.areasForImprovement,
          items: weaknesses,
          icon: Icons.trending_down_rounded,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildStrengthWeaknessCard(
    ResponsiveUtil responsive, {
    required String title,
    required List<AssessmentGrade> items,
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
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: responsive.p8),
              child: Row(
                children: [
                  Icon(item.type.icon, size: 16, color: item.type.color),
                  SizedBox(width: responsive.p8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                        fontSize: responsive.fontSize13,
                      ),
                    ),
                  ),
                  Text(
                    '${item.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: responsive.fontSize13,
                      fontWeight: FontWeight.w600,
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

  Widget _buildProjections(ResponsiveUtil responsive, AppLocalizations l10n) {
    final pending = widget.course.assessments
        .where((a) => !a.isGraded)
        .toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    final currentScore = widget.course.totalScore;
    final remainingWeight = pending.fold(0.0, (sum, a) => sum + a.weight);

    // Calculate what's needed for each grade
    final gradeTargets = [
      (GradeLetter.a, 90.0),
      (GradeLetter.b, 80.0),
      (GradeLetter.c, 70.0),
    ];

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius10),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                l10n.gradeProjections,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p16),
          ...gradeTargets.map((target) {
            final neededTotal = target.$2;
            final neededRemaining = remainingWeight > 0
                ? ((neededTotal - currentScore) / remainingWeight * 100).clamp(
                    0,
                    100,
                  )
                : 0;
            final isPossible = neededRemaining <= 100;

            return Padding(
              padding: EdgeInsets.only(bottom: responsive.p10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p8,
                      vertical: responsive.p4,
                    ),
                    decoration: BoxDecoration(
                      color: target.$1.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(responsive.radius6),
                    ),
                    child: Center(
                      child: Text(
                        target.$1.label,
                        style: TextStyle(
                          color: target.$1.color,
                          fontSize: responsive.fontSize12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.p12),
                  Expanded(
                    child: Text(
                      isPossible
                          ? 'Need ${neededRemaining.toStringAsFixed(0)}% on remaining'
                          : 'Not achievable',
                      style: TextStyle(
                        color: widget.isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: responsive.fontSize13,
                      ),
                    ),
                  ),
                  Icon(
                    isPossible
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 18,
                    color: isPossible
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAssessmentDetails(AssessmentGrade assessment) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.responsive.p20),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: assessment.type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      context.responsive.radius14,
                    ),
                  ),
                  child: Icon(
                    assessment.type.icon,
                    color: assessment.type.color,
                    size: 24,
                  ),
                ),
                SizedBox(width: context.responsive.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.name,
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: context.responsive.fontSize18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        assessment.type.label,
                        style: TextStyle(
                          color: assessment.type.color,
                          fontSize: context.responsive.fontSize13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.responsive.p20),
            if (assessment.isGraded) ...[
              _buildDetailRow(
                context.responsive,
                'Score',
                '${assessment.score.toInt()}/${assessment.maxScore.toInt()}',
              ),
              _buildDetailRow(
                context.responsive,
                'Percentage',
                '${assessment.percentage.toStringAsFixed(1)}%',
              ),
              _buildDetailRow(
                context.responsive,
                'Grade',
                assessment.gradeLetter.label,
              ),
            ],
            _buildDetailRow(
              context.responsive,
              'Weight',
              '${assessment.weight.toInt()}%',
            ),
            if (assessment.gradedDate != null)
              _buildDetailRow(
                context.responsive,
                'Graded Date',
                '${assessment.gradedDate!.day}/${assessment.gradedDate!.month}/${assessment.gradedDate!.year}',
              ),
            if (assessment.feedback != null) ...[
              SizedBox(height: context.responsive.p12),
              Text(
                'Feedback',
                style: TextStyle(
                  color: widget.isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: context.responsive.fontSize12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.responsive.p6),
              Container(
                padding: EdgeInsets.all(context.responsive.p12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(
                    context.responsive.radius10,
                  ),
                ),
                child: Text(
                  assessment.feedback!,
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontSize: context.responsive.fontSize14,
                  ),
                ),
              ),
            ],
            SizedBox(height: context.responsive.p20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    ResponsiveUtil responsive,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.p10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: widget.isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              fontSize: responsive.fontSize14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: responsive.fontSize14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
