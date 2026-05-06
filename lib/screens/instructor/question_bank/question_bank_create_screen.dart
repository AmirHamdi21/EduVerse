import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_form_cubit.dart';
import '../../../bloc/instructor/question_bank/question_form_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionBankCreateScreen extends StatelessWidget {
  const QuestionBankCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionFormCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..initializeCreate(),
      child: const _QuestionBankCreateView(),
    );
  }
}

class _QuestionBankCreateView extends StatefulWidget {
  const _QuestionBankCreateView();

  @override
  State<_QuestionBankCreateView> createState() =>
      _QuestionBankCreateViewState();
}

class _QuestionBankCreateViewState extends State<_QuestionBankCreateView> {
  List<TeachingCourseModel> _courses = const [];
  bool _loadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final result = await EnrollmentService(
      coreApiClient: CoreApiClient(),
    ).getTeachingCourses();
    if (!mounted) return;
    _courses = result.data ?? const [];
    _loadingCourses = false;
    setState(() {});
    if (_courses.isNotEmpty) {
      await context.read<QuestionFormCubit>().selectCourse(
        _courses.first.courseId,
      );
    }
  }

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
          title: Text(l10n.questionBankCreateQuestion),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _handleBack(context),
          ),
        ),
        body: BlocConsumer<QuestionFormCubit, QuestionFormState>(
          listenWhen: _feedbackChanged,
          listener: _listen,
          builder: (context, state) {
            if (_loadingCourses || state.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: QuestionBankSkeletons(itemCount: 4),
              );
            }
            return QuestionFormBody(
              courses: _courses,
              state: state,
              heroTitle: l10n.questionBankStudioTitle,
              heroSubtitle: l10n.questionBankStudioSubtitle,
              submitLabel: l10n.save,
              onSubmit: () async {
                final ok = await context.read<QuestionFormCubit>().submit();
                if (ok && context.mounted) {
                  await _showCreateSuccessActions(context);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final cubit = context.read<QuestionFormCubit>();
    if (cubit.hasDiscardableUploads) {
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

  Future<void> _showCreateSuccessActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<QuestionFormCubit>();
    final question = cubit.state.savedQuestion;
    if (question == null) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.qbQuestionCreatedDraftTitle),
        content: Text(l10n.qbQuestionCreatedDraftBody),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/instructor/question-bank');
            },
            child: Text(l10n.qbReviewLater),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/instructor/question-bank/${question.id}');
            },
            child: Text(l10n.qbViewQuestion),
          ),
          FilledButton.tonal(
            onPressed: () async {
              final ok = await cubit.statusSavedQuestion('submit-for-review');
              if (ok && context.mounted) {
                Navigator.of(dialogContext).pop();
                context.go('/instructor/question-bank/${question.id}');
              }
            },
            child: Text(l10n.submitForReview),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await cubit.statusSavedQuestion('approve');
              if (ok && context.mounted) {
                Navigator.of(dialogContext).pop();
                context.go('/instructor/question-bank/${question.id}');
              }
            },
            child: Text(l10n.qbApprove),
          ),
        ],
      ),
    );
  }

  bool _feedbackChanged(QuestionFormState previous, QuestionFormState current) {
    final previousMessage =
        previous.validationError ??
        previous.errorMessage ??
        previous.successMessage;
    final currentMessage =
        current.validationError ??
        current.errorMessage ??
        current.successMessage;
    return currentMessage != null && currentMessage != previousMessage;
  }

  void _listen(BuildContext context, QuestionFormState state) {
    final l10n = AppLocalizations.of(context);
    final message =
        state.validationError ?? state.errorMessage ?? state.successMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedQuestionBankMessage(l10n, message))),
      );
    }
  }
}

class QuestionFormBody extends StatelessWidget {
  const QuestionFormBody({
    super.key,
    required this.courses,
    required this.state,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.submitLabel,
    required this.onSubmit,
    this.lockCourse = false,
  });

