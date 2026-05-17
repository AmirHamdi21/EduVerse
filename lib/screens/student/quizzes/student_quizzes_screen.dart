import 'package:edu_verse/models/quiz/quiz_api_models.dart'
    show QuizAttemptModel;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/student_quiz_cubit.dart';
import 'package:edu_verse/bloc/quiz/student_quiz_state.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/features/walkthrough/student_walkthrough_registry.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_target.dart';
import 'package:edu_verse/widgets/student/quizzes/student_quiz_card.dart';
import 'package:edu_verse/widgets/student/quizzes/student_attempt_history.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';

class StudentQuizzesScreen extends StatefulWidget {
  const StudentQuizzesScreen({super.key});

  @override
  State<StudentQuizzesScreen> createState() => _StudentQuizzesScreenState();
}

class _StudentQuizzesScreenState extends State<StudentQuizzesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    context.read<StudentQuizCubit>().loadQuizzes();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC);

        return StudentWalkthroughRouteMarker(
          segmentId: StudentWalkthroughIds.quizzes,
          child: Scaffold(
            backgroundColor: bgColor,
            body: Stack(
              children: [
                // Gradient header
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFF2B7FFF), const Color(0xFF155DFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // ── Header ──────────────────────────────────────────
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: WalkthroughTarget(
                          id: StudentWalkthroughIds.quizzesHeader,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              responsive.p20,
                              responsive.p16,
                              responsive.p20,
                              responsive.p12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _backButton(isDark),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.quiz_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: responsive.p16),
                                const Text(
                                  'Quizzes',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Test your knowledge with instructor quizzes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                SizedBox(height: responsive.p16),
                                WalkthroughTarget(
                                  id: StudentWalkthroughIds.quizzesSearch,
                                  child: _searchBar(isDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.p12),

                      // ── Body ────────────────────────────────────────────
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child:
                              BlocBuilder<StudentQuizCubit, StudentQuizState>(
                                builder: (context, state) {
                                  if (state is StudentQuizLoading ||
                                      state is StudentQuizStarting ||
                                      state is StudentQuizActive ||
                                      state is StudentQuizSubmitting ||
                                      state is StudentQuizResultLoaded) {
                                    return _loadingView(isDark);
                                  }
                                  if (state is StudentQuizError) {
                                    return _errorView(isDark, state.message);
                                  }
                                  if (state is StudentQuizzesLoaded) {
                                    return _quizListView(
                                      isDark,
                                      state,
                                      responsive,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _backButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => _leaveStudentQuizScreen(context),
        icon: Icon(iosBackIcon(context), color: Colors.white, size: 18),
      ),
    );
  }

  Widget _searchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => context.read<StudentQuizCubit>().setSearchQuery(v),
        style: const TextStyle(color: Colors.black, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search quizzes...',
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.black.withValues(alpha: 0.6),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _loadingView(bool isDark) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF2B7FFF)),
    );
  }

  Widget _errorView(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<StudentQuizCubit>().loadQuizzes(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quizListView(
    bool isDark,
    StudentQuizzesLoaded state,
    ResponsiveUtil responsive,
  ) {
    final quizzes = state.filteredQuizzes;

    if (quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 56,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              'No quizzes available',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudentQuizCubit>().loadQuizzes(),
      color: const Color(0xFF2B7FFF),
      child: WalkthroughTarget(
        id: StudentWalkthroughIds.quizzesList,
        child: ListView.builder(
          padding: EdgeInsets.all(responsive.p16),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return StudentQuizCard(
              quiz: quiz,
              remainingAttempts: state.remainingAttempts(quiz.id),
              inProgressAttempt: state.inProgressAttempt(quiz.id),
              isDark: isDark,
              onStart: () => _onStartQuiz(quiz.id),
              onResume: () => _onStartQuiz(quiz.id),
              onViewHistory: () => _showAttemptHistory(
                isDark,
                state.myAttempts.where((a) => a.quizId == quiz.id).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onStartQuiz(int quizId) async {
    HapticFeedback.mediumImpact();
    final cubit = context.read<StudentQuizCubit>();
    await cubit.startQuiz(quizId);
    if (!mounted) return;

    final current = cubit.state;
    if (current is StudentQuizActive) {
      context.push('/student/quiz-take');
      return;
    }

    if (current is StudentQuizError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(current.message)));
      await cubit.loadQuizzes();
    }
  }

  void _showAttemptHistory(bool isDark, List<QuizAttemptModel> attempts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Attempt History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StudentAttemptHistory(
                  attempts: attempts,
                  isDark: isDark,
                  onViewResult: (id) {
                    Navigator.pop(ctx);
                    context.read<StudentQuizCubit>().viewAttemptResult(id);
                    context.push('/student/quiz-result');
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void _leaveStudentQuizScreen(BuildContext context) {
  safeBack(context, '/dashboard');
}
