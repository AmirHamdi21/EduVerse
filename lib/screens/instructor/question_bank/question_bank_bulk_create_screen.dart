import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bulk_create_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bulk_create_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';
import 'question_bank_create_screen.dart';

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

class _QuestionBankBulkCreateView extends StatefulWidget {
  const _QuestionBankBulkCreateView();

  @override
  State<_QuestionBankBulkCreateView> createState() =>
      _QuestionBankBulkCreateViewState();
}

class _QuestionBankBulkCreateViewState
    extends State<_QuestionBankBulkCreateView> {
  final Set<int> _collapsedRows = <int>{};
  bool _hasChanged = false;

  void _toggleRow(int localId) {
    setState(() {
      if (!_collapsedRows.add(localId)) {
        _collapsedRows.remove(localId);
      }
    });
  }

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
            l10n.questionBankBulkCreate,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          leading: IconButton(
            onPressed: () => _handleBack(context),
            icon: Icon(
              safeFeatureBackIcon(context),
              color: InstructorColors.textPrimaryColor(isDark),
            ),
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
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: const [QuestionBankSkeletons(itemCount: 3)],
              );
            }
            if (state.createdQuestions.isNotEmpty) {
              _hasChanged = true;
            }
            final hasCreated = state.createdQuestions.isNotEmpty;
            final hasFailures = state.failedRows.isNotEmpty;
            final selectedCourse = state.courses
                .where((course) => course.courseId == state.courseId)
                .firstOrNull;
            final content = ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
              children: [
                _buildContent(
                  context,
                  state,
                  selectedCourse?.course.code ?? '-',
                  hasCreated,
                  hasFailures,
                  isDark,
                  l10n,
                ),
              ],
            );
            return Stack(
              children: [
                content,
                if (state.activeMutationAction != null)
                  Positioned.fill(
                    child: _BulkMutationOverlay(
                      action: state.activeMutationAction!,
                      isDark: isDark,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    QuestionBulkCreateState state,
    String selectedCourseCode,
    bool hasCreated,
    bool hasFailures,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionFormHero(
          title: l10n.questionBankBulkCreate,
          subtitle: l10n.questionBankBulkSubtitle,
          tiles: {
            l10n.qbBulkRows: state.rows.length.toString(),
            l10n.course: selectedCourseCode,
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
          _BulkCoreDetailsSection(state: state, isDark: isDark),
          const SizedBox(height: 16),
          QuestionBulkEditor(
            rowCount: state.rows.length,
            onAddRow: context.read<QuestionBulkCreateCubit>().addRow,
            children: state.rows
                .map(
                  (row) => QuestionBulkRowCard(
                    row: row,
                    chapters: state.chapters,
                    isBusy: state.isSubmitting,
                    isCollapsed: _collapsedRows.contains(row.localId),
                    onToggleCollapsed: () => _toggleRow(row.localId),
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
                        : () {
                            _collapsedRows.remove(row.localId);
                            context.read<QuestionBulkCreateCubit>().removeRow(
                              row.localId,
                            );
                          },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: state.isSubmitting
                  ? null
                  : () => context.read<QuestionBulkCreateCubit>().submit(),
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: InstructorColors.primary.withValues(
                  alpha: 0.42,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(
                l10n.qbSubmitBulk,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        if (hasCreated) ...[
          const SizedBox(height: 18),
          _BulkCreateResultPanel(state: state),
        ],
      ],
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
      await cubit.discardPendingUploads();
    }
    if (context.mounted) {
      _leaveBulkCreate(
        context,
        changed: _hasChanged || cubit.state.createdQuestions.isNotEmpty,
      );
    }
  }

  bool _hasPendingUploads(List<dynamic> rows) {
    for (final row in rows) {
      if (row.questionFileId != null || row.attachments.isNotEmpty) return true;
    }
    return false;
  }
}

void _leaveBulkCreate(BuildContext context, {required bool changed}) {
  safeFeatureBack(context, '/instructor/question-bank', changed);
}

class _BulkCoreDetailsSection extends StatelessWidget {
  const _BulkCoreDetailsSection({required this.state, required this.isDark});

  final QuestionBulkCreateState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return QuestionSectionCard(
      title: l10n.qbCoreDetails,
      icon: Icons.fact_check_outlined,
      color: InstructorColors.primary,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 430;
            final courseField = QuestionFormMenuField<int>(
              label: l10n.course,
              value: state.courseId,
              icon: Icons.school_outlined,
              color: InstructorColors.primary,
              options: state.courses
                  .map(
                    (course) => QuestionFormMenuOption<int>(
                      value: course.courseId,
                      label: '${course.course.code} - ${course.course.name}',
                      icon: Icons.menu_book_outlined,
                    ),
                  )
                  .toList(),
              onChanged: context.read<QuestionBulkCreateCubit>().selectCourse,
            );
            final chapterButton = OutlinedButton.icon(
              onPressed: state.courseId == null || state.isLoadingChapters
                  ? null
                  : () => _showCreateChapter(context, state),
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
              ),
              icon: state.isLoadingChapters
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
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  courseField,
                  const SizedBox(height: 10),
                  chapterButton,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: courseField),
                const SizedBox(width: 10),
                SizedBox(width: 180, height: 58, child: chapterButton),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: InstructorColors.teal,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.questionBankBulkChapterPerRow,
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showCreateChapter(
    BuildContext context,
    QuestionBulkCreateState state,
  ) async {
    if (state.isLoadingChapters) return;
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

  int _nextChapterOrder(QuestionBulkCreateState state) {
    final activeOrders = state.chapters
        .where((chapter) => chapter.isActive)
        .map((chapter) => chapter.chapterOrder)
        .where((order) => order > 0)
        .toList();
    if (activeOrders.isEmpty) return 1;
    activeOrders.sort();
    return activeOrders.last + 1;
  }
}

class _BulkFailureReportPanel extends StatelessWidget {
  const _BulkFailureReportPanel({required this.state});

  final QuestionBulkCreateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = state.failureReportMessage ?? state.errorMessage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.warning.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: InstructorColors.warning.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: InstructorColors.warning.withValues(
                    alpha: isDark ? 0.22 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.report_problem_outlined,
                  color: InstructorColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.qbBulkFailureReportTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message == null
                ? l10n.qbBulkFailureReportBody
                : localizedQuestionBankMessage(l10n, message),
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
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
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          if (state.failedRows.length > 8)
            Text(
              l10n.qbMoreFailedRows(state.failedRows.length - 8),
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _BulkMutationOverlay extends StatelessWidget {
  const _BulkMutationOverlay({required this.action, required this.isDark});

  final String action;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = _labelForAction(l10n, action);
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
                    action == 'bulkCreate'
                        ? label
                        : 'Applying ${label.toLowerCase()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action == 'bulkCreate'
                        ? 'Please wait until the questions are created.'
                        : 'Please wait until the created questions are updated.',
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
      case 'bulkCreate':
        return l10n.questionBankBulkCreate;
      case 'submit-for-review':
        return l10n.submitForReview;
      case 'approve':
        return l10n.qbApprove;
      case 'reject':
        return l10n.qbReject;
      case 'archive':
        return l10n.qbArchive;
      case 'restore':
        return l10n.qbRestore;
      default:
        return l10n.qbQuestionsBatchUpdated;
    }
  }
}

class _BulkCreateResultPanel extends StatelessWidget {
  const _BulkCreateResultPanel({required this.state});

  final QuestionBulkCreateState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<QuestionBulkCreateCubit>();
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
              (question) => _CreatedQuestionActionCard(
                question: question,
                isBusy: state.isSubmitting,
                onAction: (action) => cubit.statusCreatedQuestion(
                  questionId: question.id,
                  action: action,
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 430;
                final questionBankButton = _ResultActionButton(
                  label: l10n.questionBank,
                  icon: Icons.list_alt_rounded,
                  color: InstructorColors.primary,
                  isDark: isDark,
                  onPressed: () => _leaveBulkCreate(context, changed: true),
                );
                final createMoreButton = _ResultActionButton(
                  label: l10n.qbCreateMoreQuestions,
                  icon: Icons.add_rounded,
                  color: InstructorColors.accent,
                  isDark: isDark,
                  onPressed: cubit.resetAfterSuccess,
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      questionBankButton,
                      const SizedBox(height: 10),
                      createMoreButton,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: questionBankButton),
                    const SizedBox(width: 10),
                    Expanded(child: createMoreButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _globalActions(
    BuildContext context,
    QuestionBulkCreateState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<QuestionBulkCreateCubit>();
    final questions = state.createdQuestions;
    final busy = state.isSubmitting;

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

class _CreatedQuestionActionCard extends StatelessWidget {
  const _CreatedQuestionActionCard({
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