  final List<TeachingCourseModel> courses;
  final QuestionFormState state;
  final String heroTitle;
  final String heroSubtitle;
  final String submitLabel;
  final VoidCallback onSubmit;
  final bool lockCourse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        QuestionFormHero(
          title: heroTitle,
          subtitle: heroSubtitle,
          tiles: {
            l10n.type: localizedQuestionType(l10n, state.questionType),
            l10n.difficulty: localizedDifficulty(l10n, state.difficulty),
            l10n.qbBloomLevel: localizedBloomLevel(l10n, state.bloomLevel),
            l10n.chapter: state.chapterId?.toString() ?? '-',
          },
        ),
        const SizedBox(height: 18),
        QuestionCoreSection(
          title: l10n.qbCoreDetails,
          children: [
            if (courses.isEmpty || lockCourse)
              TextFormField(
                key: ValueKey(
                  'question-course-${state.courseId}-${courses.length}-$lockCourse',
                ),
                initialValue: _courseLabel(),
                enabled: false,
                decoration: _decoration(l10n.course),
              )
            else
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: state.courseId,
                decoration: _decoration(l10n.course),
                items: courses
                    .map(
                      (course) => DropdownMenuItem<int>(
                        value: course.courseId,
                        child: Text(
                          '${course.course.code} - ${course.course.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    context.read<QuestionFormCubit>().selectCourse(value),
              ),
            const SizedBox(height: 12),
            QuestionChapterSelector(
              value: state.chapterId,
              chapters: state.chapters,
              onChanged: (value) => context
                  .read<QuestionFormCubit>()
                  .updateCore(chapterId: value),
              onCreateChapter: () => _showCreateChapter(context),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.questionText,
              minLines: 4,
              maxLines: 8,
              decoration: _decoration(l10n.questionBankSearchQuestionTextOnly),
              onChanged: (value) => context
                  .read<QuestionFormCubit>()
                  .updateCore(questionText: value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.hints,
              minLines: 2,
              maxLines: 4,
              decoration: _decoration(l10n.qbQuestionHints),
              onChanged: (value) =>
                  context.read<QuestionFormCubit>().updateCore(hints: value),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: state.isUploading
                      ? null
                      : () => _pickQuestionImage(context),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    state.questionFileId == null
                        ? l10n.qbUploadQuestionImage
                        : l10n.qbReplaceQuestionImage,
                  ),
                ),
                if (state.questionFileId != null)
                  IconButton.outlined(
                    tooltip: l10n.qbRemoveQuestionImage,
                    onPressed: state.isUploading
                        ? null
                        : () => context
                              .read<QuestionFormCubit>()
                              .removeQuestionImage(),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            if (state.questionFileId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, color: Color(0xFF2563EB)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${l10n.questionBankImageQuestion}: ${state.questionFileId}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.questionFileCaption,
              decoration: _decoration(l10n.qbImageCaption),
              onChanged: (value) => context
                  .read<QuestionFormCubit>()
                  .updateCore(questionFileCaption: value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.questionFileAltText,
              decoration: _decoration(l10n.qbImageAltText),
              onChanged: (value) => context
                  .read<QuestionFormCubit>()
                  .updateCore(questionFileAltText: value),
            ),
            if (state.originalQuestion == null) ...[
              const SizedBox(height: 12),
              QuestionPendingAttachmentManager(
                attachments: state.attachments,
                isUploading: state.isUploading,
                onUpload: context
                    .read<QuestionFormCubit>()
                    .uploadCreateAttachments,
                onChanged: context
                    .read<QuestionFormCubit>()
                    .updateCreateAttachment,
                onRemove: context
                    .read<QuestionFormCubit>()
                    .removeCreateAttachment,
                onReorder: context
                    .read<QuestionFormCubit>()
                    .reorderCreateAttachments,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        QuestionTypeSection(
          title: l10n.qbQuestionSettings,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _EnumDropdown<QuestionBankType>(
                  label: l10n.type,
                  value: state.questionType,
                  values: QuestionBankType.values,
                  text: (value) => localizedQuestionType(l10n, value),
                  onChanged: (value) => context
                      .read<QuestionFormCubit>()
                      .updateCore(questionType: value),
                ),
                _EnumDropdown<QuestionBankDifficulty>(
                  label: l10n.difficulty,
                  value: state.difficulty,
                  values: QuestionBankDifficulty.values,
                  text: (value) => localizedDifficulty(l10n, value),
                  onChanged: (value) => context
                      .read<QuestionFormCubit>()
                      .updateCore(difficulty: value),
                ),
                _EnumDropdown<BloomLevel>(
                  label: l10n.qbBloomLevel,
                  value: state.bloomLevel,
                  values: BloomLevel.values,
                  text: (value) => localizedBloomLevel(l10n, value),
                  onChanged: (value) => context
                      .read<QuestionFormCubit>()
                      .updateCore(bloomLevel: value),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (state.questionType == QuestionBankType.mcq ||
                state.questionType == QuestionBankType.trueFalse)
              QuestionOptionsEditor(
                options: state.options,
                lockCount: state.questionType == QuestionBankType.trueFalse,
                onChanged: context.read<QuestionFormCubit>().updateOptions,
              ),
            if (state.questionType == QuestionBankType.fillBlanks)
              QuestionFillBlanksEditor(
                blanks: state.fillBlanks,
                onChanged: context.read<QuestionFormCubit>().updateFillBlanks,
              ),
            if (state.questionType == QuestionBankType.written ||
                state.questionType == QuestionBankType.essay)
              TextFormField(
                initialValue: state.expectedAnswerText,
                minLines: 3,
                maxLines: 6,
                decoration: _decoration(l10n.qbAnswer),
                onChanged: (value) => context
                    .read<QuestionFormCubit>()
                    .updateCore(expectedAnswerText: value),
              ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: state.isSaving ? null : onSubmit,
          icon: const Icon(Icons.save_outlined),
          label: Text(submitLabel),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  String _courseLabel() {
    for (final course in courses) {
      if (course.courseId == state.courseId) {
        return '${course.course.code} - ${course.course.name}';
      }
    }
    return state.courseId?.toString() ?? '';
  }

  Future<void> _pickQuestionImage(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path != null && context.mounted) {
      await context.read<QuestionFormCubit>().uploadQuestionImage(path);
    }
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
                await context.read<QuestionFormCubit>().createChapter(
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

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.text,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) text;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: values
            .map(
              (value) => DropdownMenuItem<T>(
                value: value,
                child: Text(text(value), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
