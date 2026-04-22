import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/ai_grading/ta_ai_grading_barrel.dart';

class TAAIGradingScreen extends StatefulWidget {
  const TAAIGradingScreen({super.key});

  @override
  State<TAAIGradingScreen> createState() => _TAAIGradingScreenState();
}

class _TAAIGradingScreenState extends State<TAAIGradingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isEvaluating = false;
  String _searchQuery = '';
  String _selectedCourse = 'CS101';
  String _selectedLab = 'lab3';

  List<TASubmissionItem> _submissions = [];

  final List<Map<String, String>> _courses = [
    {'id': 'CS101', 'name': 'CS101 - Operating System'},
    {'id': 'CS201', 'name': 'CS201 - Data Structures'},
    {'id': 'CS301', 'name': 'CS301 - Algorithms'},
  ];

  final List<Map<String, String>> _labs = [
    {'id': 'lab1', 'name': 'Lab 1 - Introduction'},
    {'id': 'lab2', 'name': 'Lab 2 - Threads'},
    {'id': 'lab3', 'name': 'Lab 3 - Process Synchronization'},
    {'id': 'lab4', 'name': 'Lab 4 - Memory Management'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    _submissions = _getMockSubmissions();
    setState(() => _isLoading = false);
  }

  List<TASubmissionItem> _getMockSubmissions() {
    return [
      TASubmissionItem(
        id: '1',
        studentName: 'Ahmed Hassan',
        studentId: 'CS101-2025-001',
        timeAgo: '2 hours ago',
        wordCount: 245,
        status: TASubmissionStatus.aiEvaluated,
        aiScore: 7.5,
      ),
      TASubmissionItem(
        id: '2',
        studentName: 'Emily Rodriguez',
        studentId: 'CS101-2025-002',
        timeAgo: '4 hours ago',
        wordCount: 189,
        status: TASubmissionStatus.pending,
      ),
      TASubmissionItem(
        id: '3',
        studentName: 'Michael Chen',
        studentId: 'CS101-2025-003',
        timeAgo: '1 day ago',
        wordCount: 156,
        status: TASubmissionStatus.finalized,
        aiScore: 5.5,
        isLate: true,
      ),
      TASubmissionItem(
        id: '4',
        studentName: 'Sara Johnson',
        studentId: 'CS101-2025-004',
        timeAgo: '5 hours ago',
        wordCount: 312,
        status: TASubmissionStatus.pending,
      ),
      TASubmissionItem(
        id: '5',
        studentName: 'James Williams',
        studentId: 'CS101-2025-005',
        timeAgo: '6 hours ago',
        wordCount: 278,
        status: TASubmissionStatus.late,
      ),
    ];
  }

  List<TASubmissionItem> get _filteredSubmissions {
    if (_searchQuery.isEmpty) return _submissions;
    final query = _searchQuery.toLowerCase();
    return _submissions
        .where(
          (s) =>
              s.studentName.toLowerCase().contains(query) ||
              s.studentId.toLowerCase().contains(query),
        )
        .toList();
  }

  int get _pendingCount =>
      _submissions.where((s) => s.status == TASubmissionStatus.pending).length;
  int get _reviewedCount => _submissions
      .where(
        (s) =>
            s.status == TASubmissionStatus.aiEvaluated ||
            s.status == TASubmissionStatus.finalized,
      )
      .length;
  int get _lateCount => _submissions
      .where((s) => s.status == TASubmissionStatus.late || s.isLate)
      .length;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _autoEvaluateAll() async {
    setState(() => _isEvaluating = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      for (var i = 0; i < _submissions.length; i++) {
        if (_submissions[i].status == TASubmissionStatus.pending) {
          _submissions[i] = TASubmissionItem(
            id: _submissions[i].id,
            studentName: _submissions[i].studentName,
            studentId: _submissions[i].studentId,
            timeAgo: _submissions[i].timeAgo,
            wordCount: _submissions[i].wordCount,
            status: TASubmissionStatus.aiEvaluated,
            aiScore: 6.0 + (i * 0.5),
            isLate: _submissions[i].isLate,
          );
        }
      }
      _isEvaluating = false;
    });

    _showSnackBar('All pending submissions evaluated!');
  }

  void _showSubmissionDetail(
    bool isDark,
    AppLocalizations l10n,
    TASubmissionItem submission,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: TAColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        submission.studentName[0],
                        style: TextStyle(
                          color: TAColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            submission.studentName,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            submission.studentId,
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: TAColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDetailSection(
                      isDark,
                      l10n.taGradingSubmissionDetails,
                      [
                        _buildDetailRow(
                          isDark,
                          l10n.taGradingSubmittedAt,
                          submission.timeAgo,
                        ),
                        _buildDetailRow(
                          isDark,
                          l10n.taGradingWordCount,
                          '${submission.wordCount} words',
                        ),
                        _buildDetailRow(
                          isDark,
                          l10n.taGradingStatus,
                          _getStatusLabel(submission.status),
                        ),
                        if (submission.aiScore != null)
                          _buildDetailRow(
                            isDark,
                            l10n.taGradingAIScore,
                            '${submission.aiScore}/10',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(isDark, l10n.taGradingSubmissionContent, [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TAColors.scaffoldColor(isDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                          'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                          'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSnackBar('AI evaluation started');
                          },
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: Text(l10n.taGradingRunAI),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TAColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: TAColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSnackBar('Submission finalized');
                          },
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(l10n.taGradingFinalize),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TAColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(TASubmissionStatus status) {
    switch (status) {
      case TASubmissionStatus.aiEvaluated:
        return 'AI Evaluated';
      case TASubmissionStatus.finalized:
        return 'Finalized';
      case TASubmissionStatus.late:
        return 'Late';
      case TASubmissionStatus.pending:
        return 'Pending';
    }
  }

  Widget _buildDetailSection(bool isDark, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: TADrawer(currentRoute: '/ta/ai-grading', isDark: isDark),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: TAColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark, l10n),
                  SliverToBoxAdapter(
                    child: _buildCourseLabSelector(isDark, l10n),
                  ),
                  SliverToBoxAdapter(
                    child: TAGradingStatsCard(
                      isDark: isDark,
                      total: _submissions.length,
                      pending: _pendingCount,
                      reviewed: _reviewedCount,
                      late: _lateCount,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TABatchEvaluationCard(
                      isDark: isDark,
                      pendingCount: _pendingCount,
                      isLoading: _isEvaluating,
                      onAutoEvaluate: _autoEvaluateAll,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildSearchBar(isDark, l10n)),
                  _buildSubmissionsList(isDark, l10n),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taGradingTitle,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.taGradingSubtitle,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        _buildHeaderButton(
          icon: Icons.search_rounded,
          label: l10n.search,
          isDark: isDark,
          onTap: () => _showSnackBar('Search'),
        ),
        _buildHeaderButton(
          icon: Icons.download_rounded,
          label: l10n.export,
          isDark: isDark,
          onTap: () => _showSnackBar('Exporting grades...'),
        ),
        _buildHeaderButton(
          icon: Icons.auto_awesome,
          label: l10n.taGradingAIInsights,
          isDark: isDark,
          onTap: () => _showSnackBar('AI Insights'),
        ),
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
        ),
      ],
      floating: true,
      pinned: true,
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: TAColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseLabSelector(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taCoursesCourse,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourse,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: TAColors.textSecondaryColor(isDark),
                ),
                dropdownColor: TAColors.cardColor(isDark),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                ),
                items: _courses
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['id'],
                        child: Text(c['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCourse = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.taGradingAssignmentLab,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLab,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: TAColors.textSecondaryColor(isDark),
                ),
                dropdownColor: TAColors.cardColor(isDark),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                ),
                items: _labs
                    .map(
                      (l) => DropdownMenuItem(
                        value: l['id'],
                        child: Text(l['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedLab = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
          ),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: l10n.taGradingSearchStudents,
            hintStyle: TextStyle(
              color: TAColors.textTertiaryColor(isDark),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: TAColors.textTertiaryColor(isDark),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionsList(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: CircularProgressIndicator(color: TAColors.primary),
          ),
        ),
      );
    }

    final submissions = _filteredSubmissions;

    if (submissions.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: TAColors.textTertiaryColor(isDark),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.taGradingNoSubmissions,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final submission = submissions[index];
          return TASubmissionCard(
            submission: submission,
            isDark: isDark,
            onTap: () => _showSubmissionDetail(isDark, l10n, submission),
          );
        }, childCount: submissions.length),
      ),
    );
  }
}
