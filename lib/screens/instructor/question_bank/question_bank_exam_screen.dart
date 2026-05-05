import 'dart:convert';
import 'dart:io';

import 'package:edu_verse/bloc/instructor/question_bank_exam_cubit.dart';
import 'package:edu_verse/bloc/instructor/question_bank_exam_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/instructor/question_bank_exam_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/question_bank_exam_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/instructor/exams/exam_generation_shortage_panel.dart';
import 'package:edu_verse/widgets/instructor/question_bank/question_bank_pagination_controls.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

enum QuestionBankInitialAction {
  none,
  createQuestion,
  editQuestion,
  viewQuestion,
  bulkCreateQuestions,
  viewGroup,
  generateExam,
  reviewDraft,
  viewSavedExam,
}

class QuestionBankExamScreen extends StatelessWidget {
  const QuestionBankExamScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialCourseId,
    this.initialAction = QuestionBankInitialAction.none,
    this.initialQuestionId,
    this.initialGroupId,
    this.initialDraftId,
    this.initialExamId,
    this.service,
    this.enrollmentService,
  });

  final int initialTabIndex;
  final int? initialCourseId;
  final QuestionBankInitialAction initialAction;
  final int? initialQuestionId;
  final int? initialGroupId;
  final int? initialDraftId;
  final int? initialExamId;
  final QuestionBankExamService? service;
  final EnrollmentService? enrollmentService;

  @override
  Widget build(BuildContext context) {
    final coreApiClient = CoreApiClient(storageService: StorageService());
    return BlocProvider<QuestionBankExamCubit>(
      create: (_) => QuestionBankExamCubit(
        service:
            service ?? QuestionBankExamService(coreApiClient: coreApiClient),
        enrollmentService:
            enrollmentService ??
            EnrollmentService(coreApiClient: coreApiClient),
      )..loadInitial(preferredCourseId: initialCourseId),
      child: _QuestionBankExamView(
        initialTabIndex: initialTabIndex,
        initialAction: initialAction,
        initialQuestionId: initialQuestionId,
        initialGroupId: initialGroupId,
        initialDraftId: initialDraftId,
        initialExamId: initialExamId,
      ),
    );
  }
}

class _QuestionBankExamView extends StatefulWidget {
  const _QuestionBankExamView({
    required this.initialTabIndex,
    required this.initialAction,
    this.initialQuestionId,
    this.initialGroupId,
    this.initialDraftId,
    this.initialExamId,
  });

  final int initialTabIndex;
  final QuestionBankInitialAction initialAction;
  final int? initialQuestionId;
  final int? initialGroupId;
  final int? initialDraftId;
  final int? initialExamId;

  @override
  State<_QuestionBankExamView> createState() => _QuestionBankExamViewState();
}

class _QuestionBankExamViewState extends State<_QuestionBankExamView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _handledInitialAction = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        return BlocConsumer<QuestionBankExamCubit, QuestionBankExamState>(
          listener: (context, state) {
            final message = state.errorMessage ?? state.successMessage;
            if (message != null && message.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (!_handledInitialAction &&
                !state.isLoading &&
                widget.initialAction != QuestionBankInitialAction.none) {
              _handledInitialAction = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _handleInitialAction(context);
              });
            }
          },
          builder: (context, state) {
            return Scaffold(
              backgroundColor: InstructorColors.background(isDark),
              appBar: AppBar(
                backgroundColor: InstructorColors.background(isDark),
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: InstructorColors.textPrimaryColor(isDark),
                  ),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  l10n.questionBankTitle,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    tooltip: l10n.refresh,
                    onPressed: () =>
                        context.read<QuestionBankExamCubit>().refreshAll(),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: InstructorColors.textSecondaryColor(isDark),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.read<ThemeBloc>().add(const ToggleThemeEvent()),
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: InstructorColors.textSecondaryColor(isDark),
                    ),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: InstructorColors.primary,
                  unselectedLabelColor: InstructorColors.textSecondaryColor(
                    isDark,
                  ),
                  indicatorColor: InstructorColors.primary,
                  tabs: <Widget>[
                    Tab(text: l10n.questionBankTabQuestions),
                    Tab(text: l10n.questionBankTabGroups),
                    Tab(text: l10n.questionBankTabExams),
                  ],
                ),
              ),
              floatingActionButton: _buildFab(context, l10n),
              body: SafeArea(
                child: state.isLoading && state.teachingCourses.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: InstructorColors.primary,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          _QuestionsTab(isDark: isDark),
                          _GroupsTab(isDark: isDark),
                          _ExamsTab(isDark: isDark),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildFab(BuildContext context, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final index = _tabController.index;
        return FloatingActionButton.extended(
          backgroundColor: InstructorColors.primary,
          foregroundColor: Colors.white,
          icon: Icon(
            index == 2
                ? Icons.auto_awesome_rounded
                : index == 1
                ? Icons.splitscreen_rounded
                : Icons.add_rounded,
          ),
          label: Text(
            index == 2
                ? l10n.questionBankCreateExam
                : index == 1
                ? l10n.questionBankNewGroup
                : l10n.questionBankNewQuestion,
          ),
          onPressed: () {
            if (index == 2) {
              _showGenerateExamSheet(context);
            } else if (index == 1) {
              _showCreateGroupSheet(context);
            } else {
              _showCreateQuestionSheet(context);
            }
          },
        );
      },
    );
  }

  void _handleInitialAction(BuildContext context) {
    switch (widget.initialAction) {
      case QuestionBankInitialAction.none:
        return;
      case QuestionBankInitialAction.createQuestion:
        _tabController.animateTo(0);
        _showCreateQuestionSheet(context);
        return;
      case QuestionBankInitialAction.editQuestion:
        _tabController.animateTo(0);
        final questionId = widget.initialQuestionId;
        if (questionId != null) _showEditQuestionSheet(context, questionId);
        return;
      case QuestionBankInitialAction.viewQuestion:
        _tabController.animateTo(0);
        final questionId = widget.initialQuestionId;
        if (questionId != null) _showQuestionDetailSheet(context, questionId);
        return;
      case QuestionBankInitialAction.bulkCreateQuestions:
        _tabController.animateTo(0);
        _showBulkQuestionCreateSheet(context);
        return;
      case QuestionBankInitialAction.viewGroup:
        _tabController.animateTo(1);
        final groupId = widget.initialGroupId;
        if (groupId != null) _showGroupDetailSheet(context, groupId);
        return;
      case QuestionBankInitialAction.generateExam:
        _tabController.animateTo(2);
        _showGenerateExamSheet(context);
        return;
      case QuestionBankInitialAction.reviewDraft:
        _tabController.animateTo(2);
        final draftId = widget.initialDraftId;
        if (draftId != null) _showDraftEditor(context, draftId);
        return;
      case QuestionBankInitialAction.viewSavedExam:
        _tabController.animateTo(2);
        final examId = widget.initialExamId;
        if (examId != null) _showSavedExamDetailSheet(context, examId);
        return;
    }
  }
}

