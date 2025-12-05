import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../common/animated_progress_bar.dart';

class StudentCoursesSection extends StatefulWidget {
  const StudentCoursesSection({super.key});

  @override
  State<StudentCoursesSection> createState() => _StudentCoursesSectionState();
}

class _StudentCoursesSectionState extends State<StudentCoursesSection>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myCoursesSection,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101727),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildAnimatedCourseCard(
              _cardControllers[0],
              title: l10n.introductionToAI,
              instructor: l10n.drSarahFarley,
              progress: 0.68,
              isDark: isDark,
              l10n: l10n,
            ),
            const SizedBox(height: 12),
            _buildAnimatedCourseCard(
              _cardControllers[1],
              title: l10n.dataStructures,
              instructor: l10n.drMarkGoldberg,
              progress: 0.45,
              isDark: isDark,
              l10n: l10n,
            ),
            const SizedBox(height: 12),
            _buildAnimatedCourseCard(
              _cardControllers[2],
              title: l10n.calculusII,
              instructor: l10n.drJessicaPeterson,
              progress: 0.72,
              isDark: isDark,
              l10n: l10n,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCourseCard(
    AnimationController controller, {
    required String title,
    required String instructor,
    required double progress,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: _buildCourseCard(
            title: title,
            instructor: instructor,
            progress: progress,
            isDark: isDark,
            l10n: l10n,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String instructor,
    required double progress,
    required bool isDark,
    required AppLocalizations l10n,
  }) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF50A2FF), Color(0xFF155CFB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.book, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF101727),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF495565),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            instructor,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF495565),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.materials}: 12',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF495565),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}% ${l10n.complete}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF495565),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CompactAnimatedProgressBar(
                  value: progress,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE5E7EB),
                  valueColor: const Color(0xFF155CFB),
                  minHeight: 6,
                  duration: const Duration(milliseconds: 1500),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF155CFB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(l10n.continueButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isDark ? Colors.white54 : const Color(0xFF155CFB),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      l10n.materials,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF155CFB),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
