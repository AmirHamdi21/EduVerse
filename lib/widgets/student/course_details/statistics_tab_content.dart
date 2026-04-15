import 'package:flutter/material.dart';

class StatisticsTabContent extends StatefulWidget {
  final bool isDark;

  const StatisticsTabContent({super.key, required this.isDark});

  @override
  State<StatisticsTabContent> createState() => _StatisticsTabContentState();
}

class _StatisticsTabContentState extends State<StatisticsTabContent>
    with TickerProviderStateMixin {
  late AnimationController _gpaController;
  late AnimationController _gradeController;
  late AnimationController _topicsController;
  late AnimationController _breakdownController;

  late Animation<double> _gpaAnimation;
  late Animation<double> _gradeAnimation;
  late Animation<double> _topicsAnimation;
  late Animation<double> _breakdownAnimation;

  @override
  void initState() {
    super.initState();
    _gpaController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _gradeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _topicsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _breakdownController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _gpaAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _gpaController, curve: Curves.easeOut));
    _gradeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _gradeController, curve: Curves.easeOut));
    _topicsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _topicsController, curve: Curves.easeOut),
    );
    _breakdownAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _breakdownController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gpaController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        _gradeController.forward();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        _topicsController.forward();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _breakdownController.forward();
      });
    });
  }

  @override
  void dispose() {
    _gpaController.dispose();
    _gradeController.dispose();
    _topicsController.dispose();
    _breakdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);

    return Column(
      children: [
        // GPA and Grade Cards
        Row(
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _gpaAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1).animate(
                    CurvedAnimation(
                      parent: _gpaController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: _buildGPACard(bgColor, textColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FadeTransition(
                opacity: _gradeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1).animate(
                    CurvedAnimation(
                      parent: _gradeController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: _buildAverageGradeCard(bgColor, textColor),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Scores by Topic Card
        FadeTransition(
          opacity: _topicsAnimation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _topicsController,
                    curve: Curves.easeOut,
                  ),
                ),
            child: _buildScoresByTopicCard(
              bgColor,
              textColor,
              secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Grade Breakdown Card
        FadeTransition(
          opacity: _breakdownAnimation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _breakdownController,
                    curve: Curves.easeOut,
                  ),
                ),
            child: _buildGradeBreakdownCard(
              bgColor,
              textColor,
              secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGPACard(Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155DFC).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Current GPA',
              style: TextStyle(
                color: Color(0xFFB3D9FF),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '3.8',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageGradeCard(Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAD5DFF), Color(0xFF9D3AFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D3AFF).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Average Grade',
              style: TextStyle(
                color: Color(0xFFE5C9FF),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '87.6%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoresByTopicCard(
    Color bgColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final topics = [
      {'name': 'AI Foundations', 'score': '92', 'total': '100'},
      {'name': 'Machine Learning', 'score': '85', 'total': '100'},
      {'name': 'Neural Networks', 'score': '88', 'total': '100'},
      {'name': 'Deep Learning', 'score': '78', 'total': '100'},
      {'name': 'NLP Basics', 'score': '95', 'total': '100'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: widget.isDark
              ? const Color(0xFF3D3D54)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      color: const Color(0xFF155DFC),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scores by Topic',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(topics.length, (index) {
                final topic = topics[index];
                final score = int.parse(topic['score']!);
                final total = int.parse(topic['total']!);
                final percentage = (score / total) * 100;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == topics.length - 1 ? 0 : 16,
                  ),
                  child: _buildTopicScore(
                    topic['name']!,
                    '${topic['score']}/${topic['total']}',
                    percentage,
                    textColor,
                    secondaryTextColor,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicScore(
    String topicName,
    String score,
    double percentage,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              topicName,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Arimo',
              ),
            ),
            Text(
              score,
              style: const TextStyle(
                color: Color(0xFF155DFC),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF3D3D54)
                : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF3D3D54)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradeBreakdownCard(
    Color bgColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final breakdown = [
      {'name': 'Assignments (40%)', 'percentage': '89'},
      {'name': 'Labs (30%)', 'percentage': '92'},
      {'name': 'Quizzes (20%)', 'percentage': '85'},
      {'name': 'Participation (10%)', 'percentage': '95'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: widget.isDark
              ? const Color(0xFF3D3D54)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grade Breakdown',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(breakdown.length, (index) {
                final item = breakdown[index];
                final isLast = index == breakdown.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name']!,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Arimo',
                            ),
                          ),
                          Text(
                            '${item['percentage']}%',
                            style: const TextStyle(
                              color: Color(0xFF155DFC),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        color: widget.isDark
                            ? const Color(0xFF3D3D54)
                            : const Color(0xFFE5E7EB),
                        height: 1,
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
