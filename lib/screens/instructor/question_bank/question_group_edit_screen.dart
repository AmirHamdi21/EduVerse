import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_bank_cubit.dart';
import '../../../bloc/instructor/question_bank/question_bank_state.dart';
import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/shared/safe_feature_back.dart';

class QuestionGroupEditScreen extends StatelessWidget {
  const QuestionGroupEditScreen({super.key, required this.groupId});

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
      child: const _QuestionGroupEditView(),
    );
  }
}

class _QuestionGroupEditView extends StatefulWidget {
  const _QuestionGroupEditView();

  @override
  State<_QuestionGroupEditView> createState() => _QuestionGroupEditViewState();
}

class _QuestionGroupEditViewState extends State<_QuestionGroupEditView> {
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
            l10n.qbEditGroup,
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
        body: BlocConsumer<QuestionGroupCubit, QuestionGroupState>(
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
            final group = state.group;
            final bankState = context.watch<QuestionBankCubit>().state;
            if (state.isLoading || group == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: const [QuestionBankSkeletons(itemCount: 3)],
              );
            }
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
                  children: [
                    QuestionFormHero(
                      title: l10n.qbEditGroup,
                      subtitle: group.title?.trim().isNotEmpty == true
                          ? group.title!
                          : l10n.qbSharedPrompt,
                      tiles: {
                        l10n.course: _courseLabel(group, bankState),
                        l10n.qbGroupType: localizedGroupType(
                          l10n,
                          group.groupType,
                        ),
                      },
                    ),
                    const SizedBox(height: 18),
                    QuestionGroupFormCard(
                      initial: group,
                      courseId: group.courseId,
                      isSubmitting: _isSavingGroup || state.isMutating,
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
                            group,
                            title: title,
                            sharedPrompt: sharedPrompt,
                            sharedFileId: sharedFileId,
                            sharedImageLocalPath: sharedImageLocalPath,
                            sharedFileCaption: sharedFileCaption,
                            sharedFileAltText: sharedFileAltText,
                            groupType: groupType,
                          ),
                    ),
                  ],
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
            );
          },
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
    QuestionBankGroupModel group, {
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedImageLocalPath,
    String? sharedFileCaption,
    String? sharedFileAltText,
    required QuestionGroupType groupType,
  }) async {
    if (_isSavingGroup) return;
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
      final saved = await cubit.updateGroup(
        groupId: group.id,
        title: title,
        sharedPrompt: sharedPrompt,
        sharedFileId: resolvedSharedFileId,
        sharedFileCaption: sharedFileCaption,
        sharedFileAltText: sharedFileAltText,
        groupType: groupType,
        clearSharedFile:
            group.sharedFileId != null && resolvedSharedFileId == null,
      );
      if (!saved && uploadedFileId != null) {
        await cubit.deleteUploadedQuestionImage(
          uploadedFileId,
          showSuccessMessage: false,
        );
      }
      if (saved && context.mounted) {
        context.go('/instructor/question-bank/groups/${group.id}');
      }
    } finally {
      if (mounted) setState(() => _isSavingGroup = false);
    }
  }

  Future<void> _handleBack(BuildContext context) async {
    if (context.mounted) {
      final groupId = context.read<QuestionGroupCubit>().state.group?.id;
      safeFeatureBack(
        context,
        groupId == null
            ? '/instructor/question-bank/groups'
            : '/instructor/question-bank/groups/$groupId',
      );
    }
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
