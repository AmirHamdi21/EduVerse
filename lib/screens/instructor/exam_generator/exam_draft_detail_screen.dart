import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/exam_generator/exam_draft_editor_cubit.dart';
import '../../../bloc/instructor/exam_generator/exam_draft_editor_state.dart';
import '../../../models/exams/exam_draft_item_model.dart';
import '../../../models/exams/exam_draft_item_update_payload.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';
import '../../../widgets/instructor/shared/instructor_modern_tab_strip.dart';

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
  final Set<int> _selectedItemIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examDraftDetails)),
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
          return ListView(
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
              ),
              const SizedBox(height: 16),
              ExamDraftEditorToolbar(
                canEdit: draft.isEditable && !state.isMutating,
                onAddSection: () => setState(() {
                  _editingSection = null;
                  _tab = 1;
                }),
                onAddQuestion: () async {
                  await context
                      .read<ExamDraftEditorCubit>()
                      .loadCandidateQuestions();
                  setState(() => _tab = 4);
                },
                onSave: () => _save(context),
              ),
              if (draft.isEditable) ...[
                const SizedBox(height: 10),
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
                    icon: Icons.view_agenda_outlined,
                    label: l10n.sections,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.help_outline,
                    label: l10n.examDraftQuestions,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.swap_vert_rounded,
                    label: l10n.examDraftReorder,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.add_rounded,
                    label: l10n.examAddQuestion,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.fact_check_outlined,
                    label: l10n.examValidation,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.checklist_rounded,
                    label: l10n.examFinalReview,
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
        return Column(
          children: [
            ExamDraftSectionEditorCard(
              key: ValueKey(_editingSection?.id ?? 0),
              initial: _editingSection,
              onCancel: () => setState(() => _editingSection = null),
              onSubmit: (payload) {
                context.read<ExamDraftEditorCubit>().upsertSection(
                  sectionId: _editingSection?.id,
                  payload: payload,
                );
                setState(() => _editingSection = null);
              },
            ),
            const SizedBox(height: 12),
            ...draft.sections.map(
              (section) => ExamDraftSectionCard(
                section: section,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: draft.isEditable
                            ? () => setState(() => _editingSection = section)
                            : null,
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.examEditSection),
                      ),
                      OutlinedButton.icon(
                        onPressed: draft.isEditable
                            ? () async {
                                final confirmed = await _confirm(
                                  context,
                                  l10n.examDeleteSection,
                                  l10n.examDeleteSectionUnassigns,
                                );
                                if (confirmed && context.mounted) {
                                  context
                                      .read<ExamDraftEditorCubit>()
                                      .deleteSection(section.id);
                                }
                              }
                            : null,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.examDeleteSection),
                      ),
                      OutlinedButton.icon(
                        onPressed: draft.isEditable
                            ? () => context
                                  .read<ExamDraftEditorCubit>()
                                  .normalizeSectionMarks(
                                    section.id,
                                    totalMarks: section.totalMarks,
                                  )
                            : null,
                        icon: const Icon(Icons.auto_fix_high_outlined),
                        label: Text(l10n.examNormalizeSectionMarks),
                      ),
                      OutlinedButton.icon(
                        onPressed: draft.isEditable
                            ? () => context
                                  .read<ExamDraftEditorCubit>()
                                  .reshuffleSection(section.id)
                            : null,
                        icon: const Icon(Icons.shuffle_outlined),
                        label: Text(l10n.examReshuffleSection),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            if (_editingItem != null)
              ExamDraftItemEditorCard(
                key: ValueKey(_editingItem!.id),
                item: _editingItem!,
                sections: draft.sections,
                onCancel: () => setState(() => _editingItem = null),
                onSubmit: (payload) {
                  context.read<ExamDraftEditorCubit>().updateItem(
                    itemId: _editingItem!.id,
                    payload: payload,
                  );
                  setState(() => _editingItem = null);
                },
              ),
            if (_editingItem != null) const SizedBox(height: 12),
            if (draft.isEditable)
              _MoveSelectedBar(
                sections: draft.sections,
                selectedCount: _selectedItemIds.length,
                onMove: (sectionId) {
                  context.read<ExamDraftEditorCubit>().moveItemsToSection(
                    _selectedItemIds.toList(),
                    sectionId,
                  );
                  setState(_selectedItemIds.clear);
                },
              ),
            if (draft.isEditable) const SizedBox(height: 8),
            ..._groupedItemCards(
              context,
              draft.items,
              draft.sections,
              draft.isEditable,
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            ExamDraftSectionReorderList(
              sections: draft.sections,
              onReorder: context.read<ExamDraftEditorCubit>().reorderSections,
            ),
            const SizedBox(height: 16),
            ExamDraftItemReorderList(
              items: draft.items,
              onReorder: context.read<ExamDraftEditorCubit>().reorderItems,
            ),
          ],
        );
      case 4:
        return ExamCandidateQuestionPicker(
          questions: state.candidateQuestions,
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
                context.read<ExamDraftEditorCubit>().loadCandidateQuestions(
                  chapterId: chapterId,
                  groupId: groupId,
                  questionType: questionType,
                  difficulty: difficulty,
                  bloomLevel: bloomLevel,
                  search: search,
                );
              },
          onLoadMore: () =>
              context.read<ExamDraftEditorCubit>().loadMoreCandidateQuestions(),
          onSelected: (questionId) {
            final replacing = _editingItem;
            if (replacing == null) {
              context.read<ExamDraftEditorCubit>().addItem(
                questionId: questionId,
              );
            } else {
              _replaceQuestion(context, replacing, questionId);
            }
          },
        );
      case 5:
        return _ValidationView(state: state);
      case 6:
        return _FinalReviewView(
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              draft.isEditable
                  ? l10n.examDraftEditable
                  : l10n.examDraftNotEditable,
            ),
            const SizedBox(height: 12),
            if (!draft.isEditable) Text(l10n.examDraftNotEditableMessage),
          ],
        );
    }
  }

  Widget _itemCard(
    BuildContext context,
    ExamDraftItemModel item,
    List<ExamDraftSectionModel> sections,
    bool canEdit,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canEdit)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Checkbox(
              value: _selectedItemIds.contains(item.id),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedItemIds.add(item.id);
                  } else {
                    _selectedItemIds.remove(item.id);
                  }
                });
              },
            ),
          ),
        Expanded(
          child: ExamDraftItemCard(
            item: item,
            onOpenSource: () =>
                context.push('/instructor/question-bank/${item.questionId}'),
            onEditSource: () => _confirmEditSource(context, item.questionId),
            onEdit: canEdit ? () => setState(() => _editingItem = item) : null,
            onReplace: canEdit
                ? () async {
                    await context
                        .read<ExamDraftEditorCubit>()
                        .loadCandidateQuestions();
                    setState(() {
                      _editingItem = item;
                      _tab = 4;
                    });
                  }
                : null,
            onRemove: canEdit
                ? () => context.read<ExamDraftEditorCubit>().removeItem(item.id)
                : null,
          ),
        ),
      ],
    );
  }

  List<Widget> _groupedItemCards(
    BuildContext context,
    List<ExamDraftItemModel> items,
    List<ExamDraftSectionModel> sections,
    bool canEdit,
  ) {
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
          Card(
            elevation: 0,
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: .45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: item.sourceGroupImagePreviewUrl == null
                  ? const Icon(Icons.folder_copy_outlined)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.sourceGroupImagePreviewUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.folder_copy_outlined),
                      ),
                    ),
              title: Text(
                item.sourceGroupTitle ??
                    group?.title ??
                    '${l10n.qbGroups} ${item.sourceGroupId}',
              ),
              subtitle: Text(
                item.sourceGroupPrompt ??
                    group?.sharedPrompt ??
                    l10n.examGroupedPromptShownOnce,
              ),
            ),
          ),
        );
      } else if (item.sourceGroupId == null) {
        currentGroupId = null;
      }
      widgets.add(_itemCard(context, item, sections, canEdit));
    }
    return widgets;
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
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
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

