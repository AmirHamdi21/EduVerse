import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import '../../../bloc/tasks/tasks_cubit.dart';
import '../../../bloc/tasks/tasks_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/app_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/task_model.dart';
import '../../../common/utils/responsive.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scrollController.addListener(_onScroll);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset > 50 && _showFab) {
      setState(() => _showFab = false);
      _fabAnimationController.reverse();
    } else if (_scrollController.offset <= 50 && !_showFab) {
      setState(() => _showFab = true);
      _fabAnimationController.forward();
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocProvider(
      create: (_) => TasksCubit()..loadTasks(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final l10n = AppLocalizations.of(context);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Scaffold(
              backgroundColor: isDark
                  ? AppTheme.darkSurfaceColor
                  : const Color(0xFFF8FAFC),
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, isDark, l10n, responsive),
                    _buildTabBar(context, isDark, l10n, responsive),
                    Expanded(
                      child: BlocConsumer<TasksCubit, TasksState>(
                        listener: (context, state) {
                          if (state is TasksError) {
                            _showErrorSnackBar(context, state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is TasksLoading && state.tasks.isEmpty) {
                            return _buildLoadingState(isDark);
                          }
                          if (state is TasksError && state.tasks.isEmpty) {
                            return _buildErrorState(
                              context,
                              state.message,
                              isDark,
                              l10n,
                              responsive,
                            );
                          }
                          return _buildContent(
                            context,
                            state,
                            isDark,
                            l10n,
                            responsive,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: ScaleTransition(
                scale: _fabAnimationController,
                child: FloatingActionButton.extended(
                  onPressed: () =>
                      _showAddTaskBottomSheet(context, isDark, l10n),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addTask),
                  elevation: 4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: responsive.p96,
              height: responsive.p96,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: responsive.p48,
                color: Colors.red,
              ),
            ),
            SizedBox(height: responsive.p24),
            Text(
              l10n.error,
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: responsive.p8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            SizedBox(height: responsive.p24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TasksCubit>().loadTasks();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.p24,
                  vertical: responsive.p12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        final slideAnimation =
            Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
              CurvedAnimation(
                parent: _headerAnimationController,
                curve: Curves.easeOutCubic,
              ),
            );

        return SlideTransition(
          position: slideAnimation,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              responsive.p16,
              responsive.p12,
              responsive.p16,
              responsive.p8,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => safeBack(context, '/dashboard'),
                      icon: Icon(
                        iosBackIcon(context),
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: responsive.p12),
                    Expanded(
                      child: _isSearching
                          ? _buildSearchField(isDark, l10n, responsive)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.tasks,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Track assignments, labs, quizzes, and study tasks',
                                  style: TextStyle(
                                    fontSize: responsive.fontSize12,
                                    color: isDark
                                        ? const Color(0xFF99A1AF)
                                        : const Color(0xFF4A5565),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    _buildHeaderActions(context, isDark, l10n, responsive),
                  ],
                ),
                SizedBox(height: responsive.p8),
                // AI Suggestions Banner
                _buildAiSuggestionsBanner(isDark, responsive),
                SizedBox(height: responsive.p8),
                _buildQuickStats(context, isDark, l10n, responsive),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiSuggestionsBanner(bool isDark, ResponsiveUtil responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF162456).withOpacity(0.2)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: isDark ? const Color(0xFF193CB8) : const Color(0xFFBEDBFF),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 20,
            color: isDark ? const Color(0xFFBEDBFF) : const Color(0xFF193CB8),
          ),
          SizedBox(width: responsive.p8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  color: isDark
                      ? const Color(0xFFBEDBFF)
                      : const Color(0xFF193CB8),
                ),
                children: [
                  TextSpan(
                    text: 'AI Suggestions ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        'are automatically added based on your upcoming deadlines and weak areas.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: responsive.fontSize16,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchTasks,
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black38,
            ),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                context.read<TasksCubit>().setSearchQuery('');
                setState(() => _isSearching = false);
              },
            ),
          ),
          onChanged: (value) {
            context.read<TasksCubit>().setSearchQuery(value);
          },
        );
      },
    );
  }

  Widget _buildHeaderActions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => setState(() => _isSearching = !_isSearching),
          icon: Icon(
            _isSearching ? Icons.close : Icons.search_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          tooltip: l10n.search,
        ),
        IconButton(
          onPressed: () => _showFilterBottomSheet(context, isDark, l10n),
          icon: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              final hasFilters = state.filter.hasActiveFilters;
              return Badge(
                isLabelVisible: hasFilters,
                label: Text('${state.filter.activeFilterCount}'),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: hasFilters
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              );
            },
          ),
          tooltip: l10n.filter,
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onSelected: (value) => _handleMenuAction(context, value, l10n),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'sort',
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, size: 20),
                  SizedBox(width: responsive.p12),
                  Text(l10n.sortBy),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  const Icon(Icons.view_agenda_rounded, size: 20),
                  SizedBox(width: responsive.p12),
                  Text(l10n.viewMode),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  const Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: responsive.p12),
                  Text(l10n.refresh),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final stats = [
          _StatItem(
            label: l10n.todayTasks,
            count: state.todayTasks.length,
            color: const Color(0xFF3B82F6),
            icon: Icons.today_rounded,
          ),
          _StatItem(
            label: l10n.pending,
            count: state.pendingTasks.length,
            color: const Color(0xFFF59E0B),
            icon: Icons.pending_actions_rounded,
          ),
          _StatItem(
            label: l10n.overdue,
            count: state.overdueTasks.length,
            color: const Color(0xFFEF4444),
            icon: Icons.warning_amber_rounded,
          ),
          _StatItem(
            label: l10n.completed,
            count: state.completedTasks.length,
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
          ),
        ];

        return SizedBox(
          height: responsive.p56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            separatorBuilder: (_, __) => SizedBox(width: responsive.p8),
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _buildStatChip(stat, isDark, responsive);
            },
          ),
        );
      },
    );
  }

  Widget _buildStatChip(
    _StatItem stat,
    bool isDark,
    ResponsiveUtil responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p12,
        vertical: responsive.p6,
      ),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(color: stat.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat.icon, color: stat.color, size: responsive.p16),
          SizedBox(width: responsive.p8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stat.count}',
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: stat.color,
                ),
              ),
              Text(
                stat.label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      color: isDark ? AppTheme.darkCardColor : Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
        labelStyle: TextStyle(
          fontSize: responsive.fontSize14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: responsive.fontSize14,
          fontWeight: FontWeight.normal,
        ),
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(text: l10n.allTasks),
          Tab(text: l10n.inProgress),
          Tab(text: l10n.upcoming),
          Tab(text: l10n.completedTasks),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TasksState state,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTaskList(context, state.filteredTasks, isDark, l10n, responsive),
        _buildTaskList(
          context,
          state.inProgressTasks,
          isDark,
          l10n,
          responsive,
        ),
        _buildTaskList(context, state.thisWeekTasks, isDark, l10n, responsive),
        _buildTaskList(context, state.completedTasks, isDark, l10n, responsive),
      ],
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<TaskModel> tasks,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    if (tasks.isEmpty) {
      return _buildEmptyState(isDark, l10n, responsive);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TasksCubit>().loadTasks();
      },
      color: AppTheme.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(responsive.p16),
        // Add 2 for the header cards (weekly progress + AI tip)
        itemCount: tasks.length + 2,
        itemBuilder: (context, index) {
          // Weekly Progress Card
          if (index == 0) {
            return BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                return _buildWeeklyProgressCard(
                  context,
                  state,
                  isDark,
                  l10n,
                  responsive,
                );
              },
            );
          }

          // AI Tip Card
          if (index == 1) {
            return BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                return _buildAiTipCard(context, state, isDark, responsive);
              },
            );
          }

          // Task items (offset by 2 for header cards)
          final task = tasks[index - 2];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + ((index - 2) * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: _TaskCard(
              task: task,
              isDark: isDark,
              l10n: l10n,
              responsive: responsive,
              onTap: () => _showTaskDetails(context, task, isDark, l10n),
              onToggleComplete: () {
                try {
                  context.read<TasksCubit>().toggleTaskStatus(task.id);
                  final isNowCompleted = task.status != TaskStatus.completed;
                  _showSuccessSnackBar(
                    context,
                    isNowCompleted
                        ? 'Task completed!'
                        : 'Task marked as pending',
                  );
                } catch (e) {
                  _showErrorSnackBar(context, 'Failed to update task');
                }
              },
              onToggleBookmark: () {
                try {
                  context.read<TasksCubit>().toggleBookmark(task.id);
                } catch (e) {
                  _showErrorSnackBar(context, 'Failed to update bookmark');
                }
              },
              onDelete: () {
                try {
                  final cubit = context.read<TasksCubit>();
                  cubit.deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.taskDeleted),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: l10n.undo,
                        onPressed: () {
                          cubit.addTask(task);
                        },
                      ),
                    ),
                  );
                } catch (e) {
                  _showErrorSnackBar(context, 'Failed to delete task');
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyProgressCard(
    BuildContext context,
    TasksState state,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final totalTasks = state.tasks.length;
    final completedTasks = state.completedTasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final progressPercent = (progress * 100).round();
    final todayRemaining = state.todayTasks
        .where((t) => t.status != TaskStatus.completed)
        .length;

    // Check if ahead or behind schedule
    final overdueCount = state.overdueTasks.length;
    final isAhead = overdueCount == 0 && completedTasks > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.p12),
      child: Container(
        padding: EdgeInsets.all(responsive.p16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E3A5F), const Color(0xFF162456)]
                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          ),
          borderRadius: BorderRadius.circular(responsive.radius16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : const Color(0xFFBEDBFF),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF3B82F6))
                  .withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF3B82F6).withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF3B82F6),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$progressPercent%',
                      style: TextStyle(
                        fontSize: responsive.fontSize18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E40AF),
                      ),
                    ),
                    Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: responsive.p16),
            // Progress Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: responsive.fontSize16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E40AF),
                    ),
                  ),
                  SizedBox(height: responsive.p4),
                  Text(
                    '$todayRemaining Tasks Remaining for Today',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: isDark
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(height: responsive.p8),
                  // Status Message
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p8,
                      vertical: responsive.p4,
                    ),
                    decoration: BoxDecoration(
                      color: isAhead
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : overdueCount > 0
                          ? const Color(0xFFEF4444).withOpacity(0.15)
                          : const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(responsive.radius8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAhead
                              ? Icons.check_circle_outline_rounded
                              : overdueCount > 0
                              ? Icons.warning_amber_rounded
                              : Icons.schedule_rounded,
                          size: 14,
                          color: isAhead
                              ? const Color(0xFF10B981)
                              : overdueCount > 0
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFF59E0B),
                        ),
                        SizedBox(width: responsive.p4),
                        Flexible(
                          child: Text(
                            isAhead
                                ? 'Great job! You\'re ahead of schedule'
                                : overdueCount > 0
                                ? '$overdueCount tasks overdue'
                                : 'Keep up the momentum!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isAhead
                                  ? const Color(0xFF10B981)
                                  : overdueCount > 0
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiTipCard(
    BuildContext context,
    TasksState state,
    bool isDark,
    ResponsiveUtil responsive,
  ) {
    // Generate AI tip based on task state
    String aiTip;
    IconData tipIcon;

    final pendingLabs = state.pendingTasks
        .where(
          (t) =>
              t.category == TaskCategory.lab ||
              t.title.toLowerCase().contains('lab'),
        )
        .toList();

    final pendingAssignments = state.pendingTasks
        .where(
          (t) =>
              t.category == TaskCategory.assignment ||
              t.title.toLowerCase().contains('assignment'),
        )
        .toList();

    final overdueCount = state.overdueTasks.length;

    if (overdueCount > 0) {
      aiTip =
          'Focus on your $overdueCount overdue tasks first to avoid grade penalties.';
      tipIcon = Icons.priority_high_rounded;
    } else if (pendingLabs.isNotEmpty) {
      aiTip = 'Finish your Lab first for maximum grade impact.';
      tipIcon = Icons.science_rounded;
    } else if (pendingAssignments.isNotEmpty) {
      aiTip = 'Complete your assignments early to allow time for revisions.';
      tipIcon = Icons.assignment_rounded;
    } else if (state.todayTasks.isEmpty) {
      aiTip = 'No tasks due today. Great time to get ahead on upcoming work!';
      tipIcon = Icons.celebration_rounded;
    } else {
      aiTip = 'Stay consistent with your study schedule for best results.';
      tipIcon = Icons.tips_and_updates_rounded;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.p16),
      child: Container(
        padding: EdgeInsets.all(responsive.p12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF4C1D95).withOpacity(0.3),
                    const Color(0xFF7C3AED).withOpacity(0.2),
                  ]
                : [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
          ),
          borderRadius: BorderRadius.circular(responsive.radius12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF7C3AED).withOpacity(0.4)
                : const Color(0xFFDDD6FE),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.p8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7C3AED).withOpacity(0.3)
                    : const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.radius8),
              ),
              child: Icon(
                tipIcon,
                size: 20,
                color: isDark
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF7C3AED),
              ),
            ),
            SizedBox(width: responsive.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: isDark
                            ? const Color(0xFFA78BFA)
                            : const Color(0xFF7C3AED),
                      ),
                      SizedBox(width: responsive.p4),
                      Text(
                        'AI Tip',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFA78BFA)
                              : const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p4),
                  Text(
                    aiTip,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: isDark
                          ? const Color(0xFFE9D5FF)
                          : const Color(0xFF5B21B6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: responsive.p96,
            height: responsive.p96,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: responsive.p48,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: responsive.p24),
          Text(
            l10n.noTasksFound,
            style: TextStyle(
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.p8),
          Text(
            l10n.noTasksDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.fontSize14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          SizedBox(height: responsive.p24),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskBottomSheet(context, isDark, l10n),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addTask),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.p24,
                vertical: responsive.p12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case 'sort':
        _showSortBottomSheet(
          context,
          context.read<ThemeBloc>().state.isDark,
          l10n,
        );
        break;
      case 'view':
        _showViewModeBottomSheet(
          context,
          context.read<ThemeBloc>().state.isDark,
          l10n,
        );
        break;
      case 'refresh':
        context.read<TasksCubit>().loadTasks();
        break;
    }
  }

  void _showFilterBottomSheet(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<TasksCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _FilterBottomSheet(isDark: isDark, l10n: l10n, cubit: cubit),
    );
  }

  void _showSortBottomSheet(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<TasksCubit>();
    final responsive = context.responsive;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius20),
        ),
      ),
      builder: (context) => BlocBuilder<TasksCubit, TasksState>(
        bloc: cubit,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(responsive.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.sortBy,
                          style: TextStyle(
                            fontSize: responsive.fontSize18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => cubit.toggleSortOrder(),
                          icon: Icon(
                            state.sortAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.p16),
                    ...TasksSortBy.values.map(
                      (sortBy) => _buildSortOption(
                        sortBy,
                        state.sortBy == sortBy,
                        isDark,
                        l10n,
                        responsive,
                        () {
                          cubit.setSort(sortBy);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.p16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSortOption(
    TasksSortBy sortBy,
    bool isSelected,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
    VoidCallback onTap,
  ) {
    String label;
    IconData icon;
    switch (sortBy) {
      case TasksSortBy.dueDate:
        label = l10n.dueDate;
        icon = Icons.calendar_today_rounded;
        break;
      case TasksSortBy.priority:
        label = l10n.priority;
        icon = Icons.flag_rounded;
        break;
      case TasksSortBy.category:
        label = l10n.category;
        icon = Icons.category_rounded;
        break;
      case TasksSortBy.status:
        label = l10n.status;
        icon = Icons.check_circle_outline_rounded;
        break;
      case TasksSortBy.createdAt:
        label = l10n.createdAt;
        icon = Icons.schedule_rounded;
        break;
    }

    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isSelected
            ? AppTheme.primaryColor
            : (isDark ? Colors.white54 : Colors.black54),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? Colors.white : Colors.black87),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppTheme.primaryColor)
          : null,
      contentPadding: EdgeInsets.symmetric(horizontal: responsive.p8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.radius8),
      ),
    );
  }

  void _showViewModeBottomSheet(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;
    final cubit = context.read<TasksCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius20),
        ),
      ),
      builder: (sheetContext) => BlocBuilder<TasksCubit, TasksState>(
        bloc: cubit,
        builder: (_, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(responsive.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.viewMode,
                      style: TextStyle(
                        fontSize: responsive.fontSize18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: responsive.p16),
                    Row(
                      children: [
                        _buildViewModeOptionWidget(
                          Icons.view_list_rounded,
                          l10n.listView,
                          TasksViewMode.list,
                          state.viewMode == TasksViewMode.list,
                          isDark,
                          responsive,
                          () {
                            cubit.setViewMode(TasksViewMode.list);
                            Navigator.pop(sheetContext);
                          },
                        ),
                        SizedBox(width: responsive.p12),
                        _buildViewModeOptionWidget(
                          Icons.calendar_month_rounded,
                          l10n.calendarView,
                          TasksViewMode.calendar,
                          state.viewMode == TasksViewMode.calendar,
                          isDark,
                          responsive,
                          () {
                            cubit.setViewMode(TasksViewMode.calendar);
                            Navigator.pop(sheetContext);
                          },
                        ),
                        SizedBox(width: responsive.p12),
                        _buildViewModeOptionWidget(
                          Icons.view_kanban_rounded,
                          l10n.kanbanView,
                          TasksViewMode.kanban,
                          state.viewMode == TasksViewMode.kanban,
                          isDark,
                          responsive,
                          () {
                            cubit.setViewMode(TasksViewMode.kanban);
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.p16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildViewModeOptionWidget(
    IconData icon,
    String label,
    TasksViewMode mode,
    bool isSelected,
    bool isDark,
    ResponsiveUtil responsive,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius12),
        child: Container(
          padding: EdgeInsets.all(responsive.p16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(responsive.radius12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark ? Colors.white54 : Colors.black54),
                size: responsive.p32,
              ),
              SizedBox(height: responsive.p8),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(
    BuildContext context,
    TaskModel task,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;
    final cubit = context.read<TasksCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TaskDetailsSheet(
        task: task,
        isDark: isDark,
        l10n: l10n,
        responsive: responsive,
        onEdit: () {
          Navigator.pop(sheetContext);
          // Use the original context which has access to the cubit
          _showEditTaskBottomSheet(context, cubit, task, isDark, l10n);
        },
        onDelete: () {
          Navigator.pop(sheetContext);
          try {
            cubit.deleteTask(task.id);
            _showSuccessSnackBar(context, l10n.taskDeleted);
          } catch (e) {
            _showErrorSnackBar(context, 'Failed to delete task');
          }
        },
        onStatusChange: (status) {
          try {
            cubit.updateTaskProgress(task.id, status);
            _showSuccessSnackBar(context, 'Task status updated');
          } catch (e) {
            _showErrorSnackBar(context, 'Failed to update task status');
          }
        },
      ),
    );
  }

  void _showAddTaskBottomSheet(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<TasksCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddTaskSheet(
        isDark: isDark,
        l10n: l10n,
        onSave: (task) {
          try {
            cubit.addTask(task);
            _showSuccessSnackBar(context, 'Task added successfully');
          } catch (e) {
            _showErrorSnackBar(context, 'Failed to add task');
          }
        },
      ),
    );
  }

  void _showEditTaskBottomSheet(
    BuildContext context,
    TasksCubit cubit,
    TaskModel task,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddTaskSheet(
        isDark: isDark,
        l10n: l10n,
        existingTask: task,
        onSave: (updatedTask) {
          try {
            cubit.updateTask(updatedTask);
            _showSuccessSnackBar(context, l10n.saveChanges);
          } catch (e) {
            _showErrorSnackBar(context, 'Failed to update task');
          }
        },
      ),
    );
  }
}

// Task Card Widget
class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final AppLocalizations l10n;
  final ResponsiveUtil responsive;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleBookmark;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.isDark,
    required this.l10n,
    required this.responsive,
    required this.onTap,
    required this.onToggleComplete,
    required this.onToggleBookmark,
    required this.onDelete,
  });

  // Check if task is AI suggested (based on task source or metadata)
  bool get isAiSuggested => task.source == TaskSource.aiGenerated;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.isOverdue;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: responsive.p12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(responsive.radius16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: responsive.p24),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteTask),
            content: Text(l10n.deleteTaskConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: responsive.p12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(responsive.radius16),
            border: Border.all(
              color: isOverdue
                  ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                  : isAiSuggested
                  ? (isDark
                        ? const Color(0xFF7C3AED).withOpacity(0.4)
                        : const Color(0xFFDDD6FE))
                  : Colors.transparent,
              width: (isOverdue || isAiSuggested) ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.p16,
                  responsive.p12,
                  responsive.p8,
                  0,
                ),
                child: Row(
                  children: [
                    // Category badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.p8,
                        vertical: responsive.p4,
                      ),
                      decoration: BoxDecoration(
                        color: task.category.color.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(responsive.radius8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.category.icon,
                            size: 12,
                            color: task.category.color,
                          ),
                          SizedBox(width: responsive.p4),
                          Text(
                            task.category.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: task.category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: responsive.p8),
                    // Priority badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.p8,
                        vertical: responsive.p4,
                      ),
                      decoration: BoxDecoration(
                        color: task.priority.color.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(responsive.radius8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.priority.icon,
                            size: 12,
                            color: task.priority.color,
                          ),
                          SizedBox(width: responsive.p4),
                          Text(
                            task.priority.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: task.priority.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // AI Suggested badge
                    if (isAiSuggested) ...[
                      SizedBox(width: responsive.p8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.p8,
                          vertical: responsive.p4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7C3AED),
                              const Color(0xFFA855F7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            responsive.radius8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: responsive.p4),
                            const Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Overdue badge
                    if (isOverdue && !isCompleted) ...[
                      SizedBox(width: responsive.p8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.p8,
                          vertical: responsive.p4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                            responsive.radius8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 10,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: responsive.p4),
                            const Text(
                              'Overdue',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Bookmark
                    IconButton(
                      onPressed: onToggleBookmark,
                      icon: Icon(
                        task.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: task.isBookmarked
                            ? const Color(0xFFF59E0B)
                            : (isDark ? Colors.white38 : Colors.black26),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.p16,
                  responsive.p8,
                  responsive.p16,
                  responsive.p12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: onToggleComplete,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : (isDark ? Colors.white38 : Colors.black26),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: responsive.p12),
                    // Task info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: responsive.fontSize16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: isDark
                                  ? Colors.white54
                                  : Colors.black38,
                            ),
                          ),
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            SizedBox(height: responsive.p4),
                            Text(
                              task.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: responsive.fontSize14,
                                color: isDark ? Colors.white54 : Colors.black54,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                          if (task.courseName != null) ...[
                            SizedBox(height: responsive.p8),
                            Row(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 14,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                                SizedBox(width: responsive.p4),
                                Text(
                                  task.courseName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: EdgeInsets.fromLTRB(
                  responsive.p16,
                  responsive.p8,
                  responsive.p16,
                  responsive.p12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(responsive.radius16),
                    bottomRight: Radius.circular(responsive.radius16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: isOverdue
                          ? const Color(0xFFEF4444)
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                    SizedBox(width: responsive.p4),
                    Text(
                      _formatDueDate(task.dueDate, l10n),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isOverdue
                            ? const Color(0xFFEF4444)
                            : (isDark ? Colors.white54 : Colors.black54),
                      ),
                    ),
                    if (task.estimatedMinutes != null) ...[
                      SizedBox(width: responsive.p16),
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      SizedBox(width: responsive.p4),
                      Text(
                        _formatDuration(task.estimatedMinutes!),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (task.subtasks != null && task.subtasks!.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.p8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${task.completedSubtasks?.length ?? 0}/${task.subtasks!.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return '${l10n.today}, ${_formatTime(date)}';
    } else if (taskDate == tomorrow) {
      return '${l10n.tomorrow}, ${_formatTime(date)}';
    } else if (date.isBefore(now)) {
      return '${l10n.overdue} ${l10n.daysAgo(-task.daysUntilDue)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

// Filter Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final TasksCubit cubit;

  const _FilterBottomSheet({
    required this.isDark,
    required this.l10n,
    required this.cubit,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late TasksFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.cubit.state.filter;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.l10n.filter,
                  style: TextStyle(
                    fontSize: responsive.fontSize18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _filter = const TasksFilter());
                  },
                  child: Text(widget.l10n.clearAll),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status filter
                  _buildFilterSection(
                    widget.l10n.status,
                    TaskStatus.values.map((status) {
                      return _FilterChip(
                        label: status.label,
                        isSelected: _filter.status == status,
                        color: status.color,
                        isDark: widget.isDark,
                        onSelected: (selected) {
                          setState(() {
                            _filter = selected
                                ? _filter.copyWith(status: status)
                                : _filter.copyWith(clearStatus: true);
                          });
                        },
                      );
                    }).toList(),
                    responsive,
                  ),
                  SizedBox(height: responsive.p16),
                  // Priority filter
                  _buildFilterSection(
                    widget.l10n.priority,
                    TaskPriority.values.map((priority) {
                      return _FilterChip(
                        label: priority.label,
                        isSelected: _filter.priority == priority,
                        color: priority.color,
                        isDark: widget.isDark,
                        onSelected: (selected) {
                          setState(() {
                            _filter = selected
                                ? _filter.copyWith(priority: priority)
                                : _filter.copyWith(clearPriority: true);
                          });
                        },
                      );
                    }).toList(),
                    responsive,
                  ),
                  SizedBox(height: responsive.p16),
                  // Category filter
                  _buildFilterSection(
                    widget.l10n.category,
                    TaskCategory.values.map((category) {
                      return _FilterChip(
                        label: category.label,
                        isSelected: _filter.category == category,
                        color: category.color,
                        isDark: widget.isDark,
                        onSelected: (selected) {
                          setState(() {
                            _filter = selected
                                ? _filter.copyWith(category: category)
                                : _filter.copyWith(clearCategory: true);
                          });
                        },
                      );
                    }).toList(),
                    responsive,
                  ),
                  SizedBox(height: responsive.p16),
                  // Bookmarked filter
                  _buildFilterSection(widget.l10n.bookmarked, [
                    _FilterChip(
                      label: widget.l10n.yes,
                      isSelected: _filter.isBookmarked == true,
                      color: const Color(0xFFF59E0B),
                      isDark: widget.isDark,
                      onSelected: (selected) {
                        setState(() {
                          _filter = selected
                              ? _filter.copyWith(isBookmarked: true)
                              : _filter.copyWith(clearIsBookmarked: true);
                        });
                      },
                    ),
                    _FilterChip(
                      label: widget.l10n.no,
                      isSelected: _filter.isBookmarked == false,
                      color: Colors.grey,
                      isDark: widget.isDark,
                      onSelected: (selected) {
                        setState(() {
                          _filter = selected
                              ? _filter.copyWith(isBookmarked: false)
                              : _filter.copyWith(clearIsBookmarked: true);
                        });
                      },
                    ),
                  ], responsive),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.cubit.setFilter(_filter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: responsive.p14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius12),
                  ),
                ),
                child: Text(widget.l10n.applyFilters),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<Widget> chips,
    ResponsiveUtil responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        SizedBox(height: responsive.p8),
        Wrap(
          spacing: responsive.p8,
          runSpacing: responsive.p8,
          children: chips,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: color.withValues(alpha: 0.2),
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.withValues(alpha: 0.1),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : (isDark ? Colors.white70 : Colors.black54),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : Colors.transparent),
    );
  }
}

// Task Details Sheet
class _TaskDetailsSheet extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final AppLocalizations l10n;
  final ResponsiveUtil responsive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(TaskStatus) onStatusChange;

  const _TaskDetailsSheet({
    required this.task,
    required this.isDark,
    required this.l10n,
    required this.responsive,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(responsive.p12),
                        decoration: BoxDecoration(
                          color: task.category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            responsive.radius12,
                          ),
                        ),
                        child: Icon(
                          task.category.icon,
                          color: task.category.color,
                          size: responsive.p24,
                        ),
                      ),
                      SizedBox(width: responsive.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: responsive.fontSize18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (task.courseName != null) ...[
                              SizedBox(height: responsive.p4),
                              Text(
                                task.courseName!,
                                style: TextStyle(
                                  fontSize: responsive.fontSize14,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p24),
                  // Status selector
                  Text(
                    l10n.status,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: responsive.p8),
                  Wrap(
                    spacing: responsive.p8,
                    children: TaskStatus.values.map((status) {
                      final isSelected = task.status == status;
                      return ChoiceChip(
                        label: Text(status.label),
                        selected: isSelected,
                        onSelected: (_) {
                          onStatusChange(status);
                          Navigator.pop(context);
                        },
                        selectedColor: status.color.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? status.color
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      );
                    }).toList(),
                  ),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    SizedBox(height: responsive.p24),
                    Text(
                      l10n.description,
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: responsive.p8),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                  SizedBox(height: responsive.p24),
                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_rounded,
                          label: l10n.dueDate,
                          value:
                              '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                          color: task.isOverdue
                              ? const Color(0xFFEF4444)
                              : AppTheme.primaryColor,
                          isDark: isDark,
                          responsive: responsive,
                        ),
                      ),
                      SizedBox(width: responsive.p12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.flag_rounded,
                          label: l10n.priority,
                          value: task.priority.label,
                          color: task.priority.color,
                          isDark: isDark,
                          responsive: responsive,
                        ),
                      ),
                    ],
                  ),
                  if (task.subtasks != null && task.subtasks!.isNotEmpty) ...[
                    SizedBox(height: responsive.p24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.subtasks,
                          style: TextStyle(
                            fontSize: responsive.fontSize14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        Text(
                          '${task.completedSubtasks?.length ?? 0}/${task.subtasks!.length}',
                          style: TextStyle(
                            fontSize: responsive.fontSize14,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.p8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.subtaskProgress,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation(
                          AppTheme.primaryColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    SizedBox(height: responsive.p12),
                    ...task.subtasks!.map((subtask) {
                      final isCompleted =
                          task.completedSubtasks?.contains(subtask) ?? false;
                      return Padding(
                        padding: EdgeInsets.only(bottom: responsive.p8),
                        child: Row(
                          children: [
                            Icon(
                              isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 20,
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : (isDark ? Colors.white38 : Colors.black26),
                            ),
                            SizedBox(width: responsive.p8),
                            Text(
                              subtask,
                              style: TextStyle(
                                fontSize: responsive.fontSize14,
                                color: isDark ? Colors.white70 : Colors.black54,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.delete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: EdgeInsets.symmetric(vertical: responsive.p12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: responsive.p12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final ResponsiveUtil responsive;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: responsive.p4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p4),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Add Task Sheet
class _AddTaskSheet extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final TaskModel? existingTask;
  final Function(TaskModel) onSave;

  const _AddTaskSheet({
    required this.isDark,
    required this.l10n,
    this.existingTask,
    required this.onSave,
  });

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskCategory _category;
  late TaskPriority _priority;
  late DateTime _dueDate;
  int? _estimatedMinutes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?.description ?? '',
    );
    _category = widget.existingTask?.category ?? TaskCategory.assignment;
    _priority = widget.existingTask?.priority ?? TaskPriority.medium;
    _dueDate =
        widget.existingTask?.dueDate ??
        DateTime.now().add(const Duration(days: 1));
    _estimatedMinutes = widget.existingTask?.estimatedMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingTask != null
                      ? widget.l10n.editTask
                      : widget.l10n.addTask,
                  style: TextStyle(
                    fontSize: responsive.fontSize18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: widget.l10n.taskTitle,
                      hintText: widget.l10n.enterTaskTitle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                  ),
                  SizedBox(height: responsive.p16),
                  // Description
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: widget.l10n.description,
                      hintText: widget.l10n.enterDescription,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  SizedBox(height: responsive.p16),
                  // Category
                  Text(
                    widget.l10n.category,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: responsive.p8),
                  Wrap(
                    spacing: responsive.p8,
                    runSpacing: responsive.p8,
                    children: TaskCategory.values.map((category) {
                      final isSelected = _category == category;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 16,
                              color: isSelected ? category.color : null,
                            ),
                            SizedBox(width: responsive.p4),
                            Text(category.label),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _category = category),
                        selectedColor: category.color.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? category.color
                              : (widget.isDark
                                    ? Colors.white70
                                    : Colors.black54),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: responsive.p16),
                  // Priority
                  Text(
                    widget.l10n.priority,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: responsive.p8),
                  Wrap(
                    spacing: responsive.p8,
                    children: TaskPriority.values.map((priority) {
                      final isSelected = _priority == priority;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              priority.icon,
                              size: 16,
                              color: isSelected ? priority.color : null,
                            ),
                            SizedBox(width: responsive.p4),
                            Text(priority.label),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _priority = priority),
                        selectedColor: priority.color.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? priority.color
                              : (widget.isDark
                                    ? Colors.white70
                                    : Colors.black54),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: responsive.p16),
                  // Due date
                  ListTile(
                    onTap: () async {
                      final currentContext = context;
                      final date = await showDatePicker(
                        context: currentContext,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && mounted) {
                        final time = await showTimePicker(
                          context: currentContext,
                          initialTime: TimeOfDay.fromDateTime(_dueDate),
                        );
                        if (mounted) {
                          setState(() {
                            _dueDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time?.hour ?? _dueDate.hour,
                              time?.minute ?? _dueDate.minute,
                            );
                          });
                        }
                      }
                    },
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(
                      widget.l10n.dueDate,
                      style: TextStyle(
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                        fontSize: responsive.fontSize14,
                      ),
                    ),
                    subtitle: Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year} ${_dueDate.hour.toString().padLeft(2, '0')}:${_dueDate.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black87,
                        fontSize: responsive.fontSize16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(widget.l10n.pleaseEnterTaskTitle)),
                    );
                    return;
                  }

                  final task = TaskModel(
                    id:
                        widget.existingTask?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                    category: _category,
                    priority: _priority,
                    status: widget.existingTask?.status ?? TaskStatus.pending,
                    dueDate: _dueDate,
                    createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
                    estimatedMinutes: _estimatedMinutes,
                    isBookmarked: widget.existingTask?.isBookmarked ?? false,
                  );

                  widget.onSave(task);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: responsive.p14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius12),
                  ),
                ),
                child: Text(
                  widget.existingTask != null
                      ? widget.l10n.saveChanges
                      : widget.l10n.addTask,
                  style: TextStyle(
                    fontSize: responsive.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });
}
