import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/exam_generator/exam_generator_form_cubit.dart';
import '../../../bloc/instructor/exam_generator/exam_generator_form_state.dart';
import '../../../models/exams/exam_availability_model.dart';
import '../../../models/exams/exam_generation_form_model.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generation_section_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/question_bank/question_bank_mutation_overlay.dart';
import '../../../widgets/instructor/question_bank/question_form_menu_field.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import 'exam_generator_info_screen.dart';

class ExamGeneratorCreateScreen extends StatelessWidget {
  const ExamGeneratorCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamGeneratorFormCubit(
        examGeneratorService: ExamGeneratorService(
          coreApiClient: CoreApiClient(),
        ),
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
        enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
      )..initialize(),
      child: const _ExamGeneratorCreateView(),
    );
  }
}

class _ExamGeneratorCreateView extends StatelessWidget {
  const _ExamGeneratorCreateView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => safeBack(context, '/instructor/dashboard'),
          icon: Icon(iosBackIcon(context)),
        ),
        title: Text(l10n.examGeneratorCreateDraft),
        actions: [
          IconButton(
            tooltip: l10n.examGeneratorInfoTitle,
            onPressed: () => showExamGeneratorInfoSheet(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      bottomNavigationBar:
          BlocBuilder<ExamGeneratorFormCubit, ExamGeneratorFormState>(
            builder: (context, state) => _StickyGenerateBar(
              state: state,
              questionCount: _questionCount(state),
              onGenerate:
                  state.isSubmitting ||
                      state.isCheckingAvailability ||
                      state.isLoadingCourseData ||
                      state.availability?.canGenerate != true
                  ? null
                  : () async {
                      final draftId = await context
                          .read<ExamGeneratorFormCubit>()
                          .submit();
                      if (draftId != null && context.mounted) {
                        context.go(
                          '/instructor/exam-generator/drafts/$draftId',
                        );
                      }
                    },
            ),
          ),
      body: BlocConsumer<ExamGeneratorFormCubit, ExamGeneratorFormState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            current.errorMessage != previous.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizedExamMessage(l10n, state.errorMessage!)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: ExamGeneratorSkeletons(itemCount: 4),
            );
          }
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      constraints.maxWidth >= 900 ? 28 : 20,
                      12,
                      constraints.maxWidth >= 900 ? 28 : 20,
                      108,
                    ),
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 980),
                          child: Column(
                            children: [
                              ExamGeneratorHeroHeader(
                                title: l10n.examGeneratorStudioTitle,
                                subtitle: l10n.examGeneratorStudioSubtitle,
                                isDark: isDark,
                                stats: {
                                  l10n.course: _courseLabel(state),
                                  l10n.examQuestionCount: _questionCount(
                                    state,
                                  ).toString(),
                                  l10n.totalMarks:
                                      state.totalMarks?.toString() ?? '-',
                                },
                              ),
                              const SizedBox(height: 14),
                              _Basics(state: state),
                              if (state.isLoadingCourseData) ...[
                                const SizedBox(height: 12),
                                const _CourseDataStrip(),
                              ],
                              const SizedBox(height: 14),
                              ExamShortagePanel(
                                shortages: state.shortages,
                                chapters: state.chapters,
                              ),
                              ExamGenerationValidationPanel(
                                message: state.errorMessage,
                              ),
                              ExamAvailabilityPanel(
                                availability: state.availability,
                                isLoading: state.isCheckingAvailability,
                                onViewMatchingQuestions: (bucket) =>
                                    context.push(
                                      _questionBankUrl(
                                        bucket,
                                        approvedOnly: true,
                                      ),
                                    ),
                                onApproveMoreQuestions: (bucket) =>
                                    context.push(
                                      _questionBankUrl(
                                        bucket,
                                        approvedOnly: false,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 14),
                              ExamGenerationModeToggle(
                                value: state.mode,
                                onChanged: (mode) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(mode: mode),
                              ),
                              const SizedBox(height: 14),
                              ExamGenerationSettingsCard(
                                totalMarks: state.totalMarks,
                                markMode: state.markDistributionMode,
                                rounding: state.roundingPolicy,
                                groupSelectionMode: state.groupSelectionMode,
                                seed: state.seed,
                                durationMinutes: state.durationMinutes,
                                instructions: state.instructions,
                                headerText: state.headerText,
                                footerText: state.footerText,
                                onTotalMarksChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(
                                      totalMarks: value,
                                      clearTotalMarks: value == null,
                                    ),
                                onMarkModeChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(markDistributionMode: value),
                                onRoundingChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(roundingPolicy: value),
                                onGroupModeChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(groupSelectionMode: value),
                                onSeedChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(seed: value),
                                onRandomSeed: () => context
                                    .read<ExamGeneratorFormCubit>()
                                    .randomizeSeed(),
                                onClearSeed: () => context
                                    .read<ExamGeneratorFormCubit>()
                                    .clearSeed(),
                                onDurationChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(
                                      durationMinutes: value,
                                      clearDuration: value == null,
                                    ),
                                onInstructionsChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(instructions: value),
                                onHeaderChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(headerText: value),
                                onFooterChanged: (value) => context
                                    .read<ExamGeneratorFormCubit>()
                                    .updateBasics(footerText: value),
                              ),
                              const SizedBox(height: 14),
                              if (state.mode == ExamGenerationMode.flat)
                                _FlatRules(state: state)
                              else
                                _SectionedRules(state: state),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (state.isSubmitting)
                Positioned.fill(
                  child: QuestionBankMutationOverlay(
                    title: 'Generating draft',
                    message:
                        'Please wait while the exam draft is created and prepared.',
                    isDark: isDark,
                    color: InstructorColors.primary,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  int _questionCount(ExamGeneratorFormState state) {
    if (state.mode == ExamGenerationMode.flat) {
      return state.rules.fold(0, (total, rule) => total + rule.count);
    }
    return state.sections.fold(
      0,
      (total, section) =>
          total + section.rules.fold(0, (sum, rule) => sum + rule.count),
    );
  }

  String _courseLabel(ExamGeneratorFormState state) {
    final courseId = state.courseId;
    if (courseId == null) return '-';
    for (final course in state.courses) {
      if (course.courseId == courseId) {
        return '${course.course.code} - ${course.course.name}';
      }
    }
    return courseId.toString();
  }

  String _questionBankUrl(
    ExamAvailabilityBucketModel bucket, {
    required bool approvedOnly,
  }) {
    final filters = bucket.filters;
    final query = <String, String>{};
    void put(String key, Object? value) {
      if (value == null) return;
      final text = value.toString();
      if (text.isNotEmpty) query[key] = text;
    }

    put('courseId', filters['courseId']);
    final chapterIds = filters['chapterIds'];
    if (chapterIds is List && chapterIds.isNotEmpty) {
      put('chapterIds', chapterIds.join(','));
    }
    final groupIds = filters['groupIds'];
    if (groupIds is List && groupIds.isNotEmpty) {
      put('groupIds', groupIds.join(','));
    }
    put('questionType', filters['questionType']);
    put('difficulty', filters['difficulty']);
    put('bloomLevel', filters['bloomLevel']);
    put('status', approvedOnly ? 'approved' : 'draft');
    return Uri(
      path: '/instructor/question-bank',
      queryParameters: query,
    ).toString();
  }
}

class _StickyGenerateBar extends StatelessWidget {
  const _StickyGenerateBar({
    required this.state,
    required this.questionCount,
    required this.onGenerate,
  });

  final ExamGeneratorFormState state;
  final int questionCount;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availability = state.availability;
    final canSubmit = onGenerate != null;
    final summary = availability == null
        ? '$questionCount ${l10n.questions}'
        : l10n.examAvailabilitySummary(
            availability.totalAvailable,
            availability.totalRequired,
          );
    final color = availability == null
        ? Theme.of(context).colorScheme.primary
        : availability.canGenerate
        ? const Color(0xFF059669)
        : Theme.of(context).colorScheme.error;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          border: Border(
            top: BorderSide(color: InstructorColors.borderColor(isDark)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              availability?.canGenerate == false
                  ? Icons.error_outline
                  : Icons.fact_check_outlined,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: canSubmit
                    ? null
                    : InstructorColors.textTertiaryColor(
                        isDark,
                      ).withValues(alpha: 0.16),
                gradient: canSubmit
                    ? const LinearGradient(
                        colors: [
                          InstructorColors.primary,
                          InstructorColors.teal,
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  if (canSubmit)
                    BoxShadow(
                      color: InstructorColors.primary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: onGenerate,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: InstructorColors.textSecondaryColor(
                    isDark,
                  ),
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 13, 18, 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: state.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  l10n.examGenerateDraft,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseDataStrip extends StatelessWidget {
  const _CourseDataStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: InstructorColors.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.3,
              color: InstructorColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.examCourseDataLoading,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Basics extends StatelessWidget {
  const _Basics({required this.state});

  final ExamGeneratorFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.fact_check_outlined,
            color: InstructorColors.primary,
            title: l10n.examCreateCoreDetails,
            subtitle: l10n.examCreateCoreDetailsHint,
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: _inputDecoration(
              context,
              label: l10n.title,
              icon: Icons.title_rounded,
              color: InstructorColors.primary,
            ),
            onChanged: (value) => context
                .read<ExamGeneratorFormCubit>()
                .updateBasics(title: value),
          ),
          const SizedBox(height: 12),
          QuestionFormMenuField<int>(
            label: l10n.course,
            value: state.courseId,
            icon: Icons.school_outlined,
            color: InstructorColors.primary,
            enabled: !state.isLoadingCourseData,
            options: state.courses
                .map(
                  (course) => QuestionFormMenuOption<int>(
                    value: course.courseId,
                    label: '${course.course.code} - ${course.course.name}',
                    icon: Icons.menu_book_outlined,
                  ),
                )
                .toList(),
            onChanged: context.read<ExamGeneratorFormCubit>().selectCourse,
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  required Color color,
  String? helperText,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    helperText: helperText,
    helperMaxLines: 3,
    contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
    prefixIcon: Container(
      width: 38,
      height: 38,
      margin: const EdgeInsetsDirectional.fromSTEB(12, 8, 10, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 20),
    ),
    filled: true,
    fillColor: InstructorColors.surfaceColor(isDark),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: InstructorColors.primary, width: 1.4),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 22),
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
                  fontSize: 18,
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
      ],
    );
  }
}

class _FlatRules extends StatelessWidget {
  const _FlatRules({required this.state});

  final ExamGeneratorFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = state.rules.isEmpty
        ? [
            ExamGenerationRuleModel(
              scope: state.chapters.isEmpty
                  ? ExamGenerationScope.course
                  : ExamGenerationScope.chapter,
              chapterId: state.chapters.isEmpty
                  ? null
                  : state.chapters.first.id,
              count: 10,
              weightPerQuestion: 1,
            ),
          ]
        : state.rules;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RulesHeader(
          title: l10n.examGenerationRules,
          subtitle: state.isLoadingCourseData
              ? l10n.examCourseDataLoading
              : l10n.examCreateRulesHint,
          icon: Icons.rule_folder_outlined,
          color: InstructorColors.primary,
          count: rules.length,
        ),
        const SizedBox(height: 10),
        if (state.isLoadingCourseData) ...[
          _RulesLoadingCard(color: InstructorColors.primary),
          const SizedBox(height: 10),
        ] else ...[
          ...rules.asMap().entries.map(
            (entry) => ExamGenerationRuleCard(
              rule: entry.value,
              chapters: state.chapters,
              groups: state.groups,
              onChanged: (rule) {
                final next = [...rules];
                next[entry.key] = rule;
                context.read<ExamGeneratorFormCubit>().updateRules(next);
              },
              onRemove: rules.length <= 1
                  ? null
                  : () {
                      final next = [...rules]..removeAt(entry.key);
                      context.read<ExamGeneratorFormCubit>().updateRules(next);
                    },
            ),
          ),
        ],
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _ModernAddButton(
            label: l10n.examAddRule,
            icon: Icons.add_rounded,
            onPressed: state.isLoadingCourseData
                ? null
                : () => context.read<ExamGeneratorFormCubit>().updateRules([
                    ...rules,
                    ExamGenerationRuleModel(
                      scope: state.chapters.isEmpty
                          ? ExamGenerationScope.course
                          : ExamGenerationScope.chapter,
                      chapterId: state.chapters.isEmpty
                          ? null
                          : state.chapters.first.id,
                      count: 1,
                      weightPerQuestion: 1,
                    ),
                  ]),
          ),
        ),
      ],
    );
  }
}

class _SectionedRules extends StatelessWidget {
  const _SectionedRules({required this.state});

  final ExamGeneratorFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RulesHeader(
          title: l10n.examSectionedRules,
          subtitle: state.isLoadingCourseData
              ? l10n.examCourseDataLoading
              : l10n.examCreateSectionsHint,
          icon: Icons.view_agenda_outlined,
          color: InstructorColors.accent,
          count: state.sections.length,
        ),
        const SizedBox(height: 10),
        if (state.isLoadingCourseData) ...[
          _RulesLoadingCard(color: InstructorColors.accent),
          const SizedBox(height: 10),
        ] else ...[
          ...state.sections.asMap().entries.map(
            (entry) => ExamGenerationSectionCard(
              section: entry.value,
              chapters: state.chapters,
              groups: state.groups,
              onChanged: (section) {
                final next = [...state.sections];
                next[entry.key] = section;
                context.read<ExamGeneratorFormCubit>().updateSections(next);
              },
              onRemove: () {
                final next = [...state.sections]..removeAt(entry.key);
                context.read<ExamGeneratorFormCubit>().updateSections(next);
              },
            ),
          ),
        ],
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _ModernAddButton(
            label: l10n.examAddSection,
            icon: Icons.add_rounded,
            onPressed: state.isLoadingCourseData
                ? null
                : () => context.read<ExamGeneratorFormCubit>().updateSections([
                    ...state.sections,
                    ExamGenerationSectionModel(
                      title: l10n.sections,
                      totalMarks: 10,
                      rules: [
                        ExamGenerationRuleModel(
                          scope: state.chapters.isEmpty
                              ? ExamGenerationScope.course
                              : ExamGenerationScope.chapter,
                          chapterId: state.chapters.isEmpty
                              ? null
                              : state.chapters.first.id,
                          count: 5,
                          weightPerQuestion: 1,
                        ),
                      ],
                    ),
                  ]),
          ),
        ),
      ],
    );
  }
}

class _RulesLoadingCard extends StatelessWidget {
  const _RulesLoadingCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 2.4, color: color),
                Icon(Icons.menu_book_outlined, color: color, size: 17),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.examCourseDataLoading,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesHeader extends StatelessWidget {
  const _RulesHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.count,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
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
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernAddButton extends StatelessWidget {
  const _ModernAddButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: InstructorColors.primary,
        disabledBackgroundColor: InstructorColors.primary.withValues(
          alpha: 0.35,
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 18, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
