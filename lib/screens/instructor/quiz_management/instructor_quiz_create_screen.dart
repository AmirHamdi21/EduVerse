import 'dart:io';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_event.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/services/api/quiz_ai_service.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

class InstructorQuizCreateScreen extends StatefulWidget {
  const InstructorQuizCreateScreen({super.key});
  @override
  State<InstructorQuizCreateScreen> createState() => _CreateState();
}

class _CreateState extends State<InstructorQuizCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0 = details, 1 = questions
  bool _saving = false;

  // Detail fields
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _instructions = TextEditingController();
  final _timeLimit = TextEditingController();
  final _maxAttempts = TextEditingController(text: '1');
  final _passingScore = TextEditingController(text: '50');
  final _weight = TextEditingController(text: '1');
  int? _courseId;
  QuizTypeEnum _quizType = QuizTypeEnum.graded;
  bool _randomize = false;
  bool _showCorrect = false;
  ShowAnswersAfterEnum _showAfter = ShowAnswersAfterEnum.never;
  DateTime? _availFrom;
  DateTime? _availUntil;

  // Questions
  final List<_QuestionDraft> _questions = [];
  final Set<int> _expandedQuestions = <int>{};

  // AI generation
  final QuizAiService _aiService = QuizAiService();
  File? _aiFile;
  bool _aiLoading = false;
  int _aiNumQuestions = 5;
  String _aiQuestionType = 'MCQ';
  String _aiDifficulty = 'medium';

  @override
  void initState() {
    super.initState();
    final coursesBloc = context.read<InstructorCoursesBloc>();
    final coursesState = coursesBloc.state;
    if (coursesState is! InstructorCoursesLoaded &&
        coursesState is! InstructorCoursesLoading) {
      coursesBloc.add(const LoadTeachingCourses());
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _instructions.dispose();
    _timeLimit.dispose();
    _maxAttempts.dispose();
    _passingScore.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, ts) {
        final dk = ts.isDark;
        return Scaffold(
          backgroundColor: InstructorColors.background(dk),
          body: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: dk
                      ? InstructorColors.darkHeaderGradient
                      : InstructorColors.headerGradient,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _header(dk),
                    Expanded(
                      child: _step == 0 ? _detailsForm(dk) : _questionsForm(dk),
                    ),
                    _bottomBar(dk),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(bool dk) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Quiz',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                _step == 0 ? 'Step 1: Quiz Details' : 'Step 2: Add Questions',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        // Step indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_step + 1}/2',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _detailsForm(bool dk) => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(dk, 'Basic Info', [
          _field(
            dk,
            'Title *',
            _title,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          _field(dk, 'Description', _desc, lines: 3),
          const SizedBox(height: 14),
          _field(dk, 'Instructions', _instructions, lines: 2),
        ]),
        const SizedBox(height: 16),
        _card(dk, 'Settings', [
          _buildCourseSelector(dk),
          const SizedBox(height: 14),
          _dropdownRow(
            dk,
            'Quiz Type',
            _quizType.name,
            ['practice', 'graded', 'survey'],
            (v) => setState(() => _quizType = QuizTypeEnum.fromJson(v)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _field(dk, 'Time Limit (min)', _timeLimit, num: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(dk, 'Max Attempts', _maxAttempts, num: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _field(
                  dk,
                  'Passing Score (%)',
                  _passingScore,
                  num: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _field(dk, 'Weight', _weight, num: true)),
            ],
          ),
          const SizedBox(height: 14),
          _toggleRow(
            dk,
            'Randomize Questions',
            _randomize,
            (v) => setState(() => _randomize = v),
          ),
          const SizedBox(height: 10),
          _toggleRow(
            dk,
            'Show Correct Answers',
            _showCorrect,
            (v) => setState(() => _showCorrect = v),
          ),
          if (_showCorrect) ...[
            const SizedBox(height: 10),
            _dropdownRow(
              dk,
              'Show Answers After',
              _showAfter.toJson(),
              ['immediate', 'after_due', 'never'],
              (v) =>
                  setState(() => _showAfter = ShowAnswersAfterEnum.fromJson(v)),
            ),
          ],
        ]),
        const SizedBox(height: 16),
        _card(dk, 'Availability', [
          _dateRow(
            dk,
            'Available From',
            _availFrom,
            (d) => setState(() => _availFrom = d),
          ),
          const SizedBox(height: 14),
          _dateRow(
            dk,
            'Available Until',
            _availUntil,
            (d) => setState(() => _availUntil = d),
          ),
        ]),
        const SizedBox(height: 80),
      ],
    ),
  );

  Widget _aiPanel(bool dk) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      borderRadius: BorderRadius.circular(16),
      border: Border(
        left: BorderSide(color: InstructorColors.primary, width: 4),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: InstructorColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Generate questions with AI',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: InstructorColors.textPrimaryColor(dk),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a file (PDF, DOCX, TXT). AI-generated questions are added below and can be edited.',
          style: TextStyle(
            fontSize: 12,
            color: InstructorColors.textSecondaryColor(dk),
          ),
        ),
        const SizedBox(height: 12),
        // File picker
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                if (_courseId == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Select a course under Quiz Settings first — the AI service needs your course context.',
                      ),
                      backgroundColor: InstructorColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'docx', 'txt'],
                );
                if (result != null && result.files.single.path != null) {
                  setState(() => _aiFile = File(result.files.single.path!));
                }
              },
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: const Text('Choose File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _aiFile != null
                    ? _aiFile!.path.split(Platform.pathSeparator).last
                    : 'No file selected',
                style: TextStyle(
                  fontSize: 12,
                  color: _aiFile != null
                      ? InstructorColors.textPrimaryColor(dk)
                      : InstructorColors.textTertiaryColor(dk),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (_courseId == null) ...[
          const SizedBox(height: 10),
          Text(
            'Select a course under Quiz Settings first — the AI service needs your course context.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dk ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Config row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: InstructorColors.textSecondaryColor(dk),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: dk
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: InstructorColors.borderColor(
                          dk,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _aiNumQuestions,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: InstructorColors.cardColor(dk),
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(dk),
                          fontSize: 13,
                        ),
                        items: [3, 5, 10, 15, 20]
                            .map(
                              (n) =>
                                  DropdownMenuItem(value: n, child: Text('$n')),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _aiNumQuestions = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Style',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: InstructorColors.textSecondaryColor(dk),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: dk
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: InstructorColors.borderColor(
                          dk,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _aiQuestionType,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: InstructorColors.cardColor(dk),
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(dk),
                          fontSize: 13,
                        ),
                        items: QuizAiService.questionTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _aiQuestionType = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difficulty',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: InstructorColors.textSecondaryColor(dk),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: dk
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: InstructorColors.borderColor(
                          dk,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _aiDifficulty,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: InstructorColors.cardColor(dk),
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(dk),
                          fontSize: 13,
                        ),
                        items: QuizAiService.difficulties
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d[0].toUpperCase() + d.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _aiDifficulty = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Generate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_aiLoading || _aiFile == null || _courseId == null)
                ? null
                : _generateAiQuestions,
            icon: _aiLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome_rounded, size: 16),
            label: Text(_aiLoading ? 'Generating...' : 'Generate & Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: InstructorColors.primary.withValues(
                alpha: 0.4,
              ),
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _generateAiQuestions() async {
    if (_courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Select a course under Quiz Settings first — the AI service needs your course context.',
          ),
          backgroundColor: InstructorColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (_aiFile == null) return;
    setState(() => _aiLoading = true);
    try {
      final generated = await _aiService.generateQuestions(
        file: _aiFile!,
        numQuestions: _aiNumQuestions,
        questionType: _aiQuestionType,
        difficulty: _aiDifficulty,
      );
      setState(() {
        for (final q in generated) {
          final options = q.type == 'MCQ'
              ? q.paddedOptions
                    .map((o) => <String, dynamic>{'text': o})
                    .toList()
              : <Map<String, dynamic>>[];
          _questions.add(
            _QuestionDraft(
              questionText: q.questionText,
              type: q.mappedType,
              options: options,
              correctAnswer: q.type == 'MCQ'
                  ? q.guessMcqAnswerIndex()
                  : q.correctAnswer,
              explanation: q.reference,
              points: 1.0,
            ),
          );
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${generated.length} AI-generated question(s)'),
            backgroundColor: InstructorColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI generation failed: $e'),
            backgroundColor: InstructorColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Widget _questionsForm(bool dk) {
    if (_questions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _aiPanel(dk),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  size: 56,
                  color: InstructorColors.textTertiaryColor(dk),
                ),
                const SizedBox(height: 16),
                Text(
                  'No questions added yet',
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(dk),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use AI above or add manually below',
                  style: TextStyle(
                    color: InstructorColors.textTertiaryColor(dk),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _addQuestion(dk),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: InstructorColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: _questions.length + 2, // +1 for AI panel, +1 for add button
      itemBuilder: (_, i) {
        if (i == 0)
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _aiPanel(dk),
          );
        if (i == _questions.length + 1) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () => _addQuestion(dk),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Question'),
              style: OutlinedButton.styleFrom(
                foregroundColor: InstructorColors.primary,
                side: const BorderSide(color: InstructorColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          );
        }
        return _questionCard(dk, i - 1);
      },
    );
  }

  Widget _questionCard(bool dk, int idx) {
    final q = _questions[idx];
    final isExpanded = _expandedQuestions.contains(idx);
    final normalizedMcqAnswer = _resolveMcqCorrectAnswer(
      q.correctAnswer,
      q.options,
    );
    final mcqCorrectIndex = int.tryParse(normalizedMcqAnswer);
    final trueFalseCorrect = _normalizeTrueFalseCorrectAnswer(q.correctAnswer);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(dk),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                    color: InstructorColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q.questionText.isEmpty ? 'Untitled Question' : q.questionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: InstructorColors.textPrimaryColor(dk),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: InstructorColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  q.type.toJson(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: InstructorColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: InstructorColors.textTertiaryColor(dk),
                ),
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedQuestions.remove(idx);
                    } else {
                      _expandedQuestions.add(idx);
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: InstructorColors.textTertiaryColor(dk),
                ),
                onPressed: () => _editQuestion(dk, idx),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: InstructorColors.error,
                ),
                onPressed: () {
                  setState(() {
                    _questions.removeAt(idx);
                    _expandedQuestions.clear();
                  });
                },
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Text(
              q.questionText.isEmpty ? 'Untitled Question' : q.questionText,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(dk),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (q.type == QuestionTypeEnum.multipleChoice) ...[
              const SizedBox(height: 10),
              ...q.options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final optionText = (entry.value['text'] ?? '').toString();
                final isCorrect = mcqCorrectIndex == optionIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? InstructorColors.success.withValues(alpha: 0.12)
                        : (dk
                              ? Colors.white.withValues(alpha: 0.03)
                              : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCorrect
                          ? InstructorColors.success
                          : InstructorColors.borderColor(
                              dk,
                            ).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: isCorrect
                            ? InstructorColors.success
                            : InstructorColors.textTertiaryColor(dk),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          optionText.isEmpty
                              ? 'Option ${optionIndex + 1}'
                              : optionText,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(dk),
                            fontSize: 13,
                            fontWeight: isCorrect
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (q.type == QuestionTypeEnum.trueFalse) ...[
              const SizedBox(height: 10),
              _optionPreviewTile(dk, 'True', trueFalseCorrect == '0'),
              _optionPreviewTile(dk, 'False', trueFalseCorrect == '1'),
            ],
            if (q.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Explanation: ${q.explanation}',
                style: TextStyle(
                  fontSize: 12,
                  color: InstructorColors.textSecondaryColor(dk),
                ),
              ),
            ],
          ],
          const SizedBox(height: 8),
          Text(
            '${q.points} points',
            style: TextStyle(
              fontSize: 12,
              color: InstructorColors.textTertiaryColor(dk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(bool dk) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      border: Border(
        top: BorderSide(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
    ),
    child: Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(
                foregroundColor: InstructorColors.primary,
                side: const BorderSide(color: InstructorColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : (_step == 0 ? _goToQuestions : _saveQuiz),
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(_step == 0 ? 'Next: Add Questions' : 'Save Quiz'),
          ),
        ),
      ],
    ),
  );

  // ── Helpers ──

  Widget _card(bool dk, String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: InstructorColors.textPrimaryColor(dk),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );

  Widget _buildCourseSelector(bool dk) {
    return BlocBuilder<InstructorCoursesBloc, InstructorCoursesState>(
      builder: (context, state) {
        if (state is InstructorCoursesLoading) {
          return const LinearProgressIndicator(minHeight: 2);
        }

        if (state is! InstructorCoursesLoaded) {
          return _dropdownRow(dk, 'Course *', '', const [
            'Select course',
          ], (_) {});
        }

        final items = state.courses
            .map(
              (c) => DropdownMenuItem<int>(
                value: c.courseId,
                child: Text(c.course.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: InstructorColors.textSecondaryColor(dk),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: dk
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: InstructorColors.borderColor(
                    dk,
                  ).withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: items.any((i) => i.value == _courseId)
                      ? _courseId
                      : null,
                  hint: Text(
                    'Select course',
                    style: TextStyle(
                      color: InstructorColors.textTertiaryColor(dk),
                      fontSize: 14,
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: InstructorColors.cardColor(dk),
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(dk),
                    fontSize: 14,
                  ),
                  items: items,
                  onChanged: (v) => setState(() => _courseId = v),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _field(
    bool dk,
    String label,
    TextEditingController ctrl, {
    int lines = 1,
    bool num = false,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: InstructorColors.textSecondaryColor(dk),
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: lines,
        validator: validator,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          color: InstructorColors.textPrimaryColor(dk),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: dk
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: InstructorColors.borderColor(dk)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: InstructorColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    ],
  );

  Widget _toggleRow(
    bool dk,
    String label,
    bool val,
    ValueChanged<bool> onChanged,
  ) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: InstructorColors.textPrimaryColor(dk),
          ),
        ),
      ),
      Switch.adaptive(
        value: val,
        onChanged: onChanged,
        activeColor: InstructorColors.primary,
      ),
    ],
  );

  Widget _dropdownRow(
    bool dk,
    String label,
    String val,
    List<String> items,
    ValueChanged<String> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: InstructorColors.textSecondaryColor(dk),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: dk
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(val) ? val : items.first,
            isExpanded: true,
            dropdownColor: InstructorColors.cardColor(dk),
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(dk),
              fontSize: 14,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e[0].toUpperCase() + e.substring(1).replaceAll('_', ' '),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    ],
  );

  Widget _dateRow(
    bool dk,
    String label,
    DateTime? date,
    ValueChanged<DateTime?> onChanged,
  ) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (d != null && mounted) {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(date ?? DateTime.now()),
        );
        onChanged(
          t != null ? DateTime(d.year, d.month, d.day, t.hour, t.minute) : d,
        );
      }
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: InstructorColors.textSecondaryColor(dk),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: dk
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: InstructorColors.textTertiaryColor(dk),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                      : 'Select date & time',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null
                        ? InstructorColors.textPrimaryColor(dk)
                        : InstructorColors.textTertiaryColor(dk),
                  ),
                ),
              ),
              if (date != null)
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: InstructorColors.textTertiaryColor(dk),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  void _goToQuestions() {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _step = 1);
  }

  void _addQuestion(bool dk) {
    final q = _QuestionDraft();
    _showQuestionEditor(
      dk,
      q,
      (edited) => setState(() => _questions.add(edited)),
    );
  }

  void _editQuestion(bool dk, int idx) {
    _showQuestionEditor(
      dk,
      _questions[idx],
      (edited) => setState(() => _questions[idx] = edited),
    );
  }

  void _showQuestionEditor(
    bool dk,
    _QuestionDraft initial,
    ValueChanged<_QuestionDraft> onSave,
  ) {
    final txtCtrl = TextEditingController(text: initial.questionText);
    final expCtrl = TextEditingController(text: initial.explanation);
    final ptsCtrl = TextEditingController(text: initial.points.toString());
    var type = initial.type;
    var options = List<Map<String, dynamic>>.from(initial.options);
    var correctAnswer = initial.correctAnswer;
    if (type == QuestionTypeEnum.multipleChoice) {
      correctAnswer = _resolveMcqCorrectAnswer(correctAnswer, options);
    } else if (type == QuestionTypeEnum.trueFalse) {
      correctAnswer = _normalizeTrueFalseCorrectAnswer(correctAnswer);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(dk),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dk ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Question Editor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: InstructorColors.textPrimaryColor(dk),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        onSave(
                          _QuestionDraft(
                            questionText: txtCtrl.text,
                            type: type,
                            options: options,
                            correctAnswer: correctAnswer,
                            explanation: expCtrl.text,
                            points: double.tryParse(ptsCtrl.text) ?? 1,
                          ),
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    _dropdownRow(
                      dk,
                      'Question Type',
                      type.toJson(),
                      [
                        'mcq',
                        'true_false',
                        'short_answer',
                        'essay',
                        'matching',
                      ],
                      (v) => setBS(() => type = QuestionTypeEnum.fromJson(v)),
                    ),
                    const SizedBox(height: 14),
                    _field(dk, 'Question Text *', txtCtrl, lines: 3),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _field(dk, 'Points', ptsCtrl, num: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _field(dk, 'Explanation', expCtrl)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (type == QuestionTypeEnum.multipleChoice ||
                        type == QuestionTypeEnum.trueFalse) ...[
                      Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: InstructorColors.textSecondaryColor(dk),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (type == QuestionTypeEnum.trueFalse) ...[
                        _optionTile(
                          dk,
                          'True',
                          _normalizeTrueFalseCorrectAnswer(correctAnswer) ==
                              '0',
                          () => setBS(() {
                            correctAnswer = '0';
                            options = [
                              {'text': 'True'},
                              {'text': 'False'},
                            ];
                          }),
                        ),
                        _optionTile(
                          dk,
                          'False',
                          _normalizeTrueFalseCorrectAnswer(correctAnswer) ==
                              '1',
                          () => setBS(() {
                            correctAnswer = '1';
                            options = [
                              {'text': 'True'},
                              {'text': 'False'},
                            ];
                          }),
                        ),
                      ] else ...[
                        ...List.generate(options.length, (i) {
                          final oc = TextEditingController(
                            text: options[i]['text']?.toString() ?? '',
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: i,
                                  groupValue: int.tryParse(
                                    _resolveMcqCorrectAnswer(
                                      correctAnswer,
                                      options,
                                    ),
                                  ),
                                  activeColor: InstructorColors.primary,
                                  onChanged: (v) => setBS(
                                    () => correctAnswer = v?.toString() ?? '0',
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: oc,
                                    onChanged: (v) =>
                                        setBS(() => options[i] = {'text': v}),
                                    style: TextStyle(
                                      color: InstructorColors.textPrimaryColor(
                                        dk,
                                      ),
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Option ${i + 1}',
                                      hintStyle: TextStyle(
                                        color:
                                            InstructorColors.textTertiaryColor(
                                              dk,
                                            ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: InstructorColors.borderColor(
                                            dk,
                                          ),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: InstructorColors.error,
                                  ),
                                  onPressed: () =>
                                      setBS(() => options.removeAt(i)),
                                ),
                              ],
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () =>
                              setBS(() => options.add({'text': ''})),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Option'),
                          style: TextButton.styleFrom(
                            foregroundColor: InstructorColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(
    bool dk,
    String label,
    bool selected,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? InstructorColors.primary.withValues(alpha: 0.1)
            : InstructorColors.surfaceColor(dk),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? InstructorColors.primary
              : InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 20,
            color: selected
                ? InstructorColors.primary
                : InstructorColors.textTertiaryColor(dk),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(dk),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _optionPreviewTile(bool dk, String label, bool selected) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: selected
          ? InstructorColors.success.withValues(alpha: 0.12)
          : (dk
                ? Colors.white.withValues(alpha: 0.03)
                : const Color(0xFFF8FAFC)),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: selected
            ? InstructorColors.success
            : InstructorColors.borderColor(dk).withValues(alpha: 0.5),
      ),
    ),
    child: Row(
      children: [
        Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: selected
              ? InstructorColors.success
              : InstructorColors.textTertiaryColor(dk),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(dk),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );

  String _resolveMcqCorrectAnswer(
    dynamic correctAnswer,
    List<Map<String, dynamic>> options,
  ) {
    final raw = correctAnswer?.toString().trim() ?? '';
    if (raw.isEmpty) return '0';

    final parsedIndex = int.tryParse(raw);
    if (parsedIndex != null &&
        parsedIndex >= 0 &&
        parsedIndex < options.length) {
      return parsedIndex.toString();
    }

    final byText = options.indexWhere(
      (o) =>
          (o['text'] ?? '').toString().trim().toLowerCase() ==
          raw.toLowerCase(),
    );
    return byText >= 0 ? byText.toString() : '0';
  }

  String _normalizeTrueFalseCorrectAnswer(dynamic correctAnswer) {
    final raw = correctAnswer?.toString().trim().toLowerCase() ?? '';
    if (raw == 'true' || raw == '0') return '0';
    if (raw == 'false' || raw == '1') return '1';
    return '0';
  }

  Future<void> _saveQuiz() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quiz title is required'),
          backgroundColor: InstructorColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least one question'),
          backgroundColor: InstructorColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (_courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a course'),
          backgroundColor: InstructorColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      setState(() => _step = 0);
      return;
    }

    setState(() => _saving = true);
    final cubit = context.read<QuizManagementCubit>();

    final data = <String, dynamic>{
      'title': _title.text.trim(),
      if (_desc.text.trim().isNotEmpty) 'description': _desc.text.trim(),
      if (_instructions.text.trim().isNotEmpty)
        'instructions': _instructions.text.trim(),
      'courseId': _courseId,
      'quizType': _quizType.toJson(),
      if (_timeLimit.text.isNotEmpty)
        'timeLimitMinutes': int.tryParse(_timeLimit.text) ?? 0,
      'maxAttempts': int.tryParse(_maxAttempts.text) ?? 1,
      'passingScore': double.tryParse(_passingScore.text) ?? 50,
      'weight': double.tryParse(_weight.text) ?? 1,
      'randomizeQuestions': _randomize,
      'showCorrectAnswers': _showCorrect,
      'showAnswersAfter': _showAfter.toJson(),
      if (_availFrom != null) 'availableFrom': _availFrom!.toIso8601String(),
      if (_availUntil != null) 'availableUntil': _availUntil!.toIso8601String(),
    };

    // Create quiz — returns the model with the new ID
    final createdQuiz = await cubit.createQuiz(data);
    if (createdQuiz == null || !mounted) {
      if (mounted) setState(() => _saving = false);
      return;
    }

    final quizId = createdQuiz.id;

    // Add questions sequentially — matching web's QuizCreate.tsx handleSave
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      // Build question payload matching backend expectations
      final questionPayload = <String, dynamic>{
        'questionText': q.questionText,
        'questionType': q.type.toJson(),
        'points': q.points,
        if (q.explanation.isNotEmpty) 'explanation': q.explanation,
        'orderIndex': i,
      };

      if (q.type == QuestionTypeEnum.multipleChoice) {
        questionPayload['options'] = q.options
            .map((o) => (o['text'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();
        questionPayload['correctAnswer'] = _resolveMcqCorrectAnswer(
          q.correctAnswer,
          q.options,
        );
      } else if (q.type == QuestionTypeEnum.trueFalse) {
        questionPayload['options'] = ['True', 'False'];
        questionPayload['correctAnswer'] = _normalizeTrueFalseCorrectAnswer(
          q.correctAnswer,
        );
      } else if (q.type == QuestionTypeEnum.shortAnswer) {
        questionPayload['correctAnswer'] = q.correctAnswer?.toString() ?? '';
      } else if (q.type == QuestionTypeEnum.essay) {
        questionPayload['correctAnswer'] = null;
      } else if (q.type == QuestionTypeEnum.matching) {
        questionPayload['options'] = q.options
            .map((p) => p.toString())
            .toList();
        questionPayload['correctAnswer'] = null;
      }

      final createdQuestion = await cubit.addQuestion(quizId, questionPayload);
      if (createdQuestion == null) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add question ${i + 1}.'),
            backgroundColor: InstructorColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
    }

    if (mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quiz created successfully!'),
          backgroundColor: InstructorColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    }
  }
}

class _QuestionDraft {
  String questionText;
  QuestionTypeEnum type;
  List<Map<String, dynamic>> options;
  dynamic correctAnswer;
  String explanation;
  double points;

  _QuestionDraft({
    this.questionText = '',
    this.type = QuestionTypeEnum.multipleChoice,
    this.options = const [],
    this.correctAnswer,
    this.explanation = '',
    this.points = 1.0,
  });
}
