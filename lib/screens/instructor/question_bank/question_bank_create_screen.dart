import 'dart:io';

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
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

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
            l10n.questionBankCreateQuestion,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
            ),
            onPressed: () => _handleBack(context),
          ),
        ),
        body: BlocConsumer<QuestionFormCubit, QuestionFormState>(
          listenWhen: _feedbackChanged,
          listener: _listen,
          builder: (context, state) {
            if (_loadingCourses || state.isLoading) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: const [QuestionBankSkeletons(itemCount: 3)],
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
      safeFeatureBack(context, '/instructor/question-bank');
    }
  }

  Future<void> _showCreateSuccessActions(BuildContext context) async {
    final cubit = context.read<QuestionFormCubit>();
    final question = cubit.state.savedQuestion;
    if (question == null) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _QuestionCreatedDialog(
        onReviewLater: () {
          Navigator.of(dialogContext).pop();
          context.go('/instructor/question-bank');
        },
        onView: () {
          Navigator.of(dialogContext).pop();
          context.go('/instructor/question-bank/${question.id}');
        },
        onSubmitForReview: () async {
          final ok = await cubit.statusSavedQuestion('submit-for-review');
          if (ok && context.mounted) {
            Navigator.of(dialogContext).pop();
            context.go('/instructor/question-bank/${question.id}');
          }
          return ok;
        },
        onApprove: () async {
          final ok = await cubit.statusSavedQuestion('approve');
          if (ok && context.mounted) {
            Navigator.of(dialogContext).pop();
            context.go('/instructor/question-bank/${question.id}');
          }
          return ok;
        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasQuestionImage =
        state.questionFileId != null ||
        state.questionImageUrl != null ||
        state.questionImageLocalPath != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
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
          icon: Icons.fact_check_outlined,
          color: InstructorColors.primary,
          children: [
            if (courses.isEmpty || lockCourse)
              TextFormField(
                key: ValueKey(
                  'question-course-${state.courseId}-${courses.length}-$lockCourse',
                ),
                initialValue: _courseLabel(),
                enabled: false,
                decoration: _decoration(context, l10n.course),
              )
            else
              QuestionFormMenuField<int>(
                label: l10n.course,
                value: state.courseId,
                icon: Icons.school_outlined,
                color: InstructorColors.primary,
                options: courses
                    .map(
                      (course) => QuestionFormMenuOption<int>(
                        value: course.courseId,
                        label: '${course.course.code} - ${course.course.name}',
                        icon: Icons.menu_book_outlined,
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  context.read<QuestionFormCubit>().selectCourse(value);
                },
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
              decoration: _decoration(
                context,
                l10n.qbQuestionPrompt,
                icon: Icons.help_outline_rounded,
              ),
              onChanged: (value) => context
                  .read<QuestionFormCubit>()
                  .updateCore(questionText: value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.hints,
              minLines: 2,
              maxLines: 4,
              decoration: _decoration(
                context,
                l10n.qbQuestionHints,
                icon: Icons.lightbulb_outline_rounded,
              ),
              onChanged: (value) =>
                  context.read<QuestionFormCubit>().updateCore(hints: value),
            ),
            const SizedBox(height: 12),
            _QuestionImageUploadPanel(
              state: state,
              isDark: isDark,
              onPick: () => _pickQuestionImage(context),
              onRemove: () =>
                  context.read<QuestionFormCubit>().removeQuestionImage(),
              onPreview:
                  state.questionImageUrl == null &&
                      state.questionImageLocalPath == null
                  ? null
                  : () => _showQuestionImagePreview(
                      context,
                      imageUrl: state.questionImageUrl,
                      localPath: state.questionImageLocalPath,
                      title: state.questionFileCaption.trim().isNotEmpty
                          ? state.questionFileCaption
                          : _questionImageLabel(l10n),
                    ),
            ),
            if (state.questionFileId != null) ...[
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      state.questionImageUrl == null &&
                          state.questionImageLocalPath == null
                      ? null
                      : () => _showQuestionImagePreview(
                          context,
                          imageUrl: state.questionImageUrl,
                          localPath: state.questionImageLocalPath,
                          title: state.questionFileCaption.trim().isNotEmpty
                              ? state.questionFileCaption
                              : _questionImageLabel(l10n),
                        ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: InstructorColors.primary.withValues(
                        alpha: isDark ? 0.16 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: InstructorColors.primary.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          color: InstructorColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _questionImageLabel(l10n),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (state.questionImageUrl != null ||
                            state.questionImageLocalPath != null)
                          const Icon(
                            Icons.visibility_outlined,
                            color: InstructorColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (hasQuestionImage) ...[
              const SizedBox(height: 12),
              TextFormField(
                initialValue: state.questionFileCaption,
                decoration: _decoration(
                  context,
                  l10n.qbImageCaption,
                  icon: Icons.closed_caption_outlined,
                ),
                onChanged: (value) => context
                    .read<QuestionFormCubit>()
                    .updateCore(questionFileCaption: value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: state.questionFileAltText,
                decoration: _decoration(
                  context,
                  l10n.qbImageAltText,
                  icon: Icons.accessibility_new_outlined,
                ),
                onChanged: (value) => context
                    .read<QuestionFormCubit>()
                    .updateCore(questionFileAltText: value),
              ),
            ],
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
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 460;
                final width = compact
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    QuestionFormMenuField<QuestionBankType>(
                      width: width,
                      label: l10n.type,
                      value: state.questionType,
                      icon: Icons.category_outlined,
                      color: InstructorColors.primary,
                      options: QuestionBankType.values
                          .map(
                            (value) => QuestionFormMenuOption<QuestionBankType>(
                              value: value,
                              label: localizedQuestionType(l10n, value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => context
                          .read<QuestionFormCubit>()
                          .updateCore(questionType: value),
                    ),
                    QuestionFormMenuField<QuestionBankDifficulty>(
                      width: width,
                      label: l10n.difficulty,
                      value: state.difficulty,
                      icon: Icons.speed_rounded,
                      color: InstructorColors.teal,
                      options: QuestionBankDifficulty.values
                          .map(
                            (value) =>
                                QuestionFormMenuOption<QuestionBankDifficulty>(
                                  value: value,
                                  label: localizedDifficulty(l10n, value),
                                ),
                          )
                          .toList(),
                      onChanged: (value) => context
                          .read<QuestionFormCubit>()
                          .updateCore(difficulty: value),
                    ),
                    QuestionFormMenuField<BloomLevel>(
                      width: compact ? constraints.maxWidth : width,
                      label: l10n.qbBloomLevel,
                      value: state.bloomLevel,
                      icon: Icons.psychology_outlined,
                      color: InstructorColors.accent,
                      options: BloomLevel.values
                          .map(
                            (value) => QuestionFormMenuOption<BloomLevel>(
                              value: value,
                              label: localizedBloomLevel(l10n, value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => context
                          .read<QuestionFormCubit>()
                          .updateCore(bloomLevel: value),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            if (state.questionType == QuestionBankType.mcq ||
                state.questionType == QuestionBankType.trueFalse)
              QuestionOptionsEditor(
                options: state.options,
                lockCount: state.questionType == QuestionBankType.trueFalse,
                singleCorrect: state.questionType == QuestionBankType.trueFalse,
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
                decoration: _decoration(
                  context,
                  l10n.qbAnswer,
                  icon: Icons.notes_rounded,
                ),
                onChanged: (value) => context
                    .read<QuestionFormCubit>()
                    .updateCore(expectedAnswerText: value),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _QuestionFormSubmitBar(
          label: submitLabel,
          isSaving: state.isSaving,
          onSubmit: onSubmit,
        ),
      ],
    );
  }

  InputDecoration _decoration(
    BuildContext context,
    String label, {
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: InstructorColors.surfaceColor(isDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: InstructorColors.primary,
          width: 1.4,
        ),
      ),
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

  String _questionImageLabel(AppLocalizations l10n) {
    final localPath = state.questionImageLocalPath;
    final fileId = state.questionFileId;
    if (fileId != null &&
        fileId <= 0 &&
        localPath != null &&
        localPath.trim().isNotEmpty) {
      return _fileNameFromPath(localPath);
    }
    if (fileId != null) {
      return '${l10n.questionBankImageQuestion}: $fileId';
    }
    return l10n.questionBankImageQuestion;
  }

  Future<void> _pickQuestionImage(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path != null && context.mounted) {
      await context.read<QuestionFormCubit>().uploadQuestionImage(path);
    }
  }

  Future<void> _showQuestionImagePreview(
    BuildContext context, {
    String? imageUrl,
    String? localPath,
    required String title,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: InstructorColors.primary.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: InstructorColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                    child: localPath != null && localPath.trim().isNotEmpty
                        ? Image.file(
                            File(localPath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              size: 64,
                            ),
                          )
                        : Image.network(
                            imageUrl ?? '',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              size: 64,
                            ),
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

  Future<void> _showCreateChapter(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: QuestionChapterFormCard(
              suggestedOrder: _nextChapterOrder(),
              occupiedOrders: state.chapters
                  .where((chapter) => chapter.isActive)
                  .map((chapter) => chapter.chapterOrder)
                  .toList(),
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

  int _nextChapterOrder() {
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

class _QuestionImageUploadPanel extends StatelessWidget {
  const _QuestionImageUploadPanel({
    required this.state,
    required this.isDark,
    required this.onPick,
    required this.onRemove,
    this.onPreview,
  });

  final QuestionFormState state;
  final bool isDark;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = state.questionFileId != null;
    final label = hasImage
        ? l10n.qbReplaceQuestionImage
        : l10n.qbUploadQuestionImage;
    final color = hasImage ? InstructorColors.teal : InstructorColors.primary;
    final imageLabel = _imageLabel(l10n);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state.isUploading ? null : onPreview ?? onPick,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.14 : 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: state.isUploading
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : Icon(
                        hasImage
                            ? Icons.image_search_rounded
                            : Icons.add_photo_alternate_outlined,
                        color: color,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasImage ? imageLabel : l10n.image,
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
              const SizedBox(width: 8),
              IconButton(
                tooltip: label,
                onPressed: state.isUploading ? null : onPick,
                style: IconButton.styleFrom(
                  backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  foregroundColor: color,
                  minimumSize: const Size(40, 40),
                ),
                icon: Icon(
                  hasImage ? Icons.sync_rounded : Icons.upload_rounded,
                ),
              ),
              if (hasImage && onPreview != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: l10n.questionBankImageQuestion,
                  onPressed: state.isUploading ? null : onPreview,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.primary,
                    minimumSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                ),
              ],
              if (hasImage) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: l10n.remove,
                  onPressed: state.isUploading ? null : onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.error.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.error,
                    minimumSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _imageLabel(AppLocalizations l10n) {
    final localPath = state.questionImageLocalPath;
    final fileId = state.questionFileId;
    if (fileId != null &&
        fileId <= 0 &&
        localPath != null &&
        localPath.trim().isNotEmpty) {
      return _fileNameFromPath(localPath);
    }
    if (fileId != null) {
      return '${l10n.questionBankImageQuestion} #$fileId';
    }
    return l10n.image;
  }
}

String _fileNameFromPath(String path) {
  final parts = path.split(RegExp(r'[\\/]'));
  return parts.isEmpty ? path : parts.last;
}

class _QuestionFormSubmitBar extends StatelessWidget {
  const _QuestionFormSubmitBar({
    required this.label,
    required this.isSaving,
    required this.onSubmit,
  });

  final String label;
  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: isSaving ? null : onSubmit,
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
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class QuestionFormDecisionDialog extends StatelessWidget {
  const QuestionFormDecisionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.2 : 0.11),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 23),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 360;
                  final buttons = [
                    OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: InstructorColors.textPrimaryColor(
                          isDark,
                        ),
                        side: BorderSide(
                          color: InstructorColors.borderColor(isDark),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        secondaryLabel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FilledButton(
                      onPressed: onPrimary,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ];
                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buttons.first,
                        const SizedBox(height: 10),
                        buttons.last,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: buttons.first),
                      const SizedBox(width: 10),
                      Expanded(child: buttons.last),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCreatedDialog extends StatefulWidget {
  const _QuestionCreatedDialog({
    required this.onReviewLater,
    required this.onView,
    required this.onSubmitForReview,
    required this.onApprove,
  });

  final VoidCallback onReviewLater;
  final VoidCallback onView;
  final Future<bool> Function() onSubmitForReview;
  final Future<bool> Function() onApprove;

  @override
  State<_QuestionCreatedDialog> createState() => _QuestionCreatedDialogState();
}

class _QuestionCreatedDialogState extends State<_QuestionCreatedDialog> {
  String? _activeAction;

  Future<void> _runAction(
    String action,
    Future<bool> Function() callback,
  ) async {
    if (_activeAction != null) return;
    setState(() => _activeAction = action);
    final ok = await callback();
    if (!ok && mounted) setState(() => _activeAction = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: InstructorColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: InstructorColors.borderColor(isDark)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              InstructorColors.success,
                              InstructorColors.teal,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.qbQuestionCreatedDraftTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.qbQuestionCreatedDraftBody,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: InstructorColors.textSecondaryColor(
                                  isDark,
                                ),
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 420;
                      final width = narrow
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _QuestionCreatedAction(
                            width: width,
                            label: l10n.qbReviewLater,
                            icon: Icons.schedule_rounded,
                            color: InstructorColors.textSecondary,
                            isDark: isDark,
                            onTap: widget.onReviewLater,
                          ),
                          _QuestionCreatedAction(
                            width: width,
                            label: l10n.qbViewQuestion,
                            icon: Icons.visibility_outlined,
                            color: InstructorColors.primary,
                            isDark: isDark,
                            onTap: widget.onView,
                          ),
                          _QuestionCreatedAction(
                            width: width,
                            label: l10n.submitForReview,
                            icon: Icons.outbox_rounded,
                            color: InstructorColors.info,
                            isDark: isDark,
                            onTap: () => _runAction(
                              'submit-for-review',
                              widget.onSubmitForReview,
                            ),
                          ),
                          _QuestionCreatedAction(
                            width: width,
                            label: l10n.qbApprove,
                            icon: Icons.verified_rounded,
                            color: InstructorColors.success,
                            isDark: isDark,
                            onTap: () =>
                                _runAction('approve', widget.onApprove),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_activeAction != null)
              Positioned.fill(
                child: _CreatedQuestionMutationOverlay(
                  action: _activeAction!,
                  isDark: isDark,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreatedQuestionMutationOverlay extends StatelessWidget {
  const _CreatedQuestionMutationOverlay({
    required this.action,
    required this.isDark,
  });

  final String action;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = action == 'approve' ? l10n.qbApprove : l10n.submitForReview;
    return AbsorbPointer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: isDark ? 0.48 : 0.28),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: InstructorColors.primary.withValues(
                alpha: isDark ? 0.35 : 0.18,
              ),
            ),
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
                'Please wait until the question is updated.',
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
    );
  }
}

class _QuestionCreatedAction extends StatelessWidget {
  const _QuestionCreatedAction({
    required this.width,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final double width;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: color.withValues(alpha: isDark ? 0.16 : 0.08),
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.24)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          alignment: Alignment.centerLeft,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
