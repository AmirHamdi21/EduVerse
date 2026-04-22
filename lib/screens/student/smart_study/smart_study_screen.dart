import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/smart_study/smart_study_cubit.dart';
import '../../../bloc/smart_study/smart_study_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/smart_study/smart_study_app_bar.dart';
import '../../../widgets/student/smart_study/smart_study_tabs.dart';
import '../../../widgets/student/smart_study/smart_study_filters.dart';
import '../../../widgets/student/smart_study/topic_review_card.dart';
import '../../../widgets/student/smart_study/study_schedule_section.dart';
import '../../../widgets/student/smart_study/ai_insight_card.dart';

class SmartStudyScreen extends StatelessWidget {
  const SmartStudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SmartStudyCubit()..initialize(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;

          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0A0A0A)
                : const Color(0xFFF9FAFB),
            body: SafeArea(
              child: BlocConsumer<SmartStudyCubit, SmartStudyState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    _showErrorSnackBar(context, state.errorMessage!, isDark);
                    context.read<SmartStudyCubit>().clearError();
                  }
                  if (state.successMessage != null) {
                    _showSuccessSnackBar(
                      context,
                      state.successMessage!,
                      isDark,
                    );
                    context.read<SmartStudyCubit>().clearSuccess();
                  }
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return _buildLoadingState(isDark);
                  }

                  return Column(
                    children: [
                      SmartStudyAppBar(isDark: isDark),
                      SmartStudyTabs(isDark: isDark),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              state.currentTab == SmartStudyTab.topicsToReview
                              ? _buildTopicsTab(context, state, isDark)
                              : _buildScheduleTab(context, state, isDark),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: _buildFAB(context, isDark),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF2B7FFF) : const Color(0xFF155DFC),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your study plan...',
            style: TextStyle(
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsTab(
    BuildContext context,
    SmartStudyState state,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      key: const ValueKey('topics'),
      slivers: [
        SliverToBoxAdapter(child: SmartStudyFilters(isDark: isDark)),
        if (state.filteredTopics.isEmpty)
          SliverFillRemaining(child: _buildEmptyState(l10n, isDark))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index < state.filteredTopics.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TopicReviewCard(
                      topic: state.filteredTopics[index],
                      isDark: isDark,
                    ),
                  );
                }
                return null;
              }, childCount: state.filteredTopics.length),
            ),
          ),
        if (state.filteredTopics.isNotEmpty && state.aiInsight != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: AiInsightCard(
                insight: state.aiInsight!,
                isDark: isDark,
                onBookmarkToggle: () {
                  context.read<SmartStudyCubit>().toggleInsightBookmark();
                },
                onRefresh: () {
                  context.read<SmartStudyCubit>().regeneratePlan();
                },
              ),
            ),
          ),
        if (state.filteredTopics.isNotEmpty && state.aiInsight == null)
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildScheduleTab(
    BuildContext context,
    SmartStudyState state,
    bool isDark,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('schedule'),
      padding: const EdgeInsets.only(bottom: 100),
      child: StudyScheduleSection(
        schedule: state.weekSchedule,
        isDark: isDark,
        isOptimizing: state.isOptimizing,
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2939).withValues(alpha: 0.5)
                  : const Color(0xFFE5E7EB).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.smartStudyNoTopics,
            style: TextStyle(
              color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.smartStudyNoTopicsHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B7FFF).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQuickActionsSheet(context, isDark),
          borderRadius: BorderRadius.circular(28),
          child: const Icon(
            Icons.assistant_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showQuickActionsSheet(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: isDark
                      ? const Color(0xFF364153)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.smartStudyQuickActions,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF101828),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickAction(
              context: context,
              icon: Icons.play_circle_outline_rounded,
              title: l10n.smartStudyStartSession,
              subtitle: l10n.smartStudyStartSessionDesc,
              color: const Color(0xFF10B981),
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                // Start study session
              },
            ),
            _buildQuickAction(
              context: context,
              icon: Icons.quiz_outlined,
              title: l10n.smartStudyQuickQuiz,
              subtitle: l10n.smartStudyQuickQuizDesc,
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                // Start quick quiz
              },
            ),
            _buildQuickAction(
              context: context,
              icon: Icons.style_outlined,
              title: l10n.smartStudyFlashcards,
              subtitle: l10n.smartStudyFlashcardsDesc,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                // Open flashcards
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2939).withValues(alpha: 0.5)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF364153)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFF3F4F6)
                              : const Color(0xFF101828),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF99A1AF)
                              : const Color(0xFF4A5565),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? const Color(0xFF99A1AF)
                      : const Color(0xFF4A5565),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
