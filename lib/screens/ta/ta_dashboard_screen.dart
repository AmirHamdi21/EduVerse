import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/ta/dashboard/ta_dashboard_barrel.dart';
import '../../widgets/ta/shared/ta_colors.dart';

class TADashboardScreen extends StatefulWidget {
  const TADashboardScreen({super.key});

  @override
  State<TADashboardScreen> createState() => _TADashboardScreenState();
}

class _TADashboardScreenState extends State<TADashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  late List<TACourseModel> _courses;
  late List<TATaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate loading data
      await Future.delayed(const Duration(milliseconds: 500));

      _courses = _getMockCourses();
      _tasks = _getMockTasks();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<TACourseModel> _getMockCourses() {
    return [
      TACourseModel(
        id: '1',
        code: 'CS101',
        name: 'Operating Systems',
        instructorName: 'Dr. Sarah Johnson',
        studentsCount: 45,
        schedule: 'M, W 9:00 AM',
        pendingTasks: 3,
        color: TAColors.primary,
      ),
      TACourseModel(
        id: '2',
        code: 'CS205',
        name: 'Data Structures',
        instructorName: 'Prof. Michael Chen',
        studentsCount: 52,
        schedule: 'T, Th 11:00 AM',
        pendingTasks: 5,
        color: TAColors.secondary,
      ),
      TACourseModel(
        id: '3',
        code: 'CS301',
        name: 'Algorithms',
        instructorName: 'Dr. Emily Rodriguez',
        studentsCount: 38,
        schedule: 'M, W, F 2:00 PM',
        pendingTasks: 2,
        color: TAColors.teal,
      ),
      TACourseModel(
        id: '4',
        code: 'CS206',
        name: 'Database Systems',
        instructorName: 'Prof. David Kim',
        studentsCount: 41,
        schedule: 'T, Th 3:30 PM',
        pendingTasks: 0,
        color: TAColors.orange,
      ),
    ];
  }

  List<TATaskModel> _getMockTasks() {
    return [
      TATaskModel(
        id: '1',
        title: 'Grade Assignment 2 - Process Scheduling',
        description:
            'OS101 Submissions - Review and grade process scheduling assignments',
        courseCode: 'CS101',
        type: 'grading',
        priority: 'high',
        submissionCount: 42,
        dueDate: 'Due in 2 days',
      ),
      TATaskModel(
        id: '2',
        title: 'Review Lab 3 - Thread Programming',
        description: 'Check student implementations of thread synchronization',
        courseCode: 'CS101',
        type: 'review',
        priority: 'medium',
        submissionCount: 38,
        dueDate: 'Due in 4 days',
      ),
      TATaskModel(
        id: '3',
        title: 'Reply to Discussions - Deadlock Prevention',
        description:
            'Answer student questions about deadlock prevention strategies',
        courseCode: 'CS101',
        type: 'discussion',
        priority: 'medium',
        submissionCount: 8,
        dueDate: 'ASAP',
      ),
      TATaskModel(
        id: '4',
        title: 'Grade Assignment 4 - Binary Search Trees',
        description: 'CS205 - Grade BST implementation assignments',
        courseCode: 'CS205',
        type: 'grading',
        priority: 'high',
        submissionCount: 50,
        dueDate: 'Due tomorrow',
      ),
      TATaskModel(
        id: '5',
        title: 'AI Suggestion: Create review session for Week 5',
        description:
            'Based on student performance, a review session is recommended',
        courseCode: 'CS205',
        type: 'review',
        priority: 'low',
        submissionCount: 0,
        dueDate: 'Suggested',
      ),
      TATaskModel(
        id: '6',
        title: 'Answer questions on Graph Algorithms',
        description: 'Multiple students asked about Dijkstra\'s algorithm',
        courseCode: 'CS301',
        type: 'discussion',
        priority: 'medium',
        submissionCount: 5,
        dueDate: 'Today',
      ),
    ];
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'exam_grading':
        context.push('/ta/ai-grading');
        break;
      case 'review_labs':
        context.push('/ta/labs');
        break;
      case 'open_discussions':
        context.push('/ta/discussions');
        break;
      case 'ask_ai':
        context.push('/ai-chat');
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          drawer: TADrawer(currentRoute: '/ta/dashboard', isDark: isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF5F3FF),
                          Colors.white,
                          Color(0xFFFAF5FE),
                        ],
                      ),
                    ),
              child: _buildContent(isDark, l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: TAColors.primary));
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: TAColors.primary,
      child: CustomScrollView(
        slivers: [
          const TAAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TAAIInsightsCard(
                  isDark: isDark,
                  onViewFullInsights: () =>
                      _showSnackBar(l10n.taViewFullInsights),
                  onAskAIHelp: () => context.push('/ai-chat'),
                ),
                const SizedBox(height: 24),
                TAQuickActionsGrid(
                  isDark: isDark,
                  onActionTap: _handleQuickAction,
                ),
                const SizedBox(height: 24),
                TAActivityStatsSection(
                  isDark: isDark,
                  assignmentsGraded: 36,
                  labsReviewed: 8,
                  questionsAnswered: 12,
                  attendanceSessions: 2,
                  timeSaved: '14h',
                ),
                const SizedBox(height: 24),
                TAAssignedCoursesSection(
                  isDark: isDark,
                  courses: _courses,
                  // onCourseTap: (course) => _showSnackBar('Opening ${course.name}'),
                  onCourseTap: (course) =>
                      context.push('/ta/course/${course.id}'),
                  onViewTasks: (course) =>
                      _showSnackBar('Viewing tasks for ${course.code}'),
                  onViewAll: () => context.push('/ta/courses'),
                ),
                const SizedBox(height: 24),
                TATaskCenterSection(
                  isDark: isDark,
                  tasks: _tasks,
                  onTaskTap: (task) =>
                      _showSnackBar('Opening task: ${task.title}'),
                  onStartTask: (task) =>
                      _showSnackBar('Starting: ${task.title}'),
                  onViewAll: () => context.push('/ta/tasks'),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: TAColors.error),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TAColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
}
