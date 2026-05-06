import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/question_bank/question_form_cubit.dart';
import '../../../bloc/instructor/question_bank/question_form_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../widgets/instructor/question_bank/question_bank_barrel.dart';
import 'question_bank_create_screen.dart';

class QuestionBankEditScreen extends StatelessWidget {
  const QuestionBankEditScreen({super.key, required this.questionId});

  final int questionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionFormCubit(
        questionBankService: QuestionBankService(
          coreApiClient: CoreApiClient(),
        ),
      )..initializeEdit(questionId),
      child: _QuestionBankEditView(questionId: questionId),
    );
  }
}

class _QuestionBankEditView extends StatelessWidget {
  const _QuestionBankEditView({required this.questionId});

  final int questionId;

  @override
  Widget build(BuildContext context) {
    return _QuestionBankEditCourseLoader(questionId: questionId);
  }
}

class _QuestionBankEditCourseLoader extends StatefulWidget {
  const _QuestionBankEditCourseLoader({required this.questionId});

  final int questionId;

  @override
  State<_QuestionBankEditCourseLoader> createState() =>
      _QuestionBankEditCourseLoaderState();
}

class _QuestionBankEditCourseLoaderState
    extends State<_QuestionBankEditCourseLoader> {
  List<TeachingCourseModel> _courses = const [];
  bool _loadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final result = await EnrollmentService(
      coreApiClient: CoreApiClient(),
    ).getTeachingCourses();
    if (!mounted) return;
    setState(() {
      _courses = result.data ?? const <TeachingCourseModel>[];
      _loadingCourses = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionBankEditQuestion),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: BlocConsumer<QuestionFormCubit, QuestionFormState>(
        listenWhen: (previous, current) {
          final previousMessage =
              previous.validationError ??
              previous.errorMessage ??
              previous.successMessage;
          final currentMessage =
              current.validationError ??
              current.errorMessage ??
              current.successMessage;
          return currentMessage != null && currentMessage != previousMessage;
        },
        listener: (context, state) {
          final message =
              state.validationError ??
              state.errorMessage ??
              state.successMessage;
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizedQuestionBankMessage(l10n, message)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (_loadingCourses || state.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: QuestionBankSkeletons(itemCount: 4),
            );
          }
          return QuestionFormBody(
            courses: _courses,
            state: state,
            heroTitle: l10n.questionBankEditQuestion,
            heroSubtitle: l10n.questionBankStudioSubtitle,
            submitLabel: l10n.save,
            lockCourse: true,
            onSubmit: () async {
              if (state.originalQuestion?.status ==
                  QuestionBankStatus.approved) {
                final ok = await _confirmApprovedEdit(context);
                if (!ok) return;
                if (!context.mounted) return;
              }
              final ok = await context.read<QuestionFormCubit>().submit();
              if (ok && context.mounted) {
                context.go('/instructor/question-bank/${widget.questionId}');
              }
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmApprovedEdit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.qbApprovedEditWarningTitle),
            content: Text(l10n.qbApprovedEditWarningBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.save),
              ),
            ],
          ),
        ) ??
        false;
  }
}
