import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionGroupAddQuestionsScreen extends StatelessWidget {
  const QuestionGroupAddQuestionsScreen({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionGroupCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..load(groupId),
      child: const _QuestionGroupAddQuestionsView(),
    );
  }
}

class _QuestionGroupAddQuestionsView extends StatefulWidget {
  const _QuestionGroupAddQuestionsView();

  @override
  State<_QuestionGroupAddQuestionsView> createState() =>
      _QuestionGroupAddQuestionsViewState();
}

class _QuestionGroupAddQuestionsViewState
    extends State<_QuestionGroupAddQuestionsView> {
  int _nextRowId = 2;
  List<QuestionBulkRowModel> _rows = const [QuestionBulkRowModel(localId: 1)];

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
          title: Text(l10n.qbGroupedBatchCreate),
          leading: IconButton(
            onPressed: () => _handleBack(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: BlocConsumer<QuestionGroupCubit, QuestionGroupState>(
          listenWhen: (previous, current) {
            final previousMessage =
                previous.errorMessage ?? previous.actionMessage;
            final currentMessage =
                current.errorMessage ?? current.actionMessage;
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
            final hasCreated = state.createdQuestions.isNotEmpty;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                QuestionFormHero(
                  title: l10n.qbGroupedBatchCreate,
                  subtitle: group.title ?? l10n.questionBankGroupDetails,
                  tiles: {
                    l10n.questions: _rows.length.toString(),
                    l10n.course: group.courseId.toString(),
                    l10n.chapter: state.chapters.length.toString(),
                  },
                ),
                const SizedBox(height: 18),
                if (!hasCreated) ...[
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
                  const SizedBox(height: 14),
                  QuestionGroupBatchEditor(
                    rows: _rows,
                    chapters: state.chapters,
                    onChanged: _updateRow,
                    onUploadImage: (localId, path) =>
                        _uploadGroupedQuestionImage(context, localId, path),
                    onRemoveImage: (row) =>
                        _removeGroupedQuestionImage(context, row),
                    onUploadAttachments: (localId, paths) =>
                        _uploadGroupedQuestionAttachments(
                          context,
                          localId,
                          paths,
                        ),
                    onAttachmentChanged: _updateGroupedQuestionAttachment,
                    onRemoveAttachment: (localId, fileId) =>
                        _removeGroupedQuestionAttachment(
                          context,
                          localId,
                          fileId,
                        ),
                    onReorderAttachments: _reorderGroupedQuestionAttachments,
                    onAddRow: _addRow,
                    onRemoveRow: _removeRow,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: state.isMutating
                        ? null
                        : () => _submitGroupedBatch(context, group.courseId),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(l10n.qbSubmitBulk),
                  ),
                ] else
                  _GroupedCreateResultPanel(state: state),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addRow() {
    if (_rows.length >= 50) return;
    setState(() {
      _rows = [..._rows, QuestionBulkRowModel(localId: _nextRowId++)];
    });
  }

  void _removeRow(int localId) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows = _rows.where((row) => row.localId != localId).toList();
    });
  }

  void _updateRow(QuestionBulkRowModel updated) {
    setState(() {
      _rows = [
        for (final row in _rows)
          if (row.localId == updated.localId)
            updated.copyWith(clearError: true)
          else
            row,
      ];
    });
  }

  Future<void> _uploadGroupedQuestionImage(
    BuildContext context,
    int localId,
    String path,
  ) async {
    final fileId = await context.read<QuestionGroupCubit>().uploadQuestionImage(
      path,
    );
    if (fileId == null || !mounted) return;
    setState(() {
      _rows = [
        for (final row in _rows)
          if (row.localId == localId)
            row.copyWith(questionFileId: fileId, clearError: true)
          else
            row,
      ];
    });
  }

  Future<void> _removeGroupedQuestionImage(
    BuildContext context,
    QuestionBulkRowModel row,
  ) async {
    final fileId = row.questionFileId;
    if (fileId != null) {
      await context.read<QuestionGroupCubit>().deleteUploadedQuestionImage(
        fileId,
      );
    }
    if (!mounted) return;
    setState(() {
      _rows = [
        for (final item in _rows)
          if (item.localId == row.localId)
            item.copyWith(
              clearQuestionFile: true,
              questionFileCaption: '',
              questionFileAltText: '',
              clearError: true,
            )
          else
            item,
      ];
    });
  }

  Future<void> _uploadGroupedQuestionAttachments(
    BuildContext context,
    int localId,
    List<String> paths,
  ) async {
    final attachments = <QuestionAttachmentPayload>[];
    for (final path in paths) {
      final fileId = await context
          .read<QuestionGroupCubit>()
          .uploadQuestionImage(path);
      if (fileId == null || !mounted) return;
      attachments.add(QuestionAttachmentPayload(fileId: fileId));
    }
    setState(() {
      _rows = _rows
          .map(
            (row) => row.localId == localId
                ? row.copyWith(
                    attachments: _normalizeAttachments([
                      ...row.attachments,
                      ...attachments,
                    ]),
                  )
                : row,
          )
          .toList();
    });
  }

  void _updateGroupedQuestionAttachment(
    int localId,
    QuestionAttachmentPayload attachment,
  ) {
    setState(() {
      _rows = _rows
          .map(
            (row) => row.localId == localId
                ? row.copyWith(
                    attachments: row.attachments
                        .map(
                          (item) => item.fileId == attachment.fileId
                              ? attachment
                              : item,
                        )
                        .toList(),
                  )
                : row,
          )
          .toList();
    });
  }

  Future<void> _removeGroupedQuestionAttachment(
    BuildContext context,
    int localId,
    int fileId,
  ) async {
    await context.read<QuestionGroupCubit>().deleteUploadedQuestionImage(
      fileId,
    );
    setState(() {
      _rows = _rows
          .map(
            (row) => row.localId == localId
                ? row.copyWith(
                    attachments: row.attachments
                        .where((attachment) => attachment.fileId != fileId)
                        .toList(),
                  )
                : row,
          )
          .toList();
    });
  }

  void _reorderGroupedQuestionAttachments(
    int localId,
    List<int> orderedFileIds,
  ) {
    final row = _rows.firstWhere((item) => item.localId == localId);
    final byId = {
      for (final attachment in row.attachments)
        if (attachment.fileId != null) attachment.fileId!: attachment,
    };
    setState(() {
      _rows = _rows
          .map(
            (item) => item.localId == localId
                ? item.copyWith(
                    attachments: _normalizeAttachments([
                      for (final fileId in orderedFileIds)
                        if (byId[fileId] != null) byId[fileId]!,
                    ]),
                  )
                : item,
          )
          .toList();
    });
  }

  List<QuestionAttachmentPayload> _normalizeAttachments(
    List<QuestionAttachmentPayload> attachments,
  ) {
    return [
      for (var i = 0; i < attachments.length; i++)
        attachments[i].copyWith(displayOrder: i, isPrimary: i == 0),
    ];
  }

  Future<void> _submitGroupedBatch(BuildContext context, int courseId) async {
    final payloads = _rows
        .map((row) => row.toPayload(courseId: courseId, defaultChapterId: null))
        .toList();
    var valid = true;
    setState(() {
      _rows = [
        for (var i = 0; i < _rows.length; i++)
          _rows[i].copyWith(
            error: payloads[i].validate(),
            clearError: payloads[i].validate() == null,
          ),
      ];
      valid = _rows.every((row) => row.error == null);
    });
    if (!valid) return;
    final created = await context
        .read<QuestionGroupCubit>()
        .addGroupedQuestions(payloads);
    if (!created || !mounted) return;
    setState(() {
      _rows = const [QuestionBulkRowModel(localId: 1)];
    });
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

  Future<void> _handleBack(BuildContext context) async {
    if (_hasPendingUploads(_rows)) {
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
      await _discardPendingUploads(context);
    }
    if (context.mounted) context.pop();
  }

  bool _hasPendingUploads(List<QuestionBulkRowModel> rows) {
    for (final row in rows) {
      if (row.questionFileId != null || row.attachments.isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _discardPendingUploads(BuildContext context) async {
    final cubit = context.read<QuestionGroupCubit>();
    final fileIds = <int>{};
    for (final row in _rows) {
      final questionFileId = row.questionFileId;
      if (questionFileId != null) fileIds.add(questionFileId);
      for (final attachment in row.attachments) {
        final fileId = attachment.fileId;
        if (fileId != null) fileIds.add(fileId);
      }
    }
    await cubit.discardUploadedQuestionImages(fileIds);
  }
}

class _GroupedCreateResultPanel extends StatelessWidget {
  const _GroupedCreateResultPanel({required this.state});

  final QuestionGroupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<QuestionGroupCubit>();
    final groupId = state.group?.id;
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
                  onPressed: state.isMutating
                      ? null
                      : () => cubit.statusCreatedQuestions('submit-for-review'),
                  child: Text(l10n.submitForReview),
                ),
                FilledButton(
                  onPressed: state.isMutating
                      ? null
                      : () => cubit.statusCreatedQuestions('approve'),
                  child: Text(l10n.qbApprove),
                ),
                TextButton(
                  onPressed: groupId == null
                      ? null
                      : () => context.go(
                          '/instructor/question-bank/groups/$groupId',
                        ),
                  child: Text(l10n.questionBankGroupDetails),
                ),
                TextButton(
                  onPressed: cubit.clearCreatedQuestions,
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
