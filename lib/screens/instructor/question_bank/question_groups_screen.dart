import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';
import 'question_bank_create_screen.dart';

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

class _QuestionGroupsView extends StatefulWidget {
  const _QuestionGroupsView();

  @override
  State<_QuestionGroupsView> createState() => _QuestionGroupsViewState();
}

class _QuestionGroupsViewState extends State<_QuestionGroupsView> {
  final TextEditingController _search = TextEditingController();
  int? _chapterId;
  QuestionGroupType? _groupType;
  bool _hasCompletedInitialLoad = false;
  int? _deletingGroupId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      appBar: AppBar(
        backgroundColor: InstructorColors.background(isDark),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: InstructorColors.textPrimaryColor(isDark),
          ),
          onPressed: () =>
              safeFeatureBack(context, '/instructor/question-bank'),
        ),
        title: Text(
          l10n.qbGroups,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsetsDirectional.only(end: 10),
        //     child: IconButton(
        //       tooltip: l10n.qbCreateGroup,
        //       onPressed: () =>
        //           context.push('/instructor/question-bank/groups/create'),
        //       style: IconButton.styleFrom(
        //         backgroundColor: InstructorColors.primary.withValues(
        //           alpha: isDark ? 0.18 : 0.1,
        //         ),
        //         foregroundColor: InstructorColors.primary,
        //       ),
        //       icon: const Icon(Icons.create_new_folder_outlined),
        //     ),
        //   ),
        // ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/instructor/question-bank/groups/create'),
        backgroundColor: InstructorColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.qbCreateGroup,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
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
          final showInitialSkeleton =
              state.isLoading &&
              state.groups.isEmpty &&
              !_hasCompletedInitialLoad;
          if (!state.isLoading) _hasCompletedInitialLoad = true;
          if (showInitialSkeleton) {
            return const SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: QuestionBankSkeletons(itemCount: 4),
            );
          }

          final visibleGroups = _visibleGroups(state);
          final totalQuestions = visibleGroups.fold<int>(
            0,
            (sum, group) => sum + group.totalQuestions,
          );
          final approvedQuestions = visibleGroups.fold<int>(
            0,
            (sum, group) => sum + group.approvedQuestions,
          );

          final content = RefreshIndicator(
            onRefresh: () => context.read<QuestionBankCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
              children: [
                QuestionBankHeroHeader(
                  title: l10n.qbGroups,
                  subtitle: l10n.questionBankHeroSubtitle,
                  stats: {
                    l10n.course: _selectedCourseShortLabel(state),
                    l10n.qbGroups: visibleGroups.length.toString(),
                    l10n.questions: totalQuestions.toString(),
                    l10n.approved: approvedQuestions.toString(),
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _GroupFilterPanel(
                  state: state,
                  search: _search,
                  chapterId: _chapterId,
                  groupType: _groupType,
                  isLoading: state.isLoading && _hasCompletedInitialLoad,
                  onSearchChanged: (_) => setState(() {}),
                  onCourseChanged: (courseId) {
                    setState(() => _chapterId = null);
                    context.read<QuestionBankCubit>().selectCourse(courseId);
                  },
                  onChapterChanged: (chapterId) =>
                      setState(() => _chapterId = chapterId),
                  onGroupTypeChanged: (type) =>
                      setState(() => _groupType = type),
                  onClear: () {
                    _search.clear();
                    setState(() {
                      _chapterId = null;
                      _groupType = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (state.errorMessage != null)
                  _GroupsErrorRetry(
                    message: localizedQuestionBankMessage(
                      l10n,
                      state.errorMessage!,
                    ),
                    onRetry: () => context.read<QuestionBankCubit>().refresh(),
                  )
                else if (visibleGroups.isEmpty)
                  QuestionBankEmptyState(
                    title: l10n.qbGroups,
                    message: l10n.searchTryDifferent,
                    action: FilledButton.icon(
                      onPressed: () => context.push(
                        '/instructor/question-bank/groups/create',
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.qbCreateGroup),
                    ),
                  )
                else
                  ...visibleGroups.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ModernGroupCard(
                        group: group,
                        courseLabel: _courseLabelForGroup(state, group),
                        isBusy: _deletingGroupId == group.id,
                        onTap: () => context.push(
                          '/instructor/question-bank/groups/${group.id}',
                        ),
                        onEdit: () => context.push(
                          '/instructor/question-bank/groups/${group.id}/edit',
                        ),
                        onDelete: () => _deleteGroup(context, group.id),
                        onAddGrouped: () => context.push(
                          '/instructor/question-bank/groups/${group.id}/add-questions',
                        ),
                        onAddExisting: () => context.push(
                          '/instructor/question-bank/groups/${group.id}/link-questions',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
          return Stack(
            children: [
              content,
              if (_deletingGroupId != null)
                Positioned.fill(
                  child: QuestionBankMutationOverlay(
                    title: 'Deleting group',
                    message: 'Please wait until the group is deleted.',
                    isDark: isDark,
                    color: InstructorColors.error,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteGroup(BuildContext context, int groupId) async {
    final l10n = AppLocalizations.of(context);
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => QuestionFormDecisionDialog(
            title: l10n.qbDeleteGroup,
            message: l10n.qbGroupDeleteBody,
            icon: Icons.delete_outline_rounded,
            color: InstructorColors.error,
            primaryLabel: l10n.qbDeleteGroup,
            secondaryLabel: l10n.cancel,
            onPrimary: () => Navigator.of(context).pop(true),
            onSecondary: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    setState(() => _deletingGroupId = groupId);
    try {
      await context.read<QuestionBankCubit>().deleteGroup(groupId);
    } finally {
      if (mounted) setState(() => _deletingGroupId = null);
    }
  }

  List<QuestionBankGroupModel> _visibleGroups(QuestionBankState state) {
    final query = _search.text.trim().toLowerCase();
    return state.groups.where((group) {
      if (_chapterId != null && group.chapterId != _chapterId) return false;
      if (_groupType != null && group.groupType != _groupType) return false;
      if (query.isEmpty) return true;
      final haystack = [
        group.title,
        group.sharedPrompt,
        group.courseCode,
        group.courseName,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  String _selectedCourseShortLabel(QuestionBankState state) {
    if (state.selectedCourseId == null) {
      return AppLocalizations.of(context).allCourses;
    }
    for (final course in state.teachingCourses) {
      if (course.courseId == state.selectedCourseId) {
        final code = course.course.code.trim();
        return code.isNotEmpty ? code : course.course.name;
      }
    }
    return state.selectedCourseId?.toString() ?? '-';
  }

  String _courseLabelForGroup(
    QuestionBankState state,
    QuestionBankGroupModel group,
  ) {
    for (final course in state.teachingCourses) {
      if (course.courseId == group.courseId) {
        final code = course.course.code.trim();
        final name = course.course.name.trim();
        if (code.isNotEmpty && name.isNotEmpty) return '$code • $name';
        if (code.isNotEmpty) return code;
        if (name.isNotEmpty) return name;
      }
    }
    final code = group.courseCode?.trim();
    final name = group.courseName?.trim();
    if (code != null && code.isNotEmpty && name != null && name.isNotEmpty) {
      return '$code • $name';
    }
    if (code != null && code.isNotEmpty) return code;
    if (name != null && name.isNotEmpty) return name;
    return group.courseId.toString();
  }
}

class _GroupFilterPanel extends StatelessWidget {
  const _GroupFilterPanel({
    required this.state,
    required this.search,
    required this.chapterId,
    required this.groupType,
    required this.isLoading,
    required this.onSearchChanged,
    required this.onCourseChanged,
    required this.onChapterChanged,
    required this.onGroupTypeChanged,
    required this.onClear,
  });

  final QuestionBankState state;
  final TextEditingController search;
  final int? chapterId;
  final QuestionGroupType? groupType;
  final bool isLoading;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int?> onCourseChanged;
  final ValueChanged<int?> onChapterChanged;
  final ValueChanged<QuestionGroupType?> onGroupTypeChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFilters =
        search.text.trim().isNotEmpty || chapterId != null || groupType != null;
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
              hintText: l10n.qbSearchGroupsHint,
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
                child: _GroupFilterButton(
                  title: '${l10n.course} / ${l10n.chapter}',
                  subtitle: _scopeSubtitle(l10n),
                  icon: Icons.account_tree_outlined,
                  color: InstructorColors.primary,
                  isActive: chapterId != null,
                  entries: _scopeEntries(l10n, isDark),
                  onSelected: _handleAction,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GroupFilterButton(
                  title: l10n.qbGroupType,
                  subtitle: groupType == null
                      ? l10n.qbAllGroupTypes
                      : localizedGroupType(l10n, groupType!),
                  icon: Icons.category_outlined,
                  color: InstructorColors.teal,
                  isActive: groupType != null,
                  entries: _typeEntries(l10n, isDark),
                  onSelected: _handleAction,
                ),
              ),
            ],
          ),
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
          if (isLoading) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(minHeight: 3),
            ),
          ],
        ],
      ),
    );
  }

  String _scopeSubtitle(AppLocalizations l10n) {
    final courseLabel = _selectedCourseLabel(l10n);
    final chapter = chapterId == null
        ? null
        : state.chapters
              .where((chapter) => chapter.id == chapterId)
              .firstOrNull
              ?.name;
    return chapter == null ? courseLabel : '$courseLabel • $chapter';
  }

  String _selectedCourseLabel(AppLocalizations l10n) {
    if (state.selectedCourseId == null) return l10n.allCourses;
    final course = state.teachingCourses
        .where((course) => course.courseId == state.selectedCourseId)
        .firstOrNull;
    if (course == null) return state.selectedCourseId.toString();
    final code = course.course.code.trim();
    final name = course.course.name.trim();
    if (code.isNotEmpty && name.isNotEmpty) return '$code - $name';
    if (code.isNotEmpty) return code;
    return name.isNotEmpty ? name : state.selectedCourseId.toString();
  }

  List<PopupMenuEntry<_GroupFilterAction>> _scopeEntries(
    AppLocalizations l10n,
    bool isDark,
  ) {
    return [
      _menuHeader(l10n.course, isDark),
      _menuOption(
        label: l10n.allCourses,
        icon: Icons.layers_clear_rounded,
        selected: state.selectedCourseId == null,
        action: const _GroupFilterAction(_GroupFilterKind.course, null),
        color: InstructorColors.primary,
        isDark: isDark,
      ),
      ..._uniqueCourses(state.teachingCourses).map(
        (course) => _menuOption(
          label: '${course.course.code} - ${course.course.name}',
          icon: Icons.menu_book_outlined,
          selected: state.selectedCourseId == course.courseId,
          action: _GroupFilterAction(_GroupFilterKind.course, course.courseId),
          color: InstructorColors.primary,
          isDark: isDark,
        ),
      ),
      const PopupMenuDivider(height: 8),
      _menuHeader(l10n.chapter, isDark),
      _menuOption(
        label: l10n.allChapters,
        icon: Icons.layers_clear_rounded,
        selected: chapterId == null,
        action: const _GroupFilterAction(_GroupFilterKind.chapter, null),
        color: InstructorColors.primary,
        isDark: isDark,
      ),
      ...state.chapters.map(
        (chapter) => _menuOption(
          label: chapter.name,
          icon: Icons.menu_book_outlined,
          selected: chapterId == chapter.id,
          action: _GroupFilterAction(_GroupFilterKind.chapter, chapter.id),
          color: InstructorColors.primary,
          isDark: isDark,
        ),
      ),
    ];
  }

  List<PopupMenuEntry<_GroupFilterAction>> _typeEntries(
    AppLocalizations l10n,
    bool isDark,
  ) {
    return [
      _menuOption(
        label: l10n.qbAllGroupTypes,
        icon: Icons.filter_alt_off_rounded,
        selected: groupType == null,
        action: const _GroupFilterAction(_GroupFilterKind.type, null),
        color: InstructorColors.teal,
        isDark: isDark,
      ),
      const PopupMenuDivider(height: 8),
      ...QuestionGroupType.values.map(
        (type) => _menuOption(
          label: localizedGroupType(l10n, type),
          icon: _groupTypeIcon(type),
          selected: groupType == type,
          action: _GroupFilterAction(_GroupFilterKind.type, type),
          color: InstructorColors.teal,
          isDark: isDark,
        ),
      ),
    ];
  }

  PopupMenuItem<_GroupFilterAction> _menuOption({
    required String label,
    required IconData icon,
    required bool selected,
    required _GroupFilterAction action,
    required Color color,
    required bool isDark,
  }) {
    return PopupMenuItem<_GroupFilterAction>(
      value: action,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : icon,
            size: 18,
            color: selected
                ? color
                : InstructorColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? color
                    : InstructorColors.textPrimaryColor(isDark),
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_GroupFilterAction> _menuHeader(String label, bool isDark) {
    return PopupMenuItem<_GroupFilterAction>(
      enabled: false,
      height: 30,
      child: Text(
        label,
        style: TextStyle(
          color: InstructorColors.textSecondaryColor(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _handleAction(_GroupFilterAction action) {
    switch (action.kind) {
      case _GroupFilterKind.course:
        onCourseChanged(action.value as int?);
        break;
      case _GroupFilterKind.chapter:
        onChapterChanged(action.value as int?);
        break;
      case _GroupFilterKind.type:
        onGroupTypeChanged(action.value as QuestionGroupType?);
        break;
    }
  }

  List<TeachingCourseModel> _uniqueCourses(List<TeachingCourseModel> source) {
    final seen = <int>{};
    return [
      for (final course in source)
        if (seen.add(course.courseId)) course,
    ];
  }

  IconData _groupTypeIcon(QuestionGroupType type) {
    switch (type) {
      case QuestionGroupType.passage:
        return Icons.article_outlined;
      case QuestionGroupType.caseStudy:
        return Icons.work_outline_rounded;
      case QuestionGroupType.imageSet:
        return Icons.collections_outlined;
      case QuestionGroupType.multipart:
        return Icons.account_tree_outlined;
      case QuestionGroupType.other:
        return Icons.folder_copy_outlined;
    }
  }
}

class _GroupFilterButton extends StatelessWidget {
  const _GroupFilterButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.entries,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;
  final List<PopupMenuEntry<_GroupFilterAction>> entries;
  final ValueChanged<_GroupFilterAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<_GroupFilterAction>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 340),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => entries,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color : InstructorColors.borderColor(isDark),
            width: isActive ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? color
                          : InstructorColors.textSecondaryColor(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GroupFilterKind { course, chapter, type }

class _GroupFilterAction {
  const _GroupFilterAction(this.kind, this.value);

  final _GroupFilterKind kind;
  final Object? value;
}

class _ModernGroupCard extends StatelessWidget {
  const _ModernGroupCard({
    required this.group,
    required this.courseLabel,
    required this.isBusy,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAddGrouped,
    required this.onAddExisting,
  });

  final QuestionBankGroupModel group;
  final String courseLabel;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddGrouped;
  final VoidCallback onAddExisting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _groupColor(group.groupType);
    final title = group.title ?? l10n.questionBankGroupDetails;
    final prompt = questionTextForDisplay(group.sharedPrompt, fallback: '');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          clipBehavior: Clip.antiAlias,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: isDark ? 0.22 : 0.14),
                      InstructorColors.teal.withValues(
                        alpha: isDark ? 0.18 : 0.08,
                      ),
                    ],
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _groupTypeIcon(group.groupType),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _MiniPill(
                                label: localizedGroupType(
                                  l10n,
                                  group.groupType,
                                ),
                                color: accent,
                                isDark: isDark,
                              ),
                              _MiniPill(
                                label: l10n.qbQuestionCount(
                                  group.totalQuestions,
                                ),
                                color: InstructorColors.primary,
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            courseLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(
                                isDark,
                              ),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.qbEditGroup,
                          onPressed: isBusy ? null : onEdit,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: isDark ? 0.12 : 0.78,
                            ),
                            foregroundColor: InstructorColors.primary,
                          ),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: l10n.qbDeleteGroup,
                          onPressed: isBusy ? null : onDelete,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: isDark ? 0.12 : 0.78,
                            ),
                            foregroundColor: InstructorColors.error,
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 430;
                        final width = compact
                            ? (constraints.maxWidth - 8) / 2
                            : (constraints.maxWidth - 16) / 3;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _GroupStatTile(
                              width: width,
                              label: l10n.questions,
                              value: group.totalQuestions.toString(),
                              icon: Icons.quiz_outlined,
                              color: InstructorColors.primary,
                              isDark: isDark,
                            ),
                            _GroupStatTile(
                              width: width,
                              label: l10n.approved,
                              value: group.approvedQuestions.toString(),
                              icon: Icons.verified_rounded,
                              color: InstructorColors.success,
                              isDark: isDark,
                            ),
                            _GroupStatTile(
                              width: width,
                              label: l10n.draft,
                              value: group.draftQuestions.toString(),
                              icon: Icons.pending_actions_outlined,
                              color: InstructorColors.warning,
                              isDark: isDark,
                            ),
                          ],
                        );
                      },
                    ),
                    if (prompt.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      QuestionFormattedText(
                        text: group.sharedPrompt,
                        fallback: '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textSecondaryColor(isDark),
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 380;
                        final addGrouped = _CardActionChip(
                          label: l10n.qbGroupedBatchCreate,
                          icon: Icons.playlist_add_rounded,
                          color: InstructorColors.primary,
                          onPressed: isBusy ? null : onAddGrouped,
                        );
                        final addExisting = _CardActionChip(
                          label: l10n.qbAddExistingQuestions,
                          icon: Icons.add_link_rounded,
                          color: InstructorColors.accent,
                          onPressed: isBusy ? null : onAddExisting,
                        );
                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              addGrouped,
                              const SizedBox(height: 8),
                              addExisting,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: addGrouped),
                            const SizedBox(width: 10),
                            Expanded(child: addExisting),
                          ],
                        );
                      },
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

  Color _groupColor(QuestionGroupType type) {
    switch (type) {
      case QuestionGroupType.passage:
        return InstructorColors.primary;
      case QuestionGroupType.caseStudy:
        return InstructorColors.orange;
      case QuestionGroupType.imageSet:
        return InstructorColors.accent;
      case QuestionGroupType.multipart:
        return InstructorColors.teal;
      case QuestionGroupType.other:
        return InstructorColors.info;
    }
  }

  IconData _groupTypeIcon(QuestionGroupType type) {
    switch (type) {
      case QuestionGroupType.passage:
        return Icons.article_outlined;
      case QuestionGroupType.caseStudy:
        return Icons.work_outline_rounded;
      case QuestionGroupType.imageSet:
        return Icons.collections_outlined;
      case QuestionGroupType.multipart:
        return Icons.account_tree_outlined;
      case QuestionGroupType.other:
        return Icons.folder_copy_outlined;
    }
  }
}

class _GroupStatTile extends StatelessWidget {
  const _GroupStatTile({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textSecondaryColor(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.color,
    required this.isDark,
  });

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CardActionChip extends StatelessWidget {
  const _CardActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color.withValues(alpha: isDark ? 0.15 : 0.08),
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.22)),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 17),
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

class _GroupsErrorRetry extends StatelessWidget {
  const _GroupsErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.error.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: InstructorColors.error.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: InstructorColors.error,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
