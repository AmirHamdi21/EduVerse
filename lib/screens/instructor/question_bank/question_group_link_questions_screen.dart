import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionGroupLinkQuestionsScreen extends StatelessWidget {
  const QuestionGroupLinkQuestionsScreen({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionGroupCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..load(groupId),
      child: const _QuestionGroupLinkQuestionsView(),
    );
  }
}

class _QuestionGroupLinkQuestionsView extends StatefulWidget {
  const _QuestionGroupLinkQuestionsView();

  @override
  State<_QuestionGroupLinkQuestionsView> createState() =>
      _QuestionGroupLinkQuestionsViewState();
}

class _QuestionGroupLinkQuestionsViewState
    extends State<_QuestionGroupLinkQuestionsView> {
  final Set<int> _selected = <int>{};
  final TextEditingController _search = TextEditingController();
  List<QuestionBankQuestionModel> _candidates = const [];
  bool _loadingCandidates = false;
  bool _loadedOnce = false;
  int? _chapterId;
  QuestionBankStatus? _status;
  QuestionBankType? _type;
  QuestionBankDifficulty? _difficulty;
  BloomLevel? _bloomLevel;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.qbAddExistingQuestions)),
      body: BlocConsumer<QuestionGroupCubit, QuestionGroupState>(
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
          if (state.group != null && !_loadedOnce && !_loadingCandidates) {
            _loadCandidates(context, state);
          }
        },
        builder: (context, state) {
          if (state.isLoading || state.group == null || _loadingCandidates) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: QuestionBankSkeletons(),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            children: [
              QuestionFormHero(
                title: l10n.qbAddExistingQuestions,
                subtitle: state.group!.title ?? l10n.questionBankGroupDetails,
                tiles: {
                  l10n.questions: _candidates.length.toString(),
                  l10n.selected: _selected.length.toString(),
                },
              ),
              const SizedBox(height: 18),
              _FilterPanel(
                state: state,
                chapterId: _chapterId,
                status: _status,
                type: _type,
                difficulty: _difficulty,
                bloomLevel: _bloomLevel,
                search: _search,
                onChapterChanged: (value) {
                  setState(() => _chapterId = value);
                  _loadCandidates(context, state);
                },
                onStatusChanged: (value) {
                  setState(() => _status = value);
                  _loadCandidates(context, state);
                },
                onTypeChanged: (value) {
                  setState(() => _type = value);
                  _loadCandidates(context, state);
                },
                onDifficultyChanged: (value) {
                  setState(() => _difficulty = value);
                  _loadCandidates(context, state);
                },
                onBloomChanged: (value) {
                  setState(() => _bloomLevel = value);
                  _loadCandidates(context, state);
                },
                onSearch: () => _loadCandidates(context, state),
              ),
              const SizedBox(height: 18),
              if (_candidates.isEmpty)
                QuestionBankEmptyState(
                  title: l10n.questionBankEmptyTitle,
                  message: l10n.questionBankEmptyMessage,
                )
              else
                ..._candidates.map(
                  (question) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: CheckboxListTile(
                      value: _selected.contains(question.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selected.add(question.id);
                          } else {
                            _selected.remove(question.id);
                          }
                        });
                      },
                      title: Text(
                        question.questionText ??
                            '${l10n.questionBankImageQuestion} ${question.id}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${localizedQuestionStatus(l10n, question.status)} • ${localizedQuestionType(l10n, question.questionType)}',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _selected.isEmpty || state.isMutating
                    ? null
                    : () async {
                        final ok = await context
                            .read<QuestionGroupCubit>()
                            .linkExistingQuestions(_selected.toList());
                        if (ok && context.mounted) {
                          context.go(
                            '/instructor/question-bank/groups/${state.group!.id}',
                          );
                        }
                      },
                icon: const Icon(Icons.add_link_rounded),
                label: Text(l10n.qbAddExistingQuestions),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadCandidates(
    BuildContext context,
    QuestionGroupState state,
  ) async {
    final group = state.group;
    if (group == null) return;
    setState(() => _loadingCandidates = true);
    final result = await QuestionBankService(coreApiClient: CoreApiClient())
        .getQuestions(
          courseId: group.courseId,
          chapterId: _chapterId,
          status: _status,
          questionType: _type,
          difficulty: _difficulty,
          bloomLevel: _bloomLevel,
          search: _search.text.trim().isEmpty ? null : _search.text.trim(),
          limit: 100,
        );
    if (!mounted) return;
    final existingIds = state.questions.map((q) => q.id).toSet();
    setState(() {
      _loadingCandidates = false;
      _loadedOnce = true;
      _candidates = (result.data?.data ?? const <QuestionBankQuestionModel>[])
          .where((question) => !existingIds.contains(question.id))
          .where((question) => question.status != QuestionBankStatus.archived)
          .toList();
    });
    if (!result.isSuccess && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error?.message ?? l10n.operationFailed)),
      );
    }
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.state,
    required this.chapterId,
    required this.status,
    required this.type,
    required this.difficulty,
    required this.bloomLevel,
    required this.search,
    required this.onChapterChanged,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
    required this.onBloomChanged,
    required this.onSearch,
  });

  final QuestionGroupState state;
  final int? chapterId;
  final QuestionBankStatus? status;
  final QuestionBankType? type;
  final QuestionBankDifficulty? difficulty;
  final BloomLevel? bloomLevel;
  final TextEditingController search;
  final ValueChanged<int?> onChapterChanged;
  final ValueChanged<QuestionBankStatus?> onStatusChanged;
  final ValueChanged<QuestionBankType?> onTypeChanged;
  final ValueChanged<QuestionBankDifficulty?> onDifficultyChanged;
  final ValueChanged<BloomLevel?> onBloomChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          TextField(
            controller: search,
            decoration: InputDecoration(
              labelText: l10n.questionBankSearchQuestionTextOnly,
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FilterDropdown<int?>(
                label: l10n.chapter,
                value: chapterId,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.allChapters),
                  ),
                  ...state.chapters.map(
                    (chapter) => DropdownMenuItem<int?>(
                      value: chapter.id,
                      child: Text(
                        chapter.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: onChapterChanged,
              ),
              _FilterDropdown<QuestionBankStatus?>(
                label: l10n.status,
                value: status,
                items: [
                  DropdownMenuItem<QuestionBankStatus?>(
                    value: null,
                    child: Text(l10n.allStates),
                  ),
                  ...QuestionBankStatus.values.map(
                    (value) => DropdownMenuItem<QuestionBankStatus?>(
                      value: value,
                      child: Text(localizedQuestionStatus(l10n, value)),
                    ),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
              _FilterDropdown<QuestionBankType?>(
                label: l10n.type,
                value: type,
                items: [
                  DropdownMenuItem<QuestionBankType?>(
                    value: null,
                    child: Text(l10n.type),
                  ),
                  ...QuestionBankType.values.map(
                    (value) => DropdownMenuItem<QuestionBankType?>(
                      value: value,
                      child: Text(localizedQuestionType(l10n, value)),
                    ),
                  ),
                ],
                onChanged: onTypeChanged,
              ),
              _FilterDropdown<QuestionBankDifficulty?>(
                label: l10n.difficulty,
                value: difficulty,
                items: [
                  DropdownMenuItem<QuestionBankDifficulty?>(
                    value: null,
                    child: Text(l10n.difficulty),
                  ),
                  ...QuestionBankDifficulty.values.map(
                    (value) => DropdownMenuItem<QuestionBankDifficulty?>(
                      value: value,
                      child: Text(localizedDifficulty(l10n, value)),
                    ),
                  ),
                ],
                onChanged: onDifficultyChanged,
              ),
              _FilterDropdown<BloomLevel?>(
                label: l10n.bloomLevel,
                value: bloomLevel,
                items: [
                  DropdownMenuItem<BloomLevel?>(
                    value: null,
                    child: Text(l10n.bloomLevel),
                  ),
                  ...BloomLevel.values.map(
                    (value) => DropdownMenuItem<BloomLevel?>(
                      value: value,
                      child: Text(localizedBloomLevel(l10n, value)),
                    ),
                  ),
                ],
                onChanged: onBloomChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
