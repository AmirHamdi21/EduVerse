import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionBank),
        actions: [
          BlocBuilder<QuestionBankCubit, QuestionBankState>(
            builder: (context, state) => IconButton(
              tooltip: state.isSelectionMode
                  ? l10n.cancel
                  : l10n.qbSelectQuestions,
              onPressed: () => context
                  .read<QuestionBankCubit>()
                  .setSelectionMode(!state.isSelectionMode),
              icon: Icon(
                state.isSelectionMode
                    ? Icons.close_rounded
                    : Icons.checklist_rounded,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.qbManageChapters,
            onPressed: () => context.push('/instructor/question-bank/chapters'),
            icon: const Icon(Icons.view_list_outlined),
          ),
          IconButton(
            tooltip: l10n.qbGroups,
            onPressed: () => context.push('/instructor/question-bank/groups'),
            icon: const Icon(Icons.folder_copy_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'createGroup') {
                context.push('/instructor/question-bank/groups/create');
              } else if (value == 'bulkCreate') {
                context.push('/instructor/question-bank/bulk-create');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'createGroup',
                child: Text(l10n.qbCreateGroup),
              ),
              PopupMenuItem(
                value: 'bulkCreate',
                child: Text(l10n.questionBankBulkCreate),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/instructor/question-bank/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.questionBankCreateQuestion),
      ),
      body: BlocConsumer<QuestionBankCubit, QuestionBankState>(
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
              SnackBar(
                content: Text(localizedQuestionBankMessage(l10n, message)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.questions.isEmpty) {
            return const SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: QuestionBankSkeletons(itemCount: 5),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<QuestionBankCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                QuestionBankHeroHeader(
                  title: l10n.questionBankHeroTitle,
                  subtitle: l10n.questionBankHeroSubtitle,
                  stats: {
                    l10n.total: state.total.toString(),
                    l10n.approved: state.approvedCount.toString(),
                    l10n.draft: state.draftCount.toString(),
                    l10n.qbUnderReview: state.underReviewCount.toString(),
                    l10n.qbRejected: state.rejectedCount.toString(),
                    l10n.archived: state.archivedCount.toString(),
                    l10n.questionBankAttachedGrouped: state
                        .attachedOrGroupedCount
                        .toString(),
                  },
                ),
                const SizedBox(height: 16),
                QuestionBankFilterCard(
                  searchController: _searchController,
                  searchLabel: l10n.questionBankSearchQuestionTextOnly,
                  onSearchChanged: (value) => context
                      .read<QuestionBankCubit>()
                      .setFilters(search: value),
                  children: [
                    _CourseFilter(state: state),
                    _EnumFilter<QuestionBankStatus>(
                      value: state.selectedStatus,
                      label: l10n.status,
                      values: QuestionBankStatus.values,
                      text: (value) => localizedQuestionStatus(l10n, value),
                      onChanged: (value) =>
                          context.read<QuestionBankCubit>().setFilters(
                            status: value,
                            clearStatus: value == null,
                          ),
                    ),
                    _EnumFilter<QuestionBankType>(
                      value: state.selectedType,
                      label: l10n.type,
                      values: QuestionBankType.values,
                      text: (value) => localizedQuestionType(l10n, value),
                      onChanged: (value) => context
                          .read<QuestionBankCubit>()
                          .setFilters(type: value, clearType: value == null),
                    ),
                    _ChapterFilter(state: state),
                    _EnumFilter<QuestionBankDifficulty>(
                      value: state.selectedDifficulty,
                      label: l10n.difficulty,
                      values: QuestionBankDifficulty.values,
                      text: (value) => localizedDifficulty(l10n, value),
                      onChanged: (value) =>
                          context.read<QuestionBankCubit>().setFilters(
                            difficulty: value,
                            clearDifficulty: value == null,
                          ),
                    ),
                    _EnumFilter<BloomLevel>(
                      value: state.selectedBloomLevel,
                      label: l10n.bloomLevel,
                      values: BloomLevel.values,
                      text: (value) => localizedBloomLevel(l10n, value),
                      onChanged: (value) =>
                          context.read<QuestionBankCubit>().setFilters(
                            bloomLevel: value,
                            clearBloom: value == null,
                          ),
                    ),
                    _BoolFilter(
                      value: state.hasAttachments,
                      label: l10n.attachments,
                      onChanged: (value) =>
                          context.read<QuestionBankCubit>().setFilters(
                            hasAttachments: value,
                            clearHasAttachments: value == null,
                          ),
                    ),
                    _GroupFilter(state: state),
                  ],
                ),
                const SizedBox(height: 18),
                if (state.isSelectionMode) ...[
                  _BatchActionBar(state: state),
                  const SizedBox(height: 12),
                ],
                if (state.errorMessage != null)
                  _ErrorRetry(
                    message: state.errorMessage!,
                    onRetry: () => context.read<QuestionBankCubit>().refresh(),
                  )
                else if (state.questions.isEmpty)
                  QuestionBankEmptyState(
                    title: l10n.questionBankEmptyTitle,
                    message: l10n.questionBankEmptyMessage,
                    action: FilledButton.icon(
                      onPressed: () =>
                          context.push('/instructor/question-bank/create'),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.questionBankCreateQuestion),
                    ),
                  )
                else
                  ...state.questions.map(
                    (question) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuestionBankCard(
                        question: question,
                        onTap: () => context.push(
                          '/instructor/question-bank/${question.id}',
                        ),
                        onEdit: () => context.push(
                          '/instructor/question-bank/${question.id}/edit',
                        ),
                        selectionMode: state.isSelectionMode,
                        isSelected:
                            state.selectedQuestionIds.contains(question.id),
                        onSelectionChanged: (_) => context
                            .read<QuestionBankCubit>()
                            .toggleQuestionSelection(question.id),
                        onDelete: () async {
                          final ok = await _confirmDeleteQuestion(context);
                          if (ok && context.mounted) {
                            await context
                                .read<QuestionBankCubit>()
                                .deleteQuestion(question.id);
                          }
                        },
                      ),
                    ),
                  ),
                if (state.hasMore)
                  Center(
                    child: OutlinedButton(
                      onPressed: state.isLoadingMore
                          ? null
                          : () => context.read<QuestionBankCubit>().loadMore(),
                      child: Text(l10n.loadMore),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDeleteQuestion(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.qbDeleteQuestion),
            content: Text(l10n.qbDeleteQuestionBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.qbDeleteQuestion),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _CourseFilter extends StatelessWidget {
  const _CourseFilter({required this.state});

  final QuestionBankState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<int?>(
        isExpanded: true,
        initialValue: state.selectedCourseId,
        decoration: InputDecoration(
          labelText: l10n.course,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: [
          DropdownMenuItem<int?>(
            value: null,
            child: Text(l10n.allCourses, overflow: TextOverflow.ellipsis),
          ),
          ...state.teachingCourses.map(
            (course) => DropdownMenuItem<int?>(
              value: course.courseId,
              child: Text(
                '${course.course.code} - ${course.course.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) =>
            context.read<QuestionBankCubit>().selectCourse(value),
      ),
    );
  }
}

class _ChapterFilter extends StatelessWidget {
  const _ChapterFilter({required this.state});

  final QuestionBankState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<int?>(
        isExpanded: true,
        initialValue: state.selectedChapterId,
        decoration: InputDecoration(
          labelText: l10n.chapter,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: [
          DropdownMenuItem<int?>(
            value: null,
            child: Text(l10n.allChapters, overflow: TextOverflow.ellipsis),
          ),
          ...state.chapters.map(
            (chapter) => DropdownMenuItem<int?>(
              value: chapter.id,
              child: Text(chapter.name, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: (value) => context.read<QuestionBankCubit>().setFilters(
          chapterId: value,
          clearChapter: value == null,
        ),
      ),
    );
  }
}

class _GroupFilter extends StatelessWidget {
  const _GroupFilter({required this.state});

  final QuestionBankState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<int?>(
        isExpanded: true,
        initialValue: state.selectedGroupId,
        decoration: InputDecoration(
          labelText: l10n.qbGroups,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: [
          DropdownMenuItem<int?>(
            value: null,
            child: Text(l10n.allStates, overflow: TextOverflow.ellipsis),
          ),
          ...state.groups.map(
            (group) => DropdownMenuItem<int?>(
              value: group.id,
              child: Text(
                group.title ?? '${l10n.qbGroups} ${group.id}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) => context.read<QuestionBankCubit>().setFilters(
          groupId: value,
          clearGroup: value == null,
        ),
      ),
    );
  }
}

class _BoolFilter extends StatelessWidget {
  const _BoolFilter({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool? value;
  final String label;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<bool?>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: [
          DropdownMenuItem<bool?>(
            value: null,
            child: Text(l10n.allStates, overflow: TextOverflow.ellipsis),
          ),
          DropdownMenuItem<bool?>(
            value: true,
            child: Text(l10n.yes, overflow: TextOverflow.ellipsis),
          ),
          DropdownMenuItem<bool?>(
            value: false,
            child: Text(l10n.no, overflow: TextOverflow.ellipsis),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({required this.state});

  final QuestionBankState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<QuestionBankCubit>();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.qbSelectedCount(state.selectedQuestionIds.length),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            FilledButton.tonal(
              onPressed: state.hasSelectedQuestions
                  ? () => cubit.batchStatusAction('submit-for-review')
                  : null,
              child: Text(l10n.submitForReview),
            ),
            FilledButton.tonal(
              onPressed: state.hasSelectedQuestions
                  ? () => cubit.batchStatusAction('approve')
                  : null,
              child: Text(l10n.qbApprove),
            ),
            FilledButton.tonal(
              onPressed: state.hasSelectedQuestions
                  ? () => cubit.batchStatusAction('archive')
                  : null,
              child: Text(l10n.archive),
            ),
            FilledButton.tonal(
              onPressed: state.hasSelectedQuestions
                  ? () => cubit.batchStatusAction('restore')
                  : null,
              child: Text(l10n.restore),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnumFilter<T> extends StatelessWidget {
  const _EnumFilter({
    required this.value,
    required this.label,
    required this.values,
    required this.text,
    required this.onChanged,
  });

  final T? value;
  final String label;
  final List<T> values;
  final String Function(T) text;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T?>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: [
          DropdownMenuItem<T?>(
            value: null,
            child: Text(l10n.allStates, overflow: TextOverflow.ellipsis),
          ),
          ...values.map(
            (item) => DropdownMenuItem<T?>(
              value: item,
              child: Text(text(item), overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
