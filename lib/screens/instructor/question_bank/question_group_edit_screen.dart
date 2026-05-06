import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_group_cubit.dart';
import '../../../bloc/instructor/question_bank/question_group_state.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';

class QuestionGroupEditScreen extends StatelessWidget {
  const QuestionGroupEditScreen({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionGroupCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..load(groupId),
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
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.qbEditGroup),
          leading: IconButton(
            onPressed: () => _handleBack(context),
            icon: const Icon(Icons.arrow_back_rounded),
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
            if (state.isLoading || group == null) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: QuestionBankSkeletons(itemCount: 4),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                QuestionGroupFormCard(
                  initial: group,
                  courseId: group.courseId,
                  onUploadSharedImage: (path) =>
                      _uploadGroupImage(context, path),
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

  Future<int?> _uploadGroupImage(BuildContext context, String path) async {
    final fileId = await context.read<QuestionGroupCubit>().uploadGroupImage(
      path,
    );
    if (fileId != null) _pendingUploadIds.add(fileId);
    return fileId;
  }

  Future<void> _handleBack(BuildContext context) async {
    if (!_saved && _pendingUploadIds.isNotEmpty) {
      final l10n = AppLocalizations.of(context);
      final discard =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.qbDiscardUploadsTitle),
              content: Text(l10n.qbDiscardUploadsBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.discard),
                ),
              ],
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
}
