import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_detail_cubit.dart';
import '../../../bloc/instructor/question_bank/question_detail_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_modern_tab_strip.dart';

class QuestionBankDetailScreen extends StatelessWidget {
  const QuestionBankDetailScreen({super.key, required this.questionId});

  final int questionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionDetailCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..load(questionId),
      child: const _QuestionBankDetailView(),
    );
  }
}

class _QuestionBankDetailView extends StatefulWidget {
  const _QuestionBankDetailView();

  @override
  State<_QuestionBankDetailView> createState() =>
      _QuestionBankDetailViewState();
}

class _QuestionBankDetailViewState extends State<_QuestionBankDetailView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionBankQuestionDetails),
        actions: [
          BlocBuilder<QuestionDetailCubit, QuestionDetailState>(
            builder: (context, state) {
              final question = state.question;
              return Row(
                children: [
                  IconButton(
                    onPressed: question == null
                        ? null
                        : () => context.push(
                            '/instructor/question-bank/${question.id}/edit',
                          ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.qbDeleteQuestion,
                    onPressed: question == null
                        ? null
                        : () => _deleteQuestion(context),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<QuestionDetailCubit, QuestionDetailState>(
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
          final question = state.question;
          if (state.isLoading || question == null) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: QuestionBankSkeletons(itemCount: 4),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              QuestionBankHeroHeader(
                title: question.questionText?.trim().isNotEmpty == true
                    ? question.questionText!
                    : l10n.questionBankImageQuestion,
                subtitle: l10n.questionBankQuestionDetails,
                stats: {
                  l10n.type: localizedQuestionType(l10n, question.questionType),
                  l10n.difficulty: localizedDifficulty(
                    l10n,
                    question.difficulty,
                  ),
                  l10n.status: localizedQuestionStatus(l10n, question.status),
                  l10n.attachments: question.attachments.length.toString(),
                },
              ),
              const SizedBox(height: 16),
              InstructorModernTabStrip(
                selectedIndex: _tab,
                onChanged: (value) => setState(() => _tab = value),
                tabs: [
                  InstructorModernTabItem(
                    icon: Icons.dashboard_outlined,
                    label: l10n.qbOverview,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.check_circle_outline,
                    label: l10n.qbAnswers,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.attach_file_rounded,
                    label: l10n.attachments,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.folder_copy_outlined,
                    label: l10n.qbGroups,
                  ),
                  InstructorModernTabItem(
                    icon: Icons.tune_rounded,
                    label: l10n.qbStatus,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _tabContent(context, question, state.isMutating),
            ],
          );
        },
      ),
    );
  }

  Widget _tabContent(
    BuildContext context,
    QuestionBankQuestionModel question,
    bool isMutating,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (_tab) {
      case 1:
        return _AnswersByType(question: question);
      case 2:
        return QuestionAttachmentManager(
          attachments: question.attachments,
          isMutating: isMutating,
          onAddByFileId:
              ({
                required fileId,
                required attachmentType,
                caption,
                altText,
                displayOrder,
                isPrimary,
              }) => context.read<QuestionDetailCubit>().addAttachmentByFileId(
                fileId: fileId,
                attachmentType: attachmentType,
                caption: caption,
                altText: altText,
                displayOrder: displayOrder,
                isPrimary: isPrimary,
              ),
          onUploadImage: context
              .read<QuestionDetailCubit>()
              .uploadAttachmentImage,
          onUpdate:
              ({
                required attachmentId,
                caption,
                altText,
                displayOrder,
                isPrimary,
              }) => context.read<QuestionDetailCubit>().updateAttachment(
                attachmentId: attachmentId,
                caption: caption,
                altText: altText,
                displayOrder: displayOrder,
                isPrimary: isPrimary,
              ),
          onReorder: context.read<QuestionDetailCubit>().reorderAttachments,
          onRemove: context.read<QuestionDetailCubit>().removeAttachment,
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () =>
                  context.push('/instructor/question-bank/groups/create'),
              icon: const Icon(Icons.create_new_folder_outlined),
              label: Text(l10n.qbCreateGroup),
            ),
            const SizedBox(height: 12),
            ...question.groups.map(
              (group) => Card(
                child: ListTile(
                  title: Text(
                    group.title ?? '${l10n.qbGroups} ${group.groupId}',
                  ),
                  subtitle: Text(localizedGroupType(l10n, group.groupType)),
                  onTap: () => context.push(
                    '/instructor/question-bank/groups/${group.groupId}',
                  ),
                ),
              ),
            ),
          ],
        );
      case 4:
        return QuestionStatusActions(
          status: question.status,
          onAction: context.read<QuestionDetailCubit>().statusAction,
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoCard(
              title: l10n.qbQuestionPrompt,
              icon: Icons.help_outline_rounded,
              child: Text(
                question.questionText?.trim().isNotEmpty == true
                    ? question.questionText!
                    : l10n.questionBankImageQuestion,
              ),
            ),
            const SizedBox(height: 12),
            if (question.hints?.trim().isNotEmpty == true) ...[
              _InfoCard(
                title: l10n.qbQuestionHints,
                icon: Icons.lightbulb_outline_rounded,
                child: Text(question.hints!),
              ),
              const SizedBox(height: 12),
            ],
            _MainQuestionImageCard(question: question),
            if (question.questionImageUrl != null ||
                question.questionFileId != null)
              const SizedBox(height: 12),
            _InfoCard(
              title: l10n.metadata,
              icon: Icons.info_outline_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallChip(localizedQuestionType(l10n, question.questionType)),
                  _SmallChip(localizedDifficulty(l10n, question.difficulty)),
                  _SmallChip(localizedBloomLevel(l10n, question.bloomLevel)),
                  _SmallChip(localizedQuestionStatus(l10n, question.status)),
                ],
              ),
            ),
          ],
        );
    }
  }

  Future<void> _deleteQuestion(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok =
        await showDialog<bool>(
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
    if (!ok || !context.mounted) return;
    final deleted = await context.read<QuestionDetailCubit>().deleteQuestion();
    if (deleted && context.mounted) context.go('/instructor/question-bank');
  }
}

