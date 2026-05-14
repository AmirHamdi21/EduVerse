import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_detail_cubit.dart';
import '../../../bloc/instructor/question_bank/question_detail_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/instructor_modern_tab_strip.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

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
        enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(
        backgroundColor: InstructorColors.background(isDark),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: Icon(
            safeFeatureBackIcon(context),
            color: InstructorColors.textPrimaryColor(isDark),
          ),
          onPressed: () =>
              safeFeatureBack(context, '/instructor/question-bank'),
        ),
        title: Text(
          l10n.questionBankQuestionDetails,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          BlocBuilder<QuestionDetailCubit, QuestionDetailState>(
            builder: (context, state) {
              final question = state.question;
              return Row(
                children: [
                  IconButton(
                    tooltip: l10n.edit,
                    onPressed: question == null
                        ? null
                        : () => context.push(
                            '/instructor/question-bank/${question.id}/edit',
                          ),
                    style: IconButton.styleFrom(
                      backgroundColor: InstructorColors.primary.withValues(
                        alpha: isDark ? 0.18 : 0.1,
                      ),
                      foregroundColor: InstructorColors.primary,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: IconButton(
                      tooltip: l10n.qbDeleteQuestion,
                      onPressed: question == null
                          ? null
                          : () => _deleteQuestion(context),
                      style: IconButton.styleFrom(
                        backgroundColor: InstructorColors.error.withValues(
                          alpha: isDark ? 0.18 : 0.1,
                        ),
                        foregroundColor: InstructorColors.error,
                      ),
                      icon: const Icon(Icons.delete_outline),
                    ),
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
            return const SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: QuestionBankSkeletons(itemCount: 4),
            );
          }
          final content = RefreshIndicator(
            onRefresh: () =>
                context.read<QuestionDetailCubit>().load(question.id),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              children: [
                QuestionBankHeroHeader(
                  title: questionTextForDisplay(
                    question.questionText,
                    fallback: l10n.questionBankImageQuestion,
                  ),
                  subtitle: l10n.qbQuestionReviewWorkspace,
                  stats: {
                    l10n.type: localizedQuestionType(
                      l10n,
                      question.questionType,
                    ),
                    l10n.difficulty: localizedDifficulty(
                      l10n,
                      question.difficulty,
                    ),
                    l10n.status: localizedQuestionStatus(l10n, question.status),
                    l10n.attachments: question.attachments.length.toString(),
                    l10n.qbGroups: question.groups.length.toString(),
                  },
                  isDark: isDark,
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
                _tabContent(context, question, state),
              ],
            ),
          );
          return Stack(
            children: [
              content,
              if (state.activeMutationAction != null)
                Positioned.fill(
                  child: _QuestionDetailMutationOverlay(
                    action: state.activeMutationAction!,
                    isDark: isDark,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabContent(
    BuildContext context,
    QuestionBankQuestionModel question,
    QuestionDetailState state,
  ) {
    switch (_tab) {
      case 1:
        return QuestionAttachmentManager(
          attachments: question.attachments,
          isMutating: state.isMutating,
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
      case 2:
        return _QuestionGroupsSection(question: question);
      case 3:
        return QuestionStatusActions(
          status: question.status,
          isMutating: state.isMutating,
          onAction: context.read<QuestionDetailCubit>().statusAction,
        );
      default:
        return _QuestionOverviewSection(
          question: question,
          courseLabel: state.courseLabel,
          chapterLabel: state.chapterLabel,
        );
    }
  }

  Future<void> _deleteQuestion(BuildContext context) async {
    final ok = await showQuestionDeleteDialog(context);
    if (!ok || !context.mounted) return;
    final deleted = await context.read<QuestionDetailCubit>().deleteQuestion();
    if (deleted && context.mounted) context.go('/instructor/question-bank');
  }
}

class _QuestionDetailMutationOverlay extends StatelessWidget {
  const _QuestionDetailMutationOverlay({
    required this.action,
    required this.isDark,
  });

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
                    'Applying ${label.toLowerCase()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait until the question details are updated.',
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
      case 'attachmentUpload':
        return l10n.qbUploadAttachment;
      case 'attachmentRemove':
        return l10n.qbRemoveAttachment;
      case 'attachmentReorder':
        return l10n.qbReorderAttachments;
      case 'delete':
        return l10n.qbDeleteQuestion;
      case 'attachmentUpdate':
      default:
        return l10n.qbEditAttachment;
    }
  }
}

class _QuestionOverviewSection extends StatelessWidget {
  const _QuestionOverviewSection({
    required this.question,
    required this.courseLabel,
    required this.chapterLabel,
  });

  final QuestionBankQuestionModel question;
  final String? courseLabel;
  final String? chapterLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailSectionCard(
          title: l10n.qbQuestionPrompt,
          subtitle: l10n.qbQuestionPromptReviewHint,
          icon: Icons.help_outline_rounded,
          color: InstructorColors.primary,
          child: QuestionFormattedText(
            text: question.questionText,
            fallback: l10n.questionBankImageQuestion,
            style: _bodyStyle(context, large: true),
          ),
        ),
        const SizedBox(height: 12),
        _QuestionScopeCard(
          courseLabel: courseLabel,
          chapterLabel: chapterLabel,
          courseId: question.courseId,
          chapterId: question.chapterId,
        ),
        const SizedBox(height: 12),
        _MainQuestionImageCard(question: question),
        if (question.questionImageUrl != null ||
            question.questionFileId != null)
          const SizedBox(height: 12),
        _DetailSectionCard(
          title: l10n.qbQuestionHints,
          subtitle: l10n.qbQuestionHintsReviewHint,
          icon: Icons.lightbulb_outline_rounded,
          color: InstructorColors.warning,
          child: _ReviewTextValue(
            text: question.hints,
            fallback: l10n.qbNoQuestionHint,
            icon: Icons.lightbulb_outline_rounded,
            color: InstructorColors.warning,
          ),
        ),
        const SizedBox(height: 12),
        _AnswerModelCard(question: question),
        const SizedBox(height: 12),
        _MetadataCard(question: question),
      ],
    );
  }
}

class _AnswerModelCard extends StatelessWidget {
  const _AnswerModelCard({required this.question});

  final QuestionBankQuestionModel question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _DetailSectionCard(
      title: l10n.qbAnswerModel,
      subtitle: l10n.qbAnswerModelReviewHint,
      icon: Icons.fact_check_outlined,
      color: InstructorColors.success,
      child: _AnswerContent(question: question),
    );
  }
}

class _QuestionScopeCard extends StatelessWidget {
  const _QuestionScopeCard({
    required this.courseLabel,
    required this.chapterLabel,
    required this.courseId,
    required this.chapterId,
  });

  final String? courseLabel;
  final String? chapterLabel;
  final int courseId;
  final int chapterId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _DetailSectionCard(
      title: l10n.qbQuestionScope,
      subtitle: l10n.qbQuestionScopeReviewHint,
      icon: Icons.account_tree_outlined,
      color: InstructorColors.teal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;
          final course = _ScopeTile(
            label: l10n.course,
            value: _labelOrFallback(courseLabel, '${l10n.course} $courseId'),
            icon: Icons.school_outlined,
            color: InstructorColors.primary,
          );
          final chapter = _ScopeTile(
            label: l10n.chapter,
            value: _labelOrFallback(chapterLabel, '${l10n.chapter} $chapterId'),
            icon: Icons.menu_book_outlined,
            color: InstructorColors.orange,
          );
          if (compact) {
            return Column(
              children: [course, const SizedBox(height: 10), chapter],
            );
          }
          return Row(
            children: [
              Expanded(child: course),
              const SizedBox(width: 10),
              Expanded(child: chapter),
            ],
          );
        },
      ),
    );
  }

  String _labelOrFallback(String? value, String fallback) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }
}

