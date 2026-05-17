import 'dart:async';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

class QuestionGroupLinkQuestionsScreen extends StatelessWidget {
  const QuestionGroupLinkQuestionsScreen({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => QuestionGroupCubit(
            questionBankService: QuestionBankService(
              coreApiClient: CoreApiClient(),
            ),
          )..load(groupId),
        ),
        BlocProvider(
          create: (_) => QuestionBankCubit(
            questionBankService: QuestionBankService(
              coreApiClient: CoreApiClient(),
            ),
            enrollmentService: EnrollmentService(
              coreApiClient: CoreApiClient(),
            ),
          )..initialize(),
        ),
      ],
      child: const _QuestionGroupLinkQuestionsView(),
    );
  }
}

class _QuestionGroupLinkQuestionsView extends StatefulWidget {
  const _QuestionGroupLinkQuestionsView();

  @override
  State<_QuestionGroupLinkQuestionsView> createState() =>
      _QuestionGroupLinkQuestionsViewState();
}

class _QuestionGroupLinkQuestionsViewState
    extends State<_QuestionGroupLinkQuestionsView> {
  final Set<int> _selected = <int>{};
  final TextEditingController _search = TextEditingController();
  final QuestionBankService _questionBankService = QuestionBankService(
    coreApiClient: CoreApiClient(),
  );
  List<QuestionBankQuestionModel> _candidates = const [];
  List<CourseChapterModel> _filterChapters = const [];
  Timer? _searchDebounce;
  bool _loadingCandidates = false;
  bool _loadingFilterChapters = false;
  bool _loadedOnce = false;
  bool _courseInitialized = false;
  int _candidateRequestSerial = 0;
  int? _courseId;
  int? _chapterId;
  QuestionBankStatus? _status;
  QuestionBankType? _type;
  QuestionBankDifficulty? _difficulty;
  BloomLevel? _bloomLevel;

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
          onPressed: () {
            final groupId = context.read<QuestionGroupCubit>().state.group?.id;
            safeFeatureBack(
              context,
              groupId == null
                  ? '/instructor/question-bank/groups'
                  : '/instructor/question-bank/groups/$groupId',
            );
          },
          icon: Icon(
            safeFeatureBackIcon(context),
            color: InstructorColors.textPrimaryColor(isDark),
          ),
        ),
        title: Text(
          l10n.qbAddExistingQuestions,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: BlocConsumer<QuestionGroupCubit, QuestionGroupState>(
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
          final group = state.group;
          final bankState = context.watch<QuestionBankCubit>().state;
          if (group != null && !_courseInitialized) {
            _courseId = group.courseId;
            _filterChapters = state.chapters;
            _courseInitialized = true;
          }
          if (group != null && !_loadedOnce && !_loadingCandidates) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadCandidates(context, state);
            });
          }
          if (state.isLoading || group == null || !_loadedOnce) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: const [QuestionBankSkeletons(itemCount: 3)],
            );
          }
          final visibleIds = _candidates.map((question) => question.id).toSet();
          final visibleSelectedCount = _selected
              .intersection(visibleIds)
              .length;
          final allVisibleSelected =
              _candidates.isNotEmpty &&
              visibleSelectedCount == _candidates.length;

          final content = ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
            children: [
              QuestionFormHero(
                title: l10n.qbAddExistingQuestions,
                subtitle: group.title ?? l10n.questionBankGroupDetails,
                tiles: {
                  l10n.course: _selectedCourseLabel(group, bankState),
                  l10n.questions: _candidates.length.toString(),
                  l10n.selected: _selected.length.toString(),
                },
              ),
              const SizedBox(height: 18),
              _FilterPanel(
                bankState: bankState,
                selectedCourseId: _courseId,
                chapterId: _chapterId,
                status: _status,
                type: _type,
                difficulty: _difficulty,
                bloomLevel: _bloomLevel,
                search: _search,
                isLoading: _loadingCandidates,
                isLoadingChapters: _loadingFilterChapters,
                chapters: _filterChapters,
                onCourseChanged: (value) =>
                    _setCourseFilter(context, state, value),
                onChapterChanged: (value) =>
                    _setFilter(context, state, () => _chapterId = value),
                onStatusChanged: (value) =>
                    _setFilter(context, state, () => _status = value),
                onTypeChanged: (value) =>
                    _setFilter(context, state, () => _type = value),
                onDifficultyChanged: (value) =>
                    _setFilter(context, state, () => _difficulty = value),
                onBloomChanged: (value) =>
                    _setFilter(context, state, () => _bloomLevel = value),
                onSearchChanged: (value) => _onSearchChanged(context, state),
                onQuestionFiltersCleared: () {
                  setState(() {
                    _status = null;
                    _type = null;
                    _difficulty = null;
                    _bloomLevel = null;
                  });
                  _loadCandidates(context, state);
                },
                onClear: () {
                  _searchDebounce?.cancel();
                  setState(() {
                    _courseId = group.courseId;
                    _filterChapters = state.chapters;
                    _chapterId = null;
                    _status = null;
                    _type = null;
                    _difficulty = null;
                    _bloomLevel = null;
                    _search.clear();
                  });
                  _loadCandidates(context, state);
                },
              ),
              const SizedBox(height: 16),
              _SelectionPanel(
                candidateCount: _candidates.length,
                selectedCount: _selected.length,
                allVisibleSelected: allVisibleSelected,
                isBusy: state.isMutating,
                onSelectAllVisible: _candidates.isEmpty
                    ? null
                    : () {
                        setState(() {
                          if (allVisibleSelected) {
                            _selected.removeAll(visibleIds);
                          } else {
                            _selected.addAll(visibleIds);
                          }
                        });
                      },
                onClearSelection: _selected.isEmpty
                    ? null
                    : () => setState(_selected.clear),
                onSubmit: _selected.isEmpty
                    ? null
                    : () => _submitLink(context, state),
              ),
              const SizedBox(height: 16),
              if (_candidates.isEmpty)
                QuestionBankEmptyState(
                  title: l10n.questionBankEmptyTitle,
                  message: l10n.questionBankEmptyMessage,
                )
              else
                QuestionSectionCard(
                  title: l10n.qbAvailableQuestions,
                  icon: Icons.library_add_check_outlined,
                  color: InstructorColors.primary,
                  children: [
                    for (final question in _candidates)
                      _CandidateQuestionCard(
                        question: question,
                        selected: _selected.contains(question.id),
                        onToggle: () {
                          setState(() {
                            if (_selected.contains(question.id)) {
                              _selected.remove(question.id);
                            } else {
                              _selected.add(question.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
            ],
          );
          return Stack(
            children: [
              content,
              if (state.isMutating)
                Positioned.fill(
                  child: _LinkMutationOverlay(
                    selectedCount: _selected.length,
                    isDark: isDark,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _setFilter(
    BuildContext context,
    QuestionGroupState state,
    VoidCallback update,
  ) {
    setState(update);
    _loadCandidates(context, state);
  }

  void _onSearchChanged(BuildContext context, QuestionGroupState state) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 120), () {
      if (mounted) _loadCandidates(context, state);
    });
  }

  Future<void> _setCourseFilter(
    BuildContext context,
    QuestionGroupState state,
    int? courseId,
  ) async {
    _searchDebounce?.cancel();
    setState(() {
      _courseId = courseId;
      _chapterId = null;
      _filterChapters = courseId == state.group?.courseId
          ? state.chapters
          : const <CourseChapterModel>[];
      _loadingFilterChapters =
          courseId != null && courseId != state.group?.courseId;
    });
    if (courseId != null && courseId != state.group?.courseId) {
      final result = await _questionBankService.getChapters(courseId);
      if (!mounted) return;
      setState(() {
        _loadingFilterChapters = false;
        _filterChapters = result.data ?? const <CourseChapterModel>[];
      });
    }
    if (mounted) _loadCandidates(this.context, state);
  }

  Future<void> _submitLink(
    BuildContext context,
    QuestionGroupState state,
  ) async {
    final group = state.group;
    if (group == null || _selected.isEmpty) return;
    final ok = await context.read<QuestionGroupCubit>().linkExistingQuestions(
      _selected.toList(),
    );
    if (ok && context.mounted) {
      final refresh = DateTime.now().microsecondsSinceEpoch;
      context.go(
        '/instructor/question-bank/groups/${group.id}?refresh=$refresh',
      );
    }
  }

  Future<void> _loadCandidates(
    BuildContext context,
    QuestionGroupState state,
  ) async {
    final group = state.group;
    if (group == null) return;
    final requestId = ++_candidateRequestSerial;
    setState(() => _loadingCandidates = true);
    final result = await _questionBankService.getQuestions(
      courseId: _courseId,
      chapterId: _chapterId,
      status: _status,
      questionType: _type,
      difficulty: _difficulty,
      bloomLevel: _bloomLevel,
      search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      limit: 100,
    );
    if (!mounted || requestId != _candidateRequestSerial) return;
    final existingIds = state.questions.map((q) => q.id).toSet();
    final nextCandidates =
        (result.data?.data ?? const <QuestionBankQuestionModel>[])
            .where(
              (question) => _courseId == null || question.courseId == _courseId,
            )
            .where((question) => !existingIds.contains(question.id))
            .where((question) => question.status != QuestionBankStatus.archived)
            .toList();
    setState(() {
      _loadingCandidates = false;
      _loadedOnce = true;
      _candidates = nextCandidates;
      final availableIds = nextCandidates
          .map((question) => question.id)
          .toSet();
      _selected.removeWhere((id) => !availableIds.contains(id));
    });
    if (!result.isSuccess && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error?.message ?? l10n.operationFailed)),
      );
    }
  }

  String _selectedCourseLabel(
    QuestionBankGroupModel group,
    QuestionBankState state,
  ) {
    if (_courseId == null) return AppLocalizations.of(context).allCourses;
    for (final course in state.teachingCourses) {
      if (course.courseId == _courseId) {
        final code = course.course.code.trim();
        final name = course.course.name.trim();
        if (code.isNotEmpty && name.isNotEmpty) return '$code - $name';
        if (code.isNotEmpty) return code;
        if (name.isNotEmpty) return name;
      }
    }
    if (_courseId != group.courseId) return _courseId.toString();
    return _courseLabel(group, state);
  }

  String _courseLabel(QuestionBankGroupModel group, QuestionBankState state) {
    for (final course in state.teachingCourses) {
      if (course.courseId == group.courseId) {
        final code = course.course.code.trim();
        final name = course.course.name.trim();
        if (code.isNotEmpty && name.isNotEmpty) return '$code - $name';
        if (code.isNotEmpty) return code;
        if (name.isNotEmpty) return name;
      }
    }
    final code = group.courseCode?.trim();
    final name = group.courseName?.trim();
    if (code != null && code.isNotEmpty && name != null && name.isNotEmpty) {
      return '$code - $name';
    }
    if (code != null && code.isNotEmpty) return code;
    if (name != null && name.isNotEmpty) return name;
    return group.courseId.toString();
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.bankState,
    required this.selectedCourseId,
    required this.chapterId,
    required this.status,
    required this.type,
    required this.difficulty,
    required this.bloomLevel,
    required this.search,
    required this.isLoading,
    required this.isLoadingChapters,
    required this.chapters,
    required this.onCourseChanged,
    required this.onChapterChanged,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
    required this.onBloomChanged,
    required this.onSearchChanged,
    required this.onQuestionFiltersCleared,
    required this.onClear,
  });

  final QuestionBankState bankState;
  final int? selectedCourseId;
  final int? chapterId;
  final QuestionBankStatus? status;
  final QuestionBankType? type;
  final QuestionBankDifficulty? difficulty;
  final BloomLevel? bloomLevel;
  final TextEditingController search;
  final bool isLoading;
  final bool isLoadingChapters;
  final List<CourseChapterModel> chapters;
  final ValueChanged<int?> onCourseChanged;
  final ValueChanged<int?> onChapterChanged;
  final ValueChanged<QuestionBankStatus?> onStatusChanged;
  final ValueChanged<QuestionBankType?> onTypeChanged;
  final ValueChanged<QuestionBankDifficulty?> onDifficultyChanged;
  final ValueChanged<BloomLevel?> onBloomChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onQuestionFiltersCleared;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCustomFilters =
        search.text.trim().isNotEmpty ||
        selectedCourseId == null ||
        chapterId != null ||
        status != null ||
        type != null ||
        difficulty != null ||
        bloomLevel != null;
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
              hintText: l10n.questionBankSearchQuestionTextOnly,
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
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearchChanged(search.text),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _LinkFilterMenuButton(
                  title: '${l10n.course} / ${l10n.chapter}',
                  subtitle: _scopeSubtitle(l10n),
                  icon: Icons.account_tree_outlined,
                  color: InstructorColors.primary,
                  isDark: isDark,
                  isActive: selectedCourseId != null || chapterId != null,
                  entries: _scopeEntries(l10n, isDark),
                  onSelected: _handleAction,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LinkFilterMenuButton(
                  title: '${l10n.question} ${l10n.filters}',
                  subtitle: _questionSubtitle(l10n),
                  icon: Icons.tune_rounded,
                  color: InstructorColors.teal,
                  isDark: isDark,
                  isActive:
                      status != null ||
                      type != null ||
                      difficulty != null ||
                      bloomLevel != null,
                  entries: _questionEntries(l10n, isDark),
                  onSelected: _handleAction,
                ),
              ),
            ],
          ),
          if (isLoading || isLoadingChapters) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 3),
          ],
          if (hasCustomFilters) ...[
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

  String _scopeSubtitle(AppLocalizations l10n) {
    final labels = <String>[
      _selectedCourseLabel(l10n),
      if (chapterId != null)
        chapters
                .where((chapter) => chapter.id == chapterId)
                .firstOrNull
                ?.name ??
            l10n.chapter,
    ];
    return labels.join(' • ');
  }

  String _selectedCourseLabel(AppLocalizations l10n) {
    if (selectedCourseId == null) return l10n.allCourses;
    final course = bankState.teachingCourses
        .where((course) => course.courseId == selectedCourseId)
        .firstOrNull;
    if (course == null) return selectedCourseId.toString();
    final code = course.course.code.trim();
    final name = course.course.name.trim();
    if (code.isNotEmpty && name.isNotEmpty) return '$code - $name';
    if (code.isNotEmpty) return code;
    return name.isNotEmpty ? name : selectedCourseId.toString();
  }

  String _questionSubtitle(AppLocalizations l10n) {
    final labels = <String>[
      if (status != null) localizedQuestionStatus(l10n, status!),
      if (type != null) localizedQuestionType(l10n, type!),
      if (difficulty != null) localizedDifficulty(l10n, difficulty!),
      if (bloomLevel != null) localizedBloomLevel(l10n, bloomLevel!),
    ];
    return labels.isEmpty ? l10n.allStates : labels.join(' • ');
  }

  List<PopupMenuEntry<_LinkFilterAction>> _scopeEntries(
    AppLocalizations l10n,
    bool isDark,
  ) {
    return [
      _menuHeader(l10n.course, isDark),
      _menuOption(
        label: l10n.allCourses,
        selected: selectedCourseId == null,
        action: const _LinkFilterAction(_LinkFilterKind.course, null),
        isDark: isDark,
      ),
      ...bankState.teachingCourses.map(
        (course) => _menuOption(
          label: '${course.course.code} - ${course.course.name}',
          selected: selectedCourseId == course.courseId,
          action: _LinkFilterAction(_LinkFilterKind.course, course.courseId),
          isDark: isDark,
        ),
      ),
      const PopupMenuDivider(height: 8),
      _menuHeader(l10n.chapter, isDark),
      _menuOption(
        label: l10n.allChapters,
        selected: chapterId == null,
        action: const _LinkFilterAction(_LinkFilterKind.chapter, null),
        isDark: isDark,
      ),
      ...chapters.map(
        (chapter) => _menuOption(
          label: chapter.name,
          selected: chapterId == chapter.id,
          action: _LinkFilterAction(_LinkFilterKind.chapter, chapter.id),
          isDark: isDark,
        ),
      ),
    ];
  }

  List<PopupMenuEntry<_LinkFilterAction>> _questionEntries(
    AppLocalizations l10n,
    bool isDark,
  ) {
    return [
      _menuOption(
        label: l10n.clearFilters,
        icon: Icons.filter_alt_off_rounded,
        selected:
            status == null &&
            type == null &&
            difficulty == null &&
            bloomLevel == null,
        action: const _LinkFilterAction(_LinkFilterKind.questionReset, null),
        isDark: isDark,
      ),
      const PopupMenuDivider(height: 8),
      _menuHeader(l10n.status, isDark),
      _menuOption(
        label: l10n.allStates,
        selected: status == null,
        action: const _LinkFilterAction(_LinkFilterKind.status, null),
        isDark: isDark,
      ),
      ...QuestionBankStatus.values.map(
        (value) => _menuOption(
          label: localizedQuestionStatus(l10n, value),
          selected: status == value,
          action: _LinkFilterAction(_LinkFilterKind.status, value),
          isDark: isDark,
        ),
      ),
      const PopupMenuDivider(height: 8),
      _menuHeader(l10n.type, isDark),
      _menuOption(
        label: l10n.allStates,
        selected: type == null,
        action: const _LinkFilterAction(_LinkFilterKind.type, null),
        isDark: isDark,
      ),
      ...QuestionBankType.values.map(
        (value) => _menuOption(
          label: localizedQuestionType(l10n, value),
          selected: type == value,
          action: _LinkFilterAction(_LinkFilterKind.type, value),
          isDark: isDark,
        ),
      ),
      const PopupMenuDivider(height: 8),
      _menuHeader(l10n.difficulty, isDark),
      _menuOption(
        label: l10n.allStates,
        selected: difficulty == null,
        action: const _LinkFilterAction(_LinkFilterKind.difficulty, null),
        isDark: isDark,
      ),
      ...QuestionBankDifficulty.values.map(
        (value) => _menuOption(
          label: localizedDifficulty(l10n, value),
          selected: difficulty == value,
          action: _LinkFilterAction(_LinkFilterKind.difficulty, value),
          isDark: isDark,
        ),
      ),
      const PopupMenuDivider(height: 8),
      _menuHeader(l10n.bloomLevel, isDark),
      _menuOption(
        label: l10n.allStates,
        selected: bloomLevel == null,
        action: const _LinkFilterAction(_LinkFilterKind.bloom, null),
        isDark: isDark,
      ),
      ...BloomLevel.values.map(
        (value) => _menuOption(
          label: localizedBloomLevel(l10n, value),
          selected: bloomLevel == value,
          action: _LinkFilterAction(_LinkFilterKind.bloom, value),
          isDark: isDark,
        ),
      ),
    ];
  }

  PopupMenuItem<_LinkFilterAction> _menuOption({
    required String label,
    required bool selected,
    required _LinkFilterAction action,
    required bool isDark,
    IconData? icon,
  }) {
    return PopupMenuItem<_LinkFilterAction>(
      value: action,
      child: Row(
        children: [
          Icon(
            icon ??
                (selected ? Icons.check_circle_rounded : Icons.circle_outlined),
            size: 18,
            color: selected
                ? InstructorColors.primary
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
                    ? InstructorColors.primary
                    : InstructorColors.textPrimaryColor(isDark),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_LinkFilterAction> _menuHeader(String label, bool isDark) {
    return PopupMenuItem<_LinkFilterAction>(
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

  void _handleAction(_LinkFilterAction action) {
    switch (action.kind) {
      case _LinkFilterKind.course:
        onCourseChanged(action.value as int?);
        break;
      case _LinkFilterKind.chapter:
        onChapterChanged(action.value as int?);
        break;
      case _LinkFilterKind.status:
        onStatusChanged(action.value as QuestionBankStatus?);
        break;
      case _LinkFilterKind.type:
        onTypeChanged(action.value as QuestionBankType?);
        break;
      case _LinkFilterKind.difficulty:
        onDifficultyChanged(action.value as QuestionBankDifficulty?);
        break;
      case _LinkFilterKind.bloom:
        onBloomChanged(action.value as BloomLevel?);
        break;
      case _LinkFilterKind.questionReset:
        onQuestionFiltersCleared();
        break;
    }
  }
}

class _LinkFilterMenuButton extends StatelessWidget {
  const _LinkFilterMenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.isActive,
    required this.entries,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool isActive;
  final List<PopupMenuEntry<_LinkFilterAction>> entries;
  final ValueChanged<_LinkFilterAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_LinkFilterAction>(
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

enum _LinkFilterKind {
  course,
  chapter,
  status,
  type,
  difficulty,
  bloom,
  questionReset,
}

class _LinkFilterAction {
  const _LinkFilterAction(this.kind, this.value);

  final _LinkFilterKind kind;
  final Object? value;
}

class _SelectionPanel extends StatelessWidget {
  const _SelectionPanel({
    required this.candidateCount,
    required this.selectedCount,
    required this.allVisibleSelected,
    required this.isBusy,
    required this.onSelectAllVisible,
    required this.onClearSelection,
    required this.onSubmit,
  });

  final int candidateCount;
  final int selectedCount;
  final bool allVisibleSelected;
  final bool isBusy;
  final VoidCallback? onSelectAllVisible;
  final VoidCallback? onClearSelection;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selectedCount > 0
              ? InstructorColors.primary.withValues(alpha: 0.35)
              : InstructorColors.borderColor(isDark),
        ),
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.add_link_rounded,
                  color: InstructorColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.qbLinkSelectedQuestions,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${l10n.selected}: $selectedCount • ${l10n.qbAvailableQuestions}: $candidateCount',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(
                    alpha: isDark ? 0.18 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  selectedCount.toString(),
                  style: const TextStyle(
                    color: InstructorColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              final secondaryWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : onSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: InstructorColors.primary
                            .withValues(alpha: 0.42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      icon: isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.add_link_rounded),
                      label: Text(
                        l10n.qbLinkSelectedQuestions,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: secondaryWidth,
                    child: OutlinedButton.icon(
                      onPressed: isBusy ? null : onSelectAllVisible,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: InstructorColors.teal,
                        backgroundColor: InstructorColors.teal.withValues(
                          alpha: isDark ? 0.16 : 0.08,
                        ),
                        side: BorderSide(
                          color: InstructorColors.teal.withValues(alpha: 0.24),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: Icon(
                        allVisibleSelected
                            ? Icons.indeterminate_check_box_rounded
                            : Icons.select_all_rounded,
                      ),
                      label: Text(
                        l10n.qbSelectAllVisible,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: secondaryWidth,
                    child: OutlinedButton.icon(
                      onPressed: isBusy ? null : onClearSelection,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: InstructorColors.error,
                        backgroundColor: InstructorColors.error.withValues(
                          alpha: isDark ? 0.16 : 0.08,
                        ),
                        side: BorderSide(
                          color: InstructorColors.error.withValues(alpha: 0.24),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.clear_all_rounded),
                      label: Text(
                        l10n.qbClearSelection,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LinkMutationOverlay extends StatelessWidget {
  const _LinkMutationOverlay({
    required this.selectedCount,
    required this.isDark,
  });

  final int selectedCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AbsorbPointer(
      child: Container(
        color: Colors.black.withValues(alpha: isDark ? 0.48 : 0.32),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.96, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: InstructorColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: InstructorColors.primary.withValues(
                    alpha: isDark ? 0.35 : 0.18,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.14),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
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
                    l10n.qbLinkSelectedQuestions,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Linking ${l10n.qbSelectedCount(selectedCount).toLowerCase()} to this group. Please wait until the selected questions are updated.',
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
        ),
      ),
    );
  }
}

class _CandidateQuestionCard extends StatelessWidget {
  const _CandidateQuestionCard({
    required this.question,
    required this.selected,
    required this.onToggle,
  });

  final QuestionBankQuestionModel question;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = selected ? InstructorColors.primary : InstructorColors.teal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? InstructorColors.primary.withValues(alpha: 0.55)
                    : InstructorColors.borderColor(isDark),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: DecoratedBox(decoration: BoxDecoration(color: accent)),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.18 : 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            QuestionFormattedText(
                              text: question.questionText,
                              fallback:
                                  '${l10n.questionBankImageQuestion} ${question.id}',
                              clipMathToMaxLines: true,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 9),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _QuestionInfoPill(
                                  label: localizedQuestionStatus(
                                    l10n,
                                    question.status,
                                  ),
                                  color: _statusColor(question.status),
                                  isDark: isDark,
                                ),
                                _QuestionInfoPill(
                                  label: localizedQuestionType(
                                    l10n,
                                    question.questionType,
                                  ),
                                  color: InstructorColors.primary,
                                  isDark: isDark,
                                ),
                                _QuestionInfoPill(
                                  label: localizedDifficulty(
                                    l10n,
                                    question.difficulty,
                                  ),
                                  color: InstructorColors.teal,
                                  isDark: isDark,
                                ),
                                _QuestionInfoPill(
                                  label: localizedBloomLevel(
                                    l10n,
                                    question.bloomLevel,
                                  ),
                                  color: InstructorColors.accent,
                                  isDark: isDark,
                                ),
                                if (question.hasAttachments)
                                  _QuestionInfoPill(
                                    label: l10n.attachments,
                                    color: InstructorColors.warning,
                                    isDark: isDark,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(QuestionBankStatus status) {
    switch (status) {
      case QuestionBankStatus.approved:
        return InstructorColors.success;
      case QuestionBankStatus.underReview:
        return InstructorColors.warning;
      case QuestionBankStatus.rejected:
      case QuestionBankStatus.archived:
        return InstructorColors.error;
      case QuestionBankStatus.draft:
        return InstructorColors.primary;
    }
  }
}

class _QuestionInfoPill extends StatelessWidget {
  const _QuestionInfoPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
