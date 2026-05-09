import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/exam_generator/exam_generator_cubit.dart';
import '../../../bloc/instructor/exam_generator/exam_generator_state.dart';
import '../../../models/exams/exam_draft_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_response_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import 'exam_generator_info_screen.dart';

class InstructorExamGeneratorScreen extends StatelessWidget {
  const InstructorExamGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamGeneratorCubit(
        examGeneratorService: ExamGeneratorService(
          coreApiClient: CoreApiClient(),
        ),
        enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
      )..initialize(),
      child: const _InstructorExamGeneratorView(),
    );
  }
}

class _InstructorExamGeneratorView extends StatelessWidget {
  const _InstructorExamGeneratorView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(
        title: Text(l10n.examGenerator),
        actions: [
          IconButton(
            tooltip: l10n.examGeneratorInfoTitle,
            onPressed: () => showExamGeneratorInfoSheet(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          BlocBuilder<ExamGeneratorCubit, ExamGeneratorState>(
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading,
            builder: (context, state) {
              return IconButton(
                tooltip: l10n.refresh,
                onPressed: state.isLoading
                    ? null
                    : () => context.read<ExamGeneratorCubit>().refresh(),
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _CreateDraftFab(
        onPressed: () => context.push('/instructor/exam-generator/create'),
      ),
      body: BlocBuilder<ExamGeneratorCubit, ExamGeneratorState>(
        builder: (context, state) {
          if (state.isLoading && state.drafts.isEmpty && state.exams.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: ExamGeneratorSkeletons(itemCount: 5),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ExamGeneratorCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                ExamGeneratorHeroHeader(
                  title: l10n.examGeneratorHeroTitle,
                  subtitle: l10n.examGeneratorHeroSubtitle,
                  isDark: isDark,
                  stats: {
                    l10n.drafts:
                        (state.stats?.openDrafts ?? state.drafts.length)
                            .toString(),
                    l10n.savedExams:
                        (state.stats?.savedExams ?? state.exams.length)
                            .toString(),
                    l10n.examPublished: (state.stats?.publishedExams ?? 0)
                        .toString(),
                    l10n.examApprovedPool:
                        (state.stats?.approvedQuestionPool ?? 0).toString(),
                  },
                ),
                const SizedBox(height: 14),
                _PoolReadinessPanel(state: state),
                const SizedBox(height: 14),
                _FilterPanel(state: state, onPickDate: _pickDate),
                if (state.isRefreshing) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(minHeight: 3),
                  ),
                ],
                const SizedBox(height: 14),
                if (state.errorMessage != null)
                  Center(child: Text(state.errorMessage!))
                else
                  _CombinedExamList(state: state),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool from,
    required ExamGeneratorState state,
  }) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: (from ? state.dateFrom : state.dateTo) ?? DateTime.now(),
    );
    if (picked == null || !context.mounted) return;
    await context.read<ExamGeneratorCubit>().setFilters(
      dateFrom: from ? picked : state.dateFrom,
      dateTo: from ? state.dateTo : picked,
    );
  }
}

class _PoolReadinessPanel extends StatelessWidget {
  const _PoolReadinessPanel({required this.state});

  final ExamGeneratorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final readiness = state.readiness;
    final lowPool = (state.stats?.approvedQuestionPool ?? 1) == 0;
    final approved =
        readiness?.totalApproved ?? state.stats?.approvedQuestionPool ?? 0;
    final grouped = readiness?.grouped ?? 0;
    final standalone = readiness?.standalone ?? 0;
    final chips = <Widget>[
      _TinyStat(
        label: l10n.examApproved,
        value: approved,
        color: InstructorColors.success,
      ),
      _TinyStat(
        label: l10n.examGrouped,
        value: grouped,
        color: InstructorColors.accent,
      ),
      _TinyStat(
        label: l10n.examStandalone,
        value: standalone,
        color: InstructorColors.teal,
      ),
    ];
    final breakdown = <Widget>[
      ...?readiness?.byChapter
          .take(3)
          .map(
            (item) => _BreakdownChip(
              label: item.label,
              value: item.count,
              icon: Icons.menu_book_outlined,
              color: InstructorColors.primary,
            ),
          ),
      ...?readiness?.byType
          .take(3)
          .map(
            (item) => _BreakdownChip(
              label: _prettyBucketLabel(item.label),
              value: item.count,
              icon: Icons.category_outlined,
              color: InstructorColors.orange,
            ),
          ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lowPool
            ? (isDark ? const Color(0xFF3B1F1F) : const Color(0xFFFFF1F2))
            : InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: lowPool
              ? InstructorColors.error.withValues(alpha: isDark ? 0.45 : 0.22)
              : InstructorColors.borderColor(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      (lowPool
                              ? InstructorColors.error
                              : InstructorColors.primary)
                          .withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  lowPool
                      ? Icons.warning_amber_rounded
                      : Icons.inventory_2_outlined,
                  color: lowPool
                      ? InstructorColors.error
                      : InstructorColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.examQuestionPoolReadiness,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lowPool
                          ? l10n.examNoApprovedPoolHelp
                          : l10n.examDashboardHelp,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              if (lowPool)
                TextButton(
                  onPressed: () => context.push('/instructor/question-bank'),
                  child: Text(l10n.questionBank),
                ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map(
                      (chip) =>
                          SizedBox(width: width.clamp(90, 220), child: chip),
                    )
                    .toList(),
              );
            },
          ),
          if (breakdown.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: breakdown),
          ],
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.state, required this.onPickDate});

  final ExamGeneratorState state;
  final Future<void> Function(
    BuildContext context, {
    required bool from,
    required ExamGeneratorState state,
  })
  onPickDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCourse = _selectedCourse(state);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          _ExamSearchField(search: state.search),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = constraints.maxWidth < 430 ? 8.0 : 10.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: _CourseFilterButton(
                      selectedCourse: selectedCourse,
                      courses: state.teachingCourses,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _AdvancedFilterButton(
                      state: state,
                      onPickDate: onPickDate,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CombinedExamList extends StatelessWidget {
  const _CombinedExamList({required this.state});

  final ExamGeneratorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final records = _recordsFor(state);
    if (records.isEmpty) {
      return ExamGeneratorEmptyState(
        title: l10n.examGeneratorNoRecords,
        message: l10n.examGeneratorNoRecordsMessage,
      );
    }
    return Column(
      children: [
        ...records.map(
          (record) => record.draft != null
              ? ExamDraftCard(
                  draft: record.draft!,
                  courseLabel: _courseLabelFor(state, record.draft!.courseId),
                  onTap: () => context.push(_draftRoute(record.draft!)),
                )
              : ExamSavedCard(
                  exam: record.exam!,
                  courseLabel: _courseLabelFor(state, record.exam!.courseId),
                  onTap: () => context.push(
                    '/instructor/exam-generator/exams/${record.exam!.id}',
                  ),
                ),
        ),
        if (_hasMoreVisible(state))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: OutlinedButton(
              onPressed: state.isLoadingMore
                  ? null
                  : () async {
                      final cubit = context.read<ExamGeneratorCubit>();
                      if (_showsDrafts(state) && state.hasMoreDrafts) {
                        await cubit.loadDrafts(page: state.draftPage + 1);
                      }
                      if (_showsSaved(state) && state.hasMoreExams) {
                        await cubit.loadExams(page: state.examPage + 1);
                      }
                    },
              child: Text(state.isLoadingMore ? l10n.loading : l10n.loadMore),
            ),
          ),
      ],
    );
  }
}

class _ExamRecord {
  const _ExamRecord.draft(this.draft) : exam = null;
  const _ExamRecord.exam(this.exam) : draft = null;

  final ExamDraftModel? draft;
  final ExamResponseModel? exam;

  DateTime get sortDate {
    final draftValue = draft;
    if (draftValue != null) {
      return draftValue.updatedAt ??
          draftValue.createdAt ??
          draftValue.expiresAt;
    }
    final examValue = exam;
    return examValue?.updatedAt ??
        examValue?.createdAt ??
        examValue?.publishedAt ??
        examValue?.archivedAt ??
        DateTime.fromMillisecondsSinceEpoch(examValue?.id ?? 0);
  }
}

class _ExamSearchField extends StatefulWidget {
  const _ExamSearchField({required this.search});

  final String search;

  @override
  State<_ExamSearchField> createState() => _ExamSearchFieldState();
}

class _ExamSearchFieldState extends State<_ExamSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.search);
    _controller.addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant _ExamSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.search != _controller.text) {
      _controller.text = widget.search;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onChanged: (value) => context.read<ExamGeneratorCubit>().setFilters(
        search: value,
        refreshRemote: false,
      ),
      decoration: InputDecoration(
        hintText: l10n.examSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: l10n.clear,
                onPressed: () {
                  _controller.clear();
                  context.read<ExamGeneratorCubit>().setFilters(
                    clearSearch: true,
                    refreshRemote: false,
                  );
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: InstructorColors.surfaceColor(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: InstructorColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _CreateDraftFab extends StatelessWidget {
  const _CreateDraftFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      elevation: 12,
      shadowColor: InstructorColors.primary.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 18, 12),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF0F766E)],
                  )
                : const LinearGradient(
                    colors: [InstructorColors.primary, InstructorColors.teal],
                  ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: InstructorColors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.examGeneratorCreateDraft,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseFilterButton extends StatelessWidget {
  const _CourseFilterButton({
    required this.selectedCourse,
    required this.courses,
  });

  final TeachingCourseModel? selectedCourse;
  final List<TeachingCourseModel> courses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedLabel = selectedCourse == null
        ? l10n.allCourses
        : _courseLabel(selectedCourse!);
    return PopupMenuButton<int>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: InstructorColors.cardColor(
        Theme.of(context).brightness == Brightness.dark,
      ),
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 380),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: InstructorColors.borderColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
      onSelected: (value) => context.read<ExamGeneratorCubit>().setFilters(
        courseId: value == -1 ? null : value,
        clearCourse: value == -1,
      ),
      itemBuilder: (context) => [
        _menuItem<int>(
          context: context,
          value: -1,
          label: l10n.allCourses,
          icon: Icons.layers_outlined,
          selected: selectedCourse == null,
          color: InstructorColors.primary,
        ),
        ...courses.map(
          (course) => _menuItem<int>(
            context: context,
            value: course.courseId,
            label: _courseLabel(course),
            icon: Icons.menu_book_outlined,
            selected: selectedCourse?.courseId == course.courseId,
            color: InstructorColors.primary,
          ),
        ),
      ],
      child: _FilterButtonShell(
        icon: Icons.school_outlined,
        color: InstructorColors.primary,
        label: l10n.course,
        value: selectedLabel,
      ),
    );
  }
}

