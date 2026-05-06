import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bulk_create_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bulk_create_state.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionBankBulkCreateScreen extends StatelessWidget {
  const QuestionBankBulkCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionBulkCreateCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
        enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
      )..initialize(),
      child: const _QuestionBankBulkCreateView(),
    );
  }
}

class _QuestionBankBulkCreateView extends StatelessWidget {
  const _QuestionBankBulkCreateView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.questionBankBulkCreate),
          leading: IconButton(
            onPressed: () => _handleBack(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: BlocConsumer<QuestionBulkCreateCubit, QuestionBulkCreateState>(
          listenWhen: (previous, current) {
            final previousMessage =
                previous.errorMessage ?? previous.successMessage;
            final currentMessage =
                current.errorMessage ?? current.successMessage;
            return currentMessage != null && currentMessage != previousMessage;
          },
          listener: (context, state) {
            final message = state.errorMessage ?? state.successMessage;
            if (message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizedQuestionBankMessage(l10n, message)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: QuestionBankSkeletons(itemCount: 4),
              );
            }
            final hasCreated = state.createdQuestions.isNotEmpty;
            final hasFailures = state.failedRows.isNotEmpty;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                QuestionFormHero(
                  title: l10n.questionBankBulkCreate,
                  subtitle: l10n.questionBankBulkSubtitle,
                  tiles: {
                    l10n.qbBulkRows: state.rows.length.toString(),
                    l10n.course: state.courseId?.toString() ?? '-',
                    l10n.chapter: state.chapters.length.toString(),
                  },
                ),
                const SizedBox(height: 18),
                QuestionBulkValidationPanel(
                  message: state.errorMessage == null
                      ? null
                      : localizedQuestionBankMessage(l10n, state.errorMessage!),
                ),
                if (state.failedRows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _BulkFailureReportPanel(state: state),
                ],
                if (!hasCreated || hasFailures) ...[
                  if (state.errorMessage != null) const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 220,
                          maxWidth: 320,
                        ),
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: state.courseId,
                          decoration: InputDecoration(
                            labelText: l10n.course,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: state.courses
                              .map(
                                (course) => DropdownMenuItem(
                                  value: course.courseId,
                                  child: Text(
                                    '${course.course.code} - ${course.course.name}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: context
                              .read<QuestionBulkCreateCubit>()
                              .selectCourse,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: state.courseId == null
                            ? null
                            : () => _showCreateChapter(context),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.qbCreateChapter),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.questionBankBulkChapterPerRow,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuestionBulkEditor(
                    rowCount: state.rows.length,
                    onAddRow: context.read<QuestionBulkCreateCubit>().addRow,
                    children: state.rows
                        .map(
                          (row) => QuestionBulkRowCard(
                            row: row,
                            chapters: state.chapters,
                            onChanged: context
                                .read<QuestionBulkCreateCubit>()
                                .updateRow,
                            onTypeChanged: (type) => context
                                .read<QuestionBulkCreateCubit>()
                                .updateRowType(row.localId, type),
                            onUploadImage: (path) => context
                                .read<QuestionBulkCreateCubit>()
                                .uploadRowQuestionImage(
                                  localId: row.localId,
                                  path: path,
                                ),
                            onRemoveImage: row.questionFileId == null
                                ? null
                                : () => context
                                      .read<QuestionBulkCreateCubit>()
                                      .removeRowQuestionImage(row.localId),
                            onUploadAttachments: (paths) => context
                                .read<QuestionBulkCreateCubit>()
                                .uploadRowAttachments(
                                  localId: row.localId,
                                  paths: paths,
                                ),
                            onAttachmentChanged: (attachment) => context
                                .read<QuestionBulkCreateCubit>()
                                .updateRowAttachment(
                                  localId: row.localId,
                                  attachment: attachment,
                                ),
                            onRemoveAttachment: (fileId) => context
                                .read<QuestionBulkCreateCubit>()
                                .removeRowAttachment(
                                  localId: row.localId,
                                  fileId: fileId,
                                ),
                            onReorderAttachments: (orderedFileIds) => context
                                .read<QuestionBulkCreateCubit>()
                                .reorderRowAttachments(
                                  localId: row.localId,
                                  orderedFileIds: orderedFileIds,
                                ),
                            onRemove: state.rows.length <= 1
                                ? null
                                : () => context
                                      .read<QuestionBulkCreateCubit>()
                                      .removeRow(row.localId),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            final ok = await context
                                .read<QuestionBulkCreateCubit>()
                                .submit();
                            if (!ok || !context.mounted) return;
                          },
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(l10n.qbSubmitBulk),
                  ),
                ],
                if (hasCreated) ...[
                  const SizedBox(height: 18),
                  _BulkCreateResultPanel(state: state),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final cubit = context.read<QuestionBulkCreateCubit>();
    if (cubit.state.createdQuestions.isEmpty &&
        _hasPendingUploads(cubit.state.rows)) {
      final l10n = AppLocalizations.of(context);
      final discard =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.qbDiscardUploadsTitle),
              content: Text(l10n.qbDiscardUploadsBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.discard),
                ),
              ],
            ),
          ) ??
          false;
      if (!discard || !context.mounted) return;
      await cubit.discardPendingUploads();
    }
    if (context.mounted) context.pop();
  }

  bool _hasPendingUploads(List<dynamic> rows) {
    for (final row in rows) {
      if (row.questionFileId != null || row.attachments.isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _showCreateChapter(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QuestionChapterFormCard(
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSubmit: (name, order, _) async {
                await context.read<QuestionBulkCreateCubit>().createChapter(
                  name: name,
                  chapterOrder: order,
                );
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BulkFailureReportPanel extends StatelessWidget {
  const _BulkFailureReportPanel({required this.state});

  final QuestionBulkCreateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = state.failureReportMessage ?? state.errorMessage;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.qbBulkFailureReportTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message == null
                ? l10n.qbBulkFailureReportBody
                : localizedQuestionBankMessage(l10n, message),
          ),
          const SizedBox(height: 10),
          ...state.failedRows
              .take(8)
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${l10n.qbQuestionRow} ${row.localId}: ${row.error == null ? l10n.qbRowKeptEditable : localizedQuestionBankMessage(l10n, row.error!)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          if (state.failedRows.length > 8)
            Text(l10n.qbMoreFailedRows(state.failedRows.length - 8)),
        ],
      ),
    );
  }
}

class _BulkCreateResultPanel extends StatelessWidget {
  const _BulkCreateResultPanel({required this.state});

  final QuestionBulkCreateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<QuestionBulkCreateCubit>();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.qbBulkCreatedDraftSummary(state.createdQuestions.length),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(l10n.qbQuestionCreatedDraftBody),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: state.isSubmitting
                      ? null
                      : () => cubit.statusCreatedQuestions('submit-for-review'),
                  child: Text(l10n.submitForReview),
                ),
                FilledButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => cubit.statusCreatedQuestions('approve'),
                  child: Text(l10n.qbApprove),
                ),
                TextButton(
                  onPressed: () => context.go('/instructor/question-bank'),
                  child: Text(l10n.questionBank),
                ),
                TextButton(
                  onPressed: cubit.resetAfterSuccess,
                  child: Text(l10n.qbCreateMoreQuestions),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
