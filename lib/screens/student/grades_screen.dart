import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/grades/grades_cubit.dart';
import '../../bloc/grades/grades_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/services/grade_pdf_service.dart';
import '../../common/utils/responsive.dart';
import '../../features/walkthrough/student_walkthrough_registry.dart';
import '../../features/walkthrough/walkthrough_target.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/grades/grade_model.dart';
import '../../utils/navigation/safe_back.dart';
import '../../services/api/core_api_client.dart';
import '../../services/api/grades_service.dart';
import '../../services/api/student_stats_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/student/grades/grade_card.dart';
import '../../widgets/student/grades/grades_filter_sheet.dart';
import '../../widgets/student/grades/grade_details_sheet.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GradePdfReportService _pdfService = GradePdfReportService();
  bool _isSearching = false;
  GradesCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  void _setupTabListener(GradesCubit cubit) {
    if (_cubit != cubit) {
      _cubit = cubit;
      _tabController.removeListener(_onTabChanged);
      _tabController.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (mounted && _cubit != null) {
      _cubit!.setSelectedTab(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
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
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _generatePdfReport(GradesState state) async {
    final cubit = context.read<GradesCubit>();
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    cubit.setGeneratingPdf(true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF6366F1)),
              const SizedBox(width: 16),
              Text(l10n.generatingReport),
            ],
          ),
        ),
      ),
    );

    try {
      final storageService = StorageService();
      final userData = await storageService.getUserData();
      final roleName = userData?.primaryRoleName ?? 'student';
      final roleLabel = roleName.isNotEmpty
          ? '${roleName[0].toUpperCase()}${roleName.substring(1)}'
          : 'Student';

      final reportData = GradeReportData(
        studentName: userData?.displayName ?? 'Student',
        studentId: userData?.userId.toString() ?? '',
        program: '$roleLabel Program',
        cumulativeGPA: state.statistics?.cumulativeGPA ?? 0,
        semesterGPA: state.semesterGPA,
        totalCredits: state.statistics?.totalCredits ?? 0,
        completedCredits: state.statistics?.completedCredits ?? 0,
        targetCredits: 120,
        currentSemester: state.selectedSemester != null
            ? '${state.selectedSemester!.name} ${state.selectedSemester!.year}'
            : (state.semesters.isNotEmpty
                  ? '${state.semesters.first.name} ${state.semesters.first.year}'
                  : 'Current'),
        courses: state.courses,
        semesters: state.semesters,
        gpaTrend: state.gradeTrend,
        statistics: state.statistics,
      );

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      await _pdfService.generateAndShareReport(
        context: context,
        data: reportData,
        reportTitle: l10n.gradeReport,
        isArabic: isArabic,
      );

      if (mounted) {
        navigator.pop(); // Close dialog
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.reportGenerated),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop(); // Close dialog
        messenger.showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        cubit.setGeneratingPdf(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocProvider(
          create: (context) {
            final coreApiClient = CoreApiClient();
            return GradesCubit(
              gradesService: GradesService(coreApiClient: coreApiClient),
              studentStatsService: StudentStatsService(
                coreApiClient: coreApiClient,
              ),
              storageService: StorageService(),
            );
          },
          child: BlocConsumer<GradesCubit, GradesState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                _showErrorSnackBar(context, state.errorMessage!);
                context.read<GradesCubit>().clearError();
              }
            },
            builder: (context, state) {
              // Setup tab listener with the cubit
              _setupTabListener(context.read<GradesCubit>());

              return StudentWalkthroughRouteMarker(
                segmentId: StudentWalkthroughIds.grades,
                child: Scaffold(
                  backgroundColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  body: SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(context, state, isDark, l10n),
                        if (_isSearching)
                          _buildSearchBar(context, isDark, l10n),
                        WalkthroughTarget(
                          id: StudentWalkthroughIds.gradesGpa,
                          child: _buildGPACard(context, state, isDark, l10n),
                        ),
                        WalkthroughTarget(
                          id: StudentWalkthroughIds.gradesTabs,
                          child: Column(
                            children: [
                              _buildSemesterSelector(
                                context,
                                state,
                                isDark,
                                l10n,
                              ),
                              _buildTabBar(context, state, isDark, l10n),
                            ],
                          ),
                        ),
                        Expanded(
                          child: WalkthroughTarget(
                            id: StudentWalkthroughIds.gradesList,
                            child: _buildContent(context, state, isDark, l10n),
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
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

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
            padding: EdgeInsets.all(responsive.p16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [Colors.white, const Color(0xFFF8FAFC)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Back button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _leaveStudentGradesScreen(context),
                    borderRadius: BorderRadius.circular(responsive.radius12),
                    child: Container(
                      padding: EdgeInsets.all(responsive.p10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                      ),
                      child: Icon(
                        iosBackIcon(context),
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: responsive.p12),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.grades,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: responsive.fontSize20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.academicPerformance,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: responsive.fontSize13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isSearching = !_isSearching);
                    },
                    borderRadius: BorderRadius.circular(responsive.radius12),
                    child: Container(
                      padding: EdgeInsets.all(responsive.p10),
                      decoration: BoxDecoration(
                        color: _isSearching
                            ? const Color(0xFF6366F1)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: _isSearching
                            ? Colors.white
                            : (isDark ? Colors.white : const Color(0xFF1E293B)),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: responsive.p8),
                // Filter button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showFilterSheet(context, state, isDark);
                    },
                    borderRadius: BorderRadius.circular(responsive.radius12),
                    child: Container(
                      padding: EdgeInsets.all(responsive.p10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: responsive.p8),
                // Analysis button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/grade-analysis');
                    },
                    borderRadius: BorderRadius.circular(responsive.radius12),
                    child: Container(
                      padding: EdgeInsets.all(responsive.p10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(
                          responsive.radius12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p16,
        vertical: responsive.p8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(responsive.radius14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            context.read<GradesCubit>().setSearchQuery(value);
          },
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: responsive.fontSize14,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchCourses,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: responsive.fontSize14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      context.read<GradesCubit>().setSearchQuery('');
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.p16,
              vertical: responsive.p14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPACard(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;
    final stats = state.statistics;

    return Container(
      margin: EdgeInsets.all(responsive.p16),
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(responsive.radius20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cumulativeGPA,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: responsive.fontSize13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: responsive.p4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stats?.cumulativeGPA.toStringAsFixed(2) ?? '0.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.fontSize32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: responsive.p6),
                        child: Text(
                          ' / 4.00',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: responsive.fontSize16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Actions
              Column(
                children: [
                  // Download PDF
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _generatePdfReport(state),
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      child: Container(
                        padding: EdgeInsets.all(responsive.p12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            responsive.radius12,
                          ),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: responsive.p16),
          // Stats row
          Container(
            padding: EdgeInsets.all(responsive.p14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(responsive.radius14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGPAStatItem(
                  responsive,
                  label: l10n.semesterGPA,
                  value: state.semesterGPA.toStringAsFixed(2),
                  icon: Icons.calendar_today_rounded,
                ),
                _buildGPAStatDivider(),
                _buildGPAStatItem(
                  responsive,
                  label: l10n.credits,
                  value:
                      '${stats?.completedCredits ?? 0}/${stats?.totalCredits ?? 0}',
                  icon: Icons.school_rounded,
                ),
                _buildGPAStatDivider(),
                _buildGPAStatItem(
                  responsive,
                  label: l10n.courses,
                  value: '${state.courses.length}',
                  icon: Icons.book_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPAStatItem(
    ResponsiveUtil responsive, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        SizedBox(height: responsive.p6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: responsive.fontSize11,
          ),
        ),
      ],
    );
  }

  Widget _buildGPAStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildSemesterSelector(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return Container(
      height: 44,
      margin: EdgeInsets.symmetric(horizontal: responsive.p16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.semesters.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = state.selectedSemesterId == null;
            return Padding(
              padding: EdgeInsets.only(right: responsive.p8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<GradesCubit>().setSelectedSemester(null);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.p16,
                    vertical: responsive.p10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(responsive.radius12),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    l10n.allSemesters,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                      fontSize: responsive.fontSize13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }

          final semester = state.semesters[index - 1];
          final isSelected = state.selectedSemesterId == semester.id;

          return Padding(
            padding: EdgeInsets.only(right: responsive.p8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<GradesCubit>().setSelectedSemester(semester.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.p16,
                  vertical: responsive.p10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white),
                  borderRadius: BorderRadius.circular(responsive.radius12),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      '${semester.name} ${semester.year}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        fontSize: responsive.fontSize13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (semester.isCurrent) ...[
                      SizedBox(width: responsive.p6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.p6,
                          vertical: responsive.p2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            responsive.radius4,
                          ),
                        ),
                        child: Text(
                          l10n.current,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF10B981),
                            fontSize: responsive.fontSize10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(responsive.radius12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B),
        labelStyle: TextStyle(
          fontSize: responsive.fontSize12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: responsive.fontSize12,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        padding: EdgeInsets.all(responsive.p4),
        tabs: [
          Tab(text: '${l10n.all} (${state.allCount})'),
          Tab(text: '${l10n.inProgress} (${state.inProgressCount})'),
          Tab(text: '${l10n.completed} (${state.completedCount})'),
          Tab(text: '${l10n.needsAttention} (${state.needAttentionCount})'),
        ],
        onTap: (value) {
          HapticFeedback.lightImpact();
          _tabController.animateTo(value);
          context.read<GradesCubit>().setSelectedTab(value);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GradesState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (state.filteredCourses.isEmpty) {
      return _buildEmptyState(context, isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<GradesCubit>().refreshGrades(),
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: context.responsive.p20),
        itemCount: state.filteredCourses.length,
        itemBuilder: (context, index) {
          final course = state.filteredCourses[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: GradeCard(
                    course: course,
                    isDark: isDark,
                    onTap: () => _showGradeDetails(context, course, isDark),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(responsive.radius20),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF6366F1),
              size: 40,
            ),
          ),
          SizedBox(height: responsive.p16),
          Text(
            l10n.noCoursesFound,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: responsive.p8),
          Text(
            l10n.tryAdjustingFilters,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: responsive.fontSize14,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, GradesState state, bool isDark) {
    // Capture the cubit before showing the bottom sheet
    final cubit = context.read<GradesCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => GradesFilterSheet(
        isDark: isDark,
        currentFilter: state.filter,
        currentSort: state.sortBy,
        sortAscending: state.sortAscending,
        onFilterChanged: (filter) {
          cubit.setFilter(filter);
        },
        onSortChanged: (sort) {
          cubit.setSortBy(sort);
        },
        onReset: () {
          cubit.resetFilters();
        },
      ),
    );
  }

  void _showGradeDetails(
    BuildContext context,
    CourseGrade course,
    bool isDark,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GradeDetailsSheet(course: course, isDark: isDark),
    );
  }
}

void _leaveStudentGradesScreen(BuildContext context) {
  safeBack(context, '/dashboard');
}