class _AdvancedFilterButton extends StatelessWidget {
  const _AdvancedFilterButton({required this.state, required this.onPickDate});

  final ExamGeneratorState state;
  final Future<void> Function(
    BuildContext context, {
    required bool from,
    required ExamGeneratorState state,
  })
  onPickDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeCount = _activeFilterCount(state);
    return PopupMenuButton<_FilterAction>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: InstructorColors.cardColor(
        Theme.of(context).brightness == Brightness.dark,
      ),
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 390),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: InstructorColors.borderColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
      onSelected: (action) => _handleFilterAction(context, action),
      itemBuilder: (context) => [
        _menuHeader(context, l10n.examRecords),
        _menuItem<_FilterAction>(
          context: context,
          value: const _FilterAction.kind(ExamGeneratorListKind.all),
          label: l10n.examAllRecords,
          icon: Icons.dashboard_customize_outlined,
          selected: state.selectedListKind == ExamGeneratorListKind.all,
          color: InstructorColors.teal,
        ),
        _menuItem<_FilterAction>(
          context: context,
          value: const _FilterAction.kind(ExamGeneratorListKind.drafts),
          label: l10n.examDraftRecords,
          icon: Icons.description_outlined,
          selected: state.selectedListKind == ExamGeneratorListKind.drafts,
          color: InstructorColors.primary,
        ),
        _menuItem<_FilterAction>(
          context: context,
          value: const _FilterAction.kind(ExamGeneratorListKind.saved),
          label: l10n.examSavedRecords,
          icon: Icons.fact_check_outlined,
          selected: state.selectedListKind == ExamGeneratorListKind.saved,
          color: InstructorColors.success,
        ),
        _menuHeader(context, l10n.examDraftStatus),
        _menuItem<_FilterAction>(
          context: context,
          value: const _FilterAction.clearDraft(),
          label: l10n.allStates,
          icon: Icons.select_all_rounded,
          selected: state.selectedDraftStatus == null,
          color: InstructorColors.primary,
        ),
        ...ExamDraftStatus.values.map(
          (status) => _menuItem<_FilterAction>(
            context: context,
            value: _FilterAction.draft(status),
            label: localizedDraftStatus(l10n, status),
            icon: Icons.description_outlined,
            selected: state.selectedDraftStatus == status,
            color: InstructorColors.primary,
          ),
        ),
        _menuHeader(context, l10n.examStatus),
        _menuItem<_FilterAction>(
          context: context,
          value: const _FilterAction.clearExam(),
          label: l10n.allStates,
          icon: Icons.select_all_rounded,
          selected: state.selectedExamStatus == null,
          color: InstructorColors.success,
        ),
        ...ExamStatus.values.map(
          (status) => _menuItem<_FilterAction>(
            context: context,
            value: _FilterAction.exam(status),
            label: _localizedSavedExamStatus(l10n, status),
            icon: Icons.fact_check_outlined,
            selected: state.selectedExamStatus == status,
            color: InstructorColors.success,
          ),
        ),
        _menuHeader(context, l10n.date),
        _menuItem<_FilterAction>(
          context: context,
          value: _FilterAction.dateFrom(onPickDate),
          label: state.dateFrom == null
              ? l10n.examDateFrom
              : '${l10n.examDateFrom}: ${_formatDate(state.dateFrom!)}',
          icon: Icons.date_range_outlined,
          selected: state.dateFrom != null,
          color: InstructorColors.orange,
        ),
        _menuItem<_FilterAction>(
          context: context,
          value: _FilterAction.dateTo(onPickDate),
          label: state.dateTo == null
              ? l10n.examDateTo
              : '${l10n.examDateTo}: ${_formatDate(state.dateTo!)}',
          icon: Icons.event_outlined,
          selected: state.dateTo != null,
          color: InstructorColors.orange,
        ),
        _menuItem<_FilterAction>(
          context: context,
          value: const _FilterAction.clearDates(),
          label: l10n.clear,
          icon: Icons.clear_rounded,
          selected: false,
          color: InstructorColors.error,
        ),
      ],
      child: _FilterButtonShell(
        icon: Icons.tune_rounded,
        color: InstructorColors.teal,
        label: l10n.examFilters,
        value: l10n.examActiveFilterCount(activeCount),
      ),
    );
  }

  Future<void> _handleFilterAction(
    BuildContext context,
    _FilterAction action,
  ) async {
    final cubit = context.read<ExamGeneratorCubit>();
    switch (action.type) {
      case _FilterActionType.draft:
        await cubit.setFilters(
          draftStatus: action.draftStatus,
          listKind: ExamGeneratorListKind.drafts,
          clearExamStatus: true,
        );
      case _FilterActionType.clearDraft:
        await cubit.setFilters(clearDraftStatus: true);
      case _FilterActionType.exam:
        await cubit.setFilters(
          examStatus: action.examStatus,
          listKind: ExamGeneratorListKind.saved,
          clearDraftStatus: true,
        );
      case _FilterActionType.clearExam:
        await cubit.setFilters(clearExamStatus: true);
      case _FilterActionType.kind:
        await cubit.setFilters(
          listKind: action.listKind,
          clearDraftStatus: action.listKind != ExamGeneratorListKind.drafts,
          clearExamStatus: action.listKind != ExamGeneratorListKind.saved,
          refreshRemote: false,
        );
      case _FilterActionType.dateFrom:
        await action.onPickDate?.call(context, from: true, state: state);
      case _FilterActionType.dateTo:
        await action.onPickDate?.call(context, from: false, state: state);
      case _FilterActionType.clearDates:
        await cubit.setFilters(clearDates: true);
    }
  }
}

