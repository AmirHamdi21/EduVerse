import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/features/walkthrough/instructor_walkthrough_registry.dart';
import 'package:edu_verse/features/walkthrough/role_walkthrough_cubit.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';

class InstructorQuestionBankScreen extends StatelessWidget {
  const InstructorQuestionBankScreen({
    super.key,
    this.initialCourseId,
    this.initialChapterId,
    this.initialGroupId,
    this.initialType,
    this.initialDifficulty,
    this.initialBloomLevel,
    this.initialStatus,
    this.initialSearch,
  });

  final int? initialCourseId;
  final int? initialChapterId;
  final int? initialGroupId;
  final QuestionBankType? initialType;
  final QuestionBankDifficulty? initialDifficulty;
  final BloomLevel? initialBloomLevel;
  final QuestionBankStatus? initialStatus;
  final String? initialSearch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = QuestionBankCubit(
          questionBankService: QuestionBankService(
            coreApiClient: CoreApiClient(),
          ),
          enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
        );
        cubit.initialize(preferredCourseId: initialCourseId).then((_) {
          final hasInitialFilters =
              initialChapterId != null ||
              initialGroupId != null ||
              initialType != null ||
              initialDifficulty != null ||
              initialBloomLevel != null ||
              initialStatus != null ||
              (initialSearch?.trim().isNotEmpty ?? false);
          if (hasInitialFilters) {
            cubit.setFilters(
              chapterId: initialChapterId,
              clearChapter: initialChapterId == null,
              groupId: initialGroupId,
              clearGroup: initialGroupId == null,
              type: initialType,
              clearType: initialType == null,
              difficulty: initialDifficulty,
              clearDifficulty: initialDifficulty == null,
              bloomLevel: initialBloomLevel,
              clearBloom: initialBloomLevel == null,
              status: initialStatus,
              clearStatus: initialStatus == null,
              search: initialSearch,
            );
          }
        });
        return cubit;
      },
      child: const _InstructorQuestionBankView(),
    );
  }
}

class _InstructorQuestionBankView extends StatefulWidget {
  const _InstructorQuestionBankView();

  @override
  State<_InstructorQuestionBankView> createState() =>
      _InstructorQuestionBankViewState();
}