class _ScopeTile extends StatelessWidget {
  const _ScopeTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
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

class _AnswerContent extends StatelessWidget {
  const _AnswerContent({required this.question});

  final QuestionBankQuestionModel question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (question.questionType == QuestionBankType.mcq ||
        question.questionType == QuestionBankType.trueFalse) {
      if (question.options.isEmpty) {
        return _MutedMessage(text: l10n.qbNoAnswerProvided);
      }
      return Column(
        children: [
          for (var i = 0; i < question.options.length; i++) ...[
            _AnswerOptionTile(index: i + 1, option: question.options[i]),
            if (i != question.options.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }
    if (question.questionType == QuestionBankType.fillBlanks) {
      if (question.fillBlanks.isEmpty) {
        return _MutedMessage(text: l10n.qbNoAnswerProvided);
      }
      return Column(
        children: [
          for (var i = 0; i < question.fillBlanks.length; i++) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: InstructorColors.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: InstructorColors.borderColor(isDark)),
              ),
              child: Row(
                children: [
                  _AnswerIcon(
                    icon: Icons.short_text_rounded,
                    color: InstructorColors.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.fillBlanks[i].blankKey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        QuestionFormattedText(
                          text: question.fillBlanks[i].acceptableAnswer,
                          fallback: l10n.qbNoAnswerProvided,
                          style: _bodyStyle(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != question.fillBlanks.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }
    return QuestionFormattedText(
      text: question.expectedAnswerText,
      fallback: l10n.qbNoAnswerProvided,
      style: _bodyStyle(context),
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({required this.index, required this.option});

  final int index;
  final dynamic option;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = option.isCorrect
        ? InstructorColors.success
        : InstructorColors.textTertiaryColor(isDark);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: option.isCorrect
            ? InstructorColors.success.withValues(alpha: isDark ? 0.18 : 0.08)
            : InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: option.isCorrect
              ? InstructorColors.success.withValues(alpha: 0.28)
              : InstructorColors.borderColor(isDark),
        ),
      ),
      child: Row(
        children: [
          _AnswerIcon(
            icon: option.isCorrect
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: QuestionFormattedText(
              text: option.optionText,
              fallback: '${l10n.qbOptionNumber} $index',
              style: _bodyStyle(context).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (option.isCorrect) ...[
            const SizedBox(width: 8),
            _MiniPill(
              label: l10n.correct,
              icon: Icons.verified_rounded,
              color: InstructorColors.success,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.question});

  final QuestionBankQuestionModel question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _DetailSectionCard(
      title: l10n.metadata,
      subtitle: l10n.qbMetadataReviewHint,
      icon: Icons.info_outline_rounded,
      color: InstructorColors.teal,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MiniPill(
            label: localizedQuestionType(l10n, question.questionType),
            icon: Icons.category_outlined,
            color: InstructorColors.primary,
          ),
          _MiniPill(
            label: localizedDifficulty(l10n, question.difficulty),
            icon: Icons.speed_rounded,
            color: InstructorColors.teal,
          ),
          _MiniPill(
            label: localizedBloomLevel(l10n, question.bloomLevel),
            icon: Icons.psychology_outlined,
            color: InstructorColors.accent,
          ),
          _MiniPill(
            label: localizedQuestionStatus(l10n, question.status),
            icon: Icons.verified_outlined,
            color: _statusColor(question.status),
          ),
          _MiniPill(
            label: '${l10n.chapter} ${question.chapterId}',
            icon: Icons.menu_book_outlined,
            color: InstructorColors.orange,
          ),
        ],
      ),
    );
  }
}

class _QuestionGroupsSection extends StatelessWidget {
  const _QuestionGroupsSection({required this.question});

  final QuestionBankQuestionModel question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (question.groups.isEmpty) {
      return _ModernEmptyBlock(
        title: l10n.qbNoGroupsForQuestion,
        message: l10n.qbQuestionGroupsReviewHint,
        icon: Icons.folder_copy_outlined,
        color: InstructorColors.accent,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionIntro(
          title: l10n.qbGroups,
          message: l10n.qbQuestionGroupsReviewHint,
          icon: Icons.folder_copy_outlined,
          color: InstructorColors.accent,
        ),
        const SizedBox(height: 12),
        ...question.groups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _QuestionGroupMembershipCard(group: group),
          ),
        ),
      ],
    );
  }
}

class _QuestionGroupMembershipCard extends StatelessWidget {
  const _QuestionGroupMembershipCard({required this.group});

  final QuestionBankGroupSummaryModel group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _groupColor(group.groupType);
    final title = group.title?.trim().isNotEmpty == true
        ? group.title!
        : '${l10n.qbGroups} ${group.groupId}';
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () =>
          context.push('/instructor/question-bank/groups/${group.groupId}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.045),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(Icons.folder_copy_outlined, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _MiniPill(
                        label: '#${group.itemOrder}',
                        icon: Icons.format_list_numbered_rounded,
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniPill(
                        label: localizedGroupType(l10n, group.groupType),
                        icon: Icons.category_outlined,
                        color: color,
                      ),
                      if (group.courseCode?.trim().isNotEmpty == true)
                        _MiniPill(
                          label: group.courseCode!,
                          icon: Icons.school_outlined,
                          color: InstructorColors.primary,
                        ),
                      if (group.sharedImageUrl != null ||
                          group.sharedFileId != null)
                        _MiniPill(
                          label: l10n.qbGroupImage,
                          icon: Icons.image_outlined,
                          color: InstructorColors.teal,
                        ),
                    ],
                  ),
                  if (group.sharedPrompt?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    QuestionFormattedText(
                      text: group.sharedPrompt,
                      fallback: '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainQuestionImageCard extends StatelessWidget {
  const _MainQuestionImageCard({required this.question});

  final QuestionBankQuestionModel question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (question.questionImageUrl == null && question.questionFileId == null) {
      return const SizedBox.shrink();
    }

    return _DetailSectionCard(
      title: l10n.questionBankImageQuestion,
      subtitle: question.questionFileCaption?.trim().isNotEmpty == true
          ? question.questionFileCaption!
          : l10n.qbQuestionImageReviewHint,
      icon: Icons.image_outlined,
      color: InstructorColors.cyan,
      trailing: IconButton(
        tooltip: l10n.edit,
        onPressed: () =>
            context.push('/instructor/question-bank/${question.id}/edit'),
        style: IconButton.styleFrom(
          backgroundColor: InstructorColors.primary.withValues(
            alpha: isDark ? 0.18 : 0.1,
          ),
          foregroundColor: InstructorColors.primary,
        ),
        icon: const Icon(Icons.edit_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (question.questionImageUrl != null)
            GestureDetector(
              onTap: () => _showImagePreview(
                context: context,
                imageUrl: question.questionImageUrl!,
                title: question.questionFileCaption?.trim().isNotEmpty == true
                    ? question.questionFileCaption!
                    : l10n.questionBankImageQuestion,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    question.questionImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _BrokenImageBox(label: l10n.questionBankImageQuestion),
                  ),
                ),
              ),
            )
          else
            _MutedMessage(
              text:
                  '${l10n.questionBankImageQuestion}: ${question.questionFileId}',
            ),
          const SizedBox(height: 10),
          _ReviewTextValue(
            text: question.questionFileCaption,
            fallback: l10n.qbNoImageCaption,
            icon: Icons.closed_caption_outlined,
            color: InstructorColors.primary,
          ),
          const SizedBox(height: 10),
          _ReviewTextValue(
            text: question.questionFileAltText,
            fallback: l10n.qbNoImageAltText,
            icon: Icons.accessibility_new_rounded,
            color: InstructorColors.accent,
          ),
        ],
      ),
    );
  }
}

class _ReviewTextValue extends StatelessWidget {
  const _ReviewTextValue({
    required this.text,
    required this.fallback,
    required this.icon,
    required this.color,
  });

  final String? text;
  final String fallback;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = text?.trim();
    final hasValue = value != null && value.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasValue
            ? color.withValues(alpha: isDark ? 0.16 : 0.07)
            : InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValue
              ? color.withValues(alpha: 0.22)
              : InstructorColors.borderColor(isDark),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: QuestionFormattedText(
              text: hasValue ? value : fallback,
              fallback: fallback,
              style: _bodyStyle(context).copyWith(
                color: hasValue
                    ? InstructorColors.textPrimaryColor(isDark)
                    : InstructorColors.textSecondaryColor(isDark),
                fontWeight: hasValue ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 21),
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
                        fontSize: 17,
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _DetailSectionCard(
      title: title,
      subtitle: message,
      icon: icon,
      color: color,
      child: const SizedBox.shrink(),
    );
  }
}

class _ModernEmptyBlock extends StatelessWidget {
  const _ModernEmptyBlock({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _MutedMessage extends StatelessWidget {
  const _MutedMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          height: 1.25,
        ),
      ),
    );
  }
}

class _AnswerIcon extends StatelessWidget {
  const _AnswerIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrokenImageBox extends StatelessWidget {
  const _BrokenImageBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      alignment: Alignment.center,
      color: InstructorColors.surfaceColor(isDark),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: InstructorColors.textSecondaryColor(isDark),
            size: 42,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showImagePreview({
  required BuildContext context,
  required String imageUrl,
  required String title,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
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
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
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

Future<bool> showQuestionDeleteDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(26),
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
                  children: [
                    _AnswerIcon(
                      icon: Icons.delete_outline_rounded,
                      color: InstructorColors.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.qbDeleteQuestion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _MutedMessage(text: l10n.qbDeleteQuestionBody),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: InstructorColors.error,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: Text(l10n.qbDeleteQuestion),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}

TextStyle _bodyStyle(BuildContext context, {bool large = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextStyle(
    color: InstructorColors.textPrimaryColor(isDark),
    fontSize: large ? 15.5 : 14.5,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );
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

Color _groupColor(QuestionGroupType type) {
  switch (type) {
    case QuestionGroupType.caseStudy:
      return InstructorColors.orange;
    case QuestionGroupType.imageSet:
      return InstructorColors.accent;
    case QuestionGroupType.multipart:
      return InstructorColors.primary;
    case QuestionGroupType.passage:
      return InstructorColors.teal;
    case QuestionGroupType.other:
      return InstructorColors.cyan;
  }
}
