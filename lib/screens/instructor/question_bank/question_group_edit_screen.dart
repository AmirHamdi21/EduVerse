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
import '../../../models/question_bank/question_bank_upload_response.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import 'question_bank_create_screen.dart';

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
  final Set<int> _pendingUploadIds = <int>{};
  bool _saved = false;

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
              Icons.arrow_back_ios_new_rounded,
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
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
              children: [
                QuestionFormHero(
                  title: l10n.qbEditGroup,
                  subtitle: group.title?.trim().isNotEmpty == true
                      ? group.title!
                      : l10n.qbSharedPrompt,
                  tiles: {
                    l10n.course: _courseLabel(group, bankState),
                    l10n.qbGroupType: localizedGroupType(l10n, group.groupType),
                  },
                ),
                const SizedBox(height: 18),
                QuestionGroupFormCard(
                  initial: group,
                  courseId: group.courseId,
                  onUploadSharedImage: (path) =>
                      _uploadGroupImage(context, path),
                  onRemoveSharedImage: (fileId) async {
                    if (_pendingUploadIds.remove(fileId)) {
                      await context
                          .read<QuestionGroupCubit>()
                          .deleteUploadedQuestionImage(fileId);
                    }
                  },
                  isSubmitting: state.isMutating,
                  onSubmit:
                      ({
                        title,
                        sharedPrompt,
                        sharedFileId,
                        sharedFileCaption,
                        sharedFileAltText,
                        required QuestionGroupType groupType,
                      }) async {
                        await context.read<QuestionGroupCubit>().updateGroup(
                          groupId: group.id,
                          title: title,
                          sharedPrompt: sharedPrompt,
                          sharedFileId: sharedFileId,
                          sharedFileCaption: sharedFileCaption,
                          sharedFileAltText: sharedFileAltText,
                          groupType: groupType,
                          clearSharedFile:
                              group.sharedFileId != null &&
                              sharedFileId == null,
                        );
                        if (context.mounted) {
                          _saved = true;
                          context.go(
                            '/instructor/question-bank/groups/${group.id}',
                          );
                        }
                      },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<QuestionBankUploadResponse?> _uploadGroupImage(
    BuildContext context,
    String path,
  ) async {
    final upload = await context.read<QuestionGroupCubit>().uploadGroupImage(
      path,
    );
    final fileId = upload?.fileId;
    if (fileId != null) _pendingUploadIds.add(fileId);
    return upload;
  }

  Future<void> _handleBack(BuildContext context) async {
    if (!_saved && _pendingUploadIds.isNotEmpty) {
      final l10n = AppLocalizations.of(context);
      final discard =
          await showDialog<bool>(
            context: context,
            builder: (context) => QuestionFormDecisionDialog(
              title: l10n.qbDiscardUploadsTitle,
              message: l10n.qbDiscardUploadsBody,
              icon: Icons.cloud_off_outlined,
              color: InstructorColors.error,
              primaryLabel: l10n.discard,
              secondaryLabel: l10n.cancel,
              onPrimary: () => Navigator.of(context).pop(true),
              onSecondary: () => Navigator.of(context).pop(false),
            ),
          ) ??
          false;
      if (!discard || !context.mounted) return;
      await context.read<QuestionGroupCubit>().discardUploadedQuestionImages(
        _pendingUploadIds,
      );
    }
    if (context.mounted) context.pop();
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
