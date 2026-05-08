import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import 'question_bank_create_screen.dart';

class QuestionGroupAddQuestionsScreen extends StatelessWidget {
  const QuestionGroupAddQuestionsScreen({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => QuestionGroupCubit(
            questionBankService: QuestionBankService(
              coreApiClient: CoreApiClient(),
            ),
          )..load(groupId),
        ),
        BlocProvider(
          create: (_) => QuestionBankCubit(
            questionBankService: QuestionBankService(
              coreApiClient: CoreApiClient(),
            ),
            enrollmentService: EnrollmentService(
              coreApiClient: CoreApiClient(),
            ),
          )..initialize(),
        ),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: InstructorColors.background(isDark),
        appBar: AppBar(
          backgroundColor: InstructorColors.background(isDark),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.qbGroupedBatchCreate,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          leading: IconButton(
            onPressed: () => _handleBack(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
            ),
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
            final bankState = context.watch<QuestionBankCubit>().state;
            if (state.isLoading || group == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: const [QuestionBankSkeletons(itemCount: 3)],
              );
            }
            _ensureDefaultChapter(state);
            final hasCreated = state.createdQuestions.isNotEmpty;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                QuestionFormHero(
                  title: l10n.qbGroupedBatchCreate,
                  subtitle: group.title ?? l10n.questionBankGroupDetails,
                  tiles: {
                    l10n.questions: _rows.length.toString(),
                    l10n.course: _courseLabel(group, bankState),
                    l10n.chapter: state.chapters.length.toString(),
                  },
                ),
                const SizedBox(height: 18),
                if (!hasCreated) ...[
                  _CreateChapterActionButton(
                    isBusy: state.isMutating,
                    onPressed: () => _showCreateChapter(context, state),
                  ),
                  const SizedBox(height: 14),
                  QuestionGroupBatchEditor(
                    rows: _rows,
                    chapters: state.chapters,
                    isBusy: state.isMutating,
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
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: state.isMutating
                          ? null
                          : () => _submitGroupedBatch(context, group.courseId),
                      style: FilledButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: InstructorColors.primary
                            .withValues(alpha: 0.42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      icon: state.isMutating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        l10n.qbSubmitBulk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<QuestionGroupCubit>().state;
    _ensureDefaultChapter(state);
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

  void _ensureDefaultChapter(QuestionGroupState state) {
    if (state.chapters.isEmpty) return;
    final activeChapters = state.chapters
        .where((chapter) => chapter.isActive)
        .toList();
    final defaultChapterId = activeChapters.isNotEmpty
        ? activeChapters.first.id
        : state.chapters.first.id;
    if (_rows.every((row) => row.chapterId != null)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _rows = [
          for (final row in _rows)
            row.chapterId == null
                ? row.copyWith(chapterId: defaultChapterId, clearError: true)
                : row,
        ];
      });
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
    final cubit = context.read<QuestionGroupCubit>();
    final created = await cubit.addGroupedQuestions(payloads);
    if (!created || !mounted) return;
    _goToFreshGroupDetails(this.context, cubit.state.group?.id);
  }

  Future<void> _showCreateChapter(
    BuildContext context,
    QuestionGroupState state,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: QuestionChapterFormCard(
              suggestedOrder: _nextChapterOrder(state),
              occupiedOrders: state.chapters
                  .where((chapter) => chapter.isActive)
                  .map((chapter) => chapter.chapterOrder)
                  .toList(),
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
      ),
    );
  }

  int _nextChapterOrder(QuestionGroupState state) {
    final activeOrders = state.chapters
        .where((chapter) => chapter.isActive)
        .map((chapter) => chapter.chapterOrder)
        .where((order) => order > 0)
        .toList();
    if (activeOrders.isEmpty) return 1;
    activeOrders.sort();
    return activeOrders.last + 1;
  }

  Future<void> _handleBack(BuildContext context) async {
    final cubit = context.read<QuestionGroupCubit>();
    final groupId = cubit.state.group?.id;
    if (cubit.state.createdQuestions.isNotEmpty && groupId != null) {
      _goToFreshGroupDetails(context, groupId);
      return;
    }
    if (_hasPendingUploads(_rows)) {
      final l10n = AppLocalizations.of(context);
      final discard =
          await showDialog<bool>(
            context: context,
            builder: (context) => QuestionFormDecisionDialog(
              title: l10n.qbDiscardUploadsTitle,
              message: l10n.qbDiscardUploadsBody,
              icon: Icons.cloud_off_outlined,
              color: InstructorColors.error,
              primaryLabel: l10n.discard,
              secondaryLabel: l10n.cancel,
              onPrimary: () => Navigator.of(context).pop(true),
              onSecondary: () => Navigator.of(context).pop(false),
            ),
          ) ??
          false;
      if (!discard || !context.mounted) return;
      await _discardPendingUploads(context);
    }
    if (context.mounted) context.pop();
  }

  void _goToFreshGroupDetails(BuildContext context, int? groupId) {
    if (groupId == null || !context.mounted) return;
    final refresh = DateTime.now().microsecondsSinceEpoch;
    context.go('/instructor/question-bank/groups/$groupId?refresh=$refresh');
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

  String _courseLabel(dynamic group, QuestionBankState state) {
    for (final course in state.teachingCourses) {
      if (course.courseId == group.courseId) {
        final code = course.course.code.trim();
        final name = course.course.name.trim();
        if (code.isNotEmpty && name.isNotEmpty) return '$code - $name';
        if (code.isNotEmpty) return code;
        if (name.isNotEmpty) return name;
      }
    }
    final code = group.courseCode?.toString().trim();
    final name = group.courseName?.toString().trim();
    if (code != null && code.isNotEmpty && name != null && name.isNotEmpty) {
      return '$code - $name';
    }
    if (code != null && code.isNotEmpty) return code;
    if (name != null && name.isNotEmpty) return name;
    return group.courseId.toString();
  }
}

class _CreateChapterActionButton extends StatelessWidget {
  const _CreateChapterActionButton({
    required this.isBusy,
    required this.onPressed,
  });

  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: OutlinedButton.icon(
          onPressed: isBusy ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: InstructorColors.teal.withValues(
              alpha: isDark ? 0.18 : 0.08,
            ),
            foregroundColor: InstructorColors.teal,
            side: BorderSide(
              color: InstructorColors.teal.withValues(alpha: 0.24),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          ),
          icon: isBusy
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      InstructorColors.teal,
                    ),
                  ),
                )
              : const Icon(Icons.add_rounded),
          label: Text(
            l10n.qbCreateChapter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final globalActions = _globalActions(context, state);
    return Container(
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [InstructorColors.success, InstructorColors.teal],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.qbBulkCreatedDraftSummary(
                      state.createdQuestions.length,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.qbQuestionCreatedDraftBody,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            _ResultSectionHeader(
              title: l10n.qbBulkGlobalActions,
              subtitle: l10n.qbBulkGlobalActionsHint,
              icon: Icons.auto_awesome_motion_rounded,
              color: InstructorColors.primary,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            if (globalActions.isEmpty)
              _ResultMutedNote(
                text: l10n.qbQuestionCreatedDraftBody,
                isDark: isDark,
              )
            else
              Wrap(spacing: 10, runSpacing: 10, children: globalActions),
            const SizedBox(height: 16),
            _ResultSectionHeader(
              title: l10n.qbBulkCreatedQuestions,
              subtitle: l10n.qbBulkCreatedDraftSummary(
                state.createdQuestions.length,
              ),
              icon: Icons.fact_check_outlined,
              color: InstructorColors.teal,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            ...state.createdQuestions.map(
              (question) => _CreatedGroupedQuestionActionCard(
                question: question,
                isBusy: state.isMutating,
                onAction: (action) => cubit.statusCreatedQuestion(
                  questionId: question.id,
                  action: action,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                _ResultActionButton(
                  label: l10n.questionBankGroupDetails,
                  icon: Icons.folder_copy_outlined,
                  color: InstructorColors.primary,
                  isDark: isDark,
                  onPressed: groupId == null
                      ? null
                      : () {
                          final refresh = DateTime.now().microsecondsSinceEpoch;
                          context.go(
                            '/instructor/question-bank/groups/$groupId?refresh=$refresh',
                          );
                        },
                ),
                _ResultActionButton(
                  label: l10n.qbCreateMoreQuestions,
                  icon: Icons.add_rounded,
                  color: InstructorColors.accent,
                  isDark: isDark,
                  onPressed: cubit.clearCreatedQuestions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _globalActions(BuildContext context, QuestionGroupState state) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<QuestionGroupCubit>();
    final questions = state.createdQuestions;
    final busy = state.isMutating;

    Widget action({
      required String label,
      required IconData icon,
      required Color color,
      required String action,
    }) {
      return _ResultActionButton(
        label: label,
        icon: icon,
        color: color,
        isDark: isDark,
        onPressed: busy ? null : () => cubit.statusCreatedQuestions(action),
      );
    }

    return [
      if (questions.every(
        (question) =>
            question.status == QuestionBankStatus.draft ||
            question.status == QuestionBankStatus.rejected,
      ))
        action(
          label: l10n.submitForReview,
          icon: Icons.outbox_rounded,
          color: InstructorColors.info,
          action: 'submit-for-review',
        ),
      if (questions.every(
        (question) =>
            question.status == QuestionBankStatus.draft ||
            question.status == QuestionBankStatus.underReview,
      ))
        action(
          label: l10n.qbApprove,
          icon: Icons.verified_rounded,
          color: InstructorColors.success,
          action: 'approve',
        ),
      if (questions.every(
        (question) => question.status != QuestionBankStatus.archived,
      ))
        action(
          label: l10n.qbArchive,
          icon: Icons.archive_outlined,
          color: InstructorColors.orange,
          action: 'archive',
        ),
      if (questions.every(
        (question) => question.status == QuestionBankStatus.archived,
      ))
        action(
          label: l10n.qbRestore,
          icon: Icons.restore_rounded,
          color: InstructorColors.teal,
          action: 'restore',
        ),
    ];
  }
}

class _ResultSectionHeader extends StatelessWidget {
  const _ResultSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultMutedNote extends StatelessWidget {
  const _ResultMutedNote({required this.text, required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: InstructorColors.textSecondaryColor(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CreatedGroupedQuestionActionCard extends StatelessWidget {
  const _CreatedGroupedQuestionActionCard({
    required this.question,
    required this.isBusy,
    required this.onAction,
  });

  final QuestionBankQuestionModel question;
  final bool isBusy;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(question.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.help_outline_rounded, color: statusColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestionFormattedText(
                      text: question.questionText,
                      fallback: '${l10n.qbQuestionRow} ${question.id}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _TinyInfoPill(
                          label: localizedQuestionStatus(l10n, question.status),
                          color: statusColor,
                          isDark: isDark,
                        ),
                        _TinyInfoPill(
                          label: localizedQuestionType(
                            l10n,
                            question.questionType,
                          ),
                          color: InstructorColors.primary,
                          isDark: isDark,
                        ),
                        _TinyInfoPill(
                          label: localizedDifficulty(l10n, question.difficulty),
                          color: InstructorColors.teal,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniQuestionAction(
                label: l10n.qbViewQuestion,
                icon: Icons.visibility_outlined,
                color: InstructorColors.primary,
                isDark: isDark,
                onPressed: () =>
                    context.go('/instructor/question-bank/${question.id}'),
              ),
              ..._questionActions(l10n, question.status).map(
                (action) => _MiniQuestionAction(
                  label: action.label,
                  icon: action.icon,
                  color: action.color,
                  isDark: isDark,
                  onPressed: isBusy ? null : () => onAction(action.value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_QuestionStatusActionData> _questionActions(
    AppLocalizations l10n,
    QuestionBankStatus status,
  ) {
    return [
      if (status == QuestionBankStatus.draft ||
          status == QuestionBankStatus.rejected)
        _QuestionStatusActionData(
          value: 'submit-for-review',
          label: l10n.submitForReview,
          icon: Icons.outbox_rounded,
          color: InstructorColors.info,
        ),
      if (status == QuestionBankStatus.draft ||
          status == QuestionBankStatus.underReview)
        _QuestionStatusActionData(
          value: 'approve',
          label: l10n.qbApprove,
          icon: Icons.verified_rounded,
          color: InstructorColors.success,
        ),
      if (status == QuestionBankStatus.underReview)
        _QuestionStatusActionData(
          value: 'reject',
          label: l10n.qbReject,
          icon: Icons.undo_rounded,
          color: InstructorColors.warning,
        ),
      if (status != QuestionBankStatus.archived)
        _QuestionStatusActionData(
          value: 'archive',
          label: l10n.qbArchive,
          icon: Icons.archive_outlined,
          color: InstructorColors.orange,
        ),
      if (status == QuestionBankStatus.archived)
        _QuestionStatusActionData(
          value: 'restore',
          label: l10n.qbRestore,
          icon: Icons.restore_rounded,
          color: InstructorColors.teal,
        ),
    ];
  }

  Color _statusColor(QuestionBankStatus status) {
    switch (status) {
      case QuestionBankStatus.approved:
        return InstructorColors.success;
      case QuestionBankStatus.underReview:
        return InstructorColors.info;
      case QuestionBankStatus.rejected:
        return InstructorColors.error;
      case QuestionBankStatus.archived:
        return InstructorColors.textSecondary;
      case QuestionBankStatus.draft:
        return InstructorColors.primary;
    }
  }
}

class _QuestionStatusActionData {
  const _QuestionStatusActionData({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class _TinyInfoPill extends StatelessWidget {
  const _TinyInfoPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniQuestionAction extends StatelessWidget {
  const _MiniQuestionAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: color.withValues(alpha: isDark ? 0.15 : 0.08),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.22)),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 17),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ResultActionButton extends StatelessWidget {
  const _ResultActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: color.withValues(alpha: isDark ? 0.16 : 0.08),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.24)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
