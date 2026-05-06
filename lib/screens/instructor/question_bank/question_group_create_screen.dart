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
          title: Text(l10n.qbCreateGroup),
          leading: IconButton(
            onPressed: () => _handleBack(context),
            icon: const Icon(Icons.arrow_back_rounded),
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
          child: BlocBuilder<QuestionBankCubit, QuestionBankState>(
            builder: (context, bankState) {
              if (bankState.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: QuestionBankSkeletons(itemCount: 4),
                );
              }
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  QuestionFormHero(
                    title: l10n.qbCreateGroup,
                    subtitle: l10n.qbSharedPrompt,
                    tiles: {l10n.course: _selectedCourseLabel(bankState)},
                  ),
                  const SizedBox(height: 18),
                  _GroupCourseSelector(
                    courses: bankState.teachingCourses,
                    selectedCourseId: bankState.selectedCourseId,
                    onChanged: context.read<QuestionBankCubit>().selectCourse,
                  ),
                  const SizedBox(height: 18),
                  BlocBuilder<QuestionGroupCubit, QuestionGroupState>(
                    builder: (context, groupState) {
                      return QuestionGroupFormCard(
                        key: ValueKey(bankState.selectedCourseId),
                        courseId: bankState.selectedCourseId,
                        onUploadSharedImage: (path) =>
                            _uploadGroupImage(context, path),
                        isSubmitting: groupState.isMutating,
                        onSubmit:
                            ({
                              title,
                              sharedPrompt,
                              sharedFileId,
                              sharedFileCaption,
                              sharedFileAltText,
                              required QuestionGroupType groupType,
                            }) async {
                              final courseId = bankState.selectedCourseId;
                              if (courseId == null) return;
                              final id = await context
                                  .read<QuestionGroupCubit>()
                                  .createGroup(
                                    courseId: courseId,
                                    title: title,
                                    sharedPrompt: sharedPrompt,
                                    sharedFileId: sharedFileId,
                                    sharedFileCaption: sharedFileCaption,
                                    sharedFileAltText: sharedFileAltText,
                                    groupType: groupType,
                                  );
                              if (id != null && context.mounted) {
                                _saved = true;
                                context.go(
                                  '/instructor/question-bank/groups/$id',
                                );
                              }
                            },
                      );
                    },
                  ),
                ],
              );
            },
          ),
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
    final uniqueCourses = _uniqueCourses(courses);
    final value =
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
        initialValue: value,
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
