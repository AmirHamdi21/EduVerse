import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'dart:math' as math;

class TAQuizStatisticsScreen extends StatefulWidget {
  final QuizModel quiz;
  const TAQuizStatisticsScreen({super.key, required this.quiz});
  @override
  State<TAQuizStatisticsScreen> createState() => _SS();
}

class _SS extends State<TAQuizStatisticsScreen> {
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
          backgroundColor: TAColors.background(dk),
          body: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: dk
                      ? TAColors.darkHeaderGradient
                      : TAColors.headerGradient,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () =>
                                  safeBack(context, '/ta/dashboard'),
                              icon: Icon(
                                iosBackIcon(context),
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
                    ),
                    Expanded(
                      child:
                          BlocBuilder<QuizManagementCubit, QuizManagementState>(
                            builder: (_, s) {
                              if (s is! QuizMgmtLoaded) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: TAColors.primary,
                                  ),
                                );
                              }
                              final loading =
                                  s.loadingStatistics[widget.quiz.id] == true;
                              final stats = s.statisticsMap[widget.quiz.id];
                              if (loading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: TAColors.primary,
                                  ),
                                );
                              }
                              if (stats == null) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bar_chart_rounded,
                                        size: 56,
                                        color: TAColors.textTertiaryColor(dk),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No statistics available',
                                        style: TextStyle(
                                          color: TAColors.textSecondaryColor(
                                            dk,
                                          ),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
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

  Widget _content(bool dk, QuizStatisticsModel stats) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    physics: const BouncingScrollPhysics(),
    children: [
      Row(
        children: [
          Expanded(
            child: _ov(
              dk,
              'Total Attempts',
              '${stats.totalAttempts}',
              Icons.people_rounded,
              TAColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ov(
              dk,
              'Pass Rate',
              '${stats.passRate.toStringAsFixed(1)}%',
              Icons.check_circle_rounded,
              TAColors.success,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _ov(
              dk,
              'Avg Score',
              stats.averageScore.toStringAsFixed(1),
              Icons.trending_up_rounded,
              TAColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ov(
              dk,
              'Highest',
              stats.highestScore.toStringAsFixed(1),
              Icons.emoji_events_rounded,
              TAColors.warning,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _ov(
        dk,
        'Lowest Score',
        stats.lowestScore.toStringAsFixed(1),
        Icons.trending_down_rounded,
        TAColors.error,
      ),
      const SizedBox(height: 20),
      _chart(dk, stats),
      const SizedBox(height: 20),
      if (stats.questionStats.isNotEmpty) ...[
        Text(
          'Per-Question Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TAColors.textPrimaryColor(dk),
          ),
        ),
        const SizedBox(height: 12),
        ...stats.questionStats.asMap().entries.map(
          (e) => _qStat(dk, e.key, e.value),
        ),
      ],
    ],
  );

  Widget _ov(bool dk, String l, String v, IconData ic, Color c) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TAColors.cardColor(dk),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: TAColors.borderColor(dk).withValues(alpha: 0.5),
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
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(ic, color: c, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                v,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: TAColors.textPrimaryColor(dk),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l,
                style: TextStyle(
                  fontSize: 12,
                  color: TAColors.textTertiaryColor(dk),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _chart(bool dk, QuizStatisticsModel stats) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: TAColors.cardColor(dk),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: TAColors.borderColor(dk).withValues(alpha: 0.5),
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
            color: TAColors.textPrimaryColor(dk),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _BP(
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
            _leg(TAColors.info, 'Avg'),
            _leg(TAColors.warning, 'High'),
            _leg(TAColors.error, 'Low'),
            _leg(TAColors.success, 'Pass%'),
          ],
        ),
      ],
    ),
  );

  Widget _leg(Color c, String l) => Row(
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
        style: const TextStyle(
          fontSize: 11,
          color: TAColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  Widget _qStat(bool dk, int idx, Map<String, dynamic> qs) {
    final cr = (qs['correctRate'] ?? qs['correctPercentage'] ?? 0.0) as num;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(dk),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${idx + 1}',
              style: const TextStyle(
                color: TAColors.primary,
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
                color: TAColors.textPrimaryColor(dk),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (cr >= 70
                          ? TAColors.success
                          : cr >= 40
                          ? TAColors.warning
                          : TAColors.error)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${cr.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cr >= 70
                    ? TAColors.success
                    : cr >= 40
                    ? TAColors.warning
                    : TAColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BP extends CustomPainter {
  final double avg, high, low, pass;
  final bool isDark;
  _BP({
    required this.avg,
    required this.high,
    required this.low,
    required this.pass,
    required this.isDark,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final mx = math.max(
      100.0,
      math.max(high, math.max(avg, math.max(low, pass))),
    );
    final vals = [avg, high, low, pass];
    final cols = [
      TAColors.info,
      TAColors.warning,
      TAColors.error,
      TAColors.success,
    ];
    final bw = size.width / 6;
    final gap = (size.width - bw * 4) / 5;
    for (var i = 0; i < 4; i++) {
      final h = (vals[i] / mx) * (size.height - 20);
      final x = gap + i * (bw + gap);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, bw, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(r, Paint()..color = cols[i].withValues(alpha: 0.2));
      canvas.drawRRect(
        r,
        Paint()
          ..color = cols[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: vals[i].toStringAsFixed(1),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: cols[i],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + bw / 2 - tp.width / 2, size.height - h - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
