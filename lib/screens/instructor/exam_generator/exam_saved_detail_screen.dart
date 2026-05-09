import 'dart:convert';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/exams/exam_full_detail_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';
import '../../../widgets/instructor/question_bank/question_text_renderer.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

class ExamSavedDetailScreen extends StatefulWidget {
  const ExamSavedDetailScreen({super.key, required this.examId});

  final int examId;

  @override
  State<ExamSavedDetailScreen> createState() => _ExamSavedDetailScreenState();
}

class _ExamSavedDetailScreenState extends State<ExamSavedDetailScreen> {
  late final ExamGeneratorService _service = ExamGeneratorService(
    coreApiClient: CoreApiClient(),
  );
  ExamFullDetailModel? _detail;
  bool _loading = true;
  bool _actionInProgress = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _service.getFullExam(widget.examId);
    if (!mounted) return;
    setState(() {
      _detail = result.data;
      _error = result.error?.message;
      _loading = false;
    });
  }

  Future<void> _action(String action) async {
    final l10n = AppLocalizations.of(context);
    final reason = await _askReason();
    if (reason == null) return;
    setState(() => _actionInProgress = true);
    final result = await _service.lifecycle(
      examId: widget.examId,
      action: action,
      reason: reason,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.error?.message ?? l10n.examLifecycleUpdated),
      ),
    );
    await _load();
    if (mounted) setState(() => _actionInProgress = false);
  }

  Future<String?> _askReason() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: InstructorColors.cardColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(l10n.examLifecycleReason),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.reason,
              helperText: l10n.examLifecycleReasonHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _export() async {
    await context.push(
      '/instructor/exam-generator/exams/${widget.examId}/paper-export',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detail = _detail;
    final exam = detail?.exam;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () =>
              safeFeatureBack(context, '/instructor/exam-generator'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(l10n.examSavedDetails),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: IconButton.filledTonal(
              tooltip: l10n.examExport,
              onPressed: _loading ? null : _export,
              icon: const Icon(Icons.download_rounded),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: ExamGeneratorSkeletons(itemCount: 4),
            )
          : _error != null || detail == null || exam == null
          ? Center(
              child: FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                children: [
                  ExamGeneratorHeroHeader(
                    title: exam.title,
                    subtitle: l10n.examSnapshotHelp,
                    stats: {
                      l10n.status: localizedExamStatus(l10n, exam.status),
                      l10n.totalMarks: exam.totalMarks?.toString() ?? '-',
                      l10n.questions: exam.itemCount?.toString() ?? '-',
                      l10n.sections: exam.sectionCount?.toString() ?? '-',
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _SnapshotNotice(detail: detail),
                  const SizedBox(height: 16),
                  _SavedOverview(detail: detail),
                  if ((detail.seed ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SavedGenerationInfo(detail: detail),
                  ],
                  const SizedBox(height: 16),
                  _SavedPaperText(detail: detail),
                  const SizedBox(height: 16),
                  _SavedSections(detail: detail),
                  const SizedBox(height: 16),
                  _LifecyclePanel(
                    isBusy: _actionInProgress,
                    onPublish: () => _action('publish'),
                    onUnpublish: () => _action('unpublish'),
                    onArchive: () => _action('archive'),
                    onExport: _export,
                  ),
                ],
              ),
            ),
    );
  }
}

class _SnapshotNotice extends StatelessWidget {
  const _SnapshotNotice({required this.detail});

  final ExamFullDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ModernPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _InlineInfo(
            icon: Icons.lock_clock_outlined,
            color: InstructorColors.primary,
            text: l10n.examSavedSnapshotLocked,
          ),
          const SizedBox(height: 10),
          _InlineInfo(
            icon: Icons.info_outline_rounded,
            color: InstructorColors.accent,
            text: l10n.examSavedStudentAssignmentNote,
          ),
          if ((detail.courseCode ?? detail.courseName) != null) ...[
            const SizedBox(height: 10),
            Divider(color: InstructorColors.borderColor(isDark), height: 1),
            const SizedBox(height: 10),
            _InlineInfo(
              icon: Icons.school_outlined,
              color: InstructorColors.teal,
              text: [detail.courseCode, detail.courseName]
                  .where((value) => value != null && value.trim().isNotEmpty)
                  .join(' - '),
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedOverview extends StatelessWidget {
  const _SavedOverview({required this.detail});

  final ExamFullDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exam = detail.exam;
    return _ModernPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeading(
            icon: Icons.dashboard_customize_outlined,
            color: InstructorColors.teal,
            title: l10n.examSavedOverviewTitle,
            subtitle: l10n.examSavedOverviewSubtitle,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 500 ? 2 : 3;
              final width =
                  (constraints.maxWidth - ((columns - 1) * 10)) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricTile(
                    width: width,
                    icon: Icons.verified_outlined,
                    color: InstructorColors.success,
                    label: l10n.status,
                    value: localizedExamStatus(l10n, exam.status),
                  ),
                  _MetricTile(
                    width: width,
                    icon: Icons.help_outline_rounded,
                    color: InstructorColors.primary,
                    label: l10n.questions,
                    value: (exam.itemCount ?? _questionCount(detail))
                        .toString(),
                  ),
                  _MetricTile(
                    width: width,
                    icon: Icons.score_outlined,
                    color: InstructorColors.orange,
                    label: l10n.totalMarks,
                    value: exam.totalMarks?.toString() ?? '-',
                  ),
                  _MetricTile(
                    width: width,
                    icon: Icons.splitscreen_outlined,
                    color: InstructorColors.accent,
                    label: l10n.sections,
                    value: (exam.sectionCount ?? detail.sections.length)
                        .toString(),
                  ),
                  _MetricTile(
                    width: width,
                    icon: Icons.timer_outlined,
                    color: InstructorColors.cyan,
                    label: l10n.examDurationMinutes,
                    value:
                        (detail.durationMinutes ?? exam.durationMinutes)
                            ?.toString() ??
                        '-',
                  ),
                  _MetricTile(
                    width: width,
                    icon: Icons.school_outlined,
                    color: InstructorColors.teal,
                    label: l10n.course,
                    value: detail.courseCode ?? detail.courseName ?? '-',
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

class _SavedPaperText extends StatelessWidget {
  const _SavedPaperText({required this.detail});

  final ExamFullDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows =
        [
              _TextRowData(l10n.instructions, detail.instructions),
              _TextRowData(l10n.examHeaderText, detail.headerText),
              _TextRowData(l10n.examFooterText, detail.footerText),
            ]
            .where((row) => row.value != null && row.value!.trim().isNotEmpty)
            .toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return _ModernPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeading(
            icon: Icons.notes_outlined,
            color: InstructorColors.info,
            title: l10n.examSavedPaperText,
            subtitle: l10n.examSnapshotHelp,
          ),
          const SizedBox(height: 12),
          ...rows.map((row) => _PaperTextRow(row: row)),
        ],
      ),
    );
  }
}

class _SavedGenerationInfo extends StatelessWidget {
  const _SavedGenerationInfo({required this.detail});

  final ExamFullDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seed = detail.seed?.trim();
    if (seed == null || seed.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ModernPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeading(
            icon: Icons.tag_rounded,
            color: InstructorColors.accent,
            title: l10n.examVersionCode,
            subtitle: l10n.examSeedHelp,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: InstructorColors.accent.withValues(
                alpha: isDark ? 0.16 : 0.08,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: InstructorColors.accent.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBubble(
                  icon: Icons.pin_outlined,
                  color: InstructorColors.accent,
                  size: 38,
                  iconSize: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.examSeed,
                        style: TextStyle(
                          color: InstructorColors.textSecondaryColor(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      SelectableText(
                        seed,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (detail.generatedAt != null || detail.savedAt != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (detail.generatedAt != null)
                  _SmallMetaPill(
                    icon: Icons.auto_awesome_rounded,
                    color: InstructorColors.primary,
                    label: l10n.examGeneratedAt,
                    value: _formatDateTime(detail.generatedAt!),
                  ),
                if (detail.savedAt != null)
                  _SmallMetaPill(
                    icon: Icons.save_outlined,
                    color: InstructorColors.teal,
                    label: l10n.examSavedAt,
                    value: _formatDateTime(detail.savedAt!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedSections extends StatelessWidget {
  const _SavedSections({required this.detail});

  final ExamFullDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = [...detail.sections]..sort((a, b) => a.id.compareTo(b.id));
    final unsectioned = [...detail.unsectionedItems]
      ..sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
    final hasQuestions =
        sections.any((section) => section.items.isNotEmpty) ||
        unsectioned.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.examSections,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (sections.isEmpty)
          _CompactEmpty(text: l10n.examSavedNoSections)
        else
          ...sections.asMap().entries.map(
            (entry) => _SavedSectionCard(
              section: entry.value,
              orderNumber: entry.key + 1,
            ),
          ),
        if (unsectioned.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SavedQuestionGroup(
            title: l10n.examUnassignedQuestions,
            subtitle: l10n.examSavedUnassignedQuestionsHint,
            icon: Icons.inventory_2_outlined,
            color: InstructorColors.warning,
            items: unsectioned,
          ),
        ] else if (!hasQuestions) ...[
          const SizedBox(height: 12),
          _CompactEmpty(text: l10n.examSavedNoQuestions),
        ],
      ],
    );
  }
}

class _SavedSectionCard extends StatelessWidget {
  const _SavedSectionCard({required this.section, required this.orderNumber});

  final ExamFullSectionModel section;
  final int orderNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [...section.items]
      ..sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ModernPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(
                alpha: isDark ? 0.16 : 0.07,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBubble(
                  icon: Icons.splitscreen_outlined,
                  color: InstructorColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: Icons.format_list_numbered_rounded,
                            label: l10n.examOrderNumber(orderNumber),
                            color: InstructorColors.primary,
                          ),
                          _InfoPill(
                            icon: Icons.help_outline_rounded,
                            label: l10n.examSectionAssignedQuestions(
                              items.length,
                            ),
                            color: InstructorColors.teal,
                          ),
                          if (section.totalMarks != null)
                            _InfoPill(
                              icon: Icons.score_outlined,
                              label: '${section.totalMarks} ${l10n.examMarks}',
                              color: InstructorColors.orange,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((section.instructions ?? '').trim().isNotEmpty) ...[
                  _SoftTextBlock(
                    icon: Icons.notes_outlined,
                    color: InstructorColors.info,
                    text: section.instructions!,
                  ),
                  const SizedBox(height: 12),
                ],
                if (items.isEmpty)
                  _CompactEmpty(text: l10n.examSectionNoAssignedQuestions)
                else
                  ...items.asMap().entries.map(
                    (entry) => _SavedQuestionCard(
                      item: entry.value,
                      orderNumber: entry.key + 1,
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

class _SavedQuestionGroup extends StatelessWidget {
  const _SavedQuestionGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<ExamSnapshotItemModel> items;

  @override
  Widget build(BuildContext context) {
    return _ModernPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeading(
            icon: icon,
            color: color,
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map(
            (entry) => _SavedQuestionCard(
              item: entry.value,
              orderNumber: entry.key + 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedQuestionCard extends StatefulWidget {
  const _SavedQuestionCard({required this.item, required this.orderNumber});

  final ExamSnapshotItemModel item;
  final int orderNumber;

  @override
  State<_SavedQuestionCard> createState() => _SavedQuestionCardState();
}

class _SavedQuestionCardState extends State<_SavedQuestionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _expanded = !_expanded),
        onLongPress: () => _showActions(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: InstructorColors.primary.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              const PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: 5,
                child: ColoredBox(color: InstructorColors.primary),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuestionBadge(orderNumber: widget.orderNumber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuestionFormattedText(
                            text: widget.item.questionText,
                            fallback: l10n.examQuestionSnapshot,
                            maxLines: _expanded ? null : 3,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _IconAction(
                          icon: Icons.more_vert_rounded,
                          onTap: () => _showActions(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _metadataPills(context),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: InstructorColors.textSecondaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _expanded
                              ? l10n.examHideQuestionDetails
                              : l10n.examShowQuestionDetails,
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _expanded
                          ? _SavedQuestionDetails(item: widget.item)
                          : const SizedBox.shrink(),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 180),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metadataPills(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _InfoPill(
          label: l10n.examOrderNumber(widget.orderNumber),
          icon: Icons.format_list_numbered_rounded,
          color: InstructorColors.primary,
        ),
        if (widget.item.marks != null)
          _InfoPill(
            label: '${widget.item.marks} ${l10n.examMarks}',
            icon: Icons.score_outlined,
            color: InstructorColors.orange,
          ),
        if (widget.item.snapshotCreatedAt != null)
          _InfoPill(
            label: _formatDateTime(widget.item.snapshotCreatedAt!),
            icon: Icons.lock_clock_outlined,
            color: InstructorColors.cyan,
          ),
        if (widget.item.sourceGroupTitle != null)
          _InfoPill(
            label: widget.item.sourceGroupTitle!,
            icon: Icons.folder_copy_outlined,
            color: InstructorColors.accent,
          ),
        if (widget.item.sourceQuestionVersionId != null)
          _InfoPill(
            label: l10n.examVersionBadge(widget.item.sourceQuestionVersionId!),
            icon: Icons.history_rounded,
            color: InstructorColors.teal,
          ),
      ],
    );
  }

  Future<void> _showActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: InstructorColors.cardColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _QuestionBadge(orderNumber: widget.orderNumber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.examQuestionActions,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            QuestionFormattedText(
                              text: widget.item.questionText,
                              fallback: l10n.examQuestionSnapshot,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SheetAction(
                    icon: _expanded
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: InstructorColors.primary,
                    label: _expanded
                        ? l10n.examHideQuestionDetails
                        : l10n.examShowQuestionDetails,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      setState(() => _expanded = !_expanded);
                    },
                  ),
                  _SheetAction(
                    icon: Icons.info_outline_rounded,
                    color: InstructorColors.teal,
                    label: l10n.examSavedQuestionSnapshotDetails,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      setState(() => _expanded = true);
                    },
                  ),
                  _SheetAction(
                    icon: Icons.close_rounded,
                    color: InstructorColors.textSecondary,
                    label: l10n.close,
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SavedQuestionDetails extends StatefulWidget {
  const _SavedQuestionDetails({required this.item});

  final ExamSnapshotItemModel item;

  @override
  State<_SavedQuestionDetails> createState() => _SavedQuestionDetailsState();
}

class _SavedQuestionDetailsState extends State<_SavedQuestionDetails> {
  late final Future<QuestionBankQuestionModel?> _sourceQuestionFuture =
      _loadSourceQuestion();

  Future<QuestionBankQuestionModel?> _loadSourceQuestion() async {
    final sourceQuestionId = widget.item.sourceQuestionId;
    if (sourceQuestionId == null || sourceQuestionId <= 0) return null;
    final service = QuestionBankService(coreApiClient: CoreApiClient());
    final result = await service.getQuestion(sourceQuestionId);
    return result.data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuestionBankQuestionModel?>(
      future: _sourceQuestionFuture,
      builder: (context, snapshot) =>
          _buildDetails(context, sourceQuestion: snapshot.data),
    );
  }

  Widget _buildDetails(
    BuildContext context, {
    QuestionBankQuestionModel? sourceQuestion,
  }) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final answers = _answerWidgets(
      context,
      widget.item,
      sourceQuestion: sourceQuestion,
    );
    final media = _questionMediaItems(
      context,
      widget.item,
      sourceQuestion: sourceQuestion,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailSectionTitle(
              icon: Icons.fact_check_outlined,
              title: l10n.examAnswerAndDetails,
            ),
            const SizedBox(height: 10),
            ...answers,
            if (media.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailSectionTitle(
                icon: Icons.image_outlined,
                title: l10n.examSavedQuestionMedia,
              ),
              const SizedBox(height: 8),
              ...media.map(
                (mediaItem) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ImagePreview(
                    url: mediaItem.url,
                    title: mediaItem.label,
                  ),
                ),
              ),
            ],
            if ((widget.item.sourceGroupPrompt ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailSectionTitle(
                icon: Icons.folder_copy_outlined,
                title: l10n.examSavedSourceGroupPrompt,
              ),
              const SizedBox(height: 8),
              QuestionFormattedText(
                text: widget.item.sourceGroupPrompt,
                fallback: l10n.examQuestionSnapshot,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  height: 1.35,
                ),
              ),
            ],
            if (_sourceGroupImageUrls(widget.item).isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailSectionTitle(
                icon: Icons.photo_library_outlined,
                title: l10n.examSavedGroupMedia,
              ),
              const SizedBox(height: 8),
              _ImagePreview(
                url: _sourceGroupImageUrls(widget.item).first,
                fallbackUrls: _sourceGroupImageUrls(widget.item).skip(1),
                title: l10n.examSavedGroupMedia,
              ),
            ],
            const SizedBox(height: 12),
            _SnapshotMeta(item: widget.item),
          ],
        ),
      ),
    );
  }
}

class _SnapshotMeta extends StatelessWidget {
  const _SnapshotMeta({required this.item});

  final ExamSnapshotItemModel item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (item.snapshotCreatedAt != null)
          _InfoPill(
            icon: Icons.lock_clock_outlined,
            label: l10n.examSnapshotTimestamp(
              _formatDateTime(item.snapshotCreatedAt!),
            ),
            color: InstructorColors.cyan,
          ),
        if (item.sourceQuestionVersionId != null)
          _InfoPill(
            icon: Icons.history_rounded,
            label: l10n.examVersionBadge(item.sourceQuestionVersionId!),
            color: InstructorColors.teal,
          ),
        if (item.sourceGroupTitle != null)
          _InfoPill(
            icon: Icons.folder_copy_outlined,
            label: '${l10n.qbGroups}: ${item.sourceGroupTitle}',
            color: InstructorColors.accent,
          ),
      ],
    );
  }
}

class _LifecyclePanel extends StatelessWidget {
  const _LifecyclePanel({
    required this.isBusy,
    required this.onPublish,
    required this.onUnpublish,
    required this.onArchive,
    required this.onExport,
  });

  final bool isBusy;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onArchive;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ModernPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PanelHeading(
            icon: Icons.published_with_changes_outlined,
            color: InstructorColors.accent,
            title: l10n.examLifecycleTitle,
            subtitle: l10n.examLifecycleExplanation,
          ),
          if (isBusy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionChipButton(
                icon: Icons.publish_outlined,
                label: l10n.examPublish,
                color: InstructorColors.primary,
                onTap: isBusy ? null : onPublish,
              ),
              _ActionChipButton(
                icon: Icons.undo_rounded,
                label: l10n.examUnpublish,
                color: InstructorColors.accent,
                onTap: isBusy ? null : onUnpublish,
              ),
              _ActionChipButton(
                icon: Icons.archive_outlined,
                label: l10n.examArchive,
                color: InstructorColors.orange,
                onTap: isBusy ? null : onArchive,
              ),
              _ActionChipButton(
                icon: Icons.download_rounded,
                label: l10n.examExport,
                color: InstructorColors.teal,
                onTap: isBusy ? null : onExport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModernPanel extends StatelessWidget {
  const _ModernPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBubble(icon: icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            _IconBubble(icon: icon, color: color, size: 36, iconSize: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallMetaPill extends StatelessWidget {
  const _SmallMetaPill({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            '$label: ',
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
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
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    this.size = 46,
    this.iconSize = 22,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBubble(icon: icon, color: color, size: 34, iconSize: 17),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaperTextRow extends StatelessWidget {
  const _PaperTextRow({required this.row});

  final _TextRowData row;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.label,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            row.value!,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextRowData {
  const _TextRowData(this.label, this.value);

  final String label;
  final String? value;
}

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge({required this.orderNumber});

  final int orderNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        l10n.examQuestionShortNumber(orderNumber),
        style: const TextStyle(
          color: InstructorColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: InstructorColors.textSecondaryColor(isDark),
          size: 20,
        ),
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 18, color: InstructorColors.primary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftTextBlock extends StatelessWidget {
  const _SoftTextBlock({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: QuestionFormattedText(
              text: text,
              fallback: text,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: InstructorColors.textSecondaryColor(isDark),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.16 : 0.09),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              _IconBubble(icon: icon, color: color, size: 40, iconSize: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: InstructorColors.textSecondaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.url,
    this.fallbackUrls = const [],
    this.title,
  });

  final String url;
  final Iterable<String> fallbackUrls;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final child = _imageFromUrls(
      <String>[url, ...fallbackUrls],
      width: double.infinity,
      height: 180,
    );
    if (child == null) return const SizedBox.shrink();
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showImagePreviewDialog(
        context,
        url,
        title,
        fallbackUrls: fallbackUrls,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.zoom_out_map_rounded,
                size: 16,
                color: InstructorColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title == null || title!.trim().isEmpty
                      ? l10n.examPreviewImage
                      : '${l10n.examPreviewImage} • $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showImagePreviewDialog(
  BuildContext context,
  String url,
  String? title, {
  Iterable<String> fallbackUrls = const [],
}) {
  final l10n = AppLocalizations.of(context);
  final image = _imageFromUrls(
    <String>[url, ...fallbackUrls],
    width: double.infinity,
    height: MediaQuery.sizeOf(context).height * 0.72,
    fit: BoxFit.contain,
  );
  if (image == null) return Future.value();
  return showDialog<void>(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: InstructorColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title?.trim().isNotEmpty == true
                            ? title!.trim()
                            : l10n.examPreviewImage,
                        maxLines: 2,
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
                const SizedBox(height: 8),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.7,
                    maxScale: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: image,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

List<_SavedMediaItem> _questionMediaItems(
  BuildContext context,
  ExamSnapshotItemModel item, {
  QuestionBankQuestionModel? sourceQuestion,
}) {
  final l10n = AppLocalizations.of(context);
  final snapshot = _snapshotMap(item);
  final media = <_SavedMediaItem>[];
  final seenUrls = <String>{};
  final seenFileIds = <int>{};

  void addMedia(String? url, String label, {int? fileId}) {
    if (url == null || url.trim().isEmpty) return;
    final normalized = _normalizeImageUrl(url);
    if (normalized == null || !seenUrls.add(normalized)) return;
    if (fileId != null && !seenFileIds.add(fileId)) return;
    media.add(_SavedMediaItem(url: normalized, label: label));
  }

  final mainUrl =
      sourceQuestion?.questionImageUrl ??
      item.questionImagePreviewUrl ??
      _firstImageUrl(snapshot, const [
        'questionImagePreviewUrl',
        'questionImageUrl',
        'imageUrl',
        'previewUrl',
        'url',
        'questionFile',
        'file',
        'image',
      ]) ??
      _downloadUrlForFileId(
        item.questionFileId ?? _nullableInt(snapshot['questionFileId']),
      );
  addMedia(
    mainUrl,
    item.questionFileCaption ??
        item.questionFileAltText ??
        sourceQuestion?.questionFileCaption ??
        sourceQuestion?.questionFileAltText ??
        l10n.examSavedQuestionMedia,
    fileId: item.questionFileId ?? _nullableInt(snapshot['questionFileId']),
  );
  var index = 1;
  for (final attachment in sourceQuestion?.attachments ?? const []) {
    final fileId = attachment.fileId;
    final imageUrl = attachment.imageUrl;
    final resolvedUrl = imageUrl != null && _normalizeImageUrl(imageUrl) != null
        ? imageUrl
        : _downloadUrlForFileId(fileId);
    addMedia(
      resolvedUrl,
      attachment.caption ??
          attachment.altText ??
          '${l10n.examQuestionAttachments} $index',
      fileId: fileId,
    );
    index++;
  }
  final attachments = _firstList(snapshot, const [
    'attachmentsJson',
    'attachments',
  ]).whereType<Map>().map((value) => Map<String, dynamic>.from(value));
  for (final attachment in attachments) {
    final fileId = _nullableInt(attachment['fileId']);
    final url =
        _firstImageUrl(attachment, const [
          'previewUrl',
          'questionImagePreviewUrl',
          'questionImageUrl',
          'imageUrl',
          'url',
          'fileUrl',
          'downloadUrl',
          'file',
          'image',
        ]) ??
        _downloadUrlForFileId(fileId);
    if (url == null) continue;
    final label =
        _firstText(attachment, const ['caption', 'altText', 'label']) ??
        '${l10n.examQuestionAttachments} $index';
    addMedia(url, label, fileId: fileId);
    index++;
  }
  return media;
}

List<String> _sourceGroupImageUrls(ExamSnapshotItemModel item) {
  final snapshot = _snapshotMap(item);
  final fileId =
      item.sourceGroupFileId ??
      _nullableInt(snapshot['sourceGroupFileId']) ??
      _nullableInt(snapshot['sharedFileId']);
  final candidates = <String?>[
    _downloadUrlForFileId(fileId),
    item.sourceGroupImagePreviewUrl,
    _firstImageUrl(snapshot, const [
      'sourceGroupImagePreviewUrl',
      'sourceGroupImageUrl',
      'sourceGroupFile',
      'sourceGroupImage',
      'groupImagePreviewUrl',
      'groupImageUrl',
      'sharedImageUrl',
      'sharedFileUrl',
      'sharedFileImageUrl',
      'sharedFile',
      'file',
    ]),
  ];
  return _normalizedImageCandidates(candidates);
}

List<String> _normalizedImageCandidates(Iterable<String?> values) {
  final seen = <String>{};
  final urls = <String>[];
  for (final value in values) {
    if (value == null || value.trim().isEmpty) continue;
    final normalized = _normalizeImageUrl(value);
    if (normalized == null || !seen.add(normalized)) continue;
    urls.add(normalized);
  }
  return urls;
}

class _SavedMediaItem {
  const _SavedMediaItem({required this.url, required this.label});

  final String url;
  final String label;
}

List<Widget> _answerWidgets(
  BuildContext context,
  ExamSnapshotItemModel item, {
  QuestionBankQuestionModel? sourceQuestion,
}) {
  final l10n = AppLocalizations.of(context);
  final snapshot = _snapshotMap(item);
  final optionMaps = _firstList(snapshot, const [
    'optionsJson',
    'options',
    'answers',
    'choices',
    'questionOptions',
  ]).whereType<Map>().map((value) => Map<String, dynamic>.from(value)).toList();
  final blanks = _firstList(snapshot, const [
    'fillBlanksJson',
    'fillBlanks',
    'blanks',
    'fillBlankAnswers',
  ]).whereType<Map>().map((value) => Map<String, dynamic>.from(value)).toList();
  final answerText = _firstText(snapshot, const [
    'expectedAnswerText',
    'expectedAnswer',
    'answerText',
    'correctAnswer',
    'modelAnswer',
    'sampleAnswer',
    'answer',
  ]);
  final hints = _firstText(snapshot, const ['hints', 'hint', 'questionHints']);
  final widgets = <Widget>[];
  if (optionMaps.isNotEmpty) {
    for (final option in optionMaps) {
      final text = _firstText(option, const [
        'optionText',
        'text',
        'label',
        'content',
        'answerText',
        'value',
      ]);
      if (text == null) continue;
      final isCorrect = _truthy(
        option['isCorrect'] ?? option['correct'] ?? option['is_answer'],
      );
      widgets.add(
        _AnswerLine(
          text: text,
          isCorrect: isCorrect,
          correctLabel: l10n.correct,
        ),
      );
    }
  } else if (sourceQuestion?.options.isNotEmpty == true) {
    for (final option in sourceQuestion!.options) {
      widgets.add(
        _AnswerLine(
          text: option.optionText,
          isCorrect: option.isCorrect,
          correctLabel: l10n.correct,
        ),
      );
    }
  } else if (blanks.isNotEmpty) {
    for (final blank in blanks) {
      final key = _firstText(blank, const ['blankKey', 'key', 'label']);
      final text = _firstText(blank, const [
        'acceptableAnswer',
        'answer',
        'value',
        'text',
      ]);
      if (text == null) continue;
      widgets.add(_AnswerLine(text: key == null ? text : '$key: $text'));
    }
  } else if (sourceQuestion?.fillBlanks.isNotEmpty == true) {
    for (final blank in sourceQuestion!.fillBlanks) {
      widgets.add(
        _AnswerLine(text: '${blank.blankKey}: ${blank.acceptableAnswer}'),
      );
    }
  } else if (answerText != null) {
    widgets.add(
      _AnswerLine(
        text: answerText,
        isCorrect: true,
        correctLabel: l10n.correct,
      ),
    );
  } else if ((sourceQuestion?.expectedAnswerText ?? '').trim().isNotEmpty) {
    widgets.add(
      _AnswerLine(
        text: sourceQuestion!.expectedAnswerText!,
        isCorrect: true,
        correctLabel: l10n.correct,
      ),
    );
  }
  final resolvedHints = hints ?? sourceQuestion?.hints;
  if (resolvedHints != null && resolvedHints.trim().isNotEmpty) {
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _SoftTextBlock(
          icon: Icons.lightbulb_outline_rounded,
          color: InstructorColors.accent,
          text: '${l10n.qbQuestionHints}: $resolvedHints',
        ),
      ),
    );
  }
  if (widgets.isEmpty) {
    widgets.add(_AnswerLine(text: l10n.qbNoAnswerProvided));
  }
  return widgets;
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.text,
    this.isCorrect = false,
    this.correctLabel,
  });

  final String text;
  final bool isCorrect;
  final String? correctLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isCorrect
        ? InstructorColors.success
        : InstructorColors.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_outline_rounded
                : Icons.notes_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: QuestionFormattedText(
              text: isCorrect && correctLabel != null
                  ? '$correctLabel: $text'
                  : text,
              fallback: text,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _snapshotMap(ExamSnapshotItemModel item) {
  final snapshot = _asMap(item.raw['snapshot']);
  return snapshot.isEmpty ? item.raw : snapshot;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

String? _firstImageUrl(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final url = _imageUrlFromValue(source[key]);
    if (url != null) return url;
  }
  return null;
}

String? _imageUrlFromValue(dynamic value) {
  final direct = _nullableText(value);
  if (direct != null) return _normalizeImageUrl(direct);
  final map = _asMap(value);
  if (map.isEmpty) return null;
  return _firstImageUrl(map, const [
    'previewUrl',
    'questionImagePreviewUrl',
    'imageUrl',
    'url',
    'fileUrl',
    'downloadUrl',
    'publicUrl',
    'signedUrl',
    'filePath',
    'storagePath',
  ]);
}

String? _downloadUrlForFileId(int? fileId) {
  if (fileId == null || fileId <= 0) return null;
  return '${ApiService.baseUrl}/files/$fileId/download';
}

String? _normalizeImageUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('data:image') ||
      trimmed.startsWith('http://') ||
      trimmed.startsWith('https://')) {
    return trimmed;
  }
  final apiBase = ApiService.baseUrl;
  final origin = apiBase.endsWith('/api')
      ? apiBase.substring(0, apiBase.length - 4)
      : apiBase;
  if (trimmed.startsWith('/api/')) return '$origin$trimmed';
  if (trimmed.startsWith('/')) return '$origin$trimmed';
  if (trimmed.startsWith('api/')) return '$origin/$trimmed';
  return null;
}

String? _firstText(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) {
      final text = value
          .map((entry) => entry?.toString().trim())
          .where((entry) => entry != null && entry.isNotEmpty)
          .join(', ');
      if (text.isNotEmpty) return text;
      continue;
    }
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text != 'null') return text;
  }
  return null;
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty || text == 'null' ? null : text;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<dynamic> _firstList(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) return value;
  }
  return const <dynamic>[];
}

bool _truthy(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase().trim();
  return text == 'true' || text == '1' || text == 'yes';
}

Widget? _imageFromUrls(
  Iterable<String?> urls, {
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
}) {
  final candidates = _normalizedImageCandidates(urls);
  if (candidates.isEmpty) return null;
  return _FallbackImage(
    urls: candidates,
    width: width,
    height: height,
    fit: fit,
  );
}

Widget? _imageFromSingleUrl(
  String resolvedUrl, {
  required double width,
  required double height,
  required BoxFit fit,
  VoidCallback? onError,
}) {
  if (resolvedUrl.startsWith('data:image')) {
    final comma = resolvedUrl.indexOf(',');
    if (comma > -1) {
      try {
        final bytes = base64Decode(resolvedUrl.substring(comma + 1));
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return _ImageLoadingBox(width: width, height: height);
          },
          errorBuilder: (_, __, ___) {
            onError?.call();
            return _ImageErrorBox(width: width, height: height);
          },
        );
      } on FormatException {
        onError?.call();
        return null;
      }
    }
  }
  return _AuthenticatedImage(
    url: resolvedUrl,
    width: width,
    height: height,
    fit: fit,
    onError: onError,
  );
}

class _FallbackImage extends StatefulWidget {
  const _FallbackImage({
    required this.urls,
    required this.width,
    required this.height,
    required this.fit,
  });

  final List<String> urls;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  State<_FallbackImage> createState() => _FallbackImageState();
}

class _FallbackImageState extends State<_FallbackImage> {
  var _index = 0;

  @override
  void didUpdateWidget(covariant _FallbackImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.urls.join('\u0000') != widget.urls.join('\u0000')) {
      _index = 0;
    }
  }

  void _tryNext() {
    if (_index >= widget.urls.length - 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _index >= widget.urls.length - 1) return;
      setState(() => _index++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _imageFromSingleUrl(
      widget.urls[_index],
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      onError: _tryNext,
    );
    return image ?? _ImageErrorBox(width: widget.width, height: widget.height);
  }
}

class _AuthenticatedImage extends StatelessWidget {
  const _AuthenticatedImage({
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
    this.onError,
  });

  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final VoidCallback? onError;

  @override
  Widget build(BuildContext context) {
    final requiresAuth =
        url.contains('/api/files/') ||
        url.startsWith('${ApiService.baseUrl}/files/');
    if (!requiresAuth) return _networkImage(null);
    return FutureBuilder<String?>(
      future: StorageService().getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _ImageLoadingBox(width: width, height: height);
        }
        final token = snapshot.data;
        if (token == null || token.isEmpty) {
          return _ImageErrorBox(width: width, height: height);
        }
        return _networkImage(<String, String>{
          'Authorization': 'Bearer $token',
        });
      },
    );
  }

  Widget _networkImage(Map<String, String>? headers) {
    return Image.network(
      url,
      headers: headers,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _ImageLoadingBox(width: width, height: height);
      },
      errorBuilder: (_, __, ___) => _handleError(width: width, height: height),
    );
  }

  Widget _handleError({required double width, required double height}) {
    onError?.call();
    return _ImageErrorBox(width: width, height: height);
  }
}

class _ImageLoadingBox extends StatefulWidget {
  const _ImageLoadingBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<_ImageLoadingBox> createState() => _ImageLoadingBoxState();
}

class _ImageLoadingBoxState extends State<_ImageLoadingBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      color: InstructorColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.18 : 0.12,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: InstructorColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageErrorBox extends StatelessWidget {
  const _ImageErrorBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: InstructorColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: InstructorColors.textSecondaryColor(isDark),
      ),
    );
  }
}

int _questionCount(ExamFullDetailModel detail) {
  return detail.unsectionedItems.length +
      detail.sections.fold<int>(
        0,
        (sum, section) => sum + section.items.length,
      );
}

String _formatDateTime(DateTime value) {
  return value.toLocal().toString().split('.').first;
}
