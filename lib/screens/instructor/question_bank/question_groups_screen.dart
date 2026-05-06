import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionGroupsScreen extends StatelessWidget {
  const QuestionGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionBankCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
        enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
      )..initialize(),
      child: const _QuestionGroupsView(),
    );
  }
}

class _QuestionGroupsView extends StatelessWidget {
  const _QuestionGroupsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qbGroups),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.qbCreateGroup,
            onPressed: () =>
                context.push('/instructor/question-bank/groups/create'),
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/instructor/question-bank/groups/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.qbCreateGroup),
      ),
      body: BlocConsumer<QuestionBankCubit, QuestionBankState>(
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
          if (state.isLoading && state.groups.isEmpty) {
            return const SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: QuestionBankSkeletons(itemCount: 5),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<QuestionBankCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                QuestionBankHeroHeader(
                  title: l10n.qbGroups,
                  subtitle: l10n.questionBankHeroSubtitle,
                  stats: {
                    l10n.course: _selectedCourseLabel(state),
                    l10n.qbGroups: state.groups.length.toString(),
                  },
                ),
                const SizedBox(height: 16),
                _GroupsCourseFilter(
                  courses: state.teachingCourses,
                  selectedCourseId: state.selectedCourseId,
                  onChanged: (courseId) =>
                      context.read<QuestionBankCubit>().selectCourse(courseId),
                ),
                const SizedBox(height: 18),
                if (state.errorMessage != null)
                  _GroupsErrorRetry(
                    message: localizedQuestionBankMessage(
                      l10n,
                      state.errorMessage!,
                    ),
                    onRetry: () => context.read<QuestionBankCubit>().refresh(),
                  )
                else if (state.groups.isEmpty)
                  QuestionBankEmptyState(
                    title: l10n.qbGroups,
                    message: l10n.questionBankEmptyMessage,
                    action: FilledButton.icon(
                      onPressed: () => context.push(
                        '/instructor/question-bank/groups/create',
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.qbCreateGroup),
                    ),
                  )
                else
                  ...state.groups.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuestionGroupCard(
                        group: group,
                        onTap: () => context.push(
                          '/instructor/question-bank/groups/${group.id}',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _selectedCourseLabel(QuestionBankState state) {
    for (final course in state.teachingCourses) {
      if (course.courseId == state.selectedCourseId) {
        return course.course.code;
      }
    }
    return state.selectedCourseId?.toString() ?? '-';
  }
}

class _GroupsCourseFilter extends StatelessWidget {
  const _GroupsCourseFilter({
    required this.courses,
    required this.selectedCourseId,
    required this.onChanged,
  });

  final List<TeachingCourseModel> courses;
  final int? selectedCourseId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uniqueCourses = _uniqueCourses(courses);
    final dropdownValue =
        uniqueCourses.any((course) => course.courseId == selectedCourseId)
        ? selectedCourseId
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        initialValue: dropdownValue,
        decoration: InputDecoration(
          labelText: l10n.course,
          prefixIcon: const Icon(Icons.menu_book_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        items: uniqueCourses
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
        onChanged: onChanged,
      ),
    );
  }

  List<TeachingCourseModel> _uniqueCourses(List<TeachingCourseModel> source) {
    final seen = <int>{};
    return [
      for (final course in source)
        if (seen.add(course.courseId)) course,
    ];
  }
}

class _GroupsErrorRetry extends StatelessWidget {
  const _GroupsErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