class _AnswersByType extends StatelessWidget {
  const _AnswersByType({required this.question});

  final QuestionBankQuestionModel question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (question.questionType == QuestionBankType.mcq ||
        question.questionType == QuestionBankType.trueFalse) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: question.options
            .map(
              (option) => Card(
                child: ListTile(
                  leading: Icon(
                    option.isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: option.isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFF94A3B8),
                  ),
                  title: Text(option.optionText),
                  trailing: option.isCorrect
                      ? Chip(label: Text(l10n.correct))
                      : null,
                ),
              ),
            )
            .toList(),
      );
    }
    if (question.questionType == QuestionBankType.fillBlanks) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: question.fillBlanks
            .map(
              (blank) => Card(
                child: ListTile(
                  title: Text(blank.blankKey),
                  subtitle: Text(blank.acceptableAnswer),
                ),
              ),
            )
            .toList(),
      );
    }
    return _InfoCard(
      title: l10n.expectedAnswer,
      icon: Icons.notes_rounded,
      child: Text(
        question.expectedAnswerText?.trim().isNotEmpty == true
            ? question.expectedAnswerText!
            : l10n.questionBankEmptyMessage,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

class _MainQuestionImageCard extends StatelessWidget {
  const _MainQuestionImageCard({required this.question});

  final QuestionBankQuestionModel question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (question.questionImageUrl == null && question.questionFileId == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.image_outlined, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.questionBankImageQuestion,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push(
                    '/instructor/question-bank/${question.id}/edit',
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.edit),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (question.questionImageUrl != null)
              GestureDetector(
                onTap: () => _showPreview(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    question.questionImageUrl!,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 64),
                  ),
                ),
              )
            else
              Text(
                '${l10n.questionBankImageQuestion}: ${question.questionFileId}',
              ),
            if (question.questionFileCaption?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(question.questionFileCaption!),
            ],
            if (question.questionFileAltText?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                question.questionFileAltText!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showPreview(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.questionFileCaption?.trim().isNotEmpty == true
                            ? question.questionFileCaption!
                            : l10n.questionBankImageQuestion,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    question.questionImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 64),
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
