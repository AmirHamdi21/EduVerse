import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

class QuestionGroupCreateScreen extends StatelessWidget {
  const QuestionGroupCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
        BlocProvider(
          create: (_) => QuestionGroupCubit(
            questionBankService: QuestionBankService(
              coreApiClient: CoreApiClient(),
            ),
          ),
        ),
      ],
      child: const _QuestionGroupCreateView(),
    );
  }
}

class _QuestionGroupCreateView extends StatefulWidget {
  const _QuestionGroupCreateView();

  @override
  State<_QuestionGroupCreateView> createState() =>
      _QuestionGroupCreateViewState();
}

class _QuestionGroupCreateViewState extends State<_QuestionGroupCreateView> {
  bool _isSavingGroup = false;

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
            l10n.qbCreateGroup,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          leading: IconButton(
            onPressed: () => _handleBack(context),
            icon: Icon(
              safeFeatureBackIcon(context),
              color: InstructorColors.textPrimaryColor(isDark),
            ),
          ),
        ),
        body: BlocListener<QuestionGroupCubit, QuestionGroupState>(
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
          child: Stack(
            children: [
              BlocBuilder<QuestionBankCubit, QuestionBankState>(
                builder: (context, bankState) {
                  if (bankState.isLoading) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      children: const [QuestionBankSkeletons(itemCount: 3)],
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
                    children: [
                      QuestionFormHero(
                        title: l10n.qbCreateGroup,
                        subtitle: l10n.qbSharedPrompt,
                        tiles: {
                          l10n.course: _selectedCourseLabel(bankState),
                          l10n.qbGroupType: localizedGroupType(
                            l10n,
                            QuestionGroupType.other,
                          ),
                        },
                      ),
                      const SizedBox(height: 18),
                      _GroupCourseSelector(
                        courses: bankState.teachingCourses,
                        selectedCourseId: bankState.selectedCourseId,
                        onChanged: context
                            .read<QuestionBankCubit>()
                            .selectCourse,
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<QuestionGroupCubit, QuestionGroupState>(
                        builder: (context, groupState) {
                          return QuestionGroupFormCard(
                            key: ValueKey(bankState.selectedCourseId),
                            courseId: bankState.selectedCourseId,
                            isSubmitting:
                                _isSavingGroup || groupState.isMutating,
                            onSubmit:
                                ({
                                  title,
                                  sharedPrompt,
                                  sharedFileId,
                                  sharedImageLocalPath,
                                  sharedFileCaption,
                                  sharedFileAltText,
                                  required QuestionGroupType groupType,
                                }) => _submitGroup(
                                  context,
                                  bankState,
                                  title: title,
                                  sharedPrompt: sharedPrompt,
                                  sharedFileId: sharedFileId,
                                  sharedImageLocalPath: sharedImageLocalPath,
                                  sharedFileCaption: sharedFileCaption,
                                  sharedFileAltText: sharedFileAltText,
                                  groupType: groupType,
                                ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              if (_isSavingGroup)
                Positioned.fill(
                  child: QuestionBankMutationOverlay(
                    title: 'Saving group',
                    message: 'Please wait until the group is saved.',
                    isDark: isDark,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _uploadSharedImageIfNeeded(
    BuildContext context,
    String? path,
  ) async {
    if (path == null || path.trim().isEmpty) return null;
    final upload = await context.read<QuestionGroupCubit>().uploadGroupImage(
      path,
      showSuccessMessage: false,
    );
    return upload?.fileId;
  }

  Future<void> _submitGroup(
    BuildContext context,
    QuestionBankState bankState, {
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedImageLocalPath,
    String? sharedFileCaption,
    String? sharedFileAltText,
    required QuestionGroupType groupType,
  }) async {
    final courseId = bankState.selectedCourseId;
    if (courseId == null || _isSavingGroup) return;
    setState(() => _isSavingGroup = true);
    final cubit = context.read<QuestionGroupCubit>();
    int? uploadedFileId;
    try {
      uploadedFileId = await _uploadSharedImageIfNeeded(
        context,
        sharedImageLocalPath,
      );
      if (sharedImageLocalPath != null && uploadedFileId == null) return;
      final resolvedSharedFileId =
          uploadedFileId ?? ((sharedFileId ?? 0) > 0 ? sharedFileId : null);
      final id = await cubit.createGroup(
        courseId: courseId,
        title: title,
        sharedPrompt: sharedPrompt,
        sharedFileId: resolvedSharedFileId,
        sharedFileCaption: sharedFileCaption,
        sharedFileAltText: sharedFileAltText,
        groupType: groupType,
      );
      if (id == null && uploadedFileId != null) {
        await cubit.deleteUploadedQuestionImage(
          uploadedFileId,
          showSuccessMessage: false,
        );
      }
      if (id != null && context.mounted) {
        context.go('/instructor/question-bank/groups/$id');
      }
    } finally {
      if (mounted) setState(() => _isSavingGroup = false);
    }
  }

  Future<void> _handleBack(BuildContext context) async {
    if (context.mounted) {
      safeFeatureBack(context, '/instructor/question-bank/groups');
    }
  }

  String _selectedCourseLabel(QuestionBankState state) {
    for (final course in state.teachingCourses) {
      if (course.courseId == state.selectedCourseId) {
        return course.course.code;
      }
    }
    return state.selectedCourseId?.toString() ?? '-';
  }
}

class _GroupCourseSelector extends StatelessWidget {
  const _GroupCourseSelector({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uniqueCourses = _uniqueCourses(courses);
    final value =
        uniqueCourses.any((course) => course.courseId == selectedCourseId)
        ? selectedCourseId
        : null;
    return QuestionSectionCard(
      title: l10n.course,
      icon: Icons.school_outlined,
      color: InstructorColors.primary,
      children: [
        QuestionFormMenuField<int>(
          label: l10n.course,
          value: value,
          icon: Icons.menu_book_outlined,
          color: InstructorColors.primary,
          enabled: uniqueCourses.isNotEmpty,
          options: uniqueCourses
              .map(
                (course) => QuestionFormMenuOption<int>(
                  value: course.courseId,
                  label: '${course.course.code} - ${course.course.name}',
                  icon: Icons.menu_book_outlined,
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        if (uniqueCourses.isEmpty) ...[
          const SizedBox(height: 10),
          Text(
            l10n.noCoursesAvailable,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
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
