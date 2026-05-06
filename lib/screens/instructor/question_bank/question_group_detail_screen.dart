import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionGroupDetailScreen extends StatelessWidget {
  const QuestionGroupDetailScreen({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionGroupCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..load(groupId),
      child: const _QuestionGroupDetailView(),
    );
  }
}

class _QuestionGroupDetailView extends StatefulWidget {
  const _QuestionGroupDetailView();

  @override
  State<_QuestionGroupDetailView> createState() =>
      _QuestionGroupDetailViewState();
}

class _QuestionGroupDetailViewState extends State<_QuestionGroupDetailView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionBankGroupDetails),
        actions: [
          BlocBuilder<QuestionGroupCubit, QuestionGroupState>(
            builder: (context, state) {
              final group = state.group;
              return Row(
                children: [
                  IconButton(
                    tooltip: l10n.qbEditGroup,
                    onPressed: group == null
                        ? null
                        : () => context.push(
                            '/instructor/question-bank/groups/${group.id}/edit',
                          ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.qbDeleteGroup,
                    onPressed: group == null
                        ? null
                        : () => _delete(context, group.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
        },
        builder: (context, state) {
          final group = state.group;
          if (state.isLoading || group == null) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: QuestionBankSkeletons(),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              QuestionBankHeroHeader(
                title: group.title ?? l10n.questionBankGroupDetails,
                subtitle:
                    group.sharedPrompt ??
                    l10n.questionBankGroupDeleteKeepsQuestions,
                stats: {
                  l10n.type: localizedGroupType(l10n, group.groupType),
                  l10n.questions: group.totalQuestions.toString(),
                  l10n.approved: group.approvedQuestions.toString(),
                  l10n.qbGroupImage: group.sharedFileId?.toString() ?? '-',
                },
              ),
              const SizedBox(height: 18),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.icon(
                  onPressed: state.isMutating
                      ? null
                      : () => _showCreateChapter(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.qbCreateChapter),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push(
                      '/instructor/question-bank/groups/${group.id}/add-questions',
                    ),
                    icon: const Icon(Icons.playlist_add_rounded),
                    label: Text(l10n.qbGroupedBatchCreate),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: state.isMutating
                        ? null
                        : () => context.push(
                            '/instructor/question-bank/groups/${group.id}/link-questions',
                          ),
                    icon: const Icon(Icons.add_link_rounded),
                    label: Text(l10n.qbAddExistingQuestions),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              QuestionGroupReorderList(
                questions: state.questions,
                onReorder: context.read<QuestionGroupCubit>().reorderQuestions,
                onEdit: (question) => context.push(
                  '/instructor/question-bank/${question.id}/edit',
                ),
                onDelete: (question) =>
                    _removeQuestionFromGroup(context, question.id),
              ),
              const SizedBox(height: 18),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeQuestionFromGroup(
    BuildContext context,
    int questionId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.qbRemoveFromGroup),
            content: Text(l10n.qbRemoveFromGroupBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.qbRemoveFromGroup),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    await context.read<QuestionGroupCubit>().removeQuestionFromGroup(
      questionId,
    );
  }

  Future<void> _delete(BuildContext context, int groupId) async {
    final l10n = AppLocalizations.of(context);
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.qbDeleteGroup),
            content: Text(l10n.qbGroupDeleteBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.qbDeleteGroup),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    final deleted = await context.read<QuestionGroupCubit>().deleteGroup(
      groupId,
    );
    if (deleted && context.mounted) context.go('/instructor/question-bank');
  }

  Future<void> _showCreateChapter(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: QuestionChapterFormCard(
            onCancel: () => Navigator.of(dialogContext).pop(),
            onSubmit: (name, order, _) async {
              await context.read<QuestionGroupCubit>().createChapter(
                name: name,
                chapterOrder: order,
              );
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
          ),
        ),
      ),
    );
  }
}
