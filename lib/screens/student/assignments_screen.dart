import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/assignments/assignment_bloc.dart';
import '../../bloc/assignments/assignment_event.dart';
import '../../bloc/assignments/assignment_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/responsive.dart';
import '../../config/app_theme.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/assignments/assignment_model.dart';
import '../../widgets/student/academic/academic_list_skeleton.dart';
import '../../widgets/student/assignments/assignment_card.dart';
import '../../widgets/student/assignments/assignments_filter_sheet.dart';
import 'assignment_detail_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  final int? preselectedCourseId;

  const AssignmentsScreen({super.key, this.preselectedCourseId});

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
    _tabController = TabController(length: 4, vsync: this);
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AssignmentBloc>().add(
        FetchAssignments(courseId: widget.preselectedCourseId),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }

    context.read<AssignmentBloc>().add(
      SetAssignmentFilterStatus(
        filterStatus: _filterForIndex(_tabController.index),
      ),
    );
  }

  AssignmentFilterStatus _filterForIndex(int index) {
    switch (index) {
      case 1:
        return AssignmentFilterStatus.submitted;
      case 2:
        return AssignmentFilterStatus.pending;
      case 3:
        return AssignmentFilterStatus.overdue;
      default:
        return AssignmentFilterStatus.all;
    }
  }

  int _indexForFilter(AssignmentFilterStatus status) {
    switch (status) {
      case AssignmentFilterStatus.submitted:
        return 1;
      case AssignmentFilterStatus.pending:
        return 2;
      case AssignmentFilterStatus.overdue:
        return 3;
      case AssignmentFilterStatus.all:
        return 0;
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
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
                  BlocBuilder<AssignmentBloc, AssignmentState>(
                    builder: (context, state) {
                      return _buildCourseSelector(
                        context,
                        state,
                        isDark,
                        responsive,
                      );
                    },
                  ),
                  _buildTabBar(context, isDark, l10n, responsive),
                  Expanded(
                    child: BlocConsumer<AssignmentBloc, AssignmentState>(
                      listener: (context, state) {
                        final selectedIndex = _indexForFilter(
                          state.filterStatus,
                        );
                        if (_tabController.index != selectedIndex) {
                          _tabController.animateTo(selectedIndex);
                        }

                        if (state.error != null) {
                          _showErrorSnackBar(context, state.error!);
                          context.read<AssignmentBloc>().add(
                            const ClearError(),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state.isListLoading) {
                          return _buildLoadingState(isDark);
                        }
                        if (state.enrolledCourses.isEmpty) {
                          return _buildNoCoursesState(isDark, responsive);
                        }
                        if (state.error != null && state.assignments.isEmpty) {
                          return _buildErrorState(
                            context,
                            state.selectedCourseId ??
                                widget.preselectedCourseId,
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
    );
  }

  Widget _buildCourseSelector(
    BuildContext context,
    AssignmentState state,
    bool isDark,
    ResponsiveUtil responsive,
  ) {
    if (state.enrolledCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedCourseId =
        state.selectedCourseId ?? state.enrolledCourses.first.id;

    return Container(
      margin: EdgeInsets.fromLTRB(
        responsive.p16,
        responsive.p4,
        responsive.p16,
        responsive.p8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p12,
        vertical: responsive.p4,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.3)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.school_rounded,
            color: const Color(0xFF3B82F6),
            size: responsive.fontSize18,
          ),
          SizedBox(width: responsive.p8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedCourseId,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                style: TextStyle(
                  fontSize: responsive.fontSize13,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                items: state.enrolledCourses
                    .map(
                      (course) => DropdownMenuItem<int>(
                        value: course.id,
                        child: Text('${course.code} • ${course.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null || value == state.selectedCourseId) {
                    return;
                  }
                  context.read<AssignmentBloc>().add(
                    FetchAssignments(courseId: value),
                  );
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.read<AssignmentBloc>().add(
              RefreshAssignments(courseId: state.selectedCourseId),
            ),
            splashRadius: responsive.p20,
            icon: const Icon(Icons.refresh_rounded),
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ],
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
                _buildCircularButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: () => Navigator.pop(context),
                  isDark: isDark,
                  responsive: responsive,
                ),
                SizedBox(width: responsive.p12),
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
                      BlocBuilder<AssignmentBloc, AssignmentState>(
                        builder: (context, state) {
                          final overdue = state.overdueCount;
                          final subtitle = overdue > 0
                              ? '$overdue ${l10n.overdue}'
                              : '${state.pendingCount} ${l10n.pending}';
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
                _buildCircularButton(
                  icon: _isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  onTap: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        context.read<AssignmentBloc>().add(
                          const SetAssignmentSearchQuery(query: ''),
                        );
                      }
                    });
                  },
                  isDark: isDark,
                  responsive: responsive,
                ),
                SizedBox(width: responsive.p8),
                BlocBuilder<AssignmentBloc, AssignmentState>(
                  builder: (context, state) {
                    return _buildCircularButton(
                      icon: Icons.tune_rounded,
                      onTap: () => _showFilterSheet(context, state, isDark),
                      isDark: isDark,
                      responsive: responsive,
                      hasIndicator:
                          state.filterStatus != AssignmentFilterStatus.all,
                    );
                  },
                ),
              ],
            ),
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
                    context.read<AssignmentBloc>().add(
                      SetAssignmentSearchQuery(query: value),
                    );
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
            SizedBox(height: responsive.p16),
            BlocBuilder<AssignmentBloc, AssignmentState>(
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
          width: responsive.p48,
          height: responsive.p48,
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
    AssignmentState state,
    bool isDark,
    ResponsiveUtil responsive,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.assignment_rounded,
            label: 'Total',
            value: state.totalCount.toString(),
            color: const Color(0xFF6366F1),
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
            icon: Icons.hourglass_empty_rounded,
            label: 'Pending',
            value: state.pendingCount.toString(),
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            responsive: responsive,
          ),
          SizedBox(width: responsive.p8),
          _buildStatCard(
            icon: Icons.warning_amber_rounded,
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
      width: responsive.p96,
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
          Tab(text: l10n.submitted),
          Tab(text: l10n.pending),
          Tab(text: l10n.overdue),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return AcademicListSkeleton(isDark: isDark);
  }

  Widget _buildErrorState(
    BuildContext context,
    int? courseId,
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
              onPressed: () => context.read<AssignmentBloc>().add(
                FetchAssignments(courseId: courseId),
              ),
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
    AssignmentState state,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final assignments = state.filteredAssignments;

    if (assignments.isEmpty) {
      return _buildEmptyState(isDark, l10n, responsive);
    }

    return RefreshIndicator(
      onRefresh: () => _refreshAssignments(context),
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
              onTap: () => _openAssignmentDetails(context, assignment),
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
              'No assignments are available yet. Enroll in a course to get started.',
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

  Widget _buildNoCoursesState(bool isDark, ResponsiveUtil responsive) {
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
                Icons.school_outlined,
                size: responsive.fontSize40,
                color: const Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: responsive.p20),
            Text(
              'No enrolled courses found',
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p8),
            Text(
              'Enroll in a course to view available assignments.',
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

  Future<void> _refreshAssignments(BuildContext context) async {
    final bloc = context.read<AssignmentBloc>();
    bloc.add(RefreshAssignments(courseId: bloc.state.selectedCourseId));
    await bloc.stream.firstWhere((state) => !state.isListLoading);
  }

  void _showFilterSheet(
    BuildContext context,
    AssignmentState state,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssignmentsFilterBottomSheet(
        currentFilter: state.filterStatus,
        isDark: isDark,
        onApply: (filter) {
          context.read<AssignmentBloc>().add(
            SetAssignmentFilterStatus(filterStatus: filter),
          );
        },
        onClear: () {
          context.read<AssignmentBloc>().add(
            const SetAssignmentFilterStatus(
              filterStatus: AssignmentFilterStatus.all,
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAssignmentDetails(
    BuildContext context,
    AssignmentModel assignment,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentDetailScreen(assignment: assignment),
      ),
    );
  }
}