class _FilterButtonShell extends StatelessWidget {
  const _FilterButtonShell({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 9, 10, 9),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: InstructorColors.textSecondaryColor(isDark),
          ),
        ],
      ),
    );
  }
}

class _TinyStat extends StatelessWidget {
  const _TinyStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  const _BreakdownChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 42, maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
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

enum _FilterActionType {
  draft,
  clearDraft,
  exam,
  clearExam,
  kind,
  dateFrom,
  dateTo,
  clearDates,
}

class _FilterAction {
  const _FilterAction._({
    required this.type,
    this.draftStatus,
    this.examStatus,
    this.listKind,
    this.onPickDate,
  });

  const _FilterAction.draft(ExamDraftStatus status)
    : this._(type: _FilterActionType.draft, draftStatus: status);
  const _FilterAction.clearDraft() : this._(type: _FilterActionType.clearDraft);
  const _FilterAction.exam(ExamStatus status)
    : this._(type: _FilterActionType.exam, examStatus: status);
  const _FilterAction.clearExam() : this._(type: _FilterActionType.clearExam);
  const _FilterAction.kind(ExamGeneratorListKind kind)
    : this._(type: _FilterActionType.kind, listKind: kind);
  const _FilterAction.clearDates() : this._(type: _FilterActionType.clearDates);
  const _FilterAction.dateFrom(this.onPickDate)
    : type = _FilterActionType.dateFrom,
      draftStatus = null,
      examStatus = null,
      listKind = null;
  const _FilterAction.dateTo(this.onPickDate)
    : type = _FilterActionType.dateTo,
      draftStatus = null,
      examStatus = null,
      listKind = null;

