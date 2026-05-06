import 'dart:convert';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/exams/exam_full_detail_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getFullExam(widget.examId);
    if (!mounted) return;
    setState(() {
      _detail = result.data;
      _error = result.error?.message;
      _loading = false;
    });
  }

  Future<void> _action(String action) async {
    final reason = await _askReason(action);
    if (reason == null) return;
    final result = await _service.lifecycle(
      examId: widget.examId,
      action: action,
      reason: reason,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error?.message ?? 'Exam updated')),
    );
    await _load();
  }

  Future<String?> _askReason(String action) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.examLifecycleReason),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.reason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    await context.push(
      '/instructor/exam-generator/exams/${widget.examId}/paper-export',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = _detail;
    final exam = detail?.exam;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examSavedDetails)),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: ExamGeneratorSkeletons(itemCount: 4),
            )
          : _error != null || detail == null || exam == null
          ? Center(
              child: FilledButton(onPressed: _load, child: Text(l10n.retry)),
            )
          : ListView(
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
                ),
                const SizedBox(height: 18),
                _SavedExamPreview(detail: detail),
                const SizedBox(height: 18),
                ExamGeneratorEmptyState(
                  title: l10n.examLifecycleTitle,
                  message: l10n.examLifecycleExplanation,
                ),
                const SizedBox(height: 18),
                ExamExportActions(
                  onPublish: () => _action('publish'),
                  onUnpublish: () => _action('unpublish'),
                  onArchive: () => _action('archive'),
                  onExport: _export,
                ),
              ],
            ),
    );
  }
}

class _SavedExamPreview extends StatelessWidget {
  const _SavedExamPreview({required this.detail});

  final ExamFullDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = detail.sections;
    final unsectioned = detail.unsectionedItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(l10n.examSnapshotHelp),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.examDoesNotAssignStudents,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (detail.durationMinutes != null)
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.examDurationMinutes),
            subtitle: Text(detail.durationMinutes.toString()),
          ),
        if ((detail.instructions ?? '').isNotEmpty)
          ListTile(
            leading: const Icon(Icons.notes_outlined),
            title: Text(l10n.instructions),
            subtitle: Text(detail.instructions!),
          ),
        ...sections.map((section) => _section(context, section)),
        if (unsectioned.isNotEmpty) ...[
          Text(
            l10n.examUnassignedQuestions,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...unsectioned.map((item) => _item(context, item)),
        ],
      ],
    );
  }

  Widget _section(BuildContext context, ExamFullSectionModel section) {
    return Card(
      elevation: 0,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(section.title),
        subtitle: Text(section.totalMarks?.toString() ?? ''),
        children: section.items.map((item) => _item(context, item)).toList(),
      ),
    );
  }

  Widget _item(BuildContext context, ExamSnapshotItemModel item) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: _preview(item.questionImagePreviewUrl) ??
          Icon(
            item.questionFileId != null
                ? Icons.image_outlined
                : Icons.quiz_outlined,
          ),
      title: Text(
        item.questionText.isEmpty
            ? l10n.examQuestionSnapshot
            : item.questionText,
      ),
      subtitle: Text(
        [
          if (item.sourceGroupTitle != null)
            '${l10n.qbGroups}: ${item.sourceGroupTitle}',
          if (item.snapshotCreatedAt != null)
            l10n.examSnapshotTimestamp(
              item.snapshotCreatedAt!.toLocal().toString().split('.').first,
            ),
          if (item.sourceQuestionVersionId != null)
            l10n.examVersionBadge(item.sourceQuestionVersionId!),
          if (item.marks != null) '${item.marks} ${l10n.marks}',
        ].join('\n'),
      ),
    );
  }

  Widget? _preview(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image')) {
      final comma = url.indexOf(',');
      if (comma > -1) {
        final bytes = base64Decode(url.substring(comma + 1));
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, width: 48, height: 48, fit: BoxFit.cover),
        );
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined),
      ),
    );
  }
}
