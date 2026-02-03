import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/assignments/assignments_cubit.dart';
import '../../bloc/assignments/assignments_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/app_theme.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/assignments/assignment_model.dart';
import '../../common/utils/responsive.dart';
import '../../widgets/student/assignments/assignment_card.dart';
import '../../widgets/student/assignments/assignments_filter_sheet.dart';
import '../../widgets/student/assignments/assignment_details_sheet.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (mounted) {
      context.read<AssignmentsCubit>().setSelectedTab(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      create: (_) => AssignmentsCubit()..loadAssignments(),
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
                      child: BlocConsumer<AssignmentsCubit, AssignmentsState>(
                        listener: (context, state) {
                          if (state.error != null) {
                            _showErrorSnackBar(context, state.error!);
                            context.read<AssignmentsCubit>().clearError();
                          }
                        },
                        builder: (context, state) {
                          if (state.isLoading && state.assignments.isEmpty) {
                            return _buildLoadingState(isDark);
                          }
                          if (state.error != null &&
                              state.assignments.isEmpty) {
                            return _buildErrorState(
                              context,
                              state.error!,
                              isDark,
                              l10n,
                              responsive,
                            );
                          }
                          return _buildAssignmentsList(
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
            ),
          );
        },
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
        return Transform.translate(
          offset: Offset(0, -30 * (1 - _headerAnimationController.value)),
          child: Opacity(
            opacity: _headerAnimationController.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(responsive.p16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Back button
                _buildCircularButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: () => Navigator.pop(context),
                  isDark: isDark,
                  responsive: responsive,
                ),
                SizedBox(width: responsive.p12),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.assignments,
                        style: TextStyle(
                          fontSize: responsive.fontSize24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      BlocBuilder<AssignmentsCubit, AssignmentsState>(
                        builder: (context, state) {
                          final dueToday = state.dueTodayCount;
                          final overdue = state.overdueCount;
                          String subtitle = '';
                          if (overdue > 0) {
                            subtitle = '$overdue ${l10n.overdue}';
                          } else if (dueToday > 0) {
                            subtitle = '$dueToday ${l10n.dueToday}';
                          } else {
                            subtitle = '${state.pendingCount} ${l10n.pending}';
                          }
                          return Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: responsive.fontSize13,
                              color: overdue > 0
                                  ? const Color(0xFFEF4444)
                                  : (isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600),
                              fontWeight: overdue > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Search button
                _buildCircularButton(
                  icon: _isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  onTap: () => setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      context.read<AssignmentsCubit>().setSearchQuery('');
                    }
                  }),
                  isDark: isDark,
                  responsive: responsive,
                ),
                SizedBox(width: responsive.p8),
                // Filter button
                BlocBuilder<AssignmentsCubit, AssignmentsState>(
                  builder: (context, state) {
                    return _buildCircularButton(
                      icon: Icons.tune_rounded,
                      onTap: () => _showFilterSheet(context, state, isDark),
                      isDark: isDark,
                      responsive: responsive,
                      hasIndicator: state.filter.hasActiveFilters,
                    );
                  },
                ),
              ],
            ),
            // Search bar
            if (_isSearching) ...[
              SizedBox(height: responsive.p12),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    context.read<AssignmentsCubit>().setSearchQuery(value);
                  },
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: responsive.fontSize14,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchAssignments,
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p12,
                    ),
                  ),
                ),
              ),
            ],
            // Quick stats
            SizedBox(height: responsive.p16),
            BlocBuilder<AssignmentsCubit, AssignmentsState>(
              builder: (context, state) {
                return _buildQuickStats(state, isDark, responsive);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required ResponsiveUtil responsive,
    bool hasIndicator = false,
  }) {
    return Stack(
      children: [
        Container(
          width: responsive.p44,
          height: responsive.p44,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey.shade800.withValues(alpha: 0.5)
                : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Icon(
                icon,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                size: responsive.fontSize20,
              ),
            ),
          ),
        ),
        if (hasIndicator)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStats(
    AssignmentsState state,
    bool isDark,
    ResponsiveUtil responsive,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.hourglass_empty_rounded,
            label: 'Pending',
            value: state.pendingCount.toString(),
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            responsive: responsive,
          ),
          SizedBox(width: responsive.p8),
          _buildStatCard(
            icon: Icons.cloud_upload_rounded,
            label: 'Submitted',
            value: state.submittedCount.toString(),
            color: const Color(0xFF3B82F6),
            isDark: isDark,
            responsive: responsive,
          ),
          SizedBox(width: responsive.p8),
          _buildStatCard(
            icon: Icons.grading_rounded,
            label: 'Graded',
            value: state.gradedCount.toString(),
            color: const Color(0xFF10B981),
            isDark: isDark,
            responsive: responsive,
          ),
          SizedBox(width: responsive.p8),
          _buildStatCard(
            icon: Icons.stars_rounded,
            label: 'Avg Grade',
            value: '${state.averageGrade.toStringAsFixed(0)}%',
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            responsive: responsive,
          ),
          SizedBox(width: responsive.p8),
          _buildStatCard(
            icon: Icons.not_interested_rounded,
            label: 'Overdue',
            value: state.overdueCount.toString(),
            color: const Color(0xFFEF4444),
            isDark: isDark,
            responsive: responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required ResponsiveUtil responsive,
  }) {
    return Container(
      width: responsive.p80,
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.2 : 0.1),
            color.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: responsive.fontSize20),
          SizedBox(height: responsive.p4),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize10,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
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
      margin: EdgeInsets.symmetric(horizontal: responsive.p16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.3)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(responsive.radius10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? Colors.grey.shade400
            : Colors.grey.shade600,
        labelStyle: TextStyle(
          fontSize: responsive.fontSize12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: responsive.fontSize12,
          fontWeight: FontWeight.normal,
        ),
        padding: EdgeInsets.all(responsive.p4),
        tabs: [
          Tab(text: l10n.all),
          Tab(text: l10n.pending),
          Tab(text: l10n.submitted),
          Tab(text: l10n.graded),
          Tab(text: l10n.overdue),
        ],
        onTap: (index) {
          context.read<AssignmentsCubit>().setSelectedTab(index);
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          isDark ? Colors.white : const Color(0xFF3B82F6),
        ),
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
            Icon(
              Icons.error_outline_rounded,
              size: responsive.fontSize56,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: responsive.p16),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: responsive.p24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<AssignmentsCubit>().loadAssignments(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.p24,
                  vertical: responsive.p12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsList(
    BuildContext context,
    AssignmentsState state,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final assignments = state.filteredAssignments;

    if (assignments.isEmpty) {
      return _buildEmptyState(isDark, l10n, responsive);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AssignmentsCubit>().loadAssignments(),
      color: const Color(0xFF3B82F6),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: responsive.p16, bottom: responsive.p24),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: AssignmentCard(
              assignment: assignment,
              isDark: isDark,
              onTap: () => _showAssignmentDetails(context, assignment, isDark),
              onBookmark: () => context.read<AssignmentsCubit>().toggleBookmark(
                assignment.id,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
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
              width: responsive.p80,
              height: responsive.p80,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: responsive.fontSize40,
                color: const Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: responsive.p20),
            Text(
              l10n.noAssignmentsFound,
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p8),
            Text(
              l10n.noAssignmentsDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    AssignmentsState state,
    bool isDark,
  ) {
    final cubit = context.read<AssignmentsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AssignmentsFilterBottomSheet(
        currentFilter: state.filter,
        availableCourses: state.availableCourses,
        isDark: isDark,
        onApply: (filter) => cubit.setFilter(filter),
        onClear: () => cubit.clearFilters(),
      ),
    );
  }

  void _showAssignmentDetails(
    BuildContext context,
    AssignmentModel assignment,
    bool isDark,
  ) {
    final cubit = context.read<AssignmentsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AssignmentDetailsSheet(
        assignment: assignment,
        isDark: isDark,
        onSubmit: () {
          Navigator.pop(sheetContext);
          _showSubmitDialog(context, assignment, cubit);
        },
        onDownloadAttachments: () {
          Navigator.pop(sheetContext);
          _showSuccessSnackBar(context, 'Downloading attachments...');
        },
      ),
    );
  }

  void _showSubmitDialog(
    BuildContext context,
    AssignmentModel assignment,
    AssignmentsCubit cubit,
  ) {
    final responsive = context.responsive;
    final isDark = context.read<ThemeBloc>().state.isDark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius16),
        ),
        title: Text(
          'Submit Assignment',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment submission feature will be available soon.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: responsive.p16),
            Text(
              'You will be able to:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p8),
            _buildFeatureItem('Upload files', responsive, isDark),
            _buildFeatureItem('Add comments', responsive, isDark),
            _buildFeatureItem('Track submission status', responsive, isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    String text,
    ResponsiveUtil responsive,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.p4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: responsive.fontSize16,
            color: const Color(0xFF10B981),
          ),
          SizedBox(width: responsive.p8),
          Text(
            text,
            style: TextStyle(
              fontSize: responsive.fontSize13,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
