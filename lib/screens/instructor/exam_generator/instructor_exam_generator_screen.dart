import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/exam_generator/exam_generator_cubit.dart';
import '../../../bloc/instructor/exam_generator/exam_generator_state.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../widgets/instructor/exam_generator/exam_generator_barrel.dart';
import '../../../widgets/instructor/shared/instructor_modern_tab_strip.dart';

class InstructorExamGeneratorScreen extends StatelessWidget {
  const InstructorExamGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamGeneratorCubit(
        examGeneratorService: ExamGeneratorService(
          coreApiClient: CoreApiClient(),
        ),
        enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
      )..initialize(),
      child: const _InstructorExamGeneratorView(),
    );
  }
}

class _InstructorExamGeneratorView extends StatelessWidget {
  const _InstructorExamGeneratorView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examGenerator)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/instructor/exam-generator/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.examGeneratorCreateDraft),
      ),
      body: BlocBuilder<ExamGeneratorCubit, ExamGeneratorState>(
        builder: (context, state) {
          if (state.isLoading && state.drafts.isEmpty && state.exams.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: ExamGeneratorSkeletons(itemCount: 5),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ExamGeneratorCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                ExamGeneratorHeroHeader(
                  title: l10n.examGeneratorHeroTitle,
                  subtitle: l10n.examGeneratorHeroSubtitle,
                  stats: {
                    l10n.drafts:
                        (state.stats?.openDrafts ?? state.drafts.length)
                            .toString(),
                    l10n.savedExams:
                        (state.stats?.savedExams ?? state.exams.length)
                            .toString(),
                    l10n.examPublished: (state.stats?.publishedExams ?? 0)
                        .toString(),
                    l10n.examApprovedPool:
                        (state.stats?.approvedQuestionPool ?? 0).toString(),
                  },
                ),
                const SizedBox(height: 16),
                _ExplanationCard(state: state),
                const SizedBox(height: 16),
                _ReadinessCard(state: state),
                const SizedBox(height: 16),
                ExamGeneratorFilterCard(
                  children: [
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<int?>(
                        isExpanded: true,
                        initialValue: state.selectedCourseId,
                        decoration: InputDecoration(
                          labelText: l10n.course,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              l10n.allCourses,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...state.teachingCourses.map(
                            (course) => DropdownMenuItem<int?>(
                              value: course.courseId,
                              child: Text(
                                '${course.course.code} - ${course.course.name}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            context.read<ExamGeneratorCubit>().setFilters(
                              courseId: value,
                              clearCourse: value == null,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<ExamDraftStatus?>(
                        isExpanded: true,
                        initialValue: state.selectedDraftStatus,
                        decoration: InputDecoration(
                          labelText: l10n.examDraftStatus,
                        ),
                        items: [
                          DropdownMenuItem<ExamDraftStatus?>(
                            value: null,
                            child: Text(l10n.allStates),
                          ),
                          ...ExamDraftStatus.values.map(
                            (status) => DropdownMenuItem<ExamDraftStatus?>(
                              value: status,
                              child: Text(localizedDraftStatus(l10n, status)),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            context.read<ExamGeneratorCubit>().setFilters(
                              draftStatus: value,
                              clearDraftStatus: value == null,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<ExamStatus?>(
                        isExpanded: true,
                        initialValue: state.selectedExamStatus,
                        decoration: InputDecoration(labelText: l10n.examStatus),
                        items: [
                          DropdownMenuItem<ExamStatus?>(
                            value: null,
                            child: Text(l10n.allStates),
                          ),
                          ...ExamStatus.values.map(
                            (status) => DropdownMenuItem<ExamStatus?>(
                              value: status,
                              child: Text(localizedExamStatus(l10n, status)),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            context.read<ExamGeneratorCubit>().setFilters(
                              examStatus: value,
                              clearExamStatus: value == null,
                            ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _pickDate(context, from: true, state: state),
                      icon: const Icon(Icons.date_range_outlined),
                      label: Text(
                        state.dateFrom == null
                            ? l10n.examDateFrom
                            : state.dateFrom!
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _pickDate(context, from: false, state: state),
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        state.dateTo == null
                            ? l10n.examDateTo
                            : state.dateTo!
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context
                          .read<ExamGeneratorCubit>()
                          .setFilters(clearDates: true),
                      icon: const Icon(Icons.clear_rounded),
                      label: Text(l10n.clear),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InstructorModernTabStrip(
                  selectedIndex: state.selectedTabIndex,
                  onChanged: context.read<ExamGeneratorCubit>().selectTab,
                  tabs: [
                    InstructorModernTabItem(
                      icon: Icons.description_outlined,
                      label: l10n.drafts,
                    ),
                    InstructorModernTabItem(
                      icon: Icons.fact_check_outlined,
                      label: l10n.savedExams,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.errorMessage != null)
                  Center(child: Text(state.errorMessage!))
                else if (state.selectedTabIndex == 0)
                  _DraftList(state: state)
                else
                  _ExamList(state: state),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool from,
    required ExamGeneratorState state,
  }) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: (from ? state.dateFrom : state.dateTo) ?? DateTime.now(),
    );
    if (picked == null || !context.mounted) return;
    await context.read<ExamGeneratorCubit>().setFilters(
      dateFrom: from ? picked : state.dateFrom,
      dateTo: from ? state.dateTo : picked,
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.state});

  final ExamGeneratorState state;

  @override
  Widget build(BuildContext context) {
    final readiness = state.readiness;
    if (readiness == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.examQuestionPoolReadiness,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip(l10n.examApproved, readiness.totalApproved),
              _statChip(l10n.examGrouped, readiness.grouped),
              _statChip(l10n.examStandalone, readiness.standalone),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...readiness.byChapter
                  .take(5)
                  .map((item) => _statChip(item.label, item.count)),
              ...readiness.byType
                  .take(4)
                  .map((item) => _statChip(item.label, item.count)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count) {
    return Chip(label: Text('$label: $count', overflow: TextOverflow.ellipsis));
  }
}

class _DraftList extends StatelessWidget {
  const _DraftList({required this.state});

  final ExamGeneratorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.drafts.isEmpty) {
      return ExamGeneratorEmptyState(
        title: l10n.examGeneratorNoDrafts,
        message: l10n.examGeneratorNoDraftsMessage,
      );
    }
    return Column(
      children: state.drafts
          .map(
            (draft) => ExamDraftCard(
              draft: draft,
              onTap: () =>
                  context.push('/instructor/exam-generator/drafts/${draft.id}'),
            ),
          )
          .toList(),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.state});

  final ExamGeneratorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lowPool = (state.stats?.approvedQuestionPool ?? 1) == 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lowPool
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            lowPool ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lowPool ? l10n.examNoApprovedPoolHelp : l10n.examDashboardHelp,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (lowPool)
            TextButton(
              onPressed: () => context.push('/instructor/question-bank'),
              child: Text(l10n.questionBank),
            ),
        ],
      ),
    );
  }
}

class _ExamList extends StatelessWidget {
  const _ExamList({required this.state});

  final ExamGeneratorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.exams.isEmpty) {
      return ExamGeneratorEmptyState(
        title: l10n.examGeneratorNoSavedExams,
        message: l10n.examGeneratorNoSavedExamsMessage,
      );
    }
    return Column(
      children: state.exams
          .map(
            (exam) => ExamSavedCard(
              exam: exam,
              onTap: () =>
                  context.push('/instructor/exam-generator/exams/${exam.id}'),
            ),
          )
          .toList(),
    );
  }
}
