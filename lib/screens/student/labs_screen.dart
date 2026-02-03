import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/labs/labs_cubit.dart';
import '../../bloc/labs/labs_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/app_theme.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/labs/lab_model.dart';
import '../../common/utils/responsive.dart';
import '../../widgets/student/labs/lab_card.dart';
import '../../widgets/student/labs/labs_filter_sheet.dart';
import '../../widgets/student/labs/lab_details_sheet.dart';

class LabsScreen extends StatefulWidget {
  const LabsScreen({super.key});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> with TickerProviderStateMixin {
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
      context.read<LabsCubit>().setSelectedTab(_tabController.index);
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

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocProvider(
      create: (_) => LabsCubit()..loadLabs(),
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
                      child: BlocConsumer<LabsCubit, LabsState>(
                        listener: (context, state) {
                          if (state.error != null) {
                            _showErrorSnackBar(context, state.error!);
                            context.read<LabsCubit>().clearError();
                          }
                        },
                        builder: (context, state) {
                          if (state.isLoading && state.labs.isEmpty) {
                            return _buildLoadingState(isDark);
                          }
                          if (state.error != null && state.labs.isEmpty) {
                            return _buildErrorState(
                              context,
                              state.error!,
                              isDark,
                              l10n,
                              responsive,
                            );
                          }
                          return _buildLabsList(
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
                        l10n.labs,
                        style: TextStyle(
                          fontSize: responsive.fontSize24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      BlocBuilder<LabsCubit, LabsState>(
                        builder: (context, state) {
                          return Text(
                            '${state.todayCount} ${l10n.labsToday}',
                            style: TextStyle(
                              fontSize: responsive.fontSize13,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
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
                      context.read<LabsCubit>().setSearchQuery('');
                    }
                  }),
                  isDark: isDark,
                  responsive: responsive,
                ),
                SizedBox(width: responsive.p8),
                // Filter button
                BlocBuilder<LabsCubit, LabsState>(
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
                    context.read<LabsCubit>().setSearchQuery(value);
                  },
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: responsive.fontSize14,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchLabs,
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
            BlocBuilder<LabsCubit, LabsState>(
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
    LabsState state,
    bool isDark,
    ResponsiveUtil responsive,
  ) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.schedule_rounded,
          label: 'Upcoming',
          value: state.upcomingCount.toString(),
          color: const Color(0xFF3B82F6),
          isDark: isDark,
          responsive: responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildStatCard(
          icon: Icons.play_circle_rounded,
          label: 'In Progress',
          value: state.inProgressCount.toString(),
          color: const Color(0xFFF59E0B),
          isDark: isDark,
          responsive: responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          label: 'Completed',
          value: state.completedCount.toString(),
          color: const Color(0xFF10B981),
          isDark: isDark,
          responsive: responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildStatCard(
          icon: Icons.cancel_rounded,
          label: 'Missed',
          value: state.missedCount.toString(),
          color: const Color(0xFFEF4444),
          isDark: isDark,
          responsive: responsive,
        ),
      ],
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
    return Expanded(
      child: Container(
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
          Tab(text: l10n.upcoming),
          Tab(text: l10n.inProgress),
          Tab(text: l10n.completed),
          Tab(text: l10n.missed),
        ],
        onTap: (value) {
          context.read<LabsCubit>().setSelectedTab(value);
          context.read<LabsCubit>().loadLabs();
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
              onPressed: () => context.read<LabsCubit>().loadLabs(),
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

  Widget _buildLabsList(
    BuildContext context,
    LabsState state,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final labs = state.filteredLabs;

    if (labs.isEmpty) {
      return _buildEmptyState(isDark, l10n, responsive);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<LabsCubit>().loadLabs(),
      color: const Color(0xFF3B82F6),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: responsive.p16, bottom: responsive.p24),
        itemCount: labs.length,
        itemBuilder: (context, index) {
          final lab = labs[index];
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
            child: LabCard(
              lab: lab,
              isDark: isDark,
              onTap: () => _showLabDetails(context, lab, isDark),
              onBookmark: () =>
                  context.read<LabsCubit>().toggleBookmark(lab.id),
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
                Icons.science_outlined,
                size: responsive.fontSize40,
                color: const Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: responsive.p20),
            Text(
              l10n.noLabsFound,
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p8),
            Text(
              l10n.noLabsDescription,
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

  void _showFilterSheet(BuildContext context, LabsState state, bool isDark) {
    final cubit = context.read<LabsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => LabsFilterBottomSheet(
        currentFilter: state.filter,
        availableCourses: state.availableCourses,
        isDark: isDark,
        onApply: (filter) => cubit.setFilter(filter),
        onClear: () => cubit.clearFilters(),
      ),
    );
  }

  void _showLabDetails(BuildContext context, LabModel lab, bool isDark) {
    final cubit = context.read<LabsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => LabDetailsSheet(
        lab: lab,
        isDark: isDark,
        onStatusChange: (status) => cubit.updateLabStatus(lab.id, status),
        onSubmitReport: (url) => cubit.submitLabReport(lab.id, url),
        onJoinVirtual: () {
          // Handle join virtual lab
          Navigator.pop(sheetContext);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Opening virtual lab session...'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