  final _FilterActionType type;
  final ExamDraftStatus? draftStatus;
  final ExamStatus? examStatus;
  final ExamGeneratorListKind? listKind;
  final Future<void> Function(
    BuildContext context, {
    required bool from,
    required ExamGeneratorState state,
  })?
  onPickDate;
}

PopupMenuItem<T> _menuItem<T>({
  required BuildContext context,
  required T value,
  required String label,
  required IconData icon,
  required bool selected,
  required Color color,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return PopupMenuItem<T>(
    value: value,
    child: Row(
      children: [
        Icon(
          selected ? Icons.check_circle_rounded : icon,
          color: selected ? color : InstructorColors.textSecondaryColor(isDark),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? color
                  : InstructorColors.textPrimaryColor(isDark),
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

PopupMenuItem<_FilterAction> _menuHeader(BuildContext context, String label) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return PopupMenuItem<_FilterAction>(
    enabled: false,
    height: 34,
    child: Text(
      label,
      style: TextStyle(
        color: InstructorColors.textSecondaryColor(isDark),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

TeachingCourseModel? _selectedCourse(ExamGeneratorState state) {
  return state.teachingCourses
      .where((course) => course.courseId == state.selectedCourseId)
      .firstOrNull;
}

String? _courseLabelFor(ExamGeneratorState state, int courseId) {
  final course = state.teachingCourses
      .where((item) => item.courseId == courseId)
      .firstOrNull;
  return course == null ? null : _courseLabel(course);
}

List<_ExamRecord> _recordsFor(ExamGeneratorState state) {
  final savedExamIds = state.exams.map((exam) => exam.id).toSet();
  final records = <_ExamRecord>[
    if (_showsDrafts(state))
      ...state.drafts
          .where((draft) => _shouldShowDraftRecord(state, draft, savedExamIds))
          .map(_ExamRecord.draft),
    if (_showsSaved(state)) ...state.exams.map(_ExamRecord.exam),
  ];
  records.sort((a, b) => b.sortDate.compareTo(a.sortDate));
  return records;
}

bool _shouldShowDraftRecord(
  ExamGeneratorState state,
  ExamDraftModel draft,
  Set<int> savedExamIds,
) {
  if (draft.status != ExamDraftStatus.finalized) return true;
  if (state.selectedDraftStatus == ExamDraftStatus.finalized) return true;
  final savedExamId = draft.finalizedExamId;
  if (state.selectedListKind == ExamGeneratorListKind.all) {
    return savedExamId == null || !savedExamIds.contains(savedExamId);
  }
  return false;
}

String _draftRoute(ExamDraftModel draft) {
  final finalizedExamId = draft.finalizedExamId;
  if (draft.status == ExamDraftStatus.finalized && finalizedExamId != null) {
    return '/instructor/exam-generator/exams/$finalizedExamId';
  }
  return '/instructor/exam-generator/drafts/${draft.id}';
}

bool _showsDrafts(ExamGeneratorState state) {
  return state.selectedListKind == ExamGeneratorListKind.all ||
      state.selectedListKind == ExamGeneratorListKind.drafts;
}

bool _showsSaved(ExamGeneratorState state) {
  return state.selectedListKind == ExamGeneratorListKind.all ||
      state.selectedListKind == ExamGeneratorListKind.saved;
}

bool _hasMoreVisible(ExamGeneratorState state) {
  return (_showsDrafts(state) && state.hasMoreDrafts) ||
      (_showsSaved(state) && state.hasMoreExams);
}

String _courseLabel(TeachingCourseModel course) {
  final code = course.course.code.trim();
  final name = course.course.name.trim();
  if (code.isEmpty) return name;
  if (name.isEmpty) return code;
  return '$code - $name';
}

int _activeFilterCount(ExamGeneratorState state) {
  var count = 0;
  if (state.selectedListKind != ExamGeneratorListKind.all) count++;
  if (state.selectedDraftStatus != null) count++;
  if (state.selectedExamStatus != null) count++;
  if (state.dateFrom != null) count++;
  if (state.dateTo != null) count++;
  return count;
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _localizedSavedExamStatus(AppLocalizations l10n, ExamStatus status) {
  if (status == ExamStatus.draft) return l10n.examSavedDraftStatus;
  return localizedExamStatus(l10n, status);
}

String _prettyBucketLabel(String value) {
  final normalized = value.replaceAll('_', ' ').trim();
  if (normalized.isEmpty) return value;
  return normalized
      .split(RegExp(r'\s+'))
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
