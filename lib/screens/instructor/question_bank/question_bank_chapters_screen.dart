import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionBankChaptersScreen extends StatelessWidget {
  const QuestionBankChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionBankCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
        enrollmentService: EnrollmentService(coreApiClient: CoreApiClient()),
      )..initialize(),
      child: const _QuestionBankChaptersView(),
    );
  }
}

class _QuestionBankChaptersView extends StatefulWidget {
  const _QuestionBankChaptersView();

  @override
  State<_QuestionBankChaptersView> createState() =>
      _QuestionBankChaptersViewState();
}

class _QuestionBankChaptersViewState extends State<_QuestionBankChaptersView> {
  CourseChapterModel? _editing;
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.qbManageChapters)),
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
          if (state.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: QuestionBankSkeletons(itemCount: 4),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              QuestionBankHeroHeader(
                title: l10n.qbManageChapters,
                subtitle: l10n.qbChapterCascadeWarning,
                stats: {
                  l10n.course: _selectedCourseLabel(state),
                  l10n.chapter: state.chapters.length.toString(),
                },
              ),
              const SizedBox(height: 16),
              _ChapterCourseSelector(
                courses: state.teachingCourses,
                selectedCourseId: state.selectedCourseId,
                onChanged: (courseId) async {
                  setState(() {
                    _creating = false;
                    _editing = null;
                  });
                  await context.read<QuestionBankCubit>().selectCourse(
                    courseId,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_creating || _editing != null)
                QuestionChapterFormCard(
                  initial: _editing,
                  suggestedOrder: _nextChapterOrder(state),
                  isSubmitting: state.isMutating,
                  onCancel: () => setState(() {
                    _creating = false;
                    _editing = null;
                  }),
                  onSubmit: (name, order, isActive) async {
                    if (_editing == null) {
                      await context.read<QuestionBankCubit>().createChapter(
                        name: name,
                        chapterOrder: order,
                      );
                    } else {
                      await context.read<QuestionBankCubit>().updateChapter(
                        chapterId: _editing!.id,
                        name: name,
                        chapterOrder: order,
                        isActive: isActive,
                      );
                    }
                    setState(() {
                      _creating = false;
                      _editing = null;
                    });
                  },
                ),
              if (_creating || _editing != null) const SizedBox(height: 16),
              QuestionChapterManagerCard(
                chapters: state.chapters,
                questionCounts: state.chapterQuestionCounts,
                onCreate: () => setState(() {
                  _creating = true;
                  _editing = null;
                }),
                onEdit: (chapter) => setState(() {
                  _editing = chapter;
                  _creating = false;
                }),
                onDelete: (chapter) async {
                  final ok = await showQuestionChapterDeleteDialog(context);
                  if (ok && context.mounted) {
                    await context.read<QuestionBankCubit>().deleteChapter(
                      chapter.id,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _selectedCourseLabel(QuestionBankState state) {
    for (final course in state.teachingCourses) {
      if (course.courseId == state.selectedCourseId) {
        return course.course.code;
      }
    }
    return state.selectedCourseId?.toString() ?? '-';
  }

  int _nextChapterOrder(QuestionBankState state) {
    if (state.chapters.isEmpty) return 1;
    return state.chapters
            .map((chapter) => chapter.chapterOrder)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }
}

class _ChapterCourseSelector extends StatelessWidget {
  const _ChapterCourseSelector({
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