class _ExpiryBanner extends StatelessWidget {
  const _ExpiryBanner({required this.expiresAt});

  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remaining = expiresAt.difference(DateTime.now());
    final text = remaining.isNegative
        ? l10n.examDraftExpired
        : l10n.examDraftExpiresIn(
            remaining.inHours,
            remaining.inMinutes.remainder(60),
          );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _ValidationView extends StatelessWidget {
  const _ValidationView({required this.state});

  final ExamDraftEditorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validation = state.validation;
    if (validation == null) {
      return ExamGeneratorEmptyState(
        title: l10n.examValidation,
        message: l10n.examValidationUnavailable,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line(
          validation.canSave ? Icons.check_circle_outline : Icons.error_outline,
          validation.canSave ? l10n.examCanSave : l10n.examCannotSave,
        ),
        _line(
          Icons.quiz_outlined,
          '${validation.totalQuestions} ${l10n.questions}',
        ),
        if (validation.totalMarks != null)
          _line(Icons.score_outlined, '${validation.totalMarks} ${l10n.marks}'),
        ...validation.errors.map(
          (error) =>
              _line(Icons.error_outline, localizedExamMessage(l10n, error)),
        ),
        ...validation.warnings.map(
          (warning) => _line(
            Icons.warning_amber_outlined,
            localizedExamMessage(l10n, warning),
          ),
        ),
        ...validation.checklist.map(
          (item) => ListTile(
            leading: Icon(
              item.isOk
                  ? Icons.check_circle_outline
                  : item.isWarning
                      ? Icons.warning_amber_outlined
                      : Icons.error_outline,
              color: item.isOk
                  ? Colors.green
                  : item.isWarning
                      ? Colors.orange
                      : Theme.of(context).colorScheme.error,
            ),
            title: Text(localizedExamMessage(l10n, item.message)),
            trailing: item.action == null
                ? null
                : Chip(label: Text(item.action!)),
          ),
        ),
      ],
    );
  }

