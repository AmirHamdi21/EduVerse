import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/courses/ta_courses_barrel.dart';

class TACourseDetailScreen extends StatefulWidget {
  final String courseId;

  const TACourseDetailScreen({super.key, required this.courseId});

  @override
  State<TACourseDetailScreen> createState() => _TACourseDetailScreenState();
}

class _TACourseDetailScreenState extends State<TACourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  TACourseData? _courseData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulate loading course data
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock course data
      _courseData = TACourseData(
        id: widget.courseId,
        code: 'CS101',
        name: 'Operating Systems',
        instructor: 'Dr. Ahmed Mohamed',
        studentsCount: 120,
        labsCount: 6,
        assignmentsCount: 3,
        discussionsCount: 18,
        insights: [
          '5 submissions need urgent grading before deadline',
          '3 students are struggling with Lab 4 content',
          'Discussion activity increased 40% this week',
        ],
        upcomingTasks: [
          TAUpcomingTask(
            id: '1',
            title: 'Grade Lab 3 Submissions',
            subtitle: '45 submissions • Due in 2 days',
          ),
          TAUpcomingTask(
            id: '2',
            title: 'Review Discussion Posts',
            subtitle: '12 new posts • Week 5 content',
          ),
          TAUpcomingTask(
            id: '3',
            title: 'Prepare Lab 4 Materials',
            subtitle: 'Session on Thursday',
          ),
        ],
        recentActivities: [
          TARecentActivity(
            id: '1',
            title: 'Graded 12 submissions for Assignment 2',
            timeAgo: '2 hours ago',
            icon: Icons.grading_rounded,
            color: TAColors.success,
          ),
          TARecentActivity(
            id: '2',
            title: 'Answered 5 student questions in discussion',
            timeAgo: '4 hours ago',
            icon: Icons.forum_rounded,
            color: TAColors.info,
          ),
          TARecentActivity(
            id: '3',
            title: 'Updated attendance for Lab 2',
            timeAgo: 'Yesterday',
            icon: Icons.check_circle_rounded,
            color: TAColors.primary,
          ),
        ],
        labs: [
          TALabItem(
            id: '1',
            title: 'Lab 1: Process Management',
            subtitle: 'Week 1-2 content',
            status: TALabStatus.closed,
            progress: 1.0,
            attended: 115,
            total: 120,
          ),
          TALabItem(
            id: '2',
            title: 'Lab 2: Thread Synchronization',
            subtitle: 'Week 3-4 content',
            status: TALabStatus.closed,
            progress: 0.92,
            attended: 110,
            total: 120,
          ),
          TALabItem(
            id: '3',
            title: 'Lab 3: Memory Management',
            subtitle: 'Week 5-6 content',
            status: TALabStatus.active,
            progress: 0.78,
            attended: 94,
            total: 120,
          ),
          TALabItem(
            id: '4',
            title: 'Lab 4: File Systems',
            subtitle: 'Week 7-8 content',
            status: TALabStatus.active,
            progress: 0.0,
            attended: 0,
            total: 120,
          ),
        ],
        gradingTasks: [
          TAGradingTask(
            id: '1',
            studentName: 'Omar Hassan',
            assignmentName: 'Lab 3 - Memory Management',
            status: TAGradingStatus.pending,
            aiSuggestedScore: 85,
          ),
          TAGradingTask(
            id: '2',
            studentName: 'Sara Ahmed',
            assignmentName: 'Lab 3 - Memory Management',
            status: TAGradingStatus.pending,
            aiSuggestedScore: 92,
          ),
          TAGradingTask(
            id: '3',
            studentName: 'Mohamed Ali',
            assignmentName: 'Lab 3 - Memory Management',
            status: TAGradingStatus.inProgress,
            aiSuggestedScore: 78,
          ),
        ],
        discussions: [
          TADiscussionItem(
            id: '1',
            studentName: 'Fatima Hassan',
            question:
                'I\'m having trouble understanding the difference between paging and segmentation. Can someone explain?',
            timeAgo: '2 hours ago',
            repliesCount: 3,
            likesCount: 8,
            isAnswered: false,
            isAIFlagged: true,
          ),
          TADiscussionItem(
            id: '2',
            studentName: 'Ahmed Youssef',
            question:
                'What is the best approach for implementing the LRU page replacement algorithm in the lab assignment?',
            timeAgo: '5 hours ago',
            repliesCount: 7,
            likesCount: 15,
            isAnswered: true,
            isAIFlagged: false,
          ),
          TADiscussionItem(
            id: '3',
            studentName: 'Nour Ibrahim',
            question:
                'Is there a deadline extension for Lab 3? I\'m facing some issues with the virtual memory simulation.',
            timeAgo: '1 day ago',
            repliesCount: 2,
            likesCount: 4,
            isAnswered: false,
            isAIFlagged: false,
          ),
        ],
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          body: SafeArea(child: _buildBody(isDark, l10n)),
        );
      },
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_error != null) {
      return _buildErrorState(isDark, l10n);
    }

    if (_courseData == null) {
      return _buildEmptyState(isDark, l10n);
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildAppBar(isDark, l10n),
        SliverToBoxAdapter(child: _buildCourseContent(isDark, l10n)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            child: _buildTabBar(isDark, l10n),
            isDark: isDark,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDark, l10n),
          _buildLabsTab(isDark, l10n),
          _buildGradingTab(isDark, l10n),
          _buildDiscussionsTab(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TAColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading course...',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TAColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: TAColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load course',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCourseData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Text(
        'Course not found',
        style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_courseData!.code} — ${_courseData!.name}',
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            _courseData!.instructor,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: TAColors.aiGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () => _showAIInsightsSheet(),
            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            tooltip: l10n.taCourseAIInsights,
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildCourseContent(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TACourseStatsCards(
            isDark: isDark,
            studentsCount: _courseData!.studentsCount,
            labsCount: _courseData!.labsCount,
            assignmentsCount: _courseData!.assignmentsCount,
            discussionsCount: _courseData!.discussionsCount,
          ),
          const SizedBox(height: 16),
          TACourseQuickActions(
            isDark: isDark,
            onViewLabs: () => _tabController.animateTo(1),
            onViewSubmissions: () => _tabController.animateTo(2),
            onViewDiscussions: () => _tabController.animateTo(3),
            onAIInsights: () => _showAIInsightsSheet(),
          ),
          const SizedBox(height: 16),
          TACourseInsightsCard(
            isDark: isDark,
            insights: _courseData!.insights,
            onOpenFullInsights: () => _showAIInsightsSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      color: TAColors.scaffoldColor(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: TAColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: TAColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: TAColors.textSecondaryColor(isDark),
          labelStyle: TextStyle(
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: l10n.taCourseOverview),
            Tab(text: l10n.taCourseLabsTab),
            Tab(text: l10n.taCourseGradingTab),
            Tab(text: l10n.taCourseDiscussionsTab),
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(l10n.taCourseDiscussionsTab),
            //     const SizedBox(width: 4),
            //     const Icon(Icons.chat_bubble_outline_rounded, size: 14),
            //   ],
            // ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TACourseOverviewTab(
        isDark: isDark,
        upcomingTasks: _courseData!.upcomingTasks,
        recentActivities: _courseData!.recentActivities,
        onStartTask: (task) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Starting: ${task.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabsTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TACourseLabsTab(
        isDark: isDark,
        labs: _courseData!.labs,
        onOpenLab: (lab) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: ${lab.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onReview: (lab) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reviewing: ${lab.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onAttendance: (lab) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attendance for: ${lab.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onUpload: (lab) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload for: ${lab.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradingTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TACourseGradingTab(
        isDark: isDark,
        gradingTasks: _courseData!.gradingTasks,
        onStartReview: (task) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reviewing: ${task.studentName}\'s submission'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onApplyAIScore: (task) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Applied AI score: ${task.aiSuggestedScore}/100'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: TAColors.success,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscussionsTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TACourseDiscussionsTab(
        isDark: isDark,
        discussions: _courseData!.discussions,
        onReplyAsTA: (discussion) {
          _showReplyDialog(discussion);
        },
        onFilterChanged: (filter) {
          // Filter handling is done internally by the widget
        },
      ),
    );
  }

  void _showAIInsightsSheet() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TAFullInsightsSheet(
        isDark: isDark,
        priorityTasks: [
          'Grade 45 Lab 3 submissions (Due in 2 days)',
          'Review 5 flagged discussion posts',
          'Update attendance for Lab 2 session',
        ],
        quickActions: [
          TAQuickAction(
            icon: Icons.grading_rounded,
            label: l10n.taExamGrading,
            onTap: () => _tabController.animateTo(2),
          ),
          TAQuickAction(
            icon: Icons.science_rounded,
            label: l10n.taReviewLabs,
            onTap: () => _tabController.animateTo(1),
          ),
          TAQuickAction(
            icon: Icons.forum_rounded,
            label: l10n.taOpenDiscussions,
            onTap: () => _tabController.animateTo(3),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(TADiscussionItem discussion) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
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
              Text(
                'Reply to ${discussion.studentName}',
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TAColors.surfaceColor(isDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  discussion.question,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your reply...',
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  filled: true,
                  fillColor: TAColors.surfaceColor(isDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.primary),
                  ),
                ),
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TAColors.textSecondaryColor(isDark),
                        side: BorderSide(color: TAColors.borderColor(isDark)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Reply posted successfully'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: TAColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TAColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Post Reply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDark;

  _TabBarDelegate({required this.child, required this.isDark});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return isDark != oldDelegate.isDark;
  }
}

// Course data model
class TACourseData {
  final String id;
  final String code;
  final String name;
  final String instructor;
  final int studentsCount;
  final int labsCount;
  final int assignmentsCount;
  final int discussionsCount;
  final List<String> insights;
  final List<TAUpcomingTask> upcomingTasks;
  final List<TARecentActivity> recentActivities;
  final List<TALabItem> labs;
  final List<TAGradingTask> gradingTasks;
  final List<TADiscussionItem> discussions;

  TACourseData({
    required this.id,
    required this.code,
    required this.name,
    required this.instructor,
    required this.studentsCount,
    required this.labsCount,
    required this.assignmentsCount,
    required this.discussionsCount,
    required this.insights,
    required this.upcomingTasks,
    required this.recentActivities,
    required this.labs,
    required this.gradingTasks,
    required this.discussions,
  });
}
