import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/labs/ta_labs_barrel.dart';

class TALabDetailScreen extends StatefulWidget {
  final String labId;

  const TALabDetailScreen({super.key, required this.labId});

  @override
  State<TALabDetailScreen> createState() => _TALabDetailScreenState();
}

class _TALabDetailScreenState extends State<TALabDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  TALabDetail? _labDetail;
  bool _showCopilot = false;
  
  // Mock data for tabs
  late List<TALabTaskItem> _tasks;
  late List<TALabQuestion> _questions;
  late List<TALabActivityItem> _activities;
  late List<TALabSubmission> _submissions;
  late List<TALabSession> _sessions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLabDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLabDetail() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    _labDetail = TALabDetail(
      id: widget.labId,
      title: 'Lab 3: Process Synchronization',
      courseCode: 'CS101',
      courseName: 'Operating Systems',
      instructor: 'Dr. Ahmed Mohamed',
      taName: 'Eng. Sara Ali',
      status: 'Active',
      studentsCount: 120,
      submissionsCount: 45,
      dueDate: 'Oct 28, 2025',
      description:
          'Implement semaphores and mutex locks to solve classic synchronization problems including the producer-consumer problem and the readers-writers problem.',
    );
    
    _tasks = _getMockTasks();
    _questions = _getMockQuestions();
    _activities = _getMockActivities();
    _submissions = _getMockSubmissions();
    _sessions = _getMockSessions();

    setState(() => _isLoading = false);
  }
  
  List<TALabTaskItem> _getMockTasks() {
    return [
      TALabTaskItem(
        id: '1',
        title: 'Start grading Lab 3 submissions',
        subtitle: '12 submissions pending review',
        actionType: TALabTaskActionType.start,
      ),
      TALabTaskItem(
        id: '2',
        title: 'Mark attendance for Lab 3 session',
        subtitle: '120 students awaiting attendance',
        actionType: TALabTaskActionType.mark,
      ),
      TALabTaskItem(
        id: '3',
        title: 'Reply to student questions',
        subtitle: '5 unresolved questions',
        actionType: TALabTaskActionType.reply,
      ),
      TALabTaskItem(
        id: '4',
        title: 'Review flagged submissions',
        subtitle: '3 submissions flagged by AI',
        actionType: TALabTaskActionType.review,
      ),
    ];
  }
  
  List<TALabQuestion> _getMockQuestions() {
    return [
      TALabQuestion(
        id: '1',
        studentName: 'Alex Thompson',
        question: 'How does the semaphore counter work with multiple processes?',
        timeAgo: '2 hours ago',
        isResolved: false,
        aiHint: 'Explain that semaphore counter tracks available resources...',
      ),
      TALabQuestion(
        id: '2',
        studentName: 'Emma Wilson',
        question: 'What is the difference between binary and counting semaphores?',
        timeAgo: '4 hours ago',
        isResolved: false,
      ),
      TALabQuestion(
        id: '3',
        studentName: 'James Miller',
        question: 'How to prevent deadlock in the dining philosophers problem?',
        timeAgo: '6 hours ago',
        isResolved: true,
      ),
    ];
  }
  
  List<TALabActivityItem> _getMockActivities() {
    return [
      TALabActivityItem(
        id: '1',
        title: 'Alex Thompson submitted Lab 3',
        timeAgo: '30 min ago',
        icon: Icons.upload_file_rounded,
        color: TAColors.success,
      ),
      TALabActivityItem(
        id: '2',
        title: 'Emma Wilson asked a question',
        timeAgo: '1 hour ago',
        icon: Icons.help_outline_rounded,
        color: TAColors.warning,
      ),
      TALabActivityItem(
        id: '3',
        title: 'You graded James Miller\'s submission',
        timeAgo: '2 hours ago',
        icon: Icons.grading_rounded,
        color: TAColors.primary,
      ),
    ];
  }
  
  List<TALabSubmission> _getMockSubmissions() {
    return [
      TALabSubmission(
        id: '1',
        studentName: 'Alex Thompson',
        status: TASubmissionStatus.pending,
        submittedAgo: '30 minutes ago',
        aiScore: 85,
        aiComment: 'Good implementation with minor optimizations needed.',
      ),
      TALabSubmission(
        id: '2',
        studentName: 'Emma Wilson',
        status: TASubmissionStatus.reviewed,
        submittedAgo: '2 hours ago',
        aiScore: 92,
        finalScore: 90,
      ),
      TALabSubmission(
        id: '3',
        studentName: 'James Miller',
        status: TASubmissionStatus.late,
        submittedAgo: '1 day ago',
        aiScore: 78,
      ),
      TALabSubmission(
        id: '4',
        studentName: 'Sarah Chen',
        status: TASubmissionStatus.pending,
        submittedAgo: '3 hours ago',
        aiScore: 88,
        aiComment: 'Excellent error handling.',
      ),
    ];
  }
  
  List<TALabSession> _getMockSessions() {
    return [
      TALabSession(
        id: '1',
        title: 'Session 1',
        date: 'Oct 14, 2025',
        timeRange: '9:00 AM - 11:00 AM',
        students: [
          TALabStudent(id: '1', name: 'Alex Thompson', status: TAAttendanceStatus.present),
          TALabStudent(id: '2', name: 'Emma Wilson', status: TAAttendanceStatus.present),
          TALabStudent(id: '3', name: 'James Miller', status: TAAttendanceStatus.late),
          TALabStudent(id: '4', name: 'Sarah Chen', status: TAAttendanceStatus.absent, consecutiveAbsences: 3),
        ],
      ),
      TALabSession(
        id: '2',
        title: 'Session 2',
        date: 'Oct 21, 2025',
        timeRange: '9:00 AM - 11:00 AM',
        students: [
          TALabStudent(id: '1', name: 'Alex Thompson', status: TAAttendanceStatus.present),
          TALabStudent(id: '2', name: 'Emma Wilson', status: TAAttendanceStatus.absent),
          TALabStudent(id: '3', name: 'James Miller', status: TAAttendanceStatus.present),
          TALabStudent(id: '4', name: 'Sarah Chen', status: TAAttendanceStatus.present),
        ],
      ),
    ];
  }

  void _showReviewModal(TALabSubmission submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return TAReviewSubmissionModal(
                  isDark: themeState.isDark,
                  submission: submission,
                  labTitle: _labDetail?.title ?? '',
                  onSubmitReview: (score, feedback) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Review submitted: Score $score',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: TAColors.success,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        if (_isLoading) {
          return Scaffold(
            backgroundColor: TAColors.scaffoldColor(isDark),
            body: Center(
              child: CircularProgressIndicator(color: TAColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          body: Stack(
            children: [
              SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      _buildSliverAppBar(isDark, l10n, innerBoxIsScrolled),
                      SliverToBoxAdapter(
                        child: _buildLabHeader(isDark, l10n),
                      ),
                      SliverToBoxAdapter(
                        child: TALabStatsCards(
                          isDark: isDark,
                          status: _labDetail!.status,
                          studentsCount: _labDetail!.studentsCount,
                          submissionsCount: _labDetail!.submissionsCount,
                          dueDate: _labDetail!.dueDate,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TALabActionButtons(
                            isDark: isDark,
                            onUpload: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Upload materials'),
                                  backgroundColor: TAColors.primary,
                                ),
                              );
                            },
                            onAttendance: () {
                              _tabController.animateTo(2);
                            },
                            onAIInsights: () {
                              setState(() => _showCopilot = true);
                            },
                            onAllLabs: () {
                              context.go('/ta/labs');
                            },
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          tabBar: _buildTabBar(isDark, l10n),
                          backgroundColor: TAColors.scaffoldColor(isDark),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      TALabOverviewTab(
                        isDark: isDark,
                        tasks: _tasks,
                        questions: _questions,
                        activities: _activities,
                      ),
                      TALabSubmissionsTab(
                        isDark: isDark,
                        submissions: _submissions,
                        onOpenSubmission: _showReviewModal,
                      ),
                      TALabAttendanceTab(
                        isDark: isDark,
                        sessions: _sessions,
                      ),
                    ],
                  ),
                ),
              ),
              // Copilot Panel
              if (_showCopilot)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showCopilot = false),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {},
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.7,
                            maxChildSize: 0.95,
                            minChildSize: 0.4,
                            builder: (context, scrollController) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: TAColors.cardColor(isDark),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: TAColors.borderColor(isDark),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            color: TAColors.primary,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            l10n.taLabCopilotTitle,
                                            style: TextStyle(
                                              color: TAColors.textPrimaryColor(isDark),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () =>
                                                setState(() => _showCopilot = false),
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color:
                                                  TAColors.textSecondaryColor(isDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        controller: scrollController,
                                        padding:
                                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: TALabCopilotWidget(isDark: isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(
    bool isDark,
    AppLocalizations l10n,
    bool innerBoxIsScrolled,
  ) {
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
      title: AnimatedOpacity(
        opacity: innerBoxIsScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          _labDetail?.title ?? '',
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Edit lab'),
                    backgroundColor: TAColors.primary,
                  ),
                );
                break;
              case 'settings':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Lab settings'),
                    backgroundColor: TAColors.primary,
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 20, color: TAColors.textPrimaryColor(isDark)),
                  const SizedBox(width: 10),
                  Text(l10n.taLabEdit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_rounded, size: 20, color: TAColors.textPrimaryColor(isDark)),
                  const SizedBox(width: 10),
                  Text(l10n.taLabSettings),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildLabHeader(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _labDetail!.courseCode,
                  style: TextStyle(
                    color: TAColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _labDetail!.courseName,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _labDetail!.title,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: TAColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                _labDetail!.instructor,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.school_outlined,
                size: 16,
                color: TAColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                _labDetail!.taName,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (_labDetail!.description != null) ...[
            const SizedBox(height: 14),
            Text(
              _labDetail!.description!,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  TabBar _buildTabBar(bool isDark, AppLocalizations l10n) {
    return TabBar(
      controller: _tabController,
      labelColor: TAColors.primary,
      unselectedLabelColor: TAColors.textSecondaryColor(isDark),
      indicatorColor: TAColors.primary,
      indicatorWeight: 3,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(text: l10n.taLabOverview),
        Tab(text: l10n.taLabSubmissionsTab),
        Tab(text: l10n.taLabAttendanceTab),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class TALabDetail {
  final String id;
  final String title;
  final String courseCode;
  final String courseName;
  final String instructor;
  final String taName;
  final String status;
  final int studentsCount;
  final int submissionsCount;
  final String dueDate;
  final String? description;

  TALabDetail({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.instructor,
    required this.taName,
    required this.status,
    required this.studentsCount,
    required this.submissionsCount,
    required this.dueDate,
    this.description,
  });
}
