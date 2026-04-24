import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class InstructorQuizStatisticsScreen extends StatefulWidget {
  final QuizModel quiz;
  const InstructorQuizStatisticsScreen({super.key, required this.quiz});
  @override
  State<InstructorQuizStatisticsScreen> createState() => _StatsState();
}

class _StatsState extends State<InstructorQuizStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizManagementCubit>().loadStatistics(widget.quiz.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, ts) {
        final dk = ts.isDark;
        return Scaffold(
          backgroundColor: InstructorColors.background(dk),
          body: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: dk
                      ? InstructorColors.darkHeaderGradient
                      : InstructorColors.headerGradient,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _header(dk),
                    Expanded(
                      child:
                          BlocBuilder<QuizManagementCubit, QuizManagementState>(
                            builder: (_, s) {
                              if (s is! QuizMgmtLoaded)
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: InstructorColors.primary,
                                  ),
                                );
                              final loading =
                                  s.loadingStatistics[widget.quiz.id] == true;
                              final stats = s.statisticsMap[widget.quiz.id];
                              if (loading)
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: InstructorColors.primary,
                                  ),
                                );
                              if (stats == null) return _empty(dk);
                              return _content(dk, stats);
                            },
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(bool dk) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quiz Statistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.quiz.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _empty(bool dk) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bar_chart_rounded,
          size: 56,
          color: InstructorColors.textTertiaryColor(dk),
        ),
        const SizedBox(height: 16),
        Text(
          'No statistics available',
          style: TextStyle(
            color: InstructorColors.textSecondaryColor(dk),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _content(bool dk, QuizStatisticsModel stats) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    physics: const BouncingScrollPhysics(),
    children: [
      // Overview cards
      Row(
        children: [
          Expanded(
            child: _overviewCard(
              dk,
              'Total Attempts',
              '${stats.totalAttempts}',
              Icons.people_rounded,
              InstructorColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _overviewCard(
              dk,
              'Pass Rate',
              '${stats.passRate.toStringAsFixed(1)}%',
              Icons.check_circle_rounded,
              InstructorColors.success,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _overviewCard(
              dk,
              'Avg Score',
              stats.averageScore.toStringAsFixed(1),
              Icons.trending_up_rounded,
              InstructorColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _overviewCard(
              dk,
              'Highest',
              stats.highestScore.toStringAsFixed(1),
              Icons.emoji_events_rounded,
              InstructorColors.warning,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _overviewCard(
        dk,
        'Lowest Score',
        stats.lowestScore.toStringAsFixed(1),
        Icons.trending_down_rounded,
        InstructorColors.error,
      ),
      const SizedBox(height: 20),
      // Score distribution chart
      _chartCard(dk, stats),
      const SizedBox(height: 20),
      // Per-question stats
      if (stats.questionStats.isNotEmpty) ...[
        Text(
          'Per-Question Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: InstructorColors.textPrimaryColor(dk),
          ),
        ),
        const SizedBox(height: 12),
        ...stats.questionStats.asMap().entries.map(
          (e) => _questionStatCard(dk, e.key, e.value),
        ),
      ],
    ],
  );

  Widget _overviewCard(
    bool dk,
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dk ? 0.15 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: InstructorColors.textPrimaryColor(dk),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: InstructorColors.textTertiaryColor(dk),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _chartCard(bool dk, QuizStatisticsModel stats) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score Overview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: InstructorColors.textPrimaryColor(dk),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _BarChartPainter(
              avg: stats.averageScore,
              high: stats.highestScore,
              low: stats.lowestScore,
              pass: stats.passRate,
              isDark: dk,
            ),
            size: const Size(double.infinity, 180),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legend(InstructorColors.info, 'Avg'),
            _legend(InstructorColors.warning, 'High'),
            _legend(InstructorColors.error, 'Low'),
            _legend(InstructorColors.success, 'Pass%'),
          ],
        ),
      ],
    ),
  );

  Widget _legend(Color c, String l) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        l,
        style: TextStyle(
          fontSize: 11,
          color: InstructorColors.textTertiaryColor(false),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  Widget _questionStatCard(bool dk, int idx, Map<String, dynamic> qs) {
    final correctRate =
        (qs['correctRate'] ?? qs['correctPercentage'] ?? 0.0) as num;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(dk),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${idx + 1}',
              style: const TextStyle(
                color: InstructorColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              qs['questionText']?.toString() ?? 'Question ${idx + 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: InstructorColors.textPrimaryColor(dk),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (correctRate >= 70
                          ? InstructorColors.success
                          : correctRate >= 40
                          ? InstructorColors.warning
                          : InstructorColors.error)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${correctRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: correctRate >= 70
                    ? InstructorColors.success
                    : correctRate >= 40
                    ? InstructorColors.warning
                    : InstructorColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final double avg, high, low, pass;
  final bool isDark;
  _BarChartPainter({
    required this.avg,
    required this.high,
    required this.low,
    required this.pass,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = math.max(
      100.0,
      math.max(high, math.max(avg, math.max(low, pass))),
    );
    final values = [avg, high, low, pass];
    final colors = [
      InstructorColors.info,
      InstructorColors.warning,
      InstructorColors.error,
      InstructorColors.success,
    ];
    final barW = size.width / 6;
    final gap = (size.width - barW * 4) / 5;

    for (var i = 0; i < 4; i++) {
      final h = (values[i] / maxVal) * (size.height - 20);
      final x = gap + i * (barW + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barW, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, Paint()..color = colors[i].withValues(alpha: 0.2));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Value text
      final tp = TextPainter(
        text: TextSpan(
          text: values[i].toStringAsFixed(1),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: colors[i],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + barW / 2 - tp.width / 2, size.height - h - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