class _InstructorQuestionBankViewState
    extends State<_InstructorQuestionBankView> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _collapsedGroupIds = <int>{};
  bool _actionsOpen = false;
  bool _hasCompletedInitialLoad = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) safeBack(context, '/instructor/dashboard');
      },
      child: InstructorWalkthroughRouteMarker(
        segmentId: InstructorWalkthroughIds.questionBank,
        child: Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          appBar: AppBar(
            backgroundColor: InstructorColors.background(isDark),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => safeBack(context, '/instructor/dashboard'),
              icon: Icon(
                iosBackIcon(context),
                color: InstructorColors.textPrimaryColor(isDark),
              ),
            ),
            title: Text(
              l10n.questionBank,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              BlocBuilder<QuestionBankCubit, QuestionBankState>(
                builder: (context, state) {
                  return _AppBarActionButton(
                    tooltip: l10n.qbGroups,
                    icon: Icons.folder_copy_outlined,
                    color: InstructorColors.cyan,
                    isDark: isDark,
                    onPressed: () =>
                        context.push('/instructor/question-bank/groups'),
                  );
                },
              ),
              _AppBarActionButton(
                tooltip: l10n.qbManageChapters,
                icon: Icons.view_list_outlined,
                color: InstructorColors.orange,
                isDark: isDark,
                onPressed: () =>
                    context.push('/instructor/question-bank/chapters'),
              ),
              BlocBuilder<QuestionBankCubit, QuestionBankState>(
                builder: (context, state) {
                  return _AppBarActionButton(
                    tooltip: state.isSelectionMode
                        ? l10n.cancel
                        : l10n.qbSelectQuestions,
                    icon: state.isSelectionMode
                        ? Icons.close_rounded
                        : Icons.checklist_rounded,
                    color: InstructorColors.warning,
                    isDark: isDark,
                    onPressed: () => context
                        .read<QuestionBankCubit>()
                        .setSelectionMode(!state.isSelectionMode),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton:
              BlocBuilder<QuestionBankCubit, QuestionBankState>(
                builder: (context, state) {
                  return WalkthroughTarget(
                    id: InstructorWalkthroughIds.questionBankCreate,
                    shape: WalkthroughTargetShape.circle,
                    child: _QuestionBankFabCluster(
                      isOpen: _actionsOpen,
                      isDark: isDark,
                      onToggleOpen: () =>
                          setState(() => _actionsOpen = !_actionsOpen),
                      onCreateQuestion: () {
                        setState(() => _actionsOpen = false);
                        context.push('/instructor/question-bank/create');
                      },
                      onBulkCreate: () async {
                        setState(() => _actionsOpen = false);
                        final changed = await context.push<bool>(
                          '/instructor/question-bank/bulk-create',
                        );
                        if (changed == true && context.mounted) {
                          await context.read<QuestionBankCubit>().refresh();
                        }
                      },
                      onCreateGroup: () {
                        setState(() => _actionsOpen = false);
                        context.push('/instructor/question-bank/groups/create');
                      },
                    ),
                  );
                },
              ),
          body: BlocConsumer<QuestionBankCubit, QuestionBankState>(
            listenWhen: (previous, current) {
              final previousMessage =
                  previous.errorMessage ?? previous.actionMessage;
              final currentMessage =
                  current.errorMessage ?? current.actionMessage;
              return currentMessage != null &&
                  currentMessage != previousMessage;
            },
            listener: (context, state) {
              final message = state.errorMessage ?? state.actionMessage;
              if (message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(localizedQuestionBankMessage(l10n, message)),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (_searchController.text != state.search) {
                _searchController.value = TextEditingValue(
                  text: state.search,
                  selection: TextSelection.collapsed(
                    offset: state.search.length,
                  ),
                );
              }

              final showInitialSkeleton =
                  state.isLoading &&
                  state.questions.isEmpty &&
                  !_hasCompletedInitialLoad;
              if (!state.isLoading) _hasCompletedInitialLoad = true;
              if (showInitialSkeleton) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  children: const [QuestionBankSkeletons(itemCount: 5)],
                );
              }
              final walkthroughState = context
                  .watch<RoleWalkthroughCubit>()
                  .state;
              final showWalkthroughDemo =
                  walkthroughState.isActive &&
                  walkthroughState.role == WalkthroughRole.instructor &&
                  walkthroughState.segment?.id ==
                      InstructorWalkthroughIds.questionBank &&
                  state.questions.isEmpty &&
                  state.groups.isEmpty &&
                  state.total == 0 &&
                  state.errorMessage == null;

              final content = RefreshIndicator(
                color: InstructorColors.primary,
                onRefresh: () => context.read<QuestionBankCubit>().refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 118),
                  children: [
                    WalkthroughTarget(
                      id: InstructorWalkthroughIds.questionBankHeader,
                      child: QuestionBankHeroHeader(
                        title: l10n.questionBankHeroTitle,
                        subtitle: l10n.questionBankHeroSubtitle,
                        isDark: isDark,
                        stats: {
                          l10n.total: state.total.toString(),
                          l10n.approved: state.approvedCount.toString(),
                          l10n.draft: state.draftCount.toString(),
                          l10n.qbUnderReview: state.underReviewCount.toString(),
                          l10n.qbRejected: state.rejectedCount.toString(),
                          l10n.archived: state.archivedCount.toString(),
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    WalkthroughTarget(
                      id: InstructorWalkthroughIds.questionBankControls,
                      child: _QuestionBankControlPanel(
                        state: state,
                        searchController: _searchController,
                        isDark: isDark,
                        isLoading: state.isLoading && _hasCompletedInitialLoad,
                        onSearchChanged: (value) => context
                            .read<QuestionBankCubit>()
                            .setFilters(search: value, debounceRemote: true),
                        onFilterAction: _handleFilterAction,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (state.isSelectionMode) ...[
                      _BatchActionBar(state: state, isDark: isDark),
                      const SizedBox(height: 12),
                    ],
                    if (state.errorMessage != null)
                      _ErrorRetry(
                        message: localizedQuestionBankMessage(
                          l10n,
                          state.errorMessage!,
                        ),
                        isDark: isDark,
                        onRetry: () =>
                            context.read<QuestionBankCubit>().refresh(),
                      )
                    else if (state.questions.isEmpty)
                      if (showWalkthroughDemo)
                        WalkthroughTarget(
                          id: InstructorWalkthroughIds.questionBankFeed,
                          child: _QuestionBankWalkthroughDemoFeed(
                            isDark: isDark,
                          ),
                        )
                      else
                        QuestionBankEmptyState(
                          title: l10n.questionBankEmptyTitle,
                          message: l10n.questionBankEmptyMessage,
                          action: FilledButton.icon(
                            onPressed: () => context.push(
                              '/instructor/question-bank/create',
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(l10n.questionBankCreateQuestion),
                          ),
                        )
                    else
                      WalkthroughTarget(
                        id: InstructorWalkthroughIds.questionBankFeed,
                        child: Column(
                          children: _buildQuestionFeed(context, state, isDark),
                        ),
                      ),
                    if (state.hasMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Center(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: InstructorColors.primary,
                              side: const BorderSide(
                                color: InstructorColors.primary,
                                width: 1.4,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: state.isLoadingMore
                                ? null
                                : () => context
                                      .read<QuestionBankCubit>()
                                      .loadMore(),
                            icon: state.isLoadingMore
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.expand_more_rounded),
                            label: Text(l10n.loadMore),
                          ),
                        ),
                      ),
                  ],
                ),
              );

              return Stack(
                children: [
                  content,
                  if (state.activeBatchAction != null)
                    Positioned.fill(
                      child: _BatchMutationOverlay(
                        action: state.activeBatchAction!,
                        selectedCount: state.selectedQuestionCount,
                        isDark: isDark,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuestionFeed(
    BuildContext context,
    QuestionBankState state,
    bool isDark,
  ) {
    final entries = _QuestionFeedEntry.fromState(state);
    return entries.map((entry) {
      final question = entry.question;
      if (question != null) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildQuestionCard(context, state, question),
        );
      }

      final group = entry.group!;
      final isCollapsed =
          !state.isSelectionMode && _collapsedGroupIds.contains(group.groupId);
      return _QuestionGroupQuestionSection(
        key: ValueKey('question-group-${group.groupId}'),
        group: group,
        isDark: isDark,
        isCollapsed: isCollapsed,
        canCollapse: !state.isSelectionMode,
        onViewGroup: () =>
            context.push('/instructor/question-bank/groups/${group.groupId}'),
        onEditGroup: () => context.push(
          '/instructor/question-bank/groups/${group.groupId}/edit',
        ),
        onAddGroupedQuestions: () => context.push(
          '/instructor/question-bank/groups/${group.groupId}/add-questions',
        ),
        onAddExistingQuestions: () => context.push(
          '/instructor/question-bank/groups/${group.groupId}/link-questions',
        ),
        onToggleCollapsed: () {
          setState(() {
            if (_collapsedGroupIds.contains(group.groupId)) {
              _collapsedGroupIds.remove(group.groupId);
            } else {
              _collapsedGroupIds.add(group.groupId);
            }
          });
        },
        questionBuilder: (question, groupId) =>
            _buildQuestionCard(context, state, question, groupId: groupId),
      );
    }).toList();
  }

  Widget _buildQuestionCard(
    BuildContext context,
    QuestionBankState state,
    QuestionBankQuestionModel question, {
    int? groupId,
  }) {
    return QuestionBankCard(
      question: question,
      onTap: () => context.push('/instructor/question-bank/${question.id}'),
      onEdit: () {
        final returnTo = Uri.encodeComponent('/instructor/question-bank');
        context.push(
          '/instructor/question-bank/${question.id}/edit?returnTo=$returnTo',
        );
      },
      selectionMode: state.isSelectionMode,
      isSelected: context.read<QuestionBankCubit>().isQuestionSelected(
        question.id,
      ),
      onSelectionChanged: (_) => context
          .read<QuestionBankCubit>()
          .toggleQuestionSelection(question.id),
      onDelete: () async {
        final ok = await _confirmDeleteQuestion(context);
        if (ok && context.mounted) {
          await context.read<QuestionBankCubit>().deleteQuestion(question.id);
        }
      },
      onUnlinkFromGroup: groupId == null
          ? null
          : () async {
              final ok = await _confirmUnlinkQuestion(context);
              if (ok && context.mounted) {
                await context.read<QuestionBankCubit>().unlinkQuestionFromGroup(
                  questionId: question.id,
                  groupId: groupId,
                );
              }
            },
    );
  }

  void _handleFilterAction(_QuestionBankFilterAction action) {
    final cubit = context.read<QuestionBankCubit>();
    switch (action.kind) {
      case _QuestionBankFilterKind.course:
        cubit.selectCourse(action.value as int?);
        break;
      case _QuestionBankFilterKind.chapter:
        cubit.setFilters(
          chapterId: action.value as int?,
          clearChapter: action.value == null,
        );
        break;
      case _QuestionBankFilterKind.group:
        cubit.setFilters(
          groupId: action.value as int?,
          clearGroup: action.value == null,
        );
        break;
      case _QuestionBankFilterKind.status:
        cubit.setFilters(
          status: action.value as QuestionBankStatus?,
          clearStatus: action.value == null,
        );
        break;
      case _QuestionBankFilterKind.type:
        cubit.setFilters(
          type: action.value as QuestionBankType?,
          clearType: action.value == null,
        );
        break;
      case _QuestionBankFilterKind.difficulty:
        cubit.setFilters(
          difficulty: action.value as QuestionBankDifficulty?,
          clearDifficulty: action.value == null,
        );
        break;
      case _QuestionBankFilterKind.bloom:
        cubit.setFilters(
          bloomLevel: action.value as BloomLevel?,
          clearBloom: action.value == null,
        );
        break;
      case _QuestionBankFilterKind.attachments:
        cubit.setFilters(
          hasAttachments: action.value as bool?,
          clearHasAttachments: action.value == null,
        );
        break;
      case _QuestionBankFilterKind.questionReset:
        cubit.setFilters(
          clearStatus: true,
          clearType: true,
          clearDifficulty: true,
          clearBloom: true,
          clearHasAttachments: true,
        );
        break;
    }
  }

  Future<bool> _confirmDeleteQuestion(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: InstructorColors.cardColor(isDark),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              l10n.qbDeleteQuestion,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              l10n.qbDeleteQuestionBody,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: InstructorColors.error,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.qbDeleteQuestion),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmUnlinkQuestion(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: InstructorColors.cardColor(isDark),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              l10n.qbRemoveFromGroup,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              l10n.qbRemoveFromGroupBody,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: InstructorColors.warning,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.qbRemoveFromGroup),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _AppBarActionButton extends StatelessWidget {
  const _AppBarActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.28 : 0.18),
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class _QuestionBankControlPanel extends StatelessWidget {
  const _QuestionBankControlPanel({
    required this.state,
    required this.searchController,
    required this.isDark,
    required this.isLoading,
    required this.onSearchChanged,
    required this.onFilterAction,
  });

  final QuestionBankState state;
  final TextEditingController searchController;
  final bool isDark;
  final bool isLoading;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_QuestionBankFilterAction> onFilterAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            cursorColor: InstructorColors.primary,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: l10n.questionBankSearchQuestionTextOnly,
              hintStyle: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: InstructorColors.surfaceColor(isDark),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: InstructorColors.borderColor(isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: InstructorColors.borderColor(isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: InstructorColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterMenuButton(
                  title: '${l10n.course} / ${l10n.chapter}',
                  subtitle: _scopeSubtitle(l10n),
                  icon: Icons.account_tree_outlined,
                  color: InstructorColors.primary,
                  isDark: isDark,
                  isActive: _scopeActiveCount > 0,
                  entries: _scopeEntries(context, l10n),
                  onSelected: onFilterAction,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterMenuButton(
                  title: '${l10n.question} ${l10n.filters}',
                  subtitle: _questionSubtitle(l10n),
                  icon: Icons.tune_rounded,
                  color: InstructorColors.teal,
                  isDark: isDark,
                  isActive: _questionActiveCount > 0,
                  entries: _questionEntries(context, l10n),
                  onSelected: onFilterAction,
                ),
              ),
            ],
          ),
          if (isLoading) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(minHeight: 3),
            ),
          ],
        ],
      ),
    );
  }

  int get _scopeActiveCount =>
      (state.selectedCourseId == null ? 0 : 1) +
      (state.selectedChapterId == null ? 0 : 1) +
      (state.selectedGroupId == null ? 0 : 1);

  int get _questionActiveCount =>
      (state.selectedStatus == null ? 0 : 1) +
      (state.selectedType == null ? 0 : 1) +
      (state.selectedDifficulty == null ? 0 : 1) +
      (state.selectedBloomLevel == null ? 0 : 1) +
      (state.hasAttachments == null ? 0 : 1);

  String _scopeSubtitle(AppLocalizations l10n) {
    final selectedCourse = state.teachingCourses
        .where((course) => course.courseId == state.selectedCourseId)
        .firstOrNull;
    final selectedChapter = state.chapters
        .where((chapter) => chapter.id == state.selectedChapterId)
        .firstOrNull;
    final selectedGroup = state.groups
        .where((group) => group.id == state.selectedGroupId)
        .firstOrNull;

    final labels = <String>[
      if (selectedCourse != null) selectedCourse.course.code,
      if (selectedChapter != null) selectedChapter.name,
      if (selectedGroup != null)
        selectedGroup.title ?? '${l10n.qbGroups} ${selectedGroup.id}',
    ];
    return labels.isEmpty ? l10n.allCourses : labels.join(' • ');
  }

  String _questionSubtitle(AppLocalizations l10n) {
    final labels = <String>[
      if (state.selectedStatus != null)
        localizedQuestionStatus(l10n, state.selectedStatus!),
      if (state.selectedType != null)
        localizedQuestionType(l10n, state.selectedType!),
      if (state.selectedDifficulty != null)
        localizedDifficulty(l10n, state.selectedDifficulty!),
      if (state.selectedBloomLevel != null)
        localizedBloomLevel(l10n, state.selectedBloomLevel!),
      if (state.hasAttachments != null)
        state.hasAttachments! ? l10n.yes : l10n.no,
    ];
    return labels.isEmpty ? l10n.allStates : labels.join(' • ');
  }

  List<PopupMenuEntry<_QuestionBankFilterAction>> _scopeEntries(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      _menuHeader(l10n.course),
      _menuOption(
        label: l10n.allCourses,
        selected: state.selectedCourseId == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.course,
          null,
        ),
      ),
      ...state.teachingCourses.map(
        (course) => _menuOption(
          label: '${course.course.code} - ${course.course.name}',
          selected: state.selectedCourseId == course.courseId,
          action: _QuestionBankFilterAction(
            _QuestionBankFilterKind.course,
            course.courseId,
          ),
        ),
      ),
      _menuDivider(),
      _menuHeader(l10n.chapter),
      _menuOption(
        label: l10n.allChapters,
        selected: state.selectedChapterId == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.chapter,
          null,
        ),
      ),
      ...state.chapters.map(
        (chapter) => _menuOption(
          label: chapter.name,
          selected: state.selectedChapterId == chapter.id,
          action: _QuestionBankFilterAction(
            _QuestionBankFilterKind.chapter,
            chapter.id,
          ),
        ),
      ),
      _menuDivider(),
      _menuHeader(l10n.qbGroups),
      _menuOption(
        label: l10n.allStates,
        selected: state.selectedGroupId == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.group,
          null,
        ),
      ),
      ...state.groups.map(
        (group) => _menuOption(
          label: group.title ?? '${l10n.qbGroups} ${group.id}',
          selected: state.selectedGroupId == group.id,
          action: _QuestionBankFilterAction(
            _QuestionBankFilterKind.group,
            group.id,
          ),
        ),
      ),
    ];
  }

  List<PopupMenuEntry<_QuestionBankFilterAction>> _questionEntries(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      _menuOption(
        label: l10n.clearFilters,
        icon: Icons.filter_alt_off_rounded,
        selected: _questionActiveCount == 0,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.questionReset,
          null,
        ),
      ),
      _menuDivider(),
      _menuHeader(l10n.status),
      _menuOption(
        label: l10n.allStates,
        selected: state.selectedStatus == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.status,
          null,
        ),
      ),
      ...QuestionBankStatus.values.map(
        (status) => _menuOption(
          label: localizedQuestionStatus(l10n, status),
          selected: state.selectedStatus == status,
          action: _QuestionBankFilterAction(
            _QuestionBankFilterKind.status,
            status,
          ),
        ),
      ),
      _menuDivider(),
      _menuHeader(l10n.type),
      _menuOption(
        label: l10n.allStates,
        selected: state.selectedType == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.type,
          null,
        ),
      ),
      ...QuestionBankType.values.map(
        (type) => _menuOption(
          label: localizedQuestionType(l10n, type),
          selected: state.selectedType == type,
          action: _QuestionBankFilterAction(_QuestionBankFilterKind.type, type),
        ),
      ),
      _menuDivider(),
      _menuHeader(l10n.difficulty),
      _menuOption(
        label: l10n.allStates,
        selected: state.selectedDifficulty == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.difficulty,
          null,
        ),
      ),
      ...QuestionBankDifficulty.values.map(
        (difficulty) => _menuOption(
          label: localizedDifficulty(l10n, difficulty),
          selected: state.selectedDifficulty == difficulty,
          action: _QuestionBankFilterAction(
            _QuestionBankFilterKind.difficulty,
            difficulty,
          ),
        ),
      ),
      _menuDivider(),
      _menuHeader(l10n.bloomLevel),
      _menuOption(
        label: l10n.allStates,
        selected: state.selectedBloomLevel == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.bloom,
          null,
        ),
      ),
      ...BloomLevel.values.map(
        (level) => _menuOption(
          label: localizedBloomLevel(l10n, level),
          selected: state.selectedBloomLevel == level,
          action: _QuestionBankFilterAction(
            _QuestionBankFilterKind.bloom,
            level,
          ),
        ),
      ),
      _menuDivider(),
      _menuHeader(l10n.attachments),
      _menuOption(
        label: l10n.allStates,
        selected: state.hasAttachments == null,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.attachments,
          null,
        ),
      ),
      _menuOption(
        label: l10n.yes,
        selected: state.hasAttachments == true,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.attachments,
          true,
        ),
      ),
      _menuOption(
        label: l10n.no,
        selected: state.hasAttachments == false,
        action: const _QuestionBankFilterAction(
          _QuestionBankFilterKind.attachments,
          false,
        ),
      ),
    ];
  }

  PopupMenuItem<_QuestionBankFilterAction> _menuOption({
    required String label,
    required bool selected,
    required _QuestionBankFilterAction action,
    IconData? icon,
  }) {
    return PopupMenuItem<_QuestionBankFilterAction>(
      value: action,
      child: Row(
        children: [
          Icon(
            icon ??
                (selected ? Icons.check_circle_rounded : Icons.circle_outlined),
            size: 18,
            color: selected
                ? InstructorColors.primary
                : InstructorColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? InstructorColors.primary
                    : InstructorColors.textPrimaryColor(isDark),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_QuestionBankFilterAction> _menuHeader(String label) {
    return PopupMenuItem<_QuestionBankFilterAction>(
      enabled: false,
      height: 30,
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

  PopupMenuDivider _menuDivider() => const PopupMenuDivider(height: 8);
}

class _FilterMenuButton extends StatelessWidget {
  const _FilterMenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.isActive,
    required this.entries,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool isActive;
  final List<PopupMenuEntry<_QuestionBankFilterAction>> entries;
  final ValueChanged<_QuestionBankFilterAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_QuestionBankFilterAction>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 340),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => entries,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color : InstructorColors.borderColor(isDark),
            width: isActive ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? color
                          : InstructorColors.textSecondaryColor(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: InstructorColors.textSecondaryColor(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({required this.state, required this.isDark});

  final QuestionBankState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<QuestionBankCubit>();
    final visibleIds = state.questions.map((question) => question.id).toSet();
    final visibleCount = visibleIds.length;
    final selectedVisibleCount = state.isAllMatchingQuestionsSelected
        ? visibleIds
              .where((id) => !state.excludedQuestionIds.contains(id))
              .length
        : visibleIds.where(state.selectedQuestionIds.contains).length;
    final selectedQuestions = state.questions
        .where((question) => cubit.isQuestionSelected(question.id))
        .toList();
    final allVisibleSelected =
        visibleCount > 0 && selectedVisibleCount == visibleCount;
    final canSelectAllMatching =
        !state.isAllMatchingQuestionsSelected &&
        allVisibleSelected &&
        state.total > visibleCount;
    final canAct = state.hasSelectedQuestions && !state.isMutating;
    final canRestore =
        canAct &&
        (state.isAllMatchingQuestionsSelected
            ? state.selectedStatus == QuestionBankStatus.archived
            : selectedQuestions.isNotEmpty &&
                  selectedQuestions.every(
                    (question) =>
                        question.status == QuestionBankStatus.archived,
                  ));
    final actions = <_BatchAction>[
      _BatchAction(
        label: l10n.submitForReview,
        icon: Icons.mark_email_read_outlined,
        color: InstructorColors.primary,
        onPressed: canAct
            ? () => cubit.batchStatusAction('submit-for-review')
            : null,
      ),
      _BatchAction(
        label: l10n.qbApprove,
        icon: Icons.verified_rounded,
        color: InstructorColors.success,
        onPressed: canAct ? () => cubit.batchStatusAction('approve') : null,
      ),
      _BatchAction(
        label: l10n.archive,
        icon: Icons.archive_outlined,
        color: InstructorColors.orange,
        onPressed: canAct ? () => cubit.batchStatusAction('archive') : null,
      ),
      _BatchAction(
        label: l10n.delete,
        icon: Icons.delete_outline_rounded,
        color: InstructorColors.error,
        onPressed: canAct
            ? () => _confirmAndDeleteSelected(context, cubit, state)
            : null,
      ),
      _BatchAction(
        label: l10n.restore,
        icon: Icons.restore_rounded,
        color: InstructorColors.teal,
        onPressed: canRestore ? () => cubit.batchStatusAction('restore') : null,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: InstructorColors.primary.withValues(
            alpha: isDark ? 0.34 : 0.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.11,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: InstructorColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.qbSelectedCount(state.selectedQuestionCount),
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
                      state.isAllMatchingQuestionsSelected
                          ? l10n.qbChapterQuestionCount(state.total)
                          : l10n.qbChapterQuestionCount(visibleCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SelectAllButton(
                label: l10n.taNotifSelectAll,
                isDark: isDark,
                isSelected: allVisibleSelected,
                isEnabled: visibleCount > 0,
                onChanged: (value) =>
                    cubit.setCurrentQuestionsSelected(value ?? false),
              ),
            ],
          ),
          if (canSelectAllMatching) ...[
            const SizedBox(height: 10),
            _SelectAllMatchingButton(
              count: state.total,
              isDark: isDark,
              onPressed: cubit.selectAllMatchingQuestions,
            ),
          ] else if (state.isAllMatchingQuestionsSelected) ...[
            const SizedBox(height: 10),
            _AllMatchingSelectedNotice(count: state.selectedQuestionCount),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in actions)
                _BatchActionPill(action: action, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeleteSelected(
    BuildContext context,
    QuestionBankCubit cubit,
    QuestionBankState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: InstructorColors.cardColor(isDark),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              l10n.qbDeleteQuestion,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              'Delete ${l10n.qbSelectedCount(state.selectedQuestionCount).toLowerCase()}? This will archive and remove them from the question bank list.',
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: InstructorColors.error,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (ok && context.mounted) {
      await cubit.batchDeleteQuestions();
    }
  }
}

class _BatchMutationOverlay extends StatelessWidget {
  const _BatchMutationOverlay({
    required this.action,
    required this.selectedCount,
    required this.isDark,
  });

  final String action;
  final int selectedCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actionLabel = _labelForAction(l10n, action);

    return AbsorbPointer(
      child: Container(
        color: Colors.black.withValues(alpha: isDark ? 0.48 : 0.32),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.96, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: InstructorColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: InstructorColors.primary.withValues(
                    alpha: isDark ? 0.35 : 0.18,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.14),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: InstructorColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Applying $actionLabel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedCount > 0
                        ? 'Your action is being applied to ${l10n.qbSelectedCount(selectedCount).toLowerCase()}. Please wait until all selected questions are updated.'
                        : 'Your action is being applied. Please wait until the question bank is updated.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: InstructorColors.textSecondaryColor(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _labelForAction(AppLocalizations l10n, String action) {
    switch (action) {
      case 'submit-for-review':
        return l10n.submitForReview.toLowerCase();
      case 'approve':
        return l10n.qbApprove.toLowerCase();
      case 'archive':
        return l10n.archive.toLowerCase();
      case 'restore':
        return l10n.restore.toLowerCase();
      case 'delete':
        return l10n.qbDeleteQuestion.toLowerCase();
      case 'unlink':
        return l10n.qbRemoveFromGroup.toLowerCase();
      default:
        return 'selected action';
    }
  }
}

class _SelectAllMatchingButton extends StatelessWidget {
  const _SelectAllMatchingButton({
    required this.count,
    required this.isDark,
    required this.onPressed,
  });

  final int count;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: InstructorColors.primary,
        side: BorderSide(
          color: InstructorColors.primary.withValues(alpha: 0.42),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: InstructorColors.primary.withValues(
          alpha: isDark ? 0.1 : 0.04,
        ),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.select_all_rounded, size: 18),
      label: Text(
        'Select all $count matching questions',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _AllMatchingSelectedNotice extends StatelessWidget {
  const _AllMatchingSelectedNotice({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: isDark ? 0.16 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: InstructorColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.done_all_rounded,
            color: InstructorColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'All $count matching questions are selected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectAllButton extends StatelessWidget {
  const _SelectAllButton({
    required this.label,
    required this.isDark,
    required this.isSelected,
    required this.isEnabled,
    required this.onChanged,
  });

  final String label;
  final bool isDark;
  final bool isSelected;
  final bool isEnabled;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? () => onChanged(!isSelected) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 12, 6),
        decoration: BoxDecoration(
          color: InstructorColors.primary.withValues(
            alpha: isDark ? 0.18 : 0.08,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: InstructorColors.primary.withValues(
              alpha: isSelected ? 0.55 : 0.18,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: isEnabled ? onChanged : null,
              activeColor: InstructorColors.primary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              label,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchAction {
  const _BatchAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
}

class _BatchActionPill extends StatelessWidget {
  const _BatchActionPill({required this.action, required this.isDark});

  final _BatchAction action;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final enabled = action.onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: enabled ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: isDark ? 0.2 : 0.11),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: action.color.withValues(alpha: isDark ? 0.34 : 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, color: action.color, size: 18),
                const SizedBox(width: 8),
                Text(
                  action.label,
                  style: TextStyle(
                    color: enabled
                        ? InstructorColors.textPrimaryColor(isDark)
                        : InstructorColors.textSecondaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionBankFabCluster extends StatelessWidget {
  const _QuestionBankFabCluster({
    required this.isOpen,
    required this.isDark,
    required this.onToggleOpen,
    required this.onCreateQuestion,
    required this.onBulkCreate,
    required this.onCreateGroup,
  });

  final bool isOpen;
  final bool isDark;
  final VoidCallback onToggleOpen;
  final VoidCallback onCreateQuestion;
  final VoidCallback onBulkCreate;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = <_FabAction>[
      _FabAction(
        label: l10n.questionBankCreateQuestion,
        icon: Icons.add_rounded,
        color: InstructorColors.primary,
        onTap: onCreateQuestion,
      ),
      _FabAction(
        label: l10n.questionBankBulkCreate,
        icon: Icons.playlist_add_rounded,
        color: InstructorColors.teal,
        onTap: onBulkCreate,
      ),
      _FabAction(
        label: l10n.qbCreateGroup,
        icon: Icons.create_new_folder_outlined,
        color: InstructorColors.accent,
        onTap: onCreateGroup,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isOpen
              ? Column(
                  key: const ValueKey('open-question-bank-actions'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...actions.map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _ExpandedFabAction(
                          action: action,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        FloatingActionButton.extended(
          onPressed: onToggleOpen,
          backgroundColor: InstructorColors.primary,
          foregroundColor: Colors.white,
          icon: AnimatedRotation(
            turns: isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 180),
            child: Icon(isOpen ? Icons.close_rounded : Icons.add_rounded),
          ),
          label: Text(isOpen ? l10n.cancel : l10n.actions),
        ),
      ],
    );
  }
}

class _ExpandedFabAction extends StatelessWidget {
  const _ExpandedFabAction({required this.action, required this.isDark});

  final _FabAction action;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: action.color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
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
                  color: action.color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 18),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190),
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FabAction {
  const _FabAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _QuestionFeedEntry {
  const _QuestionFeedEntry.single(this.question) : group = null;
  const _QuestionFeedEntry.group(this.group) : question = null;

  final QuestionBankQuestionModel? question;
  final _QuestionGroupFeedSection? group;

  static List<_QuestionFeedEntry> fromState(QuestionBankState state) {
    final groupedQuestions = <int, List<QuestionBankQuestionModel>>{};
    final groupSummaries = <int, QuestionBankGroupSummaryModel>{};

    for (final question in state.questions) {
      if (question.groups.isEmpty) continue;
      final summary = question.groups.first;
      groupedQuestions
          .putIfAbsent(summary.groupId, () => <QuestionBankQuestionModel>[])
          .add(question);
      groupSummaries.putIfAbsent(summary.groupId, () => summary);
    }

    for (final entry in groupedQuestions.entries) {
      entry.value.sort((a, b) {
        final aOrder = _itemOrderForGroup(a, entry.key);
        final bOrder = _itemOrderForGroup(b, entry.key);
        return aOrder.compareTo(bOrder);
      });
    }

    final seenGroups = <int>{};
    final feed = <_QuestionFeedEntry>[];
    for (final question in state.questions) {
      if (question.groups.isEmpty) {
        feed.add(_QuestionFeedEntry.single(question));
        continue;
      }

      final groupId = question.groups.first.groupId;
      if (!seenGroups.add(groupId)) continue;

      final summary = groupSummaries[groupId]!;
      final model = _groupModelFor(state.groups, groupId);
      final course = _courseFor(
        state.teachingCourses,
        model?.courseId ?? summary.courseId,
      );
      feed.add(
        _QuestionFeedEntry.group(
          _QuestionGroupFeedSection(
            summary: summary,
            model: model,
            course: course,
            questions: groupedQuestions[groupId] ?? const [],
          ),
        ),
      );
    }

    return feed;
  }

  static int _itemOrderForGroup(
    QuestionBankQuestionModel question,
    int groupId,
  ) {
    for (final group in question.groups) {
      if (group.groupId == groupId) return group.itemOrder;
    }
    return question.id;
  }

  static QuestionBankGroupModel? _groupModelFor(
    List<QuestionBankGroupModel> groups,
    int groupId,
  ) {
    for (final group in groups) {
      if (group.id == groupId) return group;
    }
    return null;
  }

  static TeachingCourseModel? _courseFor(
    List<TeachingCourseModel> courses,
    int courseId,
  ) {
    for (final course in courses) {
      if (course.courseId == courseId) return course;
    }
    return null;
  }
}

class _QuestionGroupFeedSection {
  const _QuestionGroupFeedSection({
    required this.summary,
    required this.model,
    required this.course,
    required this.questions,
  });

  final QuestionBankGroupSummaryModel summary;
  final QuestionBankGroupModel? model;
  final TeachingCourseModel? course;
  final List<QuestionBankQuestionModel> questions;

  int get groupId => summary.groupId;
  QuestionGroupType get groupType => model?.groupType ?? summary.groupType;
  String? get title => model?.title ?? summary.title;
  String? get sharedPrompt => model?.sharedPrompt ?? summary.sharedPrompt;
  int get courseId => model?.courseId ?? summary.courseId;
}

class _QuestionGroupQuestionSection extends StatelessWidget {
  const _QuestionGroupQuestionSection({
    super.key,
    required this.group,
    required this.isDark,
    required this.isCollapsed,
    required this.canCollapse,
    required this.onViewGroup,
    required this.onEditGroup,
    required this.onAddGroupedQuestions,
    required this.onAddExistingQuestions,
    required this.onToggleCollapsed,
    required this.questionBuilder,
  });

  final _QuestionGroupFeedSection group;
  final bool isDark;
  final bool isCollapsed;
  final bool canCollapse;
  final VoidCallback onViewGroup;
  final VoidCallback onEditGroup;
  final VoidCallback onAddGroupedQuestions;
  final VoidCallback onAddExistingQuestions;
  final VoidCallback onToggleCollapsed;
  final Widget Function(QuestionBankQuestionModel question, int groupId)
  questionBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _groupColor(group.groupId);
    final title = (group.title?.trim().isNotEmpty ?? false)
        ? group.title!.trim()
        : questionTextForDisplay(
            group.sharedPrompt,
            fallback: '${l10n.qbGroups} #${group.groupId}',
          );
    final courseCode = group.course?.course.code.trim() ?? '';
    final courseName = group.course?.course.name.trim() ?? '';
    final courseLabel = [
      if (courseCode.isNotEmpty) courseCode,
      if (courseName.isNotEmpty) courseName,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.055),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canCollapse ? onToggleCollapsed : null,
              onLongPress: () => _showGroupActions(context, title, color),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.24 : 0.14),
                      InstructorColors.cyan.withValues(
                        alpha: isDark ? 0.16 : 0.08,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(24),
                    bottom: isCollapsed
                        ? const Radius.circular(24)
                        : Radius.zero,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _groupTypeIcon(group.groupType),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                localizedGroupType(l10n, group.groupType),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              _QuestionGroupCountPill(
                                label: l10n.qbChapterQuestionCount(
                                  group.questions.length,
                                ),
                                color: color,
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.16,
                            ),
                          ),
                          if (courseLabel.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              courseLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: InstructorColors.textSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _QuestionGroupHeaderActions(
                      isDark: isDark,
                      isCollapsed: isCollapsed,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isCollapsed
                ? const SizedBox.shrink(key: ValueKey('collapsed'))
                : Padding(
                    key: const ValueKey('expanded'),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < group.questions.length;
                          index++
                        )
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == group.questions.length - 1
                                  ? 0
                                  : 10,
                            ),
                            child: questionBuilder(
                              group.questions[index],
                              group.groupId,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showGroupActions(BuildContext context, String title, Color accent) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _QuestionGroupActionSheet(
          title: title,
          groupType: group.groupType,
          questionCount: group.questions.length,
          accent: accent,
          isDark: isDark,
          onViewDetails: () {
            Navigator.of(sheetContext).pop();
            onViewGroup();
          },
          onEditGroup: () {
            Navigator.of(sheetContext).pop();
            onEditGroup();
          },
          onAddGroupedQuestions: () {
            Navigator.of(sheetContext).pop();
            onAddGroupedQuestions();
          },
          onAddExistingQuestions: () {
            Navigator.of(sheetContext).pop();
            onAddExistingQuestions();
          },
        );
      },
    );
  }

  static Color _groupColor(int groupId) {
    const colors = <Color>[
      InstructorColors.cyan,
      InstructorColors.accent,
      InstructorColors.teal,
      InstructorColors.orange,
      InstructorColors.primary,
      InstructorColors.pink,
    ];
    return colors[groupId.abs() % colors.length];
  }

  static IconData _groupTypeIcon(QuestionGroupType type) {
    switch (type) {
      case QuestionGroupType.passage:
        return Icons.menu_book_outlined;
      case QuestionGroupType.caseStudy:
        return Icons.cases_outlined;
      case QuestionGroupType.imageSet:
        return Icons.photo_library_outlined;
      case QuestionGroupType.multipart:
        return Icons.account_tree_outlined;
      case QuestionGroupType.other:
        return Icons.folder_copy_outlined;
    }
  }
}

class _QuestionGroupCountPill extends StatelessWidget {
  const _QuestionGroupCountPill({
    required this.label,
    required this.color,
    required this.isDark,
  });

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.9) : color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _QuestionGroupHeaderActions extends StatelessWidget {
  const _QuestionGroupHeaderActions({
    required this.isDark,
    required this.isCollapsed,
  });

  final bool isDark;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(
          isDark,
        ).withValues(alpha: isDark ? 0.35 : 0.78),
        borderRadius: BorderRadius.circular(13),
      ),
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 180),
        turns: isCollapsed ? 0 : 0.5,
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: InstructorColors.primary,
          size: 23,
        ),
      ),
    );
  }
}

class _QuestionGroupActionSheet extends StatelessWidget {
  const _QuestionGroupActionSheet({
    required this.title,
    required this.groupType,
    required this.questionCount,
    required this.accent,
    required this.isDark,
    required this.onViewDetails,
    required this.onEditGroup,
    required this.onAddGroupedQuestions,
    required this.onAddExistingQuestions,
  });

  final String title;
  final QuestionGroupType groupType;
  final int questionCount;
  final Color accent;
  final bool isDark;
  final VoidCallback onViewDetails;
  final VoidCallback onEditGroup;
  final VoidCallback onAddGroupedQuestions;
  final VoidCallback onAddExistingQuestions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textColor = InstructorColors.textPrimaryColor(isDark);
    final secondaryText = InstructorColors.textSecondaryColor(isDark);

    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.16),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 4,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: secondaryText.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _QuestionGroupQuestionSection._groupTypeIcon(groupType),
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.questionBankGroupDetails,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$title • ${l10n.qbChapterQuestionCount(questionCount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _GroupSheetActionTile(
            label: l10n.viewDetails,
            icon: Icons.visibility_outlined,
            color: InstructorColors.cyan,
            isDark: isDark,
            onTap: onViewDetails,
          ),
          _GroupSheetActionTile(
            label: l10n.qbEditGroup,
            icon: Icons.edit_rounded,
            color: InstructorColors.primary,
            isDark: isDark,
            onTap: onEditGroup,
          ),
          _GroupSheetActionTile(
            label: l10n.qbGroupedBatchCreate,
            icon: Icons.playlist_add_rounded,
            color: InstructorColors.accent,
            isDark: isDark,
            onTap: onAddGroupedQuestions,
          ),
          _GroupSheetActionTile(
            label: l10n.qbAddExistingQuestions,
            icon: Icons.add_link_rounded,
            color: InstructorColors.teal,
            isDark: isDark,
            onTap: onAddExistingQuestions,
          ),
        ],
      ),
    );
  }
}

class _GroupSheetActionTile extends StatelessWidget {
  const _GroupSheetActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: InstructorColors.textSecondaryColor(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: InstructorColors.error,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _QuestionBankWalkthroughDemoFeed extends StatelessWidget {
  const _QuestionBankWalkthroughDemoFeed({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IgnorePointer(
      child: Column(
        children: [
          _QuestionBankWalkthroughDemoCard(
            isDark: isDark,
            icon: Icons.check_circle_rounded,
            accent: InstructorColors.success,
            title: l10n.instructorWalkthroughQuestionBankDemoTitleOne,
            body: l10n.instructorWalkthroughQuestionBankDemoBodyOne,
            chips: [l10n.approved, l10n.medium, l10n.multipleChoice],
          ),
          const SizedBox(height: 12),
          _QuestionBankWalkthroughDemoCard(
            isDark: isDark,
            icon: Icons.account_tree_rounded,
            accent: InstructorColors.cyan,
            title: l10n.instructorWalkthroughQuestionBankDemoTitleTwo,
            body: l10n.instructorWalkthroughQuestionBankDemoBodyTwo,
            chips: [l10n.qbGroups, l10n.qbUnderReview, l10n.essay],
          ),
        ],
      ),
    );
  }
}

class _QuestionBankWalkthroughDemoCard extends StatelessWidget {
  const _QuestionBankWalkthroughDemoCard({
    required this.isDark,
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.chips,
  });

  final bool isDark;
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chips
                      .map(
                        (chip) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            chip,
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_horiz_rounded,
            color: InstructorColors.textSecondaryColor(isDark),
          ),
        ],
      ),
    );
  }
}

enum _QuestionBankFilterKind {
  course,
  chapter,
  group,
  status,
  type,
  difficulty,
  bloom,
  attachments,
  questionReset,
}

class _QuestionBankFilterAction {
  const _QuestionBankFilterAction(this.kind, this.value);

  final _QuestionBankFilterKind kind;
  final Object? value;
}