class _QuestionsTab extends StatelessWidget {
  const _QuestionsTab({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        if (state.teachingCourses.isEmpty) {
          return _EmptyState(
            icon: Icons.school_outlined,
            title: l10n.questionBankNoCourses,
            isDark: isDark,
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              context.read<QuestionBankExamCubit>().loadQuestions(page: 1),
          color: InstructorColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: <Widget>[
              _HeroStats(
                isDark: isDark,
                title: l10n.questionBankTitle,
                subtitle: l10n.questionBankSubtitle,
                stats: <_StatData>[
                  _StatData(
                    l10n.questionBankApproved,
                    state.approvedQuestionCount.toString(),
                  ),
                  _StatData(
                    l10n.questionBankDrafts,
                    state.draftQuestionCount.toString(),
                  ),
                  _StatData(
                    l10n.questionBankAttachments,
                    state.questionItems
                        .where((item) => item.attachments.isNotEmpty)
                        .length
                        .toString(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CourseSelector(isDark: isDark),
              const SizedBox(height: 12),
              _QuestionFilters(isDark: isDark),
              const SizedBox(height: 12),
              if (state.questionItems.isEmpty)
                _EmptyState(
                  icon: Icons.quiz_outlined,
                  title: l10n.questionBankNoQuestions,
                  isDark: isDark,
                )
              else
                ...state.questionItems.map(
                  (question) =>
                      _QuestionCard(question: question, isDark: isDark),
                ),
              if (state.questions != null)
                QuestionBankPaginationControls(
                  isDark: isDark,
                  page: state.questions!.page,
                  totalPages: state.questions!.totalPages,
                  onPrevious: () => context
                      .read<QuestionBankExamCubit>()
                      .loadQuestions(page: state.questions!.page - 1),
                  onNext: () => context
                      .read<QuestionBankExamCubit>()
                      .loadQuestions(page: state.questions!.page + 1),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () =>
              context.read<QuestionBankExamCubit>().loadGroups(page: 1),
          color: InstructorColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: <Widget>[
              _HeroStats(
                isDark: isDark,
                title: l10n.questionBankGroups,
                subtitle: l10n.questionBankSharedPrompt,
                stats: <_StatData>[
                  _StatData(
                    l10n.questionBankGroups,
                    state.groupItems.length.toString(),
                  ),
                  _StatData(
                    l10n.questionBankCourse,
                    state.selectedCourseId?.toString() ?? '-',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CourseSelector(isDark: isDark),
              const SizedBox(height: 12),
              if (state.groupItems.isEmpty)
                _EmptyState(
                  icon: Icons.splitscreen_outlined,
                  title: l10n.questionBankNoGroups,
                  isDark: isDark,
                )
              else
                ...state.groupItems.map(
                  (group) => _GroupCard(group: group, isDark: isDark),
                ),
              if (state.groups != null)
                QuestionBankPaginationControls(
                  isDark: isDark,
                  page: state.groups!.page,
                  totalPages: state.groups!.totalPages,
                  onPrevious: () => context
                      .read<QuestionBankExamCubit>()
                      .loadGroups(page: state.groups!.page - 1),
                  onNext: () => context
                      .read<QuestionBankExamCubit>()
                      .loadGroups(page: state.groups!.page + 1),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ExamsTab extends StatefulWidget {
  const _ExamsTab({required this.isDark});

  final bool isDark;

  @override
  State<_ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<_ExamsTab> {
  bool _showDrafts = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final isDark = widget.isDark;
        final items = _showDrafts ? state.draftItems : state.examItems;
        return RefreshIndicator(
          onRefresh: () => _showDrafts
              ? context.read<QuestionBankExamCubit>().loadDrafts(page: 1)
              : context.read<QuestionBankExamCubit>().loadExams(page: 1),
          color: InstructorColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: <Widget>[
              _HeroStats(
                isDark: isDark,
                title: l10n.questionBankExamHub,
                subtitle: l10n.questionBankOnlyCompactSavedExam,
                stats: <_StatData>[
                  _StatData(
                    l10n.questionBankSavedExams,
                    state.examItems.length.toString(),
                  ),
                  _StatData(
                    l10n.questionBankExamDrafts,
                    state.draftItems.length.toString(),
                  ),
                  _StatData(
                    l10n.questionBankDrafts,
                    state.openDraftCount.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CourseSelector(isDark: isDark),
              const SizedBox(height: 12),
              _SegmentedToggle(
                isDark: isDark,
                left: l10n.questionBankSavedExams,
                right: l10n.questionBankExamDrafts,
                rightSelected: _showDrafts,
                onChanged: (value) => setState(() => _showDrafts = value),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                _EmptyState(
                  icon: Icons.assignment_outlined,
                  title: _showDrafts
                      ? l10n.questionBankNoDrafts
                      : l10n.questionBankNoExams,
                  isDark: isDark,
                )
              else if (_showDrafts)
                ...state.draftItems.map(
                  (draft) => _DraftCard(draft: draft, isDark: isDark),
                )
              else
                ...state.examItems.map(
                  (exam) => _ExamCard(exam: exam, isDark: isDark),
                ),
              if (_showDrafts && state.drafts != null)
                QuestionBankPaginationControls(
                  isDark: isDark,
                  page: state.drafts!.page,
                  totalPages: state.drafts!.totalPages,
                  onPrevious: () => context
                      .read<QuestionBankExamCubit>()
                      .loadDrafts(page: state.drafts!.page - 1),
                  onNext: () => context
                      .read<QuestionBankExamCubit>()
                      .loadDrafts(page: state.drafts!.page + 1),
                ),
              if (!_showDrafts && state.exams != null)
                QuestionBankPaginationControls(
                  isDark: isDark,
                  page: state.exams!.page,
                  totalPages: state.exams!.totalPages,
                  onPrevious: () => context
                      .read<QuestionBankExamCubit>()
                      .loadExams(page: state.exams!.page - 1),
                  onNext: () => context.read<QuestionBankExamCubit>().loadExams(
                    page: state.exams!.page + 1,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.stats,
  });

  final bool isDark;
  final String title;
  final String subtitle;
  final List<_StatData> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? InstructorColors.darkHeaderGradient
            : const LinearGradient(
                colors: <Color>[
                  Color(0xFF155CFB),
                  Color(0xFF3B82F6),
                  Color(0xFF14B8A6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 420;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stats
                    .map(
                      (stat) => SizedBox(
                        width: narrow
                            ? (constraints.maxWidth - 8) / 2
                            : (constraints.maxWidth - 16) / 3,
                        child: _StatPill(stat: stat),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.stat});

  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData(this.label, this.value);

  final String label;
  final String value;
}

class _CourseSelector extends StatelessWidget {
  const _CourseSelector({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final courses = _uniqueCourses(state.teachingCourses);
        return _Panel(
          isDark: isDark,
          child: DropdownButtonFormField<int>(
            initialValue: state.selectedCourseId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.questionBankCourse,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.school_outlined),
            ),
            items: courses
                .map(
                  (course) => DropdownMenuItem<int>(
                    value: course.courseId,
                    child: Text(
                      '${course.course.code} - ${course.course.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                context.read<QuestionBankExamCubit>().selectCourse(value),
          ),
        );
      },
    );
  }
}

class _QuestionFilters extends StatefulWidget {
  const _QuestionFilters({required this.isDark});

  final bool isDark;

  @override
  State<_QuestionFilters> createState() => _QuestionFiltersState();
}

class _QuestionFiltersState extends State<_QuestionFilters> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
        }
        return _Panel(
          isDark: widget.isDark,
          child: Column(
            children: <Widget>[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.questionBankSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => context
                    .read<QuestionBankExamCubit>()
                    .setQuestionFilters(search: value),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _FilterChip(
                      label: l10n.questionBankApproved,
                      selected:
                          state.questionStatusFilter ==
                          QuestionBankStatus.approved,
                      onTap: () => context
                          .read<QuestionBankExamCubit>()
                          .setQuestionFilters(
                            status: QuestionBankStatus.approved,
                            clearStatus:
                                state.questionStatusFilter ==
                                QuestionBankStatus.approved,
                          ),
                    ),
                    _FilterChip(
                      label: l10n.questionBankDrafts,
                      selected:
                          state.questionStatusFilter ==
                          QuestionBankStatus.draft,
                      onTap: () => context
                          .read<QuestionBankExamCubit>()
                          .setQuestionFilters(
                            status: QuestionBankStatus.draft,
                            clearStatus:
                                state.questionStatusFilter ==
                                QuestionBankStatus.draft,
                          ),
                    ),
                    _FilterChip(
                      label: l10n.questionBankWithAttachments,
                      selected: state.hasAttachmentsFilter == true,
                      onTap: () => context
                          .read<QuestionBankExamCubit>()
                          .setQuestionFilters(
                            hasAttachments: true,
                            clearHasAttachments:
                                state.hasAttachmentsFilter == true,
                          ),
                    ),
                    _FilterChip(
                      label: l10n.questionBankWithoutAttachments,
                      selected: state.hasAttachmentsFilter == false,
                      onTap: () => context
                          .read<QuestionBankExamCubit>()
                          .setQuestionFilters(
                            hasAttachments: false,
                            clearHasAttachments:
                                state.hasAttachmentsFilter == false,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.isDark});

  final QuestionBankQuestionModel question;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showQuestionDetailSheet(context, question.id),
      child: _Panel(
        isDark: isDark,
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _IconBadge(
                  icon: _questionIcon(question.questionType),
                  color: _statusColor(question.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        question.displayText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          _MetaChip(
                            label: _questionTypeLabel(
                              l10n,
                              question.questionType,
                            ),
                          ),
                          _MetaChip(
                            label: _difficultyLabel(l10n, question.difficulty),
                          ),
                          _MetaChip(
                            label: _bloomLabel(l10n, question.bloomLevel),
                          ),
                          _MetaChip(
                            label: _questionStatusLabel(l10n, question.status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => context
                      .read<QuestionBankExamCubit>()
                      .questionAction(question, action),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'submit',
                      child: Text(l10n.questionBankSubmitForReview),
                    ),
                    PopupMenuItem<String>(
                      value: 'approve',
                      child: Text(l10n.questionBankApprove),
                    ),
                    PopupMenuItem<String>(
                      value: 'reject',
                      child: Text(l10n.questionBankReject),
                    ),
                    PopupMenuItem<String>(
                      value: 'archive',
                      child: Text(l10n.questionBankArchive),
                    ),
                    PopupMenuItem<String>(
                      value: 'restore',
                      child: Text(l10n.questionBankRestore),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.isDark});

  final QuestionBankGroupModel group;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showGroupDetailSheet(context, group.id),
      child: _Panel(
        isDark: isDark,
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            const _IconBadge(
              icon: Icons.splitscreen_rounded,
              color: InstructorColors.teal,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _groupTitle(l10n, group),
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.sharedPrompt ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _MetaChip(label: group.itemCount.toString()),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.isDark});

  final ExamResponseModel exam;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showSavedExamDetailSheet(context, exam.id),
      child: _Panel(
        isDark: isDark,
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const _IconBadge(
                  icon: Icons.assignment_turned_in_outlined,
                  color: InstructorColors.accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exam.title,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                _MetaChip(label: _examStatusLabel(l10n, exam.status)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _MetaChip(
                  label:
                      '${l10n.questionBankTotalMarks}: ${exam.totalMarks ?? '-'}',
                ),
                _MetaChip(
                  label:
                      '${l10n.questionBankQuestionCount}: ${exam.itemCount ?? '-'}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: <Widget>[
                _SmallButton(
                  icon: Icons.publish_rounded,
                  label: l10n.questionBankPublish,
                  onTap: () => context
                      .read<QuestionBankExamCubit>()
                      .examLifecycle(exam, 'publish'),
                ),
                _SmallButton(
                  icon: Icons.visibility_off_outlined,
                  label: l10n.questionBankUnpublish,
                  onTap: () => context
                      .read<QuestionBankExamCubit>()
                      .examLifecycle(exam, 'unpublish'),
                ),
                _SmallButton(
                  icon: Icons.download_rounded,
                  label: l10n.questionBankExportWord,
                  onTap: () => _showExportDialog(context, exam),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.draft, required this.isDark});

  final ExamDraftModel draft;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDraftEditor(context, draft.id),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            children: <Widget>[
              const _IconBadge(
                icon: Icons.edit_note_rounded,
                color: InstructorColors.warning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      draft.title,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.questionBankQuestionCount}: ${draft.itemCount}  •  ${_draftStatusLabel(l10n, draft.status)}',
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: InstructorColors.textTertiaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.isDark, required this.child, this.margin});

  final bool isDark;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 48,
            color: InstructorColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => onTap(),
        selectedColor: InstructorColors.primarySurface,
        labelStyle: TextStyle(
          color: selected ? InstructorColors.primary : null,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: InstructorColors.primarySurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: InstructorColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.isDark,
    required this.left,
    required this.right,
    required this.rightSelected,
    required this.onChanged,
  });

  final bool isDark;
  final String left;
  final String right;
  final bool rightSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      isDark: isDark,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SegmentButton(
              label: left,
              selected: !rightSelected,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SegmentButton(
              label: right,
              selected: rightSelected,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? InstructorColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : InstructorColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

void _showBulkQuestionCreateSheet(BuildContext context) {
  final cubit = context.read<QuestionBankExamCubit>();
  if (cubit.state.selectedCourseId == null) return;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _BulkQuestionCreateSheet(),
    ),
  );
}

class _BulkQuestionCreateSheet extends StatefulWidget {
  const _BulkQuestionCreateSheet();

  @override
  State<_BulkQuestionCreateSheet> createState() =>
      _BulkQuestionCreateSheetState();
}

class _BulkQuestionCreateSheetState extends State<_BulkQuestionCreateSheet> {
  final _questionsController = TextEditingController();
  int? _chapterId;
  QuestionBankDifficulty _difficulty = QuestionBankDifficulty.medium;
  QuestionBankBloomLevel _bloom = QuestionBankBloomLevel.understand;

  @override
  void dispose() {
    _questionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        _chapterId ??= state.chapters.isNotEmpty
            ? state.chapters.first.id
            : null;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _SheetHeader(
                title: l10n.questionBankBulkCreateTitle,
                onClose: () => Navigator.of(context).pop(),
              ),
              Text(
                l10n.questionBankBulkCreateInstructions,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _chapterId,
                decoration: InputDecoration(
                  labelText: l10n.questionBankChapter,
                ),
                items: state.chapters
                    .map(
                      (chapter) => DropdownMenuItem<int>(
                        value: chapter.id,
                        child: Text(chapter.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _chapterId = value),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final chapter = await _showCreateChapterDialog(context);
                    if (chapter != null && mounted) {
                      setState(() => _chapterId = chapter.id);
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.questionBankCreateChapter),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankDifficulty>(
                      initialValue: _difficulty,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankDifficulty,
                      ),
                      items: QuestionBankDifficulty.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankDifficulty>(
                              value: item,
                              child: Text(_difficultyLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        if (value != null) _difficulty = value;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankBloomLevel>(
                      initialValue: _bloom,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankBloom,
                      ),
                      items: QuestionBankBloomLevel.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankBloomLevel>(
                              value: item,
                              child: Text(_bloomLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        if (value != null) _bloom = value;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _questionsController,
                minLines: 8,
                maxLines: 14,
                decoration: InputDecoration(
                  labelText: l10n.questionBankBulkRows,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isMutating ? null : () => _save(context),
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: Text(l10n.questionBankCreateBulkQuestions),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<QuestionBankExamCubit>();
    final courseId = cubit.state.selectedCourseId;
    final chapterId = _chapterId;
    final rows = _questionsController.text
        .split(RegExp(r'\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (courseId == null || chapterId == null || rows.isEmpty) return;
    final payloads = rows
        .map((row) {
          final parts = row.split('||');
          final questionText = parts.first.trim();
          final answerText = parts.length > 1
              ? parts.sublist(1).join('||')
              : '';
          return QuestionBankExamService.buildQuestionPayload(
            courseId: courseId,
            chapterId: chapterId,
            questionType: QuestionBankQuestionType.written,
            difficulty: _difficulty,
            bloomLevel: _bloom,
            questionText: questionText,
            expectedAnswerText: answerText.trim(),
          );
        })
        .toList(growable: false);
    final saved = await cubit.createQuestionsBatch(
      defaultChapterId: chapterId,
      questions: payloads,
    );
    if (saved && context.mounted) Navigator.of(context).pop();
  }
}

void _showQuestionDetailSheet(BuildContext context, int questionId) {
  final cubit = context.read<QuestionBankExamCubit>();
  cubit.loadQuestion(questionId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _QuestionDetailSheet(questionId: questionId),
    ),
  );
}

class _QuestionDetailSheet extends StatelessWidget {
  const _QuestionDetailSheet({required this.questionId});

  final int questionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final question = state.selectedQuestion;
        if (question == null || question.id != questionId) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              _SheetHeader(
                title: l10n.questionBankQuestionDetails,
                onClose: () => Navigator.of(context).pop(),
              ),
              Text(
                question.displayText,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _MetaChip(
                    label: _questionTypeLabel(l10n, question.questionType),
                  ),
                  _MetaChip(label: _difficultyLabel(l10n, question.difficulty)),
                  _MetaChip(label: _bloomLabel(l10n, question.bloomLevel)),
                  _MetaChip(label: _questionStatusLabel(l10n, question.status)),
                ],
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: l10n.questionBankChapter,
                value: '#${question.chapterId}',
              ),
              if ((question.expectedAnswerText ?? '').isNotEmpty)
                _DetailRow(
                  label: l10n.questionBankExpectedAnswer,
                  value: question.expectedAnswerText!,
                ),
              if ((question.hints ?? '').isNotEmpty)
                _DetailRow(
                  label: l10n.questionBankHint,
                  value: question.hints!,
                ),
              if ((question.explanation ?? '').isNotEmpty)
                _DetailRow(
                  label: l10n.questionBankExplanation,
                  value: question.explanation!,
                ),
              if (question.options.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  l10n.questionBankOptions,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                for (final option in question.options)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      option.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: option.isCorrect
                          ? InstructorColors.success
                          : InstructorColors.textSecondary,
                    ),
                    title: Text(option.optionText),
                  ),
              ],
              if (question.fillBlanks.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  l10n.questionBankFillBlanks,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                for (final blank in question.fillBlanks)
                  _DetailRow(
                    label: blank.blankKey,
                    value: blank.acceptableAnswer,
                  ),
              ],
              if (question.attachments.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  l10n.questionBankAttachments,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                for (final attachment in [
                  ...question.attachments,
                ]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attachment_rounded),
                    title: Text(
                      attachment.caption ??
                          attachment.attachmentType ??
                          '#${attachment.id}',
                    ),
                    subtitle: Text(
                      attachment.altText ?? attachment.imageUrl ?? '-',
                    ),
                    trailing: PopupMenuButton<String>(
                      enabled: !state.isMutating,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditAttachmentDialog(
                            context,
                            question.id,
                            attachment,
                          );
                        } else if (value == 'up') {
                          _moveQuestionAttachment(
                            context,
                            question,
                            attachment,
                            -1,
                          );
                        } else if (value == 'down') {
                          _moveQuestionAttachment(
                            context,
                            question,
                            attachment,
                            1,
                          );
                        } else if (value == 'delete') {
                          context
                              .read<QuestionBankExamCubit>()
                              .deleteQuestionAttachment(
                                questionId: question.id,
                                attachmentId: attachment.id,
                              );
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(l10n.questionBankEditAttachment),
                        ),
                        PopupMenuItem<String>(
                          value: 'up',
                          child: Text(l10n.questionBankMoveUp),
                        ),
                        PopupMenuItem<String>(
                          value: 'down',
                          child: Text(l10n.questionBankMoveDown),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: state.isMutating
                    ? null
                    : () => _pickAndUploadAttachmentImage(context, question.id),
                icon: const Icon(Icons.image_outlined),
                label: Text(l10n.questionBankUploadAttachmentImage),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showEditQuestionSheet(context, question.id);
                },
                icon: const Icon(Icons.edit_rounded),
                label: Text(l10n.questionBankEditQuestion),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showEditQuestionSheet(BuildContext context, int questionId) {
  final cubit = context.read<QuestionBankExamCubit>();
  cubit.loadQuestion(questionId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _EditQuestionSheet(questionId: questionId),
    ),
  );
}

Future<void> _pickAndUploadAttachmentImage(
  BuildContext context,
  int questionId,
) async {
  final picked = await FilePicker.platform.pickFiles(type: FileType.image);
  final path = picked?.files.single.path;
  if (path == null || !context.mounted) return;
  await context.read<QuestionBankExamCubit>().uploadQuestionAttachmentImage(
    questionId: questionId,
    image: File(path),
  );
}

void _moveQuestionAttachment(
  BuildContext context,
  QuestionBankQuestionModel question,
  QuestionBankAttachmentModel attachment,
  int delta,
) {
  final attachments = [...question.attachments]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final index = attachments.indexWhere((item) => item.id == attachment.id);
  final targetIndex = index + delta;
  if (index < 0 || targetIndex < 0 || targetIndex >= attachments.length) {
    return;
  }
  final moving = attachments.removeAt(index);
  attachments.insert(targetIndex, moving);
  context.read<QuestionBankExamCubit>().reorderQuestionAttachments(
    questionId: question.id,
    attachmentIds: attachments.map((item) => item.id).toList(),
  );
}

void _showEditAttachmentDialog(
  BuildContext context,
  int questionId,
  QuestionBankAttachmentModel attachment,
) {
  final captionController = TextEditingController(text: attachment.caption);
  final altTextController = TextEditingController(text: attachment.altText);
  var isPrimary = attachment.isPrimary;
  showDialog<void>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(AppLocalizations.of(context).questionBankEditAttachment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: captionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                ).questionBankAttachmentCaption,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: altTextController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                ).questionBankAttachmentAltText,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isPrimary,
              title: Text(
                AppLocalizations.of(context).questionBankPrimaryAttachment,
              ),
              onChanged: (value) => setDialogState(() => isPrimary = value),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final saved = await context
                  .read<QuestionBankExamCubit>()
                  .updateQuestionAttachment(
                    questionId: questionId,
                    attachmentId: attachment.id,
                    caption: captionController.text,
                    altText: altTextController.text,
                    isPrimary: isPrimary,
                  );
              if (saved && context.mounted) Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    ),
  );
}

class _EditQuestionSheet extends StatefulWidget {
  const _EditQuestionSheet({required this.questionId});

  final int questionId;

  @override
  State<_EditQuestionSheet> createState() => _EditQuestionSheetState();
}

class _EditQuestionSheetState extends State<_EditQuestionSheet> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _hintController = TextEditingController();
  final _explanationController = TextEditingController();
  int? _chapterId;
  QuestionBankDifficulty? _difficulty;
  QuestionBankBloomLevel? _bloom;
  int? _questionFileId;
  String? _questionImageName;
  bool _clearQuestionImage = false;
  bool _initialized = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final question = state.selectedQuestion;
        if (question == null || question.id != widget.questionId) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        _initialize(question);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _SheetHeader(
                title: l10n.questionBankEditQuestion,
                onClose: () => Navigator.of(context).pop(),
              ),
              DropdownButtonFormField<int>(
                initialValue: _chapterId,
                decoration: InputDecoration(
                  labelText: l10n.questionBankChapter,
                ),
                items: state.chapters
                    .map(
                      (chapter) => DropdownMenuItem<int>(
                        value: chapter.id,
                        child: Text(chapter.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _chapterId = value),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final chapter = await _showCreateChapterDialog(context);
                    if (chapter != null && mounted) {
                      setState(() => _chapterId = chapter.id);
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.questionBankCreateChapter),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankDifficulty>(
                      initialValue: _difficulty,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankDifficulty,
                      ),
                      items: QuestionBankDifficulty.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankDifficulty>(
                              value: item,
                              child: Text(_difficultyLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _difficulty = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankBloomLevel>(
                      initialValue: _bloom,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankBloom,
                      ),
                      items: QuestionBankBloomLevel.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankBloomLevel>(
                              value: item,
                              child: Text(_bloomLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _bloom = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _questionController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.questionBankQuestionText,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: state.isMutating ? null : _pickPromptImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      _questionImageName ?? l10n.questionBankUploadPromptImage,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.isMutating
                        ? null
                        : () => setState(() {
                            _questionFileId = null;
                            _questionImageName = null;
                            _clearQuestionImage = true;
                          }),
                    icon: const Icon(Icons.hide_image_outlined),
                    label: Text(l10n.questionBankClearPromptImage),
                  ),
                ],
              ),
              if (_questionFileId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.questionBankPromptImageReady,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: InstructorColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _answerController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.questionBankExpectedAnswer,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hintController,
                decoration: InputDecoration(labelText: l10n.questionBankHint),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _explanationController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.questionBankExplanation,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isMutating
                    ? null
                    : () => _save(context, question),
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  void _initialize(QuestionBankQuestionModel question) {
    if (_initialized) return;
    _initialized = true;
    _chapterId = question.chapterId;
    _difficulty = question.difficulty;
    _bloom = question.bloomLevel;
    _questionController.text = question.questionText ?? '';
    _answerController.text = question.expectedAnswerText ?? '';
    _hintController.text = question.hints ?? '';
    _explanationController.text = question.explanation ?? '';
  }

  Future<void> _save(
    BuildContext context,
    QuestionBankQuestionModel question,
  ) async {
    final payload = QuestionBankExamService.buildQuestionUpdatePayload(
      chapterId: _chapterId,
      questionType: question.questionType,
      difficulty: _difficulty,
      bloomLevel: _bloom,
      questionText: _questionController.text,
      expectedAnswerText: _answerController.text,
      hints: _hintController.text,
      explanation: _explanationController.text,
    );
    if (_clearQuestionImage) {
      payload['questionFileId'] = null;
    } else if (_questionFileId != null) {
      payload['questionFileId'] = _questionFileId;
    }
    final saved = await context.read<QuestionBankExamCubit>().updateQuestion(
      question.id,
      payload,
    );
    if (saved && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _pickPromptImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final file = picked?.files.single;
    final path = file?.path;
    if (path == null || !mounted) return;
    final fileId = await context
        .read<QuestionBankExamCubit>()
        .uploadQuestionImage(File(path));
    if (fileId == null || !mounted) return;
    setState(() {
      _questionFileId = fileId;
      _questionImageName =
          file?.name ??
          AppLocalizations.of(context).questionBankPromptImageReady;
      _clearQuestionImage = false;
    });
  }
}

void _showGroupDetailSheet(BuildContext context, int groupId) {
  final cubit = context.read<QuestionBankExamCubit>();
  cubit.loadGroup(groupId);
  cubit.loadGroupQuestions(groupId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _GroupDetailSheet(groupId: groupId),
    ),
  );
}

class _GroupDetailSheet extends StatelessWidget {
  const _GroupDetailSheet({required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final group = state.selectedGroup;
        if (group == null || group.id != groupId) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _SheetHeader(
                title: l10n.questionBankGroupDetails,
                onClose: () => Navigator.of(context).pop(),
              ),
              Text(
                _groupTitle(l10n, group),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: l10n.questionBankChapter,
                value: '#${group.chapterId}',
              ),
              _DetailRow(
                label: l10n.questionBankQuestionCount,
                value: group.itemCount.toString(),
              ),
              if ((group.sharedPrompt ?? '').isNotEmpty)
                _DetailRow(
                  label: l10n.questionBankSharedPrompt,
                  value: group.sharedPrompt!,
                ),
              const SizedBox(height: 16),
              Text(
                l10n.questionBankGroupedQuestions,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (state.selectedGroupQuestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.questionBankNoGroupedQuestions),
                ),
              for (final question in state.selectedGroupQuestions)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text('${(question.groupItemOrder ?? 0) + 1}'),
                  ),
                  title: Text(
                    question.displayText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _questionTypeLabel(l10n, question.questionType),
                  ),
                  trailing: Wrap(
                    spacing: 0,
                    children: <Widget>[
                      IconButton(
                        tooltip: l10n.questionBankMoveUp,
                        onPressed: state.isMutating
                            ? null
                            : () => _moveGroupedQuestion(
                                context,
                                group.id,
                                state.selectedGroupQuestions,
                                question,
                                -1,
                              ),
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                      IconButton(
                        tooltip: l10n.questionBankMoveDown,
                        onPressed: state.isMutating
                            ? null
                            : () => _moveGroupedQuestion(
                                context,
                                group.id,
                                state.selectedGroupQuestions,
                                question,
                                1,
                              ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ],
                  ),
                  onTap: () => _showQuestionDetailSheet(context, question.id),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: state.isMutating
                    ? null
                    : () => _showEditGroupSheet(context, group),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.edit),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: state.isMutating
                    ? null
                    : () => _showGroupedBatchCreateSheet(context, group),
                icon: const Icon(Icons.playlist_add_rounded),
                label: Text(l10n.questionBankAddGroupedQuestions),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: state.isMutating
                    ? null
                    : () async {
                        final deleted = await context
                            .read<QuestionBankExamCubit>()
                            .deleteGroup(group.id);
                        if (deleted && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _moveGroupedQuestion(
  BuildContext context,
  int groupId,
  List<QuestionBankQuestionModel> questions,
  QuestionBankQuestionModel question,
  int delta,
) {
  final ordered = [...questions]
    ..sort(
      (a, b) => (a.groupItemOrder ?? a.id).compareTo(b.groupItemOrder ?? b.id),
    );
  final index = ordered.indexWhere((item) => item.id == question.id);
  final targetIndex = index + delta;
  if (index < 0 || targetIndex < 0 || targetIndex >= ordered.length) return;
  final moving = ordered.removeAt(index);
  ordered.insert(targetIndex, moving);
  context.read<QuestionBankExamCubit>().reorderGroupQuestions(
    groupId: groupId,
    questionIds: ordered.map((item) => item.id).toList(),
  );
}

void _showEditGroupSheet(BuildContext context, QuestionBankGroupModel group) {
  final cubit = context.read<QuestionBankExamCubit>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _EditGroupSheet(group: group),
    ),
  );
}

class _EditGroupSheet extends StatefulWidget {
  const _EditGroupSheet({required this.group});

  final QuestionBankGroupModel group;

  @override
  State<_EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends State<_EditGroupSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _promptController;
  int? _sharedFileId;
  String? _sharedFileName;
  bool _clearSharedFile = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.group.title ?? '');
    _promptController = TextEditingController(
      text: widget.group.sharedPrompt ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _SheetHeader(
                title: l10n.questionBankGroupDetails,
                onClose: () => Navigator.of(context).pop(),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.questionBankGroupTitle,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.questionBankSharedPrompt,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: state.isMutating ? null : _pickSharedFile,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      _sharedFileName ?? l10n.questionBankUploadSharedFile,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.isMutating
                        ? null
                        : () => setState(() {
                            _sharedFileId = null;
                            _sharedFileName = null;
                            _clearSharedFile = true;
                          }),
                    icon: const Icon(Icons.hide_image_outlined),
                    label: Text(l10n.questionBankClearSharedFile),
                  ),
                ],
              ),
              if (_sharedFileId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.questionBankSharedFileReady,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: InstructorColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isMutating ? null : () => _save(context),
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickSharedFile() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final file = picked?.files.single;
    final path = file?.path;
    if (path == null || !mounted) return;
    final fileId = await context
        .read<QuestionBankExamCubit>()
        .uploadQuestionImage(File(path));
    if (fileId == null || !mounted) return;
    setState(() {
      _sharedFileId = fileId;
      _sharedFileName =
          file?.name ??
          AppLocalizations.of(context).questionBankSharedFileReady;
      _clearSharedFile = false;
    });
  }

  Future<void> _save(BuildContext context) async {
    final data = <String, dynamic>{
      'title': _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      'sharedPrompt': _promptController.text.trim().isEmpty
          ? null
          : _promptController.text.trim(),
    };
    if (_clearSharedFile) {
      data['sharedFileId'] = null;
    } else if (_sharedFileId != null) {
      data['sharedFileId'] = _sharedFileId;
    }
    final saved = await context.read<QuestionBankExamCubit>().updateGroup(
      widget.group.id,
      data,
    );
    if (saved && context.mounted) Navigator.of(context).pop();
  }
}

void _showGroupedBatchCreateSheet(
  BuildContext context,
  QuestionBankGroupModel group,
) {
  final cubit = context.read<QuestionBankExamCubit>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _GroupedBatchCreateSheet(group: group),
    ),
  );
}

class _GroupedBatchCreateSheet extends StatefulWidget {
  const _GroupedBatchCreateSheet({required this.group});

  final QuestionBankGroupModel group;

  @override
  State<_GroupedBatchCreateSheet> createState() =>
      _GroupedBatchCreateSheetState();
}

class _GroupedBatchCreateSheetState extends State<_GroupedBatchCreateSheet> {
  final _questionsController = TextEditingController();
  QuestionBankDifficulty _difficulty = QuestionBankDifficulty.medium;
  QuestionBankBloomLevel _bloom = QuestionBankBloomLevel.understand;

  @override
  void dispose() {
    _questionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _SheetHeader(
                title: l10n.questionBankAddGroupedQuestions,
                onClose: () => Navigator.of(context).pop(),
              ),
              Text(
                l10n.questionBankBulkCreateInstructions,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankDifficulty>(
                      initialValue: _difficulty,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankDifficulty,
                      ),
                      items: QuestionBankDifficulty.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankDifficulty>(
                              value: item,
                              child: Text(_difficultyLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        if (value != null) _difficulty = value;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankBloomLevel>(
                      initialValue: _bloom,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankBloom,
                      ),
                      items: QuestionBankBloomLevel.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankBloomLevel>(
                              value: item,
                              child: Text(_bloomLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        if (value != null) _bloom = value;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _questionsController,
                minLines: 6,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: l10n.questionBankBulkRows,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isMutating ? null : () => _save(context),
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.questionBankCreateBulkQuestions),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(BuildContext context) async {
    final rows = _questionsController.text
        .split(RegExp(r'\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (rows.isEmpty) return;
    final payloads = rows
        .map((row) {
          final parts = row.split('||');
          return QuestionBankExamService.buildQuestionPayload(
            courseId: widget.group.courseId,
            chapterId: widget.group.chapterId,
            questionType: QuestionBankQuestionType.written,
            difficulty: _difficulty,
            bloomLevel: _bloom,
            questionText: parts.first.trim(),
            expectedAnswerText: parts.length > 1
                ? parts.sublist(1).join('||').trim()
                : null,
          );
        })
        .toList(growable: false);
    final saved = await context
        .read<QuestionBankExamCubit>()
        .createGroupQuestionsBatch(
          groupId: widget.group.id,
          questions: payloads,
        );
    if (saved && context.mounted) Navigator.of(context).pop();
  }
}

void _showSavedExamDetailSheet(BuildContext context, int examId) {
  final cubit = context.read<QuestionBankExamCubit>();
  cubit.loadExam(examId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _SavedExamDetailSheet(examId: examId),
    ),
  );
}

class _SavedExamDetailSheet extends StatelessWidget {
  const _SavedExamDetailSheet({required this.examId});

  final int examId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final exam = state.selectedExam;
        if (exam == null || exam.id != examId) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _SheetHeader(
                title: l10n.questionBankExamDetails,
                onClose: () => Navigator.of(context).pop(),
              ),
              Text(
                exam.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _MetaChip(label: _examStatusLabel(l10n, exam.status)),
                  _MetaChip(
                    label:
                        '${l10n.questionBankTotalMarks}: ${exam.totalMarks ?? '-'}',
                  ),
                  _MetaChip(
                    label:
                        '${l10n.questionBankQuestionCount}: ${exam.itemCount ?? '-'}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _SmallButton(
                    icon: Icons.publish_rounded,
                    label: l10n.questionBankPublish,
                    onTap: () => context
                        .read<QuestionBankExamCubit>()
                        .examLifecycle(exam, 'publish'),
                  ),
                  _SmallButton(
                    icon: Icons.visibility_off_outlined,
                    label: l10n.questionBankUnpublish,
                    onTap: () => context
                        .read<QuestionBankExamCubit>()
                        .examLifecycle(exam, 'unpublish'),
                  ),
                  _SmallButton(
                    icon: Icons.download_rounded,
                    label: l10n.questionBankExportWord,
                    onTap: () => _showExportDialog(context, exam),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}

Future<CourseChapterModel?> _showCreateChapterDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<CourseChapterModel>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context).questionBankCreateChapter),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).questionBankChapterName,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            final chapter = await context
                .read<QuestionBankExamCubit>()
                .createChapter(name);
            if (context.mounted) Navigator.of(context).pop(chapter);
          },
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    ),
  );
}

void _showCreateQuestionSheet(BuildContext context) {
  final cubit = context.read<QuestionBankExamCubit>();
  final state = cubit.state;
  if (state.selectedCourseId == null) return;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _CreateQuestionSheet()),
  );
}

class _CreateQuestionSheet extends StatefulWidget {
  const _CreateQuestionSheet();

  @override
  State<_CreateQuestionSheet> createState() => _CreateQuestionSheetState();
}

class _CreateQuestionSheetState extends State<_CreateQuestionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _hintController = TextEditingController();
  QuestionBankQuestionType _type = QuestionBankQuestionType.mcq;
  QuestionBankDifficulty _difficulty = QuestionBankDifficulty.medium;
  QuestionBankBloomLevel _bloom = QuestionBankBloomLevel.understand;
  int? _chapterId;
  int? _questionFileId;
  String? _questionImageName;
  final List<TextEditingController> _options = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctIndex = 0;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    for (final controller in _options) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        _chapterId ??= state.chapters.isNotEmpty
            ? state.chapters.first.id
            : null;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  l10n.questionBankNewQuestion,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _chapterId,
                  decoration: InputDecoration(
                    labelText: l10n.questionBankChapter,
                  ),
                  items: state.chapters
                      .map(
                        (chapter) => DropdownMenuItem<int>(
                          value: chapter.id,
                          child: Text(chapter.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _chapterId = value),
                  validator: (value) =>
                      value == null ? l10n.fieldRequired : null,
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () async {
                      final chapter = await _showCreateChapterDialog(context);
                      if (chapter != null && mounted) {
                        setState(() => _chapterId = chapter.id);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.questionBankCreateChapter),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<QuestionBankQuestionType>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l10n.questionBankType),
                  items: QuestionBankQuestionType.values
                      .map(
                        (type) => DropdownMenuItem<QuestionBankQuestionType>(
                          value: type,
                          child: Text(_questionTypeLabel(l10n, type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    if (value != null) _type = value;
                  }),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<QuestionBankDifficulty>(
                        initialValue: _difficulty,
                        decoration: InputDecoration(
                          labelText: l10n.questionBankDifficulty,
                        ),
                        items: QuestionBankDifficulty.values
                            .map(
                              (item) =>
                                  DropdownMenuItem<QuestionBankDifficulty>(
                                    value: item,
                                    child: Text(_difficultyLabel(l10n, item)),
                                  ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() {
                          if (value != null) _difficulty = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<QuestionBankBloomLevel>(
                        initialValue: _bloom,
                        decoration: InputDecoration(
                          labelText: l10n.questionBankBloom,
                        ),
                        items: QuestionBankBloomLevel.values
                            .map(
                              (item) =>
                                  DropdownMenuItem<QuestionBankBloomLevel>(
                                    value: item,
                                    child: Text(_bloomLabel(l10n, item)),
                                  ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() {
                          if (value != null) _bloom = value;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _questionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.questionBankQuestionText,
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) &&
                          _questionFileId == null
                      ? l10n.fieldRequired
                      : null,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: state.isMutating ? null : _pickPromptImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _questionImageName ?? l10n.questionBankUploadPromptImage,
                  ),
                ),
                if (_questionFileId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.questionBankPromptImageReady,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: InstructorColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (_type == QuestionBankQuestionType.mcq ||
                    _type == QuestionBankQuestionType.trueFalse)
                  ..._buildOptionFields(l10n)
                else
                  TextFormField(
                    controller: _answerController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: _type == QuestionBankQuestionType.fillBlanks
                          ? l10n.questionBankAcceptableAnswer
                          : l10n.questionBankExpectedAnswer,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.fieldRequired
                        : null,
                  ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _hintController,
                  decoration: InputDecoration(labelText: l10n.questionBankHint),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: state.isMutating ? null : () => _save(context),
                  icon: state.isMutating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(l10n.save),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOptionFields(AppLocalizations l10n) {
    return <Widget>[
      for (var i = 0; i < _options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: <Widget>[
              IconButton(
                tooltip: l10n.questionBankCorrect,
                onPressed: () => setState(() => _correctIndex = i),
                icon: Icon(
                  _correctIndex == i
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _correctIndex == i
                      ? InstructorColors.success
                      : InstructorColors.textSecondary,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _options[i],
                  decoration: InputDecoration(
                    labelText: '${l10n.questionBankOption} ${i + 1}',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
            ],
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () =>
              setState(() => _options.add(TextEditingController())),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.questionBankAddOption),
        ),
      ),
    ];
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<QuestionBankExamCubit>();
    final state = cubit.state;
    final courseId = state.selectedCourseId;
    final chapterId = _chapterId;
    if (courseId == null || chapterId == null) return;

    final payload = QuestionBankExamService.buildQuestionPayload(
      courseId: courseId,
      chapterId: chapterId,
      questionType: _type,
      difficulty: _difficulty,
      bloomLevel: _bloom,
      questionText: _questionController.text,
      questionFileId: _questionFileId,
      hints: _hintController.text,
      expectedAnswerText:
          _type == QuestionBankQuestionType.written ||
              _type == QuestionBankQuestionType.essay
          ? _answerController.text
          : null,
      options:
          _type == QuestionBankQuestionType.mcq ||
              _type == QuestionBankQuestionType.trueFalse
          ? List<QuestionBankOptionModel>.generate(
              _options.length,
              (index) => QuestionBankOptionModel(
                optionText: _options[index].text,
                isCorrect: index == _correctIndex,
              ),
            )
          : null,
      fillBlanks: _type == QuestionBankQuestionType.fillBlanks
          ? <QuestionBankFillBlankModel>[
              QuestionBankFillBlankModel(
                blankKey: 'blank1',
                acceptableAnswer: _answerController.text,
              ),
            ]
          : null,
    );
    final saved = await cubit.createQuestion(payload);
    if (saved && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _pickPromptImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final file = picked?.files.single;
    final path = file?.path;
    if (path == null || !mounted) return;
    final fileId = await context
        .read<QuestionBankExamCubit>()
        .uploadQuestionImage(File(path));
    if (fileId == null || !mounted) return;
    setState(() {
      _questionFileId = fileId;
      _questionImageName =
          file?.name ??
          AppLocalizations.of(context).questionBankPromptImageReady;
    });
  }
}

void _showCreateGroupSheet(BuildContext context) {
  final cubit = context.read<QuestionBankExamCubit>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _CreateGroupSheet()),
  );
}

class _CreateGroupSheet extends StatefulWidget {
  const _CreateGroupSheet();

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  int? _chapterId;
  int? _sharedFileId;
  String? _sharedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        _chapterId ??= state.chapters.isNotEmpty
            ? state.chapters.first.id
            : null;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text(
                l10n.questionBankNewGroup,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _chapterId,
                decoration: InputDecoration(
                  labelText: l10n.questionBankChapter,
                ),
                items: state.chapters
                    .map(
                      (chapter) => DropdownMenuItem<int>(
                        value: chapter.id,
                        child: Text(chapter.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _chapterId = value),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final chapter = await _showCreateChapterDialog(context);
                    if (chapter != null && mounted) {
                      setState(() => _chapterId = chapter.id);
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.questionBankCreateChapter),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.questionBankGroupTitle,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.questionBankSharedPrompt,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: state.isMutating ? null : _pickSharedFile,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _sharedFileName ?? l10n.questionBankUploadSharedFile,
                ),
              ),
              if (_sharedFileId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.questionBankSharedFileReady,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: InstructorColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isMutating ? null : () => _save(context),
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<QuestionBankExamCubit>();
    final courseId = cubit.state.selectedCourseId;
    final chapterId = _chapterId;
    if (courseId == null || chapterId == null) return;
    final saved = await cubit.createGroup(<String, dynamic>{
      'courseId': courseId,
      'chapterId': chapterId,
      if (_titleController.text.trim().isNotEmpty)
        'title': _titleController.text.trim(),
      if (_promptController.text.trim().isNotEmpty)
        'sharedPrompt': _promptController.text.trim(),
      if (_sharedFileId != null) 'sharedFileId': _sharedFileId,
    });
    if (saved && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _pickSharedFile() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final file = picked?.files.single;
    final path = file?.path;
    if (path == null || !mounted) return;
    final fileId = await context
        .read<QuestionBankExamCubit>()
        .uploadQuestionImage(File(path));
    if (fileId == null || !mounted) return;
    setState(() {
      _sharedFileId = fileId;
      _sharedFileName =
          file?.name ??
          AppLocalizations.of(context).questionBankSharedFileReady;
    });
  }
}

void _showGenerateExamSheet(BuildContext context) {
  final cubit = context.read<QuestionBankExamCubit>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _GenerateExamSheet()),
  );
}

class _GenerateExamSheet extends StatefulWidget {
  const _GenerateExamSheet();

  @override
  State<_GenerateExamSheet> createState() => _GenerateExamSheetState();
}

class _GenerateExamSheetState extends State<_GenerateExamSheet> {
  final _titleController = TextEditingController();
  final _totalController = TextEditingController(text: '100');
  final _countController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '1');
  final _sectionTitleController = TextEditingController();
  int? _chapterId;
  QuestionBankQuestionType _type = QuestionBankQuestionType.mcq;
  QuestionBankDifficulty _difficulty = QuestionBankDifficulty.medium;
  QuestionBankBloomLevel _bloom = QuestionBankBloomLevel.understand;
  ExamMarkDistributionMode _mode = ExamMarkDistributionMode.manual;
  bool _sectioned = false;
  bool _sectionTitleInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _countController.dispose();
    _weightController.dispose();
    _sectionTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_sectionTitleInitialized) {
      _sectionTitleInitialized = true;
      _sectionTitleController.text = l10n.questionBankDefaultSectionName;
    }
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        _chapterId ??= state.chapters.isNotEmpty
            ? state.chapters.first.id
            : null;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text(
                l10n.questionBankCreateExam,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.questionBankExamTitle,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _chapterId,
                decoration: InputDecoration(
                  labelText: l10n.questionBankChapter,
                ),
                items: state.chapters
                    .map(
                      (chapter) => DropdownMenuItem<int>(
                        value: chapter.id,
                        child: Text(chapter.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _chapterId = value),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final chapter = await _showCreateChapterDialog(context);
                    if (chapter != null && mounted) {
                      setState(() => _chapterId = chapter.id);
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.questionBankCreateChapter),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankQuestionCount,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankWeight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.questionBankTotalMarks,
                ),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _sectioned,
                onChanged: (value) => setState(() => _sectioned = value),
                title: Text(l10n.questionBankSectionedMode),
              ),
              if (_sectioned) ...<Widget>[
                const SizedBox(height: 8),
                TextField(
                  controller: _sectionTitleController,
                  decoration: InputDecoration(
                    labelText: l10n.questionBankSectionTitle,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<QuestionBankQuestionType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.questionBankType),
                items: QuestionBankQuestionType.values
                    .map(
                      (item) => DropdownMenuItem<QuestionBankQuestionType>(
                        value: item,
                        child: Text(_questionTypeLabel(l10n, item)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  if (value != null) _type = value;
                }),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankDifficulty>(
                      initialValue: _difficulty,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankDifficulty,
                      ),
                      items: QuestionBankDifficulty.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankDifficulty>(
                              value: item,
                              child: Text(_difficultyLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        if (value != null) _difficulty = value;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<QuestionBankBloomLevel>(
                      initialValue: _bloom,
                      decoration: InputDecoration(
                        labelText: l10n.questionBankBloom,
                      ),
                      items: QuestionBankBloomLevel.values
                          .map(
                            (item) => DropdownMenuItem<QuestionBankBloomLevel>(
                              value: item,
                              child: Text(_bloomLabel(l10n, item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        if (value != null) _bloom = value;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ExamMarkDistributionMode>(
                initialValue: _mode,
                decoration: InputDecoration(
                  labelText: l10n.questionBankTotalMarks,
                ),
                items: ExamMarkDistributionMode.values
                    .map(
                      (item) => DropdownMenuItem<ExamMarkDistributionMode>(
                        value: item,
                        child: Text(_markModeLabel(l10n, item)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  if (value != null) _mode = value;
                }),
              ),
              const SizedBox(height: 16),
              if (state.generationShortages.isNotEmpty) ...<Widget>[
                ExamGenerationShortagePanel(
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  shortages: state.generationShortages,
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: state.isMutating ? null : () => _generate(context),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(l10n.questionBankGenerateDraft),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generate(BuildContext context) async {
    final cubit = context.read<QuestionBankExamCubit>();
    final l10n = AppLocalizations.of(context);
    final courseId = cubit.state.selectedCourseId;
    final chapterId = _chapterId;
    if (courseId == null || chapterId == null) return;
    final count = int.tryParse(_countController.text) ?? 1;
    final weight = double.tryParse(_weightController.text) ?? 1;
    if (_mode == ExamMarkDistributionMode.weightNormalized && weight <= 0) {
      return;
    }
    final totalMarks = double.tryParse(_totalController.text);
    final rule = ExamGenerationRuleModel(
      chapterId: chapterId,
      questionType: _type,
      difficulty: _difficulty,
      bloomLevel: _bloom,
      count: count,
      weightPerQuestion: weight,
    );
    final payload = QuestionBankExamService.buildGenerateExamPayload(
      courseId: courseId,
      title: _titleController.text.trim().isEmpty
          ? l10n.questionBankGeneratedExamFallback
          : _titleController.text,
      totalMarks: totalMarks,
      markDistributionMode: _mode,
      rules: _sectioned
          ? const <ExamGenerationRuleModel>[]
          : <ExamGenerationRuleModel>[rule],
      sections: _sectioned
          ? <ExamGenerationSectionModel>[
              ExamGenerationSectionModel(
                title: _sectionTitleController.text.trim().isEmpty
                    ? l10n.questionBankSectionTitle
                    : _sectionTitleController.text,
                totalMarks: totalMarks ?? count * weight,
                rules: <ExamGenerationRuleModel>[rule],
              ),
            ]
          : const <ExamGenerationSectionModel>[],
    );
    final draft = await cubit.generateDraft(payload);
    if (draft != null && context.mounted) {
      Navigator.of(context).pop();
      _showDraftEditor(context, draft.id);
    }
  }
}

void _showDraftEditor(BuildContext context, int draftId) {
  final cubit = context.read<QuestionBankExamCubit>();
  cubit.loadDraft(draftId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _DraftEditorSheet()),
  );
}

class _DraftEditorSheet extends StatelessWidget {
  const _DraftEditorSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final draft = state.selectedDraft;
        if (draft == null) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      draft.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                '${l10n.questionBankQuestionCount}: ${draft.items.length} • ${l10n.questionBankTotalMarks}: ${draft.totalMarks ?? '-'}',
              ),
              if (!draft.isEditable) ...<Widget>[
                const SizedBox(height: 8),
                _MetaChip(label: l10n.questionBankDraftLocked),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _SmallButton(
                    icon: Icons.add_rounded,
                    label: l10n.questionBankAddDraftSection,
                    onTap: draft.isEditable
                        ? () => _showAddDraftSectionDialog(context, draft.id)
                        : null,
                  ),
                  _SmallButton(
                    icon: Icons.playlist_add_rounded,
                    label: l10n.questionBankAddApprovedQuestion,
                    onTap: draft.isEditable
                        ? () => _showAddDraftItemSheet(context, draft)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final section in draft.orderedSections)
                _DraftSectionPanel(
                  draft: draft,
                  section: section,
                  items: draft.itemsForSection(section.id),
                ),
              if (draft.items.any((item) => item.draftSectionId == null)) ...[
                Text(
                  l10n.questionBankUnsectionedItems,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                for (final item in draft.items.where(
                  (item) => item.draftSectionId == null,
                ))
                  _DraftItemTile(draft: draft, item: item),
              ],
              if (draft.sections.isEmpty &&
                  draft.items.every((item) => item.draftSectionId != null))
                for (final item in draft.items)
                  _DraftItemTile(draft: draft, item: item),
              const SizedBox(height: 12),
              Text(
                _draftMarksSummary(l10n, draft),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: state.isMutating || !draft.isEditable
                    ? null
                    : () async {
                        final exam = await context
                            .read<QuestionBankExamCubit>()
                            .saveDraft(draft.id);
                        if (exam != null && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(l10n.questionBankSaveExam),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraftSectionPanel extends StatelessWidget {
  const _DraftSectionPanel({
    required this.draft,
    required this.section,
    required this.items,
  });

  final ExamDraftModel draft;
  final ExamDraftSectionModel section;
  final List<ExamDraftItemModel> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${section.sectionOrder + 1}. ${section.title}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: l10n.questionBankMoveUp,
                  onPressed: draft.isEditable
                      ? () => _moveDraftSection(context, draft, section, -1)
                      : null,
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                IconButton(
                  tooltip: l10n.questionBankMoveDown,
                  onPressed: draft.isEditable
                      ? () => _moveDraftSection(context, draft, section, 1)
                      : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                IconButton(
                  tooltip: l10n.questionBankEditSection,
                  onPressed: draft.isEditable
                      ? () => _showEditDraftSectionDialog(
                          context,
                          draft.id,
                          section,
                        )
                      : null,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: draft.isEditable
                      ? () => context
                            .read<QuestionBankExamCubit>()
                            .deleteDraftSection(
                              draftId: draft.id,
                              sectionId: section.id,
                            )
                      : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            if ((section.instructions ?? '').isNotEmpty)
              Text(section.instructions!),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.questionBankNoQuestions),
              ),
            for (final item in items) _DraftItemTile(draft: draft, item: item),
          ],
        ),
      ),
    );
  }
}

class _DraftItemTile extends StatelessWidget {
  const _DraftItemTile({required this.draft, required this.item});

  final ExamDraftModel draft;
  final ExamDraftItemModel item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = item.question?.displayText ?? '#${item.questionId}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text('${item.itemOrder + 1}')),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${_questionTypeLabel(l10n, item.questionType)} • ${l10n.questionBankItemMarks}: ${item.marks ?? '-'}',
        ),
        trailing: PopupMenuButton<String>(
          enabled: draft.isEditable,
          onSelected: (value) {
            if (value == 'marks') {
              _showEditMarksDialog(context, draft.id, item);
            } else if (value == 'replace') {
              _showAddDraftItemSheet(context, draft, replaceItem: item);
            } else if (value == 'up') {
              _moveDraftItem(context, draft, item, -1);
            } else if (value == 'down') {
              _moveDraftItem(context, draft, item, 1);
            } else if (value == 'remove') {
              context.read<QuestionBankExamCubit>().removeDraftItem(
                draft.id,
                item,
              );
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'marks',
              child: Text(l10n.questionBankItemMarks),
            ),
            PopupMenuItem<String>(
              value: 'replace',
              child: Text(l10n.questionBankReplaceItem),
            ),
            PopupMenuItem<String>(
              value: 'up',
              child: Text(l10n.questionBankMoveUp),
            ),
            PopupMenuItem<String>(
              value: 'down',
              child: Text(l10n.questionBankMoveDown),
            ),
            PopupMenuItem<String>(value: 'remove', child: Text(l10n.delete)),
          ],
        ),
      ),
    );
  }
}

void _moveDraftSection(
  BuildContext context,
  ExamDraftModel draft,
  ExamDraftSectionModel section,
  int delta,
) {
  final sections = [...draft.sections]
    ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder));
  final index = sections.indexWhere((item) => item.id == section.id);
  final targetIndex = index + delta;
  if (index < 0 || targetIndex < 0 || targetIndex >= sections.length) return;
  final moving = sections.removeAt(index);
  sections.insert(targetIndex, moving);
  context.read<QuestionBankExamCubit>().reorderDraftSections(
    draftId: draft.id,
    sectionIds: sections.map((item) => item.id).toList(growable: false),
  );
}

void _moveDraftItem(
  BuildContext context,
  ExamDraftModel draft,
  ExamDraftItemModel item,
  int delta,
) {
  final items = [...draft.items]
    ..sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
  final index = items.indexWhere((candidate) => candidate.id == item.id);
  final targetIndex = index + delta;
  if (index < 0 || targetIndex < 0 || targetIndex >= items.length) return;
  final moving = items.removeAt(index);
  items.insert(targetIndex, moving);
  context.read<QuestionBankExamCubit>().reorderDraftItems(
    draftId: draft.id,
    itemIds: items.map((candidate) => candidate.id).toList(growable: false),
  );
}

void _showAddDraftSectionDialog(BuildContext context, int draftId) {
  final titleController = TextEditingController();
  final marksController = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context).questionBankAddDraftSection),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).questionBankSectionTitle,
            ),
          ),
          TextField(
            controller: marksController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).questionBankTotalMarks,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final title = titleController.text.trim();
            if (title.isEmpty) return;
            final saved = await context
                .read<QuestionBankExamCubit>()
                .addDraftSection(
                  draftId: draftId,
                  title: title,
                  totalMarks: double.tryParse(marksController.text),
                );
            if (saved && context.mounted) Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    ),
  );
}

void _showEditDraftSectionDialog(
  BuildContext context,
  int draftId,
  ExamDraftSectionModel section,
) {
  final titleController = TextEditingController(text: section.title);
  final marksController = TextEditingController(
    text: section.totalMarks?.toString() ?? '',
  );
  final instructionsController = TextEditingController(
    text: section.instructions ?? '',
  );
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context).questionBankEditSection),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).questionBankSectionTitle,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: marksController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).questionBankTotalMarks,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: instructionsController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).questionBankHint,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final title = titleController.text.trim();
            if (title.isEmpty) return;
            final saved = await context
                .read<QuestionBankExamCubit>()
                .updateDraftSection(
                  draftId: draftId,
                  sectionId: section.id,
                  title: title,
                  instructions: instructionsController.text,
                  totalMarks: double.tryParse(marksController.text),
                  answerPolicy: section.answerPolicy,
                  requiredAnswerCount: section.requiredAnswerCount,
                );
            if (saved && context.mounted) Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    ),
  );
}

void _showAddDraftItemSheet(
  BuildContext context,
  ExamDraftModel draft, {
  ExamDraftItemModel? replaceItem,
}) {
  final cubit = context.read<QuestionBankExamCubit>();
  cubit.setQuestionFilters(status: QuestionBankStatus.approved);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddDraftItemSheet(draft: draft, replaceItem: replaceItem),
    ),
  );
}

class _AddDraftItemSheet extends StatefulWidget {
  const _AddDraftItemSheet({required this.draft, this.replaceItem});

  final ExamDraftModel draft;
  final ExamDraftItemModel? replaceItem;

  @override
  State<_AddDraftItemSheet> createState() => _AddDraftItemSheetState();
}

class _AddDraftItemSheetState extends State<_AddDraftItemSheet> {
  final _marksController = TextEditingController(text: '1');
  final _overrideController = TextEditingController();
  int? _sectionId;
  bool _useWeightUnits = false;

  @override
  void dispose() {
    _marksController.dispose();
    _overrideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<QuestionBankExamCubit, QuestionBankExamState>(
      builder: (context, state) {
        final approved = state.questionItems
            .where((item) => item.status == QuestionBankStatus.approved)
            .toList(growable: false);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _SheetHeader(
                title: widget.replaceItem == null
                    ? l10n.questionBankAddApprovedQuestion
                    : l10n.questionBankReplaceItem,
                onClose: () => Navigator.of(context).pop(),
              ),
              if (widget.replaceItem == null &&
                  widget.draft.sections.isNotEmpty)
                DropdownButtonFormField<int?>(
                  initialValue: _sectionId,
                  decoration: InputDecoration(
                    labelText: l10n.questionBankSections,
                  ),
                  items: <DropdownMenuItem<int?>>[
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.questionBankUnsectionedItems),
                    ),
                    ...widget.draft.sections.map(
                      (section) => DropdownMenuItem<int?>(
                        value: section.id,
                        child: Text(section.title),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _sectionId = value),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _useWeightUnits,
                title: Text(l10n.questionBankUseWeightUnits),
                onChanged: (value) => setState(() => _useWeightUnits = value),
              ),
              TextField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _useWeightUnits
                      ? l10n.questionBankWeight
                      : l10n.questionBankItemMarks,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _overrideController,
                decoration: InputDecoration(
                  labelText: l10n.questionBankOverrideReason,
                ),
              ),
              const SizedBox(height: 12),
              for (final question in approved)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    question.displayText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _questionTypeLabel(l10n, question.questionType),
                  ),
                  trailing: const Icon(Icons.add_circle_outline_rounded),
                  onTap: () => _selectQuestion(context, question),
                ),
              if (approved.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(l10n.questionBankNoQuestions),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectQuestion(
    BuildContext context,
    QuestionBankQuestionModel question,
  ) async {
    final marks = double.tryParse(_marksController.text);
    final overrideReason = _overrideController.text.trim();
    final cubit = context.read<QuestionBankExamCubit>();
    bool saved;
    if (widget.replaceItem == null) {
      final duplicate = widget.draft.items.any(
        (item) => item.questionId == question.id,
      );
      if (duplicate && overrideReason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).questionBankDuplicateDraftQuestion,
            ),
          ),
        );
        return;
      }
      saved = await cubit.addDraftItem(
        draftId: widget.draft.id,
        questionId: question.id,
        draftSectionId: _sectionId,
        marks: _useWeightUnits ? null : marks,
        weightUnits: _useWeightUnits ? marks : null,
        overrideReason: overrideReason.isEmpty ? null : overrideReason,
      );
    } else {
      saved = await cubit.replaceDraftItem(
        draftId: widget.draft.id,
        item: widget.replaceItem!,
        replacementQuestionId: question.id,
        overrideReason: overrideReason.isEmpty ? null : overrideReason,
      );
    }
    if (saved && context.mounted) Navigator.of(context).pop();
  }
}

String _draftMarksSummary(AppLocalizations l10n, ExamDraftModel draft) {
  final itemMarks = draft.items.fold<double>(
    0,
    (sum, item) => sum + (item.marks ?? item.weight),
  );
  final declared = draft.totalMarks;
  if (declared == null) {
    return '${l10n.questionBankItemMarks}: $itemMarks';
  }
  return '${l10n.questionBankTotalMarks}: $declared • ${l10n.questionBankItemMarks}: $itemMarks';
}

void _showEditMarksDialog(
  BuildContext context,
  int draftId,
  ExamDraftItemModel item,
) {
  final controller = TextEditingController(
    text: (item.marks ?? item.weight).toString(),
  );
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context).questionBankItemMarks),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final marks = double.tryParse(controller.text);
            if (marks != null) {
              context.read<QuestionBankExamCubit>().updateDraftItemMarks(
                draftId: draftId,
                item: item,
                marks: marks,
              );
            }
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    ),
  );
}

void _showExportDialog(BuildContext context, ExamResponseModel exam) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context).questionBankExportWord),
      content: Text(
        AppLocalizations.of(context).questionBankOnlyCompactSavedExam,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.download_rounded),
          label: Text(
            AppLocalizations.of(context).questionBankExportStudentCopy,
          ),
          onPressed: () async {
            final export = await context
                .read<QuestionBankExamCubit>()
                .exportWord(exam.id, includeAnswerKey: false);
            if (export != null && context.mounted) {
              Navigator.of(context).pop();
              await _saveAndOpenExport(context, export);
            }
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.key_rounded),
          label: Text(AppLocalizations.of(context).questionBankExportAnswerKey),
          onPressed: () async {
            final export = await context
                .read<QuestionBankExamCubit>()
                .exportWord(exam.id, includeAnswerKey: true);
            if (export != null && context.mounted) {
              Navigator.of(context).pop();
              await _saveAndOpenExport(context, export);
            }
          },
        ),
      ],
    ),
  );
}

Future<void> _saveAndOpenExport(
  BuildContext context,
  ExamExportModel export,
) async {
  final bytes = base64Decode(export.content);
  final directory = await getTemporaryDirectory();
  final file = File(
    '${directory.path}${Platform.pathSeparator}${export.fileName}',
  );
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open(file.path);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${AppLocalizations.of(context).questionBankExportSaved}: ${export.fileName}',
      ),
    ),
  );
}

List<TeachingCourseModel> _uniqueCourses(List<TeachingCourseModel> courses) {
  final byId = <int, TeachingCourseModel>{};
  for (final course in courses) {
    byId.putIfAbsent(course.courseId, () => course);
  }
  return byId.values.toList(growable: false);
}

String _questionTypeLabel(
  AppLocalizations l10n,
  QuestionBankQuestionType type,
) {
  return switch (type) {
    QuestionBankQuestionType.mcq => l10n.questionBankTypeMcq,
    QuestionBankQuestionType.trueFalse => l10n.questionBankTypeTrueFalse,
    QuestionBankQuestionType.fillBlanks => l10n.questionBankTypeFillBlanks,
    QuestionBankQuestionType.written => l10n.questionBankTypeWritten,
    QuestionBankQuestionType.essay => l10n.questionBankTypeEssay,
  };
}

String _groupTitle(AppLocalizations l10n, QuestionBankGroupModel group) {
  final title = group.title?.trim();
  return title == null || title.isEmpty
      ? l10n.questionBankUntitledGroup
      : title;
}

String _difficultyLabel(
  AppLocalizations l10n,
  QuestionBankDifficulty difficulty,
) {
  return switch (difficulty) {
    QuestionBankDifficulty.easy => l10n.questionBankDifficultyEasy,
    QuestionBankDifficulty.medium => l10n.questionBankDifficultyMedium,
    QuestionBankDifficulty.hard => l10n.questionBankDifficultyHard,
  };
}

String _bloomLabel(AppLocalizations l10n, QuestionBankBloomLevel level) {
  return switch (level) {
    QuestionBankBloomLevel.remember => l10n.questionBankBloomRemember,
    QuestionBankBloomLevel.understand => l10n.questionBankBloomUnderstand,
    QuestionBankBloomLevel.apply => l10n.questionBankBloomApply,
    QuestionBankBloomLevel.analyze => l10n.questionBankBloomAnalyze,
    QuestionBankBloomLevel.evaluate => l10n.questionBankBloomEvaluate,
    QuestionBankBloomLevel.create => l10n.questionBankBloomCreate,
  };
}

String _questionStatusLabel(AppLocalizations l10n, QuestionBankStatus status) {
  return switch (status) {
    QuestionBankStatus.draft => l10n.questionBankStatusDraft,
    QuestionBankStatus.pendingReview => l10n.questionBankStatusPendingReview,
    QuestionBankStatus.approved => l10n.questionBankStatusApproved,
    QuestionBankStatus.rejected => l10n.questionBankStatusRejected,
    QuestionBankStatus.archived => l10n.questionBankStatusArchived,
  };
}

String _examStatusLabel(AppLocalizations l10n, ExamStatus status) {
  return switch (status) {
    ExamStatus.draft => l10n.questionBankExamStatusDraft,
    ExamStatus.published => l10n.questionBankExamStatusPublished,
    ExamStatus.unpublished => l10n.questionBankExamStatusUnpublished,
    ExamStatus.archived => l10n.questionBankExamStatusArchived,
  };
}

String _draftStatusLabel(AppLocalizations l10n, ExamDraftStatus status) {
  return switch (status) {
    ExamDraftStatus.open => l10n.questionBankDraftStatusOpen,
    ExamDraftStatus.finalized => l10n.questionBankDraftStatusFinalized,
    ExamDraftStatus.expired => l10n.questionBankDraftStatusExpired,
    ExamDraftStatus.failed => l10n.questionBankDraftStatusFailed,
    ExamDraftStatus.cancelled => l10n.questionBankDraftStatusCancelled,
  };
}

String _markModeLabel(AppLocalizations l10n, ExamMarkDistributionMode mode) {
  return switch (mode) {
    ExamMarkDistributionMode.manual => l10n.questionBankMarkModeManual,
    ExamMarkDistributionMode.equal => l10n.questionBankMarkModeEqual,
    ExamMarkDistributionMode.weightNormalized =>
      l10n.questionBankMarkModeWeightNormalized,
  };
}

IconData _questionIcon(QuestionBankQuestionType type) {
  return switch (type) {
    QuestionBankQuestionType.mcq => Icons.checklist_rounded,
    QuestionBankQuestionType.trueFalse => Icons.rule_rounded,
    QuestionBankQuestionType.fillBlanks => Icons.short_text_rounded,
    QuestionBankQuestionType.written => Icons.edit_note_rounded,
    QuestionBankQuestionType.essay => Icons.subject_rounded,
  };
}

Color _statusColor(QuestionBankStatus status) {
  return switch (status) {
    QuestionBankStatus.approved => InstructorColors.success,
    QuestionBankStatus.rejected => InstructorColors.error,
    QuestionBankStatus.pendingReview => InstructorColors.warning,
    QuestionBankStatus.archived => InstructorColors.textSecondary,
    QuestionBankStatus.draft => InstructorColors.primary,
  };
}
