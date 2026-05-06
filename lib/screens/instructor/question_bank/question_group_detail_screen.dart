import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import 'question_bank_create_screen.dart';

class QuestionGroupDetailScreen extends StatelessWidget {
  const QuestionGroupDetailScreen({super.key, required this.groupId});

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
          ),
        ),
      ],
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
  int? _bankLoadedCourseId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToQuestionBank(context);
      },
      child: Scaffold(
        backgroundColor: InstructorColors.background(isDark),
        appBar: AppBar(
          backgroundColor: InstructorColors.background(isDark),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => _goToQuestionBank(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
            ),
          ),
          title: Text(
            l10n.questionBankGroupDetails,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
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
                      style: IconButton.styleFrom(
                        backgroundColor: InstructorColors.primary.withValues(
                          alpha: isDark ? 0.18 : 0.1,
                        ),
                        foregroundColor: InstructorColors.primary,
                      ),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: l10n.qbDeleteGroup,
                      onPressed: group == null
                          ? null
                          : () => _delete(context, group.id),
                      style: IconButton.styleFrom(
                        backgroundColor: InstructorColors.error.withValues(
                          alpha: isDark ? 0.18 : 0.1,
                        ),
                        foregroundColor: InstructorColors.error,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                    const SizedBox(width: 10),
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
            _ensureBankFeedLoaded(context, group);
            final feedQuestions = _questionsForGroup(
              bankState.questions,
              group.id,
            );
            final questions = state.questions.length >= feedQuestions.length
                ? state.questions
                : feedQuestions;
            if (questions.length > state.questions.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.read<QuestionGroupCubit>().syncResolvedQuestions(
                  questions,
                );
              });
            }
            final questionCount = questions.length > group.totalQuestions
                ? questions.length
                : group.totalQuestions;
            final approvedCount = questions
                .where(
                  (question) => question.status == QuestionBankStatus.approved,
                )
                .length;
            final resolvedApprovedCount =
                approvedCount > group.approvedQuestions
                ? approvedCount
                : group.approvedQuestions;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
              children: [
                QuestionBankHeroHeader(
                  title: group.title ?? l10n.questionBankGroupDetails,
                  subtitle: questionTextForDisplay(
                    group.sharedPrompt,
                    fallback: _courseLabel(group, bankState),
                  ),
                  stats: {
                    l10n.course: _courseLabel(group, bankState),
                    l10n.type: localizedGroupType(l10n, group.groupType),
                    l10n.questions: questionCount.toString(),
                    l10n.approved: resolvedApprovedCount.toString(),
                  },
                ),
                const SizedBox(height: 16),
                _GroupOverviewCard(group: group),
                const SizedBox(height: 16),
                if (questions.isEmpty && bankState.teachingCourses.isEmpty)
                  const QuestionBankSkeletons(itemCount: 2)
                else if (questions.isEmpty)
                  _GroupQuestionsEmptyPanel(
                    onAddGroupedQuestions: () => context.push(
                      '/instructor/question-bank/groups/${group.id}/add-questions',
                    ),
                    onAddExistingQuestions: () => context.push(
                      '/instructor/question-bank/groups/${group.id}/link-questions',
                    ),
                  )
                else ...[
                  _GroupActionPanel(
                    state: state,
                    onAddGroupedQuestions: () => context.push(
                      '/instructor/question-bank/groups/${group.id}/add-questions',
                    ),
                    onAddExistingQuestions: () => context.push(
                      '/instructor/question-bank/groups/${group.id}/link-questions',
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuestionSectionCard(
                    title: l10n.qbReorderGroupQuestions,
                    icon: Icons.drag_indicator_rounded,
                    color: InstructorColors.primary,
                    children: [
                      QuestionGroupReorderList(
                        questions: questions,
                        onReorder: context
                            .read<QuestionGroupCubit>()
                            .reorderQuestions,
                        onEdit: (question) => context.push(
                          '/instructor/question-bank/${question.id}/edit',
                        ),
                        onDelete: (question) =>
                            _removeQuestionFromGroup(context, question.id),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
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
          builder: (context) => QuestionFormDecisionDialog(
            title: l10n.qbRemoveFromGroup,
            message: l10n.qbRemoveFromGroupBody,
            icon: Icons.link_off_rounded,
            color: InstructorColors.warning,
            primaryLabel: l10n.qbRemoveFromGroup,
            secondaryLabel: l10n.cancel,
            onPrimary: () => Navigator.of(context).pop(true),
            onSecondary: () => Navigator.of(context).pop(false),
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
          builder: (context) => QuestionFormDecisionDialog(
            title: l10n.qbDeleteGroup,
            message: l10n.qbGroupDeleteBody,
            icon: Icons.delete_outline_rounded,
            color: InstructorColors.error,
            primaryLabel: l10n.qbDeleteGroup,
            secondaryLabel: l10n.cancel,
            onPrimary: () => Navigator.of(context).pop(true),
            onSecondary: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    final deleted = await context.read<QuestionGroupCubit>().deleteGroup(
      groupId,
    );
    if (deleted && context.mounted) context.go('/instructor/question-bank');
  }

  void _goToQuestionBank(BuildContext context) {
    context.go('/instructor/question-bank');
  }

  void _ensureBankFeedLoaded(
    BuildContext context,
    QuestionBankGroupModel group,
  ) {
    if (_bankLoadedCourseId == group.courseId) return;
    _bankLoadedCourseId = group.courseId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<QuestionBankCubit>().initialize(
        preferredCourseId: group.courseId,
      );
    });
  }

  List<QuestionBankQuestionModel> _questionsForGroup(
    List<QuestionBankQuestionModel> questions,
    int groupId,
  ) {
    final resolved = questions
        .where(
          (question) =>
              question.groups.any((summary) => summary.groupId == groupId),
        )
        .toList();
    resolved.sort((a, b) {
      final aOrder = _itemOrderForGroup(a, groupId);
      final bOrder = _itemOrderForGroup(b, groupId);
      return aOrder.compareTo(bOrder);
    });
    return resolved;
  }

  int _itemOrderForGroup(QuestionBankQuestionModel question, int groupId) {
    for (final group in question.groups) {
      if (group.groupId == groupId) return group.itemOrder;
    }
    return question.id;
  }

  String _courseLabel(QuestionBankGroupModel group, QuestionBankState state) {
    for (final course in state.teachingCourses) {
      if (course.courseId == group.courseId) {
        final code = course.course.code.trim();
        final name = course.course.name.trim();
        if (code.isNotEmpty && name.isNotEmpty) return '$code - $name';
        if (code.isNotEmpty) return code;
        if (name.isNotEmpty) return name;
      }
    }
    final code = group.courseCode?.trim();
    final name = group.courseName?.trim();
    if (code != null && code.isNotEmpty && name != null && name.isNotEmpty) {
      return '$code - $name';
    }
    if (code != null && code.isNotEmpty) return code;
    if (name != null && name.isNotEmpty) return name;
    return group.courseId.toString();
  }
}

class _GroupOverviewCard extends StatelessWidget {
  const _GroupOverviewCard({required this.group});

  final QuestionBankGroupModel group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return QuestionSectionCard(
      title: l10n.qbSharedPrompt,
      icon: Icons.notes_rounded,
      color: InstructorColors.teal,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: InstructorColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
          ),
          child: QuestionFormattedText(
            text: group.sharedPrompt,
            fallback: '-',
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.28,
            ),
          ),
        ),
        if (group.sharedFileId != null) ...[
          const SizedBox(height: 10),
          _GroupImagePreviewCard(group: group, isDark: isDark),
        ],
      ],
    );
  }
}

class _GroupImagePreviewCard extends StatelessWidget {
  const _GroupImagePreviewCard({required this.group, required this.isDark});

  final QuestionBankGroupModel group;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final imageUrl = group.sharedImageUrl;
    final caption = group.sharedFileCaption?.trim();
    final altText = group.sharedFileAltText?.trim();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: InstructorColors.accent.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: InstructorColors.accent,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.qbGroupImage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        caption?.isNotEmpty == true
                            ? caption!
                            : '#${group.sharedFileId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textSecondaryColor(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.edit,
                  onPressed: () => context.push(
                    '/instructor/question-bank/groups/${group.id}/edit',
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.primary,
                  ),
                  icon: const Icon(Icons.edit_rounded),
                ),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            GestureDetector(
              onTap: () => _showImagePreview(context, imageUrl),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: InstructorColors.textSecondaryColor(isDark),
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            if (altText?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
                child: Text(
                  altText!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                '${l10n.qbGroupImage} #${group.sharedFileId}',
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showImagePreview(BuildContext context, String imageUrl) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Container(
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        color: InstructorColors.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          group.sharedFileCaption?.trim().isNotEmpty == true
                              ? group.sharedFileCaption!.trim()
                              : l10n.qbGroupImage,
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
      ),
    );
  }
}

class _GroupActionPanel extends StatelessWidget {
  const _GroupActionPanel({
    required this.state,
    required this.onAddGroupedQuestions,
    required this.onAddExistingQuestions,
  });

  final QuestionGroupState state;
  final VoidCallback onAddGroupedQuestions;
  final VoidCallback onAddExistingQuestions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return QuestionSectionCard(
      title: l10n.actions,
      icon: Icons.auto_awesome_motion_outlined,
      color: InstructorColors.primary,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 460;
            final width = compact
                ? constraints.maxWidth
                : (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: width,
                  child: _ActionButton(
                    icon: Icons.playlist_add_rounded,
                    label: l10n.qbGroupedBatchCreate,
                    color: InstructorColors.primary,
                    onPressed: onAddGroupedQuestions,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ActionButton(
                    icon: Icons.add_link_rounded,
                    label: l10n.qbAddExistingQuestions,
                    color: InstructorColors.accent,
                    onPressed: state.isMutating ? null : onAddExistingQuestions,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GroupQuestionsEmptyPanel extends StatelessWidget {
  const _GroupQuestionsEmptyPanel({
    required this.onAddGroupedQuestions,
    required this.onAddExistingQuestions,
  });

  final VoidCallback onAddGroupedQuestions;
  final VoidCallback onAddExistingQuestions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(
                alpha: isDark ? 0.18 : 0.1,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.quiz_outlined,
              color: InstructorColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.questionBankEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.questionBankEmptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              final width = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: width,
                    child: _ActionButton(
                      icon: Icons.playlist_add_rounded,
                      label: l10n.qbGroupedBatchCreate,
                      color: InstructorColors.primary,
                      onPressed: onAddGroupedQuestions,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ActionButton(
                      icon: Icons.add_link_rounded,
                      label: l10n.qbAddExistingQuestions,
                      color: InstructorColors.accent,
                      onPressed: onAddExistingQuestions,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: color.withValues(alpha: isDark ? 0.16 : 0.08),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.24)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      icon: Icon(icon),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