  Widget _line(IconData icon, String text) {
    return ListTile(leading: Icon(icon), title: Text(text));
  }
}

class _MoveSelectedBar extends StatelessWidget {
  const _MoveSelectedBar({
    required this.sections,
    required this.selectedCount,
    required this.onMove,
  });

  final List<ExamDraftSectionModel> sections;
  final int selectedCount;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.examSelectedQuestions(selectedCount),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            PopupMenuButton<int>(
              enabled: selectedCount > 0,
              onSelected: onMove,
              itemBuilder: (context) => [
                for (final section in sections)
                  PopupMenuItem<int>(
                    value: section.id,
                    child: Text(section.title),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selectedCount > 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.drive_file_move_outline,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.examMoveSelectedQuestions,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalReviewView extends StatelessWidget {
  const _FinalReviewView({required this.state, required this.onRegenerate});

  final ExamDraftEditorState state;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = state.draft!;
    final validation = state.validation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.examFinalReview,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        if (validation != null && validation.checklist.isNotEmpty)
          ...validation.checklist.map(
            (item) => CheckboxListTile(
              value: item.isOk,
              onChanged: null,
              title: Text(localizedExamMessage(l10n, item.message)),
              subtitle: item.action == null ? null : Text(item.action!),
            ),
          )
        else ...[
          CheckboxListTile(
            value: draft.items.isNotEmpty,
            onChanged: null,
            title: Text(l10n.examReviewHasQuestions),
          ),
          CheckboxListTile(
            value: validation?.canSave ?? false,
            onChanged: null,
            title: Text(l10n.examReviewCanSave),
          ),
          CheckboxListTile(
            value: draft.items.every(
              (item) =>
                  item.question?.questionFileId != null || item.question != null,
            ),
            onChanged: null,
            title: Text(l10n.examReviewSnapshotsReady),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: draft.isEditable ? onRegenerate : null,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l10n.examRegenerateDraft),
        ),
      ],
    );
  }
}
