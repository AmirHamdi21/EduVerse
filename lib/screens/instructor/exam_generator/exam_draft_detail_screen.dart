import 'dart:convert';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/exam_generator/exam_draft_editor_cubit.dart';
import '../../../bloc/instructor/exam_generator/exam_draft_editor_state.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../../../models/exams/exam_draft_item_update_payload.dart';
import '../../../models/exams/exam_draft_model.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../../../models/exams/exam_draft_section_payload.dart';
import '../../../models/exams/exam_draft_validation_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';
import '../../../widgets/instructor/question_bank/question_bank_localized_labels.dart';
import '../../../widgets/instructor/question_bank/question_text_renderer.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/instructor_modern_tab_strip.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

class ExamDraftDetailScreen extends StatelessWidget {
  const ExamDraftDetailScreen({super.key, required this.draftId});

  final int draftId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamDraftEditorCubit(
        examGeneratorService: ExamGeneratorService(
          coreApiClient: CoreApiClient(),
        ),
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..loadDraft(draftId),
      child: const _ExamDraftDetailView(),
    );
  }
}

class _ExamDraftDetailView extends StatefulWidget {
  const _ExamDraftDetailView();

  @override
  State<_ExamDraftDetailView> createState() => _ExamDraftDetailViewState();
}

class _ExamDraftDetailViewState extends State<_ExamDraftDetailView> {
  int _tab = 0;
  ExamDraftSectionModel? _editingSection;
  ExamDraftItemModel? _editingItem;
  bool _showSectionEditor = false;
  bool _showCandidatePicker = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _candidatePickerKey = GlobalKey();
  final Set<int> _selectedItemIds = <int>{};
  bool _isMovingItems = false;
  bool _isSavingSection = false;
  int _movingItemCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () =>
              safeFeatureBack(context, '/instructor/exam-generator'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(l10n.examDraftDetails),
        actions: [
          BlocBuilder<ExamDraftEditorCubit, ExamDraftEditorState>(
            builder: (context, state) {
              final draft = state.draft;
              if (_hasSavedExam(draft)) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: IconButton.filledTonal(
                    tooltip: l10n.examOpenSavedExam,
                    onPressed: () => context.go(
                      '/instructor/exam-generator/exams/${draft!.finalizedExamId}',
                    ),
                    icon: const Icon(Icons.fact_check_outlined),
                  ),
                );
              }
              if (draft?.status == ExamDraftStatus.finalized) {
                return const SizedBox.shrink();
              }
              final canSave =
                  draft != null && draft.isEditable && !state.isMutating;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: IconButton.filledTonal(
                  tooltip: l10n.save,
                  onPressed: canSave ? () => _save(context) : null,
                  icon: const Icon(Icons.save_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ExamDraftEditorCubit, ExamDraftEditorState>(
        listenWhen: (previous, current) {
          final previousMessage =
              previous.errorMessage ?? previous.actionMessage;
          final currentMessage = current.errorMessage ?? current.actionMessage;
          return currentMessage != null && currentMessage != previousMessage;
        },
        listener: (context, state) {
          final message = state.errorMessage ?? state.actionMessage;
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedExamMessage(l10n, message))),
            );
          }
        },
        builder: (context, state) {
          final draft = state.draft;
          if (state.isLoading || draft == null) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: ExamGeneratorSkeletons(itemCount: 4),
            );
          }
          if (draft.status == ExamDraftStatus.finalized) {
            return _FinalizedDraftHandoff(
              draft: draft,
              isMutating: state.isMutating,
              onOpenSavedExam: draft.finalizedExamId == null
                  ? null
                  : () => context.go(
                      '/instructor/exam-generator/exams/${draft.finalizedExamId}',
                    ),
              onCreateEditableCopy: () => _duplicateFinalizedDraft(context),
            );
          }
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
            children: [
              ExamGeneratorHeroHeader(
                title: draft.title,
                subtitle: draft.isEditable
                    ? l10n.examDraftEditable
                    : l10n.examDraftNotEditable,
                stats: {
                  l10n.status: localizedDraftStatus(l10n, draft.status),
                  l10n.questions: draft.items.length.toString(),
                  l10n.sections: draft.sections.length.toString(),
                  l10n.totalMarks: draft.totalMarks?.toString() ?? '-',
                },
                isDark: isDark,
              ),
              if (draft.isEditable) ...[
                const SizedBox(height: 16),
                _ExpiryBanner(expiresAt: draft.expiresAt),
              ],
              const SizedBox(height: 16),
              InstructorModernTabStrip(
                selectedIndex: _tab,
                onChanged: (value) => setState(() => _tab = value),
                tabs: [
                  InstructorModernTabItem(
                    icon: Icons.dashboard_outlined,
                    label: l10n.examDraftOverview,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.construction_rounded,
                    label: l10n.examDraftBuild,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.swap_vert_rounded,
                    label: l10n.examDraftReorder,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.checklist_rounded,
                    label: l10n.examDraftReview,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _tabContent(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _tabContent(BuildContext context, ExamDraftEditorState state) {
    final l10n = AppLocalizations.of(context);
    final draft = state.draft!;
    switch (_tab) {
      case 1:
        final overrideReasonsByQuestionId = _candidateOverrideReasons(
          draft,
          state.candidateQuestions,
          l10n,
          state.candidateChapters,
          state.candidateGroups,
        );
        return _BuildTab(
          draft: draft,
          state: state,
          editingSection: _editingSection,
          editingItem: _editingItem,
          showSectionEditor: _showSectionEditor,
          showCandidatePicker: _showCandidatePicker,
          isSavingSection: _isSavingSection,
          selectedItemIds: _selectedItemIds,
          onShowSectionEditor: () => setState(() {
            _editingSection = null;
            _showSectionEditor = true;
          }),
          onCancelSectionEditor: () => setState(() {
            _editingSection = null;
            _showSectionEditor = false;
          }),
          onSubmitSection: (payload) async {
            setState(() => _isSavingSection = true);
            final saved = await context
                .read<ExamDraftEditorCubit>()
                .upsertSection(
                  sectionId: _editingSection?.id,
                  payload: payload,
                );
            if (!mounted) return;
            setState(() {
              _isSavingSection = false;
              if (saved) {
                _editingSection = null;
                _showSectionEditor = false;
              }
            });
          },
          onEditSection: (section) => setState(() {
            _editingSection = section;
            _showSectionEditor = true;
          }),
          onDeleteSection: (section) async {
            final confirmed = await _confirm(
              context,
              l10n.examDeleteSection,
              l10n.examDeleteSectionUnassigns,
            );
            if (confirmed && context.mounted) {
              context.read<ExamDraftEditorCubit>().deleteSection(section.id);
            }
          },
          onNormalizeSection: (section) =>
              context.read<ExamDraftEditorCubit>().normalizeSectionMarks(
                section.id,
                totalMarks: section.totalMarks,
              ),
          onReshuffleSection: (section) =>
              context.read<ExamDraftEditorCubit>().reshuffleSection(section.id),
          onUnassignItem: (item) =>
              _moveItemsToSection(context, [item.id], null),
          onCancelItemEditor: () => setState(() => _editingItem = null),
          onSubmitItem: (payload) {
            if (_editingItem == null) return;
            context.read<ExamDraftEditorCubit>().updateItem(
              itemId: _editingItem!.id,
              payload: payload,
            );
            setState(() => _editingItem = null);
          },
          moveSelectedBar: draft.isEditable
              ? _MoveSelectedBar(
                  sections: draft.sections,
                  selectedCount: _selectedItemIds.length,
                  isMoving: _isMovingItems,
                  movingCount: _movingItemCount,
                  onMove: (sectionId) => _moveItemsToSection(
                    context,
                    _selectedItemIds.toList(),
                    sectionId,
                  ),
                )
              : null,
          itemCards: _groupedItemCards(
            context,
            draft.items.where((item) => item.draftSectionId == null).toList(),
            draft.sections,
            draft.isEditable,
            emptyTitle: l10n.examAllQuestionsAssigned,
            emptyMessage: l10n.examAllQuestionsAssignedHint,
          ),
          candidatePicker: _showCandidatePicker
              ? KeyedSubtree(
                  key: _candidatePickerKey,
                  child: ExamCandidateQuestionPicker(
                    questions: state.candidateQuestions,
                    existingQuestionIds: _draftQuestionIds(draft),
                    questionsNeedingOverride: overrideReasonsByQuestionId.keys
                        .toSet(),
                    overrideReasonsByQuestionId: overrideReasonsByQuestionId,
                    chapters: state.candidateChapters,
                    groups: state.candidateGroups,
                    hasMore: state.candidateHasMore,
                    isLoading: state.isLoadingCandidates,
                    onFiltersChanged:
                        ({
                          chapterId,
                          groupId,
                          questionType,
                          difficulty,
                          bloomLevel,
                          search,
                        }) {
                          context
                              .read<ExamDraftEditorCubit>()
                              .loadCandidateQuestions(
                                chapterId: chapterId,
                                groupId: groupId,
                                questionType: questionType,
                                difficulty: difficulty,
                                bloomLevel: bloomLevel,
                                search: search,
                              );
                        },
                    onLoadMore: () => context
                        .read<ExamDraftEditorCubit>()
                        .loadMoreCandidateQuestions(),
                    onSelected: (question) {
                      final replacing = _editingItem;
                      if (replacing == null) {
                        _addQuestionWithPreflight(
                          context,
                          draft,
                          question,
                          state.candidateChapters,
                          state.candidateGroups,
                        );
                      } else {
                        _replaceQuestion(context, replacing, question.id);
                      }
                    },
                  ),
                )
              : null,
          onShowCandidatePicker: () => _showQuestionPicker(context),
          onHideCandidatePicker: () =>
              setState(() => _showCandidatePicker = false),
        );
      case 2:
        return Column(
          children: [
            _TabIntro(
              icon: Icons.swap_vert_rounded,
              title: l10n.examDraftReorder,
              message: l10n.examDraftReorderHint,
              color: InstructorColors.accent,
            ),
            const SizedBox(height: 12),
            ExamDraftItemReorderList(
              items: draft.items,
              sections: draft.sections,
              onReorder: context.read<ExamDraftEditorCubit>().reorderItems,
            ),
          ],
        );
      case 3:
        return _ReviewTab(
          state: state,
          onRegenerate: () async {
            final draftId = await context
                .read<ExamDraftEditorCubit>()
                .regenerateDraft();
            if (draftId != null && context.mounted) {
              context.go('/instructor/exam-generator/drafts/$draftId');
            }
          },
        );
      default:
        return _OverviewTab(state: state);
    }
  }

  Future<void> _moveItemsToSection(
    BuildContext context,
    List<int> itemIds,
    int? sectionId,
  ) async {
    if (itemIds.isEmpty || _isMovingItems) return;
    setState(() {
      _isMovingItems = true;
      _movingItemCount = itemIds.length;
      _selectedItemIds.removeAll(itemIds);
    });
    try {
      await context.read<ExamDraftEditorCubit>().moveItemsToSection(
        itemIds,
        sectionId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMovingItems = false;
          _movingItemCount = 0;
        });
      }
    }
  }

  Future<void> _showQuestionPicker(BuildContext context) async {
    final cubit = context.read<ExamDraftEditorCubit>();
    await cubit.loadCandidateQuestions();
    if (!mounted) return;
    setState(() {
      _showCandidatePicker = true;
      _tab = 1;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final pickerContext = _candidatePickerKey.currentContext;
    if (pickerContext != null && pickerContext.mounted) {
      await Scrollable.ensureVisible(
        pickerContext,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.04,
      );
    } else if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _itemCard(
    BuildContext context,
    ExamDraftItemModel item,
    List<ExamDraftSectionModel> sections,
    bool canEdit, {
    bool selectable = true,
    VoidCallback? onUnassign,
  }) {
    final selected = _selectedItemIds.contains(item.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canEdit && selectable)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 18, end: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedItemIds.remove(item.id);
                    } else {
                      _selectedItemIds.add(item.id);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? InstructorColors.primary
                        : InstructorColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? InstructorColors.primary
                          : InstructorColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_task_rounded,
                    color: selected ? Colors.white : InstructorColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ExamDraftItemCard(
              item: item,
              orderNumber: item.itemOrder + 1,
              onOpenSource: () =>
                  context.push('/instructor/question-bank/${item.questionId}'),
              onEditSource: () => _confirmEditSource(context, item.questionId),
              onEdit: canEdit
                  ? () => setState(() => _editingItem = item)
                  : null,
              onReplace: canEdit
                  ? () async {
                      await context
                          .read<ExamDraftEditorCubit>()
                          .loadCandidateQuestions();
                      setState(() {
                        _editingItem = item;
                        _showCandidatePicker = true;
                        _tab = 1;
                      });
                    }
                  : null,
              onRemove: canEdit
                  ? () =>
                        context.read<ExamDraftEditorCubit>().removeItem(item.id)
                  : null,
              onUnassign: canEdit ? onUnassign : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _groupedItemCards(
    BuildContext context,
    List<ExamDraftItemModel> items,
    List<ExamDraftSectionModel> sections,
    bool canEdit, {
    String? emptyTitle,
    String? emptyMessage,
  }) {
    final l10n = AppLocalizations.of(context);
    final widgets = <Widget>[];
    int? currentGroupId;
    for (final item in items) {
      if (item.sourceGroupId != null && item.sourceGroupId != currentGroupId) {
        currentGroupId = item.sourceGroupId;
        final group = item.question?.groups
            .where((entry) => entry.groupId == item.sourceGroupId)
            .firstOrNull;
        widgets.add(
          _GroupPromptHeader(
            title:
                item.sourceGroupTitle ??
                group?.title ??
                '${l10n.qbGroups} ${item.sourceGroupId}',
            prompt: item.sourceGroupPrompt ?? group?.sharedPrompt,
            imageUrl: item.sourceGroupImagePreviewUrl,
            fileId: item.sourceGroupFileId,
          ),
        );
        widgets.add(const SizedBox(height: 10));
      } else if (item.sourceGroupId == null) {
        currentGroupId = null;
      }
      widgets.add(_itemCard(context, item, sections, canEdit));
    }
    if (widgets.isEmpty) {
      widgets.add(
        ExamGeneratorEmptyState(
          title: emptyTitle ?? l10n.examDraftNoQuestions,
          message: emptyMessage ?? l10n.examDraftNoQuestionsHint,
        ),
      );
    }
    return widgets;
  }

  List<Widget> _sectionCards(
    BuildContext context,
    List<ExamDraftSectionModel> sections,
    List<ExamDraftItemModel> items,
    bool canEdit,
    void Function(ExamDraftSectionModel section) onEdit,
    void Function(ExamDraftSectionModel section) onDelete,
    void Function(ExamDraftSectionModel section) onNormalize,
    void Function(ExamDraftSectionModel section) onReshuffle,
    void Function(ExamDraftItemModel item) onUnassignItem,
  ) {
    final l10n = AppLocalizations.of(context);
    if (sections.isEmpty) {
      return [
        ExamGeneratorEmptyState(
          title: l10n.examDraftNoSections,
          message: l10n.examDraftNoSectionsHint,
        ),
      ];
    }
    return sections.map((section) {
      final sectionItems = items
          .where((item) => item.draftSectionId == section.id)
          .toList();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ExamDraftSectionCard(
          section: section,
          children: [
            _SectionActionGrid(
              canEdit: canEdit,
              onEdit: () => onEdit(section),
              onDelete: () => onDelete(section),
              onNormalize: () => onNormalize(section),
              onReshuffle: () => onReshuffle(section),
            ),
            const SizedBox(height: 14),
            _AssignedQuestionsBlock(
              items: sectionItems,
              itemBuilder: (item) => _itemCard(
                context,
                item,
                sections,
                canEdit,
                selectable: false,
                onUnassign: () => onUnassignItem(item),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Set<int> _draftQuestionIds(ExamDraftModel draft) {
    return {
      for (final item in draft.items) ...[
        item.questionId,
        if (item.question != null) item.question!.id,
        if (item.question != null) item.question!.questionId,
      ],
    };
  }

  Map<int, List<String>> _candidateOverrideReasons(
    ExamDraftModel draft,
    List<QuestionBankQuestionModel> questions,
    AppLocalizations l10n,
    List<CourseChapterModel> chapters,
    List<QuestionBankGroupModel> groups,
  ) {
    final existing = _draftQuestionIds(draft);
    final result = <int, List<String>>{};
    for (final question in questions) {
      if (existing.contains(question.id) ||
          existing.contains(question.questionId)) {
        continue;
      }
      final reasons = _questionRuleMismatchReasons(
        draft,
        question,
        l10n,
        chapters,
        groups,
      );
      if (reasons.isNotEmpty) {
        result[question.id] = reasons;
        result[question.questionId] = reasons;
      }
    }
    return result;
  }

  List<String> _questionRuleMismatchReasons(
    ExamDraftModel draft,
    QuestionBankQuestionModel question,
    AppLocalizations l10n,
    List<CourseChapterModel> chapters,
    List<QuestionBankGroupModel> groups,
  ) {
    final rules = draft.items
        .map((item) => item.originRule)
        .where((rule) => rule.isNotEmpty)
        .toList();
    if (rules.isEmpty) return const <String>[];
    final mismatchSets = [
      for (final rule in rules)
        _originRuleMismatchReasons(rule, question, l10n, chapters, groups),
    ];
    if (mismatchSets.any((reasons) => reasons.isEmpty)) {
      return const <String>[];
    }
    mismatchSets.sort((a, b) => a.length.compareTo(b.length));
    return mismatchSets.first;
  }

  List<String> _originRuleMismatchReasons(
    Map<String, dynamic> rule,
    QuestionBankQuestionModel question,
    AppLocalizations l10n,
    List<CourseChapterModel> chapters,
    List<QuestionBankGroupModel> groups,
  ) {
    final reasons = <String>[];
    final expectedType = _expectedString(rule['questionType']);
    if (expectedType != null && expectedType != question.questionType.value) {
      reasons.add(
        l10n.examMismatchExpectedType(
          _localizedQuestionTypeValue(l10n, expectedType),
        ),
      );
    }
    final expectedDifficulty = _expectedString(rule['difficulty']);
    if (expectedDifficulty != null &&
        expectedDifficulty != question.difficulty.value) {
      reasons.add(
        l10n.examMismatchExpectedDifficulty(
          _localizedDifficultyValue(l10n, expectedDifficulty),
        ),
      );
    }
    final expectedBloom = _expectedString(rule['bloomLevel']);
    if (expectedBloom != null && expectedBloom != question.bloomLevel.value) {
      reasons.add(
        l10n.examMismatchExpectedBloom(
          _localizedBloomValue(l10n, expectedBloom),
        ),
      );
    }
    final expectedChapter = _expectedInt(rule['chapterId']);
    if (expectedChapter != null && expectedChapter != question.chapterId) {
      reasons.add(
        l10n.examMismatchExpectedChapter(
          _chapterName(l10n, chapters, expectedChapter),
        ),
      );
    }
    final expectedChapters = _expectedIntSet(rule['chapterIds']);
    if (expectedChapters.isNotEmpty &&
        !expectedChapters.contains(question.chapterId)) {
      reasons.add(
        l10n.examMismatchExpectedChapter(
          expectedChapters
              .map((id) => _chapterName(l10n, chapters, id))
              .join(', '),
        ),
      );
    }
    final groupIds = rule['groupIds'];
    if (groupIds is List && groupIds.isNotEmpty) {
      final questionGroupIds = question.groups.map((group) => group.groupId);
      final allowed = groupIds
          .map((value) => int.tryParse(value.toString()))
          .whereType<int>()
          .toSet();
      if (allowed.isNotEmpty &&
          !questionGroupIds.any((groupId) => allowed.contains(groupId))) {
        reasons.add(
          l10n.examMismatchExpectedGroup(
            allowed.map((id) => _groupName(l10n, groups, id)).join(', '),
          ),
        );
      }
    }
    return reasons;
  }

  String? _expectedString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int? _expectedInt(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return int.tryParse(text);
  }

  Set<int> _expectedIntSet(dynamic expected) {
    if (expected is! List || expected.isEmpty) return const <int>{};
    return expected
        .map((value) => int.tryParse(value.toString()))
        .whereType<int>()
        .toSet();
  }

  String _chapterName(
    AppLocalizations l10n,
    List<CourseChapterModel> chapters,
    int chapterId,
  ) {
    return chapters
            .where((chapter) => chapter.id == chapterId)
            .map((chapter) => chapter.name)
            .firstOrNull ??
        '${l10n.chapter} $chapterId';
  }

  String _groupName(
    AppLocalizations l10n,
    List<QuestionBankGroupModel> groups,
    int groupId,
  ) {
    return groups
            .where((group) => group.id == groupId)
            .map((group) => group.title ?? '${l10n.qbGroups} $groupId')
            .firstOrNull ??
        '${l10n.qbGroups} $groupId';
  }

  String _localizedQuestionTypeValue(AppLocalizations l10n, String value) {
    return localizedQuestionType(l10n, QuestionBankType.fromJson(value));
  }

  String _localizedDifficultyValue(AppLocalizations l10n, String value) {
    return localizedDifficulty(l10n, QuestionBankDifficulty.fromJson(value));
  }

  String _localizedBloomValue(AppLocalizations l10n, String value) {
    return localizedBloomLevel(l10n, BloomLevel.fromJson(value));
  }

  Future<void> _addQuestionWithPreflight(
    BuildContext context,
    ExamDraftModel draft,
    QuestionBankQuestionModel question,
    List<CourseChapterModel> chapters,
    List<QuestionBankGroupModel> groups,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (_draftQuestionIds(draft).contains(question.id) ||
        _draftQuestionIds(draft).contains(question.questionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.examQuestionAlreadyInDraftHint)),
      );
      return;
    }
    String? overrideReason;
    final mismatchReasons = _questionRuleMismatchReasons(
      draft,
      question,
      l10n,
      chapters,
      groups,
    );
    if (mismatchReasons.isNotEmpty) {
      overrideReason = await _requestAddOverrideReason(
        context,
        question,
        mismatchReasons,
      );
      if (!context.mounted || overrideReason == null) return;
    }
    if (!context.mounted) return;
    context.read<ExamDraftEditorCubit>().addItem(
      questionId: question.id,
      overrideReason: overrideReason,
    );
  }

  Future<String?> _requestAddOverrideReason(
    BuildContext context,
    QuestionBankQuestionModel question,
    List<String> mismatchReasons,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _OverrideReasonDialog(
        question: question,
        mismatchReasons: mismatchReasons,
      ),
    );
  }

  Future<void> _confirmEditSource(BuildContext context, int questionId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      context,
      l10n.examEditSourceQuestion,
      l10n.examEditSourceQuestionWarning,
    );
    if (confirmed && context.mounted) {
      await context.push('/instructor/question-bank/$questionId/edit');
      if (context.mounted) {
        await context.read<ExamDraftEditorCubit>().reloadAfterSourceEdit();
      }
    }
  }

  Future<void> _replaceQuestion(
    BuildContext context,
    ExamDraftItemModel replacing,
    int questionId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final requiresOverride = await context
        .read<ExamDraftEditorCubit>()
        .replacementRequiresOverride(
          itemId: replacing.id,
          replacementQuestionId: questionId,
        );
    if (!context.mounted) return;
    String? reason;
    if (requiresOverride) {
      final controller = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.examReplaceQuestion),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.examOverrideReasonHelper),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: l10n.examOverrideReason),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.examReplaceQuestion),
            ),
          ],
        ),
      );
      if (!context.mounted || reason == null) return;
    }
    context.read<ExamDraftEditorCubit>().updateItem(
      itemId: replacing.id,
      payload: ExamDraftItemUpdatePayload(
        replacementQuestionId: questionId,
        overrideReason: (reason ?? '').isEmpty ? null : reason,
      ),
    );
    setState(() => _editingItem = null);
  }

  Future<void> _save(BuildContext context) async {
    final id = await context.read<ExamDraftEditorCubit>().saveDraft();
    if (id != null && context.mounted) {
      context.go('/instructor/exam-generator/exams/$id');
    }
  }

  Future<void> _duplicateFinalizedDraft(BuildContext context) async {
    final id = await context.read<ExamDraftEditorCubit>().duplicateDraft();
    if (id != null && context.mounted) {
      context.go('/instructor/exam-generator/drafts/$id');
    }
  }

  bool _hasSavedExam(ExamDraftModel? draft) {
    return draft?.status == ExamDraftStatus.finalized &&
        draft?.finalizedExamId != null;
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
  ) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _FinalizedDraftHandoff extends StatelessWidget {
  const _FinalizedDraftHandoff({
    required this.draft,
    required this.isMutating,
    required this.onOpenSavedExam,
    required this.onCreateEditableCopy,
  });

  final ExamDraftModel draft;
  final bool isMutating;
  final VoidCallback? onOpenSavedExam;
  final VoidCallback onCreateEditableCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        ExamGeneratorHeroHeader(
          title: draft.title,
          subtitle: l10n.examFinalizedDraftMessage,
          stats: {
            l10n.status: localizedDraftStatus(l10n, draft.status),
            l10n.questions: draft.items.length.toString(),
            l10n.sections: draft.sections.length.toString(),
            l10n.totalMarks: draft.totalMarks?.toString() ?? '-',
          },
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: InstructorColors.success.withValues(
                        alpha: isDark ? 0.18 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      color: InstructorColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.examFinalizedDraftTitle,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          onOpenSavedExam == null
                              ? l10n.examFinalizedDraftNoSavedExam
                              : l10n.examFinalizedDraftMessage,
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isMutating) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(minHeight: 3),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: isMutating ? null : onOpenSavedExam,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(l10n.examOpenSavedExam),
                  ),
                  OutlinedButton.icon(
                    onPressed: isMutating ? null : onCreateEditableCopy,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: Text(l10n.examCreateEditableCopy),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuildTab extends StatelessWidget {
  const _BuildTab({
    required this.draft,
    required this.state,
    required this.editingSection,
    required this.editingItem,
    required this.showSectionEditor,
    required this.showCandidatePicker,
    required this.isSavingSection,
    required this.selectedItemIds,
    required this.onShowSectionEditor,
    required this.onCancelSectionEditor,
    required this.onSubmitSection,
    required this.onEditSection,
    required this.onDeleteSection,
    required this.onNormalizeSection,
    required this.onReshuffleSection,
    required this.onUnassignItem,
    required this.onCancelItemEditor,
    required this.onSubmitItem,
    required this.itemCards,
    required this.onShowCandidatePicker,
    required this.onHideCandidatePicker,
    this.moveSelectedBar,
    this.candidatePicker,
  });

  final ExamDraftModel draft;
  final ExamDraftEditorState state;
  final ExamDraftSectionModel? editingSection;
  final ExamDraftItemModel? editingItem;
  final bool showSectionEditor;
  final bool showCandidatePicker;
  final bool isSavingSection;
  final Set<int> selectedItemIds;
  final VoidCallback onShowSectionEditor;
  final VoidCallback onCancelSectionEditor;
  final Future<void> Function(ExamDraftSectionPayload) onSubmitSection;
  final ValueChanged<ExamDraftSectionModel> onEditSection;
  final ValueChanged<ExamDraftSectionModel> onDeleteSection;
  final ValueChanged<ExamDraftSectionModel> onNormalizeSection;
  final ValueChanged<ExamDraftSectionModel> onReshuffleSection;
  final ValueChanged<ExamDraftItemModel> onUnassignItem;
  final VoidCallback onCancelItemEditor;
  final ValueChanged<ExamDraftItemUpdatePayload> onSubmitItem;
  final Widget? moveSelectedBar;
  final List<Widget> itemCards;
  final Widget? candidatePicker;
  final Future<void> Function() onShowCandidatePicker;
  final VoidCallback onHideCandidatePicker;

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_ExamDraftDetailViewState>();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabIntro(
          icon: Icons.construction_rounded,
          title: l10n.examDraftBuild,
          message: l10n.examDraftBuildHint,
          color: InstructorColors.primary,
        ),
        const SizedBox(height: 12),
        _SectionHeader(
          title: l10n.examSections,
          subtitle: l10n.examDraftSectionsHint,
          actionLabel: l10n.examCreateSection,
          actionIcon: Icons.add_rounded,
          onAction: draft.isEditable ? onShowSectionEditor : null,
        ),
        const SizedBox(height: 10),
        if (showSectionEditor) ...[
          ExamDraftSectionEditorCard(
            key: ValueKey(editingSection?.id ?? 0),
            initial: editingSection,
            isSubmitting: isSavingSection,
            onCancel: onCancelSectionEditor,
            onSubmit: onSubmitSection,
          ),
          const SizedBox(height: 12),
        ],
        ...?parent?._sectionCards(
          context,
          draft.sections,
          draft.items,
          draft.isEditable,
          onEditSection,
          onDeleteSection,
          onNormalizeSection,
          onReshuffleSection,
          onUnassignItem,
        ),
        const SizedBox(height: 12),
        _SectionHeader(
          title: l10n.examUnassignedQuestions,
          subtitle: l10n.examUnassignedQuestionsHint,
          actionLabel: showCandidatePicker
              ? l10n.examHideQuestionPicker
              : l10n.examAddQuestion,
          actionIcon: showCandidatePicker
              ? Icons.keyboard_arrow_up_rounded
              : Icons.add_rounded,
          onAction: draft.isEditable
              ? (showCandidatePicker
                    ? onHideCandidatePicker
                    : () => onShowCandidatePicker())
              : null,
        ),
        const SizedBox(height: 10),
        if (editingItem != null) ...[
          ExamDraftItemEditorCard(
            key: ValueKey(editingItem!.id),
            item: editingItem!,
            sections: draft.sections,
            onCancel: onCancelItemEditor,
            onSubmit: onSubmitItem,
          ),
          const SizedBox(height: 12),
        ],
        if (moveSelectedBar != null) ...[
          moveSelectedBar!,
          const SizedBox(height: 10),
        ],
        ...itemCards,
        if (candidatePicker != null) ...[
          const SizedBox(height: 12),
          candidatePicker!,
        ],
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.state});

  final ExamDraftEditorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = state.draft!;
    final validation = state.validation;
    final okCount = validation?.checklist.where((item) => item.isOk).length;
    final totalChecks = validation?.checklist.length;
    final hasIssues =
        (validation?.errors.isNotEmpty ?? false) ||
        (validation?.warnings.isNotEmpty ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabIntro(
          icon: Icons.dashboard_customize_outlined,
          title: l10n.examDraftOverview,
          message: l10n.examDraftOverviewHint,
          color: InstructorColors.teal,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720
                ? 3
                : constraints.maxWidth >= 320
                ? 2
                : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: columns == 1 ? 3.6 : 2.35,
              children: [
                _MetricCard(
                  icon: Icons.fact_check_outlined,
                  color: validation?.canSave == true
                      ? InstructorColors.success
                      : InstructorColors.warning,
                  label: l10n.examDraftReadiness,
                  value: validation?.canSave == true
                      ? l10n.examCanSave
                      : l10n.examCannotSave,
                ),
                _MetricCard(
                  icon: Icons.quiz_outlined,
                  color: InstructorColors.primary,
                  label: l10n.questions,
                  value:
                      validation?.totalQuestions.toString() ??
                      draft.items.length.toString(),
                ),
                _MetricCard(
                  icon: Icons.score_outlined,
                  color: InstructorColors.teal,
                  label: l10n.totalMarks,
                  value:
                      validation?.totalMarks?.toString() ??
                      draft.totalMarks?.toString() ??
                      '-',
                ),
                _MetricCard(
                  icon: Icons.checklist_rounded,
                  color: InstructorColors.primary,
                  label: l10n.examFinalReview,
                  value: okCount == null || totalChecks == null
                      ? l10n.examValidationUnavailable
                      : '$okCount/$totalChecks',
                ),
                _MetricCard(
                  icon: Icons.view_agenda_outlined,
                  color: InstructorColors.accent,
                  label: l10n.sections,
                  value:
                      validation?.sectionSummaries.length.toString() ??
                      draft.sections.length.toString(),
                ),
                _MetricCard(
                  icon: Icons.schedule_rounded,
                  color: InstructorColors.orange,
                  label: l10n.examDurationMinutes,
                  value: draft.durationMinutes?.toString() ?? '-',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        if (hasIssues && validation != null) ...[
          _IssuePanel(validation: validation),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 680;
            final panelWidth = twoColumns
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: panelWidth,
                  child: _InfoPanel(
                    icon: Icons.view_list_outlined,
                    title: l10n.examSections,
                    color: InstructorColors.accent,
                    children: _overviewSectionLines(context, draft, validation),
                  ),
                ),
                SizedBox(
                  width: panelWidth,
                  child: _InfoPanel(
                    icon: Icons.settings_suggest_outlined,
                    title: l10n.examGenerationSettings,
                    color: InstructorColors.teal,
                    children: [
                      _InfoLine(
                        label: l10n.examMarkDistribution,
                        value: localizedMarkMode(
                          l10n,
                          draft.markDistributionMode,
                        ),
                      ),
                      _InfoLine(
                        label: l10n.examRoundingPolicy,
                        value: localizedRounding(l10n, draft.roundingPolicy),
                      ),
                      _InfoLine(label: l10n.examSeed, value: draft.seed),
                    ],
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth,
                  child: _InfoPanel(
                    icon: Icons.description_outlined,
                    title: l10n.examDraftTextContent,
                    color: InstructorColors.primary,
                    children: [
                      _InfoLine(
                        label: l10n.instructions,
                        value: draft.instructions,
                      ),
                      _InfoLine(
                        label: l10n.examHeaderText,
                        value: draft.headerText,
                      ),
                      _InfoLine(
                        label: l10n.examFooterText,
                        value: draft.footerText,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<Widget> _overviewSectionLines(
    BuildContext context,
    ExamDraftModel draft,
    ExamDraftValidationModel? validation,
  ) {
    final l10n = AppLocalizations.of(context);
    if (validation != null && validation.sectionSummaries.isNotEmpty) {
      return validation.sectionSummaries
          .map(
            (section) => _InfoLine(
              label: section.title,
              value: l10n.examSectionReviewSummary(
                section.itemCount,
                section.itemMarksTotal,
              ),
            ),
          )
          .toList();
    }
    if (draft.sections.isEmpty) {
      return [
        _InfoLine(
          label: l10n.examSections,
          value: l10n.examDraftNoSectionsHint,
        ),
      ];
    }
    return draft.sections
        .map(
          (section) => _InfoLine(
            label: section.title,
            value: l10n.examOrderNumber(section.sectionOrder + 1),
          ),
        )
        .toList();
  }
}

class _ExpiryBanner extends StatelessWidget {
  const _ExpiryBanner({required this.expiresAt});

  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = expiresAt.difference(DateTime.now());
    final expired = remaining.isNegative;
    final color = expired ? InstructorColors.error : InstructorColors.accent;
    final text = expired
        ? l10n.examDraftExpired
        : l10n.examDraftExpiresIn(
            remaining.inHours,
            remaining.inMinutes.remainder(60),
          );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            expired ? Icons.lock_clock_outlined : Icons.timer_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverrideReasonDialog extends StatefulWidget {
  const _OverrideReasonDialog({
    required this.question,
    required this.mismatchReasons,
  });

  final QuestionBankQuestionModel question;
  final List<String> mismatchReasons;

  @override
  State<_OverrideReasonDialog> createState() => _OverrideReasonDialogState();
}

class _OverrideReasonDialogState extends State<_OverrideReasonDialog> {
  late final TextEditingController _controller = TextEditingController();
  bool _submittedEmpty = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = localizedQuestionType(l10n, widget.question.questionType);
    final difficulty = localizedDifficulty(l10n, widget.question.difficulty);
    final bloom = localizedBloomLevel(l10n, widget.question.bloomLevel);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconBubble(
                      icon: Icons.warning_amber_rounded,
                      color: InstructorColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.examAddQuestionOutsideRulesTitle,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.examNeedsOverrideHint,
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(
                                isDark,
                              ),
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _DialogPill(label: type, color: InstructorColors.primary),
                    _DialogPill(
                      label: difficulty,
                      color: InstructorColors.teal,
                    ),
                    _DialogPill(label: bloom, color: InstructorColors.accent),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: InstructorColors.surfaceColor(isDark),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: InstructorColors.borderColor(isDark),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.examRuleMismatchTitle,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final reason in widget.mismatchReasons)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: InstructorColors.warning,
                                size: 17,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    color: InstructorColors.textSecondaryColor(
                                      isDark,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: InstructorColors.warning.withValues(
                      alpha: isDark ? 0.16 : 0.09,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: InstructorColors.warning.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    l10n.examAddQuestionOutsideRulesBody(
                      type,
                      difficulty,
                      bloom,
                    ),
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (_) {
                    if (_submittedEmpty) {
                      setState(() => _submittedEmpty = false);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.examOverrideReason,
                    errorText: _submittedEmpty
                        ? l10n.examOverrideReasonRequired
                        : null,
                    prefixIcon: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsetsDirectional.fromSTEB(
                        12,
                        8,
                        10,
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: InstructorColors.warning.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: InstructorColors.warning,
                      ),
                    ),
                    filled: true,
                    fillColor: InstructorColors.surfaceColor(isDark),
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
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: InstructorColors.textSecondaryColor(
                          isDark,
                        ),
                        side: BorderSide(
                          color: InstructorColors.borderColor(isDark),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: Text(l10n.cancel),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        final reason = _controller.text.trim();
                        if (reason.isEmpty) {
                          setState(() => _submittedEmpty = true);
                          return;
                        }
                        Navigator.of(context).pop(reason);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.examAddQuestionWithOverride),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogPill extends StatelessWidget {
  const _DialogPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AssignedQuestionsBlock extends StatelessWidget {
  const _AssignedQuestionsBlock({
    required this.items,
    required this.itemBuilder,
  });

  final List<ExamDraftItemModel> items;
  final Widget Function(ExamDraftItemModel item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBubble(
                icon: Icons.playlist_add_check_rounded,
                color: InstructorColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.examSectionAssignedQuestions(items.length),
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              l10n.examSectionNoAssignedQuestions,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            )
          else
            ...items.map(itemBuilder),
        ],
      ),
    );
  }
}

class _MoveSelectedBar extends StatelessWidget {
  const _MoveSelectedBar({
    required this.sections,
    required this.selectedCount,
    required this.isMoving,
    required this.movingCount,
    required this.onMove,
  });

  final List<ExamDraftSectionModel> sections;
  final int selectedCount;
  final bool isMoving;
  final int movingCount;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBubble(
                icon: Icons.add_task_rounded,
                color: selectedCount > 0
                    ? InstructorColors.primary
                    : InstructorColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.examSelectedQuestions(selectedCount),
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          PopupMenuButton<int>(
            enabled: selectedCount > 0 && sections.isNotEmpty && !isMoving,
            onSelected: onMove,
            color: InstructorColors.cardColor(isDark),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: InstructorColors.borderColor(isDark)),
            ),
            itemBuilder: (context) => [
              for (final section in sections)
                PopupMenuItem<int>(
                  value: section.id,
                  child: Text(section.title),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (selectedCount > 0 && sections.isNotEmpty) || isMoving
                    ? InstructorColors.primary
                    : InstructorColors.textTertiaryColor(
                        isDark,
                      ).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMoving)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(
                      Icons.drive_file_move_outline,
                      color: selectedCount > 0 && sections.isNotEmpty
                          ? Colors.white
                          : InstructorColors.textSecondaryColor(isDark),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    isMoving
                        ? l10n.examMovingQuestions(movingCount)
                        : l10n.examMoveSelectedQuestions,
                    style: TextStyle(
                      color:
                          (selectedCount > 0 && sections.isNotEmpty) || isMoving
                          ? Colors.white
                          : InstructorColors.textSecondaryColor(isDark),
                      fontWeight: FontWeight.w900,
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
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab({required this.state, required this.onRegenerate});

  final ExamDraftEditorState state;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = state.draft!;
    final validation = state.validation;
    final canRegenerate = draft.isEditable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabIntro(
          icon: Icons.fact_check_outlined,
          title: l10n.examDraftReview,
          message: l10n.examDraftReviewHint,
          color: validation?.canSave == true
              ? InstructorColors.success
              : InstructorColors.warning,
        ),
        const SizedBox(height: 12),
        if (validation == null)
          ExamGeneratorEmptyState(
            title: l10n.examValidation,
            message: l10n.examValidationUnavailable,
          )
        else
          _ChecklistPanel(checklist: validation.checklist),
        const SizedBox(height: 12),
        _RegenerateDraftCard(
          enabled: canRegenerate,
          onRegenerate: onRegenerate,
        ),
      ],
    );
  }
}

class _RegenerateDraftCard extends StatelessWidget {
  const _RegenerateDraftCard({
    required this.enabled,
    required this.onRegenerate,
  });

  final bool enabled;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: enabled ? onRegenerate : null,
      borderRadius: BorderRadius.circular(22),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.16 : 0.08,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: InstructorColors.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              _IconBubble(
                icon: Icons.refresh_rounded,
                color: InstructorColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.examRegenerateDraft,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
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
    );
  }
}

class _TabIntro extends StatelessWidget {
  const _TabIntro({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          _IconBubble(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionIcon,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
        final action = FilledButton.icon(
          onPressed: onAction,
          style: FilledButton.styleFrom(
            backgroundColor: InstructorColors.primary,
            disabledBackgroundColor: InstructorColors.primary.withValues(
              alpha: 0.35,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: Icon(actionIcon, size: 19),
          label: Text(actionLabel, overflow: TextOverflow.ellipsis),
        );
        if (constraints.maxWidth < 430) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: action,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: text),
            const SizedBox(width: 10),
            Flexible(flex: 0, child: action),
          ],
        );
      },
    );
  }
}

class _SectionActionGrid extends StatelessWidget {
  const _SectionActionGrid({
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
    required this.onNormalize,
    required this.onReshuffle,
  });

  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onNormalize;
  final VoidCallback onReshuffle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = [
      _SectionActionTileData(
        label: l10n.examEditSection,
        icon: Icons.edit_outlined,
        color: InstructorColors.primary,
        onPressed: canEdit ? onEdit : null,
      ),
      _SectionActionTileData(
        label: l10n.examNormalizeSectionMarks,
        icon: Icons.auto_fix_high_outlined,
        color: InstructorColors.teal,
        onPressed: canEdit ? onNormalize : null,
      ),
      _SectionActionTileData(
        label: l10n.examReshuffleSection,
        icon: Icons.shuffle_rounded,
        color: InstructorColors.accent,
        onPressed: canEdit ? onReshuffle : null,
      ),
      _SectionActionTileData(
        label: l10n.examDeleteSection,
        icon: Icons.delete_outline,
        color: InstructorColors.error,
        onPressed: canEdit ? onDelete : null,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in actions) _SectionActionTile(data: action),
          ],
        );
      },
    );
  }
}

class _SectionActionTileData {
  const _SectionActionTileData({
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

class _SectionActionTile extends StatelessWidget {
  const _SectionActionTile({required this.data});

  final _SectionActionTileData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      onPressed: data.onPressed,
      avatar: Icon(data.icon, color: data.color, size: 18),
      label: Text(
        data.label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: InstructorColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      backgroundColor: data.color.withValues(alpha: isDark ? 0.16 : 0.08),
      side: BorderSide(color: data.color.withValues(alpha: 0.22)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 11,
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
                    fontSize: 15,
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

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolved = value == null || value!.trim().isEmpty
        ? l10n.examDraftNoValue
        : value!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(
              resolved,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: value == null || value!.trim().isEmpty
                    ? InstructorColors.textTertiaryColor(isDark)
                    : InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistPanel extends StatelessWidget {
  const _ChecklistPanel({required this.checklist});

  final List<ExamDraftChecklistItemModel> checklist;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = checklist.isEmpty
        ? [
            ExamDraftChecklistItemModel(
              key: 'has_questions',
              status: 'ok',
              message: l10n.examReviewHasQuestions,
            ),
          ]
        : checklist;
    return _InfoPanel(
      icon: Icons.checklist_rounded,
      title: l10n.examFinalReview,
      color: InstructorColors.primary,
      children: [
        for (final item in items)
          _ChecklistRow(
            icon: item.isOk
                ? Icons.check_circle_rounded
                : item.isWarning
                ? Icons.warning_amber_rounded
                : Icons.error_rounded,
            color: item.isOk
                ? InstructorColors.success
                : item.isWarning
                ? InstructorColors.warning
                : InstructorColors.error,
            title: localizedExamMessage(l10n, item.message),
            action: _localizedChecklistAction(l10n, item.action),
          ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.icon,
    required this.color,
    required this.title,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    action!,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssuePanel extends StatelessWidget {
  const _IssuePanel({required this.validation});

  final ExamDraftValidationModel validation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _InfoPanel(
      icon: Icons.report_problem_outlined,
      title: l10n.examDraftIssues,
      color: validation.errors.isNotEmpty
          ? InstructorColors.error
          : InstructorColors.warning,
      children: [
        for (final error in validation.errors)
          _ChecklistRow(
            icon: Icons.error_rounded,
            color: InstructorColors.error,
            title: localizedExamMessage(l10n, error),
          ),
        for (final warning in validation.warnings)
          _ChecklistRow(
            icon: Icons.warning_amber_rounded,
            color: InstructorColors.warning,
            title: localizedExamMessage(l10n, warning),
          ),
      ],
    );
  }
}

class _GroupPromptHeader extends StatelessWidget {
  const _GroupPromptHeader({
    required this.title,
    required this.prompt,
    required this.imageUrl,
    required this.fileId,
  });

  final String title;
  final String? prompt;
  final String? imageUrl;
  final int? fileId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedImageUrl = _resolveGroupHeaderImageUrl(imageUrl, fileId);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.accent.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: InstructorColors.accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          resolvedImageUrl == null
              ? _IconBubble(
                  icon: Icons.folder_copy_outlined,
                  color: InstructorColors.accent,
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _showGroupHeaderImagePreview(
                    context,
                    resolvedImageUrl,
                    title,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _GroupHeaderImage(
                      imageUrl: resolvedImageUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      isDark: isDark,
                    ),
                  ),
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
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                QuestionFormattedText(
                  text: prompt,
                  fallback: l10n.examGroupedPromptShownOnce,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String? _resolveGroupHeaderImageUrl(String? imageUrl, int? fileId) {
  final trimmed = imageUrl?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  if (fileId == null || fileId <= 0) return null;
  return '${ApiService.baseUrl}/files/$fileId/download';
}

class _GroupHeaderImage extends StatelessWidget {
  const _GroupHeaderImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.fit,
    required this.isDark,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      final comma = imageUrl.indexOf(',');
      if (comma > -1) {
        try {
          return Image.memory(
            base64Decode(imageUrl.substring(comma + 1)),
            width: width,
            height: height,
            fit: fit,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return _GroupHeaderImageLoadingBox(
                width: width,
                height: height,
                isDark: isDark,
              );
            },
            errorBuilder: (_, __, ___) => _GroupHeaderImageErrorBox(
              width: width,
              height: height,
              isDark: isDark,
            ),
          );
        } on FormatException {
          return _GroupHeaderImageErrorBox(
            width: width,
            height: height,
            isDark: isDark,
          );
        }
      }
    }

    if (_requiresImageAuth(imageUrl)) {
      return FutureBuilder<String?>(
        future: StorageService().getAccessToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _GroupHeaderImageLoadingBox(
              width: width,
              height: height,
              isDark: isDark,
            );
          }
          final token = snapshot.data;
          if (token == null || token.isEmpty) {
            return _GroupHeaderImageErrorBox(
              width: width,
              height: height,
              isDark: isDark,
            );
          }
          return _networkImage(<String, String>{
            'Authorization': 'Bearer $token',
          });
        },
      );
    }

    return _networkImage(null);
  }

  Widget _networkImage(Map<String, String>? headers) {
    return Image.network(
      imageUrl,
      headers: headers,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _GroupHeaderImageLoadingBox(
          width: width,
          height: height,
          isDark: isDark,
        );
      },
      errorBuilder: (_, __, ___) => _GroupHeaderImageErrorBox(
        width: width,
        height: height,
        isDark: isDark,
      ),
    );
  }
}

class _GroupHeaderImageLoadingBox extends StatelessWidget {
  const _GroupHeaderImageLoadingBox({
    required this.width,
    required this.height,
    required this.isDark,
  });

  final double width;
  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: InstructorColors.accent.withValues(alpha: isDark ? 0.18 : 0.1),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _GroupHeaderImageErrorBox extends StatelessWidget {
  const _GroupHeaderImageErrorBox({
    required this.width,
    required this.height,
    required this.isDark,
  });

  final double width;
  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: InstructorColors.accent.withValues(alpha: isDark ? 0.18 : 0.1),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: InstructorColors.textSecondaryColor(isDark),
        size: 20,
      ),
    );
  }
}

bool _requiresImageAuth(String url) {
  return url.contains('/api/files/') ||
      url.startsWith('${ApiService.baseUrl}/files/');
}

Future<void> _showGroupHeaderImagePreview(
  BuildContext context,
  String imageUrl,
  String title,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 4,
                  child: _GroupHeaderImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.72,
                    fit: BoxFit.contain,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

String? _localizedChecklistAction(AppLocalizations l10n, String? action) {
  switch (action) {
    case null:
      return null;
    case 'reviewImages':
      return l10n.examActionReviewImages;
    case 'moveUnassigned':
      return l10n.examActionMoveUnassigned;
    case 'regenerate':
      return l10n.examRegenerateDraft;
    default:
      return action;
  }
}
