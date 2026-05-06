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
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examGeneratorCreateDraft)),
      bottomNavigationBar:
          BlocBuilder<ExamGeneratorFormCubit, ExamGeneratorFormState>(
            builder: (context, state) => _StickyGenerateBar(
              state: state,
              questionCount: _questionCount(state),
              onGenerate: state.isSubmitting
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              ExamGeneratorHeroHeader(
                title: l10n.examGeneratorStudioTitle,
                subtitle: l10n.examGeneratorStudioSubtitle,
                stats: {
                  l10n.course: _courseLabel(state),
                  l10n.examQuestionCount: _questionCount(state).toString(),
                  l10n.totalMarks: state.totalMarks?.toString() ?? '-',
                },
              ),
              const SizedBox(height: 16),
              ExamShortagePanel(shortages: state.shortages),
              ExamGenerationValidationPanel(message: state.errorMessage),
              ExamAvailabilityPanel(
                availability: state.availability,
                isLoading: state.isCheckingAvailability,
                onViewMatchingQuestions: (bucket) =>
                    context.push(_questionBankUrl(bucket, approvedOnly: true)),
                onApproveMoreQuestions: (bucket) =>
                    context.push(_questionBankUrl(bucket, approvedOnly: false)),
              ),
              const SizedBox(height: 16),
              _Basics(state: state),
              const SizedBox(height: 16),
              ExamGenerationModeToggle(
                value: state.mode,
                onChanged: (mode) => context
                    .read<ExamGeneratorFormCubit>()
                    .updateBasics(mode: mode),
              ),
              const SizedBox(height: 16),
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
                onTotalMarksChanged: (value) =>
                    context.read<ExamGeneratorFormCubit>().updateBasics(
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
                onRandomSeed: () =>
                    context.read<ExamGeneratorFormCubit>().randomizeSeed(),
                onClearSeed: () =>
                    context.read<ExamGeneratorFormCubit>().clearSeed(),
                onDurationChanged: (value) =>
                    context.read<ExamGeneratorFormCubit>().updateBasics(
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
              const SizedBox(height: 16),
              if (state.mode == ExamGenerationMode.flat)
                _FlatRules(state: state)
              else
                _SectionedRules(state: state),
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
    final availability = state.availability;
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
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
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
            FilledButton.icon(
              onPressed: onGenerate,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(l10n.examGenerateDraft),
            ),
          ],
        ),
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
    return ExamRuleEditor(
      children: [
        TextField(
          decoration: InputDecoration(labelText: l10n.title),
          onChanged: (value) =>
              context.read<ExamGeneratorFormCubit>().updateBasics(title: value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: state.courseId,
          decoration: InputDecoration(labelText: l10n.course),
          items: state.courses
              .map(
                (course) => DropdownMenuItem(
                  value: course.courseId,
                  child: Text(
                    '${course.course.code} - ${course.course.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: context.read<ExamGeneratorFormCubit>().selectCourse,
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
      children: [
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
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: () =>
                context.read<ExamGeneratorFormCubit>().updateRules([
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
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.examGenerationRules),
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
      children: [
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
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: () =>
                context.read<ExamGeneratorFormCubit>().updateSections([
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
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.examCreateSection),
          ),
        ),
      ],
    );
  }
}
