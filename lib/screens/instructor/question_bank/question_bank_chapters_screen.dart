import 'dart:async';

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
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

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
  final TextEditingController _search = TextEditingController();
  CourseChapterModel? _editing;
  bool _creating = false;
  bool _hasCompletedInitialLoad = false;
  bool _isApplyingLocalFilter = false;
  bool _savingChapter = false;
  int? _deletingChapterId;
  Timer? _filterFeedbackTimer;
  _ChapterStatusFilter _statusFilter = _ChapterStatusFilter.all;

  @override
  void dispose() {
    _filterFeedbackTimer?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          safeFeatureBack(context, '/instructor/question-bank');
        }
      },
      child: Scaffold(
        backgroundColor: InstructorColors.background(isDark),
        appBar: AppBar(
          backgroundColor: InstructorColors.background(isDark),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icon(
              safeFeatureBackIcon(context),
              color: InstructorColors.textPrimaryColor(isDark),
            ),
            onPressed: () =>
                safeFeatureBack(context, '/instructor/question-bank'),
          ),
          title: Text(
            l10n.qbManageChapters,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsetsDirectional.only(end: 10),
          //     child: IconButton(
          //       tooltip: l10n.qbCreateChapter,
          //       onPressed: () => _showCreateForm(),
          //       style: IconButton.styleFrom(
          //         backgroundColor: InstructorColors.teal.withValues(
          //           alpha: isDark ? 0.18 : 0.1,
          //         ),
          //         foregroundColor: InstructorColors.teal,
          //       ),
          //       icon: const Icon(Icons.create_new_folder_outlined),
          //     ),
          //   ),
          // ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateForm,
          backgroundColor: InstructorColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            l10n.qbCreateChapter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: BlocConsumer<QuestionBankCubit, QuestionBankState>(
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
            final showInitialSkeleton =
                state.isLoading &&
                state.chapters.isEmpty &&
                !_hasCompletedInitialLoad;
            if (!state.isLoading) _hasCompletedInitialLoad = true;
            if (showInitialSkeleton) {
              return const SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: QuestionBankSkeletons(itemCount: 4),
              );
            }

            final visibleChapters = _visibleChapters(state);
            final activeCount = visibleChapters
                .where((chapter) => chapter.isActive)
                .length;
            final questionTotal = visibleChapters.fold<int>(
              0,
              (sum, chapter) =>
                  sum + (state.chapterQuestionCounts[chapter.id] ?? 0),
            );

            final content = RefreshIndicator(
              onRefresh: () => context.read<QuestionBankCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                children: [
                  QuestionBankHeroHeader(
                    title: l10n.qbManageChapters,
                    subtitle: l10n.qbChapterCascadeWarning,
                    stats: {
                      l10n.course: _selectedCourseShortLabel(state),
                      l10n.qbChapters: visibleChapters.length.toString(),
                      l10n.qbChapterActive: activeCount.toString(),
                      l10n.questions: questionTotal.toString(),
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _ChapterFilterPanel(
                    state: state,
                    search: _search,
                    statusFilter: _statusFilter,
                    isLoading:
                        _isApplyingLocalFilter ||
                        (state.isLoading && _hasCompletedInitialLoad),
                    onSearchChanged: (_) => _applyLocalFilterFeedback(),
                    onCourseChanged: (courseId) async {
                      setState(() {
                        _creating = false;
                        _editing = null;
                      });
                      await context.read<QuestionBankCubit>().selectCourse(
                        courseId,
                      );
                    },
                    onStatusChanged: (filter) {
                      setState(() => _statusFilter = filter);
                      _applyLocalFilterFeedback();
                    },
                    onClear: () {
                      _search.clear();
                      setState(() => _statusFilter = _ChapterStatusFilter.all);
                      _applyLocalFilterFeedback();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_creating || _editing != null) ...[
                    QuestionChapterFormCard(
                      key: ValueKey(_editing?.id ?? 'create'),
                      initial: _editing,
                      suggestedOrder: _nextChapterOrder(state),
                      occupiedOrders: _occupiedOrders(state),
                      isSubmitting: _savingChapter || state.isMutating,
                      onCancel: () => setState(() {
                        _creating = false;
                        _editing = null;
                      }),
                      onSubmit: (name, order, isActive) =>
                          _saveChapter(context, name, order, isActive),
                    ),
                    const SizedBox(height: 16),
                  ],
                  QuestionChapterManagerCard(
                    chapters: visibleChapters,
                    totalChapters: visibleChapters.length,
                    questionCounts: state.chapterQuestionCounts,
                    onCreate: _showCreateForm,
                    onEdit: (chapter) => setState(() {
                      _editing = chapter;
                      _creating = false;
                    }),
                    onDelete: (chapter) async {
                      final ok = await showQuestionChapterDeleteDialog(context);
                      if (ok && context.mounted) {
                        await _deleteChapter(context, chapter.id);
                      }
                    },
                  ),
                ],
              ),
            );
            return Stack(
              children: [
                content,
                if (_savingChapter || _deletingChapterId != null)
                  Positioned.fill(
                    child: QuestionBankMutationOverlay(
                      title: _savingChapter
                          ? 'Saving chapter'
                          : 'Deleting chapter',
                      message: _savingChapter
                          ? 'Please wait until the chapter is saved.'
                          : 'Please wait until the chapter is deleted.',
                      isDark: isDark,
                      color: _deletingChapterId == null
                          ? InstructorColors.primary
                          : InstructorColors.error,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCreateForm() {
    setState(() {
      _creating = true;
      _editing = null;
    });
  }

  void _applyLocalFilterFeedback() {
    _filterFeedbackTimer?.cancel();
    if (!_isApplyingLocalFilter) {
      setState(() => _isApplyingLocalFilter = true);
    }
    _filterFeedbackTimer = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _isApplyingLocalFilter = false);
    });
  }

  Future<void> _saveChapter(
    BuildContext context,
    String name,
    int order,
    bool isActive,
  ) async {
    if (_savingChapter) return;
    final editing = _editing;
    final cubit = context.read<QuestionBankCubit>();
    setState(() => _savingChapter = true);
    try {
      final saved = editing == null
          ? await cubit.createChapter(name: name, chapterOrder: order)
          : await cubit.updateChapter(
              chapterId: editing.id,
              name: name,
              chapterOrder: order,
              isActive: isActive,
            );
      if (!saved || !mounted) return;
      setState(() {
        _creating = false;
        _editing = null;
      });
    } finally {
      if (mounted) setState(() => _savingChapter = false);
    }
  }

  Future<void> _deleteChapter(BuildContext context, int chapterId) async {
    if (_deletingChapterId != null) return;
    setState(() => _deletingChapterId = chapterId);
    try {
      await context.read<QuestionBankCubit>().deleteChapter(chapterId);
    } finally {
      if (mounted) setState(() => _deletingChapterId = null);
    }
  }

  List<CourseChapterModel> _visibleChapters(QuestionBankState state) {
    final query = _search.text.trim().toLowerCase();
    return state.chapters.where((chapter) {
      if (_statusFilter == _ChapterStatusFilter.active && !chapter.isActive) {
        return false;
      }
      if (_statusFilter == _ChapterStatusFilter.inactive && chapter.isActive) {
        return false;
      }
      if (query.isEmpty) return true;
      return [
        chapter.name,
        chapter.chapterOrder.toString(),
      ].join(' ').toLowerCase().contains(query);
    }).toList();
  }

  String _selectedCourseShortLabel(QuestionBankState state) {
    for (final course in state.teachingCourses) {
      if (course.courseId == state.selectedCourseId) {
        final code = course.course.code.trim();
        return code.isNotEmpty ? code : course.course.name;
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

  List<int> _occupiedOrders(QuestionBankState state) {
    final orders =
        state.chapters.map((chapter) => chapter.chapterOrder).toList()..sort();
    return orders;
  }
}

enum _ChapterStatusFilter { all, active, inactive }

class _ChapterFilterPanel extends StatelessWidget {
  const _ChapterFilterPanel({
    required this.state,
    required this.search,
    required this.statusFilter,
    required this.isLoading,
    required this.onSearchChanged,
    required this.onCourseChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  final QuestionBankState state;
  final TextEditingController search;
  final _ChapterStatusFilter statusFilter;
  final bool isLoading;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int?> onCourseChanged;
  final ValueChanged<_ChapterStatusFilter> onStatusChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uniqueCourses = _uniqueCourses(state.teachingCourses);
    final selectedCourseId =
        uniqueCourses.any((course) => course.courseId == state.selectedCourseId)
        ? state.selectedCourseId
        : null;
    final hasFilters =
        search.text.trim().isNotEmpty ||
        statusFilter != _ChapterStatusFilter.all;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: search,
            onChanged: onSearchChanged,
            cursorColor: InstructorColors.primary,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: l10n.qbSearchChaptersHint,
              hintStyle: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: InstructorColors.surfaceColor(isDark),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: InstructorColors.borderColor(isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: InstructorColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: QuestionFormMenuField<int>(
                  label: l10n.course,
                  value: selectedCourseId,
                  icon: Icons.menu_book_outlined,
                  color: InstructorColors.primary,
                  options: uniqueCourses
                      .map(
                        (course) => QuestionFormMenuOption<int>(
                          value: course.courseId,
                          label: _courseLabel(course),
                          icon: Icons.menu_book_outlined,
                        ),
                      )
                      .toList(),
                  onChanged: onCourseChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuestionFormMenuField<_ChapterStatusFilter>(
                  label: l10n.qbChapterStatus,
                  value: statusFilter,
                  icon: Icons.verified_outlined,
                  color: InstructorColors.teal,
                  options: [
                    QuestionFormMenuOption<_ChapterStatusFilter>(
                      value: _ChapterStatusFilter.all,
                      label: l10n.qbAllChapterStatuses,
                      icon: Icons.filter_alt_off_rounded,
                    ),
                    QuestionFormMenuOption<_ChapterStatusFilter>(
                      value: _ChapterStatusFilter.active,
                      label: l10n.qbChapterActive,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    QuestionFormMenuOption<_ChapterStatusFilter>(
                      value: _ChapterStatusFilter.inactive,
                      label: l10n.qbChapterInactive,
                      icon: Icons.pause_circle_outline_rounded,
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) onStatusChanged(value);
                  },
                ),
              ),
            ],
          ),
          if (isLoading) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(minHeight: 3),
            ),
          ],
          if (hasFilters) ...[
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.clearFilters),
              ),
            ),
          ],
        ],
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

  String _courseLabel(TeachingCourseModel course) {
    final code = course.course.code.trim();
    final name = course.course.name.trim();
    if (code.isNotEmpty && name.isNotEmpty) return '$code - $name';
    if (code.isNotEmpty) return code;
    return name.isNotEmpty ? name : course.courseId.toString();
  }
}
